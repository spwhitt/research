# Status: elan-interpreter seems to work
# The rest doesn't, but that's ok, the interpreter is enough for me for now

{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  elan-interpreter = stdenv.mkDerivation {
    version = "3.7a";
    name = "elan-interpreter-3.7a";
    src = fetchurl {
      url = "https://elan.loria.fr/Soft/elan-interpreter-3.7a.tar.gz";
      sha256 = "04il9dmyzsxd45iqgdh5hm9zaaybxycz0n346kivij2vgw3fwqi0";
    };

    # buildFlags = [ "-Wno-error=format-security" ];
    # Breaks build, can't be bothered
    hardeningDisable = [ "format" ];

    buildInputs = [ yacc flex ];
  };

  elan-library = stdenv.mkDerivation {
    version = "1.0d";
    name = "elan-library-1.0d";
    src = fetchurl {
      url = "https://elan.loria.fr/Soft/elan-library-1.0d.tar.gz";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };
  };

  cwi-aterm = stdenv.mkDerivation {
    version = "2.0.5";
    name = "aterm-2.0.5";
    src = pkgs.fetchurl {
      url = "https://elan.loria.fr/Soft/aterm-2.0.5.tar.gz";
      sha256 = "1kjg5fs9n24cbwz18ih6h9m30pc8fpgbyra6w18nmfxy4xzys0mq";
    };
    postPatch = ''
      # CLK_TCK is obsolete
      substituteInPlace aterm/gc.c \
        --replace CLK_TCK CLOCKS_PER_SEC
    '';

    # Fails on tests, segfault ../utils/dicttoc -dict stress.dict
    # This is likely a sign of a deeper problem I should investigate
    # But I can't be bothered - probably won't use compiler anyway
    # doCheck = false; this doesn't fix the problem, it still runs
  };

  nancy-cpl = stdenv.mkDerivation {
    version = "0.7";
    name = "cpl-0.7";
    src = pkgs.fetchurl {
      url = "https://elan.loria.fr/Soft/cpl-0.7.tar.gz";
      sha256 = "1iv29app8pinl12fhdgg8vmmwpizw4dv3z7bvnh8an7f547cyhbf";
    };
  };

  bdw-gc = stdenv.mkDerivation {
    version = "6.8";
    name = "gc-6.8";
    src = pkgs.fetchurl {
      url =
        "http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source/gc6.8.tar.gz";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };
  };

  elan-compiler = stdenv.mkDerivation {
    version = "4.4a";
    name = "elan-compiler-4.4a";
    src = pkgs.fetchurl {
      url = "https://elan.loria.fr/Soft/elan-compiler-4.4a.tar.gz";
      sha256 = "1f1vnbmv6hpwnsqk7pwcfv1va67qmpylk2jrhpmhhmmw15wphw2v";
    };
    buildInputs = [ jdk yacc flex cwi-aterm nancy-cpl bdw-gc ];
  };

in {
  inherit elan-interpreter elan-compiler elan-library;
  inherit cwi-aterm nancy-cpl bdw-gc;
}
