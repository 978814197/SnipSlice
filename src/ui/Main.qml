import QtQuick
import QtQuick.Dialogs
import ui 1.0

Window {
    id: win
    width: 980
    height: 680
    visible: true
    title: qsTr("SnipSlice")
    color: "#E8F5E9"

    // 状态管理
    property bool imageLoaded: false
    property string imagePath: ""

    // 文件选择对话框
    FileDialog {
        id: fileDialog
        title: "选择图片"
        nameFilters: ["图片文件 (*.png *.jpg *.jpeg *.bmp *.gif)"]
        onAccepted: {
            imagePath = selectedFile
            imageLoaded = true
        }
    }

    // 保存文件对话框
    FileDialog {
        id: saveDialog
        title: "保存切割的图片"
        fileMode: FileDialog.SaveFile
        nameFilters: ["PNG 文件 (*.png)", "JPEG 文件 (*.jpg)"]
        defaultSuffix: "png"
        onAccepted: {
            var rect = imageEditor.getSelectionRect()
            console.log("保存到:", selectedFile)
            console.log("切割区域:", rect.x, rect.y, rect.width, rect.height)
            // 这里需要调用C++函数来实际保存图片
        }
    }

    // 欢迎屏幕
    WelcomeScreen {
        anchors.fill: parent
        visible: !imageLoaded
        onFileSelected: fileDialog.open()
    }

    // 图片编辑界面
    ImageEditor {
        id: imageEditor
        anchors.fill: parent
        visible: imageLoaded
        imagePath: win.imagePath

        onBackToWelcome: {
            imageLoaded = false
        }

        onSaveRequested: {
            saveDialog.open()
        }
    }
}
