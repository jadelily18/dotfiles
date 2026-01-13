import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

// import "./Widgets"


Scope {
	id: notificationWidgetRoot

	property var notification
	property int notificationCount: notifServer.trackedNotifications.values.length

	function expireNotification() {
		notificationLoader.active = false
		notification.expire()
	}

	function dismissNotification() {
		notificationLoader.active = false
		notification.dismiss()
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

				radius: 30

				color: mouseArea.containsMouse ? colorMantle : colorBase 

				Behavior on color {
					ColorAnimation {
						duration: 200
						easing.type: Easing.InOutQuad
					}
				}

				MouseArea {
					id: mouseArea
					anchors.fill: parent
					onClicked: dismissNotification()

					hoverEnabled: true
				}
				
				ColumnLayout {
					id: layout
					anchors {
						fill: parent
						top: parent.top
						// topMargin: 20
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
								// Layout.margins: 8
								Layout.fillWidth: true

								onClicked: {
									modelData.invoke()
									dismissNotification()
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
						// duration: reloadPopupRoot.failed ? 10000: 3500
						duration: notification.expireTimeout < 1 ? 8000 : notification.expireTimeout * 1000
						onFinished: expireNotification()

						paused: mouseArea.containsMouse
					}
				}
				Component.onCompleted: loadingBarAnim.start()
			}
		}
	}

}