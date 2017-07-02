def ansi.cc(~a=0,~c=0,s,~a=0)
    "\027[#{a};#{c}m#{s}"
end

def ansi.red(s,~a=0,~a=0)
    ansi.cc(s,c=31,a=a)
end

def ansi.green(s,~a=0)
    ansi.cc(s,c=32,a=a)
end

def ansi.yellow(s,~a=0)
    ansi.cc(s,c=33,a=a)
end

def ansi.purple(s,~a=0)
    ansi.cc(s,c=35,a=a)
end

def ansi.cyan(s,~a=0)
    ansi.cc(s,c=36,a=a)
end

def print.red(s,~a=0)
    print("#{ansi.red(s,a=a)}\027[0m")
end

def print.green(s,~a=0)
    print("#{ansi.green(s,a=a)}\027[0m")
end

def print.yellow(s,~a=0)
    print("#{ansi.yellow(s,a=a)}\027[0m")
end

def print.purple(s,~a=0)
    print("#{ansi.purple(s,a=a)}\027[0m")
end

def print.cyan(s,~a=0)
    print("#{ansi.cyan(s,a=a)}\027[0m")
end