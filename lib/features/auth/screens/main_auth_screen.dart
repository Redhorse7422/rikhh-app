import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:ui';

class MainAuthScreen extends StatefulWidget {
  const MainAuthScreen({super.key});

  @override
  State<MainAuthScreen> createState() => _MainAuthScreenState();
}

class _MainAuthScreenState extends State<MainAuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            top: -65,
            child: Image.asset('assets/images/auth_bg.png', fit: BoxFit.cover),
          ),

          // White blurry overlay - TOP
          // White blurry overlay - BOTTOM
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 140,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.white.withValues(
                          alpha: 0.8,
                        ), // Almost solid at bottom
                        Colors.white.withValues(alpha: .5), // Mid fade
                        Colors.white.withValues(alpha: 0.5), // Lightly visible
                        Colors.white.withValues(
                          alpha: 0.5,
                        ), // Fully transparent at top
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
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
            bottom: 0,
            height: 160,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
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

          // Content Overlay
          SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildAuthSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthSection() {
    final size = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 640,
        // Height around 42% of screen; tweak as desired
        maxHeight: size.height * 0.42,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(
            //   'Log in with Google or choose another method',
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: AppColors.body,
            //     fontWeight: FontWeight.w500,
            //   ),
            //   textAlign: TextAlign.center,
            // ),

            // const SizedBox(height: 24),

            // // Google Sign In Button
            // Container(
            //   width: double.infinity,
            //   height: 56,
            //   decoration: BoxDecoration(
            //     color: Colors.grey.shade100,
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: Colors.grey.shade300),
            //   ),
            //   child: Material(
            //     color: Colors.transparent,
            //     child: InkWell(
            //       onTap: () {
            //         // Handle Google sign in
            //       },
            //       borderRadius: BorderRadius.circular(12),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           // Google Logo
            //           Container(
            //             width: 24,
            //             height: 24,
            //             decoration: BoxDecoration(
            //               color: Colors.white,
            //               borderRadius: BorderRadius.circular(4),
            //             ),
            //             child: Center(
            //               child: Text(
            //                 'G',
            //                 style: TextStyle(
            //                   fontSize: 18,
            //                   fontWeight: FontWeight.bold,
            //                   color: Colors.blue,
            //                 ),
            //               ),
            //             ),
            //           ),
            //           const SizedBox(width: 12),
            //           Text(
            //             'Continue with Google',
            //             style: TextStyle(
            //               fontSize: 16,
            //               fontWeight: FontWeight.w600,
            //               color: AppColors.heading,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 24),

            // Row(
            //   children: [
            //     Expanded(
            //       child: Container(height: 1, color: Colors.grey.shade300),
            //     ),
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
            //     Expanded(
            //       child: Container(height: 1, color: Colors.grey.shade300),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 24),

            // Sign Up and Login Buttons
            Row(
              children: [
                // Sign Up Button
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(50),
                      border: const Border.fromBorderSide(
                        BorderSide(color: Color(0xFFF2F4F7)),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.push('/register');
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.heading,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Login Button
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(50),
                      border: const Border.fromBorderSide(
                        BorderSide(color: Color(0xFFF2F4F7)),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.push('/login');
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.heading,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
