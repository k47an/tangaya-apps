part of 'constant.dart';

InputDecoration primary = InputDecoration(
  isDense: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Neutral.dark5),
    borderRadius: BorderRadius.circular(30),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Neutral.dark1),
    borderRadius: BorderRadius.circular(30),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Error.lightColor),
    borderRadius: BorderRadius.circular(30),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Error.lightColor),
    borderRadius: BorderRadius.circular(30),
  ),
);

InputDecoration searchStyle = InputDecoration(
  isDense: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Neutral.dark5, width: 2),
    borderRadius: BorderRadius.circular(20),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Neutral.dark1, width: 2),
    borderRadius: BorderRadius.circular(20),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Error.lightColor, width: 2),
    borderRadius: BorderRadius.circular(20),
  ),
);

InputDecoration textBoxStyle = InputDecoration(
  isDense: true,
  enabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Neutral.dark4, width: 1),
    borderRadius: BorderRadius.circular(8),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Neutral.dark1, width: 1),
    borderRadius: BorderRadius.circular(8),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Error.lightColor, width: 1),
    borderRadius: BorderRadius.circular(8),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Error.lightColor, width: 1),
    borderRadius: BorderRadius.circular(8),
  ),
);
