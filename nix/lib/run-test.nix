{ emacsWithPackages, name, el_target, el_name }:
let
  pkgs = import <nixpkgs> {};
  emacs_packages = (epkgs: with epkgs; [
    ert-runner
    el-mock
  ]);
  emacs = import ./environment.nix {
    inherit name;
    inherit el_target;
    inherit el_name;
    emacs = emacsWithPackages emacs_packages;
    exec = ./run-test.sh;
  };
in derivation emacs
