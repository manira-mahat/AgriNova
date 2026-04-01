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
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final districtController = TextEditingController();
    final addressController = TextEditingController();
    final latController = TextEditingController();
    final longController = TextEditingController();
    String selectedMarketType = 'retail';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Market'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Market Name',
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Market name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'District',
                    controller: districtController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'District is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedMarketType,
                    decoration: const InputDecoration(
                      labelText: 'Market Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'retail',
                        child: Text('Retail Market'),
                      ),
                      DropdownMenuItem(
                        value: 'wholesale',
                        child: Text('Wholesale Market'),
                      ),
                      DropdownMenuItem(
                        value: 'collection',
                        child: Text('Collection Center'),
                      ),
                      DropdownMenuItem(
                        value: 'cooperative',
                        child: Text('Cooperative Market'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedMarketType = value;
                        });
                      }
                    },
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Latitude is required';
                      }
                      final latitude = double.tryParse(value.trim());
                      if (latitude == null) {
                        return 'Enter a valid latitude';
                      }
                      if (latitude < -90 || latitude > 90) {
                        return 'Latitude must be between -90 and 90';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Longitude',
                    controller: longController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Longitude is required';
                      }
                      final longitude = double.tryParse(value.trim());
                      if (longitude == null) {
                        return 'Enter a valid longitude';
                      }
                      if (longitude < -180 || longitude > 180) {
                        return 'Longitude must be between -180 and 180';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final data = {
                  "name": nameController.text.trim(),
                  "district": districtController.text.trim(),
                  "market_type": selectedMarketType,
                  "address": addressController.text.trim(),
                  "latitude": double.parse(latController.text.trim()),
                  "longitude": double.parse(longController.text.trim()),
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
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        marketProvider.error ?? 'Failed to add market',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
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
                itemBuilder: (itemContext, index) {
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
                            context: itemContext,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete Market'),
                              content: Text(
                                'Are you sure you want to delete ${market.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
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
