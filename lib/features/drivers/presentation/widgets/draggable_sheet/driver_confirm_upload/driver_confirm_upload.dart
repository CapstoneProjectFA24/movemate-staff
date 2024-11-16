import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/drivers/data/models/request/update_resourse_request.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';
import 'package:movemate_staff/utils/commons/widgets/cloudinary/cloudinary_camera_upload_widget.dart';

@RoutePage()
class DriverConfirmUpload extends HookConsumerWidget {
  final BookingResponseEntity job;

  const DriverConfirmUpload({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy thông tin từ bookingTrackers
    final bookingTrackers = job.bookingTrackers ?? [];

    // Lọc các trackerSources cho DRIVER_ARRIVED và DRIVER_COMPLETED
    final driverArrivedImages = bookingTrackers
        .where((tracker) => tracker.type == "DRIVER_ARRIVED")
        .expand((tracker) => tracker.trackerSources)
        .where((source) => source.containsKey(
            'resourceUrl')) // Kiểm tra sự tồn tại của 'resourceUrl'
        .map((source) =>
            source['resourceUrl'].toString()) // Chuyển resourceUrl thành chuỗi
        .toList();

    final driverCompletedImages = bookingTrackers
        .where((tracker) => tracker.type == "DRIVER_COMPLETED")
        .expand((tracker) => tracker.trackerSources)
        .map((source) => source['resourceUrl']
            .toString()) // Truy cập đúng thuộc tính resourceUrl
        .toList();

    // Color constants
    const primaryOrange = Color(0xFFFF6B00);
    const secondaryOrange = Color(0xFFFFE5D6);
    const darkGrey = Color(0xFF4A4A4A);
    const disabledGrey = Color(0xFFE0E0E0);

    // Image states
    final images1 = useState<List<String>>([]);
    final imagePublicIds1 = useState<List<String>>([]);
    final images2 = useState<List<String>>([]);
    final imagePublicIds2 = useState<List<String>>([]);
    final images3 = useState<List<String>>([]);
    final imagePublicIds3 = useState<List<String>>([]);
    final fullScreenImage = useState<String?>(null);
    final request = useState(UpdateResourseRequest(resourceList: []));
    final uploadedImages = ref.watch(uploadedImagesProvider);
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final status = useBookingStatus(bookingAsync.value, job.isReviewOnline);
    print("check 12  ${driverArrivedImages}"); // Kiểm tra dữ liệu có đúng không
    print("check 13 $driverCompletedImages"); // Kiểm tra dữ liệu có đúng không
    print("check 14 imagePublicIds1: ${imagePublicIds1.value}");

    Widget buildConfirmationSection({
      required String title,
      required List<String> imagePublicIds,
      required Function(String, String) onImageUploaded,
      required Function(String) onImageRemoved,
      required Function(String) onImageTapped,
      required VoidCallback onActionPressed,
      required String actionButtonLabel,
      required IconData actionIcon,
      required bool isEnabled,
      required bool showCameraButton,
      required UpdateResourseRequest request,
    }) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : disabledGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isEnabled ? primaryOrange : disabledGrey,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? darkGrey : disabledGrey,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? secondaryOrange
                        : disabledGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${imagePublicIds.length} ảnh',
                    style: TextStyle(
                      color: isEnabled ? primaryOrange : disabledGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (title != "Xác nhận vận chuyển")
              CloudinaryCameraUploadWidget(
                  disabled: !isEnabled,
                  imagePublicIds: imagePublicIds,
                  onImageUploaded: (url, publicId) {
                    images1.value = [...images1.value, url];
                    imagePublicIds1.value = [
                      ...imagePublicIds1.value,
                      publicId
                    ];
                  },
                  onImageRemoved: isEnabled ? onImageRemoved : (_) {},
                  onImageTapped: onImageTapped,
                  showCameraButton: showCameraButton,
                  optionalButton: imagePublicIds.isNotEmpty ||
                          title == "Xác nhận vận chuyển"
                      ? ElevatedButton.icon(
                          onPressed: isEnabled ? onActionPressed : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isEnabled ? primaryOrange : disabledGrey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Icon(actionIcon),
                          label: FittedBox(child: Text(actionButtonLabel)),
                        )
                      : null,
                  onUploadComplete: (resource) {
                    switch (title) {
                      case 'Xác nhận đến':
                        request.resourceList.add(resource);
                        break;
                      case 'Xác nhận vận chuyển':
                        // Do nothing, no image upload here
                        break;
                      case 'Xác nhận giao hàng':
                        request.resourceList.add(resource);
                        break;
                    }
                  }),
            if (title == "Xác nhận vận chuyển")
              ElevatedButton.icon(
                onPressed: isEnabled ? onActionPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnabled ? primaryOrange : disabledGrey,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(actionIcon),
                label: FittedBox(child: Text(actionButtonLabel)),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryOrange,
        elevation: 0,
        title: const Text(
          'Xác nhận giao hàng',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            height: 50,
            decoration: const BoxDecoration(
              color: primaryOrange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  //case 1: DRIVER_ARRIVED images
                  buildConfirmationSection(
                    title: 'Xác nhận đã đến',
                    imagePublicIds: driverArrivedImages,
                    onImageUploaded: (url, publicId) {
                      images1.value = [...images1.value, url];
                      imagePublicIds1.value = [
                        ...imagePublicIds1.value,
                        publicId
                      ];
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds1.value = imagePublicIds1.value
                          .where((id) => id != publicId)
                          .toList();
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,
                    onActionPressed: () async {
                      // Xử lý khi tài xế xác nhận đã đến
                      final request = UpdateResourseRequest(
                        resourceList: uploadedImages,
                      );

                      await ref
                          .read(driverControllerProvider.notifier)
                          .updateStatusDriverResourse(
                            id: job.id,
                            request: request,
                            context: context,
                          );
                      bookingAsync.isRefreshing;
                    },
                    actionButtonLabel: 'Xác nhận đến',
                    actionIcon: Icons.location_on,
                    isEnabled: status.canDriverConfirmArrived,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),

                  //case 3: DRIVER_COMPLETED images
                  buildConfirmationSection(
                    title: 'Xác nhận giao hàng',
                    imagePublicIds: driverCompletedImages,
                    onImageUploaded: (url, publicId) {
                      images3.value = [...images3.value, url];
                      imagePublicIds3.value = [
                        ...imagePublicIds3.value,
                        publicId
                      ];
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds3.value = imagePublicIds3.value
                          .where((id) => id != publicId)
                          .toList();
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,
                    onActionPressed: () async {
                      final request = UpdateResourseRequest(
                        resourceList: uploadedImages,
                      );

                      await ref
                          .read(driverControllerProvider.notifier)
                          .updateStatusDriverResourse(
                            id: job.id,
                            request: request,
                            context: context,
                          );
                      // Xử lý khi giao hàng thành công
                      print("Handling delivery confirmation");
                      bookingAsync.isRefreshing;
                    },
                    actionButtonLabel: 'Xác nhận giao hàng',
                    actionIcon: Icons.check_circle,
                    isEnabled: status.canDriverCompleteDelivery,
                    showCameraButton: true,
                    request: request.value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
