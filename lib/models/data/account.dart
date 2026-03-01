import 'package:intl/intl.dart';

class Account implements Comparable {
  final int accountId;
  final String name;
  final String creationDate;
  String? _letzteVersionDate;
  String? get letzteVersionDate => _letzteVersionDate;
  String get letzteVersionDateFormatted {
    if (_letzteVersionDate == null) {
      return "";
    }
    final localTimeLetzteVersion = DateTime.parse(
      _letzteVersionDate!,
    ).toLocal();
    final now = DateTime.now();
    if (now.difference(localTimeLetzteVersion) <= Duration(minutes: 1) &&
        letzteVersionDate != creationDate) {
      return "a moment ago";
    }
    return DateFormat.yMd(
      Intl.getCurrentLocale(),
    ).add_jms().format(localTimeLetzteVersion);
  }

  DateTime? get letzteVersionDateAsDate =>
      _letzteVersionDate == null ? null : DateTime.parse(_letzteVersionDate!);

  int _inGame = 0;
  int get inGame => _inGame;
  int _profilBildId;
  int get profilBildId => _profilBildId;

  static const String accountIdColumn = "accountId";
  static const String inGameColumn = "inGame";
  static const String nameColumn = "name";
  static const String creationDateColumn = "creationDate";
  static const String profilBildIdColumn = "profilBildId";
  static const String accountTable = "Account";

  Account({
    required this.accountId,
    letzteVersionDate,
    required this.creationDate,
    required this.name,
    required int inGame,
    required int profilBildId,
  }) : _inGame = inGame,
       _letzteVersionDate = letzteVersionDate,
       _profilBildId = profilBildId;

  factory Account.fromMap(Map<String, Object?> map) {
    return Account(
      accountId: map[accountIdColumn] as int,
      inGame: map[inGameColumn] as int,
      creationDate: map[creationDateColumn] as String,
      name: map[nameColumn] as String,
      profilBildId: map[profilBildIdColumn] as int,
    );
  }

  Account copyWith({
    int? inGame,
    String? name,
    int? profilBildId,
    String? letzteVersionDate,
  }) {
    return Account(
      accountId: accountId,
      creationDate: creationDate,
      name: name ?? this.name,
      letzteVersionDate: letzteVersionDate ?? this.letzteVersionDate,
      inGame: inGame ?? this.inGame,
      profilBildId: profilBildId ?? this.profilBildId,
    );
  }

  String getLastPlayedString() {
    final hasNeverPlayed = creationDate == _letzteVersionDate;
    if (hasNeverPlayed) {
      return 'Created on $letzteVersionDateFormatted';
    } else {
      return 'Last played $letzteVersionDateFormatted';
    }
  }

  ///Sets intern inGame to true
  void start() {
    _inGame = 1;
  }

  ///Sets intern inGame to false
  void stop() {
    _inGame = 0;
  }

  ///Sets the intern version to the new one
  void upgradeVersion(String letzteVersionDate) {
    _letzteVersionDate = letzteVersionDate;
  }

  ///Changes the ProfilBild
  void changeProfilBild(int profilBildId) {
    _profilBildId = profilBildId;
  }

  @override
  bool operator ==(covariant Account other) {
    return accountId == other.accountId;
  }

  @override
  int get hashCode => accountId.hashCode;

  @override
  int compareTo(covariant Account other) {
    if (other.letzteVersionDateAsDate == null) {
      return 1;
    }
    if (letzteVersionDateAsDate == null) {
      return -1;
    }
    return -letzteVersionDateAsDate!.compareTo(other.letzteVersionDateAsDate!);
  }
}
