import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_trackers_response_entity.dart';

String getDisplayTitle(String resourceCode) {
  switch (resourceCode.toLowerCase()) {
    case 'bedroom':
      return 'Phòng ngủ';
    case 'bathroom':
      return 'Phòng tắm';
    case 'livingroom':
      return 'Phòng khách';
    case 'kitchen':
      return 'Nhà bếp';
    case 'officeroom':
      return 'Phòng làm việc';
    default:
      return 'Khác';
  }
}

Map<String, List<String>> getGroupedImages(
    List<BookingTrackersResponseEntity> trackers) {
  Map<String, List<String>> groupedImages = {};

  for (var tracker in trackers) {
    for (var source in tracker.trackerSources) {
      if (source is Map<String, dynamic>) {
        String resourceUrl = source['resourceUrl'] ?? '';
        String resourceCode = source['resourceCode'] ?? 'OTHER';

        if (resourceUrl.isNotEmpty) {
          if (!groupedImages.containsKey(resourceCode)) {
            groupedImages[resourceCode] = [];
          }
          groupedImages[resourceCode]!.add(resourceUrl);
        }
      }
    }
  }

  return groupedImages;
}