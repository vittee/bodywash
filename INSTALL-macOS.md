## Installing OCaml and its package manager

```bash
$ brew install pkg-config ocaml opam libffi gnu-sed
```

Once install, Initialize the `opam`
```bash
$ opam init
$ export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/usr/local/opt/libffi/lib/pkgconfig"
```

## Installing libraries.
```bash
$ opam depext pcre ogg vorbis opus flac mad lame faad fdkaac lo ao portaudio taglib cry yojson magic samplerate gstreamer
$ opam install ogg vorbis opus flac mad lame faad fdkaac lo ao portaudio taglib cry yojson magic samplerate gstreamer
```

## LADSPA (Optional)
```bash
$ opam depext ladspa
$ opam install ladspa
```

### Install LADSPA Plugins
```bash
$ brew install gettext fftw
$ export PATH=${PATH}:/usr/local/opt/gettext/bin

$ git clone https://github.com/swh/ladspa.git
$ cd ladspa
$ autoreconf -i
$ ./configure
$ make
$ make install

$ wget http://quitte.de/dsp/caps_0.9.26.tar.bz2
$ tar xvf caps_0.9.26.tar.bz2
$ cd caps_0.9.26
$ ./configure.py
$ make
$ install -m 644 caps.so /usr/local/lib/ladspa/
```
TODO: TAP, CMT

## Install liquidsoap
```bash
$ opam install liquidsoap
```

## Make it available
```bash
$ ln -s $(opam config var bin)/liquidsoap /usr/local/bin
```
