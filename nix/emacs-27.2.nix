let
  pkgs = import (builtins.fetchGit {
    name = "emacs-revision-27.1";
    url = "https://github.com/NixOS/nixpkgs/";                       
    ref = "refs/heads/nixpkgs-unstable";                     
    rev = "860b56be91fb874d48e23a950815969a7b832fbc";           
  }) {};
  emacsWithPackages = with pkgs; (emacsPackagesNgGen emacs).emacsWithPackages;
  run-test = import ./run-test.nix {
    inherit emacsWithPackages;
  };
in run-test
