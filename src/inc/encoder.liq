%ifencoder %mp3
def encoder.mp3_48k(bitrate)
  if bitrate == 320 then
    %mp3(bitrate=320, samplerate=48000)
  elsif bitrate == 256 then
    %mp3(bitrate=256, samplerate=48000)
  elsif bitrate == 224 then
    %mp3(bitrate=224, samplerate=48000)
  elsif bitrate == 192 then
    %mp3(bitrate=192, samplerate=48000)
  elsif bitrate == 160 then
    %mp3(bitrate=160, samplerate=48000)
  elsif bitrate == 144 then
    %mp3(bitrate=144, samplerate=48000)
  elsif bitrate == 128 then
    %mp3(bitrate=128, samplerate=48000)
  elsif bitrate == 112 then
    %mp3(bitrate=112, samplerate=48000)
  elsif bitrate == 96 then
    %mp3(bitrate=96, samplerate=48000)
  elsif bitrate == 80 then
    %mp3(bitrate=80, samplerate=48000)
  elsif bitrate == 64 then
    %mp3(bitrate=64, samplerate=48000)
  elsif bitrate == 56 then
    %mp3(bitrate=56, samplerate=48000)
  elsif bitrate == 48 then
    %mp3(bitrate=48, samplerate=48000)
  elsif bitrate == 40 then
    %mp3(bitrate=40, samplerate=48000)
  elsif bitrate == 32 then
    %mp3(bitrate=32, samplerate=48000)
  else
    %mp3(bitrate=128, samplerate=48000)
  end
end

def encoder.mp3_44_1k(bitrate)
  if bitrate == 320 then
    %mp3(bitrate=320, samplerate=44100)
  elsif bitrate == 256 then
    %mp3(bitrate=256, samplerate=44100)
  elsif bitrate == 224 then
    %mp3(bitrate=224, samplerate=44100)
  elsif bitrate == 192 then
    %mp3(bitrate=192, samplerate=44100)
  elsif bitrate == 160 then
    %mp3(bitrate=160, samplerate=44100)
  elsif bitrate == 144 then
    %mp3(bitrate=144, samplerate=44100)
  elsif bitrate == 128 then
    %mp3(bitrate=128, samplerate=44100)
  elsif bitrate == 112 then
    %mp3(bitrate=112, samplerate=44100)
  elsif bitrate == 96 then
    %mp3(bitrate=96, samplerate=44100)
  elsif bitrate == 80 then
    %mp3(bitrate=80, samplerate=44100)
  elsif bitrate == 64 then
    %mp3(bitrate=64, samplerate=44100)
  elsif bitrate == 56 then
    %mp3(bitrate=56, samplerate=44100)
  elsif bitrate == 48 then
    %mp3(bitrate=48, samplerate=44100)
  elsif bitrate == 40 then
    %mp3(bitrate=40, samplerate=44100)
  elsif bitrate == 32 then
    %mp3(bitrate=32, samplerate=44100)
  else
    %mp3(bitrate=128, samplerate=44100)
  end
end

def encoder.mp3(~samplerate,~bitrate)
  if samplerate == 48000 then
    encoder.mp3_48k(bitrate)
  else
    encoder.mp3_44_1k(bitrate)
  end
end
%endif

%ifencoder %fdkaac
def encoder.he_aac_48k(vbr)
  if vbr == 1 then
    %fdkaac(aot="mpeg4_he_aac", samplerate=48000, vbr=1, afterburner=true, sbr_mode=true)
  elsif vbr == 2 then
    %fdkaac(aot="mpeg4_he_aac", samplerate=48000, vbr=2, afterburner=true, sbr_mode=true)
  elsif vbr == 3 then
    %fdkaac(aot="mpeg4_he_aac", samplerate=48000, vbr=3, afterburner=true, sbr_mode=true)
  elsif vbr == 4 then
    %fdkaac(aot="mpeg4_he_aac", samplerate=48000, vbr=4, afterburner=true, sbr_mode=true)
  elsif vbr == 5 then
    %fdkaac(aot="mpeg4_he_aac", samplerate=48000, vbr=5, afterburner=true, sbr_mode=true)
  else
    %fdkaac(aot="mpeg4_he_aac", samplerate=48000, bitrate=96, afterburner=true, sbr_mode=true)
  end
end

