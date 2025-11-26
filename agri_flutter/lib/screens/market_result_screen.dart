import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';

// Simple Market Result Screen
class MarketResultScreen extends StatelessWidget {
  const MarketResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final markets = marketProvider.nearestMarkets;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Nearby Markets'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Found ${markets.length} Markets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 20),

            // Markets list
            Expanded(
              child: markets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 80,
                            color: Colors.green[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No markets found nearby',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: markets.length,
                      itemBuilder: (context, index) {
                        final market = markets[index];
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
                                      Icons.store,
                                      color: Colors.green[700],
                                      size: 30,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        market.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.location_on,
                                  market.district,
                                ),
                                if (market.address != null)
                                  _buildInfoRow(Icons.place, market.address!),
                                if (market.distanceKm != null)
                                  _buildInfoRow(
                                    Icons.directions,
                                    '${market.distanceKm!.toStringAsFixed(2)} km away',
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Action buttons
            const SizedBox(height: 16),
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
                child: const Text('Search Again'),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
