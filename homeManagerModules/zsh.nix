{ lib, config, ... }:

let
  cfg = config.zsh;
in
{
  options.zsh = {
    enable = lib.mkEnableOption {
      default = true;
      description = "Enable zsh module";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
    };
  };
}
