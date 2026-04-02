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
    final rainfallMinController = TextEditingController();
    final rainfallMaxController = TextEditingController();
    final seasonOptions = ['Spring', 'Summer', 'Autumn', 'Winter'];
    String? selectedSeason;
    final formKey = GlobalKey<FormState>();
    bool autoValidate = false;
    String? apiErrorMessage;

    String? validateRequiredText(String? value, String fieldName) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }
      return null;
    }

    String? validateRequiredNumber(
      String? value,
      String fieldName, {
      double? min,
      double? max,
    }) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }

      final parsed = double.tryParse(value.trim());
      if (parsed == null) {
        return '$fieldName must be a valid number';
      }

      if (min != null && parsed < min) {
        return '$fieldName cannot be less than $min';
      }

      if (max != null && parsed > max) {
        return '$fieldName cannot be more than $max';
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: const Text('Add New Crop'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 340),
              child: Form(
                key: formKey,
                autovalidateMode: autoValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      label: 'Crop Name',
                      controller: nameController,
                      validator: (value) => validateRequiredText(value, 'Crop Name'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'N Min',
                      controller: nMinController,
                      keyboardType: TextInputType.number,
                      validator: (value) => validateRequiredNumber(value, 'N Min'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'N Max',
                      controller: nMaxController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final error = validateRequiredNumber(value, 'N Max');
                        if (error != null) return error;
                        final maxValue = double.parse(value!.trim());
                        final minValue = double.tryParse(nMinController.text.trim());
                        if (minValue != null && maxValue < minValue) {
                          return 'N Max must be greater than or equal to N Min';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'P Min',
                      controller: pMinController,
                      keyboardType: TextInputType.number,
                      validator: (value) => validateRequiredNumber(value, 'P Min'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'P Max',
                      controller: pMaxController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final error = validateRequiredNumber(value, 'P Max');
                        if (error != null) return error;
                        final maxValue = double.parse(value!.trim());
                        final minValue = double.tryParse(pMinController.text.trim());
                        if (minValue != null && maxValue < minValue) {
                          return 'P Max must be greater than or equal to P Min';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'K Min',
                      controller: kMinController,
                      keyboardType: TextInputType.number,
                      validator: (value) => validateRequiredNumber(value, 'K Min'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'K Max',
                      controller: kMaxController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final error = validateRequiredNumber(value, 'K Max');
                        if (error != null) return error;
                        final maxValue = double.parse(value!.trim());
                        final minValue = double.tryParse(kMinController.text.trim());
                        if (minValue != null && maxValue < minValue) {
                          return 'K Max must be greater than or equal to K Min';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'pH Min',
                      controller: phMinController,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          validateRequiredNumber(value, 'pH Min', min: 0),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'pH Max',
                      controller: phMaxController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final error = validateRequiredNumber(
                          value,
                          'pH Max',
                          min: 0,
                          max: 14,
                        );
                        if (error != null) return error;
                        final maxValue = double.parse(value!.trim());
                        final minValue = double.tryParse(phMinController.text.trim());
                        if (minValue != null && maxValue < minValue) {
                          return 'pH Max must be greater than or equal to pH Min';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Rainfall Min (mm)',
                      controller: rainfallMinController,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          validateRequiredNumber(value, 'Rainfall Min'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Rainfall Max (mm)',
                      controller: rainfallMaxController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final error = validateRequiredNumber(value, 'Rainfall Max');
                        if (error != null) return error;
                        final maxValue = double.parse(value!.trim());
                        final minValue = double.tryParse(
                          rainfallMinController.text.trim(),
                        );
                        if (minValue != null && maxValue < minValue) {
                          return 'Rainfall Max must be greater than or equal to Rainfall Min';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSeason,
                      decoration: InputDecoration(
                        labelText: 'Suitable Season',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: seasonOptions
                          .map(
                            (season) => DropdownMenuItem<String>(
                              value: season,
                              child: Text(season),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSeason = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Suitable Season is required' : null,
                    ),
                    if (apiErrorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        apiErrorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setDialogState(() {
                  apiErrorMessage = null;
                });

                final isValid = formKey.currentState?.validate() ?? false;
                if (!isValid) {
                  setDialogState(() {
                    autoValidate = true;
                  });
                  return;
                }

                final minN = double.parse(nMinController.text.trim());
                final maxN = double.parse(nMaxController.text.trim());
                final minP = double.parse(pMinController.text.trim());
                final maxP = double.parse(pMaxController.text.trim());
                final minK = double.parse(kMinController.text.trim());
                final maxK = double.parse(kMaxController.text.trim());
                final minPh = double.parse(phMinController.text.trim());
                final maxPh = double.parse(phMaxController.text.trim());
                final minRain = double.parse(rainfallMinController.text.trim());
                final maxRain = double.parse(rainfallMaxController.text.trim());
                final seasons = selectedSeason!;

                final data = {
                  "name": nameController.text,
                  "min_ph": minPh,
                  "max_ph": maxPh,
                  "min_nitrogen": minN,
                  "max_nitrogen": maxN,
                  "min_phosphorus": minP,
                  "max_phosphorus": maxP,
                  "min_potassium": minK,
                  "max_potassium": maxK,
                  "min_rainfall": minRain,
                  "max_rainfall": maxRain,
                  "suitable_seasons": seasons,
                };

                final cropProvider = Provider.of<CropProvider>(
                  dialogContext,
                  listen: false,
                );
                final success = await cropProvider.createCrop(data);

                if (success && mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Crop added successfully!')),
                  );
                } else if (mounted) {
                  setDialogState(() {
                    apiErrorMessage = cropProvider.error ?? 'Failed to add crop';
                  });
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
                itemBuilder: (itemContext, index) {
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
                          final messenger = ScaffoldMessenger.of(this.context);

                          final confirm = await showDialog<bool>(
                            context: itemContext,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete Crop'),
                              content: Text(
                                'Are you sure you want to delete ${crop.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(dialogContext, true),
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
                            await cropProvider.deleteCrop(crop.id);
                            if (mounted) {
                              messenger.showSnackBar(
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
