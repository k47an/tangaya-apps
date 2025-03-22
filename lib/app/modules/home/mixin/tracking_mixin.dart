import 'package:get/get.dart';
import '../models/tracking_model.dart';
import '../services/tracking_service.dart';

mixin TrackingMixin on GetxController {
  final TrackingService _trackingService = TrackingService();

  var trackingList = <TrackingModel>[].obs;
  var isLoadingTracking = false.obs;

  void fetchTrackingList() async {
    isLoadingTracking(true);
    try {
      var list = await _trackingService.getTrackingList();
      trackingList.assignAll(list);
      // ✅ Print data ke debug console
      print("🔥 Data Tracking: ${trackingList.map((e) => e.toMap()).toList()}");
    } finally {
      isLoadingTracking(false);
    }
  }
}
