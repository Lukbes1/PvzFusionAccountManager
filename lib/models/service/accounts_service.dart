import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/version.dart';
import 'package:sqflite/sqflite.dart';

class AccountAlreadyExistsException {
  final String name;
  AccountAlreadyExistsException(this.name);
  @override
  String toString() {
    return 'An account already exists with the name: $name';
  }
}

class AccountCouldNotBeDeletedException {
  AccountCouldNotBeDeletedException();
  @override
  String toString() {
    return 'The Account could not be deleted';
  }
}

class AccountNameCouldNotBeUpdatedException {
  AccountNameCouldNotBeUpdatedException();
  @override
  String toString() {
    return 'The Account name couldnt be changed';
  }
}

class AccountProfilBildCouldNotBeUpdatedException {
  AccountProfilBildCouldNotBeUpdatedException();
  @override
  String toString() {
    return 'The Account profile picture couldnt be changed';
  }
}

class AnAccountIsAlreadyPlayingException {
  final String name;
  AnAccountIsAlreadyPlayingException(this.name);
  @override
  String toString() {
    return 'The account $name is already playing. Stop the app via the stop button first';
  }
}

class AccountIsNotPlayingException {
  AccountIsNotPlayingException();
  @override
  String toString() {
    return 'The account is not playing and thus cannot be stopped.';
  }
}

class AccountCouldNotBeSetToStartedException {
  AccountCouldNotBeSetToStartedException();
  @override
  String toString() {
    return 'The account could not be set to playing';
  }
}

class AccountCouldNotBeSetToNotPlaying {
  AccountCouldNotBeSetToNotPlaying();
  @override
  String toString() {
    return 'The account could not be set to not playing';
  }
}

class CouldNotCreateNewVersionException {}

class CouldNotFindCurrVersionException {}

class AccountService {
  final Database _db;

  AccountService(this._db);

  Future<List<Account>> getAllAccounts() async {
    final listOfAccountsMap = await _db.query(Account.accountTable);
    final listOfAccounts = listOfAccountsMap
        .map((map) => Account.fromMap(map))
        .toList();
    for (final account in listOfAccounts) {
      await _appendLatestVersionDate(account);
    }
    return listOfAccounts..sort((a, b) => a.compareTo(b));
  }

  /// Creates the account and its first version
  Future<int> createAccount(String name, int profilBildId) async {
    if (name.isEmpty) {
      throw ArgumentError('Account name cannot be empty');
    }

    // Check if account name already exists
    final existing = await _db.query(
      Account.accountTable,
      where: '${Account.nameColumn} = ?',
      whereArgs: [name],
    );

    if (existing.isNotEmpty) {
      throw AccountAlreadyExistsException(name);
    }

    final now = DateTime.now().toUtc().toIso8601String();
    int accountIdResult = 0;

    await _db.transaction((txn) async {
      // Insert account
      final accountId = await txn.insert(Account.accountTable, {
        Account.nameColumn: name,
        Account.creationDateColumn: now,
        Account.profilBildIdColumn: profilBildId,
      });
      accountIdResult = accountId;

      // Create Account object
      final accountMap = (await txn.query(
        Account.accountTable,
        where: '${Account.accountIdColumn} = ?',
        whereArgs: [accountId],
      )).single;
      final account = Account.fromMap(accountMap);

      // Create first version
      await createNewVersionInTransaction(
        db: txn,
        account: account,
        creationDate: now,
      );
    });

    return accountIdResult;
  }

  /// Create a new version for an account
  Future<Version> createNewVersion({
    required Account account,
    final String? creationDate,
  }) => createNewVersionInTransaction(
    db: _db,
    account: account,
    creationDate: creationDate,
  );

  /// Internal version creation
  Future<Version> createNewVersionInTransaction({
    required final DatabaseExecutor db,
    required Account account,
    final String? creationDate,
  }) async {
    final latestVersion = await _getLatestVersion(db, account);

    int newVersionNr = 1;
    if (latestVersion != null) {
      newVersionNr = latestVersion.versionNr + 1;
    }

    String nowCreationDate =
        creationDate ?? DateTime.now().toUtc().toIso8601String();

    final newVersion = Version(
      creationDate: nowCreationDate,
      accountId: account.accountId,
      versionNr: newVersionNr,
    );

    final result = await db.insert(Version.versionTable, newVersion.toRow());
    if (result == 0) {
      throw CouldNotCreateNewVersionException();
    }
    account.upgradeVersion(newVersion.creationDate);

    return newVersion;
  }

