## Installing OCaml and its package manager

```bash
$ brew install pkg-config ocaml opam
```

Once install,Initialize the `opam`
```bash
$ opam init
```

## Installing libraries.
```bash
$ opam depext pcre ogg vorbis theora flac mad lame fdkaac lo ao portaudio taglib cry yojson magic samplerate
$ opam install ogg vorbis theora flac mad lame fdkaac lo ao portaudio taglib cry yojson magic samplerate
```

## Install liquidsoap
```bash
$ opam install liquidsoap
```

## Make it available
```bash
$ ln -s $(opam config var bin)/liquidsoap /usr/local/bin
```