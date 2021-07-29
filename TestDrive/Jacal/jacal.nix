{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation {
  version = "1c7";
  pname = "jacal";
  buildInputs = [ slibGuile guile unzip which texinfo ];

  preConfigure = ''
    chmod +x ./configure
  '';

  src = fetchurl {
    url = "http://groups.csail.mit.edu/mac/ftpdir/scm/jacal-1c7.zip";
    sha256 = "sha256-v5MVf/xCUbfamfUIFRYQYKGAph8PJdTsXcK0GVPXRRk=";
  };
}
