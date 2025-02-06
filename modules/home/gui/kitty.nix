{
  lib,
  config,
  ...
}:

let
  cfg = config.kitty;
in
{
  options.kitty = {
    enable = lib.mkEnableOption {
      default = false;
      description = "Enable kitty terminal";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      keybindings = {
        "kitty_mod+t" = "new_tab_with_cwd";
        "kitty_mod+enter" = "new_window_with_cwd";
        "kitty_mod+n" = "discard_event";

        "alt+right" = "next_tab";
        "alt+left" = "previous_tab";

        "kitty_mod+c" = "copy_and_clear_or_interrupt";
        "kitty_mod+v" = "paste_from_clipboard";

        # # Delete by word
        # "kitty_mod+backspace" = "send_text all \x17";

        # # Jump Words
        # "kitty_mod+left" = "send_text all \x1b\x62";
        # "kitty_mod+right" = "send_text all \x1b\x66";
      };

      settings = {
        tab_bar_min_tabs = 1;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";

        theme = "Catppuccin-Mocha";

        font_size = 12.0;
        opacity = 0.2;

        linux_display_server = "X11";

        kitty_mod = "ctrl";

      };
    };
  };
}
