{
  pkgs,
  myPkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.stylix-theme;
in
{
  options.stylix-theme = {
    enable = lib.mkEnableOption "Enable stylix theme";
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      image = ../files/wallpapers/rayquaza_catppuccin.png;

      fonts = {
        serif = config.stylix.fonts.sansSerif;

        sansSerif = {
          name = "Inter";
          package = pkgs.inter;
        };

        monospace = {
          name = "JetBrainsMono Nerd Font";
          package = pkgs.nerd-fonts.jetbrains-mono;
        };

        emoji = {
          name = "Fluent Emoji Color";
          package = myPkgs.fluent-emoji-webfont-color;
        };
      };
    };
  };
}
