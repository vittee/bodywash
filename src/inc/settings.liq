def settings.int(s, name, ~default=0)
    int_of_string(s[name], default=default)
end

def settings.bool(s, name, ~default=false)
    bool_of_string(s[name], default=default)
end