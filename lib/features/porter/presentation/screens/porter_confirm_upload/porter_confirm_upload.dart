import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/porter/data/models/request/porter_update_resourse_request.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';
import 'package:movemate_staff/utils/commons/widgets/cloudinary/cloudinary_camera_upload_widget.dart';

@RoutePage()
class PorterConfirmScreen extends HookConsumerWidget {
  final BookingResponseEntity job;
  const PorterConfirmScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final images4 = useState<List<String>>([]);
    final imagePublicIds4 = useState<List<String>>([]);
    final images5 = useState<List<String>>([]);
    final imagePublicIds5 = useState<List<String>>([]);
    final fullScreenImage = useState<String?>(null);

    final request = useState(PorterUpdateResourseRequest(resourceList: []));
    final uploadedImages = ref.watch(uploadedImagesProvider);
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final status = useBookingStatus(bookingAsync.value, job.isReviewOnline);
    print("tuan check status ${status.canPorterConfirmOngoing}");
    print(
        "tuan check status canPorterConfirmArrived ${status.canPorterConfirmArrived}");
    print("tuan check status ${bookingAsync.value?.status.toString()}");
    List<dynamic> getTrackerSources(
        BookingResponseEntity job, String trackerType) {
      try {
        final trackers =
            job.bookingTrackers.firstWhere((e) => e.type == trackerType);

        return trackers.trackerSources;
      } catch (e) {
        return [];
      }
    }

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
      required PorterUpdateResourseRequest request,
    }) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                  decoration: const BoxDecoration(
                    color: primaryOrange,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkGrey,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: secondaryOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${imagePublicIds.length} ảnh',
                    style: const TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CloudinaryCameraUploadWidget(
                disabled: !isEnabled,
                imagePublicIds: imagePublicIds,
                onImageUploaded: isEnabled ? onImageUploaded : (_, __) {},
                onImageRemoved: isEnabled ? onImageRemoved : (_) {},
                onImageTapped: onImageTapped,
                showCameraButton: showCameraButton,
                optionalButton:
                    imagePublicIds.isNotEmpty || title == "Xác nhận vận chuyển"
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
                    case 'Xác nhận dọn hàng':
                      // Do nothing, no image upload here
                      break;
                    case 'Xác nhận trả hàng':
                      // Do nothing, no image upload here
                      break;
                    case 'Xác nhận dọn hàng':
                      // Do nothing, no image upload here
                      break;
                    case 'Xác nhận giao hàng':
                      request.resourceList.add(resource);
                      break;
                  }
                }),
          ],
        ),
      );
    }

    // Future<void> saveImagesAndNavigate() async {
    //   // Simulate saving the images to a database or storage
    //   await Future.delayed(const Duration(seconds: 2));
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Đã lưu ảnh thành công!'),
    //       backgroundColor: primaryOrange,
    //       duration: Duration(seconds: 2),
    //     ),
    //   );

    //   context.router.pop();
    // }

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
          // Orange curved background
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

          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  //case 1
                  buildConfirmationSection(
                    title: 'Xác nhận đã đến',
                    imagePublicIds: imagePublicIds1.value,
                    onImageUploaded: (url, publicId) {
                      images1.value = [...images1.value, url];
                      imagePublicIds1.value = [
                        ...imagePublicIds1.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tải ảnh lên thành công'),
                          backgroundColor: primaryOrange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds1.value = imagePublicIds1.value
                          .where((id) => id != publicId)
                          .toList();
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,
                    onActionPressed: () async {
                      // Xử lý khi tài xế xác nhận đã đến

                      final request = PorterUpdateResourseRequest(
                        resourceList: uploadedImages,
                      );

                      await ref
                          .read(porterControllerProvider.notifier)
                          .updateStatusPorterResourse(
                            id: job.id,
                            request: request,
                            context: context,
                          );
                      bookingAsync.isRefreshing;
                    },
                    actionButtonLabel: 'Xác nhận đến',
                    actionIcon: Icons.location_on,
                    isEnabled: status.canPorterConfirmArrived,
                    // isEnabled: status.canPorterConfirmIncoming,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                  //case 2
                  buildConfirmationSection(
                    title: 'Xác nhận đã dọn',
                    imagePublicIds: imagePublicIds2.value,
                    onImageUploaded: (url, publicId) {
                      images2.value = [...images2.value, url];
                      imagePublicIds2.value = [
                        ...imagePublicIds2.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tải ảnh lên thành công'),
                          backgroundColor: primaryOrange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds2.value = imagePublicIds2.value
                          .where((id) => id != publicId)
                          .toList();
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,
                    onActionPressed: () async {
                      // Xử lý khi tài xế xác nhận đã đến

                      final request = PorterUpdateResourseRequest(
                        resourceList: uploadedImages,
                      );

                      await ref
                          .read(porterControllerProvider.notifier)
                          .updateStatusPorterResourse(
                            id: job.id,
                            request: request,
                            context: context,
                          );
                      bookingAsync.isRefreshing;
                    },
                    actionButtonLabel: 'Xác nhận đóng gói',
                    actionIcon: Icons.location_on,
                    isEnabled: status.canPorterConfirmPacking,
                    // isEnabled: status.canPorterConfirmIncoming,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                  //case 3
                  buildConfirmationSection(
                    title: 'Xác nhận đã giao',
                    imagePublicIds: imagePublicIds3.value,
                    onImageUploaded: (url, publicId) {
                      images3.value = [...images3.value, url];
                      imagePublicIds3.value = [
                        ...imagePublicIds3.value,
                        publicId  
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tải ảnh lên thành công'),
                          backgroundColor: primaryOrange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds3.value = imagePublicIds3.value
                          .where((id) => id != publicId)
                          .toList();
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,
                    onActionPressed: () async {
                      // Xử lý khi tài xế xác nhận đã đến

                      final request = PorterUpdateResourseRequest(
                        resourceList: uploadedImages,
                      );

                      await ref
                          .read(porterControllerProvider.notifier)
                          .updateStatusPorterResourse(
                            id: job.id,
                            request: request,
                            context: context,
                          );
                      bookingAsync.isRefreshing;
                    },
                    actionButtonLabel: 'Xác nhận giao hàng',
                    actionIcon: Icons.location_on,
                    isEnabled: status.canPorterConfirmDelivered,
                    // isEnabled: status.canPorterConfirmIncoming,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                  //case 4
                  buildConfirmationSection(
                    title: 'Xác nhận dỡ hàng',
                    imagePublicIds: imagePublicIds4.value,
                    onImageUploaded: (url, publicId) {
                      images4.value = [...images4.value, url];
                      imagePublicIds4.value = [
                        ...imagePublicIds4.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tải ảnh lên thành công'),
                          backgroundColor: primaryOrange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds4.value = imagePublicIds4.value
                          .where((id) => id != publicId)
                          .toList();
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,
                    onActionPressed: () async {
                      // Xử lý khi tài xế xác nhận đã đến

                      final request = PorterUpdateResourseRequest(
                        resourceList: uploadedImages,
                      );

                      await ref
                          .read(porterControllerProvider.notifier)
                          .updateStatusPorterResourse(
                            id: job.id,
                            request: request,
                            context: context,
                          );
                      bookingAsync.isRefreshing;
                    },
                    actionButtonLabel: 'Xác nhận dỡ hàng',
                    actionIcon: Icons.location_on,
                    isEnabled: status.canPorterCompleteUnloading,
                    // isEnabled: status.canPorterConfirmIncoming,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                  //case 5
                  buildConfirmationSection(
                    title: 'Xác nhận hoàn thành',
                    imagePublicIds: imagePublicIds5.value,
                    onImageUploaded: (url, publicId) {
                      images5.value = [...images5.value, url];
                      imagePublicIds5.value = [
                        ...imagePublicIds5.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tải ảnh lên thành công'),
                          backgroundColor: primaryOrange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds5.value = imagePublicIds5.value
                          .where((id) => id != publicId)
                          .toList();
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,
                    onActionPressed: () async {
                      // Xử lý khi tài xế xác nhận đã đến

                      final request = PorterUpdateResourseRequest(
                        resourceList: uploadedImages,
                      );

                      await ref
                          .read(porterControllerProvider.notifier)
                          .updateStatusPorterResourse(
                            id: job.id,
                            request: request,
                            context: context,
                          );
                      bookingAsync.isRefreshing;
                    },
                    actionButtonLabel: 'Xác nhận hoàn thành',
                    actionIcon: Icons.location_on,
                    isEnabled: status.canPorterComplete,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       saveImagesAndNavigate();
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: primaryOrange,
                  //       foregroundColor: Colors.white,
                  //       padding: const EdgeInsets.symmetric(
                  //           horizontal: 24, vertical: 12),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     child: const Text(
                  //       'Xác nhận',
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ),

          // Full screen image viewer
          if (fullScreenImage.value != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => fullScreenImage.value = null,
                child: Container(
                  color: Colors.black.withOpacity(0.9),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.network(
                          fullScreenImage.value!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 16,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => fullScreenImage.value = null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
