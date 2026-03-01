import 'package:pvz_fusion_acc_manager/models/data/version.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class VersionsService {
  final Database _db;

  VersionsService({required final Database db}) : _db = db;

  Future<List<Version>> getAllXForAccount({
    required final int accountId,
    final bool includingCurrent = false,
    required final int lastVersionsAmount,
  }) async {
    final offset = includingCurrent ? 0 : 1;
    final versionsDescending = await _db.query(
      Version.versionTable,
      where: '${Version.accountIdColumn} = ?',
      whereArgs: [accountId],
      orderBy: '${Version.creationDateColumn} DESC',
      offset: offset,
    );

    if (versionsDescending.isEmpty) {
      return [];
    }
    return versionsDescending.map((entry) => Version.fromRow(entry)).toList();
  }
}
