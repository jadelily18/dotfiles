import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects


RoundButton {
	id: timeButton
	property var transitionDuration: 200
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
			layer.enabled: true
			layer.effect: MultiEffect {
				colorization: 1
				colorizationColor: timeButton.hovered ? colorPrimary : colorText

				Behavior on colorizationColor {
					ColorAnimation {
						duration: timeButton.transitionDuration
						easing.type: Easing.InOutQuad
					}
				}
			}
		}

		Text {
			text: Time.time
			color: timeButton.hovered ? colorPrimary : colorText
			font.weight: Font.Bold

			Behavior on color {
				ColorAnimation {
					duration: timeButton.transitionDuration
					easing.type: Easing.InOutQuad
				}
			}
		}
	}
}