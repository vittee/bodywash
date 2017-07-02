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

  all_playlists = ref [('',ref [])] # multable map, k:string, v:mutable list # `v` is file list.

  sequence_started_at = ref 0.;
  pl_sequences = ref [(ref [], 0.)] # mutable list of, pair<filelist, duration>
  cur_seq = ref (ref [], 0.) # reference to current pair<filelist, duration>

  def load_uri(uri)
      files = 
          if file.is_directory(uri) then
              get_process_lines("find #{quote(uri)} -type f | sort")
          else 
              # TODO: Resolve playlist
              []
          end
          
      randomized = list.sort(fun (x,y) -> int_of_float(random.float()), files)
      ref list.filter(string.match(pattern="(flac|mp3)$"), randomized)
  end

  def circulate_sequences()
    log("Circulate sequences.")
    pl_sequences := list.tl(list.append(!pl_sequences, [!cur_seq]))
    cur_seq := list.hd(!pl_sequences, default=(ref [], 0.))
    sequence_started_at := gettimeofday()
  end  

  def rec next()
    duration = (gettimeofday() - !sequence_started_at) / 60.
    seq_limit = snd(!cur_seq)

    log("Playlist played for #{duration}, Sequence Limit = #{seq_limit}")

    if duration >= seq_limit then
      circulate_sequences()
    end

    ref_files = fst(!cur_seq)
    file = 
      if list.length(!ref_files) > 0 then
        selected = list.hd(!ref_files, default="")
        ref_files := list.tl(!ref_files) # remove head, tail remains
        if selected != "" then
          log("Selected: #{selected}")
          ref_files := list.append(!ref_files, [selected])
        end
        selected
      else
        # this should never happen
        ""
      end

    req = request.create(file)
    if notdup(backlog=artist_backlog, size=!backlog_size, request.metadata(req)) then      
      req
    else
      next()
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
    log("Adjust backlog_size")
    backlog_size := total / 3
  end

  # Pick from sequence
  cur_seq := list.hd(!pl_sequences, default=(ref [], 0.))
  sequence_started_at := gettimeofday()
  request.dynamic(id=id, default_duration=5.0, length=5.0, next)
end