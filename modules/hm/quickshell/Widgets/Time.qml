pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton{
	id: root
	property string time

	Process {
		id: dateProc
		command: ["date", "+%l:%M:%S %p"]
		running: true
		stdout: StdioCollector {
			onStreamFinished: root.time = this.text
		}
	}

	Timer {
		interval: 1000 // 1 sec
		running: true
		repeat: true
		onTriggered: dateProc.running = true
	}
}
