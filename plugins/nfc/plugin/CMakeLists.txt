include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_library(nfc-plugin SHARED nfc-plugin.h nfc-plugin.cpp ../nfcdbushelper.cpp)
target_link_libraries(nfc-plugin Qt5::Core Qt5::Qml Qt5::DBus SystemSettings)
install(TARGETS nfc-plugin DESTINATION ${PLUGIN_MODULE_DIR})
