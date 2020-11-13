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
 * Authors:
 * Sebastien Bacher <sebastien.bacher@canonical.com>
 *
*/

#ifndef STORAGEABOUT_H
#define STORAGEABOUT_H

#include "click.h"

#include <gio/gio.h>
#include <glib.h>

#include <QObject>
#include <QProcess>
#include <QVariant>
#include <QDBusInterface>
#include <QFutureWatcher>

class StorageAbout : public QObject
{
    Q_OBJECT

    Q_ENUMS(ClickModel::Roles)

    Q_PROPERTY( QString serialNumber
                READ serialNumber
                CONSTANT)

    Q_PROPERTY( QString vendorString
                READ vendorString
                CONSTANT)

    Q_PROPERTY(QAbstractItemModel *clickList
               READ getClickList
               CONSTANT)

    Q_PROPERTY(quint64 totalClickSize
               READ getClickSize
               NOTIFY clickListChanged)

    Q_PROPERTY(quint64 biggestAppTotalSize
               READ getBiggestAppTotalSize
               NOTIFY clickListChanged)

    Q_PROPERTY(QVariant biggestInstallSize
               READ getBiggestInstallSize
               NOTIFY clickListChanged)

    Q_PROPERTY(quint64 biggestConfigSize
               READ getBiggestConfigSize
               NOTIFY clickListChanged)

    Q_PROPERTY(quint64 biggestCacheSize
               READ getBiggestCacheSize
               NOTIFY clickListChanged)

    Q_PROPERTY(quint64 biggestDataSize
               READ getBiggestDataSize
               NOTIFY clickListChanged)

    Q_PROPERTY(QStringList mountedVolumes
               READ getMountedVolumes
               CONSTANT)

    Q_PROPERTY(quint64 moviesSize
               READ getMoviesSize
               NOTIFY sizeReady)

    Q_PROPERTY(quint64 audioSize
               READ getAudioSize
               NOTIFY sizeReady)

    Q_PROPERTY(quint64 picturesSize
               READ getPicturesSize
               NOTIFY sizeReady)

    Q_PROPERTY(quint64 documentsSize
               READ getDocumentsSize
               NOTIFY sizeReady)

    Q_PROPERTY(quint64 downloadsSize
               READ getDownloadsSize
               NOTIFY sizeReady)

    Q_PROPERTY(quint64 homeSize
               READ getHomeSize
               NOTIFY sizeReady)

    Q_PROPERTY(quint64 anboxSize
               READ getAnboxSize
               NOTIFY sizeReady)

    Q_PROPERTY(quint64 libertineSize
               READ getLibertineSize
               NOTIFY sizeReady)

    Q_PROPERTY(quint64 appCacheSize
               READ getAppCacheSize
               NOTIFY sizeReady)

    Q_PROPERTY(quint64 appConfigSize
               READ getAppConfigSize
               NOTIFY sizeReady)

    Q_PROPERTY(quint64 appDataSize
               READ getAppDataSize
               NOTIFY sizeReady)

    Q_PROPERTY(ClickModel::Roles sortRole
               READ getSortRole
               WRITE setSortRole
               NOTIFY sortRoleChanged)

    Q_PROPERTY( QString deviceBuildDisplayID
                READ deviceBuildDisplayID
                CONSTANT)

    Q_PROPERTY( QString ubuntuBuildID
                READ ubuntuBuildID
                CONSTANT)

    Q_PROPERTY(bool developerMode
               READ getDeveloperMode
               WRITE setDeveloperMode)
    Q_PROPERTY(bool developerModeCapable
               READ getDeveloperModeCapable
                CONSTANT)

    Q_PROPERTY(bool refreshing
               READ getRefreshing
               NOTIFY refreshingChanged)

public:
    explicit StorageAbout(QObject *parent = 0);
    ~StorageAbout();
    QAbstractItemModel *getClickList();
    QString serialNumber();
    QString vendorString();
    QString deviceBuildDisplayID();
    QString ubuntuBuildID();
    Q_INVOKABLE QString licenseInfo(const QString &subdir) const;
    ClickModel::Roles getSortRole();
    void setSortRole(ClickModel::Roles newRole);
    quint64 getClickSize() const;
    quint64 getBiggestAppTotalSize() const;
    QVariant getBiggestInstallSize() const;
    quint64 getBiggestConfigSize() const;
    quint64 getBiggestCacheSize() const;
    quint64 getBiggestDataSize() const;
    quint64 getMoviesSize();
    quint64 getAudioSize();
    quint64 getPicturesSize();
    quint64 getDocumentsSize();
    quint64 getDownloadsSize();
    quint64 getHomeSize();
    quint64 getAnboxSize();
    quint64 getLibertineSize();
    quint64 getAppCacheSize();
    quint64 getAppConfigSize();
    quint64 getAppDataSize();
    Q_INVOKABLE void populateSizes();
    QStringList getMountedVolumes();
    Q_INVOKABLE QString getDevicePath (const QString mount_point) const;
    Q_INVOKABLE qint64 getFreeSpace (const QString mount_point);
    Q_INVOKABLE qint64 getTotalSpace (const QString mount_point);
    Q_INVOKABLE bool isInternal(const QString &drive) const;
    bool getDeveloperMode();
    void setDeveloperMode(bool newMode);
    bool getDeveloperModeCapable() const;
    Q_INVOKABLE void clearAppData(const QString &appId);
    Q_INVOKABLE void clearAppCache(const QString &appId);
    Q_INVOKABLE void clearAppConfig(const QString &appId);
    Q_INVOKABLE void uninstallApp(const QString &appId, const QString &version);
    bool getRefreshing() const;
    void setRefreshing(const bool refreshing);
    Q_INVOKABLE void refreshAsync();

public Q_SLOTS:
    void endRefresh();

Q_SIGNALS:
    void sortRoleChanged();
    void sizeReady();
    void clickListChanged();
    void refreshingChanged();

private:
    void prepareMountedVolumes();
    void refresh();
    QStringList m_mountedVolumes;
    QString m_serialNumber;
    QString m_vendorString;
    QString m_deviceBuildDisplayID;
    QString m_ubuntuBuildID;
    ClickModel m_clickModel;
    ClickFilterProxy m_clickFilterProxy;
    quint64 m_moviesSize;
    quint64 m_audioSize;
    quint64 m_picturesSize;
    quint64 m_documentsSize;
    quint64 m_downloadsSize;
    quint64 m_otherSize;
    quint64 m_homeSize;
    quint64 m_anboxSize;
    quint64 m_libertineSize;
    quint64 m_appCacheSize;
    quint64 m_appConfigSize;
    quint64 m_appDataSize;
    bool m_refreshing;
    QFutureWatcher<void> m_refreshWatcher;


    QMap<QString, QString> m_mounts;

    QScopedPointer<QDBusInterface> m_propertyService;

    GCancellable *m_cancellable;
};

#endif // STORAGEABOUT_H
