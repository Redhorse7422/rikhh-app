part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class LocationLoadRequested extends LocationEvent {
  const LocationLoadRequested();
}

class LocationUpdateRequested extends LocationEvent {
  final String address;
  final double latitude;
  final double longitude;

  const LocationUpdateRequested({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [address, latitude, longitude];
}

class LocationClearRequested extends LocationEvent {
  const LocationClearRequested();
}
