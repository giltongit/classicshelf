import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: 추후 mylibrary_core 패키지로 이동 예정
class AuthService {
  const AuthService(this._client);

  final SupabaseClient _client;

  /// 세션이 없을 때만 익명 로그인. 오프라인 실패 시에도 앱 부팅 허용.
  Future<void> ensureSignedIn() async {
    if (_client.auth.currentSession != null) {
      debugPrint('[Auth] 기존 세션 유지: ${_client.auth.currentUser?.id}');
      return;
    }
    try {
      await _client.auth.signInAnonymously();
      debugPrint('[Auth] 익명 로그인 성공: ${_client.auth.currentUser?.id}');
    } catch (e) {
      // 네트워크 오프라인 등 실패 시에도 앱 정상 부팅 (local-first 원칙)
      debugPrint('[Auth] 익명 로그인 실패 (오프라인?): $e');
    }
  }

  String? get currentUserId => _client.auth.currentUser?.id;
}
