import 'package:equatable/equatable.dart';
import '../../../core/services/location_service.dart';
import 'package:bloc/bloc.dart';
part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<LocationLoadRequested>(_onLocationLoadRequested);
    on<LocationUpdateRequested>(_onLocationUpdateRequested);
    on<LocationClearRequested>(_onLocationClearRequested);
  }

  Future<void> _onLocationLoadRequested(
    LocationLoadRequested event,
    Emitter<LocationState> emit,
  ) async {
    try {
      emit(LocationLoading());

      final savedLocation = await LocationService.getSavedLocation();
      if (savedLocation != null) {
        emit(
          LocationLoaded(
            address: savedLocation['address'],
            latitude: savedLocation['latitude'],
            longitude: savedLocation['longitude'],
          ),
        );
      } else {
        emit(LocationNotSet());
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onLocationUpdateRequested(
    LocationUpdateRequested event,
    Emitter<LocationState> emit,
  ) async {
    try {
      emit(LocationLoading());

      await LocationService.saveLocation(
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
      );

      emit(
        LocationLoaded(
          address: event.address,
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      );
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onLocationClearRequested(
    LocationClearRequested event,
    Emitter<LocationState> emit,
  ) async {
    try {
      await LocationService.clearSavedLocation();
      emit(LocationNotSet());
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}
