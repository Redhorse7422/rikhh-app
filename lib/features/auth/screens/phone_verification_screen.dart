import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/otp_input_field.dart';
import '../bloc/auth_bloc.dart';
import 'dart:async';

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? deviceId;

  const PhoneVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.deviceId,
  });

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  Timer? _timer;
  int _countdown = 0;
  bool _canResend = false;
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    _sendOtp();
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
    if (phoneNumber.length >= 10) {
      final lastFour = phoneNumber.substring(phoneNumber.length - 4);
      return '******$lastFour';
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Feather.arrow_left, color: AppColors.heading),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Verify Phone',
          style: TextStyle(
            color: AppColors.heading,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is PhoneVerificationOtpSent) {
              _startCountdown(300); // 5 minutes
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('OTP sent to ${_formatPhoneNumber(state.phoneNumber)}'),
                  backgroundColor: AppColors.primary,
                ),
              );
            } else if (state is PhoneVerificationOtpResent) {
              _startCountdown(300); // 5 minutes
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('OTP resent to ${_formatPhoneNumber(state.phoneNumber)}'),
                  backgroundColor: AppColors.primary,
                ),
              );
            } else if (state is PhoneVerificationOtpVerified) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone number verified successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate back to signup or proceed with registration
              Navigator.of(context).pop(true);
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
                  const SizedBox(height: 32),

                  // Header
                  Text(
                    'Verify Your Phone',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'We sent a 6-digit code to',
                    style: TextStyle(fontSize: 16, color: AppColors.body),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _formatPhoneNumber(widget.phoneNumber),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // OTP Input Field
                  OtpInputField(
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

                  const SizedBox(height: 24),

                  // Countdown Timer
                  Center(
                    child: Text(
                      _countdown > 0
                          ? 'Resend OTP in ${_countdown ~/ 60}:${(_countdown % 60).toString().padLeft(2, '0')}'
                          : 'OTP expired',
                      style: TextStyle(
                        fontSize: 14,
                        color: _countdown > 0 ? AppColors.body : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Verify Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      
                      return Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading ? null : _verifyOtp,
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Verify OTP',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Resend Button
                  Center(
                    child: TextButton(
                      onPressed: _canResend ? _resendOtp : null,
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _canResend ? AppColors.primary : AppColors.body,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Help Text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Feather.info,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Didn\'t receive the code? Check your SMS or wait for the timer to expire to resend.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.heading,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Change Phone Number
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Change Phone Number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
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
