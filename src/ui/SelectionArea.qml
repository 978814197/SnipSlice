import QtQuick
import QtQuick.Shapes

// 选区显示组件
Item {
    id: root

    property point firstClick: Qt.point(0, 0)
    property point secondClick: Qt.point(0, 0)
    property bool firstClickDone: false
    property bool secondClickDone: false
    property point currentMousePos: Qt.point(0, 0)

    // 第一次点击后的虚线框（跟随鼠标）
    Shape {
        visible: root.firstClickDone && !root.secondClickDone
        anchors.fill: parent

        ShapePath {
            strokeColor: "#4CAF50"
            strokeWidth: 2
            strokeStyle: ShapePath.DashLine
            dashPattern: [4, 4]
            fillColor: "transparent"

            startX: root.firstClick.x
            startY: root.firstClick.y

            PathLine {
                x: root.currentMousePos.x
                y: root.firstClick.y
            }
            PathLine {
                x: root.currentMousePos.x
                y: root.currentMousePos.y
            }
            PathLine {
                x: root.firstClick.x
                y: root.currentMousePos.y
            }
            PathLine {
                x: root.firstClick.x
                y: root.firstClick.y
            }
        }
    }

    // 第二次点击后的固定选区框
    Rectangle {
        visible: root.secondClickDone
        x: Math.min(root.firstClick.x, root.secondClick.x)
        y: Math.min(root.firstClick.y, root.secondClick.y)
        width: Math.abs(root.secondClick.x - root.firstClick.x)
        height: Math.abs(root.secondClick.y - root.firstClick.y)
        color: "transparent"
        border.color: "#4CAF50"
        border.width: 3

        // 四个角的控制点
        Repeater {
            model: 4
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: "#4CAF50"
                x: (index % 2 === 0) ? -5 : parent.width - 5
                y: (index < 2) ? -5 : parent.height - 5
            }
        }
    }
}
