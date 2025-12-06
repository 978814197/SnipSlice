import QtQuick
import QtQuick.Layouts

// 欢迎屏幕组件
Rectangle {
    id: root

    signal fileSelected()

    color: "#E8F5E9"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 30

        // 标题
        Text {
            text: "SnipSlice"
            font.pixelSize: 48
            font.bold: true
            color: "#2E7D32"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "图片切割工具"
            font.pixelSize: 20
            color: "#66BB6A"
            Layout.alignment: Qt.AlignHCenter
        }

        // 选择文件按钮
        GreenButton {
            text: "选择图片"
            fontSize: 18
            Layout.preferredWidth: 200
            Layout.preferredHeight: 60
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.fileSelected()
        }
    }
}
