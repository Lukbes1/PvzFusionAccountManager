import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pvz_fusion_acc_manager/helper/dialog/general_future_dialog.dart';
import 'package:pvz_fusion_acc_manager/helper/general_yellow_button.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:pvz_fusion_acc_manager/models/data/version.dart';
import 'package:pvz_fusion_acc_manager/models/provider/versions_provider.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/views/account_view_middle.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/account_options/confirm_switch_version_dialog.dart';

class VersionHistoryDialog extends ConsumerStatefulWidget {
  final BuildContext parentContext;
  final Account currentAccount;
  final ProfilBild currentProfilbild;
  const VersionHistoryDialog({
    required this.parentContext,
    required this.currentAccount,
    required this.currentProfilbild,
    super.key,
  });

  @override
  ConsumerState<VersionHistoryDialog> createState() =>
      _VersionHistoryDialogState();
}

class _VersionHistoryDialogState extends ConsumerState<VersionHistoryDialog> {
  Version? selectedVersion;

  Future<_VersionHistoryDialogInitData> _onInit() async {
    final versionsService = await ref.read(versionsServiceProvider.future);
    final lastFiveVersions = await versionsService.getAllXForAccount(
      accountId: widget.currentAccount.accountId,
      lastVersionsAmount: 5,
    );
    return _VersionHistoryDialogInitData(
      lastFiveVersions: lastFiveVersions,
      initialVersion: lastFiveVersions.isNotEmpty ? lastFiveVersions[0] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GeneralFutureDialog<_VersionHistoryDialogInitData>(
      onLoadText: 'initializing history...',
      onInit: _onInit(),
      width: 450,
      height: 450,
      alignment: Alignment(0, 0.15),
      builder: (initData) {
        selectedVersion ??= initData.lastFiveVersions.isNotEmpty
            ? initData.lastFiveVersions[0]
            : null;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -10,
              top: -15,
              child: IconButton(
                onPressed: () => Navigator.pop(context, null),
                icon: SvgPicture.asset('resources/icons/x.svg'),
              ),
            ),

            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT',
                    style: TextStyle(
                      fontFamily: 'pvzheader',
                      fontSize: 26,
                      color: appLightYellow,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 60.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 100,
                        maxWidth: 350,
                      ),
                      child: AccountViewMiddle(
                        profilBild: widget.currentProfilbild,
                        account: widget.currentAccount,
                        isSelected: false,
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  const Text(
                    'PREVIOUS SAVES',
                    style: TextStyle(
                      fontFamily: 'PvzHeader',
                      fontSize: 22,
                      color: appLightYellow,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: ListView(
                      children: initData.lastFiveVersions.map((version) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5, top: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              height: 35,
                              width: 350,
                              child: _HistoryButton(
                                isSelected: selectedVersion == version,
                                version: version,
                                onPressed: () {
                                  setState(() {
                                    if (selectedVersion == version) {
                                      selectedVersion = null;
                                      return;
                                    }
                                    selectedVersion = version;
                                  });
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2.0,
                      horizontal: 125.0,
                    ),
                    child: GeneralYellowButton(
                      onPressed: selectedVersion != null
                          ? () async {
                              final killedVersionsAmount =
                                  (initData.lastFiveVersions.indexOf(
                                    selectedVersion!,
                                  ) +
                                  1);
                              final bool confirmed =
                                  await _showConfirmChangeVersionDialog(
                                    context: context,
                                    switchingToVersion: selectedVersion!,
                                    killingVersionsAmount: killedVersionsAmount,
                                  );
                              if (!context.mounted) {
                                return;
                              }
                              if (confirmed) {
                                Navigator.pop(context, selectedVersion);
                              }
                            }
                          : null,
                      text: 'Switch',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmChangeVersionDialog({
    required final BuildContext context,
    required final Version switchingToVersion,
    required final int killingVersionsAmount,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return ConfirmSwitchVersionDialog(
          parentContext: context,
          switchingToVersion: switchingToVersion,
          killingVersionsAmount: killingVersionsAmount,
        );
      },
    ).then((value) => value ?? false);
  }
}

class _VersionHistoryDialogInitData {
  final List<Version> lastFiveVersions;
  final Version? initialVersion;

  _VersionHistoryDialogInitData({
    required this.lastFiveVersions,
    this.initialVersion,
  });
}

class _HistoryButton extends StatelessWidget {
  final bool isSelected;
  final Version version;
  final VoidCallback onPressed;

  const _HistoryButton({
    required this.version,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.only(left: 12.0)),
        backgroundColor: WidgetStatePropertyAll(appNormalYellow),
        shape: WidgetStateOutlinedBorder.resolveWith((states) {
          if (isSelected) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: const Color(0xFFCE7936), width: 4),
            );
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: const Color(0xFFB7994B), width: 4),
            );
          }

          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: Colors.transparent, width: 0),
          );
        }),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          textAlign: TextAlign.start,
          'last played ${version.playedOnFormatted}',
          style: const TextStyle(
            color: appPurple,
            fontSize: 18,
            fontFamily: 'Pvz',
          ),
        ),
      ),
    );
  }
}
