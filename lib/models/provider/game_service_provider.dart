import 'dart:io';

import 'package:pvz_fusion_acc_manager/models/data/startup_files_state.dart';
import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/datei_service_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/db_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/startup_files_provider.dart';
import 'package:pvz_fusion_acc_manager/models/service/accounts_service.dart';
import 'package:pvz_fusion_acc_manager/models/service/datei_service.dart';
import 'package:pvz_fusion_acc_manager/models/service/game_service.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sqflite/sqflite.dart';

final gameServiceProvider = FutureProvider((ref) async {
  final DateiService dateiService = await ref.read(dateiServiceProvider.future);
  final Database db = await ref.read(databaseProvider.future);
  final StartupFilesState startupFilesState = await ref.read(
    startupFilesProvider.future,
  );
  final Directory dir = Directory(
    startupFilesState
        .getStartupFile(StartupFileType.pvzFusionDir)!
        .infoDatei
        .path,
  );
  final AccountService accountService = await ref.read(
    accountServiceProvider.future,
  );

  final gameService = GameService(
    db: db,
    dateiService: dateiService,
    pvzFusionDir: dir,
    accountService: accountService,
  );
  ref.onDispose(
    () => gameService.killPvzFusionProcess(gameService.currentPvzFusionExe),
  );
  return gameService;
});
