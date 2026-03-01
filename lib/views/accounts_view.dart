import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pvz_fusion_acc_manager/helper/general_circular_progress_indicator.dart';
import 'package:pvz_fusion_acc_manager/models/data/version.dart';
import 'package:pvz_fusion_acc_manager/models/provider/startup_files_provider.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:pvz_fusion_acc_manager/models/provider/profil_bild_provider.dart';
import 'package:pvz_fusion_acc_manager/views/account_view.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/account_options/edit_account_dialog.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/account_options/edit_account_dialog_result.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/account_options/options_dialog.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/account_options/version_history_dialog.dart';

class AccountsView extends ConsumerWidget {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final profilBilderAsync = ref.watch(profilBildForAccountProvider);
    final startupFilesAsync = ref.watch(startupFilesProvider);

    return startupFilesAsync.when(
      data: (data) {
        return accountsAsync.when(
          loading: () =>
              GeneralCircularProgressIndicator(text: 'loading accounts...'),
          error: (e, _) => Center(
            child: Text(
              textAlign: TextAlign.center,
              "${e.toString()}.\nPlease refresh",
              style: TextStyle(
                fontSize: 35,
                fontFamily: 'Pvz',
                color: appPurple,
              ),
            ),
          ),
          data: (list) {
            return profilBilderAsync.when(
              loading: () =>
                  GeneralCircularProgressIndicator(text: 'loading images...'),
              error: (e, _) => Center(
                child: Text(
                  textAlign: TextAlign.center,
                  'Error loading profile images: $e.\nPlease refresh',
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Pvz',
                    color: appPurple,
                  ),
                ),
              ),

              data: (profilMap) => ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final account = list[index];
                  final profilBild = profilMap[account.accountId];

                  return AccountView(
                    account: account,
                    profilBild: profilBild,
                    onTap: () {
                      ref
                          .read(currentlySelectedAccountProvider.notifier)
                          .set(account);
                    },
                  );
                },
              ),
            );
          },
        );
      },
      error: (e, _) => Center(
        child: Text(
          textAlign: TextAlign.center,
          'Error loading startup files: $e.\nPlease restart the app',
          style: TextStyle(fontSize: 35, fontFamily: 'Pvz', color: appPurple),
        ),
      ),
      loading: () => GeneralCircularProgressIndicator(
        text: 'Loading Startup files...\n This might take up to 30 seconds',
      ),
    );
  }
}

Future<EditAccountDialogResult?> showEditDialog({
  required BuildContext context,
  required final String currentName,
  required final int currentProfilBildIndex,
}) async {
  return showDialog<EditAccountDialogResult>(
    context: context,
    builder: (context) {
      return EditAccountDialog(
        parentContext: context,
        currentName: currentName,
        currentProfilBildIndex: currentProfilBildIndex,
      );
    },
  );
}

Future<Version?> showVersionHistory({
  required final BuildContext context,
  required final Account currAcount,
  required final ProfilBild currProfilBild,
}) {
  return showDialog<Version?>(
    context: context,
    builder: (context) {
      return VersionHistoryDialog(
        parentContext: context,
        currentAccount: currAcount,
        currentProfilbild: currProfilBild,
      );
    },
  );
}

Future<Option?> showOptionsDialog({
  required final BuildContext context,
  required final Offset startPosTopLeft,
  required final Account account,
  required final ProfilBild? profilBild,
  required final Size accountViewSize,
}) {
  return showDialog<Option>(
    context: context,
    builder: (dialogContext) {
      return OptionsDialog(
        parentContext: context,
        startPosTopLeft: startPosTopLeft,
        account: account,
        profilBild: profilBild,
        accountViewSize: accountViewSize,
      );
    },
  );
}
