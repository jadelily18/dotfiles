{
  pkgs,
}:

let
  pname = "flightcore";
  version = "3.2.0";

  src = pkgs.fetchurl {
    url = "https://github.com/R2NorthstarTools/FlightCore/releases/download/v${version}/FlightCore_${version}_amd64.AppImage";
    hash = "sha256-K174am+5ncTiYqtqvPRSuWtXuFqxnuLCvaTuZ1LIwTs=";
  };

  appimageContents = pkgs.appimageTools.extract {
    inherit pname version src;

    postExtract = ''
      echo "CONTENTS OF APPIMAGE:"
      ls $out
      # substituteInPlace $out/FlightCore.desktop --replace-fail 'Exec=flightcore' 'Exec=WEBKIT_DISABLE_DMABUF_RENDERER=1 flightcore'
      cat $out/FlightCore.desktop 
    '';
  };
in
pkgs.appimageTools.wrapAppImage {
  inherit pname version;

  src = appimageContents;

  extraPkgs =
    pkgs: with pkgs; [
      webkitgtk_4_1
    ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/FlightCore.desktop $out/share/applications/FlightCore.desktop
    install -m 444 -D ${appimageContents}/flightcore.png \
      $out/share/icons/hicolor/512x512/apps/flightcore.png
  '';

  passthru.src = src;
}
