import ./lib/run-test.nix ({
  emacsWithPackages = import ./versions/emacs-27.1.nix (_: []);
  name = "org-assistant-emacs-27.1";
} // (import ./package.nix))
