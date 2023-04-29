let pkgs = import <nixpkgs> {};
    package = (import ./package.nix);
    versions = import ./lib/versions.nix;
    create_target = target: pkgs.lib.mapAttrs (version_name: emacs_version: target {
      inherit version_name;
      emacsWithPackages = emacs_version (_: []);
    }) versions;
    run_package_lint = config: import ./lib/package-lint.nix (package // {
      emacsWithPackages = config.emacsWithPackages;
      name = "${package.name}-emacs-${config.version_name}-package-lint";
    });
    run_test = config: import ./lib/run-test.nix (package // {
      emacsWithPackages = config.emacsWithPackages;
      name = "${package.name}-${config.version_name}-test";
    });
in {
  test = create_target run_test;
  package_lint = create_target run_package_lint;
}

