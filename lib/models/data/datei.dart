import 'dart:typed_data';

class Datei {
  final int accountId;
  final String versionDate;
  final Uint8List inhalt;
  final String name;
  final String relativePath;
  final String extensionName;

  static const String accountIdColumn = "accountId";
  static const String versionDateColumn = "versionDate";
  static const String inhaltColumn = "inhalt";
  static const String nameColumn = "name";
  static const String relativePathColumn = "relativePath";
  static const String extensionNameColumn = "extension";
  static const String dateiTable = "Datei";

  Datei({
    required this.accountId,
    required this.versionDate,
    required this.inhalt,
    required this.name,
    required this.extensionName,
    required this.relativePath,
  });

  factory Datei.fromRow(Map<String, Object?> map) => Datei(
    accountId: map[accountIdColumn] as int,
    extensionName: map[extensionNameColumn] as String,
    inhalt: map[inhaltColumn] as Uint8List,
    relativePath: map[relativePathColumn] as String,
    name: map[nameColumn] as String,
    versionDate: map[versionDateColumn] as String,
  );

  @override
  bool operator ==(covariant Datei other) {
    return accountId == other.accountId &&
        versionDate == other.versionDate &&
        name == other.name &&
        relativePath == other.relativePath;
  }

  @override
  int get hashCode =>
      accountId.hashCode +
      versionDate.hashCode +
      name.hashCode +
      relativePath.hashCode;
}
