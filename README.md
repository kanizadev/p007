# 📋 Advanced Multi-Step Registration Form

A beautiful, feature-rich multi-step registration form built with Flutter, featuring a modern sage green theme, smooth animations, and advanced functionality.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)
![License](https://img.shields.io/badge/license-MIT-blue)

## ✨ Features

### 🎯 Core Functionality
- **Multi-Step Wizard**: Intuitive 4-step form with smooth navigation
- **Progress Tracking**: Visual progress indicator with completion percentage
- **Auto-Save**: Automatic form data persistence with local storage
- **Real-time Validation**: Debounced validation with instant feedback
- **Data Persistence**: Form data saved automatically and restored on app restart

### 🎨 User Experience
- **Beautiful Sage Green Theme**: Elegant dark theme with sage green accents
- **Smooth Animations**: Fade and slide transitions between steps
- **Haptic Feedback**: Tactile responses for better user interaction
- **Confetti Celebration**: Animated celebration on successful submission
- **Visual Track Selection**: Interactive cards with icons for track selection

### 📱 Advanced Features
- **Image Picker**: Choose from gallery, camera, or enter image URL
- **Export & Share**: Export form data as JSON or share as text
- **Form Statistics**: View completion percentage and form statistics
- **Completion Tracking**: Real-time completion percentage calculation
- **Error Handling**: Comprehensive validation with helpful error messages

### 📝 Form Sections

#### Step 1: Personal Information
- Profile photo with multiple upload options
- Full name with validation
- Date of birth picker
- Location/Address

#### Step 2: Contact Information
- Email address with real-time validation
- Phone number (defaults to +880 for Bangladesh)
- Visual error feedback

#### Step 3: Professional Information
- Interactive track selection cards with icons:
  - 📱 Mobile Development
  - 🌐 Web Development
  - 🎨 UI/UX Design
  - 📊 Data & Analytics
  - 📋 Project Management
- Experience level slider (0-15 years)

#### Step 4: Additional Details
- About yourself text field
- Terms and conditions checkbox
- Final review before submission

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart 3.9.2 or higher
- Android Studio / VS Code / Android Studio with Flutter plugin
- iOS development: Xcode (for macOS users)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/p007.git
   cd p007
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web
```

## 📦 Dependencies

- `shared_preferences: ^2.3.2` - Local data persistence
- `image_picker: ^1.1.2` - Image selection from gallery/camera
- `path_provider: ^2.1.4` - File system paths
- `smooth_page_indicator: ^1.2.0+3` - Animated page indicators
- `share_plus: ^10.1.2` - Share functionality
- `confetti: ^0.8.0` - Celebration animations

## 🎨 Theme

The app features a beautiful **sage green** color scheme:
- Primary: Sage Green (#87A96B)
- Background: Dark sage tones
- Text: Light cream/off-white
- Accents: Muted sage green variants

## 📱 Screenshots

_Add screenshots of your app here_

## 🔧 Usage

1. **Fill out the form step by step**
   - Navigate through steps using Next/Previous buttons
   - Form data is automatically saved as you type

2. **Upload a profile photo**
   - Click the camera icon on the profile photo
   - Choose from Gallery, Camera, or enter an image URL

3. **View statistics**
   - Tap the menu button (three dots) in the app bar
   - Select "View Stats" to see form completion percentage

4. **Export or Share**
   - Use the menu to export data as JSON
   - Share form summary as text

5. **Submit the form**
   - Complete all required fields
   - Review the summary sheet
   - Confirm submission to see the celebration!

## 🏗️ Project Structure

```
lib/
├── main.dart          # App entry point and theme configuration
└── form.dart          # Main form widget with all features
```

## 🔒 Permissions

The app requires the following permissions:

**Android:**
- `android.permission.CAMERA` - For taking photos
- `android.permission.READ_EXTERNAL_STORAGE` - For accessing gallery

**iOS:**
- `NSPhotoLibraryUsageDescription` - For accessing photo library
- `NSCameraUsageDescription` - For taking photos

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All package contributors
- Design inspiration from modern UI/UX practices

## 📊 Features in Detail

### Auto-Save
Form data is automatically saved to local storage as you type, so you never lose your progress. Data is restored when you reopen the app.

### Real-Time Validation
- Email format validation
- Phone number validation (supports Bangladesh +880 format)
- Name validation (requires first and last name)
- Debounced validation (500ms delay) for better performance

### Progress Tracking
The app calculates and displays your form completion percentage in real-time, showing a visual progress bar.

### Export & Share
- **Export JSON**: Export complete form data as formatted JSON
- **Share**: Share a human-readable summary of your form data

### Celebration
On successful submission, enjoy a beautiful confetti animation with haptic feedback!

## 🐛 Known Issues

- Dropdown widgets use deprecated `value` parameter (functionality works correctly, will be updated in future Flutter versions)

## 🔮 Future Enhancements

- [ ] Form templates
- [ ] Cloud sync
- [ ] Multi-language support
- [ ] Advanced form analytics
- [ ] PDF export
- [ ] Form versioning
- [ ] Biometric authentication

---

⭐ If you like this project, please give it a star!
