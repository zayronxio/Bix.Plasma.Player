import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.1
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

PlasmoidItem {

  id: wrapper

  anchors.fill: parent

  property var buttonPosition
  property var buttonSizes
  property bool menuActive

  property int idlistActive: 1
  property string listActive: "All Tracks"

  signal reset


  //property bool dashWindowIsFocus: true

  preferredRepresentation: compactRepresentation
  compactRepresentation: compactRepresentation
  fullRepresentation: compactRepresentation



  Component {
    id: compactRepresentation
    CompactRepresentation {}
  }


}
