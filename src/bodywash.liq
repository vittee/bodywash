# Bodywash
%include "boostrap.liq"
 
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
  dump_file="#{basename(conf_file)}.dump",
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
  

output.multi(
  encoders=encoders.load(conf("encoders")), 
  conf("outputs"),
  compress(threshold=-6.0, ratio=12.0, gain=3.0, main)
)
