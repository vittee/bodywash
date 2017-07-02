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

multi = playlist.multi(id="multi", conf("playlists"))
conf = conf.load(conf_file)

main = multi
output.portaudio(id="outout", mksafe(main))