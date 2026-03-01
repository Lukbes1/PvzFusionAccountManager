import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/db_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/explorer_file_service_provider.dart';
import 'package:pvz_fusion_acc_manager/models/service/accounts_service.dart';
import 'package:pvz_fusion_acc_manager/models/service/datei_service.dart';
import 'package:pvz_fusion_acc_manager/models/service/explorer_file_service.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final dateiServiceProvider = FutureProvider((ref) async {
  final ExplorerFileService fileService = ref.read(explorerFileServiceProvider);
  final AccountService accountService = await ref.read(
    accountServiceProvider.future,
  );
  final Database db = await ref.read(databaseProvider.future);
  return DateiService(
    db: db,
    explorerFileService: fileService,
    accountService: accountService,
  );
});
