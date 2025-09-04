# SF Pro Font Setup Guide

## 🚨 Current Status
Your app is currently configured to use SF Pro fonts but will fallback to system fonts until you add the actual font files.

## 📋 Step-by-Step Setup

### Step 1: Download SF Pro Fonts

**Option A: Apple Developer Account (Recommended)**
1. Go to [Apple Developer Downloads](https://developer.apple.com/download/all/)
2. Sign in with your Apple Developer account
3. Download "SF Pro Fonts" package
4. Extract the fonts from the downloaded package

**Option B: Apple's Official Website**
1. Visit [Apple's SF Pro Fonts page](https://developer.apple.com/fonts/)
2. Download the SF Pro font family
3. Extract the TTF files

**Option C: Alternative Fonts (Similar Look)**
If you can't access SF Pro fonts, consider these alternatives:
- **Inter** (Google Fonts) - Very similar to SF Pro
- **Roboto** (Google Fonts) - Clean, modern look
- **Poppins** (Google Fonts) - Rounded, friendly

### Step 2: Add Font Files to Your Project

1. Copy the following font files to `assets/fonts/` directory:

```
assets/fonts/
├── SFProDisplay-Regular.ttf
├── SFProDisplay-Medium.ttf
├── SFProDisplay-Semibold.ttf
├── SFProDisplay-Bold.ttf
├── SFProText-Regular.ttf
├── SFProText-Medium.ttf
├── SFProText-Semibold.ttf
└── SFProText-Bold.ttf
```

### Step 3: Enable Font Configuration

1. Open `pubspec.yaml`
2. Find the commented font section (around line 121)
3. Uncomment the entire fonts section:

```yaml
fonts:
  # SF Pro Display - for large text and headings
  - family: SF Pro Display
    fonts:
      - asset: assets/fonts/SFProDisplay-Regular.ttf
        weight: 400
      - asset: assets/fonts/SFProDisplay-Medium.ttf
        weight: 500
      - asset: assets/fonts/SFProDisplay-Semibold.ttf
        weight: 600
      - asset: assets/fonts/SFProDisplay-Bold.ttf
        weight: 700
  
  # SF Pro Text - for body text and smaller text
  - family: SF Pro Text
    fonts:
      - asset: assets/fonts/SFProText-Regular.ttf
        weight: 400
      - asset: assets/fonts/SFProText-Medium.ttf
        weight: 500
      - asset: assets/fonts/SFProText-Semibold.ttf
        weight: 600
      - asset: assets/fonts/SFProText-Bold.ttf
        weight: 700
```

### Step 4: Run the App

1. Run `flutter pub get` to update dependencies
2. Run `flutter clean` to clear build cache
3. Run `flutter run` to start your app

## 🎯 What Happens Now

### Before Adding Fonts:
- App uses system fonts (Roboto on Android, San Francisco on iOS)
- All styling and layout remain the same
- App runs without errors

### After Adding Fonts:
- App uses beautiful SF Pro fonts
- Typography matches Apple's design system
- Professional, modern appearance

## 🔧 Troubleshooting

### Error: "unable to locate asset entry"
- Make sure font files are in `assets/fonts/` directory
- Check that file names match exactly (case-sensitive)
- Ensure `pubspec.yaml` fonts section is uncommented

### Fonts Not Loading
- Run `flutter clean` and `flutter pub get`
- Check that font files are not corrupted
- Verify file paths in `pubspec.yaml`

### Alternative: Use Google Fonts Instead

If you prefer to use Google Fonts (easier setup), you can:

1. Add to `pubspec.yaml` dependencies:
```yaml
dependencies:
  google_fonts: ^6.1.0
```

2. Update `lib/core/theme/app_theme.dart` to use Google Fonts:
```dart
import 'package:google_fonts/google_fonts.dart';

// Replace SF Pro references with:
fontFamily: GoogleFonts.inter().fontFamily,  // or GoogleFonts.roboto().fontFamily
```

## 📱 Testing

After setup, test your fonts by:

1. **Check different text styles:**
```dart
Text('Display Large', style: Theme.of(context).textTheme.displayLarge)
Text('Body Text', style: Theme.of(context).textTheme.bodyMedium)
```

2. **Use SF Pro helper class:**
```dart
Text('Custom Style', style: SFProFonts.headlineLarge(color: Colors.blue))
```

## 📄 License Note

Make sure you have proper licensing rights to use SF Pro fonts in your application. For commercial apps, consider using open-source alternatives like Inter or Roboto.

---

**Need Help?** The app will work perfectly with system fonts until you add SF Pro fonts. Take your time to set this up properly!
