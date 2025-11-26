import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'crop_result_screen.dart';

// Simple Crop Recommendation Screen
class CropRecommendScreen extends StatefulWidget {
  const CropRecommendScreen({super.key});

  @override
  State<CropRecommendScreen> createState() => _CropRecommendScreenState();
}

class _CropRecommendScreenState extends State<CropRecommendScreen> {
  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendation() async {
    final cropProvider = Provider.of<CropProvider>(context, listen: false);

    // Validate inputs
    if (_nitrogenController.text.isEmpty ||
        _phosphorusController.text.isEmpty ||
        _potassiumController.text.isEmpty ||
        _temperatureController.text.isEmpty ||
        _humidityController.text.isEmpty ||
        _phController.text.isEmpty ||
        _rainfallController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final data = {
      "nitrogen": double.parse(_nitrogenController.text),
      "phosphorus": double.parse(_phosphorusController.text),
      "potassium": double.parse(_potassiumController.text),
      "temperature": double.parse(_temperatureController.text),
      "humidity": double.parse(_humidityController.text),
      "ph": double.parse(_phController.text),
      "rainfall": double.parse(_rainfallController.text),
    };

    final success = await cropProvider.getRecommendation(data);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CropResultScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cropProvider.error ?? 'Failed to get recommendation'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Crop Recommendation'),
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
                'Enter Soil & Climate Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Provide the following information to get crop recommendations',
                style: TextStyle(fontSize: 14, color: Colors.green[600]),
              ),
              const SizedBox(height: 30),

              // Nitrogen
              CustomTextField(
                label: 'Nitrogen (N)',
                controller: _nitrogenController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Phosphorus
              CustomTextField(
                label: 'Phosphorus (P)',
                controller: _phosphorusController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Potassium
              CustomTextField(
                label: 'Potassium (K)',
                controller: _potassiumController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Temperature
              CustomTextField(
                label: 'Temperature (°C)',
                controller: _temperatureController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Humidity
              CustomTextField(
                label: 'Humidity (%)',
                controller: _humidityController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // pH
              CustomTextField(
                label: 'pH Level',
                controller: _phController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Rainfall
              CustomTextField(
                label: 'Rainfall (mm)',
                controller: _rainfallController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Get Recommendation button
              Consumer<CropProvider>(
                builder: (context, cropProvider, child) {
                  return CustomButton(
                    text: 'Get Recommendation',
                    onPressed: _getRecommendation,
                    isLoading: cropProvider.isLoading,
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
