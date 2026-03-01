import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pvz_fusion_acc_manager/helper/add_icon_with_label_button.dart';
import 'package:pvz_fusion_acc_manager/helper/dialog/general_future_dialog.dart';
import 'package:pvz_fusion_acc_manager/helper/general_yellow_button.dart';
import 'package:pvz_fusion_acc_manager/helper/general_green_button.dart';
import 'package:pvz_fusion_acc_manager/helper/general_textfield.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/datei.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/profil_bild_provider.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/style/text.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/create_account/create_account_dialog_result.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/custom_dateien/custom_dateien_dialog.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/custom_dateien/custom_dateien_dialog_result.dart';
import 'package:pvz_fusion_acc_manager/views/profilbild_list_button.dart';
import 'package:pvz_fusion_acc_manager/views/toasts/error_toast.dart';
import 'package:zentoast/zentoast.dart';

class CreateAccountDialog extends ConsumerStatefulWidget {
  final duplicateAccountMessage = 'The account already exists!';
  final BuildContext parentContext;
  const CreateAccountDialog({super.key, required this.parentContext});

  @override
  ConsumerState<CreateAccountDialog> createState() => _CreateAccountDialog();
}

class _CreateAccountDialog extends ConsumerState<CreateAccountDialog> {
  final controller = TextEditingController();
  bool duplicateAccount = false;
  List<Datei> existingDateien = [];
  Directory? existingFiles;
  Account? selectedAccount;
  int? selectedProfilBildId;
  bool isTrashCanHovered = false;
  bool get hasSelectedCustomGameFile =>
      existingFiles != null || existingDateien.isNotEmpty;

  bool _hasFiles(Directory dir) {
    final contents = dir.listSync();
    return contents.any((entity) => entity is File);
  }

  @override
  Widget build(BuildContext context) {
    return GeneralFutureDialog<_CreateAccountInitData>(
      onLoadText: 'initializing',
      width: 425,
      height: 475,
      onInit: _onInit(ref),
      alignment: Alignment(0, 0.1),
      builder: (initData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: const Text(
                'Choose your plant',
                style: TextStyle(
                  color: appLightYellow,
                  fontFamily: 'Pvz',
                  fontSize: 24,
                ),
              ),
            ),

            SizedBox(
              height: 125,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 1, // square cells
                ),
                children: List.generate(initData.profilBilder.length, (index) {
                  final currentProfilBild = initData.profilBilder[index];
                  return ProfilbildListButton(
                    isSelected:
                        selectedProfilBildId == currentProfilBild.profilBildId,
                    profilBild: currentProfilBild,
                    onPressed: () {
                      setState(() {
                        selectedProfilBildId = currentProfilBild.profilBildId;
                      });
                    },
                  );
                }),
              ),
            ),

            GeneralTextfield(
              controller: controller,
              isError: () => duplicateAccount,
              errorMessage: widget.duplicateAccountMessage,
              hintMessage: 'Your Name',
              onChanged: (value) {
                setState(() {
                  duplicateAccount = false; // reset error state
                });
              },
            ),
            Center(
              child: GeneralGreenButton(
                borderWidth: 3,
                fixedSize: Size(225, 40),
                widget: AddIconWithLabel(
                  text: const Text('Add existing game file'),
                ),
                onPressed: hasSelectedCustomGameFile
                    ? null
                    : () async {
                        final CustomDateienDialogResult? dialogResult =
                            await getCustomDateienDialog(
                              context: context,
                              accounts: initData.accounts,
                            );
                        if (dialogResult == null) {
                          return;
                        }

                        if (dialogResult.dateienFromDb.isEmpty &&
                            (dialogResult.directoryForDateienFromDisk == null ||
                                !_hasFiles(
                                  dialogResult.directoryForDateienFromDisk!,
                                ))) {
                          if (!context.mounted) {
                            return;
                          }
                          Toast(
                            builder: (toast) => ErrorToast(
                              text: 'There were no existing files to use',
                              toast: toast,
                              fontSize: 20,
                            ),
                            height: 72,
                          ).show(context);
                          return;
                        }
                        setState(() {
                          existingDateien = dialogResult.dateienFromDb;
                          existingFiles =
                              dialogResult.directoryForDateienFromDisk;
                          selectedAccount = dialogResult.selectedAccount;
                        });
                      },
              ),
            ),
            Expanded(child: SizedBox(height: 15)),
            Visibility(
              visible: hasSelectedCustomGameFile,
              child: Padding(
                padding: const EdgeInsets.only(left: 25, bottom: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: 200,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: appNormalYellow,
                        ),
                        child: Center(
                          child: Text(
                            selectedAccount == null
                                ? 'Custom Gamefile'
                                : selectedAccount!.name,
                            style: purpleTextSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    MouseRegion(
                      onExit: (event) {
                        setState(() {
                          isTrashCanHovered = false;
                        });
                      },
                      onHover: (event) {
                        setState(() {
                          isTrashCanHovered = true;
                        });
                      },
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: isTrashCanHovered
                              ? SvgPicture.asset(
                                  'resources/icons/deleteRed.svg',
                                )
                              : SvgPicture.asset('resources/icons/delete.svg'),
                          onPressed: () {
                            setState(() {
                              isTrashCanHovered = false;
                              existingFiles = null;
                              existingDateien = [];
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GeneralYellowButton(
                    onPressed: () => Navigator.pop(widget.parentContext),
                    text: 'Cancel',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GeneralYellowButton(
                    onPressed:
                        controller.text.isNotEmpty &&
                            selectedProfilBildId != null
                        ? () {
                            if (!initData.accounts.any(
                              (acc) => acc.name == controller.text,
                            )) {
                              Navigator.pop(
                                widget.parentContext,
                                CreateAccountDialogResult(
                                  name: controller.text,
                                  profilBildId: selectedProfilBildId!,
                                  existingAccountFiles: existingDateien,
                                  customFiles: existingFiles,
                                ),
                              );
                            } else {
                              setState(() {
                                duplicateAccount = true;
                              });
                            }
                          }
                        : null,
                    text: 'Create account',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<_CreateAccountInitData> _onInit(WidgetRef ref) async {
    final accountsNotifier = ref.read(accountsProvider.notifier);

    var accounts = await accountsNotifier.getAllCached();

    if (accounts.isEmpty) {
      await accountsNotifier.load();
      accounts = await accountsNotifier.getAllCached();
    }
    final profilBilder = await ref.read(profilBilderProvider.future);

    return _CreateAccountInitData(
      accounts: accounts,
      profilBilder: profilBilder,
    );
  }
}

class _CreateAccountInitData {
  final List<Account> accounts;
  final List<ProfilBild> profilBilder;

  const _CreateAccountInitData({
    required this.accounts,
    required this.profilBilder,
  });
}

Future<CustomDateienDialogResult?> getCustomDateienDialog({
  required BuildContext context,
  required final List<Account> accounts,
}) async {
  final dateien = await showDialog<CustomDateienDialogResult>(
    context: context,
    builder: (context) =>
        CustomDateienDialog(parentContext: context, accounts: accounts),
  );
  return dateien;
}
