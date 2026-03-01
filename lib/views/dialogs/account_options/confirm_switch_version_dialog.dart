import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/helper/dialog/general_dialog.dart';
import 'package:pvz_fusion_acc_manager/helper/general_yellow_button.dart';
import 'package:pvz_fusion_acc_manager/models/data/version.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/style/shadows.dart';

class ConfirmSwitchVersionDialog extends StatelessWidget {
  final BuildContext parentContext;
  final Version switchingToVersion;
  final int killingVersionsAmount;
  const ConfirmSwitchVersionDialog({
    required this.parentContext,
    required this.switchingToVersion,
    required this.killingVersionsAmount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GeneralDialog(
      width: 450,
      height: 245,
      alignment: Alignment(0, -0.275),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            'Do you really want to switch to',
            style: TextStyle(fontFamily: 'pvz', fontSize: 28, color: appWhite),
          ),
          const SizedBox(height: 5),
          Text(
            switchingToVersion.playedOnFormatted,
            style: const TextStyle(
              fontFamily: 'pvz',
              fontSize: 30,
              overflow: TextOverflow.ellipsis,
              color: appLightOrange,
            ),
          ),
          Text(
            textAlign: TextAlign.center,
            'This deletes ALL newer Versions\n above this version! (total: $killingVersionsAmount)',
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
                    onPressed: () => Navigator.pop(parentContext, true),
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
                        'Switch permanently',
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
