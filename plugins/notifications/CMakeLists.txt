add_subdirectory(plugin)

SET (CMAKE_AUTOMOC ON)

set(QML_SOURCES
    PageComponent.qml
    ClickAppNotifications.qml
    ClickAppsSoundsNotify.qml
    ClickAppsVibrationsNotify.qml
    )

set(lomiri_notifications_panel_HDRS
    plugin.h
    general_notification_settings.h
    click_applications_model.h
    click_applications_notify_model.h
    )

set(lomiri_notifications_panel_SRCS
    plugin.cpp
    general_notification_settings.cpp
    click_applications_model.cpp
    click_applications_notify_model.cpp
    )

configure_file(qmldir.in qmldir COPYONLY)
add_library(LomiriNotificationsPanel MODULE ${lomiri_notifications_panel_HDRS} ${lomiri_notifications_panel_SRCS} ${QML_SOURCES})

add_definitions(-DQT_NO_KEYWORDS)
include_directories(${GIO_INCLUDE_DIRS})
include_directories(${QTGSETTINGS_INCLUDE_DIRS})

target_link_libraries(LomiriNotificationsPanel ${GIO_LDFLAGS} ${QTGSETTINGS_LDFLAGS} Qt5::Qml Qt5::Quick)

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Lomiri/SystemSettings/Notifications)
install(TARGETS LomiriNotificationsPanel DESTINATION ${PLUG_DIR})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/qmldir DESTINATION ${PLUG_DIR})
install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/notifications)

install(FILES notifications.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
