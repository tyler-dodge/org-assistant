{ exec, name, emacs, el_target, el_name }:
let
  pkgs = import <nixpkgs> {};
in rec {
  inherit name;
  inherit emacs;
  baseInputs = [];
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./builder.sh ];
  setup = exec;
  buildInputs = [emacs pkgs.coreutils];
  inherit el_target;
  inherit el_name;
  test_target = ../../test;
  system = builtins.currentSystem;
}
