set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Lomiri/SystemSettings/SecurityPrivacy)

set(HELPER_SOURCES
    polkitlistener.cpp
    helper.cpp
)
add_executable(LomiriSecurityPrivacyHelper ${HELPER_SOURCES})
set_target_properties(LomiriSecurityPrivacyHelper PROPERTIES
    INCLUDE_DIRECTORIES "${POLKIT_AGENT_INCLUDE_DIRS}"
    COMPILE_DEFINITIONS "POLKIT_AGENT_I_KNOW_API_IS_SUBJECT_TO_CHANGE"
)
target_link_libraries(LomiriSecurityPrivacyHelper ${POLKIT_AGENT_LDFLAGS})

include_directories(${CMAKE_CURRENT_BINARY_DIR}
                    ${ACCOUNTSSERVICE_INCLUDE_DIRS}
                    ${GOBJECT_INCLUDE_DIRS})
add_definitions(-DHELPER_EXEC="${PLUG_DIR}/LomiriSecurityPrivacyHelper" -DQT_NO_KEYWORDS)

set(QML_SOURCES
    AppAccess.qml
    AppAccessControl.qml
    here-terms.qml
    Location.qml
    LockSecurity.qml
    Ofono.qml
    PageComponent.qml
    PhoneLocking.qml
    SimPin.qml
    sims.js
)

set(PANEL_SOURCES
    connectivity.cpp
    connectivity.h
    plugin.cpp
    plugin.h
    securityprivacy.cpp
    securityprivacy.h
    trust-store-model.cpp
    trust-store-model.h
    ${QML_SOURCES}
)

add_library(LomiriSecurityPrivacyPanel MODULE ${PANEL_SOURCES} ${QML_SOURCES})

pkg_check_modules(TRUST_STORE REQUIRED trust-store)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${TRUST_STORE_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
)

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Lomiri/SystemSettings/SecurityPrivacy)
target_link_libraries (LomiriSecurityPrivacyPanel
    Qt5::Qml Qt5::Quick Qt5::DBus
    lss-accountsservice
    ${ACCOUNTSSERVICE_LDFLAGS}
    ${GOBJECT_LDFLAGS}
    ${TRUST_STORE_LDFLAGS}
    ${GLIB_LDFLAGS}
)
install(TARGETS LomiriSecurityPrivacyPanel LomiriSecurityPrivacyHelper DESTINATION ${PLUG_DIR})
install(FILES qmldir DESTINATION ${PLUG_DIR})
install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/security-privacy)

install(FILES settings-security-privacy.svg DESTINATION ${PLUGIN_MANIFEST_DIR}/icons)
install(FILES security-privacy.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
