{ emacsWithPackages }:
let
  pkgs = import <nixpkgs> {};
  versioned_emacs = emacsWithPackages (epkgs: with epkgs; [
    ert-async
    el-mock
    ert-runner
    uuid
    deferred
    s
    dash
  ]);
in derivation rec {
  name = "org-assistant";
  baseInputs = [];
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./builder.sh ];
  setup = ./setup.sh;
  buildInputs = [
    versioned_emacs pkgs.coreutils];
  emacs = versioned_emacs;
  org_assistant = ../org-assistant.el;
  test_target = ../test;
  system = builtins.currentSystem;
}

  
