import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Simple Custom TextField Widget
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final String? helperText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool enabled;
  final bool? enableInteractiveSelection;
  final bool? showCursor;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.helperText,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.readOnly = false,
    this.enabled = true,
    this.enableInteractiveSelection,
    this.showCursor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      focusNode: focusNode,
      maxLines: maxLines,
      validator: validator,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      readOnly: readOnly,
      enabled: enabled,
      enableInteractiveSelection: enableInteractiveSelection,
      showCursor: showCursor,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
