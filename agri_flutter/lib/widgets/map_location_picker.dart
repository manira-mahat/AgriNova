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
  static const double _minZoom = 6;
  static const double _maxZoom = 18;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late LatLng _selectedLocation;
  double _currentZoom = 15;
  String? _selectedAddress;
  String? _selectedDistrict;
  bool _loadingAddress = false;
  bool _searchingPlace = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLat != null && widget.initialLng != null
            ? LatLng(widget.initialLat!, widget.initialLng!)
            : _defaultCenter;
    _selectedAddress = widget.initialAddress;
    _searchController.text = widget.initialAddress ?? '';
    _resolveAddress(_selectedLocation, updateCamera: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      _mapController.move(location, _currentZoom);
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

  void _zoomIn() {
    _currentZoom = (_currentZoom + 1).clamp(_minZoom, _maxZoom).toDouble();
    _mapController.move(_selectedLocation, _currentZoom);
    setState(() {});
  }

  void _zoomOut() {
    _currentZoom = (_currentZoom - 1).clamp(_minZoom, _maxZoom).toDouble();
    _mapController.move(_selectedLocation, _currentZoom);
    setState(() {});
  }

  void _recenter() {
    _mapController.move(_selectedLocation, _currentZoom);
  }

  Future<void> _searchPlace() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }

    setState(() {
      _searchingPlace = true;
    });

    try {
      final results = await locationFromAddress(query);
      if (!mounted) {
        return;
      }

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No location found for that search.')),
        );
        return;
      }

      final first = results.first;
      _currentZoom = 15;
      await _resolveAddress(
        LatLng(first.latitude, first.longitude),
        updateCamera: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to search this place. Try another name.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _searchingPlace = false;
        });
      }
    }
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
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation,
                        initialZoom: _currentZoom,
                        minZoom: _minZoom,
                        maxZoom: _maxZoom,
                        onTap: _onTap,
                        onPositionChanged: (position, _) {
                          final zoom = position.zoom;
                          if (mounted) {
                            setState(() {
                              _currentZoom = zoom;
                            });
                          }
                        },
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
                    Positioned(
                      left: 12,
                      right: 72,
                      top: 12,
                      child: Material(
                        elevation: 2,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onSubmitted: (_) => _searchPlace(),
                                decoration: const InputDecoration(
                                  hintText: 'Search place name',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Search',
                              onPressed: _searchingPlace ? null : _searchPlace,
                              icon:
                                  _searchingPlace
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.search),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Column(
                        children: [
                          Material(
                            color: Colors.white,
                            elevation: 2,
                            borderRadius: BorderRadius.circular(10),
                            child: IconButton(
                              tooltip: 'Zoom in',
                              onPressed: _zoomIn,
                              icon: const Icon(Icons.add),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Material(
                            color: Colors.white,
                            elevation: 2,
                            borderRadius: BorderRadius.circular(10),
                            child: IconButton(
                              tooltip: 'Zoom out',
                              onPressed: _zoomOut,
                              icon: const Icon(Icons.remove),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Material(
                            color: Colors.white,
                            elevation: 2,
                            borderRadius: BorderRadius.circular(10),
                            child: IconButton(
                              tooltip: 'Recenter',
                              onPressed: _recenter,
                              icon: const Icon(Icons.my_location),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'OpenStreetMap: tap to select a location',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
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