/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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
 *
 * Author: Michael Terry <michael.terry@canonical.com>
 *         Iain Lane <iain.lane@canonical.com>
 */

#include "securityprivacy.h"
#include <QtCore/QProcess>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusConnectionInterface>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusVariant>
#include <act/act.h>

// FIXME: need to do this better including #include "../../src/i18n.h"
// and linking to it
#include <libintl.h>
QString _(const char *text)
{
    return QString::fromUtf8(dgettext(0, text));
}

#define AS_INTERFACE "com.ubuntu.AccountsService.SecurityPrivacy"
#define AS_TOUCH_INTERFACE "com.ubuntu.touch.AccountsService.SecurityPrivacy"

void managerLoaded(GObject    *object,
                   GParamSpec *pspec,
                   gpointer    user_data);

SecurityPrivacy::SecurityPrivacy(QObject* parent)
  : QObject(parent),
    m_manager(act_user_manager_get_default()),
    m_user(NULL)
{
    connect (&m_accountsService,
             SIGNAL (propertyChanged (QString, QString)),
             this,
             SLOT (slotChanged (QString, QString)));

    connect (&m_accountsService,
             SIGNAL (nameOwnerChanged()),
             this,
             SLOT (slotNameOwnerChanged()));

    if (m_manager != NULL) {
        g_object_ref(m_manager);

        gboolean loaded;
        g_object_get(m_manager, "is-loaded", &loaded, NULL);

        if (loaded)
            managerLoaded();
        else
            g_signal_connect(m_manager, "notify::is-loaded",
                             G_CALLBACK(::managerLoaded), this);
    }
}

SecurityPrivacy::~SecurityPrivacy()
{
    if (m_user != NULL) {
        g_signal_handlers_disconnect_by_data(m_user, this);
        g_object_unref(m_user);
    }

    if (m_manager != NULL) {
        g_signal_handlers_disconnect_by_data(m_manager, this);
        g_object_unref(m_manager);
    }
}

void SecurityPrivacy::slotChanged(QString interface,
                                  QString property)
{
    if (interface != AS_TOUCH_INTERFACE)
        return;

    if (property == "MessagesWelcomeScreen") {
        Q_EMIT messagesWelcomeScreenChanged();
    } else if (property == "StatsWelcomeScreen") {
        Q_EMIT statsWelcomeScreenChanged();
    }
}

void SecurityPrivacy::slotNameOwnerChanged()
{
    // Tell QML so that it refreshes its view of the property
    Q_EMIT messagesWelcomeScreenChanged();
    Q_EMIT statsWelcomeScreenChanged();
}

bool SecurityPrivacy::getStatsWelcomeScreen()
{
    return m_accountsService.getUserProperty(AS_TOUCH_INTERFACE,
                                             "StatsWelcomeScreen").toBool();
}

void SecurityPrivacy::setStatsWelcomeScreen(bool enabled)
{
    if (enabled == getStatsWelcomeScreen())
        return;

    m_accountsService.setUserProperty(AS_TOUCH_INTERFACE,
                                      "StatsWelcomeScreen",
                                      QVariant::fromValue(enabled));
    Q_EMIT(statsWelcomeScreenChanged());
}

bool SecurityPrivacy::getMessagesWelcomeScreen()
{
    return m_accountsService.getUserProperty(AS_TOUCH_INTERFACE,
                                             "MessagesWelcomeScreen").toBool();
}

void SecurityPrivacy::setMessagesWelcomeScreen(bool enabled)
{
    if (enabled == getMessagesWelcomeScreen())
        return;

    m_accountsService.setUserProperty(AS_TOUCH_INTERFACE,
                                      "MessagesWelcomeScreen",
                                      QVariant::fromValue(enabled));
    Q_EMIT(messagesWelcomeScreenChanged());
}

