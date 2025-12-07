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

    signal selectionChanged(point newFirstClick, point newSecondClick)

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

    // 第二次点击后的固定选区框（可拖动和调整大小）
    Rectangle {
        id: selectionBox
        visible: root.secondClickDone
        x: Math.min(root.firstClick.x, root.secondClick.x)
        y: Math.min(root.firstClick.y, root.secondClick.y)
        width: Math.abs(root.secondClick.x - root.firstClick.x)
        height: Math.abs(root.secondClick.y - root.firstClick.y)
        color: "transparent"
        border.color: "#4CAF50"
        border.width: 3

        property int edgeThreshold: 12  // 边缘检测阈值（缩小范围）

        // 扩展的拖动区域（包括边框外部）
        MouseArea {
            id: boxMouseArea
            anchors.fill: parent
            anchors.margins: -8  // 向外扩展8像素（减小范围）
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton

            property point dragStartGlobal: Qt.point(0, 0)  // 全局坐标
            property bool isDragging: false
            property string resizeMode: "none"
            property point originalFirst: Qt.point(0, 0)
            property point originalSecond: Qt.point(0, 0)
            property string currentMode: "none"

            // 根据currentMode动态设置光标
            cursorShape: {
                switch(currentMode) {
                    case "topLeft":
                    case "bottomRight":
                        return Qt.SizeFDiagCursor
                    case "topRight":
                    case "bottomLeft":
                        return Qt.SizeBDiagCursor
                    case "top":
                    case "bottom":
                        return Qt.SizeVerCursor
                    case "left":
                    case "right":
                        return Qt.SizeHorCursor
                    case "move":
                        return Qt.SizeAllCursor
                    default:
                        return Qt.ArrowCursor
                }
            }

            // 判断鼠标在哪个区域
            function getResizeMode(mx, my) {
                var threshold = parent.edgeThreshold
                var boxWidth = parent.width
                var boxHeight = parent.height

                // 调整坐标，因为MouseArea扩展了8像素
                var adjustedX = mx - 8
                var adjustedY = my - 8

                var inLeft = adjustedX < threshold
                var inRight = adjustedX > boxWidth - threshold
                var inTop = adjustedY < threshold
                var inBottom = adjustedY > boxHeight - threshold

                if (inTop && inLeft) return "topLeft"
                if (inTop && inRight) return "topRight"
                if (inBottom && inLeft) return "bottomLeft"
                if (inBottom && inRight) return "bottomRight"
                if (inTop) return "top"
                if (inBottom) return "bottom"
                if (inLeft) return "left"
                if (inRight) return "right"

                // 只有在边框内部才是移动模式
                if (adjustedX >= 0 && adjustedX <= boxWidth &&
                    adjustedY >= 0 && adjustedY <= boxHeight) {
                    return "move"
                }

                return "none"
            }

            onPositionChanged: (mouse) => {
                if (!isDragging) {
                    // 更新光标模式
                    currentMode = getResizeMode(mouse.x, mouse.y)
                } else {
                    // 转换为全局坐标（相对于imageArea）
                    var globalPos = mapToItem(root, mouse.x, mouse.y)
                    var dx = globalPos.x - dragStartGlobal.x
                    var dy = globalPos.y - dragStartGlobal.y

                    // 使用原始位置计算新位置
                    var minX = Math.min(originalFirst.x, originalSecond.x)
                    var minY = Math.min(originalFirst.y, originalSecond.y)
                    var maxX = Math.max(originalFirst.x, originalSecond.x)
                    var maxY = Math.max(originalFirst.y, originalSecond.y)

                    switch(resizeMode) {
                        case "move":
                            minX += dx
                            maxX += dx
                            minY += dy
                            maxY += dy
                            break
                        case "topLeft":
                            minX += dx
                            minY += dy
                            break
                        case "topRight":
                            maxX += dx
                            minY += dy
                            break
                        case "bottomLeft":
                            minX += dx
                            maxY += dy
                            break
                        case "bottomRight":
                            maxX += dx
                            maxY += dy
                            break
                        case "top":
                            minY += dy
                            break
                        case "bottom":
                            maxY += dy
                            break
                        case "left":
                            minX += dx
                            break
                        case "right":
                            maxX += dx
                            break
                    }

                    // 确保宽高最小为10像素
                    if (maxX - minX >= 10 && maxY - minY >= 10) {
                        root.selectionChanged(Qt.point(minX, minY), Qt.point(maxX, maxY))
                    }
                }
            }

            onEntered: {
                currentMode = getResizeMode(mouseX, mouseY)
            }

            onExited: {
                currentMode = "none"
            }

            onPressed: (mouse) => {
                isDragging = true
                // 记录全局起始位置
                dragStartGlobal = mapToItem(root, mouse.x, mouse.y)
                resizeMode = getResizeMode(mouse.x, mouse.y)

                // 保存原始选区位置
                originalFirst = root.firstClick
                originalSecond = root.secondClick
            }

            onReleased: {
                isDragging = false
                resizeMode = "none"
            }
        }

        // 四个角的控制点（视觉指示）
        Repeater {
            model: 4
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: "#4CAF50"
                border.color: "#1B5E20"
                border.width: 1
                x: (index % 2 === 0) ? -5 : parent.width - 5
                y: (index < 2) ? -5 : parent.height - 5
                z: 10
            }
        }

        // 四条边的中点控制点
        Repeater {
            model: 4
            Rectangle {
                width: index < 2 ? 8 : parent.width * 0.1
                height: index < 2 ? parent.height * 0.1 : 8
                radius: 3
                color: "#4CAF50"
                border.color: "#1B5E20"
                border.width: 1
                x: {
                    if (index === 0) return -4  // 左
                    if (index === 1) return parent.width - 4  // 右
                    return parent.width / 2 - width / 2  // 上下
                }
                y: {
                    if (index === 2) return -4  // 上
                    if (index === 3) return parent.height - 4  // 下
                    return parent.height / 2 - height / 2  // 左右
                }
                z: 10
            }
        }
    }
}
