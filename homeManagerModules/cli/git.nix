{
  config,
  lib,
  ...
}:

let
  cfg = config.git;
in
{
  options.git = {
    enable = lib.mkEnableOption "Enable git";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      extraConfig = {
        user = {
          signingKey = "910F4FE160AE36BA";
          name = "Jade Nash";
          email = "jade@lilydev.com";
        };
      };
    };
  };
}
