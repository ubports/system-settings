import QtQuick 2.4
import Lomiri.Components 1.3

Item {
    property bool ready: false
    anchors.horizontalCenter: parent.horizontalCenter
    height: units.gu(5)
    width: parent.width - units.gu(4)

    LomiriShape {
        backgroundColor: theme.palette.normal.foreground
        clip: true
        height: units.gu(3)
        width: parent.width
        source: ses
    }

    ShaderEffectSource {
        id: ses
        sourceItem: row
        width: 1
        height: 1
        hideSource: true
    }

    Row {
        id: row
        visible: false

        anchors.fill: parent

        Repeater {
            model: spaceColors

            Rectangle {
                color: ready ? modelData : theme.palette.disabled.base
                height: parent.height
                width: spaceValues[index] / diskSpace * parent.width
                Behavior on color {
                    ColorAnimation {
                        duration: LomiriAnimation.SlowDuration
                        easing: LomiriAnimation.StandardEasing
                    }
                }
            }
        }

        Rectangle {
            color: theme.palette.normal.foreground
            height: parent.height
            width: parent.width
        }
    }
}
