def notdup(~meta_key="artist",~size=20,~backlog,m)
    log = log(label="notdup")
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

def playlist.multi(~id,~sequence=[],~size=20, uris)
  log = log(label="playlist.multi")

  artist_backlog = ref []
  backlog_size = ref size

  all_playlists = ref [("",ref [])] # mutable map, k:string, v:mutable list # `v` is file list.

  sequence_started_at = ref 0.
  pl_sequences = ref [("", 0.)] # mutable list of, pair<filelist, duration>
  item_counter = ref 0

  track_pos = ref 0.
  restore_track_pos = ref 0.

  shutdown_in_progress = ref false

  def load_uri(uri)
      files =
        if file.is_directory(uri) then
            get_process_lines("find #{quote(uri)} -type f | sort")
        else
            list.map(snd, playlist.parse(uri))
        end

      randomized = list.sort(fun (x,y) -> int_of_float(random.float()), files)
      ref list.filter(string.match(pattern=!_audio_regex), randomized)
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

    if duration >= seq_timeout then
      sequence.circulate()
    elsif !item_counter >= list.length(!pl) then
      log("Playlist looped #{!item_counter} time, move to next playlist.")
      sequence.circulate(reshuffle=true)
    end

    current_seq = sequence.current()
    ref_files = playlists.of(fst(current_seq))

    file =
      if list.length(!ref_files) > 0 then
        shifted = list.shift_rotate(!ref_files, default="")

        selected = fst(shifted)
        ref_files := snd(shifted)

        log("Selected: #{selected}")

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
        ref_old := list.filter(file.exists, list.append(!ref_old, list.randomize(diff)))

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

  dump_file = "plm.#{id}.dump"

  def save_dump()
    # Truncate
    system("echo #{quote('# Bodywash playlist.multi dump')} > #{dump_file}")

    buffer = ref ""
    def dump(s)
      buffer := !buffer^"#{s}\n"
    end

    dump("[state]")
    dump("item_counter=#{!item_counter}")
    dump("duration="^string_of(gettimeofday() - !sequence_started_at))
    dump("track_pos="^string_of(!track_pos))
    dump("")

    dump("[backlog]")
    ignore(list.mapi(fun(i,e) -> begin
      dump("#{i}=#{e}")
      0
    end, !artist_backlog))
    dump("")

    dump("[sequence]")
    list.map(fun(e) -> begin
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

    system("echo #{quote(!buffer)} >> #{dump_file}")
  end

  server.register("#{id}.reload", fun(s) -> begin
    load_playlists()
    "OK"
  end)

  server.register("#{id}.dump", fun(s) -> begin
    save_dump()
    "Done"
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

    restore_track_pos := !track_pos

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

  s = request.dynamic(default_duration=5.0, length=5.0, fun() -> begin
    if !restore_track_pos > 0.0 then
      current_seq = sequence.current()
      ref_files = playlists.of(fst(current_seq))
      last = list.last(!ref_files, default="")

      request.create(last)
    else
      next()
    end
  end)

  source.on_shutdown(s, fun() -> begin
    shutdown_in_progress := true
    save_dump()
  end)

  last_track_remaining = ref 0.0
  add_timeout(fast=true, 0.1, fun() -> begin
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
  end)

  load_playlists()

  on_track(id=id, fun(m) -> begin
    track_pos := 0.0
    if !restore_track_pos > 0.0 then
      track_pos := !restore_track_pos
      source.seek(s, !restore_track_pos)

      restore_track_pos := 0.0
    else
      save_dump()
    end

  end, s)
end