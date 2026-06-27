import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  /// 익명 계정 → Google 계정 연결.
  ///
  /// google_sign_in ^6.x Android: GoogleSignIn 생성자에 nonce 파라미터 없음.
  /// accessToken을 함께 전달해 Supabase가 Google 토큰을 검증할 수 있도록 한다.
  /// user_id 유지 여부는 Supabase 서버 설정에 따라 다름 — 실기기 확인 필수.
  Future<void> linkGoogle() async {
    final googleUser = await GoogleSignIn(
      serverClientId: const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
    ).signIn();

    if (googleUser == null) return; // 사용자 취소

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw Exception('Google ID token 없음');

    try {
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      debugPrint('[Auth] Google 연결 완료: ${_client.auth.currentUser?.id}');
    } catch (e, st) {
      debugPrint('[AUTH] linkGoogle 실패: $e');
      debugPrint('[AUTH] stackTrace: $st');
      rethrow;
    }
  }
}
