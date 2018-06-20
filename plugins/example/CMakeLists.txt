include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(QML_SOURCES PageComponent.qml)
add_library(example-plugin MODULE example-plugin.cpp example-plugin.h ${QML_SOURCES})
target_link_libraries(example-plugin Qt5::Qml Qt5::Core SystemSettings)

# This plugin is only an example so let's not install it.
#install(FILES example.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
#install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/example)
