{
  lib,
  config,
  ...
}:

let
  cfg = config.gui;
in
{
  imports = [
    ./kitty.nix
    ./gnome.nix
  ];

  options.gui = {
    enable = lib.mkEnableOption {
      default = false;
      description = "Enable GUI apps";
    };
  };

  config = lib.mkIf cfg.enable {
    kitty.enable = lib.mkDefault true;
    gnome-settings.enable = lib.mkDefault true;
  };

}
