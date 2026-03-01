import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pvz_fusion_acc_manager/models/data/info_datei.dart';
import 'package:pvz_fusion_acc_manager/models/data/startup_file.dart';
import 'package:pvz_fusion_acc_manager/models/data/startup_files_state.dart';
import 'package:pvz_fusion_acc_manager/models/provider/db_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/explorer_file_service_provider.dart';
import 'package:pvz_fusion_acc_manager/models/service/info_datei_service.dart';

final infoDateienServiceProvider = FutureProvider((ref) async {
  final db = await ref.read(databaseProvider.future);
  return InfoDateiService(db: db);
});

final startupFilesProvider = AsyncNotifierProvider(StartupFilesProvider.new);

class StartupFileException implements Exception {
  final StartupFilesState lastState;
  const StartupFileException(this.lastState);
}

class StartupFilesProvider extends AsyncNotifier<StartupFilesState> {
  @override
  Future<StartupFilesState> build() async {
    final Map<StartupFileType, StartupFile> startupFiles = {};
    final infoDateienService = await ref.read(
      infoDateienServiceProvider.future,
    );

    final StartupFile? pvzFusionDir = await _getAndCheckPvzFusionDir(
      infoDateienService,
    );
    if (pvzFusionDir != null) {
      startupFiles.putIfAbsent(
        StartupFileType.pvzFusionDir,
        () => pvzFusionDir,
      );
    }
    final StartupFile? pvzFusionExe = await _getAndCheckPvzFusionExe(
      infoDateienService,
    );
    if (pvzFusionExe != null) {
      startupFiles.putIfAbsent(
        StartupFileType.pvzFusionExe,
        () => pvzFusionExe,
      );
    }
    final StartupFilesState startupFilesState = StartupFilesState(
      startupFiles: startupFiles,
    );
    if (startupFilesState.invalid) {
      state = AsyncError(
        StartupFileException(startupFilesState),
        StackTrace.current,
      );
    }
    return StartupFilesState(startupFiles: startupFiles);
  }

  ///A startup file, if a path was found, null otherwise
  Future<StartupFile?> _getAndCheckPvzFusionDir(
    final InfoDateiService infoDateienService,
  ) async {
    InfoDatei? pvzFusionDir = await infoDateienService.getInfoDatei(
      name: StartupFileType.pvzFusionDir.name,
    );
    //not in db
    if (pvzFusionDir == null) {
      final explorerService = ref.read(explorerFileServiceProvider);
      final dir = await explorerService.searchForPvzFusionDir();
      if (dir != null) {
        pvzFusionDir = InfoDatei(
          name: StartupFileType.pvzFusionDir.name,
          path: dir.path,
        );
        await infoDateienService.addIfNotExitsInfoDatei(
          infoDatei: pvzFusionDir,
        );
        return StartupFile(exists: true, infoDatei: pvzFusionDir);
      }
      return null;
    } else {
      //Check if still valid in file system
      if (!await Directory(pvzFusionDir.path).exists()) {
        return StartupFile(exists: false, infoDatei: pvzFusionDir);
      } else {
        return StartupFile(exists: true, infoDatei: pvzFusionDir);
      }
    }
  }

  Future<StartupFile?> _getAndCheckPvzFusionExe(
    final InfoDateiService infoDateienService,
  ) async {
    InfoDatei? pvzFusionExe = await infoDateienService.getInfoDatei(
      name: StartupFileType.pvzFusionExe.name,
    );
    if (pvzFusionExe == null || pvzFusionExe.path.isEmpty) {
      final explorerService = ref.read(explorerFileServiceProvider);
      final exe = await explorerService.findExeUsingPowerShell(
        "PlantsVsZombiesRH",
        Duration(seconds: 30),
      );
      if (exe != null) {
        pvzFusionExe = InfoDatei(
          name: StartupFileType.pvzFusionExe.name,
          path: exe.trim(),
        );
        await infoDateienService.addIfNotExitsInfoDatei(
          infoDatei: pvzFusionExe,
        );
        return StartupFile(exists: true, infoDatei: pvzFusionExe);
      }
      return null;
    } else {
      final exe = File(pvzFusionExe.path);
      if (!await exe.exists()) {
        return StartupFile(exists: false, infoDatei: pvzFusionExe);
      }
      return StartupFile(exists: true, infoDatei: pvzFusionExe);
    }
  }

  Future<String?> updateStartupFile({
    required final StartupFileType type,
    required String path,
  }) async {
    StartupFile? newFile;
    switch (type) {
      case StartupFileType.pvzFusionExe:
        final File file = File(path);
        if (!await file.exists()) {
          return "The file can not be found!";
        }
      case StartupFileType.pvzFusionDir:
        final Directory dir = Directory(path);
        if (!await dir.exists()) {
          return "The directory can not be found!";
        }
    }
    final StartupFile? oldFile = state.requireValue.getStartupFile(type);
    if (oldFile != null) {
      newFile = oldFile.copyWith(
        exists: true,
        infoDatei: InfoDatei(name: type.name, path: path),
      );
    } else {
      newFile = StartupFile(
        exists: true,
        infoDatei: InfoDatei(name: type.name, path: path),
      );
    }
    state = state..requireValue.putOrReplace(type: type, startupFile: newFile);
    final infodateienService = await ref.read(
      infoDateienServiceProvider.future,
    );
    await infodateienService.updateInfoDatei(infoDatei: newFile.infoDatei);
    return null;
  }
}
