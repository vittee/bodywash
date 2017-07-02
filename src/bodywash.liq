# Bodywash

# set("log.stdout", true)
%include "boostrap.liq"
 
conf_file = argv(1)
if string.length(conf_file) == 0 then
    print.red("No configuration file specified.")
    shutdown()
end

if not file.exists(conf_file) then
    print.red("Configuration file was not found.")
    shutdown()
end

conf = conf.load(conf_file)
settings = conf.settings(conf)

multi = playlist.multi(id="multi", conf.playlists(conf), sequence=conf.sequence(conf), size=int_of_string(settings["backlog_size"], default=20))
xfader = smart_crossfade(start_next=3.5,fade_in=0.,medium=-22.0,margin=5.0,eat_blank(at_beginning=true,max_blank=1.2,multi))
main = mksafe(xfader)

output.portaudio(id="outout", main)