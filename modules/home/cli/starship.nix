{ lib, config, ... }:

let
  cfg = config.starship;
in
{
  options.starship = {
    enable = lib.mkEnableOption "Enable starship module";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;

        format = "$username$directory$character";

        character = {
          success_symbol = "[>>](bold green)";
          error_symbol = "[??](bold red)";
        };

        username = {
          show_always = true;
          format = "[$user ]($style italic)";
          disabled = false;
        };

        directory = {
          format = "[$path ]($style italic)";
        };
      };
    };
  };
}
