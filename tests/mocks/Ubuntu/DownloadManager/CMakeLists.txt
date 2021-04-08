include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(MOCK_DOWNLOADMANAGER_SRCS
    plugin.cpp
    MockMetadata.cpp
    MockSingleDownload.cpp
    MockDownloadManager.cpp
)

add_library(MockUbuntuDownloadManager MODULE ${MOCK_DOWNLOADMANAGER_SRCS})

target_link_libraries(MockUbuntuDownloadManager Qt5::Qml Qt5::Quick Qt5::Core)

add_lss_mock(Ubuntu.DownloadManager 1.2 Ubuntu/DownloadManager
             TARGETS MockUbuntuDownloadManager)
