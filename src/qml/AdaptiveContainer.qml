/*
 * This file is part of system-settings
 *
 * Copyright (C) 2020 Ubports Foundation <developers@ubports.com>
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

import QtQuick 2.4

Item {
    property string layout: "list"
    property int gridItemWidth: 100
    property int gridColumnSpacing: 0
    property int gridRowSpacing: 0

    onWidthChanged: doLayout()
    onLayoutChanged: doLayout()
    onVisibleChildrenChanged: doLayout()

    function doLayout() {
        if (layout == "grid") {
            doGridLayout()
        } else {
            doColumnLayout()
        }
    }

    function doGridLayout() {
        var items = visibleChildren

        var availableColumns = Math.floor(width / (gridItemWidth + gridColumnSpacing))
        /* gridColumnSpacing is the minimal spacing: if we have a lot of room
         * left on the sides, spread the items a bit wider (up to 1/n of the
         * side space; and here we set n = 4) */
        var n = 4
        var freeSpace = width - gridItemWidth * availableColumns
        var columnSpacing = Math.max(freeSpace / ((2 * n) + availableColumns), gridColumnSpacing)

        var usedWidth = (gridItemWidth + columnSpacing) * (availableColumns - 1) + gridItemWidth
        // Center the items horizontally
        var startX = (width - usedWidth) / 2

        var rowX = startX
        var rowY = 0
        var rowHeight = 0
        var newImplicitHeight = 0
        for (var i = 0; i < items.length; i++) {
            var item = items[i]
            item.layout = layout
            var h = item.implicitHeight
            item.x = rowX
            item.y = rowY
            item.width = gridItemWidth
            item.height = h
            if (h > rowHeight) rowHeight = h

            var j = i + 1
            if (j % availableColumns == 0 || j == items.length) {
                newImplicitHeight = rowY + rowHeight
                rowX = startX
                rowY += rowHeight + gridRowSpacing
            } else {
                rowX += gridItemWidth + columnSpacing
            }
        }
        implicitHeight = newImplicitHeight
    }

    function doColumnLayout() {
        var y = 0
        var items = visibleChildren
        for (var i = 0; i < items.length; i++) {
            var item = items[i]
            item.layout = layout
            var h = item.implicitHeight
            item.x = 0
            item.y = y
            item.width = width
            item.height = h
            y += h
        }
        implicitHeight = y
    }
}
