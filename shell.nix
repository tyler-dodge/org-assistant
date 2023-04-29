{ pkgs ? import <nixpkgs> {} }:

let
  versions = (import ./nix/lib.nix { package = ./nix/package.nix; }).versions;
in pkgs.mkShell {
  packages = [
    (versions.emacs_28_1 (epkgs: []) (epkgs: []))
  ];
}
