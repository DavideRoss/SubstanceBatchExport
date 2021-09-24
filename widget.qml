import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.1
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

AlgToolBarButton {
    id: control
    iconName: control.hovered ? 'assets/batch_hover.svg' : 'assets/batch.svg'

    onClicked: {
        if (!alg.settings.contains('stdPresets'))
        {
            substanceFolderDialog.open();
        }
        else
        {
            internal.onCompleted();
            batchWindow.open();
        }
    }

    AlgWindow {
        id: batchWindow
        title: 'Batch Export'
        modality: Qt.ApplicationModal

        minimumWidth: 800
        minimumHeight: 600
        maximumWidth: 800
        maximumHeight: 600

        screenCentered: false
        x: 300
        y: 300

        onClosing: internal.saveSettings()

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

                Rectangle {
                    visible: !internal.previewVisible
                    height: 300
                    Layout.fillWidth: true
                    color: '#2c2c2c'

                    AlgLabel {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        textFormat: Text.RichText
                        text: 'Preview not available!<br /><br />To display the preview, selech both <b>Input</b> and <b>Output</b> directories.'
                    }
                }

                AlgScrollView {
                    visible: internal.previewVisible
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
                            height: 60
                            color: index % 2 == 0 ? '#2c2c2c' : '#222222'

                            GridLayout {
                                columns: 2
                                anchors.verticalCenter: parent.verticalCenter

                                AlgLabel {
                                    Layout.preferredWidth: 75
                                    Layout.margins: 2
                                    font.bold: true
                                    horizontalAlignment: Text.AlignRight
                                    text: 'Input:'
                                }
                                
                                AlgLabel {
                                    Layout.margins: 2
                                    text: input
                                }

                                AlgLabel {
                                    Layout.preferredWidth: 75
                                    Layout.margins: 2
                                    font.bold: true
                                    horizontalAlignment: Text.AlignRight
                                    text: 'Output:'
                                }

                                AlgLabel {
                                    Layout.margins: 2
                                    text: output
                                }
                            }
                        }
                    }
                }

                // Status text
                RowLayout {
                    Layout.fillWidth: true
                    anchors.margins: 10

                    Image {
                        visible: internal.warningVisible
                        Layout.preferredHeight: 20
                        Layout.preferredWidth: 40
                        fillMode: Image.PreserveAspectFit
                        source: 'assets/warning.png'
                    }

                    AlgLabel {
                        Layout.fillWidth: true
                        text: internal.statusText
                        color: internal.statusColor
                    }
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
                        id: cancelBtn
                        Layout.fillWidth: true
                        Layout.preferredWidth: 50
                        text: internal.exporting ? 'Cancel' : 'Close'
                        onClicked: internal.cancelButtonPressed()
                    }

                    AlgButton {
                        id: exportBtn
                        Layout.fillWidth: true
                        Layout.preferredWidth: 50
                        text: 'Export'
                        enabled: internal.exportBtnEnabled
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

        FileDialog  {
            id: substanceFolderDialog
            title: 'Please locate Substance Painter...'
            folder: shortcuts.home
            nameFilters: ['Substance Painter executable (*.exe *.app)', 'All files (*)']
            selectedNameFilter: 'Executable files (*)'
            onAccepted: internal.setSubstancePath()
        }
    }

    /* TODO:
    - Create settings panel
    */

    QtObject {
        id: internal

        property var previewData: []
        property var inputFolder: 'N.D.'
        property var outputFolder: 'N.D.'

        property bool exportBtnEnabled: false
        property var statusText: 'Idle...'
        property var statusColor: 'white'
        property bool warningVisible: false // '#fee300'

        property bool exporting: false
        property bool previewVisible: false

        property var initialTemplate: 1

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
            loadSettings();

            var stdPresets = alg.settings.value('stdPresets');
            var userPresets = alg.documents_directory + '/shelf/export-presets';

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
            templateComboBox.currentIndex = initialTemplate;

            reloadPreview();
        }

        function setSubstancePath() {
            var filePath = substanceFolderDialog.fileUrl.toString();
            filePath = filePath.replace('file:///', '');
            var parts = filePath.split('/');
            parts.pop();
            var path = parts.join('/');
            alg.settings.setValue('stdPresets', path + '/resources/shelf/allegorithmic/export-presets');

            onCompleted();
            batchWindow.open();
        }

        function reloadPreview() {
            if (!alg.fileIO.isDir(inputFolder) || !alg.fileIO.isDir(outputFolder))
            {
                exportBtnEnabled = false;
                previewVisible = false;
                return;
            }

            var files = alg.fileIO.listDir(inputFolder);
            previewData.clear()

            files.forEach(f => {
                var ext = f.slice(f.length - 4);
                if (ext == '.spp') {
                    previewData.append({
                        input: inputFolder+ '/' + f,
                        output: outputFolder+ '/' + f.replace('.spp', '')
                    });
                }
            });

            exportBtnEnabled = true;
            previewVisible = true;
        }

        function saveSettings() {
            alg.settings.setValue('inputFolder', inputFolder);
            alg.settings.setValue('outputFolder', outputFolder);
            alg.settings.setValue('templateIndex', templateComboBox.currentIndex);
            alg.settings.setValue('formatIndex', formatComboBox.currentIndex);
            alg.settings.setValue('sizeIndex', sizeComboBox.currentIndex);
        }

        function loadSettings() {
            inputFolder = alg.settings.value('inputFolder', 'N.D.');
            outputFolder = alg.settings.value('outputFolder', 'N.D.');
            initialTemplate = alg.settings.value('templateIndex', 0);
            formatComboBox.currentIndex = alg.settings.value('formatIndex', 0);
            sizeComboBox.currentIndex = alg.settings.value('sizeIndex', 0);
        }

        function cancelButtonPressed() {
            if (exporting) exporting = false;
            else batchWindow.close();
        }

        function batchExport() {
            exporting = true;
            exportBtnEnabled = false;

            var rawFiles = alg.fileIO.listDir(inputFolder);
            var files = [];

            rawFiles.forEach(f => {
                var ext = f.slice(f.length - 4);
                if (ext = '.spp') files.push(f);
            });

            progressBar.to = files.length - 1;
            
            for (let file of files) {
                if (!exporting) {
                    exportBtnEnabled = true;
                    statusText = 'Export canceled!'
                    progressBar.value = 0;
                    if (alg.project.isOpen()) alg.project.close();

                    return;
                }

                statusText = 'Exporting ' + file + 'N.D.';
                var title = file.substring(0, file.length - 4);

                var template = templateComboBox.currentText;
                var format = formatComboBox.currentText;

                var mapInfo = {};
                var sizeVal = sizes[sizeComboBox.currentIndex].value;
                if (sizeVal != -1) mapInfo.resolution = [sizeVal, sizeVal];

                alg.project.open('file:///' + inputFolder + '/' + file);
                alg.mapexport.exportDocumentMaps(
                    template,
                    outputFolder + '/' + title,
                    format,
                    mapInfo
                );

                alg.project.close();
                progressBar.value++;
            }

            statusText = 'Completed!';

            exporting = false;
            exportBtnEnabled = true;
        }
    }
}
