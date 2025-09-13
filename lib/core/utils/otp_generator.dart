import 'dart:math';

class OTPGenerator {
  static String generateOTP() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // 4-значный код
  }
}
