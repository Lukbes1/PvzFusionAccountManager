import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pvz_fusion_acc_manager/main.dart' show errorLogger, infoLogger;
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:pvz_fusion_acc_manager/models/data/version.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sqflite/sqflite.dart';

final databaseName = "pvzfusionmanager.db";
final databaseProvider = FutureProvider((ref) async {
  try {
    final dbPath = join(
      (await getApplicationCacheDirectory()).path,
      databaseName,
    );
    final db = await openDatabase(
      dbPath,
      version: 3,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await _onCreate(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _onUpgradeV2(db);
        }
        if (oldVersion < 3) {
          await _onUpgradeV3(db);
        }
      },
    ).timeout(const Duration(seconds: 30));
    return db;
  } catch (e, st) {
    errorLogger.e(
      'The database could not be opened!',
      error: e,
      stackTrace: st,
    );
    rethrow;
  }
});

Future<void> _onCreate(Database db) async {
  try {
    infoLogger.i('Start creating the database...');
    const createProfilBildTable = '''CREATE TABLE IF NOT EXISTS ProfilBild(
    profilBildId INTEGER primary key autoincrement,
    name TEXT not null unique,
    bild BLOB not null
  );
''';
    await db.execute(createProfilBildTable);
    infoLogger.i('Successfully created the profile pictures table');

    const createAccountTable = '''CREATE TABLE IF NOT EXISTS "Accounts" (
	"accountId"	INTEGER primary key autoincrement,
  "inGame" integer not null check(inGame in (0,1)) default 0,
	"name"	TEXT NOT NULL,
	"creationDate" TEXT NOT NULL UNIQUE,
  "profilBildId" INTEGER NOT NULL,
   FOREIGN KEY (profilBildId) REFERENCES ProfilBild(profilBildId)
);
''';
    await db.execute(createAccountTable);
    infoLogger.i('Successfully created the accounts table');

    const createVersionTable = ''' CREATE TABLE IF NOT EXISTS Versions(
	creationDate TEXT primary key,
  versionNr integer,
	accountId Integer not null,
	FOREIGN KEY (accountId) REFERENCES Accounts(accountId) ON DELETE CASCADE
);
''';
    await db.execute(createVersionTable);
    infoLogger.i('Successfully created the versions table');

    const createDateiTable = '''CREATE TABLE IF NOT EXISTS Datei(
	name TEXT not null,
	relativePath TEXT not null,
	extension TEXT not null,
	accountId Integer not null references Account(accountId) on delete cascade,
	versionDate TEXT not null references Version(creationDate) on delete cascade,
	inhalt BLOB not null,
	primary key(relativePath, name, accountId, versionDate)
);
''';
    await db.execute(createDateiTable);
    infoLogger.i('Successfully created the files table');

    const createInfoDateienTable = '''
    CREATE TABLE IF NOT EXISTS InfoDatei(
     name Text primary key,
     path Text not null 
    );
''';

    await db.execute(createInfoDateienTable);

    infoLogger.i('Successfully created the info files table');

    //Populate profilBilder

    final profilBilder = await _loadProfilBilder();
    final profilBilderBatch = db.batch();

    for (final ProfilBild profilBild in profilBilder) {
      profilBilderBatch.insert(
        ProfilBild.profilBildTable,
        profilBild.toRow(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      infoLogger.i('Inserted ${profilBild.name} to the batch');
    }
    await profilBilderBatch.commit(continueOnError: false);
    infoLogger.i('Committed the batch successfully');

    await _insertCrazyDave(db);
    infoLogger.i('Inserted crazy dave successfully');
  } on Exception catch (error) {
    errorLogger.e(error, stackTrace: StackTrace.current);
    rethrow;
  }
}

Future<void> _onUpgradeV2(Database db) async {
  await db.execute('ALTER TABLE "Account" RENAME TO "Accounts";');
}

Future<void> _onUpgradeV3(Database db) async {
  await db.execute('ALTER TABLE "Version" RENAME TO "Versions";');
}

Future<void> _insertCrazyDave(DatabaseExecutor db) async {
  final date = DateTime.now().toUtc().toIso8601String();
  final crazyDaveProfilePic = await db.query(
    ProfilBild.profilBildTable,
    where: '${ProfilBild.nameColumn} = ?',
    whereArgs: ['Crazy dave'],
    limit: 1,
  );
  if (crazyDaveProfilePic.isEmpty) {
    errorLogger.e(
      'Crazy dave profile picture could not be found on db initalization!',
      stackTrace: StackTrace.current,
      error: crazyDaveProfilePic,
    );
    return;
  }

  int accountId = await db.insert(Account.accountTable, {
    Account.nameColumn: 'Crazy Dave',
    Account.creationDateColumn: date,
    Account.profilBildIdColumn: ProfilBild.fromRow(
      crazyDaveProfilePic.first,
    ).profilBildId,
  });

  await db.insert(Version.versionTable, {
    Version.accountIdColumn: accountId,
    Version.creationDateColumn: date,
    Version.versionNrColumn: 1,
  });
}

final profilBildImages = [
  'resources/plants/crazy_dave.png',
  'resources/plants/pharos_umbrella.png',
  'resources/plants/pea_storm_commando.png',
  'resources/plants/apeacalypse_minigun.png',
  'resources/plants/peashooter.png',
  'resources/plants/obsidian_spikerock.png',
  'resources/plants/twin_solar_nut.png',
  'resources/plants/pea_nut.png',
  'resources/plants/stardrop.png',
  'resources/plants/sunrise_shroom.png',
  'resources/plants/chompzilla.png',
  'resources/plants/cob_literator.png',
  'resources/plants/obsidian_tallnut.png',
  'resources/plants/sunflower.png',
];

String _formatImageName(String path) {
  String fileName = path.split('/').last.split('.').first;
  String withSpaces = fileName.replaceAll('_', ' ');
  return withSpaces[0].toUpperCase() + withSpaces.substring(1);
}

Future<List<ProfilBild>> _loadProfilBilder() async {
  final List<ProfilBild> alleBilderResult = [];
  int id = 0;
  for (final String bildPath in profilBildImages) {
    final name = _formatImageName(bildPath);
    final bildInhalt = await _loadImageBytes(bildPath);
    final profilBild = ProfilBild(
      profilBildId: id,
      name: name,
      bild: bildInhalt,
    );
    alleBilderResult.add(profilBild);
    id++;
  }
  return alleBilderResult;
}

Future<Uint8List> _loadImageBytes(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  return data.buffer.asUint8List();
}
