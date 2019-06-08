def gapless(s,~id="")
  log = log(label="gapless", level=2)

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

  cross_duration = 2.5

  add = fun(a,b) -> add(normalize=false,[b,a])
  soon = fade.out(type="exp",duration=cross_duration*0.88) # Start fading sooner
  late = fade.out(type="exp",duration=cross_duration*0.4) # Start fading lately

  out.soon = fun(a,b) -> add(soon(a), b)
  out.late = fun(a,b) -> add(late(a), b)

  def transition(a,b,ma,mb,sa,sb)
    sooner =
      if (a - b) >= 12.0 then
        true
      elsif abs(a - b) < 12.0 then
        true
      else
        false
      end

    f =
      if sooner then
        print.purple("Crossfade: Sooner")
        out.soon
      else
        print.purple("Crossfade: Later")
        out.late
      end

    f(sa, sb)
  end

  %ifdef cross
    x = cross
  %endif

  %ifdef smart_cross
    x = smart_cross
  %endif

  x(id=id, transition, width=0.7, duration=cross_duration, eat_blank(at_beginning=true,st))
end