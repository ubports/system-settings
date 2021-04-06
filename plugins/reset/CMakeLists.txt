set(QML_SOURCES EntryComponent.qml
    EraseEverything.qml
    PageComponent.qml
    ResetAllSettings.qml
    ResetLauncherHome.qml
)

add_library(LomiriResetPanel MODULE
  plugin.cpp
  reset.cpp
  plugin.h
  reset.h
  ${QML_SOURCES}
)

target_link_libraries(LomiriResetPanel Qt5::Qml Qt5::Quick Qt5::DBus lss-accountsservice)

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Lomiri/SystemSettings/Reset)
install(TARGETS LomiriResetPanel DESTINATION ${PLUG_DIR})
install(FILES qmldir DESTINATION ${PLUG_DIR})
install(FILES reset.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
install(FILES settings-reset.svg DESTINATION ${PLUGIN_MANIFEST_DIR}/icons)
install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/reset)
