import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/views/helper/dialog/general_dialog.dart';
import 'package:pvz_fusion_acc_manager/views/helper/general_yellow_button.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/style/shadows.dart';

class DeleteAccountDialog extends StatelessWidget {
  final BuildContext parentContext;
  final String accountName;
  const DeleteAccountDialog({
    required this.parentContext,
    required this.accountName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GeneralDialog(
      width: 450,
      height: 220,
      alignment: Alignment(0, -0.40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            'Do you really want to delete?',
            style: TextStyle(fontFamily: 'pvz', fontSize: 28, color: appWhite),
          ),
          const SizedBox(height: 5),
          Text(
            accountName,
            style: const TextStyle(
              fontFamily: 'pvz',
              fontSize: 30,
              overflow: TextOverflow.ellipsis,
              color: appLightOrange,
            ),
          ),
          const Text(
            'This cannot be undone!',
            style: TextStyle(color: appWhite, fontFamily: 'pvz', fontSize: 22),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GeneralYellowButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(parentContext),
                ),

                Container(
                  decoration: BoxDecoration(boxShadow: [mainShadow]),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        parentContext,
                        rootNavigator: true,
                      ).pop(true);

                      Navigator.of(
                        parentContext,
                        rootNavigator: true,
                      ).popUntil((route) => route.isFirst);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.fromMap({
                        WidgetState.pressed: const Color(0xFF800206),
                        WidgetState.hovered: appDarkRed,
                        WidgetState.any: appRed,
                      }),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(4),
                        ),
                      ),
                    ),
                    child: Center(
                      child: const Text(
                        'Remove permanently',
                        style: TextStyle(
                          fontFamily: 'pvz',
                          fontSize: 20,
                          color: appWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
