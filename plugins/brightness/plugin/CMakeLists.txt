include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${ANDR_PROP_INCLUDE_DIRS})

add_definitions(-DQT_NO_KEYWORDS)

add_library(brightness-plugin SHARED brightness-plugin.h brightness-plugin.cpp)
target_link_libraries(brightness-plugin Qt5::Core Qt5::Qml Qt5::DBus SystemSettings ${ANDR_PROP_LDFLAGS})
install(TARGETS brightness-plugin DESTINATION ${PLUGIN_MODULE_DIR})
