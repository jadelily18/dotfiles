{
  inputs,
  pkgs,
  lib,
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

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = [ "--all" ];
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      monitor = [
        "DP-3,     2560x1440@144, 0x0,     1" # main display
        "DP-1,     2560x1440@60,  2560x0,  1" # right display
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
      bind = [
        ## Basic system stuff
        "$mod,       T,         exec, kitty"
        "$mod,       Semicolon, exec, smile" # Emoji picker
        "$mod,       E,         exec, rofi -modi emoji -show emoji" # Better emoji picker
        "$mod,       Space,     exec, rofi -show drun"
        "$mod SHIFT, S,         exec, grim -g \"$(slurp)\" - | swappy -f -" # Screenshots
        "$mod SHIFT, R,         exec, kooha"

        ## Apps
        "$mod SHIFT,F,exec,nautilus"
        "$mod SHIFT,V,exec,vesktop"
        "$mod SHIFT,P,exec,1password"
        "$mod SHIFT,O,exec,1password --quick-access"

        ## Window/workspace management
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, I, togglefloating"

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
        "$mod CTRL, LEFT,  workspace, e-1" # Previous workspace (by number)
        "$mod CTRL, RIGHT, workspace, e+1" # Next Workspace (by number)

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
        "swaync"
        "systemctl --user start hyprpolkitagent"
        "hyprpanel"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];
      cursor.enable_hyprcursor = true;
      decoration = {
        rounding = 12;
        active_opacity = 0.9;
        inactive_opacity = 0.8;
        fullscreen_opacity = 0.9;

        blur = {
          enabled = true;
          xray = true;
          size = 16;
        };
      };
    };
  };

  # programs.waybar = {
  #   enable = false;
  #   settings = {
  #     mainBar = {
  #       height = 38;
  #       modules-left = [
  #         "hyprland/workspaces"
  #         "hyprland/window"
  #       ];
  #       modules-center = [ "clock" ];
  #       modules-right = [
  #         "pulseaudio"
  #         "network"
  #         "tray"
  #       ];
  #       clock = {
  #         format = "{:%r} ";
  #         format-alt = "{:%A, %B %d, %Y (%R)} ";

  #         tooltip-format = "<tt><small>{calendar}</small></tt>";

  #         calendar = {
  #           week-pos = "left";
  #         };

  #         actions = {
  #           on-click-right = "mode";
  #         };
  #       };
  #     };
  #   };
  #   style = builtins.readFile ../../files/styles/waybar.css;
  # };

  # I should just use AGS
  programs.hyprpanel = {
    enable = true;
    settings = {
      scalingPriority = "gdk";

      menus = {
        transitionTime = 100;
        volume.raiseMaximumVolume = true;
        media = {
          displayTimeTooltip = true;
          noMediaText = "No media playing...";
        };
        dashboard = {
          # powermenu.avatar.image = "IMAGE PATH :3";
          controls.enabled = true;
          directories.enabled = false;
          shortcuts.left = {
            shortcut1 = {
              icon = "";
              tooltip = "Zen Browser";
              command = "flatpak run app.zen_browser.zen";
            };
            shortcut3 = {
              tooltip = "Discord (vesktop)";
              command = "vesktop";
            };
          };
        };
      };

      bar = {
        launcher.autoDetectIcon = true;
        notifications.show_total = true;
        clock = {
          icon = "";
          format = "%I:%M:%S %p";
          showTime = true;
        };
        workspaces = {
          show_icons = false;
          show_numbered = true;
          monitorSpecific = true;
          numbered_active_indicator = "highlight";
        };
      };

      notifications = {
        monitor = 1;
        activeMonitor = false;
        autoDismiss = true;
        clearDelay = 2000;
      };

      theme = {
        font = {
          weight = 800;
          size = "0.85rem";
        };
        osd = {
          monitor = 1;
          muted_zero = true;
          radius = "9999px";
        };
        notification = {
          opacity = 95;
          border_radius = "1.55em";
        };
        bar = {
          layer = "top";
          transparent = true;
          border.width = "0.15em";
          buttons = {
            opacity = 85;
            radius = "9999px";
            borderSize = "0.1em";
            volume.enableBorder = false;
            windowTitle.enableBorder = false;
            notifications.enableBorder = true;
            workspaces = {
              numbered_active_highlight_border = "9999px";
              numbered_active_highlight_padding = "0.5em";
            };
          };
          menus = {
            opacity = 95;
            card_radius = "1.25em";
            tooltip.radius = "1.35em";
            border.radius = "1.55em";
            popover.radius = "1.55em";
            buttons.radius = "9999px";
            progressbar.radius = "9999px";
            slider = {
              slider_radius = "9999px";
              progress_radius = "9999px";
            };
            switch = {
              radius = "9999px";
              slider_radius = "9999px";
            };
            menu.dashboard.profiles = {
              size = "7.5em";
              radius = "9999px";
            };
          };
        };
      };
    };
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = [ pkgs.rofi-emoji-wayland ];
  };

  # home.activation.ewwReopenExisting = lib.hm.dag.entryAfter [ "restartUserUnits" ] ''
  #   pgrep -x eww >/dev/null || ${pkgs.eww}/bin/eww daemon
  #   ${pkgs.coreutils}/bin/sleep 0.2
  #   W="$(${pkgs.eww}/bin/eww active-windows 2>/dev/null || ${pkgs.eww}/bin/eww windows 2>/dev/null || true)"
  #   [ -n "$W" ] && { ${pkgs.eww}/bin/eww close-many $W; ${pkgs.eww}/bin/eww open-many $W; }
  # '';

  programs.kitty.enable = lib.mkForce true;
  kitty.useX11 = false;

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
      (flameshot.overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags or [ ] ++ [ "-DUSE_WAYLAND_GRIM=ON" ];
      }))
      gradle
      jetbrains-toolbox
      audacity
      obs-studio
      pkgdiff
      kdePackages.kdenlive
      ffmpeg
      telegram-desktop
      #! Hyprland stuff
      swaynotificationcenter
      hyprpolkitagent
      cliphist
      nautilus
      hyprpicker
      hyprcursor
      rose-pine-hyprcursor
      grim
      slurp
      swappy
      kooha
      # libs for hyprland
      qt5.qtwayland
      qt6.qtwayland
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
