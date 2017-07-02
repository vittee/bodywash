# Bodywash
%include "boostrap.liq"

set("log.stdout", true)
 
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

multi = playlist.multi(id="multi", conf.playlists(conf), sequence=conf.sequence(conf), size=s.int("backlog_size", default=20))
multi = 
    if s.bool("replay_gain") then
        enable_replaygain_metadata()

        replay_gain = map_metadata(fun(m) -> begin
            if list.mem_assoc("replay_gain", m) then
                matches = string.extract(pattern="(.+)\s*dB", m["replay_gain"])
                dB = float_of_string(string.trim(matches["1"]))
                list.append([("maximized_replay_gain", "#{dB_of_lin(lin_of_dB(dB) + 1.0)} dB")], m)
            else
                m
            end
        end, multi)

        amplify(1.0, replay_gain, override="maximized_replay_gain")
    else
        multi
    end

xfader = smart_crossfade(start_next=3.5,fade_in=0.,medium=-22.0,margin=5.0,eat_blank(at_beginning=true,max_blank=0.5,multi))
main = mksafe(sequence([blank(duration=1.0),xfader],merge=true))
output.portaudio(id="outout", main)