include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/plugins/system-update
    ${CMAKE_SOURCE_DIR}/tests/mocks/plugins/system-update
    /usr/include/apt-pkg/
)

set(PLUGIN_LIBS
    UpdatePlugin
    apt-pkg
)

set(MOCK_SYSTEMUPDATE_SRCS
    plugin.cpp
    MockSystemImage.cpp
    MockUpdateManager.cpp
    MockUpdateModel.cpp
    ${CMAKE_SOURCE_DIR}/src/utils.cpp
    ${PLUGIN_SOURCES}
)

add_library(MockSystemUpdate MODULE ${MOCK_SYSTEMUPDATE_SRCS})
target_link_libraries(MockSystemUpdate ${PLUGIN_LIBS} Qt5::Qml Qt5::Quick Qt5::Core Qt5::Sql)

add_lss_mock(Lomiri.SystemSettings.Update 1.0 Lomiri/SystemSettings/Update
             TARGETS MockSystemUpdate)
