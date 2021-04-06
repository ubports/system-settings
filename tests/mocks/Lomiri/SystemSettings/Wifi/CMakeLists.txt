include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/wifi/
    ${Qt5Core_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Qml_INCLUDE_DIRS}
)

set(MOCK_WIFI_SRCS
    MockCertHandler.h
    MockCertHandler.cpp
    MockDbusHelper.h
    MockDbusHelper.cpp
    plugin.cpp
)

add_library(MockLomiriWifiPanel SHARED ${MOCK_WIFI_SRCS})

target_link_libraries(MockLomiriWifiPanel
    ${Qt5Core_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${Qt5Qml_LIBRARIES}
)

add_uss_mock(Lomiri.SystemSettings.Wifi 1.0 Lomiri/SystemSettings/Wifi
             TARGETS MockLomiriWifiPanel)
