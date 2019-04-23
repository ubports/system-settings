/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013-2016 Canonical Ltd.
 *
 * Contact: Didier Roche <didier.roches@canonical.com>
 *          Diego Sarmentero <diego.sarmentero@canonical.com>
 *          Jonas G. Drange <jonas.drange@canonical.com>
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
import SystemSettings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import Ubuntu.SystemSettings.Update 1.0
import Ubuntu.Connectivity 1.0

ItemPage {
    id: root
    objectName: "systemUpdatesPage"

    header: PageHeader {
        title: i18n.tr("Updates")
        flickable: scrollWidget
    }


    property bool batchMode: false
    property bool havePower: (indicatorPower.deviceState === "charging") ||
                             (indicatorPower.batteryLevel > 25)
    property bool online: NetworkingStatus.online
    property bool forceCheck: false

    property int updatesCount: {
        var count = 0;
        count += clickRepeater.count;
        count += imageRepeater.count;
        return count;
    }

    function check(force) {
        if (force === true) {
            UpdateManager.check(UpdateManager.CheckAll);
        } else {
            if (imageRepeater.count === 0 && clickRepeater.count === 0) {
                UpdateManager.check(UpdateManager.CheckAll);
            } else {
                // Only check 30 minutes after last successful check.
                UpdateManager.check(UpdateManager.CheckIfNecessary);
            }
        }
    }

    QDBusActionGroup {
        id: indicatorPower
        busType: 1
        busName: "com.canonical.indicator.power"
        objectPath: "/com/canonical/indicator/power"
        property var batteryLevel: action("battery-level").state || 0
        property var deviceState: action("device-state").state
        Component.onCompleted: start()
    }

    DownloadHandler {
        id: downloadHandler
        updateModel: UpdateManager.model
    }

    Flickable {
        id: scrollWidget
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: configuration.top
        }
        clip: true
        contentHeight: content.height
        boundsBehavior: (contentHeight > parent.height) ?
                        Flickable.DragAndOvershootBounds :
                        Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        Column {
            id: content
            anchors { left: parent.left; right: parent.right }

            GlobalUpdateControls {
                id: glob
                objectName: "global"
                anchors { left: parent.left; right: parent.right }

                height: hidden ? 0 : units.gu(8)
                clip: true
                status: UpdateManager.status
                batchMode: root.batchMode
                requireRestart: imageRepeater.count > 0
                updatesCount: root.updatesCount
                online: root.online
                onStop: UpdateManager.cancel()

                onRequestInstall: {
                    if (requireRestart) {
                        var popup = PopupUtils.open(
                            Qt.resolvedUrl("ImageUpdatePrompt.qml"), null, {
                                havePowerForUpdate: root.havePower
                            }
                        );
                        popup.requestSystemUpdate.connect(function () {
                            install();
                        });
                    } else {
                        install();
                    }
                }
                onInstall: {
                    root.batchMode = true
                    if (requireRestart) {
                        postAllBatchHandler.target = root;
                    } else {
                        postClickBatchHandler.target = root;
                    }
                }
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
                    text: {
                        var s = UpdateManager.status;
                        if (!root.online) {
                            return i18n.tr("Connect to the Internet to check for updates.");
                        } else if (s === UpdateManager.StatusIdle && updatesCount === 0) {
                            return i18n.tr("System software is up to date");
                        } else if (s === UpdateManager.StatusServerError ||
                                   s === UpdateManager.StatusNetworkError) {
                            return i18n.tr("The update server is not responding. Try again later.");
                        }
                        return "";
                    }
                }
            }

            ListItem.SingleValue {
                text: i18n.tr("Update apps in the OpenStore")
                progression: true
                onClicked: Qt.openUrlExternally("openstore://updates")
            }

            SettingsItemTitle {
                id: updatesAvailableHeader
                text: i18n.tr("Updates Available")
                visible: imageUpdateCol.visible || clickUpdatesCol.visible
            }

            Column {
                id: imageUpdateCol
                objectName: "imageUpdates"
                anchors { left: parent.left; right: parent.right }
                visible: {
                    var s = UpdateManager.status;
                    var haveUpdates = imageRepeater.count > 0;
                    switch (s) {
                    case UpdateManager.StatusCheckingClickUpdates:
                    case UpdateManager.StatusIdle:
                        return haveUpdates && online;
                    }
                    return false;
                }

                Repeater {
                    id: imageRepeater
                    model: UpdateManager.imageUpdates

                    delegate: UpdateDelegate {
                        objectName: "imageUpdatesDelegate-" + index
                        width: imageUpdateCol.width
                        updateState: model.updateState
                        progress: model.progress
                        version: remoteVersion
                        size: model.size
                        changelog: model.changelog
                        error: model.error
                        kind: model.kind
                        iconUrl: model.iconUrl
                        name: title

                        onResume: download()
                        onRetry: download()
                        onDownload: {
                            if (SystemImage.downloadMode < 2) {
                                SystemImage.downloadUpdate();
                                SystemImage.forceAllowGSMDownload();
                            } else {
                                SystemImage.downloadUpdate();
                            }
                        }
                        onPause: SystemImage.pauseDownload();
                        onInstall: {
                            var popup = PopupUtils.open(
                                Qt.resolvedUrl("ImageUpdatePrompt.qml"), null, {
                                    havePowerForUpdate: root.havePower
                                }
                            );
                            popup.requestSystemUpdate.connect(SystemImage.applyUpdate);
                        }
                    }
                }
            }

            Column {
                id: clickUpdatesCol
                objectName: "clickUpdates"
                anchors { left: parent.left; right: parent.right }
                visible: {
                    var s = UpdateManager.status;
                    var haveUpdates = clickRepeater.count > 0;
                    switch (s) {
                    case UpdateManager.StatusCheckingImageUpdates:
                    case UpdateManager.StatusIdle:
                        return haveUpdates && online;
                    }
                    return false;
                }

                Repeater {
                    id: clickRepeater
                    model: UpdateManager.clickUpdates

                    delegate: ClickUpdateDelegate {
                        objectName: "clickUpdatesDelegate" + index
                        width: clickUpdatesCol.width
                        updateState: model.updateState
                        progress: model.progress
                        version: remoteVersion
                        size: model.size
                        name: title
                        iconUrl: model.iconUrl
                        kind: model.kind
                        changelog: model.changelog
                        error: model.error
                        signedUrl: signedDownloadUrl

                        onInstall: downloadHandler.createDownload(model);
                        onPause: downloadHandler.pauseDownload(model)
                        onResume: downloadHandler.resumeDownload(model)
                        onRetry: {
                            /* This creates a new signed URL with which we can
                            retry the download. See onSignedUrlChanged. */
                            UpdateManager.retry(model.identifier,
                                               model.revision);
                        }

                        onSignedUrlChanged: {
                            // If we have a signedUrl, user intend to retry.
                            if (signedUrl) {
                                downloadHandler.retryDownload(model);
                            }
                        }

                        Connections {
                            target: glob
                            onInstall: install()
                        }

                        /* If we a downloadId, we expect UDM to restore it
                        after some time. Workaround for lp:1603770. */
                        Timer {
                            id: downloadTimeout
                            interval: 30000
                            running: true
                            onTriggered: {
                                var s = updateState;
                                if (model.downloadId
                                    || s === Update.StateQueuedForDownload
                                    || s === Update.StateDownloading) {
                                    downloadHandler.assertDownloadExist(model);
                                }
                            }
                        }
                    }
                }
            }

            SettingsItemTitle {
                text: i18n.tr("Recent updates")
                visible: installedCol.visible
            }

            Column {
                id: installedCol
                objectName: "installedUpdates"
                anchors { left: parent.left; right: parent.right }
                visible: installedRepeater.count > 0

                Repeater {
                    id: installedRepeater
                    model: UpdateManager.installedUpdates

                    delegate: UpdateDelegate {
                        objectName: "installedUpdateDelegate-" + index
                        width: installedCol.width
                        version: remoteVersion
                        size: model.size
                        name: title
                        kind: model.kind
                        iconUrl: model.iconUrl
                        changelog: model.changelog
                        updateState: Update.StateInstalled
                        updatedAt: model.updatedAt

                        leadingActions: ListItemActions {
                           actions: [
                               Action {
                                    iconName: "delete"
                                    onTriggered: UpdateManager.remove(
                                        model.identifier, model.revision
                                    )
                               }
                           ]
                        }

                        // Launchable if there's a package name on a click.
                        launchable: (!!packageName &&
                                     model.kind === Update.KindClick)

                        onLaunch: UpdateManager.launch(identifier, revision);
                    }
                }
            }
        } // Column inside flickable.
    } // Flickable

    Column {
        id: configuration

        height: childrenRect.height

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        ListItem.ThinDivider {}

        ListItem.SingleValue {
            objectName: "configuration"
            text: i18n.tr("Update settings")
            progression: true
            onClicked: pageStack.addPageToNextColumn(
                root, Qt.resolvedUrl("UpdateSettings.qml"))
        }
    }

    Connections {
        id: postClickBatchHandler
        ignoreUnknownSignals: true
        target: null
        onUpdatesCountChanged: {
            if (target.updatesCount === 0) {
                root.batchMode = false;
                target = null;
            }
        }
    }

    Connections {
        id: postAllBatchHandler
        ignoreUnknownSignals: true
        target: null
        onUpdatesCountChanged: {
            if (target.updatesCount === 1) {
                SystemImage.updateDownloaded.connect(function () {
                    SystemImage.applyUpdate();
                });
                SystemImage.downloadUpdate();
            }
        }
    }

    Connections {
        target: NetworkingStatus
        onOnlineChanged: {
            if (!online) {
                UpdateManager.cancel();
            } else {
                UpdateManager.check(UpdateManager.CheckAll);
            }
        }
    }

    Connections {
        target: SystemImage
        onUpdateFailed: {
            if (consecutiveFailureCount > SystemImage.failuresBeforeWarning) {
                var popup = PopupUtils.open(
                    Qt.resolvedUrl("InstallationFailed.qml"), null, {
                        text: lastReason
                    }
                );
            }
        }
    }

    Component.onCompleted: check()
}
