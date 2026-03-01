import 'package:pvz_fusion_acc_manager/models/service/explorer_file_service.dart';
import 'package:riverpod/riverpod.dart';

final explorerFileServiceProvider = Provider((ref) {
  return ExplorerFileService();
});
