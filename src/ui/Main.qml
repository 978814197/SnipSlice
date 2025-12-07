import QtQuick
import QtQuick.Controls
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

            // 调用C++函数来裁剪并保存图片
            var success = ImageProcessor.cropAndSave(
                imagePath,
                selectedFile,
                rect.x,
                rect.y,
                rect.width,
                rect.height
            )

            if (success) {
                console.log("图片保存成功！")
                saveSuccessDialog.open()
            } else {
                console.log("图片保存失败！")
                saveErrorDialog.open()
            }
        }
    }

    // 保存成功提示对话框
    Dialog {
        id: saveSuccessDialog
        title: "成功"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent

        contentItem: Rectangle {
            implicitWidth: 300
            implicitHeight: 100
            color: "#E8F5E9"

            Text {
                anchors.centerIn: parent
                text: "图片保存成功！"
                font.pixelSize: 16
                color: "#2E7D32"
            }
        }
    }

    // 保存失败提示对话框
    Dialog {
        id: saveErrorDialog
        title: "错误"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent

        contentItem: Rectangle {
            implicitWidth: 300
            implicitHeight: 100
            color: "#FFEBEE"

            Text {
                anchors.centerIn: parent
                text: "图片保存失败，请重试！"
                font.pixelSize: 16
                color: "#C62828"
            }
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
