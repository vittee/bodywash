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

def playlist.multi(~id="",~sequence=[],~size=20, uris)
  log = log(label="playlist.multi")

  artist_backlog = ref []
  backlog_size = ref size

  all_playlists = ref [('',ref [])] # mutable map, k:string, v:mutable list # `v` is file list.

  sequence_started_at = ref 0.
  pl_sequences = ref [(ref [], 0.)] # mutable list of, pair<filelist, duration>
  current_seq = ref (ref [], 0.) # reference to current pair<filelist, duration>
  seq_cursor = ref 0
  item_cursor = ref 0

  def load_uri(uri)
      files = 
        if file.is_directory(uri) then
            get_process_lines("find #{quote(uri)} -type f | sort")
        else 
            # TODO: Resolve playlist file
            []
        end
          
      randomized = list.sort(fun (x,y) -> int_of_float(random.float()), files)     
      ref list.filter(string.match(pattern=!_audio_regex), randomized)
  end

  def circulate_sequences()
    log("Circulate sequences.")
    # pl_sequences := list.tl(list.append(!pl_sequences, [!current_seq]))
    # current_seq := list.hd(!pl_sequences, default=(ref [], 0.))
    index = !seq_cursor
    current_seq := list.nth(!pl_sequences, index, default=(ref [], 0.))
    seq_cursor := (index + 1) mod list.length(!pl_sequences)
    sequence_started_at := gettimeofday()
    item_cursor := 0
  end  

  next_tried = ref 0
  def rec next()
    duration = (gettimeofday() - !sequence_started_at) / 60.
    seq_limit = snd(!current_seq)

    log("Playlist played for #{duration}, Sequence Limit = #{seq_limit}")

    if duration >= seq_limit then
      circulate_sequences()
    end

    def rec pick()
      ref_files = fst(!current_seq)

      print.yellow("pick from #{!ref_files}")

      if list.length(!ref_files) > 0 then
        index = !item_cursor
        selected = list.nth(!ref_files, index, default="")

        if index >= list.length(!ref_files) then
          print.red("End of list, circulate.")
          circulate_sequences()
          pick()
        else
          item_cursor := index + 1
          selected
        end        
      else
        # this should never happen
        ""
      end
    end

    file = pick()
    req = request.create(file)
    
    result = if notdup(backlog=artist_backlog, size=!backlog_size, request.metadata(req)) then
      next_tried := 0
      req
    else
      print.red(!next_tried)
      
      if !next_tried < !backlog_size then
        log("Duplicate found, retry next.")
        next_tried := !next_tried + 1
        next()
      else
        # Don't know what to do here, simply allow duplicates.        
        log("Can't find non-duplicated item.")
        artist_backlog := []
        next_tried := 0
        req
      end
    end

    result
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
  current_seq := list.hd(!pl_sequences, default=(ref [], 0.))
  sequence_started_at := gettimeofday()
  request.dynamic(id=id, default_duration=5.0, length=5.0, next)
end