import 'package:pvz_fusion_acc_manager/main.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ProfilBilderEmptyException {}

class ProfilBildNichtGefundenException {}

class ProfilBildService {
  final Database _db;

  ProfilBildService({required Database db}) : _db = db;

  Future<List<ProfilBild>> getAll() async {
    final profilBilder = await _db.query(ProfilBild.profilBildTable);
    if (profilBilder.isEmpty) {
      errorLogger.e(
        'Profile pictures were empty',
        stackTrace: StackTrace.current,
      );
      throw ProfilBilderEmptyException();
    }
    return profilBilder
        .map((profilBildMap) => ProfilBild.fromRow(profilBildMap))
        .toList();
  }

  Future<ProfilBild> get(int profilBildId) async {
    final profilBild = await _db.query(
      ProfilBild.profilBildTable,
      where: '${ProfilBild.profilBildIdColumn} = ?',
      whereArgs: [profilBildId],
      limit: 1,
    );
    if (profilBild.isEmpty) {
      errorLogger.e(
        'Profile picture with id "$profilBildId" could not be found',
        stackTrace: StackTrace.current,
      );
      throw ProfilBildNichtGefundenException();
    }
    return ProfilBild.fromRow(profilBild.single);
  }
}
