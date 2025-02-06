{ lib, ... }:

{
  imports = [
    ./cli
    ./gui
    ./zsh.nix
  ];

  zsh.enable = lib.mkDefault true;
  gui.enable = lib.mkDefault false;
}
