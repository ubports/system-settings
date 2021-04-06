set(QML_SOURCES
    PageComponent.qml
    SoundsList.qml
)

add_library(UbuntuSoundPanel MODULE plugin.h sound.h plugin.cpp sound.cpp
${QML_SOURCES})
target_link_libraries(UbuntuSoundPanel lss-accountsservice Qt5::Qml Qt5::Quick Qt5::DBus)

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Ubuntu/SystemSettings/Sound)
install(TARGETS UbuntuSoundPanel DESTINATION ${PLUG_DIR})
install(FILES qmldir DESTINATION ${PLUG_DIR})
install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/sound)

install(FILES sound.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
install(FILES settings-sounds.svg DESTINATION ${PLUGIN_MANIFEST_DIR}/icons)
install(FILES utilities.js DESTINATION ${PLUGIN_QML_DIR}/sound)
