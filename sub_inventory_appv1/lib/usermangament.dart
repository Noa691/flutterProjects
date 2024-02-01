class UserManager {
  static String _userName = '';

  static String get userName => _userName;

  static void setUserName(String userName) {
    _userName = userName;
  }
}
