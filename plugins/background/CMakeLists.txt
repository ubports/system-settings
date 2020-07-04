add_subdirectory(Components)

set(QML_SOURCES
    MainPage.qml
    WallpaperGrid.qml
    Preview.qml
    utilities.js
)
add_library(UbuntuBackgroundPanel MODULE
plugin.cpp background.cpp plugin.h background.h
${QML_SOURCES}) # So they show up in Qt designer.

target_link_libraries(UbuntuBackgroundPanel Qt5::Qml Qt5::Quick Qt5::DBus uss-accountsservice)

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Ubuntu/SystemSettings/Background)
install(TARGETS UbuntuBackgroundPanel DESTINATION ${PLUG_DIR})
install(FILES qmldir DESTINATION ${PLUG_DIR})
install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/background)
install(FILES toolkit_chevron-down_1gu.svg toolkit_chevron-ltr_1gu.svg bullet.png
        DESTINATION ${PLUGIN_QML_DIR}/background)
install(FILES settings-background.svg DESTINATION ${PLUGIN_MANIFEST_DIR}/icons)
install(FILES background.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
