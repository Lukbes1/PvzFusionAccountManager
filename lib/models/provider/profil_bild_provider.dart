import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:pvz_fusion_acc_manager/models/provider/db_provider.dart';
import 'package:pvz_fusion_acc_manager/models/service/profil_bild_service.dart';

final profilBildServiceProvider = FutureProvider((ref) async {
  return ProfilBildService(db: await ref.read(databaseProvider.future));
});

final profilBilderProvider = FutureProvider<List<ProfilBild>>((ref) async {
  final profilBildService = await ref.watch(profilBildServiceProvider.future);
  return profilBildService.getAll();
});

class ProfilBildForAccountProvider extends AsyncNotifier<Map<int, ProfilBild>> {
  @override
  Future<Map<int, ProfilBild>> build() async {
    final Map<int, ProfilBild> profilBilderForAccountId = {};
    final profilBildService = await ref.read(profilBildServiceProvider.future);
    final accounts = await ref.read(accountsProvider.future);
    for (final Account account in accounts) {
      final ProfilBild profilBild = await profilBildService.get(
        account.profilBildId,
      );
      profilBilderForAccountId.putIfAbsent(account.accountId, () => profilBild);
    }
    return profilBilderForAccountId;
  }

  /// Add the account to the profilBildProvider;
  Future<void> add({required Account account}) async {
    state = const AsyncValue.loading();
    ProfilBild profilBild;
    try {
      final profilBildService = await ref.read(
        profilBildServiceProvider.future,
      );
      profilBild = await profilBildService.get(account.profilBildId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return;
    }
    final currentMap = state.value ?? {};
    final newMap = {...currentMap}
      ..putIfAbsent(account.accountId, () => profilBild);
    state = AsyncValue.data(newMap);
  }

  Future<void> remove({required int accountId}) async {
    state = const AsyncValue.loading();

    final currentMap = state.value ?? {};
    final newMap = {...currentMap}..remove(accountId);

    state = AsyncValue.data(newMap);
  }

  Future<void> updateProfilBild({
    required final Account accountToUpdate,
    required final int profilBildId,
  }) async {
    state = const AsyncValue.loading();
    ProfilBild profilBild;
    try {
      final profilBildService = await ref.read(
        profilBildServiceProvider.future,
      );
      profilBild = await profilBildService.get(profilBildId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return;
    }
    final currentMap = state.value ?? {};
    final newMap = {...currentMap}
      ..update(accountToUpdate.accountId, (pb) => profilBild);
    state = AsyncValue.data(newMap);
  }
}

final profilBildForAccountProvider = AsyncNotifierProvider(() {
  return ProfilBildForAccountProvider();
});
