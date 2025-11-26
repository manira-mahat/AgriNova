import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';

// Simple Crop Result Screen
class CropResultScreen extends StatelessWidget {
  const CropResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cropProvider = Provider.of<CropProvider>(context);
    final recommendation = cropProvider.currentRecommendation;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Recommendation Result'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.green[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Recommended Crop',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recommendation?.cropName ?? 'N/A',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Input parameters
              Text(
                'Your Input Parameters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 16),

              _buildInfoRow('Nitrogen (N)', '${recommendation?.nitrogen ?? 0}'),
              _buildInfoRow(
                'Phosphorus (P)',
                '${recommendation?.phosphorus ?? 0}',
              ),
              _buildInfoRow(
                'Potassium (K)',
                '${recommendation?.potassium ?? 0}',
              ),
              _buildInfoRow(
                'Temperature',
                '${recommendation?.temperature ?? 0}°C',
              ),
              _buildInfoRow('Humidity', '${recommendation?.humidity ?? 0}%'),
              _buildInfoRow('pH Level', '${recommendation?.ph ?? 0}'),
              _buildInfoRow('Rainfall', '${recommendation?.rainfall ?? 0} mm'),
              const SizedBox(height: 30),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Get Another Recommendation'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green[700]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
