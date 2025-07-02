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

    signingKey = lib.mkOption {
      type = lib.types.str;
      description = "The GPG key to use for signing commits";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;

      userName = "Jade Nash";
      userEmail = "jade@lilydev.com";

      signing = {
        key = cfg.signingKey;
        signByDefault = true;
      };

      extraConfig = {
        credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";

        init.defaultBranch = "main";
      };
    };
  };
}
