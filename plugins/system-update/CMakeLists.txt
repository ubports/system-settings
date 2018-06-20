set(CMAKE_AUTOMOC ON)
set(QML_SOURCES
    ClickUpdateDelegate.qml
    Configuration.qml
    ChangelogExpander.qml
    DownloadHandler.qml
    GlobalUpdateControls.qml
    ImageUpdatePrompt.qml
    PageComponent.qml
    UpdateDelegate.qml
    UpdateSettings.qml
    ChannelSettings.qml
    ReinstallAllApps.qml
    FirmwareUpdate.qml
)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    /usr/include/apt-pkg/
)

pkg_check_modules(UAL REQUIRED ubuntu-app-launch-2)
add_definitions(${UAL_CFLAGS} ${UAL_CFLAGS_OTHER})

add_library(UpdatePlugin SHARED
    click/apiclient.h
    click/manager.h
    click/manifest.h

    click/apiclient_impl.cpp
    click/manifest_impl.cpp
    click/manager_impl.cpp

    image/imagemanager.h
    image/imagemanager_impl.cpp

    network/accessmanager.h
    network/accessmanager_impl.cpp

    helpers.cpp
    update.cpp
    updatedb.cpp
    updatemodel.cpp
    updatemanager.cpp
    ../../src/i18n.cpp
)
target_link_libraries(UpdatePlugin
    Qt5::Quick Qt5::Core Qt5::Network Qt5::Sql
    apt-pkg
    uss-systemimage
    ${UAL_LDFLAGS}
)

add_library(UbuntuUpdatePanel MODULE
    plugin.cpp
    ${QML_SOURCES}
)
target_link_libraries(UbuntuUpdatePanel Qt5::Qml Qt5::Quick Qt5::DBus UpdatePlugin)

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Ubuntu/SystemSettings/Update)
install(TARGETS UpdatePlugin DESTINATION ${PLUGIN_MODULE_DIR})
install(TARGETS UbuntuUpdatePanel DESTINATION ${PLUG_DIR})
install(FILES qmldir.in DESTINATION ${PLUG_DIR} RENAME qmldir)
install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/system-update)

install(FILES system-update.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
install(FILES settings-system-update.svg DESTINATION ${PLUGIN_MANIFEST_DIR}/icons)

set(QML_SOURCES_NOTIFICATION EntryComponent.qml)

# We need a dummy target so the QML files show up in Qt Creator
# If this plugin gets some C++ sources, remove this.
add_custom_target(update-notification
COMMAND echo This is just a dummy.
SOURCES ${QML_SOURCES_NOTIFICATION})

install(FILES update-notification.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
install(FILES ${QML_SOURCES_NOTIFICATION} DESTINATION ${PLUGIN_QML_DIR}/update-notification)
