def list.join(list,~separator=",") 
  list.fold(fun(a,e) -> begin
    a = if a != "" then a^separator else a end
    a^string_of(e)
  end, "", list)
end