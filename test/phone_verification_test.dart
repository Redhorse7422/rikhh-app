import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:rikhh_app/features/auth/bloc/auth_bloc.dart';
import 'package:rikhh_app/features/auth/repositories/auth_repository.dart';
import 'package:rikhh_app/features/auth/models/phone_verification_models.dart';

import 'phone_verification_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('Phone Verification Tests', () {
    late MockAuthRepository mockAuthRepository;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authBloc = AuthBloc(repo: mockAuthRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    group('Send Phone Verification OTP', () {
      test('emits [AuthLoading, PhoneVerificationOtpSent] when OTP is sent successfully', () {
        // Arrange
        const phoneNumber = '+919876543210';
        const deviceId = 'test-device-id';
        
        when(mockAuthRepository.sendPhoneVerificationOtp(
          phoneNumber: phoneNumber,
          deviceId: deviceId,
        )).thenAnswer((_) async => PhoneVerificationResponse(
          message: 'OTP sent successfully',
          data: PhoneVerificationData(
            otpId: 'test-otp-id',
            expiresAt: '2024-01-15T10:30:00.000Z',
          ),
          code: 0,
        ));

        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([
            AuthLoading(),
            PhoneVerificationOtpSent(
              otpId: 'test-otp-id',
              phoneNumber: phoneNumber,
              expiresAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
            ),
          ]),
        );

        authBloc.add(PhoneVerificationOtpRequested(
          phoneNumber: phoneNumber,
          deviceId: deviceId,
        ));
      });

      test('emits [AuthLoading, AuthError] when OTP sending fails', () {
        // Arrange
        const phoneNumber = '+919876543210';
        const deviceId = 'test-device-id';
        
        when(mockAuthRepository.sendPhoneVerificationOtp(
          phoneNumber: phoneNumber,
          deviceId: deviceId,
        )).thenThrow(Exception('Network error'));

        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([
            AuthLoading(),
            AuthError('Exception: Network error'),
          ]),
        );

        authBloc.add(PhoneVerificationOtpRequested(
          phoneNumber: phoneNumber,
          deviceId: deviceId,
        ));
      });
    });

    group('Verify Phone OTP', () {
      test('emits [AuthLoading, PhoneVerificationOtpVerified] when OTP is verified successfully', () {
        // Arrange
        const phoneNumber = '+919876543210';
        const otpCode = '123456';
        
        when(mockAuthRepository.verifyPhoneOtp(
          phoneNumber: phoneNumber,
          otpCode: otpCode,
        )).thenAnswer((_) async => VerifyOtpResponse(
          message: 'Phone number verified successfully',
          data: VerifyOtpData(
            isValid: true,
            phoneVerified: true,
          ),
          code: 0,
        ));

        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([
            AuthLoading(),
            PhoneVerificationOtpVerified(
              phoneNumber: phoneNumber,
              isValid: true,
            ),
          ]),
        );

        authBloc.add(PhoneOtpVerificationRequested(
          phoneNumber: phoneNumber,
          otpCode: otpCode,
        ));
      });

      test('emits [AuthLoading, AuthError] when OTP verification fails', () {
        // Arrange
        const phoneNumber = '+919876543210';
        const otpCode = '123456';
        
        when(mockAuthRepository.verifyPhoneOtp(
          phoneNumber: phoneNumber,
          otpCode: otpCode,
        )).thenAnswer((_) async => VerifyOtpResponse(
          message: 'Invalid OTP code',
          data: VerifyOtpData(
            isValid: false,
            phoneVerified: false,
          ),
          code: 400,
        ));

        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([
            AuthLoading(),
            AuthError('Invalid OTP code'),
          ]),
        );

        authBloc.add(PhoneOtpVerificationRequested(
          phoneNumber: phoneNumber,
          otpCode: otpCode,
        ));
      });
    });

    group('Resend Phone OTP', () {
      test('emits [AuthLoading, PhoneVerificationOtpResent] when OTP is resent successfully', () {
        // Arrange
        const phoneNumber = '+919876543210';
        const deviceId = 'test-device-id';
        
        when(mockAuthRepository.resendPhoneVerificationOtp(
          phoneNumber: phoneNumber,
          deviceId: deviceId,
        )).thenAnswer((_) async => ResendOtpResponse(
          message: 'OTP resent successfully',
          data: PhoneVerificationData(
            otpId: 'new-otp-id',
            expiresAt: '2024-01-15T10:35:00.000Z',
          ),
          code: 0,
        ));

        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([
            AuthLoading(),
            PhoneVerificationOtpResent(
              otpId: 'new-otp-id',
              phoneNumber: phoneNumber,
              expiresAt: DateTime.parse('2024-01-15T10:35:00.000Z'),
            ),
          ]),
        );

        authBloc.add(PhoneOtpResendRequested(
          phoneNumber: phoneNumber,
          deviceId: deviceId,
        ));
      });
    });

    group('Phone Verification Reset', () {
      test('emits [PhoneVerificationReset] when reset is requested', () {
        // Act & Assert
        expectLater(
          authBloc.stream,
          emitsInOrder([
            PhoneVerificationReset(),
          ]),
        );

        authBloc.add(PhoneVerificationResetRequested());
      });
    });
  });
}
