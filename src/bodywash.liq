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

        replay_gain = map_metadata(fun(m) -> begin
            if list.mem_assoc("replay_gain", m) then
                matches = string.extract(pattern="(.+)\s*dB", m["replay_gain"])
                dB = float_of_string(string.trim(matches["1"])) + 6.0
                list.append([("maximized_replay_gain", "#{dB_of_lin(lin_of_dB(dB))} dB")], m)
            else
                m
            end
        end, multi)

        amplify(1.0, replay_gain, override="maximized_replay_gain")
    else
        multi
    end

def gapless(s)
  ending = ref false

  sb = on_blank(max_blank=0.7, threshold=-36.0, {
    print.yellow("on blank #{ending}")
    if !ending then
      source.skip(s)
    end
  }, s)

  se = on_end(delay=3.5, fun(f, m) -> begin
    print.cyan("on end")
    ending := true
  end, sb)

  st = on_track(fun(m) -> begin
    print.green("on track")
    ending := false
  end, se)

  high = -10.0
  medium = -30.0
  margin = 4.0

  add = fun(a,b) -> add(normalize=false,[b,a])
  fout = fade.out(type="exp",duration=4.5)
  add.out = fun(a,b) -> add(fout(a), b)

  def transition(a,b,ma,mb,sa,sb)
      if a <= medium and b <= medium and abs(a - b) <= margin then
        add.out(sa, sb)
      elsif b >= a + margin and a >= medium and b <= high then        
        add.out(sa, sb)
      elsif a >= b + margin and b >= medium and a <= high then
        add(sa,sb)
      elsif b >= a + margin and a <= medium and b <= high then
        add(sa,sb)
      else
        add.out(sa, sb)
      end
  end

  smart_cross(transition, width=2.0, duration=3.5, eat_blank(at_beginning=true,st))
end

xfader = gapless(multi)
main = mksafe(xfader)
output.ao(id="output", fallible=true, main)