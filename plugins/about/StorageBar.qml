import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: barRoot
    property bool ready: false
    anchors.horizontalCenter: parent.horizontalCenter
    height: units.gu(5)
    width: parent.width - units.gu(4)
    property alias model: repeater.model
    property var segments: spaceValues
    property var totalBar: diskSpace
    property alias barHeight: shape.height

    UbuntuShape {
        id: shape
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
            id: repeater
            model: spaceColors

            Rectangle {
                color: ready ? modelData : theme.palette.disabled.base
                height: parent.height
                width: barRoot.segments[index] / barRoot.totalBar * parent.width
                Behavior on color {
                    ColorAnimation {
                        duration: UbuntuAnimation.SlowDuration
                        easing: UbuntuAnimation.StandardEasing
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
