import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/main');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // Background image
              Positioned.fill(
                top: -80,
                child: Image.asset(
                  'assets/images/auth_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              // White blurry overlay - TOP
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.85),
                            Colors.white.withValues(alpha: 0.55),
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // White blurry overlay - BOTTOM
              Positioned(
                left: 0,
                right: 0,
                bottom: size.height * 0.55, // position it right above the form
                height: 30,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.85),
                            Colors.white.withValues(alpha: 0.55),
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom sheet-style login form
              SafeArea(
                top: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 640,
                      maxHeight: size.height * 0.62,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.2),
                            blurRadius: 50,
                            offset: const Offset(0, -25),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.heading,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Fill in the details below to sign in to Rikhh app.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.body,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Email field
                              _buildTextField(
                                controller: _emailController,
                                hint: 'Email address',
                                icon: Feather.mail,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Password field
                              _buildTextField(
                                controller: _passwordController,
                                hint: 'Password',
                                icon: Feather.lock,
                                obscure: !_isPasswordVisible,
                                suffix: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Feather.eye_off
                                        : Feather.eye,
                                    color: AppColors.body,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(
                                      () => _rememberMe = v ?? false,
                                    ),
                                    activeColor: AppColors.primary,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                      color: AppColors.heading,
                                      fontSize: 14,
                                    ),
                                  ),
                                  // const Spacer(),
                                  // TextButton(
                                  //   onPressed: () {},
                                  //   child: Text(
                                  //     'Forgot Password?',
                                  //     style: TextStyle(
                                  //       color: AppColors.primary,
                                  //       fontSize: 14,
                                  //       fontWeight: FontWeight.w500,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              // Terms text
                              Text.rich(
                                TextSpan(
                                  text: 'By registering, you accept our ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.body,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: TextStyle(
                                        color: Color(0xFF22C55E),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Color(0xFF22C55E),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '. Your data will be securely encrypted with TLS. ',
                                    ),
                                    WidgetSpan(
                                      child: Icon(
                                        Feather.lock,
                                        size: 12,
                                        color: Color(0xFF22C55E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),
                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context.read<AuthBloc>().add(
                                              AuthLoginRequested(
                                                email: _emailController.text
                                                    .trim(),
                                                password:
                                                    _passwordController.text,
                                                rememberMe: _rememberMe,
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 8),
                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: AppColors.body,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context.push('/register');
                                          },
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Color(0xFF22C55E),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              // OR divider
                              // Row(
                              //   children: [
                              //     Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
                              //     Padding(
                              //       padding: const EdgeInsets.symmetric(horizontal: 16),
                              //       child: Text(
                              //         'OR',
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           color: Colors.grey.shade600,
                              //           fontWeight: FontWeight.w500,
                              //         ),
                              //       ),
                              //     ),
                              //     Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
                              //   ],
                              // ),

                              // const SizedBox(height: 12),
                              // // Continue with Google button (visual only)
                              // SizedBox(
                              //   width: double.infinity,
                              //   height: 52,
                              //   child: OutlinedButton(
                              //     onPressed: isLoading ? null : () {},
                              //     style: OutlinedButton.styleFrom(
                              //       backgroundColor: const Color(0xFFF2F4F7),
                              //       side: const BorderSide(color: Color(0xFFF2F4F7)),
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(50),
                              //       ),
                              //     ),
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       children: [
                              //         // Simple G box as placeholder for Google icon
                              //         Container(
                              //           width: 24,
                              //           height: 24,
                              //           decoration: BoxDecoration(
                              //             color: Colors.white,
                              //             borderRadius: BorderRadius.circular(4),
                              //           ),
                              //           child: const Center(
                              //             child: Text(
                              //               'G',
                              //               style: TextStyle(
                              //                 fontSize: 18,
                              //                 fontWeight: FontWeight.bold,
                              //                 color: Colors.blue,
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //         const SizedBox(width: 12),
                              //         Text(
                              //           'Continue with Google',
                              //           style: TextStyle(
                              //             fontSize: 16,
                              //             fontWeight: FontWeight.w600,
                              //             color: AppColors.heading,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.heading,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.body),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
        ),
      ),
    );
  }
}
