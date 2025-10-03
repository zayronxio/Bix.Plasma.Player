import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Item {
    width: 250
    height: 40

    property color bgColor: Kirigami.Theme.backgroundColor
    property color borderColor: Kirigami.Theme.textColor
    property color textColor: Kirigami.Theme.textColor
    property string entryText: searchEntry.text
    property color bgFinalColor

    function isColorLight(color) {
        let r = color.r * 255;
        let g = color.g * 255;
        let b = color.b * 255;
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b;
        return luminance > 127.5;
    }

    TextField {
        id: searchEntry
        anchors.fill: parent
        placeholderText: qsTr("Search")
        color: textColor
        leftPadding: icon.width + 16

        property int iconSize: 20

        background: Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: isColorLight(bgColor) ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.5)
            border.width: 1
            border.color: isColorLight(bgColor) ? Qt.rgba(0, 0, 0, 0.3) : Qt.rgba(255, 255, 255, 0.2)

            Kirigami.Icon {
                id: icon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8
                source: "edit-find-symbolic"
                width: searchEntry.iconSize
                height: width
                color: isColorLight(bgColor) ? "black" : "white"
            }
        }
    }
}
