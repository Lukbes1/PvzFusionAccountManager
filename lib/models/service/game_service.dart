import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/service/accounts_service.dart';
import 'package:pvz_fusion_acc_manager/models/service/datei_service.dart';
import 'package:sqflite/sqflite.dart';

class PVZFusionProcessEvent {
  const PVZFusionProcessEvent();

  factory PVZFusionProcessEvent.started() = PVZFusionProcessStarted;
  factory PVZFusionProcessEvent.stopped(int exitcode) =>
      PVZFusionProcessStopped(exitcode);
}

class PVZFusionProcessStarted extends PVZFusionProcessEvent {}

class PVZFusionProcessStopped extends PVZFusionProcessEvent {
  final int exitCode;
  PVZFusionProcessStopped(this.exitCode);
}

class GameService {
  final Database _db;
  final DateiService _dateiService;
  final AccountService _accountService;
  File? currentPvzFusionExe;
  Process? _pvzFusionProcess;
  final _pvzFusionProcessEvents =
      StreamController<PVZFusionProcessEvent>.broadcast();
  Stream<PVZFusionProcessEvent> get prvzFusionProcessEvent =>
      _pvzFusionProcessEvents.stream;

  GameService({
    required Database db,
    required DateiService dateiService,
    required Directory pvzFusionDir,
    required AccountService accountService,
  }) : _db = db,
       _dateiService = dateiService,
       _accountService = accountService;

  Future<void> _switchAccount(
    DatabaseExecutor txn,
    final Account accountToSwitchTo,
    final Directory pvzFusionDir,
  ) async {
    final bool noFiles = await _dateiService.isEmpty(db: txn);
    if (noFiles) {
      await _dateiService.addFilesFromDirToAccount(
        txn: txn,
        dir: pvzFusionDir,
        account: accountToSwitchTo,
        newVersion: false,
      );
    }
    await _dateiService.moveAccountDataToPvzFusionDir(
      txn: txn,
      pvzFusionDir: pvzFusionDir,
      account: accountToSwitchTo,
    );
  }

  Future<void> _saveAccount(
    DatabaseExecutor txn,
    final Account accountToSave,
    final Directory pvzFusionDir,
  ) async {
    await _dateiService.addFilesFromDirToAccount(
      txn: txn,
      dir: pvzFusionDir,
      account: accountToSave,
      newVersion: true,
    );
  }

  /// Startet den Account und leitet dafür alle nötigen Schritte ein
  /// 1. Starts playing with the account
  /// 2. Switches the account
  /// 3. Boots the game
  Future<String?> startAccount(
    final Account accountToStart,
    final File pvzFusionExe,
    final Directory pvzFusionDir,
  ) async {
    bool stopAccount = false;
    try {
      currentPvzFusionExe = pvzFusionExe;
      await _db.transaction((txn) async {
        await _accountService.playWith(txn, accountToStart);
        stopAccount = true;
        await _switchAccount(txn, accountToStart, pvzFusionDir);
        return true;
      }, exclusive: true);
      log('Starting game with the following exe: ${pvzFusionExe.path}');
      _pvzFusionProcess = await Process.start(
        pvzFusionExe.path,
        [],
        workingDirectory: pvzFusionExe.parent.path,
        runInShell: true,
      );

      if (_pvzFusionProcess == null) {
        const error = "Could not start pvzFusionExe";
        log(error);
        unawaited(
          Future(
            () => _pvzFusionProcessEvents.add(
              PVZFusionProcessEvent.stopped(exitCode),
            ),
          ),
        );
        return error;
      } else {
        _pvzFusionProcessEvents.add(PVZFusionProcessEvent.started());
        _pvzFusionProcess?.stdout
            .transform(SystemEncoding().decoder)
            .listen(log);
        _pvzFusionProcess?.stderr
            .transform(SystemEncoding().decoder)
            .listen(log);
        unawaited(_handleProcessExit(accountToStart));
      }
    } catch (e) {
      log(e.toString());
      if (stopAccount) {
        accountToStart.stop();
      }
      return e.toString();
    }

    return null;
  }

  Future<void> _handleProcessExit(Account account) async {
    final process = _pvzFusionProcess;
    if (process == null) return;

    try {
      final exitCode = await process.exitCode;
      log('PVZ Fusion exited with code $exitCode');
      _pvzFusionProcessEvents.add(PVZFusionProcessEvent.stopped(exitCode));
    } catch (e, st) {
      log('Process exit handler failed: $e\n$st');
    }
  }

  /// Stoppt den Account und leitet dafür alle nötigen Schrite ein
  /// 1. Stops playing with the account
  /// 2. saves the account
  /// 3. Stop the game (or not if already closed)
  Future<String?> stopAccount({
    required final Account accountToStop,
    required final Directory pvzFusionDir,
    bool skipSavingStage = false,
    bool skipKillingGame = false,
  }) async {
    bool startAccount = false;
    try {
      await _db.transaction((txn) async {
        if (!skipKillingGame) {
          await killPvzFusionProcess(currentPvzFusionExe!);
        }
        await _accountService.stopPlayingWith(txn, accountToStop);
        startAccount = true;
        if (!skipSavingStage) {
          await _saveAccount(txn, accountToStop, pvzFusionDir);
        }

        return null;
      }, exclusive: true);
    } catch (e) {
      log(e.toString());
      if (startAccount) {
        accountToStop.start();
      }
      return e.toString();
    } finally {
      currentPvzFusionExe = null;
    }
    return null;
  }

  Future<void> killPvzFusionProcess(File? pvzFusionExe) async {
    if (_pvzFusionProcess != null && _pvzFusionProcess?.pid != null) {
      _pvzFusionProcess?.kill(ProcessSignal.sigterm);
      if (pvzFusionExe != null) {
        final String name = basenameWithoutExtension(pvzFusionExe.path);
        await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          """
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
  [DllImport("user32.dll")]
  public static extern bool PostMessage(IntPtr hWnd, int Msg, IntPtr wParam, IntPtr lParam);
}
"@
\$proc = Get-Process $name
[Win32]::PostMessage(\$proc.MainWindowHandle, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
""",
        ]);
        log("Tried killing ${pvzFusionExe.path}");
        currentPvzFusionExe = null;
      }
    }
  }

  Future<void> dispose() async {
    await killPvzFusionProcess(currentPvzFusionExe);
  }
}
