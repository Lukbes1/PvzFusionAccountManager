import 'dart:typed_data';

class ProfilBild {
  final int profilBildId;
  final String name;
  final Uint8List bild;

  static const String bildColumn = "bild";
  static const String nameColumn = "name";
  static const String profilBildIdColumn = "profilBildId";
  static const String profilBildTable = "ProfilBild";

  ProfilBild({
    required this.profilBildId,
    required this.name,
    required this.bild,
  });

  factory ProfilBild.fromRow(Map<String, Object?> map) {
    return ProfilBild(
      profilBildId: map[profilBildIdColumn] as int,
      name: map[nameColumn] as String,
      bild: map[bildColumn] as Uint8List,
    );
  }

  Map<String, Object?> toRow() {
    return {
      nameColumn: name,
      bildColumn: bild,
      profilBildIdColumn: profilBildId,
    };
  }

  @override
  bool operator ==(covariant ProfilBild other) {
    return profilBildId == other.profilBildId;
  }

  @override
  int get hashCode => profilBildId.hashCode;
}
