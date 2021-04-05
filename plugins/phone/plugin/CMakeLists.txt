include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_library(phone-plugin SHARED phone-plugin.h phone-plugin.cpp)
target_link_libraries(phone-plugin Qt5::Core Qt5::Qml Qt5::DBus LomiriSystemSettings)
install(TARGETS phone-plugin DESTINATION ${PLUGIN_MODULE_DIR})
