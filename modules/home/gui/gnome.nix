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

        ];

        # "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"
      };
    };
  };
}
