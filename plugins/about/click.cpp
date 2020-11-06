/*
 * Copyright (C) 2013 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Iain Lane <iain.lane@canonical.com>
 *
*/

#include "click.h"

#include <click.h>
#include <gio/gio.h>
#include <gio/gdesktopappinfo.h>
#include <glib.h>
#include <libintl.h>

#include <QDebug>
#include <QIcon>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

ClickModel::ClickModel(QObject *parent):
    QAbstractTableModel(parent),
    m_totalClickSize(0)
{
    m_clickPackages = buildClickList();
}

/* Look through `hooks' for a desktop or ini file in `directory'
 * and set the display name and icon from this.
 *
 * Will set with information from the first desktop or ini file found and parsed.
 */
void ClickModel::populateFromDesktopFile (Click *newClick,
                                          QVariantMap hooks,
                                          const QString& name,
                                          const QString& version)
{
    QVariantMap appHooks;
    gchar *desktopFileName = nullptr;

    QVariantMap::ConstIterator begin(hooks.constBegin());
    QVariantMap::ConstIterator end(hooks.constEnd());

    // Look through the hooks for first 'desktop' key for an icon to use
    while (begin != end) {
        GKeyFile *appinfo = g_key_file_new();
        auto app = begin.key();
        appHooks = (*begin++).toMap();

        if (!appHooks.isEmpty() && appHooks.contains("desktop")) {
            auto appid = g_strdup_printf("%s_%s_%s.desktop",
                                         name.toLocal8Bit().constData(),
                                         app.toLocal8Bit().constData(),
                                         version.toLocal8Bit().constData());
            g_debug ("Checking app: %s", appid);

            desktopFileName =
                g_build_filename(g_get_user_data_dir(),
                                 "applications",
                                 appid,
                                 nullptr);
            g_free (appid);

            if (!QFile::exists(desktopFileName))
                goto out;

            g_debug ("Desktop file: %s", desktopFileName);


            gboolean loaded = g_key_file_load_from_file(appinfo,
                                                        desktopFileName,
                                                        G_KEY_FILE_NONE,
                                                        nullptr);

            if (!loaded) {
                g_warning ("Couldn't parse desktop file %s", desktopFileName);
                goto out;
            }

            // Only load display name if not set from click manifest
            if (newClick->displayName.isEmpty()) {
                gchar * title = g_key_file_get_locale_string (appinfo,
                                                              G_KEY_FILE_DESKTOP_GROUP,
                                                              G_KEY_FILE_DESKTOP_KEY_NAME,
                                                              nullptr,
                                                              nullptr);

                if (title) {
                    g_debug ("Title is %s", title);
                    newClick->displayName = title;
                    g_free (title);
                    title = nullptr;
                }
            }

            // Overwrite the icon with the .desktop or ini file's one if we have it.
            // This is the one that the app scope displays so use that if we
            // can.
            gchar * icon = g_key_file_get_string (appinfo,
                                                  G_KEY_FILE_DESKTOP_GROUP,
                                                  G_KEY_FILE_DESKTOP_KEY_ICON,
                                                  nullptr);

            if (icon) {
                g_debug ("Icon is %s", icon);
                if (QFile::exists(icon)) {
                    newClick->icon = icon;
                }
                g_free(icon);
            }
        }
out:
        g_free (desktopFileName);
        g_key_file_free (appinfo);

        if (!newClick->icon.isEmpty()) {
            break;
        }
    }
}

ClickModel::Click ClickModel::buildClick(QVariantMap manifest)
{
    Click newClick;
    QDir directory;

    newClick.displayName = manifest.value("title",
                                          gettext("Unknown title")).toString();

    // This key is the base directory where the click package is installed to.
    // We'll look for files relative to this.
    if (manifest.contains("_directory")) {
        directory = manifest.value("_directory", "/undefined").toString();
        // Set the icon from the click package. Might be a path or a reference to a themed icon.
        QString iconFile(manifest.value("icon", "undefined").toString());

        if (directory.exists() && iconFile != "undefined") {
            QFile icon(directory.absoluteFilePath(iconFile.simplified()));
            if (!icon.exists() && QIcon::hasThemeIcon(iconFile)) // try the icon theme
                newClick.icon = QString("image://theme/%1").arg(iconFile);
            else
                newClick.icon = icon.fileName();
        }

    }

    // "hooks" → title → "desktop" or "ini" / "icon"
    QVariant hooks(manifest.value("hooks"));

    if (hooks.isValid()) {
        auto name = manifest.value("name", "unknown").toString();
        auto version = manifest.value("version", "0.0").toString();
        // Load the icon from the first app hook's desktop file
        populateFromDesktopFile(&newClick, hooks.toMap(), name, version);
   }

    newClick.installSize = manifest.value("installed-size",
        "0").toString().toUInt()*1024;

    m_totalClickSize += newClick.installSize;

    return newClick;
}

QList<ClickModel::Click> ClickModel::buildClickList()
{
    ClickDB *clickdb;
    GError *err = nullptr;
    gchar *clickmanifest = nullptr;

    clickdb = click_db_new();
    click_db_read(clickdb, nullptr, &err);
    if (err != nullptr) {
        g_warning("Unable to read Click database: %s", err->message);
        g_error_free(err);
        g_object_unref(clickdb);
        return QList<ClickModel::Click>();
    }

    clickmanifest = click_db_get_manifests_as_string(clickdb, FALSE, &err);
    g_object_unref(clickdb);

    if (err != nullptr) {
        g_warning("Unable to get the manifests: %s", err->message);
        g_error_free(err);
        return QList<ClickModel::Click>();
    }

    QJsonParseError error;

    QJsonDocument jsond =
            QJsonDocument::fromJson(clickmanifest, &error);
    g_free(clickmanifest);

    if (error.error != QJsonParseError::NoError) {
        qWarning() << error.errorString();
        return QList<ClickModel::Click>();
    }

    QJsonArray data(jsond.array());

    QJsonArray::ConstIterator begin(data.constBegin());
    QJsonArray::ConstIterator end(data.constEnd());

    QList<ClickModel::Click> clickPackages;

    while (begin != end) {
        QVariantMap val = (*begin++).toObject().toVariantMap();

        clickPackages.append(buildClick(val));
    }

    return clickPackages;
}

int ClickModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_clickPackages.count();
}

int ClickModel::columnCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return 3; //Display, size, icon
}

QHash<int, QByteArray> ClickModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;

    roleNames[Qt::DisplayRole] = "displayName";
    roleNames[InstalledSizeRole] = "installedSize";
    roleNames[IconRole] = "iconPath";

    return roleNames;
}

QVariant ClickModel::data(const QModelIndex &index, int role) const
{
    if (index.row() > m_clickPackages.count() ||
            index.row() < 0)
        return QVariant();

    Click click = m_clickPackages[index.row()];

    switch (role) {
    case Qt::DisplayRole:
        return click.displayName;
    case InstalledSizeRole:
        return click.installSize;
    case IconRole:
        return click.icon;
    default:
        qWarning() << "Unknown role requested";
        return QVariant();
    }
}

quint64 ClickModel::getClickSize() const
{
    return m_totalClickSize;
}

ClickModel::~ClickModel()
{
}

ClickFilterProxy::ClickFilterProxy(ClickModel *parent)
    : QSortFilterProxyModel(parent)
{
    this->setSourceModel(parent);
    this->setDynamicSortFilter(false);
    this->setSortCaseSensitivity(Qt::CaseInsensitive);
    this->sort(0);
}
