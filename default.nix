let
  pkgs = import <nixpkgs> {};
  lib = pkgs.fetchFromGitHub {
    owner = "tyler-dodge";
    repo = "emacs-package-nix-build";
    rev = "f23e1efea5083125a47ea1234c060771605f0dbe";
    hash = "sha256-EhZrROJNPYnbxY9dIql4ziVrN9vCjPIdCD3QSpTYvf8=";
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
