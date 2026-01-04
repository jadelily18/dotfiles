import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Scope {
	id: reloadPopupRoot
	property bool failed
	property string errorString

	Connections {
		target: Quickshell

		function onReloadCompleted() {
			Quickshell.inhibitReloadPopup()
			reloadPopupRoot.failed = false
			reloadPopupLoader.loading = true
		}
		
		function onReloadFailed(error: string) {
			Quickshell.inhibitReloadPopup()
			reloadPopupLoader.active = false
			
			reloadPopupRoot.failed = true
			reloadPopupRoot.errorString = error
			
			reloadPopupLoader.loading = false
		}
	}
	
	LazyLoader {
		id: reloadPopupLoader

		PanelWindow {
			id: reloadPopup

			anchors {
				top: true
				left: true
			}

			margins {
				top: 40
				left: 40
			}

			implicitWidth: rect.width
			implicitHeight: rect.height

			color: "transparent"
			
			ClippingRectangle {
				id: rect

				implicitHeight: layout.implicitHeight + 50
				implicitWidth: layout.implicitWidth + 30

				opacity: 0.85

				radius: 20

				color: failed ? colorRed : colorBase

				MouseArea {
					id: mouseArea
					anchors.fill: parent
					onClicked: reloadPopupLoader.active = false

					hoverEnabled: true
				}
				
				ColumnLayout {
					id: layout
					anchors {
						top: parent.top
						topMargin: 20
						horizontalCenter: parent.horizontalCenter
					}

					Text {
						text: reloadPopupRoot.failed ? "Reload failed!" : "Reloaded successfully."
						color: colorText
						font.pixelSize: 20
						font.weight: Font.Black
					}

					Text {
						text: reloadPopupRoot.errorString
						visible: reloadPopupRoot.errorString != ""
						color: colorText
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

					PropertyAnimation {
						id: loadingBarAnim
						target: loadingBar
						property: "width"
						from: rect.width
						to: 0
						duration: reloadPopupRoot.failed ? 10000: 3500
						onFinished: reloadPopupLoader.active = false

						paused: mouseArea.containsMouse
					}
				}
				Component.onCompleted: loadingBarAnim.start()
			}
		}
	}
}