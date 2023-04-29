{ emacsWithPackages, name, el_name, el_target }:
let
  pkgs = import <nixpkgs> {};
  emacs_packages = (epkgs: with epkgs; [
    ert-runner
    el-mock
    package-lint
  ]);
  emacs = import ./environment.nix {
    inherit name;
    inherit el_name;
    inherit el_target;
    emacs = emacsWithPackages emacs_packages;
    exec = ./package-lint.sh;
  };
in derivation (emacs // rec {
  buildInputs = emacs.buildInputs ++ [pkgs.wget];
})
