{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = [
    (import ./nix/versions/emacs-28.1.nix (epkgs: []) (epkgs: []))
  ];
}
