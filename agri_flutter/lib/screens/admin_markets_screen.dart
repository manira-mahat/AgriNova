import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/market.dart';
import '../providers/market_provider.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/map_location_picker.dart';

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
    String selectedMarketType = 'retail';
    double? selectedLatitude;
    double? selectedLongitude;

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
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => MapLocationPicker(
                          initialLat: selectedLatitude,
                          initialLng: selectedLongitude,
                          initialAddress: addressController.text.trim(),
                          onLocationSelected: (
                            latitude,
                            longitude,
                            address,
                            district,
                          ) {
                            setDialogState(() {
                              selectedLatitude = latitude;
                              selectedLongitude = longitude;
                              if (address.isNotEmpty) {
                                addressController.text = address;
                              }
                              if (district.isNotEmpty) {
                                districtController.text = district;
                              }
                            });
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.green.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Select location on map',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          if (selectedLatitude != null &&
                              selectedLongitude != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Lat: ${selectedLatitude!.toStringAsFixed(6)}, Lng: ${selectedLongitude!.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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

                if (selectedLatitude == null || selectedLongitude == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a market location on the map'),
                    ),
                  );
                  return;
                }

                final data = {
                  "name": nameController.text.trim(),
                  "district": districtController.text.trim(),
                  "market_type": selectedMarketType,
                  "address": addressController.text.trim(),
                  "latitude": selectedLatitude,
                  "longitude": selectedLongitude,
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

  void _showEditMarketDialog(Market market) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: market.name);
    final districtController = TextEditingController(text: market.district);
    final addressController = TextEditingController(text: market.address ?? '');
    String selectedMarketType = market.marketType;
    double? selectedLatitude = market.latitude;
    double? selectedLongitude = market.longitude;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${market.name}'),
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
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => MapLocationPicker(
                          initialLat: selectedLatitude,
                          initialLng: selectedLongitude,
                          initialAddress: addressController.text.trim(),
                          onLocationSelected: (
                            latitude,
                            longitude,
                            address,
                            district,
                          ) {
                            setDialogState(() {
                              selectedLatitude = latitude;
                              selectedLongitude = longitude;
                              if (address.isNotEmpty) {
                                addressController.text = address;
                              }
                              if (district.isNotEmpty) {
                                districtController.text = district;
                              }
                            });
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.green.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Select location on map',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          if (selectedLatitude != null &&
                              selectedLongitude != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Lat: ${selectedLatitude!.toStringAsFixed(6)}, Lng: ${selectedLongitude!.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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

                if (selectedLatitude == null || selectedLongitude == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a market location on the map'),
                    ),
                  );
                  return;
                }

                final data = {
                  'name': nameController.text.trim(),
                  'district': districtController.text.trim(),
                  'market_type': selectedMarketType,
                  'address': addressController.text.trim(),
                  'latitude': selectedLatitude,
                  'longitude': selectedLongitude,
                };

                final marketProvider = Provider.of<MarketProvider>(
                  context,
                  listen: false,
                );
                final success = await marketProvider.updateMarket(market.id, data);

                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Market updated successfully!')),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        marketProvider.error ?? 'Failed to update market',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
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
                      onTap: () => _showEditMarketDialog(market),
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
