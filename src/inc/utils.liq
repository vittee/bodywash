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

def list.rotate(a,~default)
  list.push(list.tl(a), list.hd(a, default=default))
end

def list.shift(a,~default)
  (list.hd(a,default=default), list.tl(a)) 
end

def list.shift_rotate(a,~default)
  hd = list.hd(a, default=default)
  (hd, list.push(list.tl(a), hd))
end

def list.last(a,~default)
  i = list.length(a)-1
  if i >= 0 then
    list.nth(a,i,default=default)
  else
    default
  end
end

def list.movef(a,~index,~default)
  item = list.nth(a,index,default=default)
  list.add(item,list.filter(fun(e) -> e != item,a))
end