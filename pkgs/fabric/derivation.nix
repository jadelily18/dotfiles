{
  pypkgs,
  pkgs,
  lib,
}:

pypkgs.buildPythonPackage {
  pname = "python-fabric";
  version = "0.0.1";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric";
    rev = "c0b321ab0ffc534f25fa902aaaed07b81bba56c4";
    sha256 = "sha256-TuCItKO05jRw5f4UFLRX402xJelHxZu6xxCiUxGysto=";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    wrapGAppsHook3
    gobject-introspection
    cairo
  ];

  propagatedBuildInputs = with pkgs; [
    gtk3
    gtk-layer-shell
    libdbusmenu-gtk3
    cinnamon-desktop
    gnome-bluetooth
  ];

  dependencies = with pypkgs; [
    setuptools
    click
    pycairo
    pygobject3
    pygobject-stubs
    loguru
    psutil
  ];

  meta = {
    changelog = "";
    description = ''
      next-gen framework for building desktop widgets using Python (check the rewrite branch for progress)
    '';
    homepage = "https://github.com/Fabric-Development/fabric";
    license = lib.licenses.agpl3Only;
  };
}
