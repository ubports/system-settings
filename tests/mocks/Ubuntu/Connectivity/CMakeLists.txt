include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(MOCK_CONNECTIVITY_SRCS
    plugin.cpp
    MockNetworkingStatus.cpp
)

add_library(MockConnectivity MODULE ${MOCK_CONNECTIVITY_SRCS})

target_link_libraries(MockConnectivity Qt5::Qml Qt5::Quick Qt5::Core)

add_uss_mock(Ubuntu.Conectivity 1.0 Ubuntu/Connectivity
             TARGETS MockConnectivity)
