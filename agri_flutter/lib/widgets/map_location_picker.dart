import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class MapLocationPicker extends StatefulWidget {
  final Function(double latitude, double longitude, String address, String district)
      onLocationSelected;
  final double? initialLat;
  final double? initialLng;
  final String? initialAddress;

  const MapLocationPicker({
    required this.onLocationSelected,
    this.initialLat,
    this.initialLng,
    this.initialAddress,
    super.key,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  static const LatLng _defaultCenter = LatLng(27.7172, 85.3240);

  final MapController _mapController = MapController();

  late LatLng _selectedLocation;
  String? _selectedAddress;
  String? _selectedDistrict;
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLat != null && widget.initialLng != null
            ? LatLng(widget.initialLat!, widget.initialLng!)
            : _defaultCenter;
    _selectedAddress = widget.initialAddress;
    _resolveAddress(_selectedLocation, updateCamera: false);
  }

  Future<void> _resolveAddress(
    LatLng location, {
    bool updateCamera = true,
  }) async {
    setState(() {
      _loadingAddress = true;
      _selectedLocation = location;
    });

    if (updateCamera) {
      _mapController.move(location, 15);
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted) {
        return;
      }

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String?>[
          place.name,
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].whereType<String>().where((part) => part.trim().isNotEmpty);
        _selectedAddress = parts.join(', ');
        _selectedDistrict = <String?>[
          place.subAdministrativeArea,
          place.locality,
          place.administrativeArea,
        ].whereType<String>().firstWhere(
          (value) => value.trim().isNotEmpty,
          orElse: () => '',
        );
      } else {
        _selectedAddress = null;
        _selectedDistrict = null;
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _selectedAddress = null;
      _selectedDistrict = null;
    } finally {
      if (mounted) {
        setState(() {
          _loadingAddress = false;
        });
      }
    }
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    _resolveAddress(point);
  }

  void _confirmLocation() {
    widget.onLocationSelected(
      _selectedLocation.latitude,
      _selectedLocation.longitude,
      _selectedAddress ?? '',
      _selectedDistrict ?? '',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.82,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Market Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap anywhere on the map to set the market position.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 15,
                    onTap: _onTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.agri_fluttter',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.location_on,
                            size: 44,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location: ${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        if (_loadingAddress)
                          const Text('Fetching address...')
                        else if (_selectedAddress != null &&
                            _selectedAddress!.trim().isNotEmpty)
                          Text(
                            'Address: $_selectedAddress',
                            style: TextStyle(color: Colors.grey[700]),
                          )
                        else
                          Text(
                            'Address not available for this point.',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirm Location'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}