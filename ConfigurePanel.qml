import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import AlgWidgets 2.0

AlgWindow {
    id: configPanel
    title: 'Batch Export Configuration'
    visible: false
    modality: Qt.ApplicationModal

    minimumWidth: 600
    minimumHeight: 200
    maximumWidth: 600
    maximumHeight: 200

    screenCentered: false
    x: 300
    y: 300
    
    function loadSettings() {
        internal.loadSettings();
    }

    Rectangle {
        anchors.fill: parent
        color: 'transparent'

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            AlgLabel {
                Layout.alignment: Qt.AlignTop
                font.bold: true
                text: 'General settings'
            }

            RowLayout {
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true

                AlgLabel {
                    Layout.preferredWidth: 150
                    text: 'Substance Painter directory'
                }

                AlgButton {
                    Layout.fillWidth: true
                    text: internal.substanceFolder
                    onClicked: {
                        if (alg.fileIO.isDir('file:///' + internal.substanceFolder))
                        {
                            substanceFolderDialog.folder = 'file:///' + internal.substanceFolder;
                        }

                        substanceFolderDialog.open();
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true

                AlgLabel {
                    Layout.preferredWidth: 150
                    text: 'Shelf directory'
                }

                AlgButton {
                    Layout.fillWidth: true
                    text: internal.shelfFolder
                    onClicked: {
                        if (alg.fileIO.isDir('file:///' + internal.shelfFolder))
                        {
                            shelfFolderDialog.folder = 'file:///' + internal.shelfFolder;
                        }

                        shelfFolderDialog.open();
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true

                AlgButton {
                    Layout.fillWidth: true
                    text: '  '
                    onClicked: internal.wipeSettings()

                    RowLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        Image {
                            source: 'assets/warning.png'
                            Layout.preferredHeight: 18
                            Layout.preferredWidth: 18
                        }

                        AlgLabel {
                            horizontalAlignment: Text.AlignHCenter
                            text: 'Wipe all settings'
                        }
                    }
                }
            }

            // Status text
            RowLayout {
                Layout.fillWidth: true
                anchors.margins: 10

                AlgLabel {
                    Layout.fillWidth: true
                    text: internal.statusText
                    color: internal.statusColor
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom

                AlgButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 50
                    text: 'Cancel'
                    onClicked: internal.cancelButtonPressed()
                }

                AlgButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 50
                    text: 'Save'
                    onClicked: internal.saveButtonPressed()
                }
            }
        }

        FileDialog  {
            id: substanceFolderDialog
            title: 'Locate Substance Painter...'
            folder: shortcuts.home
            nameFilters: ['Substance Painter executable (*.exe *.app)', 'All files (*)']
            selectedNameFilter: 'Executable files (*)'
            onAccepted: internal.substanceFolder = folder.toString().replace('file:///', '')
        }

        FileDialog  {
            id: shelfFolderDialog
            title: 'Choose shelf folder...'
            folder: shortcuts.home
            selectFolder: true
            onAccepted: internal.shelfFolder = folder.toString().replace('file:///', '')
        }
    }

    QtObject {
        id: internal

        property var substanceFolder: 'N.D.'
        property var shelfFolder: 'N.D.'

        property var statusText: 'Idle...'
        property var statusColor: 'white'
        

        function loadSettings() {
            substanceFolder = alg.settings.value('substanceFolder', 'N.D.');
            shelfFolder = alg.settings.value('shelfFolder', 'N.D.');
        }

        function wipeSettings() {
            alg.settings.clear();

            substanceFolder = 'N.D.';
            shelfFolder = 'N.D.';
            statusText = 'Settings wiped!';
        }

        function cancelButtonPressed() {
            configPanel.close();
        }

        function saveButtonPressed() {
            alg.settings.setValue('substanceFolder', substanceFolder);
            alg.settings.setValue('shelfFolder', shelfFolder);

            configPanel.close();
        }
    }
}