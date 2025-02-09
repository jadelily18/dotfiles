{
  lib,
  config,
  ...
}:

let
  cfg = config.zsh;
in
{
  options.zsh = {
    enable = lib.mkEnableOption {
      default = true;
      description = "Enable zsh module";
    };

    enableKeybinds = lib.mkEnableOption {
      default = true;
      description = "Enable zsh keybinds";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;

      shellAliases = {
        "ls" = "eza --icons --group-directories-first";
        "zshsrc" = "source ~/.zshrc";
      };

      initExtra = ''
        eval "$(zoxide init zsh)"
        ${if cfg.enableKeybinds then (builtins.readFile ../../scripts/modules/zsh/keybinds.zsh) else ""}
      '';
    };
  };
}
