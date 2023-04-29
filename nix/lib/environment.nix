{ exec, name, emacs, targets }:
let
  pkgs = import <nixpkgs> {};
  link_step = (with pkgs.lib.strings; concatMapStringsSep "\n" (target: "cp ${target.file} ${target.name}") targets);
  install_step = (with pkgs.lib.strings; concatMapStringsSep "\n" (target: ''(package-install-file "${target.name}")'') targets);
  emacs_start = pkgs.writeText "run-test.el" (''
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(package-refresh-contents)
${install_step}
'');
  build_targets = pkgs.writeShellScript "generate_targets.sh"
    link_step;
in rec {
  inherit name;
  inherit emacs;
  baseInputs = [];
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./builder.sh ];
  setup = exec;
  inherit build_targets;
  inherit emacs_start;
  buildInputs = [emacs pkgs.coreutils];
  test_target = ../../test;
  system = builtins.currentSystem;
}
