def conf.load(file)
    regex = "(\r\n|\r|\n)"
    lines = list.filter(fun(l) -> l != "" and not string.match(pattern=regex, l), string.split(separator=regex, file.contents(file)))

    name = ref ""

    fp = list.fold(fun(rows, l) -> begin
        sm = string.extract(pattern="\[(.+)\]", l)

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

    fun(n) -> list.map(fun(f) -> snd(f), list.filter(fun(f) -> fst(f) == n, fp))
end