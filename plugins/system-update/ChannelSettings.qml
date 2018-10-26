/*
 * This file is part of system-settings
 *
 * Copyright (C) 2017 The UBports project
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

import QtQuick 2.4
import SystemSettings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Connectivity 1.0
import Ubuntu.SystemSettings.Update 1.0


ItemPage {
    id: root
    objectName: "channelSettingsPage"
    title: i18n.tr("Channel settings")

    Connections {
      target: UpdateManager
      onStatusChanged: {
        switch (UpdateManager.status) {
        case UpdateManager.StatusCheckingImageUpdates:
        case UpdateManager.StatusCheckingAllUpdates:
            aIndicator.visible = true;
            channelSelector.visible = false;
            return;
        }
        aIndicator.visible = false;
        channelSelector.visible = true;

        if (channelSelectorModel.count !== 0)
          return;
        appendChannels()
        return;
      }
    }

    function appendChannels() {
      if (channelSelectorModel.count !== 0)
        return;
      var prettyChannels = {"stable": i18n.tr("Stable"), "rc": i18n.tr("Release candidate"), "devel": i18n.tr("Development")}
      SystemImage.getChannels().forEach(function (_channel) {
          var channel = _channel.split("/");

          // Do not show other ubuntu series then current
          if (SystemImage.getSwitchChannel().indexOf(channel[1]) == -1)
            return;

          var prettyChannel = prettyChannels[channel[channel.length-1]] ? prettyChannels[channel[channel.length-1]] : channel[channel.length-1];
          channelSelectorModel.append({ name: prettyChannel, description: "", channel: _channel});
      });
      setSelectedChannel();
    }

    function setSelectedChannel() {
      var selNum = 0;
      var channel = SystemImage.getSwitchChannel();
      for (var i = 0; i <= channelSelectorModel.count; i++) {
        if (channelSelectorModel.get(i).channel === channel){
            selNum = i;
            break;
        }
      }
      channelSelector.selectedIndex = selNum;
      return selNum;
    }

    Column {
        id: aIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        visible: false

        ActivityIndicator {
            opacity: visible ? 1 : 0
            visible: parent.visible
            running: visible
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: aIndicatorText
            text: i18n.tr("Fetching channels")
            visible: parent.visible
        }
    }

    ListItem.ItemSelector {
        id: channelSelector
        anchors.top: root.header.bottom
        expanded: true
        text: i18n.tr ("Channel to get updates from:")
        model: channelSelectorModel
        delegate: selectorDelegate
        selectedIndex: {
          setSelectedChannel()
        }
        onSelectedIndexChanged: {
          // Cancel all ongoing updates before switching
          SystemImage.cancelUpdate()
          SystemImage.setSwitchChannel(channelSelectorModel.get(selectedIndex).channel);

          if (channelSelectorModel.get(selectedIndex).channel === SystemImage.channelName)
            SystemImage.setSwitchBuild(SystemImage.currentBuildNumber);
          else
            SystemImage.setSwitchBuild(0);
          UpdateManager.check(UpdateManager.CheckImage);
          aIndicatorText.text = i18n.tr("Switching channel");
        }
    }

    Component {
        id: selectorDelegate
        OptionSelectorDelegate { text: name; subText: description; }
    }

    ListModel {
        id: channelSelectorModel
        Component.onCompleted: {
          switch (UpdateManager.status) {
          case UpdateManager.StatusCheckingImageUpdates:
          case UpdateManager.StatusCheckingAllUpdates:
              aIndicator.visible = true;
              channelSelector.visible = false;
              return;
          }
          if (SystemImage.getChannels().length !== 0){
            appendChannels()
            return;
          }
          UpdateManager.check(UpdateManager.CheckImage);
          return;
        }
    }
}
