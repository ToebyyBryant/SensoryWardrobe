import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/backup_service.dart';

// ── Service ───────────────────────────────────────────────────────────────────

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

// ── Backup / restore state ────────────────────────────────────────────────────

enum BackupStatus { idle, inProgress, success, error }

class BackupState {
  final BackupStatus status;
  final String? message;

  const BackupState({this.status = BackupStatus.idle, this.message});

  BackupState copyWith({BackupStatus? status, String? message}) =>
      BackupState(
        status: status ?? this.status,
        message: message ?? this.message,
      );
}

final backupNotifierProvider =
    StateNotifierProvider<BackupNotifier, BackupState>(
  (ref) => BackupNotifier(ref.watch(backupServiceProvider)),
);

class BackupNotifier extends StateNotifier<BackupState> {
  final BackupService _service;

  BackupNotifier(this._service) : super(const BackupState());

  Future<void> backup() async {
    state = const BackupState(status: BackupStatus.inProgress);
    try {
      await _service.backupToCloud();
      state = const BackupState(
        status: BackupStatus.success,
        message: 'Backup completed successfully.',
      );
    } catch (e) {
      state = BackupState(
        status: BackupStatus.error,
        message: e.toString(),
      );
    }
  }

  Future<void> restore() async {
    state = const BackupState(status: BackupStatus.inProgress);
    try {
      await _service.restoreFromCloud();
      state = const BackupState(
        status: BackupStatus.success,
        message: 'Data restored successfully.',
      );
    } catch (e) {
      state = BackupState(
        status: BackupStatus.error,
        message: e.toString(),
      );
    }
  }

  void reset() => state = const BackupState();
}
