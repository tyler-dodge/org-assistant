let
  pkgs = import <nixpkgs> {};
  lib = pkgs.fetchFromGitHub {
    owner = "tyler-dodge";
    repo = "emacs-package-nix-build";
    rev = "eb109da5900436c7b2ec2a61818a0fc7e2fdce8a";
    hash = "sha256-Iq9VMffjSumE7imFMvHqb0Ydjrfh25fQDD+COBzdt68=";
  };
in import lib {
  package = {
    name = "org-assistant";
    test_target = ./test;
    targets = [{
      name = "org-assistant.el";
      file = ./org-assistant.el;
    }];
  };
}
