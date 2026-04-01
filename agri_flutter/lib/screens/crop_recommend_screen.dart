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
  final _humidityController = TextEditingController();
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _districtController = TextEditingController();
  final _nitrogenFocusNode = FocusNode();
  final _phosphorusFocusNode = FocusNode();
  final _potassiumFocusNode = FocusNode();
  final _temperatureFocusNode = FocusNode();
  final _humidityFocusNode = FocusNode();
  final _phFocusNode = FocusNode();
  final _rainfallFocusNode = FocusNode();
  final _districtFocusNode = FocusNode();
  final List<TextInputFormatter> _numericInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  ];
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  String _selectedSeason = 'Spring';
  final List<String> _seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];

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

  String? _validateDistrict(String? value) {
    final district = value?.trim() ?? '';
    if (district.isEmpty) {
      return 'District is required';
    }

    if (district.length < 2) {
      return 'District must be at least 2 characters';
    }

    if (district.length > 50) {
      return 'District must be 50 characters or less';
    }

    final pattern = RegExp(r'^[A-Za-z\s\-]+$');
    if (!pattern.hasMatch(district)) {
      return 'Use letters, spaces, and hyphens only';
    }

    return null;
  }

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    _districtController.dispose();
    _nitrogenFocusNode.dispose();
    _phosphorusFocusNode.dispose();
    _potassiumFocusNode.dispose();
    _temperatureFocusNode.dispose();
    _humidityFocusNode.dispose();
    _phFocusNode.dispose();
    _rainfallFocusNode.dispose();
    _districtFocusNode.dispose();
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
      "humidity": double.parse(_humidityController.text.trim()),
      "ph_level": double.parse(_phController.text.trim()),
      "rainfall": double.parse(_rainfallController.text.trim()),
      "district": _districtController.text.trim(),
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
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Crop Recommendation'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
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
                  focusNode: _nitrogenFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => _validateNumericField(
                    value,
                    field: 'Nitrogen',
                    min: 0,
                    max: 140,
                    unit: 'kg/ha',
                  ),
                  inputFormatters: _numericInputFormatters,
                  textInputAction: TextInputAction.next,
                ),
                _buildGuideOnFocus(
                  focusNode: _nitrogenFocusNode,
                  child: _buildRangeUnitGuide(range: '0-140', unit: 'kg/ha'),
                ),
                const SizedBox(height: 16),

                // Phosphorus
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
                    max: 145,
                    unit: 'kg/ha',
                  ),
                  inputFormatters: _numericInputFormatters,
                  textInputAction: TextInputAction.next,
                ),
                _buildGuideOnFocus(
                  focusNode: _phosphorusFocusNode,
                  child: _buildRangeUnitGuide(range: '5-145', unit: 'kg/ha'),
                ),
                const SizedBox(height: 16),

                // Potassium
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
                    min: 5,
                    max: 205,
                    unit: 'kg/ha',
                  ),
                  inputFormatters: _numericInputFormatters,
                  textInputAction: TextInputAction.next,
                ),
                _buildGuideOnFocus(
                  focusNode: _potassiumFocusNode,
                  child: _buildRangeUnitGuide(range: '5-205', unit: 'kg/ha'),
                ),
                const SizedBox(height: 16),

                // Temperature
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
                const SizedBox(height: 16),

                // Humidity
                CustomTextField(
                  label: 'Humidity (%)',
                  controller: _humidityController,
                  focusNode: _humidityFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => _validateNumericField(
                    value,
                    field: 'Humidity',
                    min: 0,
                    max: 100,
                    unit: '%',
                  ),
                  inputFormatters: _numericInputFormatters,
                  textInputAction: TextInputAction.next,
                ),
                _buildGuideOnFocus(
                  focusNode: _humidityFocusNode,
                  child: _buildRangeUnitGuide(range: '0-100', unit: '%'),
                ),
                const SizedBox(height: 16),

                // pH
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

                // Rainfall
                CustomTextField(
                  label: 'Rainfall (mm)',
                  controller: _rainfallController,
                  focusNode: _rainfallFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => _validateNumericField(
                    value,
                    field: 'Rainfall',
                    min: 0,
                    unit: 'mm/year',
                  ),
                  inputFormatters: _numericInputFormatters,
                  textInputAction: TextInputAction.next,
                ),
                _buildGuideOnFocus(
                  focusNode: _rainfallFocusNode,
                  child: _buildRangeUnitGuide(range: '>= 0', unit: 'mm/year'),
                ),
                const SizedBox(height: 16),

                // District
                CustomTextField(
                  label: 'District',
                  controller: _districtController,
                  focusNode: _districtFocusNode,
                  validator: _validateDistrict,
                  textInputAction: TextInputAction.done,
                ),
                _buildGuideOnFocus(
                  focusNode: _districtFocusNode,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: _buildGuideChip(
                      icon: Icons.location_on_outlined,
                      text: 'Letters only, 2-50 characters',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Season dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
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
      ),
    );
  }
}
