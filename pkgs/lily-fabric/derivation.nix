{
  pypkgs,
  pkgs,
  python-fabric,
}:

pypkgs.buildPythonApplication {
  pname = "lily-fabric";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  nativeBuildInputs = with pkgs; [
    wrapGAppsHook3
    gtk3
    gobject-introspection
    cairo
  ];

  dependencies = with pypkgs; [
    python-fabric
    psutil
  ];
  doCheck = false;
  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = {
    changelog = "";
    description = ''
      Jade's Fabric configuration.
    '';
    homepage = "https://github.com/jadelily18/dotfiles";
  };
}
