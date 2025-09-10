import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import 'phone_verification_screen.dart';

class PhoneVerificationDemoScreen extends StatefulWidget {
  const PhoneVerificationDemoScreen({super.key});

  @override
  State<PhoneVerificationDemoScreen> createState() => _PhoneVerificationDemoScreenState();
}

class _PhoneVerificationDemoScreenState extends State<PhoneVerificationDemoScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _startPhoneVerification() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PhoneVerificationScreen(
            phoneNumber: _phoneController.text.trim(),
            deviceId: 'demo-${DateTime.now().millisecondsSinceEpoch}',
          ),
        ),
      ).then((isVerified) {
        if (isVerified == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone verification completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Phone Verification Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Header
                Text(
                  'Phone Verification Demo',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Test the phone verification flow with a valid Indian phone number',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.body,
                  ),
                ),

                const SizedBox(height: 48),

                // Phone Number Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+919876543210',
                    prefixIcon: const Icon(Icons.phone, color: AppColors.body),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    if (!RegExp(r'^\+91[6-9]\d{9}$').hasMatch(value)) {
                      return 'Please enter a valid Indian phone number (+91XXXXXXXXXX)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Start Verification Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _startPhoneVerification,
                      borderRadius: BorderRadius.circular(12),
                      child: const Center(
                        child: Text(
                          'Start Phone Verification',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Features List
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Features:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem('✓ OTP sent via SMS'),
                      _buildFeatureItem('✓ 6-digit OTP input with auto-focus'),
                      _buildFeatureItem('✓ 5-minute countdown timer'),
                      _buildFeatureItem('✓ Resend OTP functionality'),
                      _buildFeatureItem('✓ Real-time validation'),
                      _buildFeatureItem('✓ Error handling'),
                      _buildFeatureItem('✓ Modern UI design'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Instructions:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Enter a valid Indian phone number (+91XXXXXXXXXX)\n'
                        '2. Click "Start Phone Verification"\n'
                        '3. You will be redirected to the verification screen\n'
                        '4. Enter the 6-digit OTP sent to your phone\n'
                        '5. The OTP will be verified automatically',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.heading,
        ),
      ),
    );
  }
}
