import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
// import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Row {
	id: privDotsWidget
	property string dotsStatus
	
	Process {
		id: privDotsProc
		command: ["/home/jade/dotfiles/modules/nixos/quickshell/scripts/privacy_dots/privacy_dots.sh"]
		running: true
		stdout: StdioCollector {
			onStreamFinished: () => {
				privDotsWidget.dotsStatus = this.text
				// console.log("Privacy dots: " + this.text)
			}
		}
	}

	Timer {
		interval: 3000 // 3 sec
		running: true
		repeat: true
		onTriggered: privDotsProc.running = true
	}

	Row {
		id: dotsContainer
		property var dotsData: dotsText()

		function dotsText() {
			const output = JSON.parse(privDotsWidget.dotsStatus)
			console.log(output.toString())
			return output
		}

		IconImage {
			source: "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/microphone.svg"
			implicitSize: 16
			visible: dotsContainer.dotsData.mic === "true"

			layer.enabled: true
			layer.effect: MultiEffect {
				colorization: 1
				colorizationColor: root.colorOrange

				Behavior on colorizationColor {
					ColorAnimation {
						duration: 200
						easing.type: Easing.InOutQuad
					}
				}
			}
		}
		
		IconImage {
			source: "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/video-camera.svg"
			implicitSize: 16
			visible: dotsContainer.dotsData.cam === "true"

			layer.enabled: true
			layer.effect: MultiEffect {
				colorization: 1
				colorizationColor: root.colorRed

				Behavior on colorizationColor {
					ColorAnimation {
						duration: 200
						easing.type: Easing.InOutQuad
					}
				}
			}
		}

		IconImage {
			source: "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/globe-alt.svg"
			implicitSize: 16
			visible: dotsContainer.dotsData.loc === "true"

			layer.enabled: true
			layer.effect: MultiEffect {
				colorization: 1
				colorizationColor: root.colorBlue

				Behavior on colorizationColor {
					ColorAnimation {
						duration: 200
						easing.type: Easing.InOutQuad
					}
				}
			}
		}
		
		IconImage {
			source: "file:///home/jade/dotfiles/modules/nixos/quickshell/assets/heroicons/computer-desktop.svg"
			implicitSize: 16
			visible: dotsContainer.dotsData.scr === "true"

			layer.enabled: true
			layer.effect: MultiEffect {
				colorization: 1
				colorizationColor: root.colorPurple

				Behavior on colorizationColor {
					ColorAnimation {
						duration: 200
						easing.type: Easing.InOutQuad
					}
				}
			}
		}

		spacing: 4
		

		
	}
}

