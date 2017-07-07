# Bodywash
%include "boostrap.liq"

set("log.stdout", true)
set("server.telnet", true)
 
conf_file = argv(1)
if string.length(conf_file) == 0 then
    print.red("No configuration file specified.")
    exit(1)
end

if not file.exists(conf_file) then
    print.red("Configuration file was not found.")
    exit(1)
end

conf = conf.load(conf_file)
settings = conf.settings(conf)
s.int = settings.int(settings)
s.bool = settings.bool(settings)

multi = playlist.multi(id="multi", conf.playlists(conf), 
  sequence=conf.sequence(conf),
  size=s.int("backlog_size", default=20),
  auto_resume=s.bool("auto_resume", default=true)
)
add_skip_command(multi)

multi = 
    if s.bool("replay_gain") then
        enable_replaygain_metadata()
        replaygain(multi)
    else
        multi
    end

xfader = gapless(multi)
mixer = mix(id="mixer", [xfader])
warmup = blank(duration=0.7)
main = mksafe(sequence(merge=true,[warmup,mixer]))

def output.multi(~namespace="output", conf, s)
  result = ref []
  ready_count = ref 0

  def ready()
    ready_count := !ready_count + 1
    if !ready_count == list.length(!result) then
      ignore(server.execute("mixer.select 0 true"))
    end
  end

  list.iter(fun(r) -> begin
    name = fst(r)
    cnf = list.map(
      fun(e) -> begin 
        e = string.split(separator=":",e)
        (list.nth(e,0,default=""), list.nth(e,1,default="")) 
      end, 
      string.split(separator="\,", snd(r))
    )

    type = cnf["type"]
    id = if cnf["id"] != "" then namespace^"_"^cnf["id"] else "" end

    if type == "ao" then
      buffer_size = int_of_string(cnf["buffer_size"], default=2)
      result := list.push(!result, output.ao(id=id, buffer_size=buffer_size, fallible=true, on_start=ready, s))
    elsif type == "harbor" then
      format = cnf["format"]
      encoder =
        if format == "aac" then
          %fdkaac
        elsif format == "mp3" then
          %mp3
        else
          %vorbis
        end

      port = int_of_string(cnf["port"], default=8000)
      mount = cnf["mount"]

      if mount != "" then
        print.cyan("Harbor")
        result := list.push(!result, output.harbor(id=id, fallible=true, on_start=ready, encoding="UTF-8", port=port, mount=mount, encoder, s))
      end
    end
  end, conf)
end

output.multi(conf("outputs"), main)

# output.ao(id="output", buffer_size=4, fallible=true, on_start=fun() -> ignore(server.execute("mixer.select 0 true")), main)