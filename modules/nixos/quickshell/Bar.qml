import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray

import qs.Widgets

Scope {
	id: root
	
	property var colorPink:    "#f5c2e7"
	property var colorRed:     "#f38ba8"
	property var colorGreen:   "#a6e3a1"
	property var colorYellow:  "#f9e2af"
	property var colorBlue:    "#89b4fa"
	property var colorOrange:  "#fab387"
	property var colorPurple:  "#cba6f7"

	property var colorPrimary: colorPink
	property var colorText:    "#cdd6f4"
	property var colorSubtext: "#a6adc8"
	property var colorBase:    "#1e1e2e"
	property var colorMantle:  "#181825"
	property var colorCrust:   "#11111b"

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
										colorizationColor: colorText

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
							PrivacyDots { }
						}

						RowLayout {
							// Layout.fillWidth: true
							// Layout.fillHeight: true
							

							Layout.alignment: Qt.AlignRight
							RoundButton {
								text: "power mode"
							}
							// RoundButton {
							// 	text: "tray"
							// }

							RowLayout {
								id: sysTray
								Layout.fillHeight: true
								// Layout.alignment: Qt.AlignHCenter | Qt.AlignRight
								visible: SystemTray.items.values.length > 0

								ClippingRectangle {
									anchors.fill: parent
									radius: 9999
									color: colorCrust	
								}

								RowLayout {
									Layout.margins: 0
									Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
									Layout.leftMargin: 0
									Layout.rightMargin: 2
									spacing: 0

									Repeater {
										model: SystemTray.items

										RoundButton {
											id: trayButton
											
											function mapFromGlobalToRelative() {
												const absolutePosition = this.mapToGlobal(0, 0)
												return {
													x: absolutePosition.x,
													y: absolutePosition.y + 36 // screenWindow.height // below screen window
												}
											}


											background: Rectangle {
												// color: parent.down ? colorCrust : (parent.hovered ? colorMantle : "transparent")
												color: parent.down ? colorMantle : (parent.hovered ? colorBase : "transparent")
												radius: 9999
											}

											contentItem: IconImage {
												source: modelData.icon
												implicitSize: trayButtonArea.pressed ? 18 : 20
												layer.enabled: true


												Behavior on implicitSize {
													NumberAnimation {
														duration: 100
														easing.type: Easing.InOutQuad
													}
												}

												MouseArea {
													id: trayButtonArea

													anchors.fill: parent
													acceptedButtons: Qt.LeftButton | Qt.RightButton
													onClicked: event => {
														console.log("Event: " + event)
														if (event.button === Qt.LeftButton) {
															modelData.activate()
														}
														if (event.button === Qt.RightButton) {
															modelData.display(screenWindow, trayButton.mapFromGlobalToRelative().x, trayButton.mapFromGlobalToRelative().y)
														}
													}
												}
												
												// layer.effect: MultiEffect {
												// 	colorization: 1
												// 	colorizationColor: parent.hovered ? colorPrimary : colorText

												// 	Behavior on colorizationColor {
												// 		ColorAnimation {
												// 			duration: 200
												// 			easing.type: Easing.InOutQuad
												// 		}
												// 	}
												// }
											}
										}
									}
								}
							}
							RoundButton {
								text: "audio/volume"
							}
							RoundButton {
								text: "notifications"
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
