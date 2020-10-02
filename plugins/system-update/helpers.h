/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013-2016 Canonical Ltd.
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

#ifndef SYSTEM_UPDATE_HELPERS_H
#define SYSTEM_UPDATE_HELPERS_H

#include <sstream>
#include <vector>
#include <QString>
#include <QStringList>
#include <QDebug>
#include <QDir>

namespace UpdatePlugin
{
class Helpers
{
public:
    static QString getFrameworksDir();
    static QStringList getAvailableFrameworks();
    static QString getArchitecture();
    static QString getSystemCodename();
    static QString clickMetadataUrl();
    static QString clickRevisionUrl();
    static QString whichClick();
    static QString whichPkcon();
    static bool isArchSupported(QString arch);
private:
    static QString architectureFromDpkg();
    static std::vector<std::string> listFolder(const std::string &folder,
                                               const std::string &pattern);
};
} // UpdatePlugin

#endif // SYSTEM_UPDATE_HELPERS_H
