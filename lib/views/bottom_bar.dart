import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pvz_fusion_acc_manager/views/helper/top_shadow_wrapper.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';
import 'package:pvz_fusion_acc_manager/style/text.dart';

class BottomBar extends ConsumerStatefulWidget {
  const BottomBar({super.key});

  @override
  ConsumerState<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<BottomBar> {
  @override
  Widget build(BuildContext context) {
    final currentAccount = ref.watch(currentlySelectedAccountProvider);
    final accountsNotifier = ref.read(accountsProvider.notifier);
    final isSomeonePlaying = ref.watch(isSomeonePlayingProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 10, right: 10, left: 10),
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: BoxBorder.all(color: appGreenBorder, width: 5),
          color: appGreen,
        ),
        child: TopShadowWrapper(
          childContainerHeight: 85,
          child: Row(
            children: [
              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(left: 74.0),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 225, minWidth: 225),
                  padding: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: appNormalYellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    currentAccount?.name ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: purpleTextBig,
                  ),
                ),
              ),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: !isSomeonePlaying
                    ? FittedBox(
                        child: IconButton(
                          iconSize: 85,
                          style: ButtonStyle(
                            iconColor: WidgetStateColor.fromMap({
                              WidgetState.hovered: appGreenBorder,
                              WidgetState.disabled: Color(0xFFB4A163),
                              WidgetState.any: appNormalYellow,
                            }),
                          ),
                          onPressed: currentAccount != null
                              ? () async {
                                  try {
                                    await accountsNotifier
                                        .startPlayingWithCurrent();
                                  } catch (e) {
                                    log('Error', error: e);
                                  }
                                }
                              : null,
                          icon: Builder(
                            builder: (context) {
                              final color = IconTheme.of(context).color;
                              return SvgPicture.asset(
                                'resources/icons/play.svg',
                                colorFilter: ColorFilter.mode(
                                  color ?? appNormalYellow,
                                  BlendMode.srcIn,
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    //Someones playing
                    : FittedBox(
                        child: IconButton(
                          iconSize: 85,
                          style: ButtonStyle(
                            iconColor: WidgetStateColor.fromMap({
                              WidgetState.hovered: appGreenBorder,
                              WidgetState.any: appNormalYellow,
                            }),
                          ),
                          onPressed: () async =>
                              await accountsNotifier.stopPlayingWithCurrent(),
                          icon: Builder(
                            builder: (context) {
                              final color = IconTheme.of(context).color;
                              return SvgPicture.asset(
                                'resources/icons/stop.svg',
                                colorFilter: ColorFilter.mode(
                                  color ?? appNormalYellow,
                                  BlendMode.srcIn,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
