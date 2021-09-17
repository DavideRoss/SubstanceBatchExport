import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12
import AlgWidgets 2.0

Item {
    width: 24
    height: 24
    objectName: 'BatchExport'
    property alias rectangle: rect

    Rectangle {
        id: rect
        anchors.fill: parent
        color: 'red'

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onClicked: {
                batchWindow.open();
                // var base = 'D:/Projects/3D Works/Slum_tower/Slum_tower_painter/';
                // var output = 'D:/Projects/3D Works/Slum_tower/Slum_tower_batch/';
                // var files = alg.fileIO.listDir(base);

                // files.forEach(file => {
                //     if (file === 'wips') return;

                //     var title = file.substring(0, file.length - 4);

                //     alg.project.open('file:///' + base + file);
                //     alg.mapexport.exportDocumentMaps(
                //         'Unreal Engine 4 (Packed)',
                //         output + title,
                //         'png'
                //     );

                //     alg.project.close();
                // });
            }
        }
    }

    AlgWindow {
        id: batchWindow
        title: 'Batch Export'
        screenCentered: true

        minimumWidth: 800
        minimumHeight: 600
        maximumWidth: 800
        maximumHeight: 600

        Rectangle {
            width: parent.width
            height: fsColumnLayout.height

            border.color: '#ff0000'
            border.width: 1
            color: '#00000000'

            ColumnLayout {
                id: fsColumnLayout
                height: 60
                anchors.fill: parent

                RowLayout {
                    height: 30
                    Layout.fillWidth: true

                    AlgTextEdit {
                        height: parent.height
                        tooltip: 'Input'
                        Layout.fillWidth: true
                    }

                    AlgButton {
                        height: parent.height
                        text: 'Set input'
                    }
                }

                RowLayout {
                    height: 30
                    Layout.fillWidth: true

                    AlgTextEdit {
                        height: parent.height
                        tooltip: 'Output'
                        Layout.fillWidth: true
                    }

                    AlgButton {
                        height: parent.height
                        text: 'Set Output'
                    }
                }
            }
        }
    }
}
