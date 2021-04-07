include_directories(
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

add_library(LomiriSettingsTestQml MODULE
    testutil.cpp
    lstplugin.cpp
    TouchEventSequenceWrapper.cpp
)

target_link_libraries(LomiriSettingsTestQml
    Qt5::Core
    Qt5::Quick
    Qt5::Test
)

export_qmlfiles(Lomiri.Settings.Test Lomiri/Test NO_INSTALL)
export_qmlplugin(Lomiri.Settings.Test 0.1 Lomiri/Test TARGETS LomiriSettingsTestQml NO_INSTALL)

add_custom_target(LomiriSettingsTest)
add_dependencies(LomiriSettingsTest LomiriSettingsTestQml Lomiri.Settings.Test-qmlfiles)
