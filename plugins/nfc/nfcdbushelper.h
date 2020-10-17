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

#ifndef NFC_DBUS_HELPER
#define NFC_DBUS_HELPER

#include <QObject>
#include <QtDBus>

/**
 * Communication between system-settings and nfcd.
 */

class NfcDbusHelper final : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool hasAdapter READ hasAdapter NOTIFY hasAdapterChanged)
    //Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    explicit NfcDbusHelper(QObject *parent = nullptr);
    ~NfcDbusHelper() {};

public Q_SLOTS:
	bool hasAdapter();
	bool enabled();
    void setEnabled(const bool value);

Q_SIGNALS:
	void hasAdapterChanged();
	void enabledChanged(bool value);

private:
    QDBusInterface* m_nfcdDaemonInterface = nullptr;
    QDBusInterface* m_nfcdSettingsInterface = nullptr;
};


#endif
