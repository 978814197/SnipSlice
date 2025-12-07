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

                        // 更新坐标显示
                        coordinateDisplay.updatePosition(mouse.x, mouse.y)

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

                    onExited: {
                        coordinateDisplay.visible = false
                    }

                    onEntered: {
                        coordinateDisplay.visible = true
                    }

                    onClicked: (mouse) => {
                        if (!root.secondClickDone && !isDragging) {
                            // 将鼠标坐标转换为imageArea坐标系（选区框的父坐标系）
                            var areaPos = mapToItem(imageArea, mouse.x, mouse.y)

                            if (!root.firstClickDone) {
                                // 第一次点击
                                root.firstClick = areaPos
                                root.firstClickDone = true
                            } else {
                                // 第二次点击
                                root.secondClick = areaPos
                                root.secondClickDone = true
                            }
                        }
                    }
                }
            }
        }

        // 选区显示（移到imageArea层级，避免缩放影响）
        SelectionArea {
            id: selectionArea
            anchors.fill: parent
            firstClick: root.firstClick
            secondClick: root.secondClick
            firstClickDone: root.firstClickDone
            secondClickDone: root.secondClickDone

            onSelectionChanged: (newFirstClick, newSecondClick) => {
                root.firstClick = newFirstClick
                root.secondClick = newSecondClick
            }
        }

        // 坐标显示（跟随鼠标）- 放在imageArea层级，不受缩放影响
        Rectangle {
            id: coordinateDisplay
            visible: false
            width: coordText.width + 16
            height: coordText.height + 12
            color: "#2E7D32"
            opacity: 0.9
            radius: 5
            border.color: "#1B5E20"
            border.width: 1
            z: 100  // 确保在最上层

            property point imagePos: Qt.point(0, 0)

            // 根据鼠标位置更新显示
            function updatePosition(imgX, imgY) {
                imagePos = Qt.point(Math.round(imgX), Math.round(imgY))

                // 获取imageContainer相对于imageArea的位置，考虑缩放和偏移
                var containerX = imageContainer.x
                var containerY = imageContainer.y
                var scale = imageContainer.scale

                // 计算鼠标在imageArea中的实际显示位置
                var displayX = containerX + imgX * scale
                var displayY = containerY + imgY * scale

                // 默认显示在光标右下方
                var offsetX = 10
                var offsetY = 10

                // 如果太靠右，显示在左边
                if (displayX + width + offsetX > imageArea.width) {
                    offsetX = -width - 10
                }

                // 如果太靠下，显示在上边
                if (displayY + height + offsetY > imageArea.height) {
                    offsetY = -height - 10
                }

                x = displayX + offsetX
                y = displayY + offsetY
            }

            Text {
                id: coordText
                anchors.centerIn: parent
                text: "X: " + coordinateDisplay.imagePos.x + "  Y: " + coordinateDisplay.imagePos.y
                color: "white"
                font.pixelSize: 12
                font.family: "Consolas, Monaco, monospace"
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

    // 获取切割区域信息（转换为原始图片坐标）
    function getSelectionRect() {
        // 选区在imageArea中的坐标
        var minX = Math.min(firstClick.x, secondClick.x)
        var minY = Math.min(firstClick.y, secondClick.y)
        var maxX = Math.max(firstClick.x, secondClick.x)
        var maxY = Math.max(firstClick.y, secondClick.y)

        // 减去imageContainer的偏移
        minX -= imageContainer.x
        minY -= imageContainer.y
        maxX -= imageContainer.x
        maxY -= imageContainer.y

        // 除以缩放比例，得到displayImage中的坐标
        minX /= imageContainer.scale
        minY /= imageContainer.scale
        maxX /= imageContainer.scale
        maxY /= imageContainer.scale

        // 获取图片的实际尺寸和显示尺寸
        var sourceWidth = displayImage.sourceSize.width
        var sourceHeight = displayImage.sourceSize.height
        var displayWidth = displayImage.paintedWidth
        var displayHeight = displayImage.paintedHeight

        // 计算图片在displayImage中的偏移（由于PreserveAspectFit）
        var offsetX = (displayImage.width - displayWidth) / 2
        var offsetY = (displayImage.height - displayHeight) / 2

        // 减去偏移，得到在实际显示图片区域的坐标
        minX -= offsetX
        minY -= offsetY
        maxX -= offsetX
        maxY -= offsetY

        // 计算缩放比例（显示尺寸到原始尺寸）
        var scaleX = sourceWidth / displayWidth
        var scaleY = sourceHeight / displayHeight

        // 转换为原始图片坐标
        var cropX = minX * scaleX
        var cropY = minY * scaleY
        var cropWidth = (maxX - minX) * scaleX
        var cropHeight = (maxY - minY) * scaleY

        // 确保坐标在有效范围内
        cropX = Math.max(0, Math.min(cropX, sourceWidth))
        cropY = Math.max(0, Math.min(cropY, sourceHeight))
        cropWidth = Math.max(1, Math.min(cropWidth, sourceWidth - cropX))
        cropHeight = Math.max(1, Math.min(cropHeight, sourceHeight - cropY))

        return {
            x: Math.round(cropX),
            y: Math.round(cropY),
            width: Math.round(cropWidth),
            height: Math.round(cropHeight)
        }
    }
}