SecurityPrivacy::SecurityType SecurityPrivacy::getSecurityType()
{
    if (m_user == NULL || !act_user_is_loaded(m_user))
        return SecurityPrivacy::Passphrase; // we need to return something

    if (act_user_get_password_mode(m_user) == ACT_USER_PASSWORD_MODE_NONE)
        return SecurityPrivacy::Swipe;
    else if (m_accountsService.getUserProperty(AS_INTERFACE,
                                               "PasswordDisplayHint").toInt() == 1)
        return SecurityPrivacy::Passcode;
    else
        return SecurityPrivacy::Passphrase;
}

bool SecurityPrivacy::setDisplayHint(SecurityType type)
{
    if (!m_accountsService.setUserProperty(AS_INTERFACE, "PasswordDisplayHint",
                                           (type == SecurityPrivacy::Passcode) ? 1 : 0)) {
        return false;
    }

    Q_EMIT securityTypeChanged();
    return true;
}

bool SecurityPrivacy::setPasswordMode(SecurityType type, QString password)
{
    ActUserPasswordMode newMode = (type == SecurityPrivacy::Swipe) ?
                                  ACT_USER_PASSWORD_MODE_NONE :
                                  ACT_USER_PASSWORD_MODE_REGULAR;

    // act_user_set_password_mode() will involve a check with policykit to see
    // if we have admin authorization.  Since Touch doesn't have a general
    // policykit agent yet (and the design for this panel involves asking for
    // the password up from anyway), we will spawn our own agent just for this
    // call.  It will only authorize one request for this pid and it will use
    // the password we pass it via stdin.  We can drop this helper code when
    // Touch has a real policykit agent and/or the design for this panel
    // changes.
    //
    // The reason we do this as a separate helper rather than in-process is
    // that glib's thread signal handling (needed to not block on the agent)
    // and QProcess's signal handling conflict.  They seem to get in each
    // other's way for the same signals.  So we just do this out-of-process.

    QProcess polkitHelper;
    polkitHelper.setProgram(HELPER_EXEC);
    polkitHelper.start();
    polkitHelper.write(password.toUtf8() + "\n");
    polkitHelper.closeWriteChannel();

    while (polkitHelper.canReadLine() || polkitHelper.waitForReadyRead()) {
        QString output = polkitHelper.readLine();
        if (output == "ready\n")
            break;
    }

    act_user_set_password_mode(m_user, newMode);

    polkitHelper.kill(); // kill because maybe it wasn't even needed (polkit might not have need to auth us)
    polkitHelper.waitForFinished();

    // act_user_set_password_mode() does not return success/failure, and we
    // can't easily check get_password_mode() after setting to make sure it
    // took, because that value is updated asynchronously when a change signal
    // is received from AS.  So instead we just see whether our polkit helper
    // authenticated correctly.

    if (polkitHelper.exitStatus() == QProcess::NormalExit &&
        polkitHelper.exitCode() != 0) {
        return false;
    }

    return true;
}

QString SecurityPrivacy::setPassword(QString oldValue, QString value)
{
    QByteArray passwdData;
    if (!oldValue.isEmpty())
        passwdData += oldValue.toUtf8() + '\n';
    passwdData += value.toUtf8() + '\n' + value.toUtf8() + '\n';

    QProcess pamHelper;
    pamHelper.setProgram("/usr/bin/passwd");
    pamHelper.start();
    pamHelper.write(passwdData);
    pamHelper.closeWriteChannel();
    pamHelper.setReadChannel(QProcess::StandardError);

    pamHelper.waitForFinished();
    if (pamHelper.state() == QProcess::Running || // after 30s!
        pamHelper.exitStatus() != QProcess::NormalExit ||
        pamHelper.exitCode() != 0) {
        QString output = QString::fromUtf8(pamHelper.readLine());
        if (output.isEmpty()) {
            return "Internal error: could not run passwd";
        } else {	
            // Grab everything on first line after the last colon.  This is because
            // passwd will bunch it up like so:
            // "(current) UNIX password: Enter new UNIX password: Retype new UNIX password: You must choose a longer password"
            return output.section(':', -1).trimmed();
        }
    }

    return "";
}

