{ emacsWithPackages }:
let
  pkgs = import <nixpkgs> {};
  versioned_emacs = emacsWithPackages (epkgs: with epkgs; [
    package-lint
  ]);
in derivation rec {
  name = "org-assistant";
  baseInputs = [];
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./builder.sh ];
  setup = ./package-lint.sh;
  buildInputs = [
    pkgs.wget
    versioned_emacs pkgs.coreutils];
  emacs = versioned_emacs;
  org_assistant = ../org-assistant.el;
  test_target = ../test;
  system = builtins.currentSystem;
}

  
