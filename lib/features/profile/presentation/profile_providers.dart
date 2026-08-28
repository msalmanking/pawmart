import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/profile_repository.dart';
import '../domain/user_profile.dart';
import '../../../core/push/push_service.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(Supabase.instance.client),
);

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchProfile();
});

Future<void> updateProfile(WidgetRef ref,
    {String? fullName, String? phone}) async {
  final repo = ref.read(profileRepositoryProvider);
  await repo.updateProfile(fullName: fullName, phone: phone);
  ref.invalidate(userProfileProvider);
}

Future<void> signOutUser(WidgetRef ref) async {
  await PushService.unregisterToken();
  final repo = ref.read(profileRepositoryProvider);
  await repo.signOut();
}
