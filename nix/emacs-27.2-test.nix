import ./lib/run-test.nix ({
  emacsWithPackages = import ./versions/emacs-27.2.nix (_: []);
  name = "org-assistant-emacs-27.2";
} // (import ./package.nix))
