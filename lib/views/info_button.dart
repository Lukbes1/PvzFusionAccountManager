import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/style/text.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/info/info_dialog.dart';

class InfoButton extends StatelessWidget {
  const InfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: const ButtonStyle(
        backgroundColor: WidgetStateColor.fromMap({WidgetState.any: appGreen}),
        shape: WidgetStateOutlinedBorder.fromMap({
          WidgetState.pressed: CircleBorder(
            side: BorderSide(color: Color(0xFFCE7936), width: 5),
          ),
          WidgetState.hovered: CircleBorder(
            side: BorderSide(color: Color(0xFFD2B25F), width: 5),
          ),
          WidgetState.focused: CircleBorder(
            side: BorderSide(color: Color(0xFFD2B25F), width: 5),
          ),
          WidgetState.any: CircleBorder(
            side: BorderSide(color: appGreenBorder, width: 5),
          ),
        }),
        padding: WidgetStatePropertyAll(EdgeInsets.all(3)),
        elevation: WidgetStatePropertyAll(10),
      ),
      onPressed: () => showInfoDialog(context),
      child: Center(
        child: Text('?', style: normalYellowNormal.copyWith(fontSize: 28)),
      ),
    );
  }
}

Future<void> showInfoDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return InfoDialog();
    },
  );
}
