let
  pkgs = import <nixpkgs> {};
  lib = pkgs.fetchFromGitHub {
    owner = "tyler-dodge";
    repo = "emacs-package-nix-build";
    rev = "5f1ba3834d6f77464f6b5c5fff86750f3e04029e";
    hash = "sha256-Uk2Cl8+xPwDidiUkYiuxlY9Bi+rCmnRsv8k5DcMe56Y=";
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
