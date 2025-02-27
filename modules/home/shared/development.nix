{ pkgs }:

with pkgs;
[
  rustup
  devenv
  direnv
  nixd
  nixfmt-rfc-style
  zed-editor # even if not using its GUI, this installs Zed server for remote development
]
