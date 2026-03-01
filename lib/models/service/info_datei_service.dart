import 'package:pvz_fusion_acc_manager/models/data/info_datei.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class InfoDateiService {
  final Database _db;

  InfoDateiService({required Database db}) : _db = db;

  Future<InfoDatei?> getInfoDatei({
    required final String name,
    DatabaseExecutor? txn,
  }) async {
    final db = txn ?? _db;
    final infoDateiRow = await db.query(
      InfoDatei.infoDateiTable,
      where: '${InfoDatei.nameColumn} = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (infoDateiRow.isEmpty) {
      return null;
    }
    return InfoDatei.fromRow(infoDateiRow.single);
  }

  Future<void> addIfNotExitsInfoDatei({
    required final InfoDatei infoDatei,
    DatabaseExecutor? txn,
  }) async {
    final db = txn ?? _db;
    final infoDateiRow = await getInfoDatei(name: infoDatei.name);
    if (infoDateiRow != null) {
      if (infoDateiRow.path.isEmpty) {
        await db.delete(
          InfoDatei.infoDateiTable,
          where: '${InfoDatei.nameColumn} = ?',
          whereArgs: [infoDatei.name],
        );
      } else {
        return;
      }
    }
    await db.insert(InfoDatei.infoDateiTable, infoDatei.toRow());
  }

  Future<void> updateInfoDatei({required final InfoDatei infoDatei}) async {
    await _db.update(
      InfoDatei.infoDateiTable,
      {InfoDatei.pathColumn: infoDatei.path},
      where: '${InfoDatei.nameColumn} = ?',
      whereArgs: [infoDatei.name],
    );
  }
}
