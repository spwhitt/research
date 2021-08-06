{ stdenv, jre, fetchurl, buildFHSUserEnv, swt, webkitgtk }:

let
  rodin = stdenv.mkDerivation {
    pname = "rodin";
    version = "3.6.0";
    src = fetchurl {
      url =
        "https://downloads.sourceforge.net/project/rodin-b-sharp/Core_Rodin_Platform/3.6/rodin-3.6.0.202105121522-77c344946-linux.gtk.x86_64.tar.gz";
      sha256 = "sha256-Wrd+ukEWnmi+2RrUpUKPsyZ9V3UfCVS3ex0jhkOBgZg=";
    };

    buildInputs = [ jre ];

    installPhase = ''
      mkdir -p $out
      cp -r . $out
    '';

    # FHS user env is taking care of everything
    # This is just a dumb unpack
    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;
    dontPatchShebangs = true;
    dontAutoPatchelf = true;
  };
in (buildFHSUserEnv {
  name = "spoofax-env";
  targetPkgs = pkgs: (with pkgs; [ jre swt webkitgtk ]);
  runScript = ''
    ${rodin}/rodin
  '';
}).env
