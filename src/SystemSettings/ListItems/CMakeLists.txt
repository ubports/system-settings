set(QML_SOURCES
    Divider.qml
    Icon.qml
    IconProgression.qml
    ProportionalShape.qml
    SingleControl.qml
    SingleValue.qml
    SingleValueProgression.qml
    Standard.qml
    StandardProgression.qml
)

set(PLUG_DIR ${PLUGIN_QML_DIR}/SystemSettings/ListItems)
install(FILES qmldir DESTINATION ${PLUG_DIR})
install(FILES ${QML_SOURCES} DESTINATION ${PLUG_DIR})
