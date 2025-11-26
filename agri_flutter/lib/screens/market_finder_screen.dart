import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'market_result_screen.dart';

// Simple Market Finder Screen
class MarketFinderScreen extends StatefulWidget {
  const MarketFinderScreen({super.key});

  @override
  State<MarketFinderScreen> createState() => _MarketFinderScreenState();
}

class _MarketFinderScreenState extends State<MarketFinderScreen> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController(text: '10');

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _findMarkets() async {
    final marketProvider = Provider.of<MarketProvider>(context, listen: false);

    // Validate inputs
    if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter latitude and longitude')),
      );
      return;
    }

    final data = {
      "latitude": double.parse(_latitudeController.text),
      "longitude": double.parse(_longitudeController.text),
      "radius_km": double.parse(_radiusController.text),
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
                'Enter your location to find agricultural markets near you',
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
                          'You can get your location coordinates from Google Maps or GPS',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Latitude
              CustomTextField(
                label: 'Latitude',
                controller: _latitudeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Longitude
              CustomTextField(
                label: 'Longitude',
                controller: _longitudeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Radius
              CustomTextField(
                label: 'Search Radius (km)',
                controller: _radiusController,
                keyboardType: TextInputType.number,
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
    );
  }
}
