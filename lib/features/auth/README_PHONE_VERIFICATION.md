# Phone Verification Implementation

This document describes the phone verification system implemented for user registration.

## Overview

The phone verification system allows users to verify their phone numbers during registration using OTP (One-Time Password) sent via SMS. This ensures that users have access to the phone number they provide during registration.

## Architecture

### Models
- `PhoneVerificationRequest`: Request model for sending OTP
- `PhoneVerificationResponse`: Response model for OTP sent confirmation
- `VerifyOtpRequest`: Request model for OTP verification
- `VerifyOtpResponse`: Response model for OTP verification
- `ResendOtpRequest`: Request model for resending OTP
- `ResendOtpResponse`: Response model for OTP resend confirmation

### API Service
The `AuthApiService` class includes three new methods:
- `sendPhoneVerificationOtp()`: Sends OTP to the provided phone number
- `verifyPhoneOtp()`: Verifies the OTP code entered by the user
- `resendPhoneVerificationOtp()`: Resends OTP to the same phone number

### BLoC Events
- `PhoneVerificationOtpRequested`: Triggers OTP sending
- `PhoneOtpVerificationRequested`: Triggers OTP verification
- `PhoneOtpResendRequested`: Triggers OTP resend
- `PhoneVerificationResetRequested`: Resets phone verification state

### BLoC States
- `PhoneVerificationOtpSent`: OTP sent successfully
- `PhoneVerificationOtpVerified`: OTP verified successfully
- `PhoneVerificationOtpResent`: OTP resent successfully
- `PhoneVerificationReset`: Phone verification state reset

## User Flow

1. **Registration Form**: User fills out the registration form including phone number
2. **Phone Validation**: Phone number is validated for Indian format (+91XXXXXXXXXX)
3. **OTP Sending**: When user clicks "Sign Up", OTP is sent to the phone number
4. **Phone Verification Screen**: User is navigated to a dedicated verification screen
5. **OTP Input**: User enters the 6-digit OTP using a custom OTP input field
6. **Verification**: OTP is verified against the backend
7. **Success**: Upon successful verification, user can proceed with registration

## Features

### OTP Input Field
- Custom 6-digit OTP input with individual boxes
- Auto-focus on next field when digit is entered
- Paste support for complete OTP
- Visual feedback for focused/unfocused states

### Countdown Timer
- 5-minute countdown timer for OTP validity
- Resend button enabled only after timer expires
- Visual indication of remaining time

### Error Handling
- Network error handling
- Invalid OTP error handling
- Expired OTP error handling
- Rate limiting error handling

### UI/UX Features
- Clean, modern design consistent with app theme
- Loading states during API calls
- Success/error feedback via SnackBar
- Phone number masking for privacy
- Help text and instructions

## API Integration

The implementation follows the backend API specification:

### Send OTP
```
POST /auth/send-phone-verification-otp
{
  "phoneNumber": "+919876543210",
  "deviceId": "device-123-optional"
}
```

### Verify OTP
```
POST /auth/verify-phone-otp
{
  "phoneNumber": "+919876543210",
  "otpCode": "123456"
}
```

### Resend OTP
```
POST /auth/resend-phone-verification-otp
{
  "phoneNumber": "+919876543210",
  "deviceId": "device-123-optional"
}
```

## Usage

### In Signup Screen
```dart
// Navigate to phone verification
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => PhoneVerificationScreen(
      phoneNumber: _phoneController.text.trim(),
      deviceId: 'flutter-${DateTime.now().millisecondsSinceEpoch}',
    ),
  ),
).then((isVerified) {
  if (isVerified == true) {
    // Phone verified, proceed with registration
  }
});
```

### Using BLoC
```dart
// Send OTP
context.read<AuthBloc>().add(
  PhoneVerificationOtpRequested(
    phoneNumber: phoneNumber,
    deviceId: deviceId,
  ),
);

// Verify OTP
context.read<AuthBloc>().add(
  PhoneOtpVerificationRequested(
    phoneNumber: phoneNumber,
    otpCode: otpCode,
  ),
);

// Resend OTP
context.read<AuthBloc>().add(
  PhoneOtpResendRequested(
    phoneNumber: phoneNumber,
    deviceId: deviceId,
  ),
);
```

## Security Considerations

1. **Rate Limiting**: OTP requests are rate-limited to prevent spam
2. **OTP Expiry**: OTPs expire after 5 minutes
3. **Attempt Limits**: Maximum 3 attempts per OTP
4. **Phone Uniqueness**: Each phone number can only be registered once
5. **Device ID**: Optional device identification for additional security

## Testing

The implementation includes:
- Input validation for phone numbers
- OTP format validation
- Error state handling
- Loading state management
- Success flow testing

## Future Enhancements

1. **Biometric Authentication**: Add fingerprint/face ID for OTP verification
2. **Voice OTP**: Support for voice-based OTP delivery
3. **WhatsApp OTP**: Alternative OTP delivery via WhatsApp
4. **International Support**: Support for non-Indian phone numbers
5. **Analytics**: Track OTP delivery and verification rates

## Dependencies

- `flutter_bloc`: State management
- `dio`: HTTP client for API calls
- `shared_preferences`: Local storage
- `equatable`: Value equality for BLoC states
- `flutter_vector_icons`: Icons

## File Structure

```
lib/features/auth/
├── models/
│   └── phone_verification_models.dart
├── services/
│   └── auth_api_service.dart (updated)
├── bloc/
│   ├── auth_bloc.dart (updated)
│   ├── auth_event.dart (updated)
│   └── auth_state.dart (updated)
├── repositories/
│   └── auth_repository.dart (updated)
└── screens/
    ├── signup_screen.dart (updated)
    └── phone_verification_screen.dart

lib/shared/components/
└── otp_input_field.dart
```
