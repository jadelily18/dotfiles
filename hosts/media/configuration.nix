# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../user.nix
    inputs.home-manager.nixosModules.default
  ];

  primary-user = {
    enable = true;
    username = "jade";
    description = "jade lily";
  };

  stylix-theme.enable = true;

  gnupg.enable = true;

  networking.hostName = "hs-media";

  services.vscode-server.enable = true;

  services.openssh = {
    enable = true;
    allowSFTP = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    zsh
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  /*
    	This value determines the NixOS release from which the default
      settings for stateful data, like file locations and database versions
      on your system were taken. It‘s perfectly fine and recommended to leave
      this value at the release version of the first install of this system.
      Before changing this value read the documentation for this option
      (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  */
  system.stateVersion = "24.11";

}
