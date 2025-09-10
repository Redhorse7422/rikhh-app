import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/otp_input_field.dart';
import '../bloc/auth_bloc.dart';
import 'phone_verification_confirmation_screen.dart';
import 'dart:async';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? deviceId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final bool otpAlreadySent;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.deviceId,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.otpAlreadySent = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  Timer? _timer;
  int _countdown = 0;
  bool _canResend = false;
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    if (!widget.otpAlreadySent) {
      _sendOtp();
    } else {
      // If OTP was already sent, start the countdown timer
      _startCountdown(300); // 5 minutes
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _sendOtp() {
    context.read<AuthBloc>().add(
      PhoneVerificationOtpRequested(
        phoneNumber: widget.phoneNumber,
        deviceId: widget.deviceId,
      ),
    );
  }

  void _startCountdown(int seconds) {
    setState(() {
      _countdown = seconds;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        PhoneOtpVerificationRequested(
          phoneNumber: widget.phoneNumber,
          otpCode: _otpCode,
        ),
      );
    }
  }

  void _onOtpChanged(String otp) {
    setState(() {
      _otpCode = otp;
    });
  }

  void _onOtpCompleted(String otp) {
    setState(() {
      _otpCode = otp;
    });
    _verifyOtp();
  }

  void _resendOtp() {
    if (_canResend) {
      context.read<AuthBloc>().add(
        PhoneOtpResendRequested(
          phoneNumber: widget.phoneNumber,
          deviceId: widget.deviceId,
        ),
      );
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Format phone number to show last 4 digits with proper spacing
    if (phoneNumber.length >= 4) {
      final lastFour = phoneNumber.substring(phoneNumber.length - 4);
      return '********$lastFour';
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Light gray background
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is PhoneVerificationOtpSent) {
              _startCountdown(300); // 5 minutes
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'OTP sent to ${_formatPhoneNumber(state.phoneNumber)}',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            } else if (state is PhoneVerificationOtpResent) {
              _startCountdown(300); // 5 minutes
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'OTP resent to ${_formatPhoneNumber(state.phoneNumber)}',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            } else if (state is PhoneVerificationOtpVerified) {
              // OTP verified, now call registration API if we have the data
              if (widget.firstName != null &&
                  widget.lastName != null &&
                  widget.email != null &&
                  widget.password != null) {
                context.read<AuthBloc>().add(
                  AuthRegistrationRequested(
                    firstName: widget.firstName!,
                    lastName: widget.lastName!,
                    email: widget.email!,
                    phoneNumber: widget.phoneNumber,
                    password: widget.password!,
                  ),
                );
              } else {
                // Navigate to confirmation screen if no registration data
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PhoneVerificationConfirmationScreen(
                      phoneNumber: widget.phoneNumber,
                    ),
                  ),
                );
              }
            } else if (state is AuthRegistrationSuccess) {
              // Registration successful, show success message and navigate to confirmation screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registration successful! Account created.'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PhoneVerificationConfirmationScreen(
                    phoneNumber: widget.phoneNumber,
                  ),
                ),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Back button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Feather.arrow_left,
                        color: Color(0xFF333333),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Phone illustration
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(bottom: 15, top: 15),
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Phone outline
                          Container(
                            width: 120,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          // Profile icon
                          Positioned(
                            top: 40,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Feather.user,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          // Checkmark
                          Positioned(
                            top: 30,
                            right: 30,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Feather.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          // Speech bubble with asterisks
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '*****',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Green dot at bottom
                          Positioned(
                            bottom: 20,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Verify your Phone',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Instructions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Please enter the code we sent to ${_formatPhoneNumber(widget.phoneNumber)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // OTP Input Field
                  Center(
                    child: OtpInputField(
                      length: 6,
                      onChanged: _onOtpChanged,
                      onCompleted: _onOtpCompleted,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the OTP';
                        }
                        if (value.length != 6) {
                          return 'OTP must be 6 digits';
                        }
                        if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                          return 'OTP must contain only numbers';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Resend option
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Didn't get the code? ",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _canResend ? _resendOtp : null,
                              child: Text(
                                'Resend it.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _canResend
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFF999999),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Verify Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF4CAF50,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading ? null : _verifyOtp,
                            borderRadius: BorderRadius.circular(30),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Verify',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Countdown Timer
                  if (_countdown > 0)
                    Center(
                      child: Text(
                        'Resend OTP in ${_countdown ~/ 60}:${(_countdown % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
