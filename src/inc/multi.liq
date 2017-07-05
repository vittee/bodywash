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

  all_playlists = ref [('',ref [])] # mutable map, k:string, v:mutable list # `v` is file list.

  sequence_started_at = ref 0.
  pl_sequences = ref [(ref [], 0.)] # mutable list of, pair<filelist, duration>
  seq_cursor = ref 0
  item_counter = ref 0

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

  def sequence.current()
    list.hd(!pl_sequences, default=(ref [], 0.))
  end

  def sequence.circulate(~reshuffle=false)
    log("Circulate sequences.")

    pl_sequences := list.rotate(!pl_sequences, default=(ref [], 0.))

    print.green(pl_sequences)

    if reshuffle then
      current_seq = sequence.current()

      list = fst(current_seq)
      d = snd(current_seq)

      list := list.sort(fun (x,y) -> int_of_float(random.float()), !list)
      print.cyan("Shuffled #{!list}")
    end    

    sequence_started_at := gettimeofday()
    item_counter := 0
  end

  next_tried = ref 0
  def rec next()
    current_seq = sequence.current()

    duration = (gettimeofday() - !sequence_started_at) / 60.
    seq_limit = snd(current_seq)

    log("Playlist played for #{duration}, Sequence Limit = #{seq_limit}")

    if duration >= seq_limit then
      sequence.circulate()
    elsif !item_counter >= list.length(!fst(current_seq)) then
      print.red("Playlist loop, move to next playlist.")
      sequence.circulate(reshuffle=true)      
    end

    current_seq = sequence.current()
    ref_files = fst(current_seq)

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

    if notdup(backlog=artist_backlog, size=!backlog_size, meta) then
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

  all_playlists := list.map(
    fun(item) -> begin
      (fst(item),load_uri(snd(item)))
    end,
    uris
  )
  total = list.fold(
    fun(sum,item) -> begin
      sum+list.length(!snd(item))
    end,
    0,
    !all_playlists
  )

  log("Total files: #{total}")

  def playlists.of(name)
    ret = ref []

    list.iter(
      fun(item) -> begin
        if list.length(!ret) == 0 then
          if fst(item) == name then
            ret := !snd(item)
          end
        end
      end,
      !all_playlists
    )

    ret
  end

  # Build list of playlists [(ref [file], float)]
  pl_sequences := list.map(
    fun(seq) -> begin
      name = fst(seq)
      duration = snd(seq)

      (playlists.of(name), duration)
    end,
    if list.length(sequence) > 0 then
      sequence
    else
      list.map(fun(p) -> (fst(p), 5.0), !all_playlists)
    end
  )

  if (total < !backlog_size) then
    backlog_size := total
    log("Adjust backlog_size to #{!backlog_size}")
  end

  # Pick from sequence
  # current_seq := list.hd(!pl_sequences, default=(ref [], 0.))
  sequence_started_at := gettimeofday()
  request.dynamic(id=id, default_duration=5.0, length=5.0, next)
end