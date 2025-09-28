{
  pypkgs,
  pkgs,
}:

pypkgs.buildPythonApplication {
  pname = "rofi-bookmarks-zen";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  dependencies = with pypkgs; [
    setuptools
  ];

  meta = {
    changelog = "";
    description = ''
      Implementation for grabbing Zen bookmarks in rofi.
    '';
    homepage = "https://github.com/jadelily18/dotfiles";
  };
}
