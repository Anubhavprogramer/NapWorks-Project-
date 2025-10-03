# NapWorks Gallery 📸

A modern iOS photo gallery app built with SwiftUI and Firebase, featuring user authentication and real-time cloud storage.

## Features ✨

### 🔐 Authentication
- **Email/Password Authentication** with Firebase Auth
- **Sign Up** with form validation and password requirements
- **Sign In** with error handling and loading states
- **Forgot Password** functionality with email reset
- **Secure Logout** with confirmation dialog
- **Persistent Authentication** - stays logged in between app launches

### 📱 Gallery Management
- **Real-time Photo Gallery** - updates instantly when new images are added
- **User-specific Images** - each user sees only their own photos
- **Grid Layout** with responsive design
- **Custom Image Loading** with retry mechanism and error handling
- **Delete Images** with confirmation dialog
- **Pull to Refresh** support

### 📤 Photo Upload
- **Camera Integration** with proper permissions
- **Photo Library Access** 
- **Image Compression** for optimal storage
- **Custom Naming** for uploaded images
- **Upload Progress Indicators**
- **Error Handling** with user feedback

### 🎨 Modern UI/UX
- **Native iOS Design** with SwiftUI
- **Green Accent Theme** throughout the app
- **Custom Text Field Styling**
- **Loading States** and progress indicators
- **Empty State Views** with helpful messaging
- **Responsive Layout** for different screen sizes

## Tech Stack 🛠️

- **Frontend**: SwiftUI (iOS 15+)
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Storage
- **Architecture**: MVVM Pattern
- **Language**: Swift 5.0+

## Project Structure 📁

```
NapWorks(Project)/
├── Screens/
│   ├── LoginScreen.swift          # Authentication entry point
│   ├── SignUpScreen.swift         # User registration
│   ├── ForgotPasswordScreen.swift # Password reset
│   ├── ImagesScreen.swift         # Main gallery view
│   ├── MainScreen.swift           # Upload interface
│   └── UploadDetailScreen.swift   # Image upload details
├── ViewModel/
│   ├── AuthManager.swift          # Authentication management
│   ├── FirebaseStorageManager.swift # Cloud storage operations
│   └── DataViewModel.swift        # Data handling
├── Model/
│   └── data.swift                 # Data models
├── Utils/
│   ├── ImagePicker.swift          # Camera/gallery picker
│   └── CustomTextFieldStyle.swift # UI components
├── Assets.xcassets/               # App icons and assets
└── GoogleService-Info.plist      # Firebase configuration
```

## Setup Instructions 🚀

### Prerequisites
- Xcode 14.0 or later
- iOS 15.0 or later
- Active Apple Developer Account
- Firebase Account

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd NapWorks\(Project\)
```

### 2. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing one
3. Add an iOS app with your bundle identifier
4. Download `GoogleService-Info.plist` and add it to your Xcode project
5. Enable the following Firebase services:

#### Authentication
- Go to Authentication > Sign-in method
- Enable "Email/Password"

#### Firestore Database
- Create a Firestore database
- Set up security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /images/{imageId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

#### Storage
- Enable Firebase Storage
- Set up security rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/images/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Install Dependencies
```bash
# Open NapWorks(Project).xcodeproj in Xcode
# Dependencies are managed through Swift Package Manager
# Firebase SDK should already be integrated
```

### 4. Configure Info.plist
Add camera and photo library permissions:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select images</string>
```

### 5. Build and Run
1. Select your target device or simulator
2. Press `Cmd + R` to build and run
3. Test authentication flow and image upload

## Usage Guide 📖

### First Time Setup
1. **Launch the app** - you'll see the login screen
2. **Create Account** - tap "Sign Up" to register
3. **Verify Email** (optional) - check your email for verification
4. **Start Uploading** - use the Upload tab to add your first photo

### Daily Usage
1. **View Gallery** - Images tab shows all your photos
2. **Upload Photos** - Upload tab lets you add new images
3. **Delete Images** - tap the red minus button on any photo
4. **Logout** - tap the logout button in the top-left of gallery

## Key Features Explained 🔍

### Real-time Updates
The app uses Firebase Firestore listeners to provide real-time updates. When you upload an image, it appears immediately in the gallery without refreshing.

### User Isolation
Each user's images are stored separately:
- **Storage Path**: `users/{userId}/images/{imageName}.jpg`
- **Database Filter**: Only shows images where `userId` matches current user

### Custom Image Loading
Built-in retry mechanism with exponential backoff for reliable image loading, replacing AsyncImage to avoid cancellation errors.

### Security
- All images are private to the authenticated user
- Firebase security rules enforce user isolation
- Proper authentication state management

## Troubleshooting 🔧

### Common Issues

**Images not loading:**
- Check Firebase Storage rules
- Verify internet connection
- Ensure user is properly authenticated

**Authentication failing:**
- Verify `GoogleService-Info.plist` is added to project
- Check Firebase Authentication is enabled
- Ensure bundle ID matches Firebase configuration

**Upload failing:**
- Check camera/photo library permissions
- Verify Firebase Storage rules
- Ensure image name is not empty
