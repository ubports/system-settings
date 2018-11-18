/*
 * This file is part of system-settings
 *
 * Copyright (C) 2018 The UBports project
 *
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
 *
 * Authors: Marius Gripsgard <marius@ubports.com>
 */

import QMenuModel 0.1
import QtQuick 2.4
import SystemSettings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import Ubuntu.Components.Popups 1.3
import Ubuntu.SystemSettings.Update 1.0
import Ubuntu.Connectivity 1.0

ItemPage {
    id: root
    objectName: "reinstallAllAppsPage"

    header: PageHeader {
        title: i18n.tr("Reinstall all apps")
        flickable: scrollWidget
    }


    property bool batchMode: false
    property bool online: NetworkingStatus.online
    property bool forceCheck: false

    property int updatesCount: {
        var count = 0;
        count += clickRepeater.count;
        return count;
    }

    function check(force) {
        UpdateManager.check(UpdateManager.CheckClickIgnoreVersion);
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
            bottom: parent.bottom
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

            ListItems.Caption {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                text: i18n.tr(
                    "Use this to get all of the latest apps, typically needed after a major system upgrade, " +
                    "e.g. vivid (15.04) to xenial (16.04)."
                )
            }

            Button {
                id: updatesReinstallAllAppsButton
                objectName: "updatesReinstallAllAppsButton"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - units.gu(4)
                text: i18n.tr("Reinstall all apps")
                onClicked: check()
                color: theme.palette.normal.positive
                strokeColor: "transparent"
            }

            GlobalUpdateControls {
                id: glob
                objectName: "global"
                anchors { left: parent.left; right: parent.right }

                height: hidden ? 0 : units.gu(8)
                clip: true
                status: UpdateManager.status
                batchMode: root.batchMode
                updatesCount: root.updatesCount
                online: root.online
                onStop: UpdateManager.cancel()

                onRequestInstall: {
                      install();
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
                            return i18n.tr("Software is up to date");
                        } else if (s === UpdateManager.StatusServerError ||
                                   s === UpdateManager.StatusNetworkError) {
                            return i18n.tr("The update server is not responding. Try again later.");
                        }
                        return "";
                    }
                }
            }

            SettingsItemTitle {
                id: updatesAvailableHeader
                text: i18n.tr("Updates Available")
                visible: clickUpdatesCol.visible
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

        } // Column inside flickable.
    } // Flickable

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
        target: NetworkingStatus
        onOnlineChanged: {
            if (!online) {
                UpdateManager.cancel();
            } else {
                UpdateManager.check(UpdateManager.CheckClickIgnoreVersion);
            }
        }
    }
}
