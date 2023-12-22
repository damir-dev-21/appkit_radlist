abstract class ValidationUtils {
  static final mobilePhonePattern = RegExp(r'(^\+?77([0124567][0-8]\d{7})$)');
  static final binPattern = RegExp(r'^\d{12}$');
  static final emailPattern =
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool isValidMobilePhone(String input) {
    return mobilePhonePattern.hasMatch(input);
  }

  static bool isValidBin(String input) {
    return binPattern.hasMatch(input);
  }

  static bool isValidEmail(String input) {
    return emailPattern.hasMatch(input);
  }
}
