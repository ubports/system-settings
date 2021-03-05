/*
 * Copyright (C) 2020 UBports foundation
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
*/

#include "plugin.h"

#include <QtQml>
#include <QtQml/QQmlContext>
#include "nfcdbushelper.h"

namespace {

NfcDbusHelper *s = nullptr;

QObject* dbusProvider(QQmlEngine* engine, QJSEngine* /* scriptEngine */)
{
    if(!s)
        s = new NfcDbusHelper(engine);
    return s;
}

}

void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Ubuntu.SystemSettings.Nfc"));
    qmlRegisterSingletonType<NfcDbusHelper>(uri, 1, 0, "DbusHelper", dbusProvider);
}

void BackendPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}
