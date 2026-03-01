import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pvz_fusion_acc_manager/views/helper/general_green_button.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/views/account_view.dart';

enum Option { edit, showHistory, backup }

class OptionsDialog extends ConsumerWidget {
  final BuildContext parentContext;
  static const _boxWidthOffset = 88.5;
  static const _boxHeightOffset = 40.5;
  static const _boxWidth = OptionsDialog._boxWidthOffset + 32;
  static const _spacerHeight = 5.0;
  static const _amountOfSpacers = 2;
  static const _boxHeight =
      OptionsDialog._boxHeightOffset + 64 + _amountOfSpacers * _spacerHeight;
  static const _amountBoxElements = 3;
  static const _boxElementHeight =
      (_boxHeight - _amountOfSpacers * _spacerHeight) / _amountBoxElements;
  final Offset startPosTopLeft;
  final Account account;
  final ProfilBild? profilBild;
  final Size accountViewSize;
  const OptionsDialog({
    required this.parentContext,
    required this.startPosTopLeft,
    required this.account,
    required this.profilBild,
    required this.accountViewSize,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: _boxHeightOffset,
      width: _boxWidthOffset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: startPosTopLeft.dx,
            top: startPosTopLeft.dy,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: accountViewSize.height,
                maxWidth: accountViewSize.width,
              ),
              child: AccountView(
                withTrashcan: true,
                outerRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                preventRightClick: true,
                account: account,
                profilBild: profilBild,
                onTap: null,
                onRightClick: null,
              ),
            ),
          ),
          Positioned(
            left:
                startPosTopLeft.dx +
                accountViewSize.width / 2 +
                _boxWidthOffset,
            top:
                startPosTopLeft.dy +
                accountViewSize.height / 2 +
                _boxHeightOffset,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: appGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: appGreenBorder, width: 5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(80, 0, 0, 0),
                      blurRadius: 2,
                      spreadRadius: 1,
                      offset: Offset(-4, 5),
                      // pushed downward
                    ),
                  ],
                ),
                child: SizedBox(
                  width: _boxWidth,
                  height: _boxHeight,
                  child: Column(
                    spacing: 0,
                    children: [
                      GeneralGreenButton(
                        withShadows: false,
                        noBorderDefault: true,
                        padding: EdgeInsetsGeometry.zero,
                        borderRadius: BorderRadius.zero,
                        fixedSize: const Size(_boxWidth, _boxElementHeight),
                        widget: Center(
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(4),
                            child: const Text(
                              textAlign: TextAlign.center,
                              'EDIT',
                              style: TextStyle(
                                fontFamily: 'pvzHeader',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pop(parentContext, Option.edit),
                      ),
                      Container(color: appGreenBorder, height: _spacerHeight),
                      GeneralGreenButton(
                        withShadows: false,
                        noBorderDefault: true,
                        padding: EdgeInsetsGeometry.zero,
                        borderRadius: BorderRadius.zero,
                        borderWidth: 5,
                        fixedSize: const Size(_boxWidth, _boxElementHeight),
                        widget: Center(
                          child: const Text(
                            'PREVIOUS SAVES',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'pvzHeader',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pop(parentContext, Option.showHistory),
                      ),
                      Container(color: appGreenBorder, height: _spacerHeight),
                      GeneralGreenButton(
                        withShadows: false,
                        noBorderDefault: true,
                        padding: EdgeInsetsGeometry.zero,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        fixedSize: const Size(_boxWidth, _boxElementHeight),
                        widget: Center(
                          child: const Text(
                            'BACKUP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'pvzHeader',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, Option.backup),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
