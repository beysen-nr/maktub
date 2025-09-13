import 'package:flutter/services.dart';

class IinInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length > 12) {
      digitsOnly = digitsOnly.substring(0, 12);
    }

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      formatted += digitsOnly[i];
      if ((i == 1 || i == 3 || i == 5) && i != digitsOnly.length - 1) {
        formatted += ' ';
      }
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Удаляем всё, кроме цифр
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Гарантируем, что начинается с 77
    if (!digits.startsWith('77')) {
      digits = '77${digits.replaceFirst(RegExp(r'^7*'), '')}';
    }

    // Обрезаем до 11 цифр (включая 77)
    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    // Форматируем как +7 7XX XXX XX XX
    String formatted = '+7';
    if (digits.length > 1) {
      formatted += ' ${digits[1]}';
    }
    if (digits.length > 2) {
      formatted += digits.substring(2, digits.length > 4 ? 4 : digits.length);
    }
    if (digits.length > 4) {
      formatted +=
          ' ${digits.substring(4, digits.length > 7 ? 7 : digits.length)}';
    }
    if (digits.length > 7) {
      formatted +=
          ' ${digits.substring(7, digits.length > 9 ? 9 : digits.length)}';
    }
    if (digits.length > 9) {
      formatted += ' ${digits.substring(9, digits.length)}';
    }

    formatted = formatted.trimRight();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
