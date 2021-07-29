{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let jacal = import ./jacal.nix { inherit pkgs; }; in

mkShell {
  buildInputs = [ jacal ];
}
