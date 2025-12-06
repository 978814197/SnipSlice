import QtQuick
import QtQuick.Layouts

// 顶部工具栏组件
Rectangle {
    id: root

    property real imageScale: 1.0
    property bool firstClickDone: false
    property bool secondClickDone: false

    signal backClicked()
    signal resetSelection()
    signal saveClicked()
    signal scaleChanged(real newScale)
    signal resetView()

    height: 60
    color: "#C8E6C9"
    border.color: "#81C784"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        GreenButton {
            text: "返回"
            Layout.preferredWidth: 70
            Layout.preferredHeight: 40
            onClicked: root.backClicked()
        }

        GreenButton {
            text: "重置选区"
            Layout.preferredWidth: 90
            Layout.preferredHeight: 40
            enabled: root.firstClickDone
            onClicked: root.resetSelection()
        }

        GreenButton {
            text: "保存切割"
            Layout.preferredWidth: 90
            Layout.preferredHeight: 40
            enabled: root.secondClickDone
            onClicked: root.saveClicked()
        }

        Item { Layout.fillWidth: true }

        Text {
            text: root.secondClickDone ? "✓ 选区已确定" : (root.firstClickDone ? "点击第二个点确定选区" : "点击两次以选择切割区域")
            color: "#2E7D32"
            font.pixelSize: 14
        }

        // 缩放控制
        Text {
            text: "缩放: " + (root.imageScale * 100).toFixed(0) + "%"
            color: "#2E7D32"
        }

        GreenButton {
            text: "-"
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            onClicked: root.scaleChanged(Math.max(0.1, root.imageScale - 0.1))
        }

        GreenButton {
            text: "+"
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            onClicked: root.scaleChanged(Math.min(5, root.imageScale + 0.1))
        }

        GreenButton {
            text: "100%"
            Layout.preferredWidth: 50
            Layout.preferredHeight: 30
            onClicked: root.resetView()
        }
    }
}
