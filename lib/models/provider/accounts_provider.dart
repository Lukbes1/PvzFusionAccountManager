import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/datei.dart';
import 'package:pvz_fusion_acc_manager/models/data/startup_files_state.dart';
import 'package:pvz_fusion_acc_manager/models/data/version.dart';
import 'package:pvz_fusion_acc_manager/models/provider/datei_service_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/explorer_file_service_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/game_service_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/startup_files_provider.dart';
import 'package:pvz_fusion_acc_manager/models/provider/profil_bild_provider.dart';
import 'package:pvz_fusion_acc_manager/models/service/accounts_service.dart';
import 'package:pvz_fusion_acc_manager/models/provider/db_provider.dart';
import 'package:pvz_fusion_acc_manager/models/service/game_service.dart';
import 'package:riverpod/riverpod.dart';

final accountServiceProvider = FutureProvider<AccountService>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return AccountService(db);
});

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, List<Account>>(
  AccountsNotifier.new,
);

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  StreamSubscription? _pvzFusionProcessSub;
  @override
  Future<List<Account>> build() async {
    final service = await ref.read(accountServiceProvider.future);
    final gameService = await ref.read(gameServiceProvider.future);
    _pvzFusionProcessSub = gameService.prvzFusionProcessEvent.listen(
      _onPvzFusionProcessEvent,
    );

    ref.onDispose(() {
      _pvzFusionProcessSub?.cancel();
    });
    return service.getAllAccounts();
  }

  Future<void> _onPvzFusionProcessEvent(PVZFusionProcessEvent event) async {
    if (event is PVZFusionProcessStarted) {
    } else if (event is PVZFusionProcessStopped) {
      if (await isSomeonePlaying() && event.exitCode != -1) {
        final badExecution = event.exitCode == 1;
        await stopPlayingWithCurrent(
          skipSavingStage: badExecution,
          skipKillingGame: true,
        );
        if (badExecution) {
          state = AsyncError("The exe could not be opened", StackTrace.current);
        }
      }
    }
  }

  Future<void> load() async {
    state = const AsyncLoading();

    try {
      final service = await ref.read(accountServiceProvider.future);

      final accounts = await service.getAllAccounts();

      state = AsyncData(accounts);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> add({
    required final String name,
    required final int profilBildId,
    final List<Datei>? fromExistingDateien,
    final Directory? fromExistingFilesDir,
  }) async {
    if (fromExistingDateien != null && fromExistingFilesDir != null) {
      throw "Existing files and existing dateien must not be set both at the same time";
    }
    final service = await ref.read(accountServiceProvider.future);
    try {
      final newAccountId = await service.createAccount(name, profilBildId);
      final newAccount = await service.getAccount(newAccountId);
      await ref
          .read(profilBildForAccountProvider.notifier)
          .add(account: newAccount);
      final dateiService = await ref.read(dateiServiceProvider.future);
      if (fromExistingDateien?.isNotEmpty ?? false) {
        final infoDateiService = await ref.read(
          infoDateienServiceProvider.future,
        );
        final explorerFileService = ref.read(explorerFileServiceProvider);
        final pvzFusionDir = (await infoDateiService.getInfoDatei(
          name: 'pvzFusionDir',
        ))?.path;
        if (pvzFusionDir == null) {
          throw "Could not find pvz Fusion dir";
        }
        final Directory pvzFusionDirectory = Directory(pvzFusionDir);
        explorerFileService.writeToPvzFusionData(
          pvzFusionDirectory,
          fromExistingDateien!,
        );
        dateiService.addFilesFromDirToAccount(
          dir: pvzFusionDirectory,
          account: newAccount,
          newVersion: false,
        );
      }
      if (fromExistingFilesDir != null) {
        dateiService.addFilesFromDirToAccount(
          dir: fromExistingFilesDir,
          account: newAccount,
          newVersion: false,
        );
      }

      state = AsyncData(
        [...state.value!, newAccount]..sort((a, b) => a.compareTo(b)),
      );
    } on AccountAlreadyExistsException catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateName({
    required final Account accountToUpdate,
    required final String newName,
  }) async {
    final accountsService = await ref.read(accountServiceProvider.future);
    try {
      accountsService.updateName(
        accountId: accountToUpdate.accountId,
        newName: newName,
      );
      final accounts = state.value ?? <Account>[];
      final List<Account> newAccounts = [];
      for (final account in accounts) {
        if (account == accountToUpdate) {
          newAccounts.add(account.copyWith(name: newName));
        } else {
          newAccounts.add(account);
        }
      }
      state = AsyncData(newAccounts);
      log('Changed name of \'${accountToUpdate.name}\' to \'$newName\'');
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateProfilBild({
    required final Account accountToUpdate,
    required final int newProfilbildId,
  }) async {
    final accountsService = await ref.read(accountServiceProvider.future);
    try {
      accountsService.updateProfilbild(
        accountId: accountToUpdate.accountId,
        newProfilbild: newProfilbildId,
      );
      final accounts = state.value ?? <Account>[];
      final List<Account> newAccounts = [];
      await ref
          .read(profilBildForAccountProvider.notifier)
          .updateProfilBild(
            accountToUpdate: accountToUpdate,
            profilBildId: newProfilbildId,
          );
      for (final account in accounts) {
        if (account == accountToUpdate) {
          newAccounts.add(account.copyWith(profilBildId: newProfilbildId));
        } else {
          newAccounts.add(account);
        }
      }
      state = AsyncData(newAccounts);

      log(
        'Changed profilBild of \'${accountToUpdate.name}\' to \'$newProfilbildId\'',
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> delete(int id) async {
    final service = await ref.read(accountServiceProvider.future);

    await service.deleteAccount(id);

    state = AsyncData(
      state.value!.where((a) => a.accountId != id).toList()
        ..sort((a, b) => a.compareTo(b)),
    );
  }

  Future<void> switchToVersion({
    required final int accountId,
    required final Version newVersion,
  }) async {
    state = const AsyncValue.loading();
    final service = await ref.read(accountServiceProvider.future);

    await service.switchVersion(accountId: accountId, toVersion: newVersion);
    final accounts = state.value ?? <Account>[];
    final List<Account> newAccounts = [];
    Account? newAccount;
    for (final account in accounts) {
      if (account.accountId == accountId) {
        newAccount = account.copyWith(
          letzteVersionDate: newVersion.creationDate,
        );
        newAccounts.add(newAccount);
      } else {
        newAccounts.add(account);
      }
    }
    state = AsyncData(newAccounts..sort((a, b) => a.compareTo(b)));
    if (newAccount != null) {
      ref.read(currentlySelectedAccountProvider.notifier).set(newAccount);
    }
  }

  Future<List<Account>> getAllCached() async {
    List<Account> result = [];
    state.when(
      data: (list) => result = list,
      error: (error, stackTrace) {
        throw NoAccountsCachedException();
      },
      loading: () {},
    );
    return result;
  }

  Future<bool> isSomeonePlaying() async {
    return await getCurrentlyPlaying() != null;
  }

  Future<void> stopPlayingWithCurrent({
    bool skipSavingStage = false,
    bool skipKillingGame = false,
  }) async {
    final currentlyPlaying = await getCurrentlyPlaying();
    if (currentlyPlaying == null) {
      throw NoAccountIsPlayingException();
    }
    final gameService = await ref.read(gameServiceProvider.future);
    final pvzFusionDir = (await ref.read(
      startupFilesProvider.future,
    )).getStartupFile(StartupFileType.pvzFusionDir);
    final errorMessage = await gameService.stopAccount(
      accountToStop: currentlyPlaying,
      skipSavingStage: skipSavingStage,
      pvzFusionDir: Directory(pvzFusionDir!.infoDatei.path),
      skipKillingGame: skipKillingGame,
    );
    if (errorMessage != null) {
      state = AsyncError(
        "The account could not be stopped:\n$errorMessage",
        StackTrace.current,
      );
      return;
    }

    final accounts = state.value;
    if (accounts == null) return;

    state = AsyncData(
      [
        for (final acc in accounts)
          if (acc == currentlyPlaying) acc.copyWith(inGame: 0) else acc,
      ]..sort((a, b) => a.compareTo(b)),
    );
  }

  Future<void> startPlayingWithCurrent() async {
    final currentAccount = ref.read(currentlySelectedAccountProvider);
    if (currentAccount == null) {
      throw NoAccountIsSelectedException();
    }
    final gameService = await ref.read(gameServiceProvider.future);
    final pvzFusionDir = (await ref.read(
      startupFilesProvider.future,
    )).getStartupFile(StartupFileType.pvzFusionDir);
    final pvzFusionExe = (await ref.read(
      startupFilesProvider.future,
    )).getStartupFile(StartupFileType.pvzFusionExe);
    final errorMessage = await gameService.startAccount(
      currentAccount,
      File(pvzFusionExe!.infoDatei.path),
      Directory(pvzFusionDir!.infoDatei.path),
    );
    if (errorMessage != null) {
      state = AsyncError(
        "The account could not be started: \n$errorMessage",
        StackTrace.current,
      );
      return;
    }

    final accounts = state.value;
    if (accounts == null) return;

    state = AsyncData([
      for (final acc in accounts)
        if (acc == currentAccount) acc.copyWith(inGame: 1) else acc,
    ]);
  }

  Future<Account?> getCurrentlyPlaying() async {
    final accounts = state.value;
    if (accounts == null) {
      return null;
    }
    if (accounts.any((a) => a.inGame == 1)) {
      return accounts.firstWhere((a) => a.inGame == 1);
    }
    return null;
  }
}

class NoAccountIsPlayingException {}

class NoAccountIsSelectedException {}

class NoAccountsCachedException {}

class SelectedAccountNotifier extends Notifier<Account?> {
  @override
  Account? build() {
    return null;
  }

  void set(Account acc) {
    if (state == acc) {
      clear();
    } else {
      state = acc;
    }
  }

  void clear() {
    state = null;
  }
}

final currentlySelectedAccountProvider =
    NotifierProvider<SelectedAccountNotifier, Account?>(
      () => SelectedAccountNotifier(),
    );

final currentlyPlayingAccountProvider = Provider<Account?>((ref) {
  final accountsAsync = ref.watch(accountsProvider);

  return accountsAsync.maybeWhen(
    data: (data) {
      return data.where((acc) => acc.inGame == 1).singleOrNull;
    },
    orElse: () => null,
  );
});

final isSomeonePlayingProvider = Provider<bool>((ref) {
  final accountsAsync = ref.watch(accountsProvider);

  return accountsAsync.maybeWhen(
    data: (accounts) => accounts.any((a) => a.inGame == 1),
    orElse: () => false,
  );
});
