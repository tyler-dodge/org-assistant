{ emacsWithPackages, name, targets }:
let
  pkgs = import <nixpkgs> {};
  emacs_packages = (epkgs: with epkgs; [
    ert-runner
    el-mock
  ]);
  emacs = import ./environment.nix {
    inherit name;
    inherit targets;
    emacs = emacsWithPackages emacs_packages;
    exec = ./run-test.sh;
  };
in derivation emacs
