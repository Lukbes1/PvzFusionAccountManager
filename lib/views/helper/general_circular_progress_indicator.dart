import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';

class GeneralCircularProgressIndicator extends StatelessWidget {
  final String text;
  final Color? color;
  const GeneralCircularProgressIndicator({
    required this.text,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color ?? appPurple,
              fontSize: 28,
              fontFamily: 'Pvz',
            ),
          ),
          const SizedBox(height: 4),
          CircularProgressIndicator(
            color: color ?? appPurple,
            padding: EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}
