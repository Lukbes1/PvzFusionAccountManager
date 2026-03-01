import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pvz_fusion_acc_manager/views/helper/dialog/general_future_dialog.dart';
import 'package:pvz_fusion_acc_manager/views/helper/general_yellow_button.dart';
import 'package:pvz_fusion_acc_manager/views/helper/general_svg_icon_button.dart';
import 'package:pvz_fusion_acc_manager/models/data/startup_file.dart';
import 'package:pvz_fusion_acc_manager/models/data/startup_files_state.dart';
import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/startup_files_provider.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/style/shadows.dart';
import 'package:pvz_fusion_acc_manager/views/toasts/error_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zentoast/zentoast.dart';

class StartupFilesBlockerDialog extends ConsumerStatefulWidget {
  const StartupFilesBlockerDialog({super.key});

  @override
  ConsumerState<StartupFilesBlockerDialog> createState() =>
      _StartupFilesBlockerDialogState();
}

class _StartupFilesBlockerDialogState
    extends ConsumerState<StartupFilesBlockerDialog> {
  Future<_StartupFilesInitData> _onInit(WidgetRef ref) async {
    final startupFilesState = await ref.watch(startupFilesProvider.future);
    return _StartupFilesInitData(startupFilesState: startupFilesState);
  }

  @override
  Widget build(BuildContext context) {
    return GeneralFutureDialog(
      onLoadText: 'initalizing...',
      onInit: _onInit(ref),
      width: 450,
      canDragApp: true,
      height: 475,
      alignment: Alignment(0, 0),
      builder: (initData) {
        return Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: const Text(
                'Welcome !',
                style: TextStyle(
                  color: appLightYellow,
                  fontFamily: 'pvzHeader',
                  fontSize: 26,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
                child: Container(
                  height: 175,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: appNormalYellow,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [mainShadow],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async => await launchUrl(
                            Uri(
                              scheme: 'https',
                              host:
                                  'https://github.com/Lukbes1/PvzFusionAccountManager/blob/main/README.md',
                            ),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: const Text(
                            textAlign: TextAlign.center,
                            'Please consider reading the documentation! ',
                            style: TextStyle(
                              color: Color(0xFFAAAAFF),
                              decoration: TextDecoration.underline,
                              fontSize: 20,
                              fontFamily: 'pvz',
                            ),
                          ),
                        ),
                        const Text(
                          'The program automatically tries to detect the path of the .exe file of the game and the game files.\nIf this fails, or if the paths change,\nthey must be updated manually!',
                          style: TextStyle(
                            height: 1.2,
                            color: appPurple,
                            fontSize: 24,
                            fontFamily: 'pvz',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _StartupFiles(lastState: initData.startupFilesState),
            GeneralYellowButton(
              onPressed: initData.startupFilesState.valid
                  ? () {
                      Navigator.pop(context);
                      ref.invalidate(accountsProvider);
                    }
                  : null,
              text: 'Start',
              width: 200,
              height: 40,
              fontSize: 28,
            ),
          ],
        );
      },
    );
  }
}

class _StartupFilesInitData {
  final StartupFilesState startupFilesState;

  const _StartupFilesInitData({required this.startupFilesState});
}

///Helper widget for startupDateien
class _StartupFiles extends StatelessWidget {
  final StartupFilesState lastState;
  const _StartupFiles({required this.lastState});

  @override
  Widget build(BuildContext context) {
    final StartupFile? exePath = lastState.getStartupFile(
      StartupFileType.pvzFusionExe,
    );
    final StartupFile? gamefilesPath = lastState.getStartupFile(
      StartupFileType.pvzFusionDir,
    );
    return Column(
      children: [
        _StartupFileItem(
          leadingText: '.exe file',
          startupFile: exePath,
          type: StartupFileType.pvzFusionExe,
        ),
        const SizedBox(height: 15),
        _StartupFileItem(
          leadingText: 'game files',
          startupFile: gamefilesPath,
          type: StartupFileType.pvzFusionDir,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _StartupFileItem extends ConsumerStatefulWidget {
  final String leadingText;
  final StartupFile? startupFile;
  final StartupFileType type;

  const _StartupFileItem({
    required this.leadingText,
    required this.startupFile,
    required this.type,
  });

  @override
  ConsumerState<_StartupFileItem> createState() => _StartupFileItemState();
}

class _StartupFileItemState extends ConsumerState<_StartupFileItem> {
  late ScrollController scrollController;
  late FocusNode textFocusNode;
  Border? pathBorder;
  @override
  void initState() {
    scrollController = ScrollController();
    textFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget buildIcon() {
    if (widget.startupFile != null && widget.startupFile!.exists) {
      return Positioned(
        right: 22,
        top: 2,
        child: SvgPicture.asset(
          'resources/icons/checkmark.svg',
          width: 22,
          height: 22,
        ),
      );
    } else {
      return Positioned(
        right: 25,
        top: 2,
        child: SvgPicture.asset(
          'resources/icons/red_x.svg',
          width: 32,
          height: 32,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final valid = (widget.startupFile?.exists) ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 185,
          height: 45,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: appNormalYellow,
            border: BoxBorder.all(
              color: valid ? appGreenBorder : appRed,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [mainShadow],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -4,
                child: Text(
                  widget.leadingText,
                  style: const TextStyle(
                    color: appPurple,
                    fontSize: 24,
                    fontFamily: 'pvz',
                  ),
                ),
              ),
              buildIcon(),
              Positioned(
                right: -9,
                top: -6,
                child: GeneralSvgIconButton(
                  width: 22,
                  height: 22,
                  iconRessource: 'resources/icons/upload.svg',
                  onPressed: () async {
                    String? newPath;
                    switch (widget.type) {
                      case StartupFileType.pvzFusionExe:
                        final result = await FilePicker.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['exe'],
                          dialogTitle: 'Pick the PvzFusion .exe',
                        );
                        if (result?.count != 0) {
                          newPath = result?.files.single.path;
                        }
                      case StartupFileType.pvzFusionDir:
                        newPath = await FilePicker.getDirectoryPath(
                          dialogTitle: 'Pick the PvzFusion game file directory',
                        );
                    }
                    if (newPath != null) {
                      String? error = await ref
                          .read(startupFilesProvider.notifier)
                          .updateStartupFile(type: widget.type, path: newPath);
                      if (error != null) {
                        if (!context.mounted) {
                          return;
                        }
                        Toast(
                          height: 72,
                          builder: (toast) =>
                              ErrorToast(text: error, toast: toast),
                        ).show(context);
                      }
                    }
                  },
                  iconColor: WidgetStateColor.fromMap({
                    WidgetState.pressed: appGreen,
                    WidgetState.hovered: appGreenBorder,
                    WidgetState.disabled: Color(0xFFB4A163),
                    WidgetState.any: Colors.transparent,
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15, height: 15),
        Container(
          width: 200,
          height: 45,
          padding: const EdgeInsets.only(left: 6, top: 5.0),
          decoration: BoxDecoration(
            color: appNormalYellow,
            borderRadius: BorderRadius.circular(8),
            border: pathBorder,
            boxShadow: [mainShadow],
          ),
          child: Scrollbar(
            thickness: 4,
            radius: Radius.circular(4),
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,

              scrollDirection: Axis.horizontal,
              child: SelectableText(
                focusNode: textFocusNode,
                widget.startupFile?.infoDatei.path ?? '',
                style: const TextStyle(
                  color: appPurple,
                  fontSize: 24,
                  fontFamily: 'pvz',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
