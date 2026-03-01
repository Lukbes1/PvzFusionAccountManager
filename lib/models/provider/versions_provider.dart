import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pvz_fusion_acc_manager/models/provider/db_provider.dart';
import 'package:pvz_fusion_acc_manager/models/service/versions_service.dart';

final versionsServiceProvider = FutureProvider<VersionsService>((ref) async {
  final db = await ref.read(databaseProvider.future);
  return VersionsService(db: db);
});
