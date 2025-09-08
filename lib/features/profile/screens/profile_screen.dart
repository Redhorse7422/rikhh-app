import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../core/routes/app_router.dart';
import '../../../shared/components/optimized_image.dart';
import '../../../core/services/image_optimization_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Navigate to startup screen after logout using GoRouter
          context.go(AppRouter.startup);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top Section - User Profile Header
              _buildUserProfileHeader(context),

              const SizedBox(height: 20),

              // Middle Section - Profile Options List
              Expanded(child: _buildProfileOptionsList(context)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'User';
        String userEmail = 'user@example.com';
        String? userAvatar;

        if (state is AuthAuthenticated && state.user.isNotEmpty) {
          // Extract user data from the authenticated state
          final user = state.user;
          userName =
              user['name'] ?? user['fullName'] ?? user['firstName'] ?? 'User';
          userEmail = user['email'] ?? 'user@example.com';
          userAvatar = user['avatar'] ?? user['profileImage'];
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: ClipOval(
                  child: userAvatar != null
                      ? OptimizedImage(
                          imageUrl: userAvatar,
                          fit: BoxFit.cover,
                          size: ImageSize.thumbnail,
                          width: 60,
                          height: 60,
                          errorWidget: _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),

              const SizedBox(width: 16),

              // User Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(fontSize: 14, color: AppColors.body),
                    ),
                  ],
                ),
              ),

              // Edit Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Feather.edit_3, size: 20, color: AppColors.primary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Feather.user, size: 30, color: Colors.grey.shade600),
    );
  }

  Widget _buildProfileOptionsList(BuildContext context) {
    final profileOptions = [
      {'icon': Feather.user, 'title': 'Edit Profile', 'onTap': () {}},
      {'icon': Feather.lock, 'title': 'Account Security', 'onTap': () {}},
      {'icon': Feather.users, 'title': 'Refer a Friend', 'onTap': () {}},
      {'icon': Feather.credit_card, 'title': 'Payment Methods', 'onTap': () {}},
      {'icon': Feather.map_pin, 'title': 'Addresses', 'onTap': () {}},
      {'icon': Feather.shield, 'title': 'Privacy Policy', 'onTap': () {}},
      {
        'icon': Feather.file_text,
        'title': 'Terms & Conditions',
        'onTap': () {},
      },

      {
        'icon': Feather.log_out,
        'title': 'Logout',
        'onTap': () => _showLogoutDialog(context),
        'isDestructive': true,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: profileOptions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
          indent: 60,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final option = profileOptions[index];
          final isDestructive = option['isDestructive'] == true;

          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                option['icon'] as IconData,
                size: 20,
                color: isDestructive ? Colors.red : AppColors.primary,
              ),
            ),
            title: Text(
              option['title'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : AppColors.heading,
              ),
            ),
            trailing: Icon(
              Feather.chevron_right,
              size: 20,
              color: Colors.grey.shade400,
            ),
            onTap: option['onTap'] as VoidCallback,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Feather.log_out, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout? You will need to login again to access your account.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.body, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger logout
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}
