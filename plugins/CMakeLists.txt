if(ANDR_PROP_FOUND)
    add_subdirectory(about)
    add_subdirectory(brightness)
    add_subdirectory(nfc)
endif()
#add_subdirectory(accessibility)
add_subdirectory(background)
add_subdirectory(battery)
add_subdirectory(bluetooth)
# TODO(Ratchanan): separate the plugin to an independent package
# Additional deps: qtdeclarative5-ubuntu-keyboard-extensions0.1 ("enterKeyText")
# add_subdirectory(cellular)
add_subdirectory(example)
add_subdirectory(flight-mode)
add_subdirectory(hotspot)
add_subdirectory(language)
add_subdirectory(launcher)
add_subdirectory(mouse)
add_subdirectory(notifications)
add_subdirectory(orientation-lock)
# TODO(Ratchanan): separate the plugin to an independent package
# Additional deps: qtdeclarative5-ubuntu-history0.1
# add_subdirectory(phone)
add_subdirectory(printing)
add_subdirectory(reset)
# TODO(Ratchanan): separate the plugin to an independent package
# Additional deps: trust-store
# add_subdirectory(security-privacy)
add_subdirectory(sound)
# TODO(Ratchanan): separate the plugin to an independent package
# Additional deps: lomiri-download-manager
# add_subdirectory(system-update)
add_subdirectory(time-date)
add_subdirectory(vpn)
add_subdirectory(wifi)
