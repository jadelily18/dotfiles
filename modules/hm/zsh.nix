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
        "cd" = "z";
        "zshsrc" = "source ~/.zshrc";
        "zed" = "zeditor";
        "icat" = "kitten icat";

        # docker
        "dc" = "docker compose";
        "da" = "docker attach";
        "dca" = "docker compose attach";
        "dps" = "docker ps";
        "dcps" = "docker compose ps";
        "dlogs" = "docker logs";
        "dclogs" = "docker compose logs";

        # git
        "gc" = "git commit";
        "gp" = "git push";
        "gu" = "git pull";
        "gl" = "git log";
        "ga" = "git add";
        "gaa" = "git add --all";

        "nixconf" = "code ~/dotfiles";
      };

      initContent = ''
        eval "$(zoxide init zsh)"
        ${if cfg.enableKeybinds then (builtins.readFile ../../scripts/modules/zsh/keybinds.zsh) else ""}
        ${if cfg.enableDirenv then "eval \"$(direnv hook zsh)\"" else ""}
        export PATH="/home/jade/.deno/bin:$PATH" # for deno binaries
      '';
    };
  };
}
