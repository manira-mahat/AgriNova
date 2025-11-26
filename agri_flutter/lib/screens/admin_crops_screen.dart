import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../widgets/custom_textfield.dart';

// Simple Admin Crops Screen
class AdminCropsScreen extends StatefulWidget {
  const AdminCropsScreen({super.key});

  @override
  State<AdminCropsScreen> createState() => _AdminCropsScreenState();
}

class _AdminCropsScreenState extends State<AdminCropsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<CropProvider>(context, listen: false).loadCrops(),
    );
  }

  void _showAddCropDialog() {
    final nameController = TextEditingController();
    final nMinController = TextEditingController();
    final nMaxController = TextEditingController();
    final pMinController = TextEditingController();
    final pMaxController = TextEditingController();
    final kMinController = TextEditingController();
    final kMaxController = TextEditingController();
    final phMinController = TextEditingController();
    final phMaxController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Crop'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'Crop Name', controller: nameController),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'N Min',
                controller: nMinController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'N Max',
                controller: nMaxController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'P Min',
                controller: pMinController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'P Max',
                controller: pMaxController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'K Min',
                controller: kMinController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'K Max',
                controller: kMaxController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'pH Min',
                controller: phMinController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'pH Max',
                controller: phMaxController,
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
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter crop name')),
                );
                return;
              }

              final data = {
                "name": nameController.text,
                "nitrogen_min": double.parse(nMinController.text),
                "nitrogen_max": double.parse(nMaxController.text),
                "phosphorus_min": double.parse(pMinController.text),
                "phosphorus_max": double.parse(pMaxController.text),
                "potassium_min": double.parse(kMinController.text),
                "potassium_max": double.parse(kMaxController.text),
                "ph_min": double.parse(phMinController.text),
                "ph_max": double.parse(phMaxController.text),
              };

              final cropProvider = Provider.of<CropProvider>(
                context,
                listen: false,
              );
              final success = await cropProvider.createCrop(data);

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Crop added successfully!')),
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
    final cropProvider = Provider.of<CropProvider>(context);
    final crops = cropProvider.crops;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Manage Crops'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCropDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: cropProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : crops.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grass, size: 80, color: Colors.green[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No crops in database',
                      style: TextStyle(fontSize: 18, color: Colors.green[600]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  final crop = crops[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: Icon(
                        Icons.grass,
                        color: Colors.green[700],
                        size: 40,
                      ),
                      title: Text(
                        crop.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        'N: ${crop.nitrogenMin}-${crop.nitrogenMax} | P: ${crop.phosphorusMin}-${crop.phosphorusMax} | K: ${crop.potassiumMin}-${crop.potassiumMax}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Crop'),
                              content: Text(
                                'Are you sure you want to delete ${crop.name}?',
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
                            await cropProvider.deleteCrop(crop.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Crop deleted successfully!'),
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
