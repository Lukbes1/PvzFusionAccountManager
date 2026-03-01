class InfoDatei {
  final String name;
  final String path;

  static const String nameColumn = "name";
  static const String pathColumn = "path";
  static const String infoDateiTable = "InfoDatei";

  InfoDatei({required this.name, required this.path});

  factory InfoDatei.fromRow(Map<String, Object?> row) {
    return InfoDatei(
      name: row[nameColumn] as String,
      path: row[pathColumn] as String,
    );
  }

  Map<String, Object?> toRow() {
    return {nameColumn: name, pathColumn: path};
  }
}