def encoder.he_aac_44_1k(vbr)
  if vbr == 1 then
    %fdkaac(aot="mpeg4_he_aac", samplerate=44100, vbr=1, afterburner=true, sbr_mode=true)
  elsif vbr == 2 then
    %fdkaac(aot="mpeg4_he_aac", samplerate=44100, vbr=2, afterburner=true, sbr_mode=true)
  elsif vbr == 3 then
    %fdkaac(aot="mpeg4_he_aac", samplerate=44100, vbr=3, afterburner=true, sbr_mode=true)
  elsif vbr == 4 then
    %fdkaac(aot="mpeg4_he_aac", samplerate=44100, vbr=4, afterburner=true, sbr_mode=true)
  elsif vbr == 5 then
    %fdkaac(aot="mpeg4_he_aac", samplerate=44100, vbr=5, afterburner=true, sbr_mode=true)
  else
    %fdkaac(aot="mpeg4_he_aac", samplerate=44100, bitrate=96, afterburner=true, sbr_mode=true)
  end
end

def encoder.he_aac(~samplerate,~vbr)
  if samplerate == 48000 then
    encoder.he_aac_48k(vbr)
  else
    encoder.he_aac_44_1k(vbr)
  end
end

def encoder.he_aac_v2_48k(vbr)
  if vbr == 1 then
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=48000, vbr=1, afterburner=true, sbr_mode=true)
  elsif vbr == 2 then
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=48000, vbr=2, afterburner=true, sbr_mode=true)
  elsif vbr == 3 then
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=48000, vbr=3, afterburner=true, sbr_mode=true)
  elsif vbr == 4 then
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=48000, vbr=4, afterburner=true, sbr_mode=true)
  elsif vbr == 5 then
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=48000, vbr=5, afterburner=true, sbr_mode=true)
  else
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=48000, bitrate=64, afterburner=true, sbr_mode=true)
  end
end

def encoder.he_aac_v2_44_1k(vbr)
  if vbr == 1 then
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=44100, vbr=1, afterburner=true, sbr_mode=true)
  elsif vbr == 2 then
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=44100, vbr=2, afterburner=true, sbr_mode=true)
  elsif vbr == 3 then
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=44100, vbr=3, afterburner=true, sbr_mode=true)
  elsif vbr == 4 then
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=44100, vbr=4, afterburner=true, sbr_mode=true)
  elsif vbr == 5 then
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=44100, vbr=5, afterburner=true, sbr_mode=true)
  else
    %fdkaac(aot="mpeg4_he_aac_v2", samplerate=44100, bitrate=64, afterburner=true, sbr_mode=true)
  end
end

def encoder.he_aac_v2(~samplerate,~vbr)
  if samplerate == 48000 then
    encoder.he_aac_v2_48k(vbr)
  else
    encoder.he_aac_v2_44_1k(vbr)
  end
end
%endif

%ifencoder %opus
def encoder.opus(~bitrate)
  if bitrate == 320 then
    %opus(application="audio", signal="music", max_bandwidth="full_band", bitrate=320)
  elsif bitrate == 256 then
    %opus(application="audio", signal="music", max_bandwidth="full_band", bitrate=256)
  elsif bitrate == 192 then
    %opus(application="audio", signal="music", max_bandwidth="full_band", bitrate=192)
  elsif bitrate == 128 then
    %opus(application="audio", signal="music", max_bandwidth="full_band", bitrate=128)
  elsif bitrate == 96 then
    %opus(application="audio", signal="music", max_bandwidth="full_band", bitrate=96)
  elsif bitrate == 64 then
    %opus(application="audio", signal="music", max_bandwidth="full_band", bitrate=64)
  else
    %opus(application="audio", signal="music", max_bandwidth="full_band")
  end
end
%endif

%ifencoder %flac
def encoder.flac_48k(compression)
  if compression == 0 then
    %ogg(%flac(samplerate=48000, compression=0))
  elsif compression == 1 then
    %ogg(%flac(samplerate=48000, compression=1))
  elsif compression == 2 then
    %ogg(%flac(samplerate=48000, compression=2))
  elsif compression == 3 then
    %ogg(%flac(samplerate=48000, compression=3))
  elsif compression == 4 then
    %ogg(%flac(samplerate=48000, compression=4))
  elsif compression == 5 then
    %ogg(%flac(samplerate=48000, compression=5))
  elsif compression == 6 then
    %ogg(%flac(samplerate=48000, compression=6))
  elsif compression == 7 then
    %ogg(%flac(samplerate=48000, compression=7))
  else
    %ogg(%flac(samplerate=48000))
  end
end

