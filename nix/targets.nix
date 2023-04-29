let
  targets = import ./lib.nix;
in targets {
  package = import ./package.nix;
}
