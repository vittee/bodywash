def output.multi(~namespace="output", ~encoders, conf, s)
  result = ref []
  ready_count = ref 0

  def ready()
    ready_count := !ready_count + 1
    if !ready_count == list.length(!result) then
      ignore(server.execute("main_out.select 0 true"))
    end
  end

  list.iter(fun(r) -> begin
    let (name, detail) = r
    cnf = conf.parse_detail(detail)

    type = cnf["type"]

    id = cnf["id"]
    id = if id != "" then id else name end
    id = "#{namespace}_#{id}"

    samplerate = get("frame.audio.samplerate", default=44100)
    frame_duration = get("frame.duration", default=0.04)

    gain = interactive.float("#{id}_gain", 1.0)
    bus_source = amplify(gain, s)

    def get_encoder(~default)
      encoders.lookup(cnf["encoder"], encoders, default=default)
    end

    def pure_source(codec, s)
      if codec == "opus" or codec == "flac" then
        print.yellow("Streaming with #{codec} codec, does not support metadata update.")
        drop_metadata(s)
      else
        s
      end
    end

    def default_icecast_encoder()
      ("vorbis", encoder.vorbis(samplerate=samplerate,bitrate=96))
    end

    active_source =
      if type == "ao" then
        dev=cnf["dev"]
        options=if dev != "" then [("id", dev)] else [] end
        output.ao(id=id,
          on_start=ready,
          buffer_size=int_of_string(cnf["buffer_size"], default=4),
          options=options,
          bus_source
        )
      elsif type == "portaudio" then
        buflen = int_of_string(cnf["buflen"], default=int_of_float(float_of_int(samplerate) * frame_duration * 3.0))

        output.portaudio(id=id,
          on_start=ready,
          buflen=buflen,
          bus_source
        )
      elsif type == "harbor" then
        port = int_of_string(cnf["port"], default=8000)
        mount = cnf["mount"]

        if mount != "" then
          let (codec, encoder) = get_encoder(default=default_icecast_encoder())

          output.harbor(id=id,
            on_start=ready,
            encoding="UTF-8",
            port=port,
            mount=mount,
            encoder,
            pure_source(codec, bus_source)
          )
        else
          output.dummy(s)
        end
      elsif type == "icecast" then
        host = cnf["host"]
        port = int_of_string(cnf["port"], default=8000)
        mount = cnf["mount"]
        password = cnf["password"]
        public = bool_of_string(cnf["public"], default=false)
        description = cnf["description"]
        genre = cnf["genre"]

        if mount != "" then
          let (codec, encoder) = get_encoder(default=default_icecast_encoder())

          output.icecast(id=id,
            on_start=ready, encoding="UTF-8",
            host=host, port=port, mount=mount,
            password=password, public=public,
            description=description, genre=genre,
            encoder, pure_source(codec, bus_source)
          )
        else
          output.dummy(s)
        end
      elsif type == "ffplay" then
        output.external(id=id,
          on_start=ready,
          flush=true,
          %wav, "ffplay -i - -nodisp -autoexit -v -8", 
          bus_source
        )
      %ifdef output.gstreamer.audio
      elsif type == "gstreamer" then
        output.gstreamer.audio(id=id,
          on_start=ready,
          pipeline="audioconvert ! queue ! autoaudiosink",
          bus_source
        )
      %endif
      else
        output.dummy(s)
      end

    result := list.push(!result, active_source)
  end, conf)

  ignore(!result)
end