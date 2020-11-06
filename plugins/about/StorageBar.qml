import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    property bool ready: false
    anchors.horizontalCenter: parent.horizontalCenter
    height: units.gu(5)
    width: parent.width - units.gu(4)

    UbuntuShape {
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
            id: colorsRepeater
            model: spaceColors

            Rectangle {
                color: ready ? modelData : theme.palette.disabled.base
                height: parent.height
                width: spaceValues[index] / diskSpace * parent.width
                Behavior on color {
                    ColorAnimation {
                        duration: UbuntuAnimation.SlowDuration
                        easing: UbuntuAnimation.StandardEasing
                    }
                }
                Rectangle {
                    height: parent.height
                    width: Math.min(units.dp(1), parent.width) / 2
                    color: theme.palette.normal.background
                    anchors.left: parent.left
                    z: parent.z +1
                    visible: index != 0
                }
                Rectangle {
                    height: parent.height
                    width: Math.min(units.dp(1), parent.width) / 2
                    color: theme.palette.normal.background
                    anchors.right: parent.right
                    z: parent.z +1
                    visible: index != colorsRepeater.count - 1
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
