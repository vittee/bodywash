def conf.load(file)
  regex = "(\\r\\n|\\r|\\n)"
  lines = list.filter(
      fun(l) -> begin
          l != "" and not string.match(pattern=regex, l) and (string.sub(l, start=0, length=1) != "#")
      end,
      string.split(separator=regex, file.contents(file))
  )

  name = ref ""

  fp = list.fold(fun(rows, l) -> begin
      sm = string.extract(pattern="^\\[(.+)\\]$", l)

      if list.mem_assoc("1", sm) then
          name := sm["1"]
          rows
      else
          kv = string.extract(pattern="([^=]+)=(.+)", l)
          if list.mem_assoc("2", kv) then
              list.append(rows, [(!name, (kv["1"], kv["2"]))])
          else
              rows
          end
      end
  end, [], lines)

  fun(n) -> list.map(snd, list.filter(fun(f) -> fst(f) == n, fp))
end

def conf.settings(conf)
  conf("settings")    
end

def conf.playlists(conf)
  conf("playlists")
end

def conf.sequence(conf)
  list.map(fun(kv) -> (fst(kv), float_of_string(snd(kv))), conf("sequence"))
end

def conf.parse_detail(s) 
  list.map(
    fun(e) -> begin 
      e = string.split(separator=":",e)
      (list.nth(e,0,default=""), list.nth(e,1,default="")) 
    end, 
    string.split(separator="\\,", s)
  )
end