  Future<Version?> _getLatestVersion(
    DatabaseExecutor db,
    final Account account,
  ) async {
    final latestVersionQuery = await db.query(
      Version.versionTable,
      where: '${Version.accountIdColumn} = ?',
      whereArgs: [account.accountId],
      orderBy: '${Version.creationDateColumn} DESC',
      limit: 1,
    );
    Version? version;
    if (latestVersionQuery.isNotEmpty) {
      version = Version.fromRow(latestVersionQuery.single);
    }
    return version;
  }

  Future<Account> getAccount(int id) async {
    final accountRow = await _db.query(
      Account.accountTable,
      where: '${Account.accountIdColumn} = ?',
      whereArgs: [id],
      limit: 1,
    );

    final account = Account.fromMap(accountRow.first);
    _appendLatestVersionDate(account);
    return account;
  }

  Future<void> _appendLatestVersionDateInTransaction(
    DatabaseExecutor db,
    Account account,
  ) async {
    final lastVersion = await _getLatestVersion(_db, account);
    if (lastVersion != null) {
      account.upgradeVersion(lastVersion.creationDate);
    }
  }

  Future<void> _appendLatestVersionDate(Account account) async =>
      _appendLatestVersionDateInTransaction(_db, account);

  Future<void> deleteAccount(int id) async {
    final deletion = await _db.delete(
      Account.accountTable,
      where: '${Account.accountIdColumn} = ?',
      whereArgs: [id],
    );
    if (deletion <= 0) {
      throw AccountCouldNotBeDeletedException();
    }
  }

  Future<void> updateName({
    required final int accountId,
    required final String newName,
  }) async {
    final updates = await _db.update(
      Account.accountTable,
      {Account.nameColumn: newName},
      where: '${Account.accountIdColumn} = ?',
      whereArgs: [accountId],
    );
    if (updates == 0) {
      throw AccountNameCouldNotBeUpdatedException();
    }
  }

  Future<void> updateProfilbild({
    required final int accountId,
    required final int newProfilbild,
  }) async {
    final updates = await _db.update(
      Account.accountTable,
      {Account.profilBildIdColumn: newProfilbild},
      where: '${Account.accountIdColumn} = ?',
      whereArgs: [accountId],
    );
    if (updates == 0) {
      throw AccountProfilBildCouldNotBeUpdatedException();
    }
  }

  ///Switch to the new Version and kill all newer Versions
  Future<int> switchVersion({
    required final int accountId,
    required final Version toVersion,
  }) async {
    return await _db.delete(
      Version.versionTable,
      where:
          '${Version.accountIdColumn} = ? and ${Version.creationDateColumn} > ?',
      whereArgs: [accountId, toVersion.creationDate],
    );
  }

  Future<Account?> isSomeonePlayingWithTransaction(DatabaseExecutor txn) async {
    final peopleAlreadyPlaying = await txn.query(
      Account.accountTable,
      where: '${Account.inGameColumn} = 1',
    );
    if (peopleAlreadyPlaying.isNotEmpty) {
      return Account.fromMap(peopleAlreadyPlaying.single);
    }
    return null;
  }

  Future<Account?> isSomeonePlaying() async =>
      isSomeonePlayingWithTransaction(_db);

  Future<bool> isAccountPlaying(final Account account) async =>
      isAccountPlayingWithTransaction(account, _db);

  Future<bool> isAccountPlayingWithTransaction(
    final Account account,
    DatabaseExecutor txn,
  ) async {
    final foundAccount = await txn.query(
      Account.accountTable,
      where: '${Account.accountIdColumn} = ? AND ${Account.inGameColumn} = 1',
      whereArgs: [account.accountId],
      limit: 1,
    );
    return foundAccount.isNotEmpty;
  }

  Future<void> playWith(DatabaseExecutor txn, final Account account) async {
    final someonePlayingAcc = await isSomeonePlayingWithTransaction(txn);
    if (someonePlayingAcc != null) {
      throw AnAccountIsAlreadyPlayingException(someonePlayingAcc.name);
    }
    final result = await txn.update(
      Account.accountTable,
      {Account.inGameColumn: 1},
      where: '${Account.accountIdColumn} = ?',
      whereArgs: [account.accountId],
    );
    if (result == 0) {
      throw AccountCouldNotBeSetToStartedException();
    }
    account.start();
  }

  Future<void> stopPlayingWith(DatabaseExecutor txn, final Account acc) async {
    if (!await isAccountPlayingWithTransaction(acc, txn)) {
      throw AccountIsNotPlayingException();
    }

    final result = await txn.update(
      Account.accountTable,
      {Account.inGameColumn: 0},
      where: '${Account.accountIdColumn} = ?',
      whereArgs: [acc.accountId],
    );
    if (result == 0) {
      throw AccountCouldNotBeSetToNotPlaying();
    }
    acc.stop();
  }
}
