# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ../../user.nix
    inputs.home-manager.nixosModules.default
  ];

  inputs.nixpkgs.hostPlatform = "aarch64-darwin";

  primary-user = {
    enable = true;
    username = "jade";
    description = "jade lily";
  };

  programs.firefox.enable = true;

  programs.steam.enable = true;

  gnupg.enable = true;

  networking.hostName = "jade-macbook";
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.flatpak.enable = true;
  services.flatpak.packages = [
    "app.zen_browser.zen"
  ];

  # Recommended by nixd
  # nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixd
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
