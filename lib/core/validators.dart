/// Input rules for UC1 BR4 and UC3 BR22.
class Validators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _phone = RegExp(r'^(0|\+84)\d{9}$');

  static bool isEmail(String value) => _email.hasMatch(value.trim());

  /// Vietnamese mobile number: 0xxxxxxxxx or +84xxxxxxxxx.
  static bool isPhone(String value) =>
      _phone.hasMatch(value.replaceAll(' ', ''));

  static String normalizePhone(String value) {
    final compact = value.replaceAll(' ', '');
    return compact.startsWith('+84') ? '0${compact.substring(3)}' : compact;
  }

  /// At least 8 characters with a letter and a digit.
  static bool isStrongPassword(String value) =>
      value.length >= 8 &&
      value.contains(RegExp(r'[A-Za-z]')) &&
      value.contains(RegExp(r'\d'));

  static bool isValidNewPassword(String password, String confirm) =>
      isStrongPassword(password) && password == confirm;
}
