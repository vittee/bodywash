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

if s.bool("replay_gain") then        
  enable_replaygain_metadata()
end

multi = playlist.multi(id="ml", conf.playlists(conf), 
  sequence=conf.sequence(conf),
  dump_file="#{path.basename(conf_file)}.dump",
  size=s.int("backlog_size", default=20),
  auto_resume=s.bool("auto_resume", default=true)
)
add_skip_command(multi)

replaygain = amplify(id="replaygain", 1.0, multi, override="replay_gain")
player = gapless(id="gapless", replaygain)

%ifndef ladspa.karaoke
  patch = player
%endif

%ifdef ladspa.karaoke
  karaoke_on = interactive.bool("karaoke", false)
  karaoke_switch = switch(track_sensitive=false, [
    (karaoke_on, karaoke(player, vocal_volume=-40.0)),
    ({not karaoke_on()}, player)
  ])

  # off vocal [-1.0] --- mixed [0.0] --- full vocal [1.0]
  xfader_getter = interactive.float("xfader", -1.)
  xfader = add([  
    amplify({ 1. - (clamp(xfader_getter(), -1., 1.) + 1.) / 2. }, karaoke_switch),
    amplify({ (clamp(xfader_getter(), -1., 1.) + 1.) / 2. }, player)
  ])
  patch = xfader
%endif


main_out = mix(id="main_out", [patch])

output.multi(
  encoders=encoders.load(conf("encoders")),
  conf("outputs"),
  compress(threshold=-6.0, ratio=12.0, gain=3.0, mksafe(main_out))
)