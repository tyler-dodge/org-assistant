let
  pkgs = import <nixpkgs> {};
in import (pkgs.fetchFromGitHub {
  owner = "tyler-dodge";
  repo = "emacs-package-nix-build";
  rev = "217c28bda09c76ca17c11918ee29e4041c572229";
  hash = "sha256-Ip+JJg03FT+dKjxTtQYIlZ8TqpFtzQSq3WnxokQssio=";
})
