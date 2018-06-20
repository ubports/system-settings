# set(XVFB_CMD xvfb-run -a -s "-screen 0 640x480x24")
include_directories(${CMAKE_CURRENT_BINARY_DIR} ../../../plugins/security-privacy ${GLIB_INCLUDE_DIRS})
add_definitions(-DTESTS)
add_definitions(-DDATA_DIR="${CMAKE_CURRENT_SOURCE_DIR}/data")

add_executable(tst-trust-store-model
    tst_trust_store_model.cpp
    ../../../plugins/security-privacy/trust-store-model.cpp
)
target_link_libraries (tst-trust-store-model ${GLIB_LDFLAGS} Qt5::Core Qt5::Gui Qt5::DBus Qt5::Qml Qt5::Test)
add_test(NAME tst-trust-store-model COMMAND ${XVFB_CMD} ${CMAKE_CURRENT_BINARY_DIR}/tst-trust-store-model)