def encoder.flac_44_1k(compression)
  if compression == 0 then
    %ogg(%flac(samplerate=44100, compression=0))
  elsif compression == 1 then
    %ogg(%flac(samplerate=44100, compression=1))
  elsif compression == 2 then
    %ogg(%flac(samplerate=44100, compression=2))
  elsif compression == 3 then
    %ogg(%flac(samplerate=44100, compression=3))
  elsif compression == 4 then
    %ogg(%flac(samplerate=44100, compression=4))
  elsif compression == 5 then
    %ogg(%flac(samplerate=44100, compression=5))
  elsif compression == 6 then
    %ogg(%flac(samplerate=44100, compression=6))
  elsif compression == 7 then
    %ogg(%flac(samplerate=44100, compression=7))
  else
    %ogg(%flac(samplerate=44100))
  end
end

def encoder.flac(~samplerate, ~compression)
  if samplerate == 48000 then
    encoder.flac_48k(compression)
  else
    encoder.flac_44_1k(compression)
  end
end
%endif

%ifencoder %vorbis
def encoder.vorbis_48k(bitrate)
  if bitrate == 48 then
    %vorbis.cbr(samplerate=48000, bitrate=48)
  elsif bitrate == 64 then
    %vorbis.cbr(samplerate=48000, bitrate=64)
  elsif bitrate == 80 then
    %vorbis.cbr(samplerate=48000, bitrate=80)
  elsif bitrate == 96 then
    %vorbis.cbr(samplerate=48000, bitrate=96)
  elsif bitrate == 112 then
    %vorbis.cbr(samplerate=48000, bitrate=112)
  elsif bitrate == 128 then
    %vorbis.cbr(samplerate=48000, bitrate=128)
  elsif bitrate == 160 then
    %vorbis.cbr(samplerate=48000, bitrate=160)
  elsif bitrate == 192 then
    %vorbis.cbr(samplerate=48000, bitrate=192)
  elsif bitrate == 224 then
    %vorbis.cbr(samplerate=48000, bitrate=224)
  elsif bitrate == 256 then
    %vorbis.cbr(samplerate=48000, bitrate=256)
  elsif bitrate == 320 then
    %vorbis.cbr(samplerate=48000, bitrate=320)
  elsif bitrate >= 500 then
    %vorbis.cbr(samplerate=48000, bitrate=500)
  else
    %vorbis.cbr(samplerate=48000)
  end
end

def encoder.vorbis_44_1k(bitrate)
  if bitrate == 48 then
    %vorbis.cbr(samplerate=44100, bitrate=48)
  elsif bitrate == 64 then
    %vorbis.cbr(samplerate=44100, bitrate=64)
  elsif bitrate == 80 then
    %vorbis.cbr(samplerate=44100, bitrate=80)
  elsif bitrate == 96 then
    %vorbis.cbr(samplerate=44100, bitrate=96)
  elsif bitrate == 112 then
    %vorbis.cbr(samplerate=44100, bitrate=112)
  elsif bitrate == 128 then
    %vorbis.cbr(samplerate=44100, bitrate=128)
  elsif bitrate == 160 then
    %vorbis.cbr(samplerate=44100, bitrate=160)
  elsif bitrate == 192 then
    %vorbis.cbr(samplerate=44100, bitrate=192)
  elsif bitrate == 224 then
    %vorbis.cbr(samplerate=44100, bitrate=224)
  elsif bitrate == 256 then
    %vorbis.cbr(samplerate=44100, bitrate=256)
  elsif bitrate == 320 then
    %vorbis.cbr(samplerate=44100, bitrate=320)
  elsif bitrate >= 500 then
    %vorbis.cbr(samplerate=44100, bitrate=500)
  else
    %vorbis.cbr(samplerate=44100)
  end
end

def encoder.vorbis(~samplerate, ~bitrate)
  if samplerate == 48000 then
    encoder.vorbis_48k(bitrate)
  else
    encoder.vorbis_44_1k(bitrate)
  end
end

def encoder.vorbis.vbr_48k(quality)
  if quality >= 1.0 then
    %vorbis(samplerate=48000, quality=1.0)
  elsif quality >= 0.9 then
    %vorbis(samplerate=48000, quality=0.9)
  elsif quality >= 0.8 then
    %vorbis(samplerate=48000, quality=0.8)
  elsif quality >= 0.7 then
    %vorbis(samplerate=48000, quality=0.7)
  elsif quality >= 0.6 then
    %vorbis(samplerate=48000, quality=0.6)
  elsif quality >= 0.5 then
    %vorbis(samplerate=48000, quality=0.5)
  elsif quality >= 0.4 then
    %vorbis(samplerate=48000, quality=0.4)
  elsif quality >= 0.3 then
    %vorbis(samplerate=48000, quality=0.3)
  elsif quality >= 0.2 then
    %vorbis(samplerate=48000, quality=0.2)
  elsif quality >= 0.1 then
    %vorbis(samplerate=48000, quality=0.1)
  elsif quality >= 0.0 then
    %vorbis(samplerate=48000, quality=0.0)
  elsif quality >= -0.1 then
    %vorbis(samplerate=48000, quality=-0.1)    
  else
    %vorbis(samplerate=48000, quality=0.2)        
  end                            
