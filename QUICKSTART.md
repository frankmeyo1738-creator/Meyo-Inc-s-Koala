# Quick Start Guide

## Run the App

### iOS (requires Xcode)
```bash
flutter run
```

### Android (requires Android Studio)
```bash
flutter run
```

### Web (Chrome)
```bash
flutter run -d chrome
```

## Explore the App

1. **Home Feed** - Scroll through beautiful posts in masonry grid
2. **Explore Tab** - Browse categories (tap any tile)
3. **Tap any post** - View full-screen with zoom
4. **Create Tab** - Try the Moodboard Creator
   - Tap "Image" to add images
   - Tap "Text" to add text
   - Tap "Sticker" to add emojis
   - Drag elements around
   - Tap "Export" when done
5. **Reels Tab** - Swipe up/down through vertical videos
6. **Profile Tab** - View profile with stats and photo grid

## Key Features to Test

✨ **Moodboard Creator** (Signature feature):
- Navigate to Create tab
- Add multiple images
- Drag them around
- Add text overlays
- Add sticker emojis
- Export your creation

📱 **Post Viewer**:
- Tap any post from Home
- Pinch to zoom
- Tap "Use in Moodboard" button
- View author info

🎨 **Aesthetic Design**:
- Notice the soft colors
- Rounded corners everywhere
- Gentle shadows
- Poppins font
- Pastel interactions

## Troubleshooting

### "No devices found"
Run `flutter devices` to see available devices/simulators

### iOS issues
Install Xcode and CocoaPods:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo gem install cocoapods
```

### Android issues
Ensure Android Studio and SDK are installed, and emulator is running.

---

Happy exploring! 🐨✨
