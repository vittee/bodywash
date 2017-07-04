def list.join(list,~separator=",") 
  list.fold(fun(a,e) -> begin
    a = if a != "" then a^separator else a end
    a^string_of(e)
  end, "", list)
end

def list.push(l,e)
  list.append(l,[e])
end

def list.diff(a,b)
    list.filter(fun(e) -> not list.mem(e,a), b)
end

def list.intersect(a,b)
    list.filter(fun(e) -> list.mem(e,b), a)
end

def list.union(a,b)
    list.append(a, list.diff(a,b))
end

def list.unique(a)
    list.fold(fun(l,e) -> begin
        if not list.mem(e,l) then
            list.append(l, [e])
        else
            l 
        end
    end, [], a)
end

def list.rotate(a)
  list.push(list.tl(a), list.hd(a, default=""))
end

def list.shift(a,~default="")
  (list.hd(a,default=default), list.tl(a)) 
end

def list.shift_rotate(a,~default="")
  hd = list.hd(a, default="")
  (hd, list.push(list.tl(a), hd))
end