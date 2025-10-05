{
  lib,
  config,
  ...
}:

let
  cfg = config.zed;
in
{
  options.zed = {
    enable = lib.mkEnableOption {
      default = true;
      description = "Enable Zed editor configuration";
    };

    enableRemoteServer = lib.mkEnableOption {
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;

      userSettings = {
        load_direnv = "shell_hook";
        middle_click_paste = false;

        ui_font_size = lib.mkForce 16;
        buffer_font_size = lib.mkForce 16;
        buffer_font_features.calt = false;
        buffer_font_family = "JetBrainsMono Nerd Font";

        theme = lib.mkForce {
          mode = "system";
          light = "Catppuccin Latte";
          dark = "Catppuccin Mocha";
        };
        icon_theme = "Catppuccin Mocha";

        languages = {
          "Nix" = {
            language_servers = [
              "nixd"
              "!nil"
            ];
          };
        };

        lsp = {
          rust-analyzer.binary.path_lookup = true;
          nix.binary.path_lookup = true;
        };
      };

      userKeymaps = [
        {
          context = "Editor";
          bindings = {
            ctrl-shift-up = "editor::MoveLineUp";
            ctrl-shift-down = "editor::MoveLineDown";
            ctrl-d = "editor::DuplicateLineDown";
            ctrl-shift-d = "editor::DuplicateLineUp";
          };
        }
        {
          context = "Editor && mode == full";
          bindings = {
            shift-enter = "editor::NewlineBelow";
          };
        }
      ];
    };
  };
}
