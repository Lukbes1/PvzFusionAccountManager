import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';

class GeneralYellowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double fontSize;
  final double? width;
  final double? height;
  const GeneralYellowButton({
    super.key,
    this.width,
    this.height,
    this.fontSize = 20,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            blurRadius: 2,
            spreadRadius: 1,
            offset: Offset(-4, 5),
            // pushed downward
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: const WidgetStateColor.fromMap({
            WidgetState.disabled: Color(0xFFB4A163),
            WidgetState.pressed: Color(0xFFCE7936),
            WidgetState.hovered: Color(0xFFD2B25F),
            WidgetState.focused: Color(0xFFD2B25F),
            WidgetState.any: appNormalYellow,
          }),
          foregroundColor: const WidgetStateColor.fromMap({
            WidgetState.disabled: Color(0xFF5F4A56),
            WidgetState.any: appPurple,
          }),
          shape: WidgetStateOutlinedBorder.fromMap({
            WidgetState.any: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          }),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, fontFamily: 'Pvz'),
          ),
        ),
      ),
    );
  }
}
