 
file(RELATIVE_PATH DESKTOP_FILE_IN_IN ${CMAKE_SOURCE_DIR}
     ${CMAKE_SOURCE_DIR}/${DESKTOP_FILE}.in.in)
file(RELATIVE_PATH DESKTOP_FILE_IN_IN_H ${CMAKE_CURRENT_SOURCE_DIR}
     ${CMAKE_CURRENT_SOURCE_DIR}/${DESKTOP_FILE_IN_IN}.h)

file(GLOB CPPFILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
                   "${CMAKE_SOURCE_DIR}/plugins/*/*.cpp"
                   "${CMAKE_SOURCE_DIR}/src/*.cpp"
                   "${CMAKE_SOURCE_DIR}/wizard/*.cpp")
file(GLOB QMLFILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
                   "${CMAKE_SOURCE_DIR}/plugins/*/*.qml"
                   "${CMAKE_SOURCE_DIR}/plugins/*/*/*.qml"
                   "${CMAKE_SOURCE_DIR}/src/qml/*.qml"
                   "${CMAKE_SOURCE_DIR}/wizard/qml/*/*.qml")
file(GLOB SETTINGSFILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
                        "${CMAKE_SOURCE_DIR}/plugins/*/*.settings")
file(GLOB PYFILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
                        "${CMAKE_SOURCE_DIR}/push-helper/*.py")
file(RELATIVE_PATH SETTINGSJSFILE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/settings.js")

add_custom_target(settings.js
    COMMAND ./extractsettingsinfo ${SETTINGSFILES} -o ${CMAKE_CURRENT_SOURCE_DIR}/settings.js
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS ${SETTINGSFILES}
)

add_custom_target(pot-desktop
    COMMAND ${INTLTOOL_EXTRACT} --update --type=gettext/ini
                            --srcdir=${CMAKE_SOURCE_DIR} ${DESKTOP_FILE_IN_IN}
    COMMAND ${XGETTEXT_BIN} -o ubuntu-system-settings.pot
                            --copyright=\"Canonical Ltd.\"
                            --package-name ubuntu-system-settings
                            --qt --c++ --add-comments=TRANSLATORS
                            --keyword=N_ --from-code=UTF-8
                            --sort-by-file
                            ${DESKTOP_FILE_IN_IN_H}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

add_custom_target(pot-qml
    COMMAND ${XGETTEXT_BIN} -o ubuntu-system-settings.pot
                            --join-existing
                            --copyright=\"Canonical Ltd.\"
                            --package-name ubuntu-system-settings
                            --qt --c++ --add-comments=TRANSLATORS
                            --keyword=QT_TR_NOOP --keyword=ctr:1c,2
                            --keyword=tr --keyword=tr:1,2 --from-code=UTF-8
                            --sort-by-file
                            ${QMLFILES} ${SETTINGSJSFILE}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS pot-desktop ${QMLFILES} settings.js #desktop.js
)

add_custom_target(pot-cpp
    COMMAND ${XGETTEXT_BIN} -o ubuntu-system-settings.pot
                            --join-existing
                            --copyright=\"Canonical Ltd.\"
                            --package-name ubuntu-system-settings
                            --qt --c++ --add-comments=TRANSLATORS
                            --keyword=_ --from-code=UTF-8
                            --sort-by-file
                            ${CPPFILES}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS pot-qml ${CPPFILES}
)

add_custom_target(pot-py
    COMMAND ${XGETTEXT_BIN} -o ubuntu-system-settings.pot
                            --join-existing
                            --copyright=\"Canonical Ltd.\"
                            --package-name ubuntu-system-settings
                            --add-comments=TRANSLATORS
                            --keyword=_
                            --sort-by-file
                            ${PYFILES}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS ${PYFILES}
)

add_custom_target(pot DEPENDS pot-desktop pot-qml pot-cpp pot-py)

set(languages "aa;af;am;ar;ast;az;be;bg;br;bs;ca;ckb;cs;cy;da;de;el;en_AU;en_GB;eo;es;eu;fa;fi;fr;fr_CA;ga;gd;gl;gu;he;hi;hr;hu;hy;ia;id;is;it;ja;km;ko;lo;lt;lv;ml;mr;ms;my;nb;nl;oc;pa;pl;pt;pt_BR;ro;ru;sa;sc;shn;si;sk;sl;sq;sr;st;sv;ta;te;th;tr;ug;uk;vi;xh;zh_CN;zh_HK;zh_TW")
foreach(i ${languages})
  add_custom_command(OUTPUT ${i}.mo
  COMMAND ${MSGFMT_BIN} ${CMAKE_CURRENT_SOURCE_DIR}/${i}.po -o ${CMAKE_CURRENT_BINARY_DIR}/${i}.mo
  DEPENDS ${i}.po
  )
  add_custom_target(${i}gen ALL DEPENDS ${i}.mo)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${i}.mo 
  DESTINATION share/locale/${i}/LC_MESSAGES
  RENAME ubuntu-system-settings.mo)
endforeach()

