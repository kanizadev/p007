# 📋 Advanced Multi-Step Registration Form

A beautiful, feature-rich multi-step registration form built with Flutter, featuring a modern sage green theme, smooth animations, and advanced functionality.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

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


## 🔒 Permissions

The app requires the following permissions:

**Android:**
- `android.permission.CAMERA` - For taking photos
- `android.permission.READ_EXTERNAL_STORAGE` - For accessing gallery

**iOS:**
- `NSPhotoLibraryUsageDescription` - For accessing photo library
- `NSCameraUsageDescription` - For taking photos


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


⭐ If you like this project, please give it a star!
