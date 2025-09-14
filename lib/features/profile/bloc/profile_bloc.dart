import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/profile_update_model.dart';
import '../services/profile_api_service.dart';
import '../../../core/app_config.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final ProfileUpdateRequest request;

  const UpdateProfile(this.request);

  @override
  List<Object> get props => [request];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile user;

  const ProfileLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class ProfileUpdated extends ProfileState {
  final UserProfile user;

  const ProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(AppConfig.userKey);

      if (userStr != null) {
        final userData = jsonDecode(userStr) as Map<String, dynamic>;

        // Debug logging

        // Convert the stored user data to UserProfile model
        final userProfile = UserProfile(
          id: userData['id'] ?? userData['_id'] ?? '',
          firstName:
              userData['firstName'] ?? userData['name']?.split(' ').first ?? '',
          lastName:
              userData['lastName'] ?? userData['name']?.split(' ').last ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? userData['phoneNumber'] ?? '',
          type: userData['type'] ?? 'buyer',
          emailVerified: userData['emailVerified'] ?? false,
          phoneVerified: userData['phoneVerified'] ?? false,
          createdAt: userData['createdAt'] ?? '',
          updatedAt: userData['updatedAt'] ?? '',
        );

        emit(ProfileLoaded(userProfile));
      } else {
        emit(ProfileError('No user data found'));
      }
    } catch (e) {
      emit(ProfileError('Failed to load user profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final response = await ProfileService.updateProfile(event.request);

      // Update shared preferences with new user data
      final prefs = await SharedPreferences.getInstance();
      final userJson = response.data.user.toJson();
      await prefs.setString(AppConfig.userKey, jsonEncode(userJson));

      // Also update the auth state by emitting a new AuthAuthenticated state
      // This will be handled by the edit profile screen
      emit(ProfileUpdated(response.data.user));
    } catch (e) {
      emit(ProfileError('Failed to update profile: ${e.toString()}'));
    }
  }
}
