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

multi = playlist.multi(id="multi", conf.playlists(conf), sequence=conf.sequence(conf), size=s.int("backlog_size", default=20))
multi = 
    if s.bool("replay_gain") then
        enable_replaygain_metadata()
        replaygain(multi)
    else
        multi
    end

xfader = gapless(multi)
main = mksafe(xfader)
output.ao(id="output", fallible=true, main)