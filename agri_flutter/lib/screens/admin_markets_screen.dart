import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../widgets/custom_textfield.dart';

// Simple Admin Markets Screen
class AdminMarketsScreen extends StatefulWidget {
  const AdminMarketsScreen({super.key});

  @override
  State<AdminMarketsScreen> createState() => _AdminMarketsScreenState();
}

class _AdminMarketsScreenState extends State<AdminMarketsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<MarketProvider>(context, listen: false).loadMarkets(),
    );
  }

  void _showAddMarketDialog() {
    final nameController = TextEditingController();
    final districtController = TextEditingController();
    final addressController = TextEditingController();
    final latController = TextEditingController();
    final longController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Market'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'Market Name', controller: nameController),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'District',
                controller: districtController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Address',
                controller: addressController,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Latitude',
                controller: latController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Longitude',
                controller: longController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  districtController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }

              final data = {
                "name": nameController.text,
                "district": districtController.text,
                "address": addressController.text,
                "latitude": double.parse(latController.text),
                "longitude": double.parse(longController.text),
              };

              final marketProvider = Provider.of<MarketProvider>(
                context,
                listen: false,
              );
              final success = await marketProvider.createMarket(data);

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Market added successfully!')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final markets = marketProvider.markets;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Manage Markets'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMarketDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: marketProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : markets.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store, size: 80, color: Colors.green[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No markets in database',
                      style: TextStyle(fontSize: 18, color: Colors.green[600]),
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
                    child: ListTile(
                      leading: Icon(
                        Icons.store,
                        color: Colors.green[700],
                        size: 40,
                      ),
                      title: Text(
                        market.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(market.district),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Market'),
                              content: Text(
                                'Are you sure you want to delete ${market.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            await marketProvider.deleteMarket(market.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Market deleted successfully!'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
