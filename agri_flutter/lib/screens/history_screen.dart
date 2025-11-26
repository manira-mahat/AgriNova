import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';

// Simple History Screen
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load history when screen opens
    Future.microtask(
      () => Provider.of<CropProvider>(context, listen: false).loadHistory(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cropProvider = Provider.of<CropProvider>(context);
    final history = cropProvider.history;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Recommendation History'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Past Recommendations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 20),

            // History list
            Expanded(
              child: cropProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: Colors.green[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recommendation history yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Get your first crop recommendation!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final recommendation = history[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.agriculture,
                                      color: Colors.green[700],
                                      size: 30,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        recommendation.cropName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'N',
                                  '${recommendation.nitrogen}',
                                ),
                                _buildInfoRow(
                                  'P',
                                  '${recommendation.phosphorus}',
                                ),
                                _buildInfoRow(
                                  'K',
                                  '${recommendation.potassium}',
                                ),
                                _buildInfoRow(
                                  'Temp',
                                  '${recommendation.temperature}°C',
                                ),
                                _buildInfoRow(
                                  'Humidity',
                                  '${recommendation.humidity}%',
                                ),
                                _buildInfoRow('pH', '${recommendation.ph}'),
                                _buildInfoRow(
                                  'Rainfall',
                                  '${recommendation.rainfall} mm',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
