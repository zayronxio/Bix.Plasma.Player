import QtMultimedia
import QtQuick

Item {
    property var currentCover
    property url currentTrack
    property string currentTitle
    property string currentArtist
    property int newPosition
    property string trackDuration: player.position > 0 ? msToTime(player.duration) : "0:00"
    property string trackPosition: msToTime(player.position)
    property bool isPlay: player.playing
    property int playbackPercent: player.position > 0 ? (player.position / player.duration)*100 : 0

    signal playPause
    signal trackFinished
    signal coverReady

    function msToTime(ms) {
        var totalSeconds = Math.floor(ms / 1000);
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds);
    }

    onNewPositionChanged: {
        player.position = (newPosition*player.duration)/100
    }
    onPlayPause: {
        if (player.playing) {
            player.pause()
        } else {
            player.play()
        }

    }

    MediaPlayer {
        id: player
        autoPlay: true
        source: currentTrack
        audioOutput: AudioOutput { id: audioOutput
            volume: 1
        }
        onSourceChanged: {
            if (!player.playing && player.source) {
                player.play()
            }
        }
        onPositionChanged: {
            if (player.position === player.duration){
                trackFinished()
            }
        }
        onMediaStatusChanged: {
            coverReady()
            currentCover = player.metaData.value("24")
        }
    }
}
