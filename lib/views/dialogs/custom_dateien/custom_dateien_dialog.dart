import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pvz_fusion_acc_manager/helper/add_icon_with_label_button.dart';
import 'package:pvz_fusion_acc_manager/helper/dialog/general_future_dialog.dart';
import 'package:pvz_fusion_acc_manager/helper/general_yellow_button.dart';
import 'package:pvz_fusion_acc_manager/helper/general_green_button.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/datei.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:pvz_fusion_acc_manager/models/provider/datei_service_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/explorer_file_service_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/profil_bild_provider.dart';
import 'package:pvz_fusion_acc_manager/models/service/datei_service.dart';
import 'package:pvz_fusion_acc_manager/models/service/explorer_file_service.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/views/account_view_middle.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/custom_dateien/custom_dateien_dialog_result.dart';

class CustomDateienDialog extends ConsumerStatefulWidget {
  final BuildContext parentContext;
  final List<Account> accounts;
  const CustomDateienDialog({
    super.key,
    required this.parentContext,
    required this.accounts,
  });

  @override
  ConsumerState<CustomDateienDialog> createState() =>
      CustomDateienDialogState();
}

class CustomDateienDialogState extends ConsumerState<CustomDateienDialog> {
  bool isLoadingFiles = false;
  Account? currentlySelectedAccount;

  @override
  Widget build(BuildContext context) {
    return GeneralFutureDialog(
      onLoadText: 'initializing',
      onInit: _onInit(ref),
      width: 350,
      height: 360,
      alignment: Alignment(0, 0.8),
      builder: (initData) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -10,
              top: -15,
              child: IconButton(
                onPressed: () => Navigator.pop(widget.parentContext, null),
                icon: SvgPicture.asset('resources/icons/x.svg'),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.fromMap({
                        WidgetState.any: appNormalYellow,
                      }),
                    ),
                    child: ListView.builder(
                      itemCount: widget.accounts.length,
                      itemBuilder: (context, index) {
                        final acc = widget.accounts[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              currentlySelectedAccount =
                                  acc == currentlySelectedAccount ? null : acc;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                              right: 17.5,
                              left: 5,
                              bottom: 10.0,
                            ),

                            child: AccountViewMiddle(
                              account: acc,
                              fontHeightLastPlayed: 0.8,
                              fontSizeName: 28,
                              profilBild: initData
                                  .profilBilderForAccounts[acc.accountId],
                              isSelected: currentlySelectedAccount == acc,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: GeneralGreenButton(
                          fixedSize: Size(150, 35),
                          widget: AddIconWithLabel(
                            text: const Text(
                              'import files',
                              style: TextStyle(
                                color: appLightYellow,
                                fontFamily: 'pvz',
                                fontSize: 22,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            final Directory? dir = await initData
                                .explorerFileService
                                .getDirFromFilePicker();
                            if (!widget.parentContext.mounted) return;
                            Navigator.pop(
                              widget.parentContext,
                              CustomDateienDialogResult(
                                dateienFromDb: <Datei>[],
                                directoryForDateienFromDisk: dir,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      GeneralYellowButton(
                        onPressed:
                            (currentlySelectedAccount != null &&
                                !isLoadingFiles)
                            ? () async {
                                setState(() => isLoadingFiles = true);
                                final result = await initData.dateiService
                                    .getAll(account: currentlySelectedAccount!);
                                if (!widget.parentContext.mounted) return;
                                Navigator.pop(
                                  widget.parentContext,
                                  CustomDateienDialogResult(
                                    dateienFromDb: result,
                                    selectedAccount: currentlySelectedAccount,
                                    directoryForDateienFromDisk: null,
                                  ),
                                );
                              }
                            : null,
                        text: isLoadingFiles ? 'Loading...' : 'Add',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<_CustomDateienInitData> _onInit(WidgetRef ref) async {
    final dateiService = await ref.read(dateiServiceProvider.future);
    final explorerFileService = ref.read(explorerFileServiceProvider);
    final profilBildForAccount = await ref.read(
      profilBildForAccountProvider.future,
    );
    return _CustomDateienInitData(
      accounts: widget.accounts,
      dateiService: dateiService,
      explorerFileService: explorerFileService,
      profilBilderForAccounts: profilBildForAccount,
    );
  }
}

class _CustomDateienInitData {
  final List<Account> accounts;
  final Map<int, ProfilBild> profilBilderForAccounts;
  final DateiService dateiService;
  final ExplorerFileService explorerFileService;

  const _CustomDateienInitData({
    required this.accounts,
    required this.profilBilderForAccounts,
    required this.dateiService,
    required this.explorerFileService,
  });
}
