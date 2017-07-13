def output.multi(~namespace="output", ~encoders, conf, s)
  result = ref []
  ready_count = ref 0

  def ready()
    ready_count := !ready_count + 1
    if !ready_count == list.length(!result) then
      ignore(server.execute("mixer.select 0 true"))
    end
  end

  list.iter(fun(r) -> begin
    name = fst(r)
    cnf = conf.parse_detail(snd(r))

    type = cnf["type"]
    id = if cnf["id"] != "" then namespace^"_"^cnf["id"] else "" end

    def get_encoder(~default)
      encoders.lookup(cnf["encoder"], encoders, default=default)
    end

    def pure_source(codec, s) 
      if codec == "opus" or codec == "flac" then
        print.yellow("Streaming with #{codec} codec, does not support metadata update.")
        drop_metadata(buffer(s, buffer=0.25))
      else
        s
      end      
    end

    def default_icecast_encoder()
      ("vorbis", encoder.vorbis(samplerate=44100,bitrate=96))
    end

    active_source = 
      if type == "ao" then
        buffer_size = int_of_string(cnf["buffer_size"], default=2)
        output.ao(id=id, buffer_size=buffer_size, fallible=true, on_start=ready, s)
      elsif type == "harbor" then
        port = int_of_string(cnf["port"], default=8000)
        mount = cnf["mount"]

        if mount != "" then
          encoder = get_encoder(default=default_icecast_encoder())
          codec = fst(encoder)
          encoder = snd(encoder)

          output.harbor(id=id, on_start=ready, encoding="UTF-8", port=port, mount=mount, encoder, pure_source(codec, s))
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
          encoder = get_encoder(default=default_icecast_encoder())
          codec = fst(encoder)
          encoder = snd(encoder)

          output.icecast(
            fallible=true,
            id=id, on_start=ready, encoding="UTF-8",
            host=host, port=port, mount=mount,
            password=password, public=public,
            description=description, genre=genre,
            encoder, pure_source(codec, s)
          )
        else
          output.dummy(s)
        end
      else
        output.dummy(s)      
      end

    result := list.push(!result, active_source)
  end, conf)

  !result
end