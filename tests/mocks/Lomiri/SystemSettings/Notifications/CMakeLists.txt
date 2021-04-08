include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/notifications/
    ${GIO_INCLUDE_DIRS}
    ${QTGSETTINGS_INCLUDE_DIRS}
)

set(MOCK_NOTIFICATIONS_SRCS
    ${CMAKE_SOURCE_DIR}/plugins/notifications/click_applications_model.cpp
    ${CMAKE_SOURCE_DIR}/plugins/notifications/click_applications_notify_model.cpp
    MockClickApplicationsModel.cpp
    MockClickApplicationsNotifyModel.cpp
    plugin.cpp
)

add_library(MockLomiriNotificationsPanel MODULE ${MOCK_NOTIFICATIONS_SRCS})

target_link_libraries(MockLomiriNotificationsPanel ${GIO_LDFLAGS} ${QTGSETTINGS_LDFLAGS} Qt5::Qml Qt5::Quick Qt5::Core)

add_lss_mock(Lomiri.SystemSettings.Notifications 1.0 Lomiri/SystemSettings/Notifications
             TARGETS MockLomiriNotificationsPanel)
