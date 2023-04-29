{ pkgs ? import <nixpkgs> {} }:

let
  versions = import ./nix/lib/versions.nix;
in pkgs.mkShell {
  packages = [
    (versions.emacs_28_1 (epkgs: []) (epkgs: []))
  ];
}
