{
  config,
  lib,
  pkgs,
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
        credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";

        init.defaultBranch = "main";

        user = {
          signingKey = "910F4FE160AE36BA";
          name = "Jade Nash";
          email = "jade@lilydev.com";
        };
      };
    };
  };
}
