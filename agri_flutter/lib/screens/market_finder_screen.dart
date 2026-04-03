import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../widgets/map_location_picker.dart';
import 'market_result_screen.dart';

// Simple Market Finder Screen
class MarketFinderScreen extends StatefulWidget {
  const MarketFinderScreen({super.key});

  @override
  State<MarketFinderScreen> createState() => _MarketFinderScreenState();
}

class _MarketFinderScreenState extends State<MarketFinderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  String _selectedAddress = '';
  final List<TextInputFormatter> _coordinateInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
  ];
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  void _openMapPicker() {
    final existingLat = double.tryParse(_latitudeController.text.trim());
    final existingLng = double.tryParse(_longitudeController.text.trim());

    showDialog(
      context: context,
      builder: (dialogContext) => MapLocationPicker(
        initialLat: existingLat,
        initialLng: existingLng,
        initialAddress: _selectedAddress,
        onLocationSelected: (latitude, longitude, address, district) {
          setState(() {
            _latitudeController.text = latitude.toStringAsFixed(6);
            _longitudeController.text = longitude.toStringAsFixed(6);
            _selectedAddress = address;
            _autovalidateMode = AutovalidateMode.onUserInteraction;
          });
        },
      ),
    );
  }

  String? _validateLatitude(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Latitude is required';
    }

    final latitude = double.tryParse(input);
    if (latitude == null) {
      return 'Enter a valid latitude value';
    }

    if (latitude < -90 || latitude > 90) {
      return 'Latitude must be between -90 and 90 degrees';
    }

    return null;
  }

  String? _validateLongitude(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Longitude is required';
    }

    final longitude = double.tryParse(input);
    if (longitude == null) {
      return 'Enter a valid longitude value';
    }

    if (longitude < -180 || longitude > 180) {
      return 'Longitude must be between -180 and 180 degrees';
    }

    return null;
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _findMarkets() async {
    final marketProvider = Provider.of<MarketProvider>(context, listen: false);

    FocusScope.of(context).unfocus();
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    final data = {
      "latitude": double.parse(_latitudeController.text.trim()),
      "longitude": double.parse(_longitudeController.text.trim()),
    };

    final success = await marketProvider.findNearest(data);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MarketResultScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(marketProvider.error ?? 'Failed to find markets'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Market Finder'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Nearby Markets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap on map to select your location and find nearby agricultural markets',
                  style: TextStyle(fontSize: 14, color: Colors.green[600]),
                ),
                const SizedBox(height: 30),

                // Info card
                Card(
                  color: Colors.green[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Tap "Pick from Map" and select your location directly',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                InkWell(
                  onTap: _openMapPicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green.shade50,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.map, color: Colors.green[700]),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Pick from Map',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
                if (_selectedAddress.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _selectedAddress,
                    style: TextStyle(fontSize: 12, color: Colors.green[800]),
                  ),
                ],
                const SizedBox(height: 20),

                // Latitude
                CustomTextField(
                  label: 'Latitude',
                  controller: _latitudeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  validator: _validateLatitude,
                  inputFormatters: _coordinateInputFormatters,
                  helperText: 'Range: -90 to 90 degrees',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Longitude
                CustomTextField(
                  label: 'Longitude',
                  controller: _longitudeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  validator: _validateLongitude,
                  inputFormatters: _coordinateInputFormatters,
                  helperText: 'Range: -180 to 180 degrees',
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                // Find Markets button
                Consumer<MarketProvider>(
                  builder: (context, marketProvider, child) {
                    return CustomButton(
                      text: 'Find Markets',
                      onPressed: _findMarkets,
                      isLoading: marketProvider.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
