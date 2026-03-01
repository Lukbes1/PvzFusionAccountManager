import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pvz_fusion_acc_manager/views/helper/dialog/general_dialog.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/style/shadows.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralDialog(
      width: 450,
      height: 475,
      alignment: Alignment(0, -0.05),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            top: -15,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: SvgPicture.asset('resources/icons/x.svg'),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10, top: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GUIDE',
                  style: TextStyle(
                    fontFamily: 'PvzHeader',
                    fontSize: 28,
                    color: appLightYellow,
                  ),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  rowNum: '1.',
                  rightBoxWidget: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: const Text(
                          'Create an account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'pvz',
                            fontSize: 22,
                            color: appPurple,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -20,
                        bottom: 0,
                        child: const Text(
                          '(Right-click to edit)',
                          style: TextStyle(
                            fontFamily: 'pvz',
                            fontSize: 12,
                            color: appPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _InfoRow(
                  rowNum: '2.',
                  rightBoxWidget: const Text(
                    'Select your account',
                    style: TextStyle(
                      fontFamily: 'pvz',
                      fontSize: 22,
                      color: appPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _InfoRow(
                  rowNum: '3.',
                  rightBoxWidget: Row(
                    children: [
                      const Text(
                        'Press',
                        style: TextStyle(
                          fontFamily: 'pvz',
                          fontSize: 22,
                          color: appPurple,
                        ),
                      ),

                      const SizedBox(width: 10),
                      SvgPicture.asset(
                        'resources/icons/playGreen.svg',
                        width: 22,
                        height: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _InfoRow(
                  rowNum: '4.',
                  rightBoxWidget: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: -2,
                        child: const Text(
                          'To stop quit the game or press',
                          style: TextStyle(
                            fontFamily: 'pvz',
                            fontSize: 22,
                            color: appPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Positioned(
                        right: -15,
                        bottom: 7,
                        child: SvgPicture.asset(
                          'resources/icons/stopGreen.svg',
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Container(
                  width: 385,

                  decoration: BoxDecoration(
                    color: appNormalYellow,
                    boxShadow: [mainShadow],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'Everything has been saved\nautomatically for your next session!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pvz', // optional, if available
                      fontSize: 24,
                      color: appPurple, // dark purple text
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  '© 2026 Lukbessolutions (Lukas Beschorner and Lana Langen). This software and its source code are original works and may not be copied, modified, or used for commercial purposes without explicit permission from the authors. All characters, names, and images resembling content from the original fanmade game belong to their respective creators; this project is unofficial and not affiliated with or endorsed by them.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    color: Color(0xBBD2B25F),
                    fontStyle: FontStyle.italic,
                    fontFamily: 'pvz',
                    height: 0.75,
                    wordSpacing: 0.5,
                    fontSize: 13,
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

class _InfoRow extends StatefulWidget {
  final String rowNum;
  final Widget rightBoxWidget;
  const _InfoRow({required this.rightBoxWidget, required this.rowNum});

  @override
  State<_InfoRow> createState() => _InfoRowState();
}

class _InfoRowState extends State<_InfoRow> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: appNormalYellow,
              boxShadow: [mainShadow],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(width: 2, color: Colors.transparent),
            ),

            child: SizedBox(
              width: 35,
              height: 35,
              child: Center(
                child: Text(
                  widget.rowNum,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PvzHeader',
                    fontSize: 26,
                    color: appPurple,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: appNormalYellow,
                boxShadow: [mainShadow],
                borderRadius: BorderRadius.circular(3),
                border: Border.all(width: 2, color: Colors.transparent),
              ),
              child: widget.rightBoxWidget,
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}
