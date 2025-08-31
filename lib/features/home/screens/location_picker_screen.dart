import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/responsive.dart';
import '../bloc/location_bloc.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingCurrentLocation = false;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    final savedLocation = await LocationService.getSavedLocation();
    if (savedLocation != null) {
      setState(() {
        _currentAddress = savedLocation['address'];
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (!mounted) return;

        setState(() {
          _currentAddress = address ?? 'Unknown Location';
        });

        // Save the location using bloc
        if (address != null) {
          context.read<LocationBloc>().add(
            LocationUpdateRequested(
              address: address,
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingCurrentLocation = false;
      });
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      List<Map<String, dynamic>> placemarks = [];

      for (Location location in locations.take(5)) {
        List<Placemark> marks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (marks.isNotEmpty) {
          placemarks.add({
            'latitude': location.latitude,
            'longitude': location.longitude,
            'address': _formatAddress(marks.first),
          });
        }
      }

      setState(() {
        _searchResults = placemarks;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  String _formatAddress(Placemark place) {
    List<String> parts = [];

    if (place.name != null && place.name!.isNotEmpty) {
      parts.add(place.name!);
    }

    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }

    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }

    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }

    if (place.country != null && place.country!.isNotEmpty) {
      parts.add(place.country!);
    }

    return parts.join(', ');
  }

  Future<void> _selectLocation(Map<String, dynamic> place) async {
    try {
      final address = place['address'];

      // Save the selected location using bloc
      context.read<LocationBloc>().add(
        LocationUpdateRequested(
          address: address,
          latitude: double.parse(place['latitude'] ?? '0'),
          longitude: double.parse(place['longitude'] ?? '0'),
        ),
      );

      // Return the selected location
      if (mounted) {
        Navigator.of(context).pop({
          'address': address,
          'latitude': double.parse(place['latitude'] ?? '0'),
          'longitude': double.parse(place['longitude'] ?? '0'),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Feather.arrow_left, color: AppColors.heading),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Select Location',
          style: TextStyle(
            color: AppColors.heading,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: Responsive.padding(context, all: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location...',
                prefixIcon: Icon(Feather.search, color: AppColors.body),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Feather.x, color: AppColors.body),
                        onPressed: () {
                          _searchController.clear();
                          _searchLocations('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchLocations(value);
                } else {
                  setState(() {
                    _searchResults = [];
                    _isSearching = false;
                  });
                }
              },
            ),
          ),

          // Current Location Button
          Container(
            padding: Responsive.padding(context, horizontal: 16),
            child: InkWell(
              onTap: _isLoadingCurrentLocation ? null : _getCurrentLocation,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: Responsive.padding(context, all: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Feather.map_pin, color: AppColors.primary, size: 24),
                    Responsive.hSpace(context, 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use Current Location',
                            style: TextStyle(
                              color: AppColors.heading,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (_currentAddress != null) ...[
                            Responsive.vSpace(context, 4),
                            Text(
                              _currentAddress!,
                              style: TextStyle(
                                color: AppColors.body,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_isLoadingCurrentLocation)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                    else
                      Icon(Feather.chevron_right, color: AppColors.body),
                  ],
                ),
              ),
            ),
          ),

          Responsive.vSpace(context, 16),

          // Search Results
          if (_isSearching)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    Responsive.vSpace(context, 16),
                    Text(
                      'Searching...',
                      style: TextStyle(color: AppColors.body),
                    ),
                  ],
                ),
              ),
            )
          else if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: Responsive.padding(context, horizontal: 16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final place = _searchResults[index];
                  final address = place['address'];

                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _selectLocation(place),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: Responsive.padding(context, all: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Feather.map_pin,
                              color: AppColors.body,
                              size: 20,
                            ),
                            Responsive.hSpace(context, 16),
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(
                                  color: AppColors.heading,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Feather.chevron_right,
                              color: AppColors.body,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else if (_searchController.text.isNotEmpty && !_isSearching)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Feather.search, color: AppColors.body, size: 48),
                    Responsive.vSpace(context, 16),
                    Text(
                      'No locations found',
                      style: TextStyle(color: AppColors.body, fontSize: 16),
                    ),
                    Responsive.vSpace(context, 8),
                    Text(
                      'Try searching with different keywords',
                      style: TextStyle(color: AppColors.body, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Feather.search, color: AppColors.body, size: 48),
                    Responsive.vSpace(context, 16),
                    Text(
                      'Search for a location',
                      style: TextStyle(color: AppColors.body, fontSize: 16),
                    ),
                    Responsive.vSpace(context, 8),
                    Text(
                      'Enter a city, address, or landmark',
                      style: TextStyle(color: AppColors.body, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
