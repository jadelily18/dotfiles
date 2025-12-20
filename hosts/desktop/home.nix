{
  inputs,
  config,
  pkgs,
  myPkgs,
  lib,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
in
{

  imports = [
    inputs.self.homeModules.default
    inputs.spicetify-nix.homeManagerModules.spicetify
    inputs.zen-browser.homeModules.beta
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

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = [ "--all" ];
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      monitor = [
        "DP-3,     2560x1440@144, 0x0,     1" # main display
        "DP-2,     2560x1440@60,  2560x0,  1" # right display
        "HDMI-A-1, 2560x1440@60,  -2560x0, 1" # left display
        ",         preferred,     auto,    1" # for any other display, set preferred resolution and place on the right
      ];
      env = [
        "NIXOS_OZONE_WL,               1"
        "ELECTRON_OZONE_PLATFORM_HINT, wayland"
        "HYPRCURSOR_THEME,             rose-pine-hyprcursor"
        "XCURSOR_THEME,                rose-pine-hyprcursor"
        "HYPRCURSOR_SIZE,              24"
        "XCURSOR_SIZE,                 24"
      ];
      bindm = [
        "$mod, mouse:273, resizewindow"
        "$mod, mouse:272, movewindow"
      ];
      bindc = [
        "$mod, mouse:274, togglefloating"
      ];
      bind = [
        ## Basic system stuff
        "$mod,       T,         exec, kitty"
        "$mod,       Semicolon, exec, smile" # Emoji picker
        "$mod,       E,         exec, rofimoji -r 💖 --use-icons" # Better emoji picker
        "$mod,       Space,     exec, rofi -show drun -display-drun ♥ -show-icons" # App launcher
        "$mod,       B,         exec, ${myPkgs.rofi-bookmarks-zen}/bin/main | rofi -dmenu -p \"bark! wruff!\" -show-icons" # Bookmarks
        "$mod SHIFT, C,         exec, hyprpicker -a" # Color picker
        "$mod SHIFT, S,         exec, grimblast --freeze save area - | swappy -f - -o - | wl-copy" # Screenshots
        "$mod SHIFT, R,         exec, kooha"
        "$mod SHIFT, Z,         exec, zen-beta"
        "$mod SHIFT, L,         exec, reload-waybar"

        ## Apps
        "$mod SHIFT, F, exec, nautilus"
        "$mod SHIFT, V, exec, vesktop"
        "$mod SHIFT, P, exec, 1password"
        "$mod SHIFT, O, exec, 1password --quick-access"

        ## Window/workspace management
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, I, togglefloating"

        # Resize windows
        "$mod CTRL, LEFT,  resizeactive, -75 0"
        "$mod CTRL, RIGHT, resizeactive, 75 0"
        "$mod CTRL, UP,    resizeactive, 0 -75"
        "$mod CTRL, DOWN,  resizeactive, 0 75"

        # Cycle windows
        "$mod,       TAB, cyclenext"
        "$mod SHIFT, TAB, cyclenext, prev"

        # Focus
        "$mod, LEFT,  movefocus, l"
        "$mod, RIGHT, movefocus, r"
        "$mod, UP,    movefocus, u"
        "$mod, DOWN,  movefocus, d"

        # Move windows
        "$mod SHIFT, LEFT,  movewindow, l"
        "$mod SHIFT, RIGHT, movewindow, r"
        "$mod SHIFT, UP,    movewindow, u"
        "$mod SHIFT, DOWN,  movewindow, d"

        # Workspace navigation
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move focused window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
      ];
      exec-once = [
        "systemctl --user start hyprpolkitagent"
        "waybar"
        "hyprpaper"
        "swaync -c ~/dotfiles/modules/hm/swaync/config.json -s ~/dotfiles/modules/hm/swaync/style.css"
        "uair"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];
      cursor.enable_hyprcursor = true;
      decoration = {
        rounding = 20;
        active_opacity = 0.9;
        inactive_opacity = 0.8;
        fullscreen_opacity = 1.0;

        blur = {
          enabled = true;
          xray = true;
          size = 16;
        };
      };
      misc = {
        animate_manual_resizes = true;
        enable_anr_dialog = false;
        middle_click_paste = false;
      };
      general = {
        "col.active_border" = lib.mkForce "0xFFEDABD6";
      };
      windowrulev2 = [
        "float,class:^(org.pulseaudio.pavucontrol)$"
        "size 750 550,class:^(org.pulseaudio.pavucontrol)$"
        "move 1500 70,class:^(org.pulseaudio.pavucontrol)$"
        "pin,class:^(org.pulseaudio.pavucontrol)$"
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
  };

  programs.waybar = {
    enable = true;
    # settings = {
    #   modules-left = [ "hyprland/workspaces" ];
    # };
    settings = {
      bar = builtins.fromJSON (builtins.readFile ../../modules/hm/waybar/config.json);
    };
    style = builtins.readFile ../../modules/hm/waybar/style.css;
  };

  programs.rofi = {
    enable = true;
    plugins = with pkgs; [ rofi-emoji ];
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        configuration = {
          show-icons = true;
        };

        "*" = {
          border-radius = 18;
          padding = 4;
          font = "Inter";

          selected-normal-background = lib.mkForce (mkLiteral "#f5c2e7");
        };

        window = {
          border = 1;
          border-color = mkLiteral "rgb(49, 50, 68)";
          width = mkLiteral "30%";
        };

        element = {
          border-radius = mkLiteral "100%";
        };

        element-icon = {
          size = 24;
        };

        "element-icon selected.normal" = {
          background-color = mkLiteral "rgb(30, 30, 46)";
        };
      };
  };

  programs.spicetify = {
    enable = true;
    wayland = false; # breaks dropdowns if true
    enabledExtensions = with spicePkgs.extensions; [
      shuffle
      beautifulLyrics
      # simpleBeautifulLyrics
      oldCoverClick
    ];
    enabledCustomApps = with spicePkgs.apps; [
      marketplace
      reddit
      newReleases
      lyricsPlus
    ];
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
  };

  programs.kitty.enable = lib.mkForce true;
  kitty.useX11 = false;

  services.kdeconnect.enable = true;

  # Custom GNOME configuration
  gnome-settings.enable = true;

  # services.gnome-keyring.enable = true;

  gtk = {
    enable = true;
    theme = {
      # name = lib.mkForce "Catppuccin-Mocha-Pink";
      # package = lib.mkForce pkgs.catppuccin-gtk;
      # name = lib.mkForce "Breeze-Dark";
      # package = lib.mkForce pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "kora";
      package = pkgs.kora-icon-theme;
    };
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
        };
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
        "text/html" = [ "zen-beta.desktop" ];
        "application/pdf" = [ "org.gnome.Evince.desktop" ];
        "image/*" = [ "org.gnome.Loupe.desktop" ];
        "video/*" = [ "vlc.desktop" ];
        "audio/*" = [ "vlc.desktop" ];
        "application/zip" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-modrinth-modpack+zip" = [ "org.gnome.FileRoller.desktop" ];
      };
    };
  };

  fonts.fontconfig.enable = lib.mkForce false;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    with pkgs;
    [
      vesktop
      kitty
      _1password-cli
      _1password-gui
      (symlinkJoin {
        name = "vscode-wrapped-libsecret";
        paths = [ vscode ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/code \
          --add-flags "--password-store=gnome-libsecret"
        '';
      })
      nixfmt-rfc-style
      xclip
      nixos-generators
      steam
      filezilla
      prismlauncher
      modrinth-app
      smile
      # davinci-resolve doesn't work properly and I don't want to fix it right now

      heroic
      lutris
      itch
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
      gradle
      jetbrains-toolbox
      audacity
      obs-studio
      pkgdiff
      kdePackages.kdenlive
      ffmpeg
      telegram-desktop
      element-desktop
      bitwig-studio
      yazi
      kora-icon-theme
      kdePackages.ark
      gnome-text-editor
      file-roller
      snapshot
      loupe
      evince
      blockbench
      nitch
      yad
      uair
      nushell
      pavucontrol
      streamcontroller
      (inputs.affinity-nix.packages.${system}.v3)
      pureref
      beeref
      bambu-studio
      orca-slicer
      freecad-wayland

      #! Hyprland stuff
      swaynotificationcenter
      cliphist
      nautilus
      hyprpicker
      hyprcursor
      rose-pine-hyprcursor
      grim
      grimblast
      slurp
      swappy
      kooha
      rofimoji

      # libs for hyprland
      qt5.qtwayland
      qt6.qtwayland
      wl-clipboard
      gnome-keyring
      playerctl
      libnotify

      # myPkgs.shell-scripts.reload-waybar
      # myPkgs.shell-scripts.toggle-pavucontrol
      # myPkgs.shell-scripts.get-windows-boot-id
      myPkgs.shell-scripts-all

      # fonts
      (inputs.apple-fonts.packages.${system}.sf-pro-nerd)
    ]
    ++ (import ../../modules/pkgs/packages.nix { inherit pkgs; })
    ++ (import ../../modules/pkgs/development.nix { inherit pkgs; });

  gui.enable = true;

  git.signingKey = "910F4FE160AE36BA";

  zsh.enableDirenv = true;

  stylix.targets = {
    # gitui's theming is kinda broken
    gitui.enable = false;
    qt.enable = false;
    zen-browser.enable = false;
    spicetify.enable = false;
  };

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
            replace = "Apologies for the delay; we're doing our best to get to all projects as soon as possible!";
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
          {
            trigger = ":mrsep";
            replace = "					
---

**It looks like your project is intended for a private server.**

**Once you've addressed the above, and if you're okay with your project being unlisted (only accessible via its URL, not in search results), you can ignore everything below this text. Otherwise, please update your project accordingly!**

---
";
          }
          {
            trigger = ":mrambroke";
            replace = "## Content Scanning Error
Unfortunately, our AutoMod could not process your modpack, this may be because it is invalid or there was an error during export.   
We ask that you resubmit your project for review, we appreciate your patience and understanding.  
";
          }
          {
            trigger = ":mrmmh";
            replace = "(This is from [Fabulously Optimized](https://modrinth.com/modpack/fabulously-optimized), so you must link back there)";
          }
          {
            trigger = ":mrvt";
            replace = "(This is from [Vanilla Tweaks](https://vanillatweaks.net), so you must link back there)";
          }
        ];
      };
    };
  };

  programs.zen-browser.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # "scripts" = {
    #   source = ../../files/scripts;
    #   recursive = true;
    # };

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
