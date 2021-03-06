/*
 * Copyright (C) 2020 UBports Foundation
 *
 * Authors:
 *    Alfred Neumayer <dev.beidl@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#pragma once

#include <QObject>
#include <QtDBus>

/**
 * Communication between system-settings and nfcd.
 */

class NfcDbusHelper final : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool hasAdapter READ hasAdapter NOTIFY hasAdapterChanged)

public:
    explicit NfcDbusHelper(QObject *parent = nullptr);
    ~NfcDbusHelper() {};

public Q_SLOTS:
    bool hasAdapter();
    bool enabled();
    void setEnabled(bool value);

Q_SIGNALS:
    void hasAdapterChanged();
    void enabledChanged();

private Q_SLOTS:
    void handleEnabledChanged(bool enabled);
    void handleSetEnabledDone();
    void handleEnableError(QDBusError error);

private:
    bool m_enabled = false;
    QDBusInterface* m_nfcdDaemonInterface = nullptr;
    QDBusInterface* m_nfcdSettingsInterface = nullptr;
};
