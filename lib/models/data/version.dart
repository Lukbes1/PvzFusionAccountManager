import 'package:intl/intl.dart';

class Version {
  final String creationDate;
  final int versionNr;
  final int accountId;

  static const String creationDateColumn = "creationDate";
  static const String versionNrColumn = "versionNr";
  static const String accountIdColumn = "accountId";
  static const String versionTable = "Versions";

  String get playedOnFormatted {
    final localTimeCreationDate = DateTime.parse(creationDate).toLocal();
    return DateFormat.yMd(
      Intl.getCurrentLocale(),
    ).add_jms().format(localTimeCreationDate);
  }

  Version({
    required this.creationDate,
    required this.accountId,
    required this.versionNr,
  });

  factory Version.fromRow(Map<String, Object?> map) {
    return Version(
      creationDate: map[creationDateColumn] as String,
      accountId: map[accountIdColumn] as int,
      versionNr: map[versionNrColumn] as int,
    );
  }

  Map<String, Object?> toRow() {
    return {
      versionNrColumn: versionNr,
      accountIdColumn: accountId,
      creationDateColumn: creationDate,
    };
  }

  @override
  bool operator ==(covariant Version other) {
    return accountId == other.accountId && versionNr == other.versionNr;
  }

  @override
  int get hashCode => accountId.hashCode + versionNr.hashCode;
}
