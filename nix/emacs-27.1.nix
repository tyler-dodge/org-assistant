let
  pkgs = import (builtins.fetchGit {
    name = "emacs-revision-27.1";
    url = "https://github.com/NixOS/nixpkgs/";                       
    ref = "refs/heads/nixpkgs-unstable";                     
    rev = "a765beccb52f30a30fee313fbae483693ffe200d";    
  }) {};
  emacsWithPackages = with pkgs; (emacsPackagesNgGen emacs).emacsWithPackages;
  run-test = import ./run-test.nix {
    inherit emacsWithPackages;
  };
in run-test
