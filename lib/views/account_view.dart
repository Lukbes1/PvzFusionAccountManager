import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart';
import 'package:pvz_fusion_acc_manager/views/helper/general_svg_hover_icon_button.dart';
import 'package:pvz_fusion_acc_manager/views/helper/top_shadow_wrapper.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/datei.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:pvz_fusion_acc_manager/models/data/version.dart';
import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/datei_service_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/explorer_file_service_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/profil_bild_provider.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/views/account_view_middle.dart';
import 'package:pvz_fusion_acc_manager/views/accounts_view.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/account_options/delete_account_dialog.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/account_options/edit_account_dialog_result.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/account_options/options_dialog.dart';
import 'package:pvz_fusion_acc_manager/views/ingame_gate.dart';
import 'package:pvz_fusion_acc_manager/views/toasts/error_toast.dart';
import 'package:pvz_fusion_acc_manager/views/toasts/success_toast.dart';
import 'package:zentoast/zentoast.dart';

class AccountView extends ConsumerStatefulWidget {
  final bool preventRightClick;
  final bool withTrashcan;
  final BorderRadius? outerRadius;
  final Account account;
  final ProfilBild? profilBild;
  final VoidCallback? onTap;
  final VoidCallback? onRightClick;

  const AccountView({
    this.preventRightClick = false,
    this.withTrashcan = false,
    this.outerRadius,
    required this.account,
    required this.profilBild,
    required this.onTap,
    this.onRightClick,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AccountViewState();
  }
}

class _AccountViewState extends ConsumerState<AccountView> {
  final WidgetStateProperty<Color> borderColors = WidgetStateColor.fromMap({
    WidgetState.selected: const Color(0xFFCE7936),
    WidgetState.pressed: const Color(0xFFCE7936),
    WidgetState.hovered: const Color(0xFFD2B25F),
    WidgetState.focused: const Color(0xFFD2B25F),
    WidgetState.any: appGreenBorder,
  });
  WidgetStatesConstraint currentState = WidgetState.any;

  final WidgetStatesController inkStatesController = WidgetStatesController();

  @override
  void dispose() {
    inkStatesController.dispose();
    super.dispose();
  }

  Future<void> _handleOptionEdit(BuildContext context) async {
    final EditAccountDialogResult? editResult = await showEditDialog(
      context: context,
      currentName: widget.account.name,
      currentProfilBildIndex: widget.profilBild?.profilBildId ?? 0,
    );
    if (editResult == null) {
      return;
    }
    if (editResult.newName != null) {
      await ref
          .read(accountsProvider.notifier)
          .updateName(
            accountToUpdate: widget.account,
            newName: editResult.newName!,
          );
    }
    if (editResult.newProfilBildId != null) {
      await ref
          .read(accountsProvider.notifier)
          .updateProfilBild(
            accountToUpdate: widget.account,
            newProfilbildId: editResult.newProfilBildId!,
          );
    }
  }

  Future<void> _handleOptionShowHistory(BuildContext context) async {
    final Version? newVersion = await showVersionHistory(
      context: context,
      currProfilBild: widget.profilBild!,
      currAcount: widget.account,
    );
    if (newVersion == null) {
      return;
    }
    await ref
        .read(accountsProvider.notifier)
        .switchToVersion(
          accountId: widget.account.accountId,
          newVersion: newVersion,
        );
  }

  Future<void> _handleOptionBackup(BuildContext context) async {
    final dateiService = await ref.read(dateiServiceProvider.future);
    final explorerFileService = ref.read(explorerFileServiceProvider);
    final selectedDirectory = await explorerFileService.getDirFromFilePicker(
      dialogTitle: 'Select a folder to save to',
    );
    if (selectedDirectory != null) {
      final List<Datei> allDateien = await dateiService.getAll(
        account: widget.account,
      );
      if (!context.mounted) {
        return;
      }
      if (allDateien.isEmpty) {
        Toast(
          height: 72,
          builder: (toast) =>
              ErrorToast(text: 'The account has no data!', toast: toast),
        ).show(context);
      } else {
        final Directory newDir = Directory(
          join(selectedDirectory.path, widget.account.name),
        );
        final whereToSaveDirectory = await newDir.create();
        await explorerFileService.writeToPvzFusionData(
          whereToSaveDirectory,
          allDateien,
        );
        if (!context.mounted) {
          return;
        }
        Toast(
          height: 72,
          builder: (toast) => SuccessToast(
            text: 'Saved to: ${whereToSaveDirectory.path}',
            toast: toast,
          ),
        ).show(context);
      }
    }
  }

