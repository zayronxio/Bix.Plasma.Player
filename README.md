# Bix Plasma Player (ALFA)

<p align="center">
  <img src="https://raw.githubusercontent.com/zayronxio/Bix.Plasma.Player/main/preview/image10.png" width=320/>
  <h2 align="center">A Modern Multimedia Player for KDE Plasma</h2>
</p>

Bix Plasma Player is a modern plasmoid that brings a full-featured multimedia audio player experience directly to your KDE Plasma 6.1+ desktop. Designed to function like a standalone application while seamlessly integrating with the Plasma environment.

> **⚠️ Early Development Stage**  
> This plasmoid is currently in active development and may contain experimental features. Your support and feedback are greatly appreciated!

---

## ✨ Features

### 🎵 Core Functionality
- **MP3 Scanner** - Automatically locates audio files in selected folders
- **Audio Playback** - Full MP3 player with play, next, and previous controls
- **Metadata Reader** - Comprehensive tag information display
- **Album Art** - Automatic cover image loading and display
- **Progress Bar** - Visual playback progress with seek functionality
- **Favorites System** - Mark and manage your favorite tracks
- **Search** - Quick search through your music library
- **Shuffle Mode** - Random playback option

### 🚀 New & Experimental Features
- **Media Key Support** - Experimental multimedia keyboard key binding
- **Album Browser** - Visual album list with cover images
- **SQLite Database** - Enhanced performance and reliability (replaces QtCore settings)
- **MPRIS Support** - Experimental media player remote interfacing
- **Redesigned UI** - Completely refreshed user interface
- **Persistent Configuration** - Loads information without rescanning

### 🎯 Interface
- Standalone application-like behavior and appearance
- Bottom panel displaying current track title and artist
- Integrated panel controls and visualization

---

## 📋 Current Limitations

### 🛠️ In Progress
- Playlist generator implementation
- Window management detection
- Player index behavior fixes (switching between All Music and Favorites)

### ⏸️ Temporarily Unavailable
- Minimize, close, and move buttons (under redesign)

### 🔮 Future Possibilities
- Web-based album cover image management
- Internet radio station player
- Enhanced window controls

---

## 📦 Installation

### Manual Installation
1. Download the contents of this repository
2. Create a directory named `Bix.Plasma.Player` in `~/.local/share/plasma/plasmoids/`
3. Copy the `contents` folder and `metadata.json` file into the `Bix.Plasma.Player` directory
4. Add the plasmoid to your panel through KDE Plasma's widget interface

### Store Installation
* Right click on the desktop
* Click on "Add Widgets"
* Click on "Get New Widgets"
* Click on "Download New Plasma Widgets"
* Search for "Bix Plasma Player"
* Click on "Install" and you're done!

---

## 🆘 Support

For technical support, bug reports, or feature requests:
- **Email**: [adolfo@librepixels.com](mailto:adolfo@librepixels.com)

---

## 📄 License

This project is licensed under the [GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.txt)

---

## 💝 Support Development

Bix Plasma Player is a passion project developed in spare time. If you find this project useful and want to support its continued development, consider making a donation:

<p align="center">
  <a href="https://www.paypal.com/paypalme/zayronxio">
    <img src="https://raw.githubusercontent.com/stefan-niedermann/paypal-donate-button/master/paypal-donate-button.png" width=200 alt="Donate with PayPal"/>
  </a>
</p>

---

**Note**: This plasmoid does not require root access for installation and is designed to work exclusively with KDE Plasma 6.1 or later versions.
