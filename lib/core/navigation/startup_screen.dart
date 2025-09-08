import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../network/dio_client.dart';
import '../routes/app_router.dart';
import '../../shared/components/app_logo.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);
      // Configure Dio with token if present
      DioClient.updateAuthToken(token);
      
      // Add small delay to prevent blocking main thread
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckStatusRequested());
      }
    } catch (e) {
      // Handle bootstrap errors gracefully
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckStatusRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to main navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRouter.main);
          });
          return const SizedBox.shrink(); // Return empty widget while navigating
        }
        if (state is AuthUnauthenticated) {
          return const AuthScreen();
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                RikhhLogo.splash(),
                const SizedBox(height: 32),
                // Loading indicator
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
