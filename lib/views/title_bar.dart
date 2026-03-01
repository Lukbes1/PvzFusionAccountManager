import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends ConsumerWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onPanStart: (details) => WindowManager.instance.startDragging(),
      child: Container(
        color: appGreen,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('resources/icons/appicon.png', height: 35),
            ),
            const Text(
              'PVZFusionAccountManager',
              style: TextStyle(
                color: appNormalYellow,
                fontFamily: 'pvz',
                fontSize: 18,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(0),
                          ),
                        ),

                        backgroundColor: const WidgetStateColor.fromMap({
                          WidgetState.focused: Color(0xFF5E864E),
                          WidgetState.hovered: Color(0xFF5E864E),
                          WidgetState.any: Colors.transparent,
                        }),
                        iconColor: const WidgetStatePropertyAll(
                          appNormalYellow,
                        ),
                      ),
                      onPressed: () async =>
                          await WindowManager.instance.minimize(),
                      icon: Builder(
                        builder: (context) {
                          final color = IconTheme.of(context).color;
                          return SvgPicture.asset(
                            'resources/icons/minimize_window.svg',
                            colorFilter: ColorFilter.mode(
                              color ?? appNormalYellow,
                              BlendMode.srcIn,
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      iconSize: 40,
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(0),
                          ),
                        ),

                        backgroundColor: const WidgetStateColor.fromMap({
                          WidgetState.focused: Color(0xFF5E864E),
                          WidgetState.hovered: Color(0xFF5E864E),
                          WidgetState.any: Colors.transparent,
                        }),
                        iconColor: const WidgetStateColor.fromMap({
                          WidgetState.hovered: appRed,
                          WidgetState.any: appNormalYellow,
                        }),
                      ),
                      onPressed: () async => WindowManager.instance.close(),
                      icon: Builder(
                        builder: (context) {
                          final color = IconTheme.of(context).color;
                          return SvgPicture.asset(
                            'resources/icons/close_window.svg',
                            colorFilter: ColorFilter.mode(
                              color ?? appNormalYellow,
                              BlendMode.srcIn,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
