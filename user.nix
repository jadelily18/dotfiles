{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.primary-user;
in
{
  options.primary-user = {
    enable = lib.mkEnableOption "Enable user module";

    username = lib.mkOption {
      default = "jade";
      description = "Username";
    };

    extraGroups = lib.mkOption {
      default = [
        "wheel"
        "networkmanager"
      ];
      type = lib.types.listOf lib.types.str;
      description = "Extra groups for the user";
    };

    description = lib.mkOption {
      default = "Main user";
      type = lib.types.str;
      description = "Description for the user";
    };

  };

  config = lib.mkIf config.primary-user.enable {
    users.users.${cfg.username} = {
      isNormalUser = true;
      initialPassword = "1234";
      description = cfg.description;
      extraGroups = cfg.extraGroups;
      shell = pkgs.zsh;
    };
  };
}
