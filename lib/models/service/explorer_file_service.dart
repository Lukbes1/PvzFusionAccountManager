import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:pvz_fusion_acc_manager/models/data/datei.dart';

class CantGetPVZFusionDataException {}

class CantWriteFileToPVZFusionDataException {}

class CantDeleteFilesFromPVZFusionDirException {
  final String error;
  CantDeleteFilesFromPVZFusionDirException(this.error);

  @override
  String toString() {
    return error;
  }
}

class ExplorerFileService {
  Future<List<File>> getDataFromDir(final Directory dir) async {
    final List<File> pvzDateien = [];
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && await entity.exists()) {
          pvzDateien.add(entity);
        }
      }
    } catch (e) {
      log(e.toString());
    }

    return pvzDateien;
  }

  Future<void> writeToPvzFusionData(
    final Directory pvzFusionDir,
    final List<Datei> dateien,
  ) async {
    for (final Datei datei in dateien) {
      final newPath = p.join(
        pvzFusionDir.path,
        datei.relativePath,
        '${datei.name}${datei.extensionName}',
      );

      final file = File(newPath);
      // Ensure parent directory exists
      await file.parent.create(recursive: true);
      final resultOfWrite = await file.writeAsBytes(datei.inhalt);
      if (!await resultOfWrite.exists()) {
        throw CantWriteFileToPVZFusionDataException();
      }
    }
  }

  Future<void> writeToPvzFusionDataWithFiles({
    required final Directory pvzFusionDir,
    required final List<File> files,
  }) async {
    for (final File file in files) {
      final String relative = getRelativeDirectory(pvzFusionDir, file);
      file.copy(relative);
    }
  }

  /// Killed alle Dateien in dem Directory
  Future<void> killAllInPvzFusionDir(final Directory pvzFusionDir) async {
    try {
      await for (final entity in pvzFusionDir.list(recursive: true)) {
        if (await entity.exists()) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Suche das PVZFusionDir
  Future<Directory?> searchForPvzFusionDir() async {
    final userProfile = Platform.environment['USERPROFILE']!;
    final appDataRoot = p.join(
      userProfile,
      'AppData',
      'LocalLow',
      'LanPiaoPiao',
      'PlantsVsZombiesRH',
    );
    final directory = Directory(appDataRoot);
    if (!await directory.exists()) {
      try {
        final createdDir = await directory.create(recursive: true);
        return createdDir;
      } catch (e) {
        return null;
      }
    }
    return directory;
  }

  Future<Directory?> getDirFromFilePicker({String? dialogTitle}) async {
    final result = await FilePicker.getDirectoryPath(dialogTitle: dialogTitle);

    if (result == null) {
      return null;
    }
    log('Picked folder: $result');
    return Directory(result);
  }

  /// Suche die PVZFusionExe
  Future<String?> findExeUsingPowerShell(
    String exeName,
    Duration waitFor,
  ) async {
    final result = await Process.start('powershell', [
      '-Command',
      'Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -ExpandProperty DeviceID |ForEach-Object { where.exe /r "\$_\\" $exeName.exe } | Select-Object -First 1',
    ]);

    final timer = Timer(waitFor, () {
      log('done Waiting');
      Process.killPid(result.pid);
    });

    String? exe;
    await for (final line
        in result.stdout.transform(utf8.decoder).transform(LineSplitter())) {
      if (line.isNotEmpty) {
        log('Found: $line');
        exe = line;
        timer.cancel();
        result.kill();
        break;
      }
    }
    await result.exitCode;
    return exe;
  }

  ///Gibt den relativen Pfad vom pvzFusion dir zur Datei
  String getRelativeDirectory(final Directory pvzFusionDir, final File file) {
    String dir = p.dirname(p.relative(file.path, from: pvzFusionDir.path));
    if (dir == ".") {
      dir = "";
    }
    return dir;
  }
}
