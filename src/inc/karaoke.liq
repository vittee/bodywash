%ifdef ladspa.karaoke
def karaoke(~vocal_volume=-18.0, s)  
    off_vocal = ladspa.karaoke(s, vocal_volume=vocal_volume)

    %ifndef ladspa.wider
        imager = audio_to_stereo
    %endif

    %ifdef ladspa.wider
        imager = ladspa.wider
    %endif

    amplify(lin_of_dB(3.)+1., # make up gain
        add(weights=[100,60,30], # Mix up the boost
        [
            off_vocal,
            imager(mean(filter.iir.eq.low(frequency=80., q=2.0, s))), # Use mono bass line for boosting
            imager(mean(filter.iir.eq.high(frequency=4000., q=0.8, s)))
        ]
        )
    )
end
%endif