{
  pkgs,
  variant,
}:
let
  version = "0.8.5";
  variantMap = {
    "color" = "Color";
    "flat" = "Flat";
    "hc" = "HighContrast";
    "hc-inv" = "HighContrastInverted";
  };
  capitalizedVariant = variantMap.${variant};
in
pkgs.stdenv.mkDerivation {
  pname = "fluent-emoji-webfont-${variant}";
  inherit version;

  src = pkgs.fetchFromGitHub {
    name = "fluent-emoji-webfont";
    owner = "tetunori";
    repo = "fluent-emoji-webfont";
    rev = "v${version}";
    sha256 = "sha256-HqnTMMW6YW8g956q0zEZCyoROr6MruRqgET2jfnlqFg=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp dist/FluentEmoji${capitalizedVariant}.ttf $out/share/fonts/truetype
  '';

  meta = {
    description = "Fluent UI Emoji Webfont (${variant})";
    homepage = "https://github.com/tetunori/fluent-emoji-webfont";
  };
}
