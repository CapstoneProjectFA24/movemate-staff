import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_trackers_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/image_section.dart';

class ImageInfoSection extends StatelessWidget {
  final ValueNotifier<bool> isExpanded1;
  final Function() toggleDropdown1;
  final Map<String, List<String>> groupedImages;

  const ImageInfoSection({
    Key? key,
    required this.isExpanded1,
    required this.toggleDropdown1,
    required this.groupedImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông tin hình ảnh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isExpanded1.value
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: Colors.black54,
                  ),
                  onPressed: toggleDropdown1,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isExpanded1.value)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (groupedImages.isEmpty)
                      const Center(
                        child: Text('Không có hình ảnh'),
                      )
                    else
                      ...groupedImages.entries.map((entry) => Section(
                            title: getDisplayTitle(entry.key),
                            imageUrls: entry.value,
                          )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
