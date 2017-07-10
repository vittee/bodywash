%include "inc/ansi.liq"
%include "inc/utils.liq"

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

  if list.length(!_audio_ext) == 0 then
    _audio_ext := ["mp3", "ogg", "flac", "wav"]
  end

  _audio_regex := "\.(#{list.join(!_audio_ext,separator='|')})$"
  set("server.telnet", true)
  set("server.timeout", 180.0)
  set("audio.converter.samplerate.libsamplerate.quality", "best")  
end

%include "inc/conf.liq"
%include "inc/settings.liq"
%include "inc/multi.liq"
%include "inc/gapless.liq"
%include "inc/replaygain.liq"
%include "inc/encoder.liq"
%include "inc/multioutput.liq"

boot()