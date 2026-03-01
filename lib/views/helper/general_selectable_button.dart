import 'package:flutter/material.dart';

///Useful, when the callside decides the selected state and just needs visuals
class GeneralSelectableButton extends StatelessWidget {
  const GeneralSelectableButton({
    super.key,
    required this.onPressed,
    required this.isSelected,
    required this.child,
    this.padding = const WidgetStatePropertyAll(EdgeInsets.zero),
    this.minimumSize = const WidgetStatePropertyAll(Size.zero),
  });

  final WidgetStateProperty<EdgeInsetsGeometry>? padding;
  final WidgetStateProperty<Size>? minimumSize;
  final VoidCallback onPressed;
  final bool isSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: padding,
        minimumSize: minimumSize,
        shape: WidgetStateOutlinedBorder.resolveWith((states) {
          if (isSelected) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: const Color(0xFFCE7936), width: 3),
            );
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: const Color(0xFFD2B25F), width: 3),
            );
          }

          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: Colors.transparent, width: 0),
          );
        }),
      ),
      child: child,
    );
  }
}
