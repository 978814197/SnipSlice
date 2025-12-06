import QtQuick

// 图片编辑界面组件
Rectangle {
    id: root

    property string imagePath: ""
    property point firstClick: Qt.point(0, 0)
    property point secondClick: Qt.point(0, 0)
    property bool firstClickDone: false
    property bool secondClickDone: false

    signal backToWelcome()
    signal saveRequested()

    color: "#E8F5E9"

    // 顶部工具栏
    Toolbar {
        id: toolbar
        width: parent.width
        anchors.top: parent.top
        imageScale: imageContainer.scale
        firstClickDone: root.firstClickDone
        secondClickDone: root.secondClickDone

        onBackClicked: root.backToWelcome()
        onResetSelection: {
            root.firstClickDone = false
            root.secondClickDone = false
        }
        onSaveClicked: root.saveRequested()
        onScaleChanged: (newScale) => imageContainer.scale = newScale
        onResetView: {
            imageContainer.scale = 1
            imageContainer.x = 0
            imageContainer.y = 0
        }
    }

    // 图片显示区域
    Rectangle {
        id: imageArea
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#F1F8E9"
        clip: true

        // 图片容器（支持缩放和拖动）
        Item {
            id: imageContainer
            width: displayImage.width
            height: displayImage.height
            scale: 1
            transformOrigin: Item.TopLeft

            Image {
                id: displayImage
                source: root.imagePath
                fillMode: Image.PreserveAspectFit
                width: imageArea.width
                height: imageArea.height

                MouseArea {
                    id: imageMouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true
                    property point lastPos: Qt.point(0, 0)
                    property bool isDragging: false

                    onPressed: (mouse) => {
                        if (root.secondClickDone) {
                            // 如果已经完成选区，则进行拖动
                            isDragging = true
                            lastPos = Qt.point(mouse.x, mouse.y)
                        }
                    }

                    onPositionChanged: (mouse) => {
                        // 更新鼠标位置用于虚线框
                        selectionArea.currentMousePos = mapToItem(imageArea, mouse.x, mouse.y)

                        if (isDragging && root.secondClickDone) {
                            var dx = mouse.x - lastPos.x
                            var dy = mouse.y - lastPos.y
                            imageContainer.x += dx * imageContainer.scale
                            imageContainer.y += dy * imageContainer.scale
                        }
                    }

                    onReleased: {
                        isDragging = false
                    }

                    onClicked: (mouse) => {
                        if (!root.secondClickDone && !isDragging) {
                            var globalPos = mapToItem(imageArea, mouse.x, mouse.y)

                            if (!root.firstClickDone) {
                                // 第一次点击
                                root.firstClick = globalPos
                                root.firstClickDone = true
                            } else {
                                // 第二次点击
                                root.secondClick = globalPos
                                root.secondClickDone = true
                            }
                        }
                    }
                }
            }

            // 选区显示
            SelectionArea {
                id: selectionArea
                anchors.fill: parent
                firstClick: root.firstClick
                secondClick: root.secondClick
                firstClickDone: root.firstClickDone
                secondClickDone: root.secondClickDone
            }
        }

        // 鼠标滚轮缩放
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true
            onWheel: (wheel) => {
                var scaleFactor = wheel.angleDelta.y > 0 ? 1.1 : 0.9
                var newScale = imageContainer.scale * scaleFactor
                newScale = Math.max(0.1, Math.min(5, newScale))
                imageContainer.scale = newScale
            }
        }
    }

    // 获取切割区域信息
    function getSelectionRect() {
        return {
            x: Math.min(firstClick.x, secondClick.x) / imageContainer.scale,
            y: Math.min(firstClick.y, secondClick.y) / imageContainer.scale,
            width: Math.abs(secondClick.x - firstClick.x) / imageContainer.scale,
            height: Math.abs(secondClick.y - firstClick.y) / imageContainer.scale
        }
    }
}
