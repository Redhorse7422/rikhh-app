import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final String? Function(String?)? validator;
  final bool enabled;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.validator,
    this.enabled = true,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _otp;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _otp = List.filled(widget.length, '');
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    final otpString = _otp.join('');
    widget.onChanged?.call(otpString);

    if (otpString.length == widget.length) {
      widget.onCompleted?.call(otpString);
    }
  }

  void _onDigitChanged(String value, int index) {
    if (value.length > 1) {
      // Handle paste
      final pasted = value.substring(0, widget.length);
      for (int i = 0; i < pasted.length && i < widget.length; i++) {
        _otp[i] = pasted[i];
        _controllers[i].text = pasted[i];
      }
      _onChanged();
      return;
    }

    _otp[index] = value;
    _onChanged();

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_otp[index].isEmpty && index > 0) {
          // If current field is empty and we're not at the first field,
          // move to previous field and clear it
          _focusNodes[index - 1].requestFocus();
          _otp[index - 1] = '';
          _controllers[index - 1].clear();
          _onChanged();
        } else if (_otp[index].isNotEmpty) {
          // If current field has content, clear it
          _otp[index] = '';
          _controllers[index].clear();
          _onChanged();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.length,
        (index) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AspectRatio(
              aspectRatio: 0.8, // controls box shape (wider/narrower)
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onKeyEvent(event, index),
                  child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  enabled: widget.enabled,
                  showCursor: false,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: '',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ), // ✅ add padding
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white, // Always white background
                  ),
                  style: const TextStyle(
                    fontSize: 28, // ✅ bigger font size
                    fontWeight: FontWeight.bold,
                    height: 1.2, // ✅ fix vertical alignment
                    color: Colors.black, // Always black text
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => _onDigitChanged(value, index),
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
