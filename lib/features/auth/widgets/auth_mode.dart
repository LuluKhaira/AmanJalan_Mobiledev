/// Menyimpan pilihan siang/malam supaya Welcome, Login, dan Daftar kompak.
class AuthMode {
  AuthMode._();

  /// null = belum pernah dipilih, ikuti jam perangkat.
  static bool? night;

  static bool resolve() => night ?? _isNightNow();

  static bool _isNightNow() {
    final h = DateTime.now().hour;
    return h >= 18 || h < 5;
  }
}