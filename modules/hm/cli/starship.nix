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

        format = "$username$hostname $directory $character";

        character = {
          success_symbol = "[\\$](bold #f2cdcd)";
          error_symbol = "[?](bold #f38ba8)";
        };

        username = {
          show_always = true;
          format = "[$user](bold italic #f5c2e7)";
          disabled = false;
        };

        hostname = {
          ssh_only = true;
          format = "[@$hostname](bold italic #cba6f7)";
        };

        directory = {
          format = "[$path]($style italic #b4befe)";
        };
      };
    };
  };
}