  Future<void> _onRightClick(BuildContext context) async {
    final RenderBox thisRenderObj = context.findRenderObject() as RenderBox;
    final Offset startPosTopLeft = thisRenderObj.localToGlobal(Offset.zero);
    final profilBildForAccount = (await ref.read(
      profilBildForAccountProvider.future,
    ))[widget.account.accountId];
    if (!context.mounted) {
      return;
    }
    final Option? option = await showOptionsDialog(
      context: context,
      startPosTopLeft: startPosTopLeft,
      accountViewSize: thisRenderObj.size,
      profilBild: profilBildForAccount,
      account: widget.account,
    );

    if (!context.mounted) {
      return;
    }
    switch (option) {
      case null:
        return;
      case Option.edit:
        await _handleOptionEdit(context);
      case Option.showHistory:
        await _handleOptionShowHistory(context);
      case Option.backup:
        await _handleOptionBackup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentlySelected = ref.watch(currentlySelectedAccountProvider);
    final isSelected = widget.account.accountId == currentlySelected?.accountId;
    if (isSelected) {
      inkStatesController.value.add(WidgetState.selected);
    } else {
      inkStatesController.value.remove(WidgetState.selected);
    }

    return InGameGate(
      child: Material(
        clipBehavior: Clip.none,
        color: Colors.transparent,
        child: InkWell(
          statesController: inkStatesController,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.transparent),
          ),
          overlayColor: WidgetStateColor.fromMap({
            WidgetState.any: Colors.transparent,
          }),
          onTap: widget.onTap,
          onSecondaryTap: !widget.preventRightClick
              ? () async => await _onRightClick(context)
              : null,

          splashColor: Colors.transparent,
          child: ValueListenableBuilder(
            valueListenable: inkStatesController,
            builder: (context, value, child) {
              final borderColor = widget.preventRightClick
                  ? appGreenBorder
                  : borderColors.resolve(value);

              return Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius:
                        widget.outerRadius ?? BorderRadius.circular(14),
                    color: appGreen,
                    border: BoxBorder.all(color: borderColor, width: 5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(80, 0, 0, 0),
                        blurRadius: 2,
                        spreadRadius: 1,
                        offset: Offset(-4, 5), // pushed downward
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
            child: TopShadowWrapper(
              circleRadius: 12,
              childContainerHeight: 90,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 10.0,
                        top: 8,
                        bottom: 8,
                        right: widget.withTrashcan ? 0 : 15.0,
                      ),
                      child: AccountViewMiddle(
                        account: widget.account,
                        profilBild: widget.profilBild,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.withTrashcan,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 10.0,
                        bottom: 10,
                      ),
                      child: SizedBox(
                        width: 74,
                        height: 74,
                        child: Center(
                          child: GeneralSvgHoverIconButton(
                            icon: SvgPicture.asset(
                              'resources/icons/delete.svg',
                              width: 60,
                              height: 60,
                            ),
                            iconHovered: SvgPicture.asset(
                              'resources/icons/deleteRed.svg',
                              width: 60,
                              height: 60,
                            ),
                            onPressed: () async {
                              final isDeleted = await _showDeleteDialog(
                                context,
                                widget.account.name,
                              );
                              if (isDeleted) {
                                ref
                                    .read(accountsProvider.notifier)
                                    .delete(widget.account.accountId);
                                ref
                                    .read(
                                      currentlySelectedAccountProvider.notifier,
                                    )
                                    .clear();

                                ref
                                    .read(profilBildForAccountProvider.notifier)
                                    .remove(
                                      accountId: widget.account.accountId,
                                    );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(
    BuildContext context,
    String accountName,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return DeleteAccountDialog(
          parentContext: context,
          accountName: accountName,
        );
      },
    ).then((value) => value ?? false);
  }
}
