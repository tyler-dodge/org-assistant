{ pkgs }:
let
  emacsWithPackages = (with pkgs; emacsPackagesFor emacs).emacsWithPackages;
in extraPackages: packages: emacsWithPackages (epkgs:
  (packages epkgs) ++ (extraPackages epkgs)
)
