import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pvz_fusion_acc_manager/views/helper/general_green_button.dart';
import 'package:pvz_fusion_acc_manager/views/helper/general_svg_hover_icon_button.dart';
import 'package:pvz_fusion_acc_manager/views/helper/top_shadow_wrapper.dart';
import 'package:pvz_fusion_acc_manager/models/provider/startup_files_provider.dart';
import 'package:pvz_fusion_acc_manager/style/shadows.dart';
import 'package:pvz_fusion_acc_manager/views/accounts_view.dart';
import 'package:pvz_fusion_acc_manager/views/bottom_bar.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';
import 'package:pvz_fusion_acc_manager/style/text.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/create_account/create_account_dialog.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/create_account/create_account_dialog_result.dart';
import 'package:pvz_fusion_acc_manager/views/dialogs/startup_files_blocker_dialog.dart';
import 'package:pvz_fusion_acc_manager/views/info_button.dart';
import 'package:pvz_fusion_acc_manager/views/ingame_gate.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen(startupFilesProvider, (previous, next) {
      if (next.hasError && next.error is StartupFileException) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showStartupFilesBlocker(context: context);
        });
      }
    });
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 7.5,
              left: 30.0,
              right: 30.0,
            ),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [mainShadow],
                color: appGreen,
                border: Border.all(color: appGreenBorder, width: 5),
              ),
              child: TopShadowWrapper(
                childContainerHeight: 50,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: const Text('Account-Manager', style: lightYellowBig),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InGameGate(
              child: GeneralSvgHoverIconButton(
                icon: SvgPicture.asset(
                  'resources/icons/settings.svg',
                  width: 40,
                  height: 40,
                ),
                iconHovered: SvgPicture.asset(
                  'resources/icons/settings_hovered.svg',
                  width: 40,
                  height: 40,
                ),
                onPressed: () async {
                  await showStartupFilesBlocker(context: context);
                },
              ),
            ),

            GeneralGreenButton(
              fixedSize: Size(170, 40),
              text: 'Refresh',
              onPressed: () async {
                ref.invalidate(startupFilesProvider);
                await ref.read(accountsProvider.notifier).load();
              },
            ),
            InGameGate(
              child: GeneralGreenButton(
                fixedSize: Size(170, 40),
                text: 'Create',
                onPressed: () async => await createAccount(context, ref),
              ),
            ),
            InfoButton(),
          ],
        ),
        Expanded(child: AccountsView()),
        BottomBar(),
      ],
    );
  }

  Future<void> createAccount(BuildContext context, WidgetRef ref) async {
    final CreateAccountDialogResult? createAccountResult =
        await showCreateAccountDialog(context: context);

    if (createAccountResult == null) return;
    final accountsNotifier = ref.read(accountsProvider.notifier);
    await accountsNotifier.add(
      name: createAccountResult.name,
      profilBildId: createAccountResult.profilBildId,
      fromExistingDateien: createAccountResult.existingAccountFiles.isEmpty
          ? null
          : createAccountResult.existingAccountFiles,
      fromExistingFilesDir: createAccountResult.customFiles,
    );
  }

  Future<CreateAccountDialogResult?> showCreateAccountDialog({
    required BuildContext context,
  }) async {
    final createAccountResult = await showDialog<CreateAccountDialogResult>(
      context: context,
      builder: (context) {
        return CreateAccountDialog(parentContext: context);
      },
    );
    return createAccountResult;
  }
}

Future<void> showStartupFilesBlocker({
  required final BuildContext context,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StartupFilesBlockerDialog();
    },
  );
}
