import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: 추후 mylibrary_core 패키지로 이동 예정
class AuthService {
  AuthService(this._client);

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
  User? get currentUser => _client.auth.currentUser;

  /// Google identity 연결 여부.
  bool get isGoogleLinked =>
      currentUser?.identities?.any((i) => i.provider == 'google') ?? false;

  /// 연결된 Google 계정 이메일 (미연결이면 null).
  String? get linkedGoogleEmail => currentUser?.identities
      ?.where((i) => i.provider == 'google')
      .map((i) => i.identityData?['email'] as String?)
      .firstOrNull;

  /// 익명 계정 → Google 계정 연결 (브라우저 redirect 방식).
  ///
  /// linkIdentity 호출 시 브라우저가 열리고 Google 로그인 후
  /// io.supabase.classicshelf://login-callback 으로 돌아옴.
  /// 실제 연결 완료는 deep link 처리 후 onAuthStateChange 이벤트로 확인.
  /// 기존 익명 user_id 유지됨 (signInWithIdToken과 달리).
  ///
  /// 이 스킴은 AndroidManifest.xml의 intent-filter, Supabase 대시보드의
  /// Redirect URLs 와 항상 같아야 한다. 하나라도 어긋나면 연결이
  /// redirect_to is not allowed 로 거부된다.
  Future<void> linkGoogle() async {
    await Supabase.instance.client.auth.linkIdentity(
      OAuthProvider.google,
      redirectTo: 'io.supabase.classicshelf://login-callback',
    );
  }
}
