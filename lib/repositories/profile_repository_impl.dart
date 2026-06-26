import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepositoryImpl(this._supabase);

  @override
  Future<DateTime?> getTrackingStartedAt() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final row = await _supabase
          .from('profiles')
          .select('tracking_started_at')
          .eq('user_id', uid)
          .maybeSingle();
      if (row == null) return null;
      final val = row['tracking_started_at'];
      if (val == null) return null;
      return DateTime.parse(val as String);
    } catch (e) {
      debugPrint('[PROFILE] getTrackingStartedAt 실패: $e');
      return null;
    }
  }

  @override
  Future<void> setTrackingStartedAt(DateTime date) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await _supabase.from('profiles').upsert({
      'user_id': uid,
      'tracking_started_at': dateStr,
    });
  }
}
