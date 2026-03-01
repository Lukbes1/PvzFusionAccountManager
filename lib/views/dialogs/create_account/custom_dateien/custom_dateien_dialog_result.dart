import 'dart:io';

import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/datei.dart';

class CustomDateienDialogResult {
  final List<Datei> dateienFromDb;
  final Account? selectedAccount;
  final Directory? directoryForDateienFromDisk;

  const CustomDateienDialogResult({
    required this.dateienFromDb,
    this.selectedAccount,
    this.directoryForDateienFromDisk,
  });
}
