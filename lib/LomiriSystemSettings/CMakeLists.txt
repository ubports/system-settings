add_library(LomiriSystemSettings SHARED item-base.cpp item-base.h)
set_target_properties(LomiriSystemSettings PROPERTIES
VERSION 1.0.0
SOVERSION 1
)

target_link_libraries(LomiriSystemSettings Qt5::Core Qt5::Gui Qt5::Quick Qt5::Qml)

install(TARGETS LomiriSystemSettings LIBRARY DESTINATION ${LIBDIR})
install(FILES item-base.h ItemBase plugin-interface.h PluginInterface
DESTINATION include/LomiriSystemSettings)

set(SYSTEMSETTINGS_LIB LomiriSystemSettings)
configure_file(LomiriSystemSettings.pc.in LomiriSystemSettings.pc @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/LomiriSystemSettings.pc DESTINATION ${LIBDIR}/pkgconfig)
