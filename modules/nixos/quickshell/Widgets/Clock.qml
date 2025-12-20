import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


RoundButton {
	id: timeButton
	palette.buttonText: colorText
	leftPadding: 12
	rightPadding: 12
	Layout.fillHeight: true

	background: Rectangle {
		color: parent.down ? colorCrust : (parent.hovered ? colorMantle : "transparent")
		radius: 9999
	}

	contentItem: Row {
		spacing: 2

		IconImage {
			source: "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/clock.svg"
			implicitSize: 18
			Layout.margins: 0
			anchors.verticalCenter: parent.verticalCenter
		}

		Text {
			text: Time.time
			color: colorText
			font.weight: Font.Bold
		}
	}
}