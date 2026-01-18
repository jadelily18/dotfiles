pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications


Singleton {
	id: root

	// property var notifsTest: []
	property alias notifications: notifServer.trackedNotifications

	signal notification(notification: Notification)

	NotificationServer {
		id: notifServer
		actionsSupported: true
		imageSupported: true
		persistenceSupported: true
		bodyMarkupSupported: true

		onNotification: (notif) => {
			notif.tracked = true
			// notifsTest.push(notif)
			// notificationWidgetRoot.notification = notif
			// notifPopupLoader.active = true

			// console.log(`Notification icon: '${notif.image}'`)

			// console.log(`New notification received:\nApp: ${notif.appName}\nSummary: ${notif.summary}\nBody: ${notif.body}\nActions: ${notif.actions}\nExpire Timeout: ${notif.expireTimeout}\nID: ${notif.id}`)
			// console.log(notifications)
		}
	}

}