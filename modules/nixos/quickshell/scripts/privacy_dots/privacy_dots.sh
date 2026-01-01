#!/usr/bin/env bash
# dependencies: pipewire (pw-dump), v4l2loopback-dkms, jq, dbus-send (dbus)
set -euo pipefail

JQ_BIN="${JQ:-jq}"
PW_DUMP_CMD="${PW_DUMP:-pw-dump}"

mic=0
cam=0
loc=0
scr=0

mic_app=""
cam_app=""
loc_app=""
scr_app=""

# mic & camera
if command -v "$PW_DUMP_CMD" >/dev/null 2>&1 && command -v "$JQ_BIN" >/dev/null 2>&1; then
  dump="$($PW_DUMP_CMD 2>/dev/null || true)"

  mic="$(
    printf '%s' "$dump" \
    | $JQ_BIN -r '
      [ .[]
        | select(.type=="PipeWire:Interface:Node")
        | select((.info.props."media.class"=="Audio/Source" or .info.props."media.class"=="Audio/Source/Virtual"))
        | select((.info.state=="running") or (.state=="running"))
      ] | (if length>0 then 1 else 0 end)
    ' 2>/dev/null || echo 0
  )"

  if [[ "$mic" -eq 1 ]]; then
    mic_app="$(
      printf '%s' "$dump" \
      | $JQ_BIN -r '
        [ .[]
          | select(.type=="PipeWire:Interface:Node")
          | select((.info.props."media.class"=="Stream/Input/Audio"))
          | select((.info.state=="running") or (.state=="running"))
          | .info.props["node.name"]
        ] | unique | join(", ")
      ' 2>/dev/null || echo ""
    )"
  fi

  if command -v fuser >/dev/null 2>&1; then
      cam=0
      for dev in /dev/video*; do
          if [ -e "$dev" ] && fuser "$dev" >/dev/null 2>&1; then
              cam=1
              break
          fi
      done
  else
      cam=0
  fi

  if command -v fuser >/dev/null 2>&1; then
      for dev in /dev/video*; do
          if [ -e "$dev" ] && fuser "$dev" >/dev/null 2>&1; then
              pids=$(fuser "$dev" 2>/dev/null)
              for pid in $pids; do
                  pname=$(ps -p "$pid" -o comm=)
                  if [[ -n "$pname" ]]; then
                      cam_app+="$pname, "
                  fi
              done
          fi
      done
      cam_app="${cam_app%, }"
  fi

fi

# location
if command -v gdbus >/dev/null 2>&1; then
  loc="$(
    if ps aux | grep "[g]eoclue" >/dev/null 2>&1; then
      echo 1
    else
      echo 0
    fi
  )"
fi

if command -v gdbus >/dev/null 2>&1; then
    if pids=$(pgrep -x geoclue); then
        loc=1
        for pid in $pids; do
            pname=$(ps -p "$pid" -o comm=)
            [[ -n "$pname" ]] && loc_app+="$pname, "
        done
        loc_app="${loc_app%, }"
    else
        loc=0
    fi
fi

# screen sharing
if command -v "$PW_DUMP_CMD" >/dev/null 2>&1 && command -v "$JQ_BIN" >/dev/null 2>&1; then
  if [[ -z "${dump:-}" ]]; then
    dump="$($PW_DUMP_CMD 2>/dev/null || true)"
  fi

  scr="$(
      printf '%s' "$dump" \
      | $JQ_BIN -e '
          [ .[]
            | select(.info?.props?)
            | select(
                (.info.props["media.name"]? // "")
                | test("^(xdph-streaming|gsr-default|game capture)")
            )
          ]
          | (if length > 0 then true else false end)
        ' >/dev/null && echo 1 || echo 0
    )"
fi

if [[ "$scr" -eq 1 ]]; then
    scr_app="$(
    printf '%s' "$dump" \
    |   $JQ_BIN -r '
        [ .[]
          | select(.type=="PipeWire:Interface:Node")
          | select((.info.props."media.class"=="Stream/Input/Video") or (.info.props."media.name"=="gsr-default_output") or (.info.props."media.name"=="game capture"))
          | select((.info.state=="running") or (.state=="running"))
          | .info.props["media.name"]
        ] | unique | join(", ")
      ' 2>/dev/null || echo ""
    )"
fi

if [[ "$mic" -eq 1 ]]; then
  mic_active=true
else
  mic_active=false
fi

if [ "$cam" -eq 1 ]; then
  cam_active=true
else
  cam_active=false
fi

if [ "$loc" -eq 1 ]; then
  loc_active=true
else
  loc_active=false
fi

if [[ "$scr" -eq 1 ]]; then
  scr_active=true
else
  scr_active=false
fi

jq -c -n --arg mic_active  "$mic_active" --arg cam_active "$cam_active" --arg loc_active "$loc_active" --arg scr_active "$scr_active" \
  '{ mic: $mic_active, cam: $cam_active, loc: $loc_active, scr: $scr_active }'

