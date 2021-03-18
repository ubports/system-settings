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

#include "nfcdbushelper.h"
#include <QStringList>
#include <QDBusReply>
#include <QtDebug>
#include <QDBusInterface>
#include <QDBusReply>

const QString NFCD_DAEMON_SERVICE = QStringLiteral("org.sailfishos.nfc.settings");
const QString NFCD_DAEMON_PATH = QStringLiteral("/");
const QString NFCD_DAEMON_INTERFACE = QStringLiteral("org.sailfishos.nfc.Daemon");
const QString NFCD_DAEMON_METHOD_GETADAPTERS = QStringLiteral("GetAdapters");

const QString NFCD_SETTINGS_SERVICE = QStringLiteral("org.sailfishos.nfc.daemon");
const QString NFCD_SETTINGS_PATH = QStringLiteral("/");
const QString NFCD_SETTINGS_INTERFACE = QStringLiteral("org.sailfishos.nfc.Settings");
const QString NFCD_SETTINGS_METHOD_GETENABLED = QStringLiteral("GetEnabled");
const QString NFCD_SETTINGS_METHOD_SETENABLED = QStringLiteral("SetEnabled");

NfcDbusHelper::NfcDbusHelper(QObject *parent) : QObject(parent)
{
    this->m_nfcdDaemonInterface = new QDBusInterface(
        NFCD_DAEMON_SERVICE,
        NFCD_DAEMON_PATH,
        NFCD_DAEMON_INTERFACE,
        QDBusConnection::systemBus(),
        this);
    this->m_nfcdSettingsInterface = new QDBusInterface(
        NFCD_SETTINGS_SERVICE,
        NFCD_SETTINGS_PATH,
        NFCD_SETTINGS_INTERFACE,
        QDBusConnection::systemBus(),
        this);

    QDBusReply<bool> initialEnabledValue =
        this->m_nfcdSettingsInterface->call(NFCD_SETTINGS_METHOD_GETENABLED);
    this->m_enabled = initialEnabledValue.isValid() && initialEnabledValue.value();

    connect(this->m_nfcdSettingsInterface, SIGNAL(EnabledChanged(bool)),
            this, SLOT(handleEnabledChanged(bool)));
}

void NfcDbusHelper::handleEnabledChanged(bool enabled)
{
    if (this->m_enabled == enabled)
        return;

    this->m_enabled = enabled;
    Q_EMIT enabledChanged();
}

void NfcDbusHelper::handleSetEnabledDone()
{
    qDebug() << "NFC enabled changed";
}

void NfcDbusHelper::handleEnableError(QDBusError error)
{
    qWarning() << "Failed to change NFC enable state," << error.message();
}

bool NfcDbusHelper::hasAdapter()
{
    QDBusReply<QList<QDBusObjectPath> > adapterObjects =
        this->m_nfcdDaemonInterface->call(NFCD_DAEMON_METHOD_GETADAPTERS);
    return adapterObjects.isValid() && (adapterObjects.value().size() > 0);
}

bool NfcDbusHelper::enabled()
{
    return this->m_enabled;
}

void NfcDbusHelper::setEnabled(bool value)
{
    QVariantList args;
    args.append(QVariant(value));

    this->m_nfcdSettingsInterface->callWithCallback(NFCD_SETTINGS_METHOD_SETENABLED,
                                                    args, this,
                                                    SLOT(handleSetEnabledDone()),
                                                    SLOT(handleEnableError(QDBusError)));
}
