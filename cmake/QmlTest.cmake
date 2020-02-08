# add_qml_test(path component_name [NO_ADD_TEST] [NO_TARGETS]
#              [TARGETS target1 [target2 [...]]]
#              [IMPORT_PATHS import_path1 [import_path2 [...]]
#              [PROPERTIES prop1 value1 [prop2 value2 [...]]])
#
# NO_ADD_TEST will prevent adding the test to the "test" target
# NO_TARGETS will prevent adding the test to any targets
# TARGETS lists the targets the test should be added to
# IMPORT_PATHS will pass those paths to qmltestrunner as "-import" arguments
# PROPERTIES will be set on the target and test target. See CMake's set_target_properties()
#
# Two targets will be created:
#   - testComponentName - Runs the test with qmltestrunner
#   - tryComponentName - Runs the test with uqmlscene, for manual interaction
#
# To change/set a default value for the whole test suite, prior to calling add_qml_test, set:
# qmltest_DEFAULT_NO_ADD_TEST (default: FALSE)
# qmltest_DEFAULT_TARGETS
# qmltest_DEFAULT_IMPORT_PATHS
# qmltest_DEFAULT_PROPERTIES

find_program(qmltestrunner_exe qmltestrunner)
find_program(qmlscene_exe qmlscene)
find_program(gcc_exe gcc)

set(XVFB_CMD
    env ${qmltest_ENVIRONMENT}
    xvfb-run -a -s "-screen 0 640x480x24"
)

if(NOT qmltestrunner_exe)
  message(FATAL_ERROR "Could not locate qmltestrunner.")
endif()

macro(add_manual_qml_test SUBPATH COMPONENT_NAME)
    set(options NO_ADD_TEST NO_TARGETS)
    set(multi_value_keywords IMPORT_PATHS TARGETS PROPERTIES ENVIRONMENT)

    cmake_parse_arguments(qmltest "${options}" "" "${multi_value_keywords}" ${ARGN})

    set(qmlscene_TARGET try${COMPONENT_NAME})
    set(qmltest_FILE ${SUBPATH}/tst_${COMPONENT_NAME})

    set(qmlscene_imports "")
    if(NOT "${qmltest_IMPORT_PATHS}" STREQUAL "")
        foreach(IMPORT_PATH ${qmltest_IMPORT_PATHS})
            list(APPEND qmlscene_imports "-I")
            list(APPEND qmlscene_imports ${IMPORT_PATH})
        endforeach(IMPORT_PATH)
    elseif(NOT "${qmltest_DEFAULT_IMPORT_PATHS}" STREQUAL "")
        foreach(IMPORT_PATH ${qmltest_DEFAULT_IMPORT_PATHS})
            list(APPEND qmlscene_imports "-I")
            list(APPEND qmlscene_imports ${IMPORT_PATH})
        endforeach(IMPORT_PATH)
    endif()

    set(qmlscene_command
        env ${qmltest_ENVIRONMENT}
            ${qmlscene_exe} ${CMAKE_CURRENT_SOURCE_DIR}/${qmltest_FILE}.qml
            ${qmlscene_imports}
    )
    add_custom_target(${qmlscene_TARGET} ${qmlscene_command})

endmacro(add_manual_qml_test)

macro(add_qml_test SUBPATH COMPONENT_NAME)
    set(options NO_ADD_TEST NO_TARGETS)
    set(multi_value_keywords IMPORT_PATHS TARGETS PROPERTIES ENVIRONMENT)

    cmake_parse_arguments(qmltest "${options}" "" "${multi_value_keywords}" ${ARGN})

    set(qmltest_TARGET test${COMPONENT_NAME})
    set(qmltest_FILE ${SUBPATH}/tst_${COMPONENT_NAME})

    set(qmltestrunner_imports "")
    if(NOT "${qmltest_IMPORT_PATHS}" STREQUAL "")
        foreach(IMPORT_PATH ${qmltest_IMPORT_PATHS})
            list(APPEND qmltestrunner_imports "-import")
            list(APPEND qmltestrunner_imports ${IMPORT_PATH})
        endforeach(IMPORT_PATH)
    elseif(NOT "${qmltest_DEFAULT_IMPORT_PATHS}" STREQUAL "")
        foreach(IMPORT_PATH ${qmltest_DEFAULT_IMPORT_PATHS})
            list(APPEND qmltestrunner_imports "-import")
            list(APPEND qmltestrunner_imports ${IMPORT_PATH})
        endforeach(IMPORT_PATH)
    endif()

    set(qmltest_command
        env ${qmltest_ENVIRONMENT}
        ${XVFB_CMD} ${qmltestrunner_exe} -input ${CMAKE_CURRENT_SOURCE_DIR}/${qmltest_FILE}.qml
            ${qmltestrunner_imports}
            -o ${CMAKE_BINARY_DIR}/${qmltest_TARGET}.xml,xunitxml
            -o -,txt
    )
    add_custom_target(${qmltest_TARGET} ${qmltest_command})

    if(NOT "${qmltest_PROPERTIES}" STREQUAL "")
        set_target_properties(${qmltest_TARGET} PROPERTIES ${qmltest_PROPERTIES})
    elseif(NOT "${qmltest_DEFAULT_PROPERTIES}" STREQUAL "")
        set_target_properties(${qmltest_TARGET} PROPERTIES ${qmltest_DEFAULT_PROPERTIES})
    endif()

    if("${qmltest_NO_ADD_TEST}" STREQUAL FALSE AND NOT "${qmltest_DEFAULT_NO_ADD_TEST}" STREQUAL "TRUE")
        add_test(${qmltest_TARGET} ${qmltest_command})

        if(NOT "${qmltest_UNPARSED_ARGUMENTS}" STREQUAL "")
            set_tests_properties(${qmltest_TARGET} PROPERTIES ${qmltest_PROPERTIES})
        elseif(NOT "${qmltest_DEFAULT_PROPERTIES}" STREQUAL "")
            set_tests_properties(${qmltest_TARGET} PROPERTIES ${qmltest_DEFAULT_PROPERTIES})
        endif()
    endif("${qmltest_NO_ADD_TEST}" STREQUAL FALSE AND NOT "${qmltest_DEFAULT_NO_ADD_TEST}" STREQUAL "TRUE")

    if("${qmltest_NO_TARGETS}" STREQUAL "FALSE")
        if(NOT "${qmltest_TARGETS}" STREQUAL "")
            foreach(TARGET ${qmltest_TARGETS})
                add_dependencies(${TARGET} ${qmltest_TARGET})
            endforeach(TARGET)
        elseif(NOT "${qmltest_DEFAULT_TARGETS}" STREQUAL "")
            foreach(TARGET ${qmltest_DEFAULT_TARGETS})
                add_dependencies(${TARGET} ${qmltest_TARGET})
            endforeach(TARGET)
        endif()
    endif("${qmltest_NO_TARGETS}" STREQUAL "FALSE")

    add_manual_qml_test(${SUBPATH} ${COMPONENT_NAME} ${ARGN})
endmacro(add_qml_test)
