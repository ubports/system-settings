/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013-2016 Canonical Ltd.
 *
 * Contact: Iain Lane <iain.lane@canonical.com>
 *          Jonas G. Drange <jonas.drange@canonical.com>
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
import Biometryd 0.0
import GSettings 1.0
import QtQuick 2.4
import QtQuick.Layouts 1.1
import SystemSettings 1.0
import SystemSettings.ListItems 1.0 as SettingsListItems
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3 as ListItems
import Lomiri.Components.Popups 1.3
import Lomiri.Settings.Fingerprint 0.1
import Lomiri.SystemSettings.SecurityPrivacy 1.0

ItemPage {
    id: page
    objectName: "lockSecurityPage"
    title: i18n.tr("Lock security")

    // The user can still press the main "back" button or other buttons on the
    // page while the "change password" dialog is up.  This is because the
    // dialog is not guaranteed to cover the whole screen; consider the case of
    // turning a device to landscape mode.  We'd rather not have the password
    // changing operation interrupted by destroying the dialog out from under
    // it.  So we make sure the whole page and header back button are disabled
    // while the dialog is working.
    enabled: dialog === null
    flickable: scrollWidget
    head.backAction: Action {
        iconName: "back"
        enabled: page.enabled
        onTriggered: {
            pageStack.pop();
        }
    }

    property var dialog: null
    property int enrolledFingerprints: 0

    LomiriSecurityPrivacyPanel {
        id: securityPrivacy
    }

    function methodToIndex(method) {
        switch (method) {
            case LomiriSecurityPrivacyPanel.Swipe:
                return 0
            case LomiriSecurityPrivacyPanel.Passcode:
                return 1
            case LomiriSecurityPrivacyPanel.Passphrase:
                return 2
            case LomiriSecurityPrivacyPanel.Fingerprint:
                return 3
        }
    }

    function indexToMethod(index) {
        switch (index) {
            case 0:
                return LomiriSecurityPrivacyPanel.Swipe
            case 1:
                return LomiriSecurityPrivacyPanel.Passcode
            case 2:
                return LomiriSecurityPrivacyPanel.Passphrase
            case 3:
                return LomiriSecurityPrivacyPanel.Fingerprint
        }
    }

    function openDialog() {
        dialog = PopupUtils.open(dialogComponent, page)
        // Set manually rather than have these be dynamically bound, since
        // the security type can change out from under us, but we don't
        // want dialog to change in that case.
        dialog.oldMethod = securityPrivacy.securityType
        dialog.newMethod = indexToMethod(unlockMethod.selectedIndex)
    }

    RegExpValidator {
        id: passcodeValidator
        regExp: /\d{4}/
    }

    Component {
        id: dialogComponent

        Dialog {
            id: changeSecurityDialog
            objectName: "changeSecurityDialog"

            function displayMismatchWarning() {
                /* If the entry have the same length and different content,
                       display the non matching warning, if they do have the
                       same value then don't display it*/
                if (newInput.text.length === confirmInput.text.length)
                    if (newInput.text !== confirmInput.text)
                        notMatching.visible = true
                    else
                        notMatching.visible = false
            }

            // This is a bit hacky, but the contents of this dialog get so tall
            // that on a mako device, they don't fit with the OSK also visible.
            // So we scrunch up spacing.
            Binding {
                target: __foreground
                property: "itemSpacing"
                value: units.gu(1)
            }

            property int oldMethod
            property int newMethod

            title: {
                if (changeSecurityDialog.newMethod ==
                        changeSecurityDialog.oldMethod) { // Changing existing
                    switch (changeSecurityDialog.newMethod) {
                    case LomiriSecurityPrivacyPanel.Passcode:
                        return i18n.tr("Change passcode…")
                    case LomiriSecurityPrivacyPanel.Passphrase:
                        return i18n.tr("Change passphrase…")
                    default: // To stop the runtime complaining
                        return ""
                    }
                } else {
                    switch (changeSecurityDialog.newMethod) {
                    case LomiriSecurityPrivacyPanel.Swipe:
                        return i18n.tr("Switch to swipe")
                    case LomiriSecurityPrivacyPanel.Passcode:
                        return i18n.tr("Switch to passcode")
                    case LomiriSecurityPrivacyPanel.Passphrase:
                        return i18n.tr("Switch to passphrase")
                    }
                }
            }

            Label {
                text: {
                    switch (changeSecurityDialog.oldMethod) {
                    case LomiriSecurityPrivacyPanel.Passcode:
                        return i18n.tr("Existing passcode")
                    case LomiriSecurityPrivacyPanel.Passphrase:
                        return i18n.tr("Existing passphrase")
                    // Shouldn't be reached when visible but still evaluated
                    default:
                        return ""
                    }
                }

                visible: currentInput.visible
            }

            TextField {
                id: currentInput
                objectName: "currentInput"
                echoMode: TextInput.Password
                inputMethodHints: {
                    if (changeSecurityDialog.oldMethod ===
                            LomiriSecurityPrivacyPanel.Passphrase)
                        return Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                    else if (changeSecurityDialog.oldMethod ===
                             LomiriSecurityPrivacyPanel.Passcode)
                        return Qt.ImhNoAutoUppercase |
                               Qt.ImhSensitiveData |
                               Qt.ImhDigitsOnly
                    else
                        return Qt.ImhNone
                }
                visible: changeSecurityDialog.oldMethod ===
                            LomiriSecurityPrivacyPanel.Passphrase ||
                         changeSecurityDialog.oldMethod ===
                             LomiriSecurityPrivacyPanel.Passcode
                onTextChanged: {
                    if (changeSecurityDialog.newMethod ===
                            LomiriSecurityPrivacyPanel.Swipe)
                        confirmButton.enabled = text.length > 0
                }
                Component.onCompleted: {
                    if (securityPrivacy.securityType !== LomiriSecurityPrivacyPanel.Swipe)
                        forceActiveFocus()
                }
            }

            /* Using bindings since it is, according to documentation,
            impossible to unset both validator and maximumLength properties */
            Binding {
                target: currentInput
                property: "validator"
                value:  passcodeValidator
                when: changeSecurityDialog.oldMethod ===
                    LomiriSecurityPrivacyPanel.Passcode
            }

            Binding {
                target: currentInput
                property: "maximumLength"
                value:  4
                when: changeSecurityDialog.oldMethod ===
                    LomiriSecurityPrivacyPanel.Passcode
            }

            Label {
                id: incorrect
                text: ""
                visible: text !== ""
                color: "darkred"
            }

            Label {
                text: {
                    switch (changeSecurityDialog.newMethod) {
                    case LomiriSecurityPrivacyPanel.Passcode:
                        return i18n.tr("Choose passcode")
                    case LomiriSecurityPrivacyPanel.Passphrase:
                        return i18n.tr("Choose passphrase")
                    // Shouldn't be reached when visible but still evaluated
                    default:
                        return ""
                    }
                }
                visible: newInput.visible
            }

            TextField {
                id: newInput
                objectName: "newInput"
                echoMode: TextInput.Password
                inputMethodHints: {
                    if (changeSecurityDialog.newMethod ===
                            LomiriSecurityPrivacyPanel.Passphrase)
                        return Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                    else if (changeSecurityDialog.newMethod ===
                             LomiriSecurityPrivacyPanel.Passcode)
                        return Qt.ImhNoAutoUppercase |
                               Qt.ImhSensitiveData |
                               Qt.ImhDigitsOnly
                    else
                        return Qt.ImhNone
                }
                visible: changeSecurityDialog.newMethod ===
                            LomiriSecurityPrivacyPanel.Passcode ||
                         changeSecurityDialog.newMethod ===
                            LomiriSecurityPrivacyPanel.Passphrase
                onTextChanged: { displayMismatchWarning() }
                Component.onCompleted: {
                    if (securityPrivacy.securityType === LomiriSecurityPrivacyPanel.Swipe)
                        forceActiveFocus()
                }
            }

            /* Using bindings since it is, according to documentation,
            impossible to unset both validator and maximumLength properties */
            Binding {
                target: newInput
                property: "validator"
                value: passcodeValidator
                when: changeSecurityDialog.newMethod ===
                    LomiriSecurityPrivacyPanel.Passcode
            }

            Binding {
                target: newInput
                property: "maximumLength"
                value:  4
                when: changeSecurityDialog.newMethod ===
                    LomiriSecurityPrivacyPanel.Passcode
            }

            Label {
                text: {
                    switch (changeSecurityDialog.newMethod) {
                    case LomiriSecurityPrivacyPanel.Passcode:
                        return i18n.tr("Confirm passcode")
                    case LomiriSecurityPrivacyPanel.Passphrase:
                        return i18n.tr("Confirm passphrase")
                    // Shouldn't be reached when visible but still evaluated
                    default:
                        return ""
                    }
                }
                visible: confirmInput.visible
            }

            TextField {
                id: confirmInput
                echoMode: TextInput.Password
                inputMethodHints: {
                    if (changeSecurityDialog.newMethod ===
                            LomiriSecurityPrivacyPanel.Passphrase)
                        return Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                    else if (changeSecurityDialog.newMethod ===
                             LomiriSecurityPrivacyPanel.Passcode)
                        return Qt.ImhNoAutoUppercase |
                               Qt.ImhSensitiveData |
                               Qt.ImhDigitsOnly
                    else
                        return Qt.ImhNone
                }
                visible: changeSecurityDialog.newMethod ===
                            LomiriSecurityPrivacyPanel.Passcode ||
                         changeSecurityDialog.newMethod ===
                            LomiriSecurityPrivacyPanel.Passphrase
                onTextChanged: { displayMismatchWarning() }
            }

            /* Using bindings since it is, according to documentation,
            impossible to unset both validator and maximumLength properties */
            Binding {
                target: confirmInput
                property: "validator"
                value:  passcodeValidator
                when: changeSecurityDialog.newMethod ===
                    LomiriSecurityPrivacyPanel.Passcode
            }

            Binding {
                target: confirmInput
                property: "maximumLength"
                value:  4
                when: changeSecurityDialog.newMethod ===
                    LomiriSecurityPrivacyPanel.Passcode
            }

            Label {
                id: notMatching
                wrapMode: Text.Wrap
                text: {
                    if (changeSecurityDialog.newMethod ===
                            LomiriSecurityPrivacyPanel.Passcode)
                        return i18n.tr("Those passcodes don't match. Try again.")
                    if (changeSecurityDialog.newMethod ===
                            LomiriSecurityPrivacyPanel.Passphrase)
                        return i18n.tr("Those passphrases don't match. Try again.")

                    //Fallback to prevent warnings. Not displayed.
                    return ""
                }
                visible: false
                color: "darkred"
            }

            RowLayout {
                spacing: units.gu(1)

                Button {
                    Layout.fillWidth: true
                    text: i18n.tr("Cancel")
                    onClicked: {
                        PopupUtils.close(changeSecurityDialog);
                        var newSelectedIndex;
                        if (securityPrivacy.enableFingerprintIdentification) {
                            newSelectedIndex = methodToIndex(LomiriSecurityPrivacyPanel.Fingerprint);
                        } else {
                            newSelectedIndex = methodToIndex(securityPrivacy.securityType);
                        }
                        unlockMethod.selectedIndex = newSelectedIndex;
                    }
                }

                Button {
                    id: confirmButton
                    Layout.fillWidth: true
                    color: theme.palette.normal.positive

                    text: {
                        if (changeSecurityDialog.newMethod ===
                                LomiriSecurityPrivacyPanel.Swipe)
                            return i18n.tr("Unset")
                        else if (changeSecurityDialog.oldMethod ===
                                changeSecurityDialog.newMethod)
                            return i18n.tr("Change")
                        else
                            return i18n.tr("Set")
                    }
                    /* see https://wiki.ubuntu.com/SecurityAndPrivacySettings#Phone for details */
                    enabled: /* Validate the old method, it's either swipe or a secret which needs
                                to be valid, 4 digits for the passcode or > 0 for a passphrase */
                             (changeSecurityDialog.oldMethod === LomiriSecurityPrivacyPanel.Swipe ||
                              ((changeSecurityDialog.oldMethod === LomiriSecurityPrivacyPanel.Passcode &&
                                currentInput.text.length === 4) ||
                               (changeSecurityDialog.oldMethod === LomiriSecurityPrivacyPanel.Passphrase &&
                                currentInput.text.length > 0))) &&
                             /* Validate the new auth method, either it's a passcode and the code needs to be 4 digits */
                             ((changeSecurityDialog.newMethod === LomiriSecurityPrivacyPanel.Passcode &&
                              newInput.text.length === 4 && confirmInput.text.length === 4) ||
                             /* or a passphrase and then > 0 */
                             (changeSecurityDialog.newMethod === LomiriSecurityPrivacyPanel.Passphrase &&
                              newInput.text.length > 0 && confirmInput.text.length > 0) ||
                             /* or to be swipe */
                             changeSecurityDialog.newMethod === LomiriSecurityPrivacyPanel.Swipe)

                    onClicked: {
                        changeSecurityDialog.enabled = false
                        incorrect.text = ""

                        var match = (newInput.text == confirmInput.text)
                        notMatching.visible = !match
                        if (!match) {
                            changeSecurityDialog.enabled = true
                            newInput.forceActiveFocus()
                            newInput.selectAll()
                            return
                        }

                        var errorText = securityPrivacy.setSecurity(
                            currentInput.visible ? currentInput.text : "",
                            newInput.text,
                            changeSecurityDialog.newMethod)

                        if (errorText !== "") {
                            incorrect.text = errorText
                            currentInput.forceActiveFocus()
                            currentInput.selectAll()
                            changeSecurityDialog.enabled = true

                            // We can always safely disable FP ident here, but
                            // in some cases it is required.
                            securityPrivacy.enableFingerprintIdentification = false;
                        } else {
                            PopupUtils.close(changeSecurityDialog)
                        }
                    }
                }
            }
        }
    }

    Flickable {
        id: scrollWidget
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > page.height) ?
                            Flickable.DragAndOvershootBounds :
                            Flickable.StopAtBounds
        /* Set the direction to workaround
           https://bugreports.qt-project.org/browse/QTBUG-31905 otherwise the UI
           might end up in a situation where scrolling doesn't work */
        flickableDirection: Flickable.VerticalFlick

        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            SettingsItemTitle {
                text: i18n.tr("Unlock the device using:")
            }

            ListItems.ItemSelector {
                property string swipe: i18n.tr("Swipe (no security)")
                property string passcode: i18n.tr("4-digit passcode")
                property string passphrase: i18n.tr("Passphrase")
                property string fingerprint: i18n.tr("Fingerprint")
                property string swipeAlt: i18n.tr("Swipe (no security)… ")
                property string passcodeAlt: i18n.tr("4-digit passcode…")
                property string passphraseAlt: i18n.tr("Passphrase…")

                id: unlockMethod
                model: Biometryd.available ? 4 : 3
                delegate: OptionSelectorDelegate {
                    objectName: {
                        switch (index) {
                            case 0:
                                return "method_swipe";
                            case 1:
                                return "method_code";
                            case 2:
                                return "method_phrase";
                            case 3:
                                return "method_finger";
                            default:
                                return "method_unknown";
                        }
                    }
                    text: {
                        var si = unlockMethod.selectedIndex;
                        switch (index) {
                        case 0:
                            return si == 0 ? unlockMethod.swipe : unlockMethod.swipeAlt;
                        case 1:
                            return si == 1 ? unlockMethod.passcode : unlockMethod.passcodeAlt;
                        case 2:
                            return si == 2 ? unlockMethod.passphrase : unlockMethod.passphraseAlt;
                        case 3:
                            return unlockMethod.fingerprint;
                        }
                    }
                    enabled: {
                        // Fingerprint is the only one we disable, unless the user
                        // has chosen FP ident and there are more than 0 enrolled
                        // FPs and there's a pass{code|phrase} set.
                        var passSet = (securityPrivacy.securityType ===
                                       LomiriSecurityPrivacyPanel.Passcode
                                       || securityPrivacy.securityType ===
                                       LomiriSecurityPrivacyPanel.Passphrase);
                        var haveFps = page.enrolledFingerprints > 0;
                        return index !== 3 || (haveFps && passSet);
                    }
                }
                expanded: true
                onDelegateClicked: {
                    if (selectedIndex === index && !changeControl.visible)
                        return // nothing to do

                    // This check is needed for when FP is the chosen method,
                    // but the user wants to disable FP in favour of the
                    // securityType already set, for which  there is nothing
                    // to do, except turn off FP ident.
                    if (methodToIndex(securityPrivacy.securityType) === index) {
                        securityPrivacy.enableFingerprintIdentification = false;
                        return
                    }

                    // Bail if we enabled FP ident.
                    if (index === 3) {
                        // Toggle FP ident.
                        securityPrivacy.enableFingerprintIdentification = true;
                        return;
                    }

                    selectedIndex = index
                    openDialog()
                }
            }
            Binding {
                target: unlockMethod
                property: "selectedIndex"
                value: {
                    if (securityPrivacy.enableFingerprintIdentification) {
                        return methodToIndex(LomiriSecurityPrivacyPanel.Fingerprint);
                    } else {
                        return methodToIndex(securityPrivacy.securityType);
                    }
                }
            }

            SettingsListItems.SingleControl {

                id: changeControl
                visible: securityPrivacy.securityType ===
                         LomiriSecurityPrivacyPanel.Passcode &&
                         securityPrivacy.securityType ===
                         LomiriSecurityPrivacyPanel.Passphrase

                Button {
                    property string changePasscode: i18n.tr("Change passcode…")
                    property string changePassphrase: i18n.tr("Change passphrase…")

                    property bool passcode: securityPrivacy.securityType ===
                                            LomiriSecurityPrivacyPanel.Passcode

                    objectName: "changePass"
                    enabled: parent.visible

                    text: passcode ? changePasscode : changePassphrase
                    width: parent.width - units.gu(4)

                    onClicked: openDialog()
                }
                showDivider: false
            }
        }
    }

    // This observer is used to decide whether or not to enabled Fingerprint ID
    // to be selected by the user as a security method.
    Observer {
        id: sizeObserver
        onFailed: {
            page.enrolledFingerprints = 0;
            _op = null;
        }
        onSucceeded: {
            page.enrolledFingerprints = result;
            _op = null;
        }
        onCanceled: _op = null

        function start () {
            _op = Biometryd.defaultDevice.templateStore.size(user);
            _op.start(sizeObserver);
        }

        property var _op: null

        Component.onCompleted: {
            if (Biometryd.available)
                start();
        }
        Component.onDestruction: _op && _op.cancel();
    }

    Connections {
        target: Biometryd
        onAvailableChanged: {
            if (available)
                sizeObserver.start();
        }
    }

    User {
        id: user
        uid: LomiriSettingsFingerprint.uid
    }

}
