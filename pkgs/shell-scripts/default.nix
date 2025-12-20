{ pkgs }:
let
  get-windows-boot-id = pkgs.writeShellScriptBin "get-windows-boot-id" (
    builtins.readFile ./scripts/get-windows-boot-id.sh
  );
in
{
  reload-waybar = pkgs.writeShellScriptBin "reload-waybar" (
    builtins.readFile ./scripts/reload-waybar.sh
  );

  toggle-pavucontrol = pkgs.writeShellScriptBin "toggle-pavucontrol" ''
    #!/usr/bin/env bash
    set -euo pipefail

    pkill pavucontrol || pavucontrol &
    exit 0
  '';

  get-windows-boot-id = get-windows-boot-id;

  reboot-to-windows = pkgs.writeShellApplication {
    name = "reboot2windows";
    runtimeInputs = [ get-windows-boot-id ];
    text = builtins.readFile ./scripts/reboot2windows.sh;
  };
}
