include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_library(notifications-plugin SHARED notifications-plugin.h notifications-plugin.cpp)
target_link_libraries(notifications-plugin Qt5::Core Qt5::Qml SystemSettings)
install(TARGETS notifications-plugin DESTINATION ${PLUGIN_MODULE_DIR})
