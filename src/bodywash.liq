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

playing_pos = ref 0.0

def post_json(url, data)
  ignore(http.post(url, data=json_of(data), headers=[("Content-Type", "application/json")], timeout=0.5))
end

multi = playlist.multi(id="ml", conf.playlists(conf), 
  sequence=conf.sequence(conf),
  dump_file="#{path.basename(conf_file)}.dump",
  size=s.int("backlog_size", default=20),
  auto_resume=s.bool("auto_resume", default=true),
  track_callback=fun(m,p) -> begin
    url = settings["on_track"]
    if url != "" then
      data = list.add(("position_ms", string_of(!p*1000.0)), m)
      data = list.add(("sending_time_ms", string_of(time()*1000.0)), data)
      data = list.add(("frame_duration", string_of(get("frame.duration", default=0.04)*1000.0)), data)
      post_json(url, data)
    end
    ()
  end,
  pos_callback=fun(p) -> begin
    playing_pos := p
  end
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
  compress(threshold=-9.0, ratio=9.0, gain=2.0, mksafe(main_out))
)