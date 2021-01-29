import QtQuick 2.7
import QtQuick.Layouts 1.1
import SystemSettings 1.0
import Ubuntu.Components 1.3
import SystemSettings.ListItems 1.0 as SettingsListItems

ItemPage {
    id: root
    title: i18n.tr("VPN")
    objectName: "vpnPage"
    flickable: scrollWidget

    property var files

    signal validate(var selected, var login, var password)
    signal cancel()

    Flickable {
        id: scrollWidget
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: actionButtons.top
            margins: units.gu(2)
        }
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > root.height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

        Column {
            anchors { left: parent.left; right: parent.right }

            ListView {
                model: files.length
                anchors { left: parent.left; right: parent.right }
                height: contentItem.height
                clip: true
                delegate: SettingsListItems.Standard {
                    text: files[index].displayName
                    Switch {
                        id: devModeSwitch
                        checked: files[index].checked
                        onClicked: files[index].checked = !files[index].checked
                    }
                }
            }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: actionInput.top
        }
        // This rectangle acts as a horizontal border on top of the action
        // buttons. I.e. height is the width of the border.
        height: units.dp(2)
        color: theme.palette.normal.foreground
    }

    Rectangle {
        color: theme.palette.normal.background
        id: actionInput
        anchors {
            left: parent.left
            right: parent.right
            bottom: actionButtons.top
        }
        height: units.gu(12)

        ColumnLayout {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: units.gu(2)
            }
            spacing: units.gu(2)

            CheckBox {
                id: anonymousCheck
                checked: true
                text: i18n.tr("Anonymous")
            }

            RowLayout {
                spacing: units.gu(2)

                TextField {
                    id: importOvpnPromptDiagLogin
                    placeholderText: i18n.tr("Login")
                    enabled: !anonymousCheck.checked
                    Layout.fillWidth: true
                }

                TextField {
                    id: importOvpnPromptDiagPassword
                    placeholderText: i18n.tr("Password")
                    echoMode: TextInput.Password
                    enabled: !anonymousCheck.checked
                    Layout.fillWidth: true
                }
            }
        }
    }

    Rectangle {
        color: theme.palette.normal.background
        id: actionButtons
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(6)
    
        RowLayout {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: units.gu(2)
            }
            spacing: units.gu(2)

            Button {
                text: i18n.dtr("ubuntu-settings-components", "Cancel")
                onClicked: {
                    pageStack.removePages(root);
                    cancel();
                }
                Layout.fillWidth: true
            }

            Button {
                text: i18n.dtr("ubuntu-settings-components", "OK")
                onClicked: {
                    pageStack.removePages(root);
                    var selectedPath = [];
                    for (var i=0; i<files.length; i++) {
                        if (files[i].checked) {
                            selectedPath.push(files[i].path);
                        }
                    }
                    validate(selectedPath, importOvpnPromptDiagLogin.text, importOvpnPromptDiagPassword.text);
                }
                Layout.fillWidth: true
                enabled: true
            }
        }
    }
}
