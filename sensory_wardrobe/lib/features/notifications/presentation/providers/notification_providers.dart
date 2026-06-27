import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/notification_service.dart';

// ── Service singleton ─────────────────────────────────────────────────────────

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ── Initialization future (called once at app startup) ────────────────────────

final notificationInitProvider = FutureProvider<void>((ref) async {
  await ref.watch(notificationServiceProvider).initialize();
});
