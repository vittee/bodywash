def notdup(~meta_key="artist",~size=20,~backlog,m)
    log = log(label="notdup", level=2)
    v = string.case(m[meta_key],lower=true)

    if string.length(v) == 0 then
        log("Empty metadata for field #{meta_key}, considered as not duplicated.")
        true
    else
        if not list.mem(v,!backlog) then
            bl = if list.length(!backlog) == size then
                list.tl(!backlog)
            else
                !backlog
            end

            log("#{v} not found in backlog.")
            backlog := list.append(bl, [v])
            true
        else
            log("Duplicated #{v} found in backlog.")
            false
        end
    end
end

def playlist.multi(~id,~sequence=[],~size=20, ~dump_file="", ~auto_resume=true, uris)
  log = log(label="playlist.multi(#{id})", level=2)

  artist_backlog = ref []
  backlog_size = ref size

  all_playlists = ref [("",ref [])] # mutable map, k:string, v:mutable list # `v` is file list.

  sequence_started_at = ref 0.
  pl_sequences = ref [("", 0.)] # mutable list of, pair<listname, duration>

  # TODO: Remove item_counter, it causes confusion.
  item_counter = ref 0

  track_pos = ref 0.
  resume_track_pos = ref 0.
  resume_file = ref ""

  track = ref [("", "")]

  shutdown_in_progress = ref false

  def load_uri(uri)
      files =
        if file.is_directory(uri) then
          cmd = 
            if os.type == "Win32" then
              "dir #{uri} /s/b/a-d/on"
            else
              "find #{quote(uri)} -type f | sort"
            end

          get_process_lines(cmd)
        else
          list.map(snd, playlist.parse(uri))
        end

      files = list.map(fun(s) -> string.replace(pattern="[\r\n]", fun(m) -> "", s), files)

      randomized = list.sort(fun (x,y) -> int_of_float(random.float()), files)
      ref list.filter(string.match(pattern=!_audio_regex), randomized)
  end

  dump_file =
    if dump_file == "" then
      "plm.#{id}.dump"
    else
      dump_file
    end

  def save_dump()
    ignore(file.write(data="# Bodywash playlist.multi dump\n", dump_file))

    buffer = ref ""
    def dump(s)
      buffer := !buffer^"#{s}\n"
    end

    dump("[state]")
    dump("item_counter=#{!item_counter}")
    dump("duration=#{gettimeofday() - !sequence_started_at}")
    dump("track_pos=#{!track_pos}")
    dump("current=$(initial_uri)" % !track)
    dump("")

    dump("[backlog]")
    ignore(list.mapi(fun(i,e) -> begin
      dump("#{i}=#{e}")
      0
    end, !artist_backlog))
    dump("")

    dump("[sequence]")
    list.iter(fun(e) -> begin
      dump("#{fst(e)}=#{snd(e)}")
    end, !pl_sequences)
    dump("")

    dump("[playlists]")
    ignore(list.mapi(fun(i,e) -> begin
      dump("#{i}=#{fst(e)}")
    end, !all_playlists))
    dump("")

    list.iter(fun(e) -> begin
      section = "[*p:#{fst(e)}]"
      items = list.join(list.mapi(fun(i,f) -> "#{i}=#{f}", !snd(e)), separator="\n")
      dump("#{section}\n#{items}\n")
    end, !all_playlists)

    ignore(file.write(data=!buffer, append=true, dump_file))
  end  

  def playlists.lookup(name,list)
    list.fold(fun(ret, item) -> begin
        if list.length(!ret) == 0 then
          if fst(item) == name then
            snd(item)
          else
            ret
          end
        else
          ret
        end
      end,
      ref [], list
    )
  end

  def playlists.of(name)
    playlists.lookup(name, !all_playlists)
  end

  def playlists.shuffle(name)
    pl = playlists.of(name)
    pl := list.randomize(!pl)
  end

  def sequence.current()
    list.hd(!pl_sequences, default=("", 0.))
  end

  def sequence.circulate(~reshuffle=false)
    log("Circulate sequences.")

    pl_sequences := list.rotate(!pl_sequences, default=("", 0.))

    if reshuffle then
      name = fst(sequence.current())
      playlists.shuffle(name)
      save_dump()
    end

    sequence_started_at := gettimeofday()
    item_counter := 0
  end

  next_tried = ref 0
  def rec next(~force=false)
    current_seq = sequence.current()

    pl_name = fst(current_seq)
    seq_timeout = snd(current_seq)
    pl = playlists.of(pl_name)

    duration = (gettimeofday() - !sequence_started_at) / 60.
    log("Playlist played for #{duration}, Sequence Limit = #{seq_timeout}")

    end_of_playlist = !item_counter >= list.length(!pl)

    if (duration >= seq_timeout) or end_of_playlist then
      sequence.circulate(reshuffle=end_of_playlist)
    end

    current_seq = sequence.current()
    ref_files = playlists.of(fst(current_seq))

    file =
      if list.length(!ref_files) > 0 then
        shifted = list.shift_rotate(!ref_files, default="")

        selected = fst(shifted)
        ref_files := snd(shifted)

        selected
      else
        # this should never happen
        ""
      end

    req = request.create(file)
    meta = request.metadata(req)

    if force or notdup(backlog=artist_backlog, size=!backlog_size, meta) then
      next_tried := 0
      item_counter := !item_counter + 1
      print.green("$(artist) - $(title)" % meta)
      req
    else
      if !next_tried < !backlog_size then
        log("Duplicate found, retry next.")
        next_tried := !next_tried + 1
        next()
      else
        log("Can't find non-duplicated item.")
        # make some room and try again
        artist_backlog := list.tl(!artist_backlog)
        next()
      end
    end
  end

  def load_playlists()
    new_playlists = list.map(
      fun(item) -> begin
        (fst(item),load_uri(snd(item)))
      end,
      uris
    )

    all_playlists := list.fold(fun(a,e) -> begin
      name = fst(e)
      new = !snd(e)

      a = if list.mem_assoc(name, a) then
        ref_old = playlists.lookup(name, a)
        diff = list.diff(!ref_old, new)
        ref_old := list.filter(file.exists, list.append(list.randomize(diff), !ref_old,))

        list.push(list.remove_assoc(name, a), (name, ref_old))
      else
        list.append(a, [e])
      end

      list.remove_assoc("",a)
    end, !all_playlists, new_playlists)

    total = list.fold(
      fun(sum,item) -> begin
        sum+list.length(!snd(item))
      end,
      0,
      !all_playlists
    )

    log("Total files: #{total}")

    backlog_size :=
      if (total < size) then
        total
      else
        size
      end

    log("New backlog_size = #{!backlog_size}")
  end

  server.register(namespace=id, "reload", usage="reload", fun(s) -> begin
    load_playlists()
    save_dump()
    "OK"
  end)

  server.register(namespace=id, "dump", usage="dump", fun(s) -> begin
    save_dump()
    "Done"
  end)

  server.register(namespace=id, "backlog", usage="backlog", fun(s) -> begin
    list.join(!artist_backlog, separator="\n")
  end)

  server.register(namespace=id, "backlog.clear", usage="backlog.clear", fun(s) -> begin
    artist_backlog := []
    save_dump()
    "OK"
  end)

  server.register(namespace=id, "sequence", usage="sequence", fun(s) -> begin
    list.join(separator="\n",list.map(fun(e) -> begin
      "#{fst(e)}=#{snd(e)}"
    end, !pl_sequences))
  end)

  server.register(namespace=id, "playlists", usage="playlists", fun(s) -> begin
    list.join(separator="\n",list.map(fst,!all_playlists))
  end)

  def dump_playlist(name)
    name = if string.length(name) > 0 then
      fst(sequence.current())
    else
      name
    end

    list.join(separator="\n", list.mapi(fun(i,e) -> "#{i}=#{e}", !playlists.of(name)))
  end

  server.register(namespace=id, "playlist", usage="playlist <name>", dump_playlist)

  server.register(namespace=id, "playlist.current", usage="playlist.current", fun(s) -> begin
    dump_playlist(fst(sequence.current()))
  end)

  server.register(namespace=id, "plc", usage="plc", fun(s) -> begin
    dump_playlist(fst(sequence.current()))
  end)  

  def movef_playlist(name,index)
    ref_files = playlists.of(name)
    ref_files := list.movef(!ref_files, index=index, default="") 
    save_dump()
    list.hd(!ref_files,default="")
  end

  server.register(namespace=id, "playlist.movef", usage="playlist.movef <name> <index>", description="Move item <index> to the top of the playlist <name>", fun(s) -> begin
    args = string.split(s,separator=" ")
    name = list.hd(args,default="")
    index = int_of_string(list.hd(list.tl(args),default=""),default=0)
    movef_playlist(name,index)
  end)

  def movefc_playlist(s)
    movef_playlist(fst(sequence.current()),int_of_string(s))
  end

  server.register(namespace=id, "playlist.movefc", usage="playlist.movefc <index>", description="Move item <index> to the top of the current playlist", movefc_playlist)
  server.register(namespace=id, "plmfc", usage="plmfc <index>", description="Move item <index> to the top of the current playlist", movefc_playlist)

  server.register(namespace=id, "shuffle", usage="shuffle", description="Shuffle current playlist", fun(s) -> begin
    playlists.shuffle(fst(sequence.current()))
    save_dump()
    "OK"
  end)

  server.register(namespace=id, "sequence.next", usage="sequence.next", description="", fun(s) -> begin
    sequence.circulate()
    save_dump()
    "OK"    
  end)  

  server.register(namespace=id, "track", usage="track", fun(_s) -> begin
    l = list.map(fun(e) -> "#{fst(e)}=#{snd(e)}", !track)
    list.join(l, separator="\n")
  end)

  pl_sequences :=
    if list.length(sequence) > 0 then
      sequence
    else
      list.map(fun(p) -> (fst(p), 5.0), !all_playlists)
    end

  if file.exists(dump_file) then
    d = conf.load(dump_file)
    state = d("state")

    item_counter := int_of_string(state["item_counter"],default=0)
    sequence_started_at := gettimeofday() - float_of_string(state["duration"],default=0.0)
    track_pos := float_of_string(state["track_pos"],default=0.0)
    resume_file := state["current"]

    resume_track_pos := !track_pos

    artist_backlog := list.map(snd, d("backlog"))
    pl_sequences := list.map(fun(e) -> begin
      (fst(e), float_of_string(snd(e), default=5.0))
    end, d("sequence"))

    all_playlists := list.map(fun(e) -> begin
      name = snd(e)
      (name, ref list.map(snd, d("*p:#{name}")))
    end, d("playlists"))
  else
    sequence_started_at := gettimeofday()
  end

  s = request.dynamic(id=id, default_duration=5.0, length=5.0, {
    if !resume_file != "" then
      print.cyan("Resuming #{!resume_file} at #{!resume_track_pos}")

      last = !resume_file
      resume_file := ""

      request.create(last)
    else
      next()
    end
  })

  def identity_volume()
    1.
  end  

  # TODO: create a fader function based on the new mkfade() API
  # fade_volume = mkfade(type="exp", start=1.0, stop=0.0, duration=0.66, s)

  fader = ref identity_volume  

  server.register(namespace=id, "out", usage="out", description="Fade out", fun(_s) -> begin
    # TODO: assign the fader
    # fader := fade_volume
    "Not Implemented"
  end)

  source.on_shutdown(s, {
    shutdown_in_progress := true
    save_dump()
  })

  last_track_remaining = ref 0.0
  add_timeout(fast=true, 0.1, {
    # TODO: Use new source.time() API
    remaining = source.remaining(s)
    if remaining != !last_track_remaining then
      track_pos := !track_pos + 0.1
    end

    last_track_remaining := remaining

    if !shutdown_in_progress then
      -1.0
    else
      0.1
    end
  })

  load_playlists()

  source.out = on_track(id=id, fun(m) -> begin
    track := m
    if auto_resume and !resume_track_pos > 0.0 then
      track_pos := !resume_track_pos
      resume_track_pos := 0.0
      track_pos := source.seek(s, !track_pos)
    else
      track_pos := 0.0
      save_dump()
    end

    fader := identity_volume
  end, s)

  amplify(id=id, override="", !fader, source.out)
end