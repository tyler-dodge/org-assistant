import ./lib/run-test.nix ({
  emacsWithPackages = import ./versions/emacs-28.1.nix (_: []);
  name = "org-assistant-emacs-28.1";
} // (import ./package.nix))
