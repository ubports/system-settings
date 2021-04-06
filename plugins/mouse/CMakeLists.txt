set(QML_SOURCES
    PageComponent.qml
    None.qml
    Connected.qml
    ItemTitle.qml
    TapArea.qml
    PrimaryButtonSelector.qml
    SectionHeader.qml
)

set(PANEL_SOURCES
    mouse.cpp
    mouse.h
    plugin.cpp
    plugin.h
    ${QML_SOURCES}
)

configure_file(qmldir.in qmldir COPYONLY)
add_definitions(-DQT_NO_KEYWORDS)
add_library(LomiriMousePanel MODULE ${PANEL_SOURCES} ${QML_SOURCES})

include_directories(${CMAKE_CURRENT_BINARY_DIR}
                    ${ACCOUNTSSERVICE_INCLUDE_DIRS}
                    ${GOBJECT_INCLUDE_DIRS})

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Lomiri/SystemSettings/Mouse)
target_link_libraries (LomiriMousePanel
    Qt5::Qml Qt5::Quick Qt5::DBus
    lss-accountsservice
    ${ACCOUNTSSERVICE_LDFLAGS}
    ${GOBJECT_LDFLAGS}
    ${GLIB_LDFLAGS}
)
install(TARGETS LomiriMousePanel DESTINATION ${PLUG_DIR})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/qmldir DESTINATION ${PLUG_DIR})

# We need a dummy target so the QML files show up in Qt Creator
# If this plugin gets some C++ sources, remove this.
add_custom_target(mouse-holder
COMMAND echo This is just a dummy.
SOURCES ${QML_SOURCES})

install(FILES mouse.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
install(FILES settings-mouse.svg DESTINATION ${PLUGIN_MANIFEST_DIR}/icons)
install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/mouse)
