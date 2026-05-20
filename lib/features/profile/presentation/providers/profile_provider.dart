import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/domain/entities/user_progress_entity.dart';
import 'package:runner085/features/auth/presentation/providers/auth_provider.dart';

/// Provider for user progress stats
final userProgressProvider =
    FutureProvider<UserProgressEntity?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  // TODO: Fetch from user progress repository
  return null;
});
