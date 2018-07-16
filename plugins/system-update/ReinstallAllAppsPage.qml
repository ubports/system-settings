/*
 * This file is part of system-settings
 *
 * Copyright (C) 2018 Marius Gripsgard <marius@ubports.com>
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
 */

import QMenuModel 0.1
import QtQuick 2.4
import SystemSettings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import Ubuntu.OnlineAccounts.Client 0.1
import Ubuntu.SystemSettings.Update 1.1
import Ubuntu.Connectivity 1.0

ItemPage {
    id: root
    objectName: "reinstallAllAppsPage"

    header: PageHeader {
        title: i18n.tr("Reinstall all apps")
        flickable: scrollWidget
    }

    ReinstallAllApps {}

}
