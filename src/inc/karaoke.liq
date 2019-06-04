%ifdef ladspa.karaoke
def karaoke(~vocal_volume=-18.0, s)  
    off_vocal = ladspa.karaoke(s, vocal_volume=vocal_volume)

    amplify(lin_of_dB(3.)+1., # make up gain
        add(weights=[100,60], # Mix up the boost
        [
            off_vocal,
            audio_to_stereo(mean(filter.iir.eq.low(frequency=80., q=2.0, s) )) # Use mono bass line for boosting
        ]
        )
    )
end
%endif