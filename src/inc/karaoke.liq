def karaoke(~vocal_volume=-18.0, s)
  %ifdef ladspa.karaoke
    off_vocal = ladspa.karaoke(s, vocal_volume=vocal_volume)
  %endif

  %ifndef ladspa.karaoke
    off_vocal = s
  %endif



  amplify(lin_of_dB(8.)+1., # make up gain
    add(weights=[100,65,40], # Mix up the boost
      [
          off_vocal,
          filter.iir.eq.low(frequency=180., q=0.5, s), # TODO: Add limiter
          filter.iir.eq.high(frequency=4000., q=0.8, s)
      ]
    )
  )
end
