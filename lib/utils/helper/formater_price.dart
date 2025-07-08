import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = '.';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(separator, '');

    try {
      final number = int.parse(newText);
      final formatter = NumberFormat('#,###');
      formatter.format(number);
    } catch (e) {
      return oldValue;
    }

    final formatter = NumberFormat.decimalPattern('id_ID');
    String formattedText = formatter.format(int.parse(newText));

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
