# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../user.nix
    inputs.home-manager.nixosModules.default
  ];

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

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.plymouth = {
    enable = true;
  };

  xdg.portal.enable = true;

  programs.firefox.enable = true;

  programs.steam.enable = true;

  gnupg.enable = true;

  qt.style = lib.mkForce null;
  qt.platformTheme = lib.mkForce "qt5ct";

  networking.hostName = "jade-nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Should probably be in hardware-configuration.nix, but permission issues that I don't want to deal with rn

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

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

  services.flatpak.enable = true;
  services.flatpak.packages = [
    "app.zen_browser.zen"
    "com.google.Chrome"
    "io.github.java_decompiler.jd-gui"
    "org.vinegarhq.Sober"
    "com.modrinth.ModrinthApp"
    "com.usebruno.Bruno"
  ];

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    zsh
    nixd
    sbctl
    clinfo
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
