let
  pkgs = import <nixpkgs> {};
  emacsWithPackages = import ./emacsWithPackages.nix;
  emacs = fetcher: emacsWithPackages {
      pkgs = import (builtins.fetchGit fetcher) {};
    };
 in {
   emacs_27_1 = emacs {
     name = "emacs-revision-27.1";
     url = "https://github.com/NixOS/nixpkgs/";
     ref = "refs/heads/nixpkgs-unstable";
     rev = "a765beccb52f30a30fee313fbae483693ffe200d";
   };
   emacs_27_2 = emacs {
       name = "emacs-revision-27.2";
       url = "https://github.com/NixOS/nixpkgs/";
       ref = "refs/heads/nixpkgs-unstable";
       rev = "860b56be91fb874d48e23a950815969a7b832fbc";
   };
   emacs_28_1 = emacs {
     name = "emacs-revision-28.1";
     url = "https://github.com/NixOS/nixpkgs/";
     ref = "refs/heads/nixpkgs-unstable";
     rev = "b1abaab2d14493c20740de34bad772f17d1e731b";
   };
 }
