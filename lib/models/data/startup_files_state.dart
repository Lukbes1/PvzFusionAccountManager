import 'package:pvz_fusion_acc_manager/models/data/startup_file.dart';

enum StartupFileType { pvzFusionExe, pvzFusionDir }

class StartupFilesState {
  final Map<StartupFileType, StartupFile> _startupFiles;

  bool get invalid =>
      _startupFiles.values.any((startupFile) => !startupFile.exists) ||
      _startupFiles.length != StartupFileType.values.length;
  bool get valid => !invalid;

  const StartupFilesState({
    required Map<StartupFileType, StartupFile> startupFiles,
  }) : _startupFiles = startupFiles;

  StartupFile? getStartupFile(final StartupFileType type) =>
      _startupFiles[type];

  /// true if exists in the file system
  bool startupFileExists(final StartupFileType type) {
    final StartupFile? startupFile = _startupFiles[type];
    if (startupFile == null) {
      return false;
    }
    return startupFile.exists;
  }

  void putOrReplace({
    required final StartupFileType type,
    required final StartupFile startupFile,
  }) {
    final oldFile = _startupFiles[type];
    if (oldFile != null) {
      _startupFiles.remove(type);
    }
    _startupFiles.putIfAbsent(type, () => startupFile);
  }
}