end

def encoder.vorbis.vbr_44_1k(quality)
  if quality >= 1.0 then
    %vorbis(samplerate=44100, quality=1.0)
  elsif quality >= 0.9 then
    %vorbis(samplerate=44100, quality=0.9)
  elsif quality >= 0.8 then
    %vorbis(samplerate=44100, quality=0.8)
  elsif quality >= 0.7 then
    %vorbis(samplerate=44100, quality=0.7)
  elsif quality >= 0.6 then
    %vorbis(samplerate=44100, quality=0.6)
  elsif quality >= 0.5 then
    %vorbis(samplerate=44100, quality=0.5)
  elsif quality >= 0.4 then
    %vorbis(samplerate=44100, quality=0.4)
  elsif quality >= 0.3 then
    %vorbis(samplerate=44100, quality=0.3)
  elsif quality >= 0.2 then
    %vorbis(samplerate=44100, quality=0.2)
  elsif quality >= 0.1 then
    %vorbis(samplerate=44100, quality=0.1)
  elsif quality >= 0.0 then
    %vorbis(samplerate=44100, quality=0.0)
  elsif quality >= -0.1 then
    %vorbis(samplerate=44100, quality=-0.1)    
  else
    %vorbis(samplerate=44100, quality=0.2)        
  end                            
end

def encoder.vorbis.vbr(~samplerate, ~quality)
  if samplerate == 48000 then
    encoder.vorbis.vbr_48k(quality)
  else
    encoder.vorbis.vbr_44_1k(quality)
  end
end
%endif

def encoder.default()
  %ifencoder %mp3
    %mp3
  %endif

  %ifnencoder %mp3
    %wav
  %endif
end

def encoder.default.icecast()
  encoder.vorbis(samplerate=44100, bitrate=96)
end

def encoder.codec(conf,~default_samplerate=0)
  default_samplerate =
    if default_samplerate == 0 then
      get("frame.audio.samplerate", default=48000)
    else
      default_samplerate
    end

  samplerate = int_of_string(conf["samplerate"], default=default_samplerate)
  codec = conf["codec"]

  encoder =
    if codec == "he_aac" then
      %ifencoder %fdkaac
        vbr = int_of_string(conf["vbr"], default=0)
        encoder.he_aac(samplerate=samplerate, vbr=vbr)
      %endif

      %ifnencoder %fdkaac
        encoder.default()
      %endif
    elsif codec == "he_aac_v2" then
      %ifencoder %fdkaac
        vbr = int_of_string(conf["vbr"], default=0)
        encoder.he_aac_v2(samplerate=samplerate, vbr=vbr)
      %endif

      %ifnencoder %fdkaac
        encoder.default()
      %endif
    elsif codec == "opus" then
      %ifencoder %opus
        bitrate = int_of_string(conf["bitrate"], default=96)
        encoder.opus(bitrate=bitrate)
      %endif

      %ifnencoder %opus
        encoder.default()
      %endif
    elsif codec == "flac" then
      %ifencoder %flac
        compression = int_of_string(conf["compression"], default=5)
        encoder.flac(samplerate=samplerate, compression=compression)
      %endif

      %ifnencoder %flac
        encoder.default()
      %endif
    elsif codec == "vorbis" then
      %ifencoder %vorbis
        bitrate = int_of_string(conf["bitrate"], default=96)
        encoder.vorbis(samplerate=samplerate, bitrate=bitrate)
      %endif

      %ifnencoder %vorbis
        encoder.default()
      %endif
    elsif codec == "vorbis.vbr" then
      %ifencoder %vorbis
        quality = float_of_string(conf["quality"], default=0.2)
        encoder.vorbis.vbr(samplerate=samplerate, quality=quality)
      %endif

      %ifnencoder %vorbis
        encoder.default()
      %endif
    elsif codec == "mp3" then
      %ifencoder %mp3
        bitrate = int_of_string(conf["bitrate"], default=128)
        encoder.mp3(samplerate=samplerate, bitrate=bitrate)
      %endif

      %ifnencoder %mp3
        encoder.default()
      %endif
    else
      encoder.default()
    end

  (codec,encoder)
