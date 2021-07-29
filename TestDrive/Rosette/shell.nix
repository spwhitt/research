{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  buildInputs = [ racket z3 ];

  shellHook = ''
    raco pkg install rosette
  '';
}
