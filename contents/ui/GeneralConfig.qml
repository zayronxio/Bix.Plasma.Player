import QtQuick
import QtQuick.Controls
import Qt.labs.platform
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot

    QtObject {
        id: unidWeatherValue
        property var value
    }



    signal configurationChanged

    property alias cfg_temperatureUnit: unidWeatherValue.value
    property alias cfg_latitudeC: latitude.text
    property alias cfg_longitudeC: longitude.text
    property alias cfg_useCoordinatesIp: autamateCoorde.checked
    property alias cfg_colorHex: colorDialog.color

    ColorDialog {
        id: colorDialog
    }

    GridLayout {
        columns: 2
        //spacing: units.smallSpacing * 2

        Label {
            text: i18n("Color:")
            Layout.minimumWidth: root.width/2
            horizontalAlignment: Text.AlignRight
        }
        Item {
            width: 64
            height: 24
            Rectangle {
                width: 64
                radius: 4
                height: 24
                border.color: "black"
                opacity: 0.5
                color: "transparent"
                border.width: 2
            }
            Rectangle {
                id: colorhex
                color: colorDialog.color
                border.color: "#B3FFFFFF"
                border.width: 1
                width: 64
                radius: 4
                height: 24
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        colorDialog.open()
                    }
                }
            }
        }
        Label {
            Layout.minimumWidth: root.width/2
            text: i18n('Use IP location:')
            horizontalAlignment: Text.AlignRight
        }
        RowLayout{
            CheckBox {
                id: autamateCoorde
                Layout.columnSpan: 2
            }
        }
        Label {
            visible: !autamateCoorde.checked
            Layout.minimumWidth: root.width/2
            text: i18n("latitude:")
            horizontalAlignment: Text.AlignRight
        }
        TextField {
            visible: !autamateCoorde.checked
            id: latitude
            width: 200
        }
        Label {
            visible: !autamateCoorde.checked
            text: i18n("longitude:")
            Layout.minimumWidth: root.width/2
            horizontalAlignment: Text.AlignRight
        }
        TextField {
            visible: !autamateCoorde.checked
            id: longitude
            width: 200
        }
        Label {
            text: i18n("temperature unit:")
            Layout.minimumWidth: root.width/2
            horizontalAlignment: Text.AlignRight
        }
        ComboBox {
            textRole: "text"
            valueRole: "value"
            id: positionComboBox
            model: [
                {text: i18n("Celsius (°C)"), value: 0},
                {text: i18n("Fahrenheit (°F)"), value: 1},
            ]
            onActivated: unidWeatherValue.value = currentValue
            Component.onCompleted: currentIndex = indexOfValue(unidWeatherValue.value)
        }

    }
}
