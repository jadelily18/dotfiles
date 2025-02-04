{
  lib,
  config,
  ...
}:

{
  options.gnupg = {
    enable = lib.mkEnableOption "Enable gnupg";
  };

  config = lib.mkIf config.gnupg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
