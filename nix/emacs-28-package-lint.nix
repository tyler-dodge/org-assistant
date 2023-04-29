import ./lib/package-lint.nix ({
  emacsWithPackages = import ./versions/emacs-28.1.nix (_: []);
  name = "org-assistant-emacs-28.1-package-lint";
} // (import ./package.nix))
