import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../core/theme/app_colors.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final VoidCallback? onChanged;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.labelText = 'Phone Number',
    this.hintText,
    this.validator,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  static const String _countryCode = '+91';
  late TextEditingController _displayController;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController();
    
    // Initialize with +91 if controller is empty
    if (widget.controller.text.isEmpty) {
      widget.controller.text = _countryCode;
      _displayController.text = _countryCode;
    } else {
      _displayController.text = widget.controller.text;
    }
    
    // Listen to controller changes
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _displayController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.controller.text != _displayController.text) {
      _displayController.text = widget.controller.text;
    }
  }

  void _onTextChanged(String value) {
    // Always ensure +91 is at the start
    if (!value.startsWith(_countryCode)) {
      if (value.isEmpty) {
        value = _countryCode;
      } else if (value.startsWith('+9')) {
        value = _countryCode + value.substring(2);
      } else if (value.startsWith('91')) {
        value = _countryCode + value.substring(2);
      } else if (value.startsWith('+')) {
        value = _countryCode + value.substring(1);
      } else {
        value = _countryCode + value;
      }
    }

    // Limit to 13 characters (+91 + 10 digits)
    if (value.length > 13) {
      value = value.substring(0, 13);
    }

    // Update both controllers
    _displayController.text = value;
    widget.controller.text = value;
    
    // Call onChanged callback
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _displayController,
      keyboardType: TextInputType.phone,
      enabled: widget.enabled,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
        LengthLimitingTextInputFormatter(13), // +91 + 10 digits
      ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText ?? '+919876543210',
        prefixIcon: const Icon(
          Feather.phone,
          color: AppColors.body,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
      validator: widget.validator ?? _defaultValidator,
      onChanged: _onTextChanged,
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    // Basic Indian phone number validation
    if (!RegExp(r'^\+91[6-9]\d{9}$').hasMatch(value)) {
      return 'Please enter a valid Indian phone number (+91XXXXXXXXXX)';
    }
    return null;
  }
}
