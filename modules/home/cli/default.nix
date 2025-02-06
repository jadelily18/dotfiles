{
  lib,
  ...
}:

{
  imports = [
    ./git.nix
    ./starship.nix
  ];

  git.enable = lib.mkDefault true;
  starship.enable = lib.mkDefault true;
}
