include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_library(cellular-plugin SHARED cellular-plugin.h cellular-plugin.cpp)
target_link_libraries(cellular-plugin Qt5::Core Qt5::Qml Qt5::DBus LomiriSystemSettings)
install(TARGETS cellular-plugin DESTINATION ${PLUGIN_MODULE_DIR})
