import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Widgets

Scope {
	id: root

	Variants {
		model: Quickshell.screens;

		PanelWindow {
			required property var modelData
			screen: modelData

			color: "transparent"
			
			anchors {
				top: true
				left: true
				right: true
			}

			implicitHeight: 30

			RowLayout {
				anchors.fill: parent
				spacing: 10

				Item {
					Text {
						text: "Screen " + modelData.name
					}
				}

				Item {
					Text {
						text: "Screen " + modelData.name
					}
				}

				Rectangle {
					color: "#800000"
					Text {
						anchors.centerIn: parent
						text: Time.time
					}
				}
				
				Rectangle {
					color: "#800000"
					Text {
						anchors.centerIn: parent
						text: Time.time
					}
				}
			}
		}
	}
}
