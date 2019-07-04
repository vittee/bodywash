def replaygain(s)
  replay_gain = map_metadata(fun(m) -> begin
    if list.mem_assoc("replay_gain", m) then
        matches = string.extract(pattern="(.+)\\s*dB", m["replay_gain"])
        dB = float_of_string(string.trim(matches["1"]))
        list.append([("maximized_replay_gain", "#{dB_of_lin(lin_of_dB(dB))} dB")], m)
    else
        m
    end
  end, s)

  amplify(1.0, replay_gain, override="maximized_replay_gain")
end