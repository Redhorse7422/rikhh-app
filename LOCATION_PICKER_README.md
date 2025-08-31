# Location Picker Implementation

This document describes the location picker functionality implemented in the Rikhh E-Commerce app.

## Features

### 1. Current Location Detection
- Automatically detects user's current location using GPS
- Requests necessary permissions (location access)
- Converts coordinates to human-readable addresses

### 2. Location Search
- Search for locations by city, address, or landmark
- Real-time search results with address formatting
- Integration with Google's geocoding services

### 3. Location Management
- Save selected locations to local storage
- Persistent location data across app sessions
- Easy location switching

### 4. User Interface
- Clean, intuitive location picker screen
- Current location button with loading states
- Search functionality with real-time results
- Responsive design for all screen sizes

## Implementation Details

### Files Created/Modified

1. **Location Service** (`lib/core/services/location_service.dart`)
   - Handles all location-related operations
   - GPS permission management
   - Coordinate-to-address conversion
   - Local storage integration

2. **Location Bloc** (`lib/features/home/bloc/location_bloc.dart`)
   - State management for location data
   - Events: Load, Update, Clear location
   - States: Initial, Loading, Loaded, NotSet, Error

3. **Location Picker Screen** (`lib/features/home/screens/location_picker_screen.dart`)
   - Main location selection interface
   - Search functionality
   - Current location detection
   - Location result display

4. **Home Screen Updates** (`lib/features/home/screens/home_screen.dart`)
   - Integrated location display
   - Tappable location bar
   - Location bloc integration

5. **Main App Updates** (`lib/main.dart`)
   - LocationBloc provider registration

6. **Permission Updates**
   - Android: `AndroidManifest.xml`
   - iOS: `Info.plist`

### Dependencies Added

```yaml
# Location Services
geolocator: ^10.1.0          # GPS location detection
geocoding: ^2.1.1            # Address/coordinate conversion
google_maps_flutter: ^2.5.3  # Maps integration (future use)
```

## Usage

### For Users

1. **Tap the location bar** in the home screen header
2. **Use Current Location**: Tap the "Use Current Location" button
3. **Search for Location**: Type in the search bar to find specific places
4. **Select Location**: Tap on any search result to set it as your location

### For Developers

1. **Access Location State**:
   ```dart
   BlocBuilder<LocationBloc, LocationState>(
     builder: (context, state) {
       if (state is LocationLoaded) {
         // Use state.address, state.latitude, state.longitude
       }
     },
   )
   ```

2. **Update Location**:
   ```dart
   context.read<LocationBloc>().add(
     LocationUpdateRequested(
       address: 'New York, NY',
       latitude: 40.7128,
       longitude: -74.0060,
     ),
   );
   ```

3. **Get Current Location**:
   ```dart
   final position = await LocationService.getCurrentLocation();
   ```

## Permissions Required

### Android
- `ACCESS_FINE_LOCATION`: Precise location access
- `ACCESS_COARSE_LOCATION`: Approximate location access
- `ACCESS_BACKGROUND_LOCATION`: Background location (optional)

### iOS
- `NSLocationWhenInUseUsageDescription`: Location usage description
- `NSLocationAlwaysAndWhenInUseUsageDescription`: Always location access
- `NSLocationAlwaysUsageDescription`: Background location access

## Future Enhancements

1. **Maps Integration**: Show selected location on a map
2. **Delivery Radius**: Calculate delivery areas based on location
3. **Nearby Stores**: Show stores near the selected location
4. **Location History**: Remember previously used locations
5. **Favorites**: Save frequently used locations
6. **Offline Support**: Cache location data for offline use

## Troubleshooting

### Common Issues

1. **Location Not Working**
   - Check if location services are enabled
   - Verify app permissions are granted
   - Ensure device has GPS capability

2. **Search Not Working**
   - Check internet connectivity
   - Verify geocoding service availability
   - Try different search terms

3. **Permission Denied**
   - Guide user to app settings
   - Explain why location access is needed
   - Provide manual location input option

### Debug Information

- Location service logs are printed to console
- Check `LocationService` methods for error handling
- Verify bloc state transitions in debug mode

## Security Considerations

1. **Permission Management**: Only request necessary permissions
2. **Data Privacy**: Location data is stored locally only
3. **User Control**: Users can clear location data anytime
4. **Transparency**: Clear explanation of location usage

## Testing

1. **Unit Tests**: Test LocationService methods
2. **Bloc Tests**: Test LocationBloc events and states
3. **Widget Tests**: Test LocationPickerScreen UI
4. **Integration Tests**: Test complete location flow
5. **Permission Tests**: Test permission request flows
