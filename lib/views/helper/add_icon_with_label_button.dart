import 'package:flutter/material.dart';

class AddIconWithLabel extends StatelessWidget {
  final Text text;
  final Color? color;
  const AddIconWithLabel({required this.text, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_rounded, size: 28, color: color),
        text,
      ],
    );
  }
}
