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
      autosuggestion.enable = true;

      shellAliases = {
        "zshsrc" = "source ~/.zshrc";
      };

      initExtra = ''
        				eval "$(zoxide init zsh)"
        			'';
    };
  };
}
