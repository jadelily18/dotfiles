{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ../../user.nix
    ./disk-config.nix
    inputs.home-manager.nixosModules.default
  ];

  primary-user = {
    enable = true;
    username = "jade";
    description = "jade - mediapi";
  };

  services.openssh.enable = true;
  users.users.jade.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGkkgeN1zvmcNhVk3JdGDT3uQea5cADJpcDAeRdmyJh jade@lilydev.com"
  ];

  networking.hostName = "mediapi";

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
