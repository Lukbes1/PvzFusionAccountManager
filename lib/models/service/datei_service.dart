import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pvz_fusion_acc_manager/main.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/datei.dart';
import 'package:pvz_fusion_acc_manager/models/data/version.dart';
import 'package:pvz_fusion_acc_manager/models/service/accounts_service.dart';
import 'package:pvz_fusion_acc_manager/models/service/explorer_file_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class NoFilesFoundException {}

class DateiService {
  final Database _db;
  final ExplorerFileService _explorerFileService;
  final AccountService _accountService;

  const DateiService({
    required Database db,
    required ExplorerFileService explorerFileService,
    required AccountService accountService,
  }) : _db = db,
       _explorerFileService = explorerFileService,
       _accountService = accountService;

  ///Sucht die Aktuellen dateien raus und fügt diese dem  account hinzu
  ///Legt diese in eine neue Version, falls newVersion true ist.
  ///Liefert den Neuen Account zurück (mit neu eingetragener Version)
  Future<Account> addFilesFromDirToAccount({
    DatabaseExecutor? txn,
    required final Directory dir,
    required final Account account,
    final bool newVersion = true,
  }) async {
    final db = txn ?? _db;
    List<File> files = await _explorerFileService.getDataFromDir(dir);
    Account updatedAccount = account;
    if (newVersion) {
      await _accountService.createNewVersionInTransaction(
        db: db,
        account: updatedAccount,
      );
    }
    await deleteOldestXVersionsAndFiles(
      txn: db,
      account: account,
      olderThan: 5,
    );

    for (final File file in files) {
      final name = p.basenameWithoutExtension(file.path);
      final extensionName = p.extension(file.path);
      final inhalt = await file.readAsBytes();
      final relativePath = _explorerFileService.getRelativeDirectory(dir, file);

      await db.insert(Datei.dateiTable, {
        Datei.accountIdColumn: updatedAccount.accountId,
        Datei.versionDateColumn: updatedAccount.letzteVersionDate,
        Datei.nameColumn: name,
        Datei.extensionNameColumn: extensionName,
        Datei.inhaltColumn: inhalt,
        Datei.relativePathColumn: relativePath,
      });
    }
    return updatedAccount;
  }

  ///Housekeeping für den account für alle versionen und dateien äter als x Versionen
  Future<void> deleteOldestXVersionsAndFiles({
    required DatabaseExecutor txn,
    required int olderThan,
    required final Account account,
  }) async {
    final allVersionsDescending = await txn.query(
      Version.versionTable,
      columns: [Version.creationDateColumn],
      where: '${Version.accountIdColumn} = ?',
      whereArgs: [account.accountId],
      orderBy: '${Version.creationDateColumn} DESC',
    );

    if (allVersionsDescending.isEmpty ||
        allVersionsDescending.length <= olderThan) {
      return;
    }

    final versionDates = allVersionsDescending
        .map((row) => row[Version.creationDateColumn])
        .skip(olderThan)
        .toList();

    final placeholders = List.filled(versionDates.length, '?').join(',');

    await txn.delete(
      Datei.dateiTable,
      where: '${Datei.versionDateColumn} IN ($placeholders)',
      whereArgs: versionDates,
    );

    await txn.delete(
      Version.versionTable,
      where: '${Version.creationDateColumn} IN ($placeholders)',
      whereArgs: versionDates,
    );
  }

  ///Sorgt dafür, dass Alle Dateien der Aktuellen Version des Accounts in das PvzFusionDir gelden werden, um damit spielen zu können
  Future<void> moveAccountDataToPvzFusionDir({
    required DatabaseExecutor txn,
    required final Directory pvzFusionDir,
    required final Account account,
    final Version? version,
  }) async {
    final allDateien = await getAll(
      txn: txn,
      account: account,
      version: version,
    );
    try {
      await _explorerFileService.killAllInPvzFusionDir(pvzFusionDir);
      await _explorerFileService.writeToPvzFusionData(pvzFusionDir, allDateien);
    } catch (e, st) {
      errorLogger.e(
        'Could not move all account data into the pvz fusion directory "${pvzFusionDir.absolute}"',
        error: e,
        stackTrace: st,
      );
      throw StateError(e.toString());
    }
  }

  Future<bool> isEmpty({required DatabaseExecutor db}) async {
    final result = await db.rawQuery(
      'SELECT 1 FROM ${Datei.dateiTable} LIMIT 1',
    );
    return result.isEmpty;
  }

  Future<List<Datei>> getAll({
    DatabaseExecutor? txn,
    required final Account account,
    final Version? version,
  }) async {
    final db = txn ?? _db;
    final accountId = version?.accountId ?? account.accountId;
    final versionDate = version?.creationDate ?? account.letzteVersionDate;
    if (versionDate == null) {
      final errorMessage =
          'No active version set for account ${account.accountId}';
      errorLogger.e(errorMessage);
      throw StateError(errorMessage);
    }
    final result = await db.query(
      Datei.dateiTable,
      where: '${Datei.accountIdColumn} = ? AND ${Datei.versionDateColumn} = ?',
      whereArgs: [accountId, versionDate],
    );
    if (result.isEmpty) {
      final anyFiles = await db.query(
        Datei.dateiTable,
        where: '${Datei.accountIdColumn} = ?',
        whereArgs: [accountId],
      );
      if (anyFiles.isEmpty) {
        return []; //If account is fresh,
      }
      final errorMessage =
          'This error should not have happened: You might closed the app to quickly';
      errorLogger.e(errorMessage);
      throw StateError(errorMessage);
    }
    return result.map((element) => Datei.fromRow(element)).toList();
  }
}
