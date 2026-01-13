//@ pragma UseQApplication
//@ pragma IconTheme kora
//@ pragma Env QS_ICON_THEME=kora

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
// import Quickshell.Io

import "./Widgets"

Scope {
	id: root

	property var colorPink:          Qt.hsla(316 / 360, 0.72, 0.86, 1)
	property var colorPinkRaised:    Qt.hsla(316 / 360, 0.3, 0.22, 1)
	property var colorRed:           "#f38ba8"
	property var colorGreen:         "#a6e3a1"
	property var colorYellow:        "#f9e2af"
	property var colorBlue:          "#89b4fa"
	property var colorOrange:        "#fab387"
	property var colorPurple:        "#cba6f7"

	property var colorPrimary:       colorPink
	property var colorPrimaryRaised: colorPinkRaised
	property var colorText:          "#cdd6f4"
	property var colorSubtext1:      "#bac2de"
	property var colorSubtext0:      "#a6adc8"
	property var colorOverlay2:      "#9399b2"
	property var colorOverlay1:      "#7f849c"
	property var colorOverlay0:      "#6c7086"
	property var colorSurface2:      "#585b70"
	property var colorSurface1:      "#45475a"
	property var colorSurface0: 		 "#313244"
	property var colorBase:          "#1e1e2e"
	property var colorMantle:        "#181825"
	property var colorCrust:         "#11111b"

	ReloadPopup { }

	Notification {  }

	Bar {}
	
}
