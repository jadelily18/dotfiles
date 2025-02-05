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

      userName = "Jade Nash";
      userEmail = "jade@lilydev.com";

      signing = {
        key = "910F4FE160AE36BA";
        signByDefault = true;
      };

      extraConfig = {
        credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";

        init.defaultBranch = "main";

        # user = {
        #   signingKey = "910F4FE160AE36BA";
        #   name = "Jade Nash";
        #   email = "jade@lilydev.com";
        # };
      };
    };
  };
}
