{
  lib,
  ...
}:

{
  imports = [
    ./common
    ./gnupg.nix
    ./stylix.nix
  ];

  gnupg.enable = lib.mkDefault false;
  stylix-theme.enable = lib.mkDefault true;
}
