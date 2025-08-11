{
  inputs,
  pkgs,
  ...
}:

{

  imports = [
    inputs.self.homeModules.default
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jade";
  home.homeDirectory = "/home/jade";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Custom GNOME configuration
  gnome-settings.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    with pkgs;
    [
      vesktop
      kitty
      _1password-cli
      _1password-gui
      vscode
      nixfmt-rfc-style
      xclip
      nixos-generators
      steam
      filezilla
      prismlauncher
      smile
      # davinci-resolve doesn't work properly and I don't want to fix it right now
      spotify
      spicetify-cli
      heroic
      eyedropper
      openrgb-with-all-plugins
      hoppscotch
      thunderbird
      gparted
      packwiz
      blender
      libsForQt5.qt5ct
      catppuccin-qt5ct
      slack
      oxipng
      gimp
      vivaldi
      recaf-launcher
      vlc
      flameshot
      gradle
      jetbrains-toolbox
      audacity
      obs-studio
      pkgdiff
      kdePackages.kdenlive
      ffmpeg
      telegram-desktop
    ]
    ++ (import ../../modules/home/shared/packages.nix { inherit pkgs; })
    ++ (import ../../modules/home/shared/gnomeExtensions.nix { inherit pkgs; })
    ++ (import ../../modules/home/shared/development.nix { inherit pkgs; });

  gui.enable = true;

  git.signingKey = "910F4FE160AE36BA";

  zsh.enableDirenv = true;

  # gitui's theming is kinda broken
  stylix.targets.gitui.enable = false;

  stylix.targets.qt.enable = false;

  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
    configs = {
      default = {
        undo-backspace = true;
      };
    };
    matches = {
      base = {
        matches = [
          {
            trigger = ":mcr";
            replace = "[Modrinth's Content Rules](https://modrinth.com/legal/rules)";
          }
          {
            trigger = ":mrsupport";
            replace = "[Modrinth's Support Portal](https://support.modrinth.com)";
          }
          {
            trigger = ":mrdelay";
            replace = "Apologies for the delay, we're currently experiencing a very high volume of projects being submitted, but we're doing our best to get to them as soon as possible!";
          }
          {
            trigger = ":mrfixed";
            replace = "We have gone ahead and fixed this for your project so it can be approved, thank you!";
          }
          {
            trigger = ":mrinv";
            replace = "Invalid modpack file";
          }
          {
            trigger = ":mrpriv";
            replace = "
---
Your project is currently unlisted so it's not available publicly, but
feel free to share the link with others until the issue(s) mentioned
above are fixed!";
          }
        ];
      };
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    "scripts" = {
      source = ../../files/scripts;
      recursive = true;
    };

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jade/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "lvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
