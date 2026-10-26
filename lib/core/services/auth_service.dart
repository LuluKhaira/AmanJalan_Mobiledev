import 'package:shared_preferences/shared_preferences.dart';

/// Mock Authentication Service (Tanpa Backend)
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _kLoggedIn = 'logged_in';
  static const _kUserName = 'user_name';

  Future<void> _fakeDelay([int ms = 1200]) =>
      Future.delayed(Duration(milliseconds: ms));

  Future<AuthResult> login({
    required String id,
    required String password,
  }) async {
    await _fakeDelay();
    if (password.toLowerCase() == 'salah') {
      return const AuthResult.failure('Kata sandi salah (demo).');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    await prefs.setString(_kUserName, id.contains('@') ? id.split('@').first : 'Pengguna');
    return const AuthResult.success();
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _fakeDelay();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    await prefs.setString(_kUserName, name);
    return const AuthResult.success();
  }

  Future<AuthResult> verifyOtp(String code) async {
    await _fakeDelay(900);
    if (code.length != 6) {
      return const AuthResult.failure('Kode harus 6 digit.');
    }
    // Demo: kode apapun 6 digit diterima.
    return const AuthResult.success();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName) ?? 'Pengguna';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class AuthResult {
  final bool ok;
  final String? message;
  const AuthResult._(this.ok, this.message);
  const AuthResult.success() : this._(true, null);
  const AuthResult.failure(String msg) : this._(false, msg);
}