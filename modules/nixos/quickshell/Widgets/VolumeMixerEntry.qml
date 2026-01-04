import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire

ColumnLayout {
	required property PwNode node
	property string label
	property int transitionDuration: 200
	Layout.fillWidth: true

	PwObjectTracker {
		objects: [node]
	}
	
	RowLayout {
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignVCenter

		Label {
			text: node.properties["application.name"] ?? label ?? "Unknown"
			// text: {
			// 	// application.name -> description -> name
			// 	const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
			// 	const media = node.properties["media.name"];
			// 	return media != undefined ? `${app} - ${media}` : app;
			// }
			font.pixelSize: 14
			font.weight: Font.Bold
			color: colorText
		}
	}

	RowLayout {
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignVCenter

		Image {
			source: {
				const iconName = node.properties["application.icon-name"]; // node: PwNode
				const iconPath = Quickshell.iconPath(iconName, true);
				// console.log(`Volume mixer icon:\n${iconName} -> ${iconPath === "" ? "no icon found" : iconPath}`);
				return iconPath;
			}
			visible: source != ""
			sourceSize.width: 20
			sourceSize.height: 20
		}

		RoundButton {
			id: muteButton

			onClicked: node.audio.muted = !node.audio.muted

			background: Rectangle {
				color: parent.down ? colorCrust : (parent.hovered ? colorMantle : "transparent")
				radius: 9999
			}

			contentItem: RowLayout {
				property var buttonContentColor: node.audio.muted ? colorRed : (muteButton.hovered ? colorPrimary : colorText)
				IconImage {
					source: node.audio.muted ? "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/speaker-x-mark.svg" : "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/speaker-wave.svg"
					implicitSize: 20
					layer.enabled: true
					layer.effect: MultiEffect {
						colorization: 1
						colorizationColor: parent.buttonContentColor

						Behavior on colorizationColor {
							ColorAnimation {
								duration: transitionDuration
								easing.type: Easing.InOutQuad
							}
						}
					}
				}

				Text {
					text: Math.round(node.audio.volume * 100) + "%"
					font.weight: Font.Bold

					color: parent.buttonContentColor

					Behavior on color {
						ColorAnimation {
							duration: transitionDuration
							easing.type: Easing.InOutQuad
						}
					}
				}
			}
		}

		Slider {
			id: volumeSlider
			Layout.fillWidth: true

			value: node.audio.volume
			onValueChanged: node.audio.volume = value


			
			background: Rectangle {
				x: volumeSlider.leftPadding
        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
				width: volumeSlider.availableWidth
				height: 6
				radius: 9999

				color: colorSurface1

				Rectangle {
					width: volumeSlider.visualPosition * parent.width
					height: parent.height
					radius: 9999

					color: node.audio.muted ? colorOverlay2 : colorPrimary

					Behavior on color {
						ColorAnimation {
							duration: transitionDuration
							easing.type: Easing.InOutQuad
						}
					}
				}
			}

			handle: Rectangle {
				x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
        y: parent.topPadding + parent.availableHeight / 2 - height / 2
				implicitWidth: 14
				implicitHeight: 14
				radius: 9999

				color: volumeSlider.pressed ? colorOverlay2 : (volumeSlider.hovered ? colorSubtext1 : colorText)

				Behavior on color {
					ColorAnimation {
						duration: transitionDuration / 2
						easing.type: Easing.InOutQuad
					}
				}
			}
		}
	}
}