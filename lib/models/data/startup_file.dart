import 'package:pvz_fusion_acc_manager/models/data/info_datei.dart';

class StartupFile {
  final InfoDatei infoDatei;
  final bool exists;

  const StartupFile({required this.exists, required this.infoDatei});

  StartupFile copyWith({bool? exists, InfoDatei? infoDatei}) {
    return StartupFile(
      exists: exists ?? this.exists,
      infoDatei: infoDatei ?? this.infoDatei,
    );
  }
}
