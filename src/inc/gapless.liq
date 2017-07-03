def gapless(s)
  ending = ref false

  sb = on_blank(max_blank=0.7, threshold=-39.0, {
    if !ending then
      source.skip(s)
    end
  }, s)

  se = on_end(delay=5.0, fun(f, m) -> begin
    ending := true
  end, sb)

  st = on_track(fun(m) -> begin
    ending := false
  end, se)

  high = -10.0
  medium = -30.0
  margin = 4.0

  add = fun(a,b) -> add(normalize=false,[b,a])
  fout = fade.out(type="exp",duration=3.0)
  add.out = fun(a,b) -> add(fout(a), b)

  def transition(a,b,ma,mb,sa,sb)
      if a <= medium and b <= medium and abs(a - b) <= margin then
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

  smart_cross(transition, width=2.0, duration=3.5, eat_blank(at_beginning=true,st))
end