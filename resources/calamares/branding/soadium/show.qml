import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    Timer {
        interval: 12000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        anchors.fill: parent
        Rectangle { anchors.fill: parent; color: "#0B1021"; z: -1 }
        Column {
            anchors.centerIn: parent
            spacing: 18
            Text { text: "⬢"; color: "#FACC15"; font.pixelSize: 64; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Welcome to Soadium OS"; color: "#E2E8F0"; font.pixelSize: 34; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "A clean, stable, developer-first Linux."; color: "#818CF8"; font.pixelSize: 20; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }

    Slide {
        anchors.fill: parent
        Rectangle { anchors.fill: parent; color: "#0B1021"; z: -1 }
        Column {
            anchors.centerIn: parent
            spacing: 18
            Text { text: "⬢"; color: "#22D3EE"; font.pixelSize: 64; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Everything a developer needs"; color: "#E2E8F0"; font.pixelSize: 34; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "VS Code · Docker CE · Node.js LTS · Python · GitHub CLI · Ollama"; color: "#818CF8"; font.pixelSize: 20; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }

    Slide {
        anchors.fill: parent
        Rectangle { anchors.fill: parent; color: "#0B1021"; z: -1 }
        Column {
            anchors.centerIn: parent
            spacing: 18
            Text { text: "⬢"; color: "#818CF8"; font.pixelSize: 64; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Stable by policy"; color: "#E2E8F0"; font.pixelSize: 34; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Only LTS bases, stable channels, and tagged releases. No nightlies."; color: "#818CF8"; font.pixelSize: 20; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }
}
