def gapless(s)
  log = log(label="gapless", level=2)

  high = -10.0
  medium = -30.0
  margin = 4.0  

  ending = ref false

  sb = on_blank(max_blank=1.2, min_noise=0.8, threshold=medium-(margin*2.0), track_sensitive=true, {
    if !ending then
      log("Blank detected at ending, force doing smart cross.")
      source.skip(s)
    end
  }, s)

  se = on_end(delay=15.0, fun(f, m) -> begin
    ending := true
  end, sb)

  st = on_track(fun(m) -> begin
    ending := false
  end, se)

  add = fun(a,b) -> add(normalize=false,[b,a])
  fout = fade.out(type="exp",duration=1.7)
  ffout = fade.out(type="exp",duration=0.85)
  add.out = fun(a,b) -> add(fout(a), b)
  fast.out = fun(a,b) -> add(ffout(a), b)

  def transition(a,b,ma,mb,sa,sb)
      if a < medium + margin then
        fast.out(sa, sb)
      elsif a <= medium and b <= medium and abs(a - b) <= margin then
        add.out(sa, sb)
      elsif b >= a + margin and a >= medium and b <= high then        
        add.out(sa, sb)
      elsif a >= b + margin and b >= medium and a <= high then
        add(sa, sb)
      elsif b >= a + margin and a <= medium and b <= high then
        add(sa, sb)
      else
        add.out(sa, sb)
      end
  end

  smart_cross(transition, width=0.5, duration=3.0, eat_blank(at_beginning=true,st))
end