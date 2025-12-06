add_library(ui STATIC)
qt_add_qml_module(ui
        URI "ui"
        VERSION 1.0
        QML_FILES
        Main.qml
        GreenButton.qml
        ImageEditor.qml
        SelectionArea.qml
        Toolbar.qml
        WelcomeScreen.qml
)