let
  pkgs = import (builtins.fetchGit {
    name = "emacs-revision-28.1";
    url = "https://github.com/NixOS/nixpkgs/";                       
    ref = "refs/heads/nixpkgs-unstable";                     
    rev = "b1abaab2d14493c20740de34bad772f17d1e731b";    
  }) {};
  emacsWithPackages = with pkgs; (emacsPackagesFor emacs).emacsWithPackages;
  package-lint = import ./run-package-lint.nix {
    inherit emacsWithPackages;
  };
in package-lint
