import 'dart:io';

import 'package:pvz_fusion_acc_manager/models/data/datei.dart';

class CreateAccountDialogResult {
  final String name;
  final int profilBildId;
  final List<Datei> existingAccountFiles;
  final Directory? customFiles;

  const CreateAccountDialogResult({
    required this.name,
    required this.profilBildId,
    required this.existingAccountFiles,
    required this.customFiles,
  });
}
