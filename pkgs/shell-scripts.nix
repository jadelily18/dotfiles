{ pkgs }:
{
  reload-waybar = pkgs.writeShellScriptBin "reload-waybar" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Kill existing waybar instances (exclude this script)
    WAYBAR_PIDS=$(pgrep -f waybar | grep -v "^$$\$" || true)
    if [[ -n "$WAYBAR_PIDS" ]]; then
      echo "🚧 Stopping existing waybar (PIDs: $WAYBAR_PIDS)"
      echo "$WAYBAR_PIDS" | xargs kill 2>/dev/null || true
      sleep 0.2
    else
      echo "ℹ️ No running waybar found"
    fi

    # Start waybar
    waybar -c ~/dotfiles/modules/hm/waybar/config.json -s ~/dotfiles/modules/hm/waybar/style.css "$@" &>/dev/null &

    # Verify it started
    sleep 0.3
    if pgrep -f waybar | grep -v "^$$\$" >/dev/null; then
      echo "✅ waybar reloaded successfully"
    else
      echo "❌ ERROR: waybar failed to start!"
    fi
  '';

  toggle-pavucontrol = pkgs.writeShellScriptBin "toggle-pavucontrol" ''
    #!/usr/bin/env bash
    pkill pavucontrol || pavucontrol &
  '';
}
