import 'dart:async';
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
    final script =
        r'''
$exe = "''' +
        exeName +
        r'''.exe"
 $timeout = ''' +
        waitFor.inSeconds.toString() +
        r''' ## seconds
 $RetryInterval = 1 ## seconds

$commonPaths = @(
 "$env:USERPROFILE\Desktop",
 "C:\Games",
 "D:\Games",
 "$env:USERPROFILE"
)

$job = Start-Job -ScriptBlock {
    param($exe,$commonPaths)

    foreach ($p in $commonPaths) {
        if (Test-Path $p) {
            $found = Get-ChildItem $p -Filter $exe -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { return $found.FullName }
        }
    }

    $drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
              Select-Object -ExpandProperty DeviceID

    foreach ($d in $drives) {
        $found = Get-ChildItem "$d\" -Filter $exe -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { return $found.FullName }
    }
} -ArgumentList $exe,$commonPaths

$isjobStillRunning = {param($job) $job.State -eq 'Running'}
$timer = [Diagnostics.Stopwatch]::StartNew()

while (($timer.Elapsed.TotalSeconds -lt $timeout) -and (& $isjobStillRunning $job))
{
    Start-Sleep -Seconds $RetryInterval

    $totalSeconds = [math]::Round($timer.Elapsed.TotalSeconds, 0)
    Write-Output "Still waiting for action to complete after [$totalSeconds] seconds..."
}

$result = Receive-Job $job
Remove-Job $job -Force
if ($result) {
    Write-Output "$result"
} else {
    Write-Output "File not found within timeout."
}
$timer.Stop()

    
    ''';

    final result = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      script,
    ]);

    final output = (result.stdout as String).trim();
    if (output.isEmpty ||
        !output.contains(exeName) ||
        (result.stderr as String).isNotEmpty) {
      return null;
    }

    return output.split('\n').last.trim();
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
