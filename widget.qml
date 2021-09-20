import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

Item {
    width: 24
    height: 24
    objectName: 'BatchExport'

    Rectangle {
        anchors.fill: parent
        color: '#ffff00'

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onClicked: {
                batchWindow.open();
            }
        }
    }

    AlgWindow {
        id: batchWindow
        title: 'Batch Export'
        screenCentered: true
        modality: Qt.ApplicationModal

        minimumWidth: 800
        minimumHeight: 600
        maximumWidth: 800
        maximumHeight: 600

        Component.onCompleted: internal.onCompleted()

        Rectangle {
            anchors.fill: parent
            color: '#333'

            ColumnLayout {
                id: fsColumnLayout
                anchors.fill: parent

                anchors.margins: 10

                AlgLabel {
                    font.bold: true
                    text: 'General settings'
                }

                RowLayout {
                    Layout.fillWidth: true

                    AlgLabel {
                        Layout.preferredWidth: 150
                        text: 'Input directory'
                    }

                    AlgButton {
                        id: inputFolderModel
                        Layout.fillWidth: true
                        text: internal.inputFolder
                        onClicked: {
                            if (alg.fileIO.isDir('file:///' + internal.inputFolder))
                            {
                                inputFolderDialog.folder = 'file:///' + internal.inputFolder;
                            }

                            inputFolderDialog.open();
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    AlgLabel {
                        Layout.preferredWidth: 150
                        text: 'Output directory'
                    }

                    AlgButton {
                        id: outputFolderModel
                        Layout.fillWidth: true
                        text: internal.outputFolder
                        onClicked: {
                            if (alg.fileIO.isDir('file:///' + internal.outputFolder))
                            {
                                outputFolderDialog.folder = 'file:///' + internal.outputFolder;
                            }

                            outputFolderDialog.open();
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    AlgLabel {
                        Layout.preferredWidth: 150
                        text: 'Output template'
                    }

                    AlgComboBox {
                        id: templateComboBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: 27
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    AlgLabel {
                        Layout.preferredWidth: 150
                        text: 'File type'
                    }

                    AlgComboBox {
                        id: formatComboBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: 27
                        model: internal.formats
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    AlgLabel {
                        Layout.preferredWidth: 150
                        text: 'Size'
                    }

                    AlgComboBox {
                        id: sizeComboBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: 27

                        model: internal.sizes
                        textRole: 'text'
                    }
                }

                AlgLabel {
                    Layout.topMargin: 15
                    font.bold: true
                    text: 'Preview'
                }

                AlgScrollView {
                    id: previewScrollArea
                    Layout.fillWidth: true
                    height: 300
                    contentHeight: previewListView.contentHeight

                    ListView {
                        id: previewListView
                        Layout.minimumHeight: contentHeight

                        model: ListModel {
                            id: previewData
                        }

                        delegate: Rectangle {
                            width: previewScrollArea.viewportWidth
                            height: 30
                            color: index % 2 == 0 ? '#262626' : '#242424'

                            RowLayout {
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                height: parent.height

                                AlgLabel {
                                    Layout.preferredWidth: 390
                                    text: input
                                }

                                AlgLabel {
                                    text: output
                                }
                            }
                        }
                    }
                }

                AlgLabel {
                    Layout.fillWidth: true
                    id: progressLabel
                    text: 'Idle...'
                }

                AlgProgressBar {
                    id: progressBar
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                    from: 0
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom

                    AlgButton {
                        Layout.fillWidth: true
                        text: 'Cancel'
                        onClicked: internal.closeWindow()
                    }

                    AlgButton {
                        Layout.fillWidth: true
                        text: 'Export'
                        // TODO: enable in prod
                        // enabled: internal.exportBtnEnabled
                        onClicked: internal.batchExport()
                    }
                }
            }
        }

        FileDialog  {
            id: inputFolderDialog
            title: 'Choose input folder'
            folder: shortcuts.home
            selectFolder: true
            onAccepted: {
                internal.inputFolder = inputFolderDialog.fileUrl.toString().replace('file:///', '');
                internal.reloadPreview();
            }
        }

        FileDialog  {
            id: outputFolderDialog
            title: 'Choose output folder'
            folder: shortcuts.home
            selectFolder: true
            onAccepted: {
                internal.outputFolder = outputFolderDialog.fileUrl.toString().replace('file:///', '');
                internal.reloadPreview();
            }
        }
    }

    QtObject {
        id: internal

        property var previewData: []
        property var inputFolder: 'C:/Users/i7/Documents/Projects/RagdollDunk/RagdollDunk_painter'
        property var outputFolder: '...'
        property bool exportBtnEnabled: false

        property var sizes: [
            { text: 'Based on each Texture Sets\'s size', value: -1 },
            { text: '128x128', value: 128 },
            { text: '256x256', value: 256 },
            { text: '512x512', value: 512 },
            { text: '1024x1024', value: 1024 },
            { text: '2048x2048', value: 2048 },
            { text: '4096x4096', value: 4096 },
            { text: '8192x8192', value: 8192 },
        ]

        property var formats: ['bmp', 'ico', 'jpeg', 'jng', 'pbm', 'pgm', 'png', 'ppm', 'targa', 'tiff', 'wbmp', 'xpm', 'gif', 'hdr', 'exr', 'j2k', 'jp2', 'pfm', 'webm', 'jpeg-xr', 'psd']

        function onCompleted() {
            // TODO: move to persistent settings
            var stdPresets = 'C:/Program Files/Allegorithmic/Substance Painter/resources/shelf/allegorithmic/export-presets';
            var userPresets = 'C:/Users/i7/Documents/Allegorithmic/Substance Painter/shelf/export-presets';

            var presets = [];

            var stdFiles = alg.fileIO.listDir(stdPresets);
            for (var i = 0; i < stdFiles.length; i++) {
                if (stdFiles[i].indexOf('.spexp') > -1) presets.push(stdFiles[i].replace('.spexp', ''));
            }

            var userFiles = alg.fileIO.listDir(userPresets);
            for (var i = 0; i < userFiles.length; i++) {
                if (userFiles[i].indexOf('.spexp') > -1) presets.push(userFiles[i].replace('.spexp', ''));
            }

            presets.sort();
            templateComboBox.model = presets;
        }

        function reloadPreview() {
            if (!alg.fileIO.isDir(internal.inputFolder) || !alg.fileIO.isDir(internal.outputFolder))
            {
                internal.exportBtnEnabled = false;
                return;
            }

            internal.exportBtnEnabled = true;
            var files = alg.fileIO.listDir(inputFolder);
            previewData.clear()

            files.forEach(f => {
                // TODO: check by extension
                if (f.indexOf('.spp') > -1) {
                    previewData.append({
                        input: internal.inputFolder+ '/' + f,
                        output: internal.outputFolder+ '/' + f,
                    });
                }
            });
        }

        function closeWindow() {
            batchWindow.close();
        }

        function batchExport() {
            var rawFiles = alg.fileIO.listDir(inputFolder);
            var files = [];

            rawFiles.forEach(f => {
                // TODO: check by extension
                if (f.indexOf('.spp') > -1) files.push(f);
            });

            progressBar.to = files.length - 1;
            
            files.forEach(file => {
                progressLabel.text = 'Exporting ' + file + '...';
                var title = file.substring(0, file.length - 4);

                var template = templateComboBox.currentText;
                var format = formatComboBox.currentText;

                var mapInfo = {};
                var sizeVal = internal.sizes[sizeComboBox.currentIndex].value;
                if (sizeVal != -1) mapInfo.resolution = [sizeVal, sizeVal];

                alg.project.open('file:///' + internal.inputFolder + '/' + file);
                alg.mapexport.exportDocumentMaps(
                    template,
                    internal.outputFolder + '/' + title,
                    format,
                    mapInfo
                );

                alg.project.close();
                progressBar.value++;
            });

            progressLabel.text = 'Completed!';
        }
    }
}
