import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pvz_fusion_acc_manager/helper/dialog/general_future_dialog.dart';
import 'package:pvz_fusion_acc_manager/helper/general_yellow_button.dart';
import 'package:pvz_fusion_acc_manager/helper/general_textfield.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/profil_bild_provider.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/account_options/edit_account_dialog_result.dart';
import 'package:pvz_fusion_acc_manager/views/profilbild_list_button.dart';

class EditAccountDialog extends ConsumerStatefulWidget {
  final BuildContext parentContext;
  static const _duplicateAccountMessage = 'The account already exists!';
  final String currentName;
  final int currentProfilBildIndex;
  const EditAccountDialog({
    required this.parentContext,
    required this.currentName,
    required this.currentProfilBildIndex,
    super.key,
  });

  @override
  ConsumerState<EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends ConsumerState<EditAccountDialog> {
  late final TextEditingController controller;
  bool duplicateAccount = false;
  int? selectedProfilBildId;
  @override
  void initState() {
    controller = TextEditingController(text: widget.currentName);
    selectedProfilBildId = widget.currentProfilBildIndex;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<_EditAccountDialogInitData> _onInit(WidgetRef ref) async {
    final List<ProfilBild> profilBilder = await ref.read(
      profilBilderProvider.future,
    );
    final List<Account> accounts = await ref.read(accountsProvider.future);
    return _EditAccountDialogInitData(
      profilBilder: profilBilder,
      accounts: accounts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GeneralFutureDialog<_EditAccountDialogInitData>(
      onLoadText: 'initializing...',
      onInit: _onInit(ref),
      width: 425,
      height: 350,
      alignment: Alignment(0, -0.15),
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
              errorMessage: EditAccountDialog._duplicateAccountMessage,
              hintMessage: 'Your Name',
              onChanged: (value) {
                setState(() {
                  duplicateAccount = false; // reset error state
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GeneralYellowButton(
                    onPressed: () => Navigator.pop(
                      widget.parentContext,
                      EditAccountDialogResult(
                        newName: null,
                        newProfilBildId: null,
                      ),
                    ),
                    text: 'Cancel',
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 175, maxWidth: 175),
                    child: GeneralYellowButton(
                      onPressed:
                          (controller.text.isNotEmpty &&
                              selectedProfilBildId != null)
                          ? () {
                              if (!initData.accounts.any(
                                (acc) =>
                                    acc.name == controller.text &&
                                    acc.name != widget.currentName,
                              )) {
                                Navigator.pop(
                                  widget.parentContext,
                                  EditAccountDialogResult(
                                    newName:
                                        controller.text == widget.currentName
                                        ? null
                                        : controller.text,
                                    newProfilBildId:
                                        selectedProfilBildId ==
                                            widget.currentProfilBildIndex
                                        ? null
                                        : selectedProfilBildId,
                                  ),
                                );
                              } else {
                                setState(() {
                                  duplicateAccount = true;
                                });
                              }
                            }
                          : null,
                      text: 'Save',
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
}

class _EditAccountDialogInitData {
  final List<ProfilBild> profilBilder;
  final List<Account> accounts;

  const _EditAccountDialogInitData({
    required this.profilBilder,
    required this.accounts,
  });
}
