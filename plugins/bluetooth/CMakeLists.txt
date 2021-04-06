include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(QML_SOURCES
ProvidePinCodeDialog.qml
ConfirmPasskeyDialog.qml
DisplayPinCodeDialog.qml
DisplayPasskeyDialog.qml
ProvidePasskeyDialog.qml
AuthorizationRequestDialog.qml
DevicePage.qml
PageComponent.qml
)

add_library(LomiriBluetoothPanel MODULE
  bluez_adapter1.cpp
  bluez_agentmanager1.cpp
  bluez_device1.cpp
  bluez_agent1adaptor.cpp
  freedesktop_properties.cpp
  freedesktop_objectmanager.cpp
  agent.cpp
  bluetooth.cpp
  device.cpp
  devicemodel.cpp
  bluez_adapter1.h
  bluez_agentmanager1.h
  bluez_device1.h
  bluez_agent1adaptor.h
  freedesktop_properties.h
  freedesktop_objectmanager.h
  plugin.cpp
  bluez_helper.h
  agent.h
  bluetooth.h
  device.h
  devicemodel.h
  plugin.h
  ${QML_SOURCES}
)

target_link_libraries(LomiriBluetoothPanel Qt5::Qml Qt5::Quick Qt5::DBus)

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Lomiri/SystemSettings/Bluetooth)
install(TARGETS LomiriBluetoothPanel DESTINATION ${PLUG_DIR})
install(FILES qmldir DESTINATION ${PLUG_DIR})
install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/bluetooth)

install(FILES bluetooth.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
install(FILES settings-bluetooth.svg DESTINATION ${PLUGIN_MANIFEST_DIR}/icons)
