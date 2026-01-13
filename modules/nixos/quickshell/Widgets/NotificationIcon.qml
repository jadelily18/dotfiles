import QtQuick
import Quickshell
import Quickshell.Widgets

Row {
	required property var notifImageSrc
	required property var notifAppIconSrc
	
	Image {
		source: Quickshell.iconPath(notifAppIconSrc, true)
		visible: notifImageSrc == "" && notifAppIconSrc != ""
		sourceSize.width: 75
		sourceSize.height: 75
	}

	Image {
		source: notifImageSrc
		visible: notifImageSrc != "" && notifAppIconSrc == ""
		sourceSize.width: 55
		sourceSize.height: 55
	}

	Item {
		visible: notifAppIconSrc != "" && notifImageSrc != ""

		width: appIconImg.width
		height: appIconImg.height

		Image {
			id: appIconImg
			source: Quickshell.iconPath(notifAppIconSrc, true)
			sourceSize.width: 75
			sourceSize.height: 75
		}
		
		Image {
			anchors {
				right: parent.right
				bottom: parent.bottom
			}

			source: notifImageSrc
			// Layout.margins: 16
			width: 40
			height: 40
			// implicitSize: 40
		}
	}

}