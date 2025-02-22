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

    enableDirenv = lib.mkEnableOption {
      default = false;
      description = "Enable direnv integration";
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
        "gc" = "git commit";
        "gp" = "git push";
        "gl" = "git log";
        "ga" = "git add";
        "gaa" = "git add --all";
      };

      initExtra = ''
        eval "$(zoxide init zsh)"
        ${if cfg.enableKeybinds then (builtins.readFile ../../scripts/modules/zsh/keybinds.zsh) else ""}
        ${if cfg.enableDirenv then "eval \"$(direnv hook zsh)\"" else ""}
      '';
    };
  };
}
