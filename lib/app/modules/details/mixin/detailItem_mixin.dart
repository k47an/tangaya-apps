import 'package:get/get.dart';

mixin DetailItemMixin {
  late final String itemType;
  late final String itemId;

  final Rx<dynamic> detailItem = Rx<dynamic>(null);
}
