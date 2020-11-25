/*
 * Copyright (C) 2013 Michael Zanetti <michael_zanetti@gmx.net>
 *               2013-2016 Canonical Ltd
 * Canonical modifications by Iain Lane <iain.lane@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

Dialog {
    id: root
    title: i18n.tr("Set time & date")

    property alias hour: timePicker.hours
    property alias minute: timePicker.minutes
    property alias seconds: timePicker.seconds
    property alias day: datePicker.day
    property alias month: datePicker.month
    property alias year: datePicker.year
    property int minYear: 1970
    property int maxYear: 2048

    signal accepted(int hours, int minutes, int seconds,
                    int day, int month, int year)
    signal rejected

    QtObject {
        id: priv
        property date now: new Date()
    }

    Label {
        text: i18n.tr("Time")
    }
    DatePicker {
        id: timePicker
        date: priv.now
        mode: "Hours|Minutes|Seconds"
    }

    Label {
        text: i18n.tr("Date")
    }
    DatePicker {
        id: datePicker
        date: priv.now
        minimum: {
            var d = new Date();
            d.setFullYear(root.minYear);
            return d;
        }
        maximum: {
            var d = new Date();
            d.setFullYear(root.maxYear);
            return d;
        }
    }

    Row {
        spacing: units.gu(1)
        Button {
            text: i18n.tr("Cancel")
            onClicked: {
                root.rejected()
                PopupUtils.close(root)
            }
            width: (parent.width - parent.spacing) / 2
        }
        Button {
            objectName: "TimePickerOKButton"
            text: i18n.tr("Set")
            color: theme.palette.normal.positive
            onClicked: {
                root.accepted(root.hour, root.minute, root.seconds,
                              root.day, root.month, root.year)
                PopupUtils.close(root)
            }
            width: (parent.width - parent.spacing) / 2
        }
    }
}
