include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_definitions(-DQT_NO_KEYWORDS)

add_library(hotspot-plugin SHARED hotspot-plugin.h hotspot-plugin.cpp)
target_link_libraries(hotspot-plugin Qt5::Core Qt5::Qml Qt5::DBus SystemSettings)
install(TARGETS hotspot-plugin DESTINATION ${PLUGIN_MODULE_DIR})
