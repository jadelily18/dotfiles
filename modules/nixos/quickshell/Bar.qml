import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire

import qs.Widgets

Scope {
	id: bar
	
	// Colors based on Catppuccin Mocha

	Variants {
		model: Quickshell.screens;

		delegate: Component {
			PanelWindow {
				id: screenWindow
				required property var modelData
				screen: modelData

				color: "transparent"

				Component.onCompleted: {
					if (this.WlrLayershell != null) {
						this.WlrLayershell.layer = WlrLayer.Bottom;
					}
				}

				margins {
					left: 20
					right: 20
				}
				
				anchors {
					top: true
					left: true
					right: true
				}

				PopupWindow {
					id: volumeMixer
					width: 600

					height: 400

					Component.onCompleted: {
						if (this.WlrLayershell != null) {
							this.WlrLayershell.layer = WlrLayer.Bottom;
							this.WlrLayershell.namespace = "quickshell-volume-mixer";
						}
					}

					color: "transparent"

					anchor.window: screenWindow
					anchor.rect.x: screenWindow.width - volumeMixer.width
					anchor.rect.y: screenWindow.height + 20

					visible: volumeMixerBg.opacity > 0

					ClippingRectangle {
						id: volumeMixerBg

						property var transitionDuration: 100

						anchors.fill: parent
						color: colorBase
						opacity: 0

						radius: 20
						
						MultiEffect {
							layer.enabled: true
							blur: 1
						}

						Behavior on opacity {
							NumberAnimation {
								duration: transitionDuration
								easing.type: Easing.InOutQuad
							}
						}

						Behavior on scale {
							NumberAnimation {
								duration: transitionDuration
								easing.type: Easing.InOutQuad
							}
						}

						ScrollView {
							anchors.fill: parent
							anchors.margins: 12

							contentWidth: availableWidth

							ColumnLayout {
								anchors.fill: parent
								// Text {
								// 	text: "Volume Mixer"
								// 	color: colorText
								// 	font.pixelSize: 24
								// 	font.weight: Font.Bold
								// }
								spacing: 20

								PwNodeLinkTracker {
									id: nodeLinkTracker
									node: Pipewire.defaultAudioSink
								}

								VolumeMixerEntry {
									node: Pipewire.defaultAudioSink
									label: "Output Device"
								}

								Repeater {
									model: nodeLinkTracker.linkGroups

									VolumeMixerEntry {
										required property PwLinkGroup modelData
										node: modelData.source
									}
								}
							}
						}
					}
				}

				ClippingRectangle {
					anchors.fill: parent
					color: colorBase
					opacity: 0.8

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
							Layout.alignment: Qt.AlignHCenter
							Clock { }
							PrivacyDots { }
						}

						RowLayout {
							Layout.alignment: Qt.AlignRight
							RoundButton {
								text: "power mode"
							}

							RowLayout {
								id: sysTray
								Layout.fillHeight: true
								visible: SystemTray.items.values.length > 0

								// uNDefiNeD BeHAviOr >:(
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
													y: absolutePosition.y + 36 // below screen window
												}
											}


											background: Rectangle {
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
											}
										}
									}
								}
							}
							
							// RoundButton {
							// 	text: "audio/volume"
							// }
							
							RoundButton {
								id: volumeButton
								property var transitionDuration: 200
								// color: this.down ? colorMantle : (this.hovered ? colorBase : "transparent")
								visible: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio

								PwObjectTracker {
									objects: [ Pipewire.defaultAudioSink ]
								}

								background: Rectangle {
									color: parent.down ? colorCrust : (parent.hovered ? colorMantle : "transparent")
									radius: 9999
								}

								contentItem: RowLayout {
									Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
									// Layout.leftMargin: 4
									// Layout.rightMargin: 4
									spacing: 4

									IconImage {
										source: "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/speaker-wave.svg"
										implicitSize: 16
										layer.enabled: true
										layer.effect: MultiEffect {
											colorization: 1
											colorizationColor: volumeButton.hovered ? colorPrimary : colorText

											Behavior on colorizationColor {
												ColorAnimation {
													duration: volumeButton.transitionDuration
													easing.type: Easing.InOutQuad
												}
											}
										}
									}

									Text {
										text: Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%"
										font.weight: Font.Bold
										color: volumeButton.hovered ? colorPrimary : colorText

										Behavior on color {
											ColorAnimation {
												duration: volumeButton.transitionDuration
												easing.type: Easing.InOutQuad
											}
										}
									}
								}
								
								onClicked: {
									if (volumeMixer.visible) {
										volumeMixerBg.scale = 0
										volumeMixerBg.opacity = 0
									} else {
										volumeMixerBg.scale = 1
										volumeMixerBg.opacity = 0.65
									}
								}
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