QString SecurityPrivacy::badPasswordMessage(SecurityType type)
{
    switch (type) {
        case SecurityPrivacy::Passcode:
            return _("Incorrect passcode. Try again.");
        case SecurityPrivacy::Passphrase:
            return _("Incorrect passphrase. Try again.");
        default:
        case SecurityPrivacy::Swipe:
            return _("Could not set security mode");
    }
}

QString SecurityPrivacy::setSecurity(QString oldValue, QString value, SecurityType type)
{
    if (m_user == NULL || !act_user_is_loaded(m_user))
        return "Internal error: user not loaded";
    else if (type == SecurityPrivacy::Swipe && !value.isEmpty())
        return "Internal error: trying to set password with swipe mode";

    SecurityType oldType = getSecurityType();
    if (type == oldType && value == oldValue)
        return ""; // nothing to do

    // We need to set three pieces of metadata:
    //
    // 1) PasswordDisplayHint
    // 2) AccountsService password mode (i.e. is user in nopasswdlogin group)
    // 3) The user's actual password
    //
    // If we fail any one of them, the whole thing is a wash and we try to roll
    // the already-changed metadata pieces back to their original values.

    if (!setDisplayHint(type)) {
        return _("Could not set security display hint");
    }

    if (type == SecurityPrivacy::Swipe) {
        if (!setPasswordMode(type, oldValue)) {
            setDisplayHint(oldType);
            return badPasswordMessage(oldType);
        }
    } else {
        QString errorText = setPassword(oldValue, value);
        if (!errorText.isEmpty()) {
            setDisplayHint(oldType);
            // Special case this common message because the one PAM gives is so awful
            if (errorText == dgettext("Linux-PAM", "Authentication token manipulation error"))
                return badPasswordMessage(oldType);
            else
                return errorText;
        }
        if (!setPasswordMode(type, value)) {
            setDisplayHint(oldType);
            setPassword(value, oldValue);
            return badPasswordMessage(oldType);
        }
    }

    return "";
}

void securityTypeChanged(GObject    *object,
                         GParamSpec *pspec,
                         gpointer    user_data)
{
    Q_UNUSED(object);
    Q_UNUSED(pspec);

    SecurityPrivacy *plugin(static_cast<SecurityPrivacy *>(user_data));
    Q_EMIT plugin->securityTypeChanged();
}

void SecurityPrivacy::userLoaded()
{
    if (act_user_is_loaded(m_user)) {
        g_signal_handlers_disconnect_by_data(m_user, this);

        g_signal_connect(m_user, "notify::password-mode", G_CALLBACK(::securityTypeChanged), this);
        Q_EMIT securityTypeChanged();
    }
}

void userLoaded(GObject    *object,
                GParamSpec *pspec,
                gpointer    user_data)
{
    Q_UNUSED(object);
    Q_UNUSED(pspec);

    SecurityPrivacy *plugin(static_cast<SecurityPrivacy *>(user_data));
    plugin->userLoaded();
}

void SecurityPrivacy::managerLoaded()
{
    gboolean loaded;
    g_object_get(m_manager, "is-loaded", &loaded, NULL);

    if (loaded) {
        g_signal_handlers_disconnect_by_data(m_manager, this);

        const char *name(qPrintable(qgetenv("USER")));

        if (name != NULL) {
            m_user = act_user_manager_get_user(m_manager, name);

            if (m_user != NULL) {
                g_object_ref(m_user);

                if (act_user_is_loaded(m_user))
                    userLoaded();
                else
                    g_signal_connect(m_user, "notify::is-loaded",
                                     G_CALLBACK(::userLoaded), this);
            }
        }
    }
}

void managerLoaded(GObject    *object,
                   GParamSpec *pspec,
                   gpointer    user_data)
{
    Q_UNUSED(object);
    Q_UNUSED(pspec);

    SecurityPrivacy *plugin(static_cast<SecurityPrivacy *>(user_data));
    plugin->managerLoaded();
}

#include "securityprivacy.moc"
