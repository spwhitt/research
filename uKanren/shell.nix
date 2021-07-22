{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  buildInputs = [ racket inotifyTools ];

  shellHook = ''
    raco pkg install racket-langserver
  '';
}