end

def encoders.predefined()
  samplerate = get("frame.audio.samplerate", default=48000)
  
  %ifencoder %fdkaac
  he_aac = encoder.he_aac(samplerate=samplerate)
  he_aac_v2 = encoder.he_aac_v2(samplerate=samplerate)
  %endif

  %ifencoder %mp3
  mp3 = encoder.mp3(samplerate=samplerate)
  %endif

  %ifencoder %vorbis
  vorbis = encoder.vorbis(samplerate=samplerate)
  vorbis.vbr = encoder.vorbis.vbr(samplerate=samplerate)
  %endif

  %ifencoder %flac
  flac = encoder.flac(samplerate=samplerate)
  %endif

  groups = [
    %ifencoder %fdkaac
    # HE-AAC v1
    ("he_aac", [
      (".max", he_aac(vbr=5)),
      ("", he_aac(vbr=4)),
      (".medium", he_aac(vbr=3)),
      (".low", he_aac(vbr=2)),
      (".min", he_aac(vbr=1))
    ]),
    # HE-AAC v2
    ("he_aac_v2", [
      (".max", he_aac_v2(vbr=5)),
      ("", he_aac_v2(vbr=4)),
      (".medium", he_aac_v2(vbr=3)),
      (".low", he_aac_v2(vbr=2)),
      (".min", he_aac_v2(vbr=1))
    ]),
    %endif
    %ifencoder %mp3
    ("mp3", [
      (".max", mp3(bitrate=320)),
      (".high", mp3(bitrate=256)),
      (".medium", mp3(bitrate=192)),
      ("", mp3(bitrate=128)),
      (".low", mp3(bitrate=96)),
      (".poor", mp3(bitrate=64)),
      (".min", mp3(bitrate=48))
    ]),
    %endif
    %ifencoder %vorbis
    ("vorbis", [
      (".max", vorbis(bitrate=500)),
      (".high", vorbis(bitrate=320)),
      (".medium", vorbis(bitrate=128)),
      (".low", vorbis(bitrate=96)),
      ("", vorbis(bitrate=96)),
      (".poor", vorbis(bitrate=64)),
      (".min", vorbis(bitrate=48))
    ]),
    ("vorbis.vbr", [
      (".max", vorbis.vbr(quality=1.0)),
      (".high", vorbis.vbr(quality=0.9)),
      (".medium", vorbis.vbr(quality=0.4)),
      (".low", vorbis.vbr(quality=0.2)),
      ("", vorbis.vbr(quality=0.2)),
      (".poor", vorbis.vbr(quality=0.0)),
      (".min", vorbis.vbr(quality=-0.1))
    ]),
    %endif
    %ifencoder %opus
    ("opus", [
      (".max", encoder.opus(bitrate=320)),
      (".high", encoder.opus(bitrate=256)),
      (".medium", encoder.opus(bitrate=128)),
      ("", encoder.opus(bitrate=96)),
      (".min", encoder.opus(bitrate=64)),
    ]),
    %endif
    %ifencoder %flac
    ("flac", [      
      (".fast", flac(compression=0)),
      ("", flac(compression=5)),
      (".slow", flac(compression=7)),
    ])
    %endif
  ]

  groups = list.map(fun(g) -> begin
    codec = fst(g)
    (codec, list.map(fun(e) -> begin
      suffix = fst(e)
      ("#{codec}#{suffix}", snd(e))
    end, snd(g)))
  end, groups)

  list.fold(fun(a,g) -> begin
    codec = fst(g)
    list = snd(g)
    
    mapped = list.map(fun(e) -> begin
      (fst(e), (codec, snd(e)))
    end, list)

    list.append(a, mapped)
  end, [], groups)
end

def encoders.load(conf, ~include_predefined=true)
  predefined =
    if include_predefined then
      encoders.predefined()
    else
      []
    end

  list.append(predefined, list.map(fun(kv) -> begin
      (fst(kv), encoder.codec(conf.parse_detail(snd(kv))))
  end, conf))
end

def encoders.lookup(name,list,~default)
  result = list.fold(fun(ret, item) -> begin
      if list.length(!ret) == 0 then
        if fst(item) == name then
          ref [snd(item)]
        else
          ret
        end
      else
        ret
      end
    end,
    ref [], list
  )

  if list.length(!result) == 0 then
    print.yellow("Encoder name #{name} not found, fallback to default")
  end

  list.hd(!result,default=default)
end