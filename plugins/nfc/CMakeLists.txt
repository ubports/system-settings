add_subdirectory(plugin)

set(QML_SOURCES PageComponent.qml)

add_library(LomiriNfcPanel MODULE
  nfcdbushelper.cpp
  nfcdbushelper.h
  plugin.cpp
  plugin.h
  ${QML_SOURCES}
)
target_link_libraries(LomiriNfcPanel Qt5::Qml Qt5::Quick Qt5::DBus)

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Lomiri/SystemSettings/Nfc)
install(TARGETS LomiriNfcPanel DESTINATION ${PLUG_DIR})
install(FILES qmldir.in DESTINATION ${PLUG_DIR} RENAME qmldir)
install(FILES nfc.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/nfc)
