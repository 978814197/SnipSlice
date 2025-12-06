import QtQuick
import QtQuick.Layouts

// 自定义绿色主题按钮组件
Rectangle {
    id: root

    property alias text: buttonText.text
    property alias fontSize: buttonText.font.pixelSize
    property bool enabled: true

    signal clicked()

    implicitWidth: 100
    implicitHeight: 40
    radius: 10
    border.color: "#2E7D32"
    border.width: 2
    opacity: enabled ? 1.0 : 0.5

    color: {
        if (!enabled) return "#E0E0E0"
        if (mouseArea.pressed) return "#43A047"
        if (mouseArea.containsMouse) return "#66BB6A"
        return "#4CAF50"
    }

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Text {
        id: buttonText
        anchors.centerIn: parent
        font.pixelSize: 14
        color: root.enabled ? "white" : "#9E9E9E"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        onClicked: root.clicked()
    }
}
