import QtQuick
import org.kde.kirigami as Kirigami

Item {
    property var resultImage
    property var originalImage
    property bool createFile: false
    property string prefixName: "bixCover"
    property int subfixName: 0

    signal readyImage

    Kirigami.Icon {
        id: image
        width: 200
        visible: false
        height: width
    }

    onOriginalImageChanged: {
        image.source = null
        image.source = originalImage
        captureQImage()
    }


    function captureQImage() {
        image.grabToImage(function(response) {
            if (response) {
                if (createFile) {
                    console.log(subfixName)
                    var tmpPath = "/tmp/" + prefixName + subfixName.toString() + ".png" // las imagenes se guardan en temp
                    response.saveToFile(tmpPath)
                    resultImage = "file://" + tmpPath
                    subfixName = subfixName + 1
                    readyImage()
                } else {
                    resultImage = response.url
                    readyImage()
                }

            } else {
                readyImage()
            }
        })
    }
}
