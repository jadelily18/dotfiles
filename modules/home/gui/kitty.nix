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
    useX11 = lib.mkEnableOption {
      default = true;
      description = "Use X11 instead of Wayland";
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

        "ctrl+right" = "no_op";
        "ctrl+left" = "no_op";

        "kitty_mod+c" = "copy_and_clear_or_interrupt";
        "kitty_mod+v" = "paste_from_clipboard";

        # zsh ctrl+backspace keybind will not work without this
        "kitty_mod+backspace" = "no_op";
      };

      settings = {
        tab_bar_min_tabs = 1;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";

        font_size = 12.0;
        opacity = 0.2;

        linux_display_server = lib.mkIf cfg.useX11 "X11";

        kitty_mod = "ctrl";

        window_padding_width = 4;
      };
    };
  };
}
