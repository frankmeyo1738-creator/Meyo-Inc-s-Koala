# Meyo Inc's Koala 🐨

Meyo Inc's First App.
A soft, cozy, aesthetic-first social discovery app for Zambian youth.

## ✨ Features

### Core Screens
- **Home Feed** - Pinterest-style masonry grid with beautiful posts
- **Explore** - Category discovery (Aesthetic, Campus Life, 90s Vibes, Soft Life, Zed Nature, Outfits, Wallpapers)
- **Moodboard Creator** - 🌟 Signature feature: drag, resize, rotate images; add text and stickers
- **Reels** - Vertical video feed with aesthetic color grading
- **Profile** - IG-style layout with Pinterest flair

### Design Philosophy
> *"A soft, cozy, aesthetic-first space for Zambian youth to discover, create, and express."*

- **Soft Colors** - Cream White, Sage Green, Mocha Brown, Dusty Rose, Soft Terracotta
- **Rounded Typography** - Poppins font throughout
- **Gentle Aesthetics** - Rounded corners, soft shadows, pastel interactions
- **Zambian-Friendly** - Local themes and relatable content

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.1+)
- Dart SDK
- Android Studio / Xcode for simulators

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   
   For iOS:
   ```bash
   flutter run
   ```
   
   For Android:
   ```bash
   flutter run
   ```

### Dependencies
- `google_fonts: ^6.1.0` - Poppins typography
- `flutter_staggered_grid_view: ^0.7.0` - Masonry grid layouts
- `cached_network_image: ^3.3.0` - Efficient image loading

## 🎨 Design System

### Color Palette
```dart
Cream White    #FAF7F0  // Background
Sage Green     #9CAF88  // Brand accent
Mocha Brown    #8B7355  // Subtle details
Dusty Rose     #D4A5A5  // Highlights
Soft Terracotta #D4997D // Call-to-action
```

### Typography
All text uses **Poppins** font with semantic naming:
- Headings (H1-H5)
- Body text (Large, Medium, Small)
- Labels and buttons

### Components
- `PostCard` - Pinterest-style cards with hover effects
- `CategoryTile` - Big visual tiles for Explore page
- `MoodboardCanvas` - Signature interactive editor

## 📁 Project Structure

```
lib/
├── core/theme/          # Design system (colors, typography, theme)
├── models/              # Data models
├── data/                # Sample data for demo
├── widgets/             # Reusable components
├── screens/             # All 6 main screens
└── main.dart           # App entry point
```

## 🌟 Signature Feature: Moodboard Creator

The killer feature that sets Koala apart:
- ✅ Drag images anywhere
- ✅ Resize elements
- ✅ Rotate for creative layouts
- ✅ Add text overlays
- ✅ Add stickers (emojis)
- ✅ Export as single image

Access from:
- Post Viewer: "Use in Moodboard" button
- Bottom Navigation: Create tab

## 🎯 Next Steps

To make this production-ready:

1. **Backend Integration**
   - Firebase/Supabase for data
   - User authentication
   - Real-time updates

2. **Media Features**
   - Image picker for uploads
   - Video recording/playback
   - Moodboard export to gallery

3. **Social Features**
   - Follow/unfollow
   - Comments and replies
   - Notifications
   - Sharing

4. **Performance**
   - Infinite scroll pagination
   - Image optimization
   - Offline caching

## 📱 Screens Preview

### Home Feed
Masonry grid layout with staggered posts, soft shadows, and smooth navigation.

### Explore
Category tiles with visual themes, emojis, and gradient overlays.

### Post Viewer
Full-screen image view with one-tap zoom, author info, and "Use in Moodboard" button.

### Moodboard Creator
Interactive canvas with drag-and-drop editing, text, stickers, and export functionality.

### Profile
IG-style header with blurred cover, stats, tabs, and photo grid.

### Reels
Vertical scrolling videos with aesthetic color grading and action buttons.

## 🛠️ Built With

- **Flutter** - Cross-platform framework
- **Material 3** - Modern design system
- **Google Fonts** - Poppins typography
- **Cached Network Image** - Optimized image loading
- **Flutter Staggered Grid View** - Pinterest-style layouts

## 📄 License

This project is a design system implementation. Add your license here.

## 🤝 Contributing

Contributions welcome! Please follow the aesthetic design principles outlined in the design system.

---

**Made with ❤️ for Zambian youth** 🐨✨
