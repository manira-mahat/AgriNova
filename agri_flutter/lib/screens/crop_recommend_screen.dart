import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _nitrogenFocusNode = FocusNode();
  final _phosphorusFocusNode = FocusNode();
  final _potassiumFocusNode = FocusNode();
  final _temperatureFocusNode = FocusNode();
  final _phFocusNode = FocusNode();
  final List<TextInputFormatter> _numericInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  ];
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  String _selectedSeason = 'Spring';
  final List<String> _seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];
  String _selectedRainfallLevel = 'Moderate';
  final Map<String, (double min, double max, double suggested)>
  _rainfallLevels = {
    'Low': (0, 800, 500),
    'Moderate': (801, 1400, 1100),
    'High': (1401, 2200, 1800),
    'Very High': (2201, 3500, 2600),
  };

  Widget _buildGuideChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.green[800]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeUnitGuide({required String range, required String unit}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildGuideChip(icon: Icons.straighten, text: 'Range: $range'),
          _buildGuideChip(icon: Icons.science_outlined, text: 'Unit: $unit'),
        ],
      ),
    );
  }

  Widget _buildGuideOnFocus({
    required FocusNode focusNode,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: focusNode.hasFocus ? child : const SizedBox.shrink(),
        );
      },
    );
  }

  String _formatRangeValue(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  String? _validateNumericField(
    String? value, {
    required String field,
    required double min,
    double? max,
    required String unit,
  }) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return '$field is required';
    }

    final number = double.tryParse(input);
    if (number == null) {
      return 'Enter a valid number ($unit)';
    }

    if (number < min || (max != null && number > max)) {
      final minDisplay = _formatRangeValue(min);
      if (max == null) {
        return '$field must be at least $minDisplay $unit';
      }
      final maxDisplay = _formatRangeValue(max);
      return '$field must be between $minDisplay and $maxDisplay $unit';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _applyRainfallLevel(_selectedRainfallLevel);
  }

  void _applyRainfallLevel(String level) {
    final range = _rainfallLevels[level];
    if (range == null) {
      return;
    }
    _rainfallController.text = range.$3.toStringAsFixed(0);
  }

  String _rainfallRangeLabel(String level) {
    final range = _rainfallLevels[level];
    if (range == null) {
      return '';
    }
    return '${range.$1.toStringAsFixed(0)}-${range.$2.toStringAsFixed(0)} mm/year';
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.88),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.green[900],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.45,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _temperatureController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    _nitrogenFocusNode.dispose();
    _phosphorusFocusNode.dispose();
    _potassiumFocusNode.dispose();
    _temperatureFocusNode.dispose();
    _phFocusNode.dispose();
    super.dispose();
  }

  Future<void> _getRecommendation() async {
    final cropProvider = Provider.of<CropProvider>(context, listen: false);

    FocusScope.of(context).unfocus();
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    final data = {
      "nitrogen": double.parse(_nitrogenController.text.trim()),
      "phosphorus": double.parse(_phosphorusController.text.trim()),
      "potassium": double.parse(_potassiumController.text.trim()),
      "temperature": double.parse(_temperatureController.text.trim()),
      "ph_level": double.parse(_phController.text.trim()),
      "rainfall": double.parse(_rainfallController.text.trim()),
      "season": _selectedSeason,
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
      backgroundColor: const Color(0xFFEAF7EE),
      appBar: AppBar(
        title: const Text('Crop Recommendation'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[800]!, Colors.green[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.24),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.10),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green[800]!,
                            Colors.green[600]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.spa_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Crop Recommendation',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tune your soil and climate inputs for smarter crop suggestions.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.88),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.grass_rounded,
                                title: 'Soil Metrics',
                                value: '5 Inputs',
                                color: const Color(0xFFC8FACC),
                              ),
                              const SizedBox(width: 10),
                              _buildInfoChip(
                                icon: Icons.cloud_rounded,
                                title: 'Climate',
                                value: '2 Inputs',
                                color: const Color(0xFFE3F2FD),
                              ),
                              const SizedBox(width: 10),
                              _buildInfoChip(
                                icon: Icons.auto_awesome_rounded,
                                title: 'Result',
                                value: 'Best Crop',
                                color: const Color(0xFFFFF3C4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel(
                            'Enter Soil & Climate Data',
                            'Provide the following information to get crop recommendations.',
                          ),
                          const SizedBox(height: 22),
                          CustomTextField(
                            label: 'Nitrogen (N)',
                            controller: _nitrogenController,
                            focusNode: _nitrogenFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) => _validateNumericField(
                              value,
                              field: 'Nitrogen',
                              min: 0,
                              max: 1000,
                              unit: 'kg/ha',
                            ),
                            inputFormatters: _numericInputFormatters,
                            textInputAction: TextInputAction.next,
                          ),
                          _buildGuideOnFocus(
                            focusNode: _nitrogenFocusNode,
                            child: _buildRangeUnitGuide(
                              range: '0-1000',
                              unit: 'kg/ha',
                            ),
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            label: 'Phosphorus (P)',
                            controller: _phosphorusController,
                            focusNode: _phosphorusFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) => _validateNumericField(
                              value,
                              field: 'Phosphorus',
                              min: 5,
                              max: 1000,
                              unit: 'kg/ha',
                            ),
                            inputFormatters: _numericInputFormatters,
                            textInputAction: TextInputAction.next,
                          ),
                          _buildGuideOnFocus(
                            focusNode: _phosphorusFocusNode,
                            child: _buildRangeUnitGuide(
                              range: '0-1000',
                              unit: 'kg/ha',
                            ),
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            label: 'Potassium (K)',
                            controller: _potassiumController,
                            focusNode: _potassiumFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) => _validateNumericField(
                              value,
                              field: 'Potassium',
                              min: 0,
                              max: 1000,
                              unit: 'kg/ha',
                            ),
                            inputFormatters: _numericInputFormatters,
                            textInputAction: TextInputAction.next,
                          ),
                          _buildGuideOnFocus(
                            focusNode: _potassiumFocusNode,
                            child: _buildRangeUnitGuide(
                              range: '0-1000',
                              unit: 'kg/ha',
                            ),
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            label: 'Temperature (°C)',
                            controller: _temperatureController,
                            focusNode: _temperatureFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) => _validateNumericField(
                              value,
                              field: 'Temperature',
                              min: 0,
                              max: 50,
                              unit: '°C',
                            ),
                            inputFormatters: _numericInputFormatters,
                            textInputAction: TextInputAction.next,
                          ),
                          _buildGuideOnFocus(
                            focusNode: _temperatureFocusNode,
                            child: _buildRangeUnitGuide(range: '0-50', unit: '°C'),
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            label: 'pH Level',
                            controller: _phController,
                            focusNode: _phFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) => _validateNumericField(
                              value,
                              field: 'pH Level',
                              min: 0,
                              max: 14,
                              unit: 'pH',
                            ),
                            inputFormatters: _numericInputFormatters,
                            textInputAction: TextInputAction.next,
                          ),
                          _buildGuideOnFocus(
                            focusNode: _phFocusNode,
                            child: _buildRangeUnitGuide(range: '0-14', unit: 'pH'),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFF9FFF9),
                                  Colors.green[50]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.green[100]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedRainfallLevel,
                              decoration: const InputDecoration(
                                labelText: 'Rainfall Level',
                                border: InputBorder.none,
                              ),
                              items: _rainfallLevels.keys.map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Text(
                                    '$level (${_rainfallRangeLabel(level)})',
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _selectedRainfallLevel = value;
                                  _applyRainfallLevel(value);
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFF9FFF9),
                                  Colors.green[50]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.green[100]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedSeason,
                              decoration: const InputDecoration(
                                labelText: 'Season',
                                border: InputBorder.none,
                              ),
                              items: _seasons.map((season) {
                                return DropdownMenuItem(
                                  value: season,
                                  child: Text(season),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSeason = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                          Consumer<CropProvider>(
                            builder: (context, cropProvider, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: CustomButton(
                                  text: 'Get Recommendation',
                                  onPressed: _getRecommendation,
                                  isLoading: cropProvider.isLoading,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tip: Fill in accurate values for better crop suggestions.',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
