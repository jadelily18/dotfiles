# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  wallpaperPath = ../../files/wallpapers/rayquaza_catppuccin.png;
  wallpaperName = builtins.baseNameOf wallpaperPath;
  wallpaper = pkgs.runCommand wallpaperName { } ''
    local_path=${wallpaperPath}
    cp "$local_path" "$out" 
  '';
  sddm-theme = inputs.silentSDDM.packages.${pkgs.system}.default.override {
    # theme = "rei";
    extraBackgrounds = [ wallpaper ];

    theme-overrides = {
      "LoginScreen" = {
        background = "${wallpaperName}";
      };

      "LockScreen" = {
        background = "${wallpaperName}";
      };
    };
  };
  sddm-theme-pkgs = [
    sddm-theme
    sddm-theme.test
  ];
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../user.nix
    inputs.home-manager.nixosModules.default
  ];

  programs.hyprland.enable = true;

  primary-user = {
    enable = true;
    username = "jade";
    description = "jade lily";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  };

  nix.optimise.automatic = true;

  boot = {
    kernelParams = [
      "systemd.gpt_auto=0"
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    loader.systemd-boot = {
      enable = lib.mkForce false;
      consoleMode = "1";
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    plymouth = {
      enable = true;
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
  };

  programs.firefox.enable = true;

  programs.steam.enable = true;

  gnupg.enable = true;

  qt.style = lib.mkForce null;
  qt.platformTheme = lib.mkForce "qt5ct";

  networking.hostName = "jade-nixos";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  qt.enable = true;
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = sddm-theme.pname;
    extraPackages = sddm-theme.propagatedBuildInputs;

    settings = {
      General = {
        GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
        # InputMethod = "qtvirtualkeyboard";
      };
    };
  };

  services.xserver.displayManager.setupCommands = ''
    X_RANDR="${lib.getExe pkgs.xorg.xrandr}"

    $X_RANDR --output DisplayPort-0 --off
    $X_RANDR --output HDMI-A-0 --off

    $X_RANDR --output DisplayPort-2 --primary --mode 2560x1440
  '';

  services.displayManager.sessionPackages = [ pkgs.hyprland ];
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
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

  services.gnome.gnome-keyring.enable = true;

  services.dbus = {
    enable = true;
    packages = with pkgs; [
      gnome-keyring
      libsecret
    ];
  };

  security.pam.services = {
    sddm.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
    hyprland.enableGnomeKeyring = true;
  };

  security.unprivilegedUsernsClone = true;

  security.wrappers.bwrap = {
    enable = true;
    source = "${pkgs.bubblewrap}/bin/bwrap";
    owner = "root";
    group = "root";
    permissions = "u+xs,g+x,o+x";
  };

  virtualisation.docker.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.flatpak = {
    enable = true;
    packages = [
      # "app.zen_browser.zen"
      "com.google.Chrome"
      "io.github.java_decompiler.jd-gui"
      "org.vinegarhq.Sober"
      "com.modrinth.ModrinthApp"
      "com.usebruno.Bruno"
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      5173
    ];
    allowedUDPPorts = [
      5173
    ];
  };

  # Recommended by nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        .zen-wrapped
      ''; # or just "zen" if you use unwrapped package
      mode = "0755";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      zsh
      nixd
      sbctl
      clinfo
      libsecret
      file
      xdg-utils
    ]
    ++ sddm-theme-pkgs;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
