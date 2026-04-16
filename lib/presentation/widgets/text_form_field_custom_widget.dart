import 'package:flutter/material.dart';

class TextFormFieldCustomWidget extends StatelessWidget {
  const TextFormFieldCustomWidget({
    super.key,
    required this.controller,
    required this.validator,
    this.enabled = true,
    required this.labelText,
    required this.hintText,
    this.textCapitalization = TextCapitalization.words,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onFieldSubmitted,
    required this.focusedBorderColor,
  });

  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool enabled;
  final String labelText;
  final String hintText;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final int maxLines;
  final void Function(String)? onFieldSubmitted;
  final Color focusedBorderColor;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      maxLines: maxLines,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        floatingLabelStyle: TextStyle(
          color: focusedBorderColor, 
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: focusedBorderColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: cs.outline),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      validator: validator,
    );
  }
}