## Installing OCaml and its package manager

```bash
$ brew install pkg-config ocaml opam
```

Once install,Iinitialize the `opam`
```bash
$ opam init
```

## Installing libraries.
```bash
$ opam depext pcre ogg vorbis theora flac mad lame fdkaac lo ao portaudio taglib cry yojson magic
$ opam install ogg vorbis theora flac mad lame fdkaac lo ao portaudio taglib cry yojson magic
```

## Install liquidsoap
```bash
$ opam install liquidsoap
```

## Make it available
```bash
$ ln -s $(opam config var bin)/liquidsoap /usr/local/bin
```