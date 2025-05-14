{
  lib,
  config,
  ...
}:

let
  cfg = config.gnome-settings;
in
{
  options.gnome-settings = {
    enable = lib.mkEnableOption "Enable GNOME settings";
  };

  config = lib.mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = lib.mkForce "prefer-dark";
        clock-format = "12h";
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = ":minimize,maximize,close";
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          # "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Smile";
        command = "smile";
        binding = "<Super>semicolon";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "Kitty Terminal";
        command = "kitty";
        binding = "<Super>T";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "Flameshot";
        command = "/bin/sh -c \"flameshot gui\" > /dev/null &";
        binding = "<Super><Shift>s";
      };

      "org/gnome/shell".enabled-extensions = [
        "smile-extension@mijorus.it"
        "trayIconsReloaded@selfmade.pl"
        "pop-shell@system76.com"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "Reboot2Windows@coooolfan.com"
        "reboottouefi@ubaygd.com"
      ];
    };
  };
}
