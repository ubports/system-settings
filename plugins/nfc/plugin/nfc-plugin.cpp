/*
 * This file is part of system-settings
 *
 * Copyright (C) 2020 UBports Foundation
 * Copyright (C) 2015 Canonical Ltd.
 *
 * Contact: Alfred Neumayer <dev.beidl@gmail.com>
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

#include "nfc-plugin.h"

#include <QDebug>
#include <QDBusInterface>
#include <QDBusPendingReply>
#include <QProcessEnvironment>
#include <QtDBus>
#include <LomiriSystemSettings/ItemBase>

#include "../nfcdbushelper.h"

using namespace LomiriSystemSettings;

class NfcItem: public ItemBase
{
    Q_OBJECT

public:
    explicit NfcItem(const QVariantMap &staticData, QObject *parent = 0);
    void setVisibility(bool visible);

private:
    NfcDbusHelper m_nfcDbusHelper;
};


NfcItem::NfcItem(const QVariantMap &staticData, QObject *parent):
    ItemBase(staticData, parent)
{
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    if (env.contains(QLatin1String("USS_SHOW_ALL_UI"))) {
        QString showAllS = env.value("USS_SHOW_ALL_UI", QString());

        if(!showAllS.isEmpty()) {
            setVisibility(true);
            return;
        }
    }

    const bool supportedDevice = this->m_nfcDbusHelper.hasAdapter();
    setVisibility(supportedDevice);
}

void NfcItem::setVisibility(bool visible)
{
    setVisible(visible);
}

ItemBase *NfcPlugin::createItem(const QVariantMap &staticData,
                                 QObject *parent)
{
    return new NfcItem(staticData, parent);
}

#include "nfc-plugin.moc"
