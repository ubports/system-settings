/*
 * This file is part of system-settings
 *
 * Copyright (C) 2018 The UBports Project
 *
 * Written by: Marius Gripsgard <marius@ubports.com>
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QMenuModel 0.1
import QtQuick 2.4
import QtQuick.Layouts 1.1
import SystemSettings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import Ubuntu.SystemSettings.Update 1.0
import Ubuntu.Connectivity 1.0

ItemPage {
    id: root
    objectName: "firmwareUpdatePage"

    header: PageHeader {
        title: i18n.tr("Firmware Update")
        flickable: pageFlickable
    }

    property bool online: NetworkingStatus.online
    property bool hasUpdate: false
    property bool isUpdating: false
    property bool isChecking: true
    property var partitions: ""

    function check() {
        root.isChecking = true;
        SystemImage.checkForFirmwareUpdate();
    }

    function flash() {
        root.isUpdating = true;
        SystemImage.updateFirmware();
    }

    Connections {
        target: SystemImage
        onCheckForFirmwareUpdateDone: {
            var updateobj = JSON.parse(updateObj);
            if (Array.isArray(updateobj) && updateobj.length > 0) {
              for (var u in updateobj) {
                console.log(u);
                if (root.partitions === "")
                  root.partitions += updateobj[u].file;
                else
                  root.partitions += ", " + updateobj[u].file;
              }
              root.hasUpdate = true;
            }
            console.log(updateobj);
            root.isChecking = false;
        }
        onUpdateFirmwareDone: {
            var updateobj = JSON.parse(updateObj);
            if (Array.isArray(updateobj) && updateobj.length === 0) {
              // This means success!
              root.hasUpdate = false;
              root.partitions = "";
              SystemImage.reboot();
              return;
            }
            console.log(updateobj);
            root.isUpdating = false;
        }
    }

    Flickable {
        id: pageFlickable
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: contentItem.childrenRect.height
        visible: !spinner.visible

        // Only allow flicking if the content doesn't fit on the page
        boundsBehavior: (contentHeight > root.height) ?
                         Flickable.DragAndOvershootBounds : Flickable.StopAtBounds


      Column {
          id: column
          anchors {
              top: parent.top + units.gu(10)
              left: parent.left
              right: parent.right
              bottom: parent.bottom
          }
          spacing: units.gu(3)
          opacity: spinner.visible ? 0.5 : 1
          Behavior on opacity {
              UbuntuNumberAnimation {}
          }

          Rectangle {
              id: overlay
              objectName: "overlay"
              anchors {
                  left: parent.left
                  leftMargin: units.gu(2)
                  right: parent.right
                  rightMargin: units.gu(2)
              }
              visible: placeholder.text
              color: theme.palette.normal.background
              height: units.gu(10)

              Label {
                  id: placeholder
                  objectName: "overlayText"
                  anchors.fill: parent
                  verticalAlignment: Text.AlignVCenter
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  text: hasUpdate ? i18n.tr("There is a firmware update available!")
                                  : i18n.tr("Firmware is up to date!")
              }
          }

          GridLayout {
              rows: 3
              columns: 2
              rowSpacing: units.gu(1)
              columnSpacing: units.gu(2)
              anchors.horizontalCenter: parent.horizontalCenter
              visible: hasUpdate

              Icon {
                  Layout.rowSpan: 3
                  Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                  width: units.gu(5)
                  height: width
                  name: "security-alert"
              }

              Label {
                  font.weight: Font.Normal
                  textSize: Label.Medium
                  text: i18n.tr("Firmware Update")
              }

              Label {
                  font.weight: Font.Light
                  fontSize: "small"
                  text: root.partitions
              }

              Label {
                  font.weight: Font.Light
                  fontSize: "small"
                  text: i18n.tr("The device will restart automatically after installing is done.")
              }
          }

          Rectangle {
              anchors.left: parent.left
              anchors.leftMargin: 3
              anchors.horizontalCenter: parent.horizontalCenter
              color: theme.palette.normal.foreground
              radius: units.dp(4)
              width: buttonLabel.paintedWidth + units.gu(3)
              height: buttonLabel.paintedHeight + units.gu(1.8)
              visible: hasUpdate

              Label {
                  id: buttonLabel
                  text: i18n.tr("Install and restart now")
                  font.weight: Font.Light
                  anchors.horizontalCenter: parent.horizontalCenter
                  anchors.centerIn: parent
              }

              AbstractButton {
                  id: button
                  objectName: "installButton"
                  anchors.fill: parent
                  anchors.horizontalCenter: parent.horizontalCenter
                  onClicked: {
                      root.flash();
                  }
              }

              transformOrigin: Item.Top
              scale: button.pressed ? 0.98 : 1.0
              Behavior on scale {
                  ScaleAnimator {
                      duration: UbuntuAnimation.SnapDuration
                      easing.type: Easing.Linear
                  }
              }
          }
      }
    }

    Column {
      id: spinner
      anchors.centerIn: root
      visible: root.isChecking || root.isUpdating
      spacing: units.gu(1)

      ActivityIndicator {
          anchors.horizontalCenter: parent.horizontalCenter
          running: parent.visible
      }

      Label {
          wrapMode: Text.Wrap
          width: root.width - units.gu(3)
          fontSize: "small"
          text: i18n.tr("Downloading and Flashing firmware updates, this could take a few minutes...")
          visible: root.isUpdating
      }

      Label {
          wrapMode: Text.Wrap
          fontSize: "small"
          text: i18n.tr("Checking for firmware update")
          visible: root.isChecking
      }

      Component.onCompleted: root.check()

    }

    Connections {
        target: NetworkingStatus
        onOnlineChanged: {
            if (online) {
                root.check();
        }
    }
  }
}
