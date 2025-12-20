import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
	Layout.fillHeight: true
	Layout.fillWidth: true
	spacing: 2
	Repeater {
		id: workspaceRepeater
		property var thisMonitor: Hyprland.monitorFor(screenWindow.screen)
		property var workspaces: Hyprland.workspaces.values.filter(w => w.monitor.id === thisMonitor.id)

		model: workspaces

		RoundButton {
			property var workspace: modelData
			property bool isActive: Hyprland.focusedWorkspace?.id == workspace.id
			onClicked: {
				console.log("Switching to workspace " + workspace.id)
				Hyprland.dispatch("workspace " + workspace.id)
				Hyprland.refreshWorkspaces()
			}

			background: Rectangle {
				color: isActive ? root.colorText : (parent.hovered ? root.colorSubtext : "transparent")
				implicitWidth: isActive ? 54 : 32
				radius: 9999
				
				Behavior on color {
					ColorAnimation {
						duration: 200
						easing.type: Easing.InOutQuad
					}
				}

				Behavior on implicitWidth {
					NumberAnimation {
						duration: 200
						easing.type: Easing.InOutQuad
					}
				}
			}

			contentItem: Text {
				text: workspace.id
				font.pixelSize: 16
				font.weight: Font.Bold
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: isActive ? root.colorBase : (parent.hovered ? root.colorBase : root.colorText)

				Behavior on color {
					ColorAnimation {
						duration: 200
						easing.type: Easing.InOutQuad
					}
				}
			}

			// color: isActive ? root.colorText : root.colorMantle
		}
	}
}
