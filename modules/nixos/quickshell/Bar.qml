import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Mpris

import qs.Widgets

Scope {
	id: root
	
	property var colorPrimary: "#f5c2e7"
	property var colorText: "#cdd6f4"
	property var colorSubtext: "#a6adc8"
	property var colorBase: "#1e1e2e"
	property var colorMantle: "#181825"
	property var colorCrust: "#11111b"

	Variants {
		model: Quickshell.screens;

		delegate: Component {
			PanelWindow {
				id: screenWindow
				required property var modelData
				screen: modelData

				color: "transparent"

				margins {
					left: 20
					right: 20
				}
				
				anchors {
					top: true
					left: true
					right: true
				}

				ClippingRectangle {
					anchors.fill: parent
					color: colorBase
					opacity: 0.85

					Layout.fillWidth: true
					Layout.fillHeight: true

					radius: 9999

					RowLayout {
						anchors {
							fill: parent
							margins: 4
							leftMargin: 8
							rightMargin: 8
						}
						uniformCellSizes: true
						
						RowLayout {
							spacing: 16
							RoundButton {
								id: menuButton
								Layout.fillHeight: true

								background: Rectangle {
									// id: menuButtonBg
									color: parent.down ? colorCrust : (parent.hovered ? colorMantle : "transparent")
									radius: 9999
								}

								contentItem: IconImage {
									source: "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/heart.svg"
									implicitSize: 20
									layer.enabled: true
									layer.effect: MultiEffect {
										colorization: 1
										colorizationColor: menuButton.hovered ? colorPrimary : colorText

										Behavior on colorizationColor {
											ColorAnimation {
												duration: 200
												easing.type: Easing.InOutQuad
											}
										}
									}
								}
							}
							
							Workspaces { }
							
							Row {
								property var player: Mpris.players.values[0]
								spacing: 4
								
								IconImage {
									source: parent.player.isPlaying ? 
										"file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/pause-circle.svg"
										: "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/play-circle.svg"
									implicitSize: 20
									layer.enabled: true
									layer.effect: MultiEffect {
										colorization: 1
										colorizationColor: menuButton.hovered ? colorPrimary : colorText

										Behavior on colorizationColor {
											ColorAnimation {
												duration: 200
												easing.type: Easing.InOutQuad
											}
										}
									}
								}
								
								Text {
									text: formatPlayerInfo()
									color: colorText

									function formatPlayerInfo() {
										const player = parent.player
										let playerString = "" 

										if (player.trackTitle) {
											playerString += player.trackTitle
										}
										if (player.trackArtist) {
											if (playerString.length > 0) {
												playerString += " - "
											}
											playerString += player.trackArtist
										}
										if (player.trackAlbum) {
											if (playerString.length > 0) {
												playerString += " // "
											}
											playerString += player.trackAlbum
										}
										return playerString
									}
								}
							}
						}

						RowLayout {
							// Layout.fillWidth: true
							// Layout.fillHeight: true
							Layout.alignment: Qt.AlignHCenter
							Clock { }
						}

						RowLayout {
							// Layout.fillWidth: true
							// Layout.fillHeight: true
							Layout.alignment: Qt.AlignRight
							RoundButton {
								text: ">:3"
							}
						}
					}
				}

				// radius: 9999
				implicitHeight: 40

			}
		}
	}
}
