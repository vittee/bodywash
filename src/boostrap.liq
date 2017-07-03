def _audio_ext = ref [] end
def _audio_regex = ref "" end

def boot()
  xpath = "/all/section/label[text()='file decoding']/../section/label"
  fmts = get_process_output("liquidsoap --list-plugins-xml | xmllint --xpath #{quote(xpath)} - | sed -nE 's/<label>([^<]+)<\/label>/\1 /pg'")

  decoders = string.split(separator=" ", string.case(string.trim(fmts)))

  _audio_ext := list.filter(fun(d) -> d != "", list.map(fun(d) -> begin
    if d == "mad" then
        "mp3"
    elsif d == "flac" then
        "flac"
    elsif d == "wav" then
        "wav"
    else
        ""
    end
  end, decoders))

  _audio_regex := "\.("^list.fold(fun(a,e) -> begin
    a = if a != "" then a^"|" else a end
    a^e 
  end, "", !_audio_ext)^")$"
end

%include "inc/ansi.liq"
%include "inc/conf.liq"
%include "inc/settings.liq"
%include "inc/multi.liq"
%include "inc/gapless.liq"
%include "inc/replaygain.liq"

boot()