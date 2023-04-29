{ emacsWithPackages, name, targets }:
let
  pkgs = import <nixpkgs> {};
  emacs_packages = (epkgs: with epkgs; [
    ert-runner
    el-mock
    package-lint
  ]);
  package_lint_target = pkgs.lib.head targets;
  package_lint_script = ''
(package-install-file "${package_lint_target.name}")
(require 'package-lint)
(message "[NOT RESPONSIBLE FOR WARNINGS PRIOR TO THIS POINT]")
(find-file "${package_lint_target.name}")
(checkdoc-eval-current-buffer)
(with-current-buffer "*Style Warnings*" (message "%s" (buffer-string)))
(package-lint-current-buffer)
(byte-compile-file "${package_lint_target.name}")
(require 'melpazoid)
(melpazoid-check-experimentals)
(with-current-buffer "*Package-Lint*" (message "%s" (buffer-string)))
'';
  run_package_lint = pkgs.writeText "package-lint.el" package_lint_script;
  emacs = import ./environment.nix {
    inherit name;
    inherit targets;
    emacs = emacsWithPackages emacs_packages;
    exec = ./package-lint.sh;
  };
in derivation (emacs // rec {
  inherit run_package_lint;
  buildInputs = emacs.buildInputs ++ [pkgs.wget];
})
