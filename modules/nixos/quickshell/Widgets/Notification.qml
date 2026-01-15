import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

// import "./Widgets"


Scope {
	id: notificationWidgetRoot

	property var notification
	property int notificationCount: notifServer.trackedNotifications.values.length

	property bool showHoverBackground: false
	// property alias hovered: notificationHoverHandler.hovered

	function expireNotification() {
		notification.expire()
		notificationLoader.active = false
	}

	function dismissNotification() {
		notification.dismiss()
		notificationLoader.active = false
	}
	
	Connections {
		target: NotificationServer {
			id: notifServer
			actionsSupported: true
			imageSupported: true
			persistenceSupported: true
			bodyMarkupSupported: true

			onNotification: (notif) => {
				notif.tracked = true
				notificationWidgetRoot.notification = notif
				notificationLoader.active = true

				console.log(`Notification icon: '${notif.image}'`)
			}
		}
	}


	LazyLoader {
		id: notificationLoader

		PanelWindow {
			id: notificationPopup

			anchors {
				top: true
				right: true
			}

			margins {
				top: 40
				right: 40
			}

			implicitWidth: rect.width
			implicitHeight: rect.height

			color: "transparent"
			
			ClippingRectangle {
				id: rect

				implicitHeight: layout.implicitHeight
				implicitWidth: 450


				opacity: 0.85

				radius: 24

				color: showHoverBackground ? colorMantle : colorBase 

				Behavior on color {
					ColorAnimation {
						duration: 200
						easing.type: Easing.InOutQuad
					}
				}

				// This is purely for the progress bar.
				HoverHandler {
					id: notificationHoverHandler
				}

				MouseArea {
					id: mouseArea
					anchors.fill: parent
					hoverEnabled: true
					onClicked: dismissNotification()

					onEntered: {
						showHoverBackground = true
					}
					onExited: {
						showHoverBackground = false
					}
				}
				
				RoundButton {
					opacity: notificationHoverHandler.hovered ? 1 : 0
					visible: opacity > 0

					onClicked: dismissNotification()

					anchors {
						top: parent.top
						right: parent.right
						margins: 16
					}

					Behavior on opacity {
						NumberAnimation {
							duration: 200
							easing.type: Easing.InOutQuad
						}
					}

					background: ClippingRectangle {
						color: parent.pressed ? colorCrust : (parent.hovered ? colorMantle : "transparent")
						radius: 9999

						Behavior on color {
							ColorAnimation {
								duration: 200
								easing.type: Easing.InOutQuad
							}
						}
					}

					contentItem: IconImage {
						source: "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/x-mark.svg"
						implicitSize: 20
						layer.enabled: true
						layer.effect: MultiEffect {
							colorization: 1
							colorizationColor: colorText
						}
					}
				}
				
				ColumnLayout {
					id: layout
					anchors {
						fill: parent
						top: parent.top
					}

					spacing: 0


					RowLayout {
						Layout.fillWidth: true
						Layout.margins: 16

						spacing: 12

						NotificationIcon {
							Layout.alignment: Qt.AlignTop
							notifImageSrc: notification.image
							notifAppIconSrc: notification.appIcon
						}
								
						ColumnLayout {
							Layout.fillWidth: true
							Text {
								text: notification.appName
								color: colorSubtext1

								font.pixelSize: 12
								font.weight: Font.Bold
								elide: Text.ElideRight

								Layout.fillWidth: true
							}

							Text {
								text: notification.summary
								color: colorText
								
								font.pixelSize: 16
								font.weight: Font.Bold
								elide: Text.ElideRight
								
								Layout.fillWidth: true
							}

							Text {
								text: notification.body
								color: colorText

								elide: Text.ElideRight
								wrapMode: Text.WordWrap
								textFormat: Text.MarkdownText

								Layout.fillWidth: true

								HoverHandler {
									id: bodyHoverHandler
								}
							}
						}
					}

					RowLayout {
						visible: notification.actions.length > 0

						Layout.leftMargin: 16
						Layout.rightMargin: 16
						Layout.bottomMargin: 12

						spacing: 8

						Repeater {
							model: notification.actions

							RoundButton {
								id: actionButton
								text: modelData.text
								Layout.fillWidth: true
								
								onClicked: (mouse) => {
									modelData.invoke()
									dismissNotification()
									mouse.accepted = false
								}

								background: Rectangle {
									color: parent.down ? colorCrust : (parent.hovered ? colorMantle : "transparent")
									radius: 9999

									Behavior on color {
										ColorAnimation {
											duration: 200
											easing.type: Easing.InOutQuad
										}
									}
								}
								
								contentItem: Text {
									text: parent.text
									color: colorText
									font.pixelSize: 16
									font.weight: Font.Bold
									Layout.fillWidth: true
									horizontalAlignment: Text.AlignHCenter
								}
							}
						}
					}
				}
				
				
				
				Rectangle {
					id: loadingBar
					color: colorPrimary
					anchors {
						bottom: parent.bottom
						left: parent.left
					}
					height: 6

					radius: 9999

					PropertyAnimation {
						id: loadingBarAnim
						target: loadingBar
						property: "width"
						from: rect.width
						to: 0
						duration: notification.expireTimeout < 1 ? 8000 : notification.expireTimeout * 1000
						onFinished: expireNotification()

						paused: notificationHoverHandler.hovered
					}
				}
				Component.onCompleted: loadingBarAnim.start()
			}
		}
	}

}