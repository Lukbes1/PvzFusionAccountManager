import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/style/text.dart';

class GeneralTextfield extends StatelessWidget {
  final TextEditingController controller;
  final bool Function() isError;
  final String errorMessage;
  final String hintMessage;
  final void Function(String value) onChanged;
  const GeneralTextfield({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isError,
    required this.errorMessage,
    required this.hintMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: 50,
      controller: controller,
      cursorColor: appWhite,
      style: purpleTextNormal,
      onChanged: (value) => onChanged(value),
      decoration: InputDecoration(
        errorText: isError() ? errorMessage : null,
        errorStyle: errorText,
        counterStyle: counterText,
        filled: true,
        fillColor: appNormalYellow,
        hintText: hintMessage,
        hintStyle: purpleTextFaded,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.transparent, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.transparent, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.transparent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: appRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: appRed, width: 2),
        ),
      ),
    );
  }
}
