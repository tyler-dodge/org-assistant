{ pkgs ? import <nixpkgs> {} }:

let
  versions = (import ./default.nix).versions;
in pkgs.mkShell {
  packages = [
    (versions.latest (epkgs: []) (epkgs: []))
  ];
}
