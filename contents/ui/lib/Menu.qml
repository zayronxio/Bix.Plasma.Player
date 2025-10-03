import QtQuick
import org.kde.kirigami as Kirigami


Item {
    id: root
    width: Kirigami.Theme.gridUnits * 4
    height: backgroundMenu.implicitHeight
    property int idList: idlistActive
    property int itemHeight: 1
    property int spacing: Kirigami.Units.largeSpacing
    property bool isMenuActive: visible
    visible: false
    property int hcounteiner: itemHeight*menuModel.count + spacing*(menuModel.count +2)

    signal open
    signal close
    signal buttonClicked
    signal chargeList

    onButtonClicked: {
        visible = !visible
    }
    onIsMenuActiveChanged: {
        menuActive = isMenuActive
    }
    onClose: {
        Qt.callLater(function() {
            visible = false
        })

    }
    onOpen: {
        visible = true
    }
    ListModel {
        id: menuModel
         ListElement { icon: "view-media-playlist"; elementId: 1; name: "All tracks" }
         ListElement { icon: "favorite-symbolic"; elementId: 2; name: "Favorites" }
         ListElement { icon: "media-album-cover-symbolic"; elementId: 3; name: "Albums" }
         ListElement { icon: "editor-symbolic"; elementId: 4; name: "New List" }
    }

    HelperCard {
        id: backgroundMenu
        width: parent.width
        height: hcounteiner
        isCustom: true
        customOpacity: 97
        customRadius: 16
        customColorbg: Kirigami.Theme.alternateBackgroundColor
        ListView {
            id: standarList
            model: menuModel
            width: parent.width - Kirigami.Units.largeSpacing*5
            anchors.top: parent.top
            anchors.topMargin: Kirigami.Units.largeSpacing
            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.largeSpacing
            height: hcounteiner
            spacing: root.spacing
            delegate: Item {
                width: root.width
                height: name.implicitHeight
                Kirigami.Icon {
                    id: icon
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: standarList.spacing
                    width: height
                    color: model.elementId === idlistActive ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                    source: model.icon
                }
                Kirigami.Heading {
                    id: name
                    width: parent.width - standarList.spacing*2 -  icon.width
                    color: model.elementId === idlistActive ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                    anchors.left: icon.right
                    anchors.leftMargin: spacing
                    text: model.name
                    level: 5
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        close()
                        listActive = model.name
                        idlistActive = model.elementId
                        chargeList()
                    }
                }
                Component.onCompleted: {
                    itemHeight = name.implicitHeight
                }

            }
        }
    }
}
