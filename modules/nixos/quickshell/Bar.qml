import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Widgets

Scope {
	id: root
	
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
				// property var screen: modelData
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
						anchors.fill: parent
						Layout.margins: 10
						spacing: 10

						RowLayout {
							Layout.fillWidth: true
							Layout.fillHeight: true
							Layout.margins: 4
							Layout.leftMargin: 8
							Layout.rightMargin: 8
							
							RowLayout {
								Layout.fillWidth: true
								Layout.fillHeight: true
								
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
										// width: 24
										// height: 24
										// fillMode: Image.PreserveAspectFit
										// anchors.verticalCenter: parent.verticalCenter
									}
								}
								
								Workspaces { }
							}

							RowLayout {
								Layout.fillWidth: true
								Layout.fillHeight: true
								Clock { }
							}

							RowLayout {
								Layout.fillWidth: true
								Layout.fillHeight: true
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
