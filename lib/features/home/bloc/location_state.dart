part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final String address;
  final double latitude;
  final double longitude;

  const LocationLoaded({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [address, latitude, longitude];
}

class LocationNotSet extends LocationState {}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
