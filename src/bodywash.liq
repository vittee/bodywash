# Bodywash

%include "inc/ansi.liq"

print.red("Hello")

main = sine(440.0)
output.portaudio(id="outout", main)