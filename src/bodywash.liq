# Bodywash

set("log.stdout", true)
%include "boostrap.liq"

multi = playlist.multi(id="multi", 
    [
        ("chill", "/Volumes/Data/Musics/liq/chill")        
    ]
)

main = multi
output.portaudio(id="outout", mksafe(main))