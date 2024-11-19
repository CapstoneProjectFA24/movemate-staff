// File: driver_confirm_upload.dart

import 'package:cloudinary_url_gen/transformation/source/source.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/data/models/request/update_resourse_request.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';
import 'package:movemate_staff/utils/commons/widgets/cloudinary/cloudinary_camera_upload_widget.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

@RoutePage()
class DriverConfirmUpload extends HookConsumerWidget {
  final BookingResponseEntity job;

  const DriverConfirmUpload({
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

    final images3 = useState<List<String>>([]);
    final imagePublicIds3 = useState<List<String>>([]);
    final fullScreenImage = useState<String?>(null);
    final request = useState(UpdateResourseRequest(resourceList: []));
    final uploadedImages = ref.watch(uploadedImagesProvider);
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final status = useBookingStatus(bookingAsync.value, job.isReviewOnline);

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

    final imagesSourceArrived = getTrackerSources(job, "DRIVER_ARRIVED");
    final imagesSourceCompleted = getTrackerSources(job, "DRIVER_COMPLETED");

    useEffect(() {
      if (imagesSourceArrived.isNotEmpty) {
        images1.value = imagesSourceArrived
            .map((source) => source['resourceUrl'] as String)
            .toList();

        imagePublicIds1.value = imagesSourceArrived
            .map((source) => source['resourceCode'] as String)
            .toList();
      }
      if (imagesSourceCompleted.isNotEmpty) {
        images3.value = imagesSourceCompleted
            .map((source) => source['resourceUrl'] as String)
            .toList();

        imagePublicIds3.value = imagesSourceCompleted
            .map((source) => source['resourceCode'] as String)
            .toList();
      }
    }, [imagesSourceArrived, imagesSourceCompleted]);

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
                    style: TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 16),
            if (title != "Xác nhận vận chuyển")
              CloudinaryCameraUploadWidget(
                  disabled: !isEnabled,
                  imagePublicIds: imagePublicIds,
                  // onImageUploaded: onImageUploaded,
                  onImageUploaded: isEnabled ? onImageUploaded : (_, __) {},
                  onImageRemoved: isEnabled ? onImageRemoved : (_) {},
                  onImageTapped: onImageTapped,
                  showCameraButton: showCameraButton,
                  optionalButton: imagePublicIds.isNotEmpty ||
                          title == "Xác nhận vận chuyển"
                      ? ElevatedButton.icon(
                          onPressed: isEnabled ? onActionPressed : null,
                          // onPressed: onActionPressed,
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
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        backgroundColor: primaryOrange,
        backButtonColor: AssetsConstants.whiteColor,
        onBackButtonPressed: () {
          // context.router.push(DriverDetailScreenRoute(
          //     job: job, bookingStatus: status, ref: ref));
          context.router.pop();
        },
        title: "Xác nhận hình ảnh",
        // showBackButton: true,
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
                  //case 1:
                  buildConfirmationSection(
                    title: imagesSourceArrived.isNotEmpty
                        ? 'Đã xác nhận'
                        : 'Xác nhận đã đến',
                    imagePublicIds: imagePublicIds1.value,
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

                      // context.router.push(DriverDetailScreenRoute(
                      //     job: job, bookingStatus: status, ref: ref));

                      // context.router.popUntil((route) =>
                      //     route.settings.name == 'DriversScreenRoute');
                      // context.router.push(DriverDetailScreenRoute(
                      //     job: job, bookingStatus: status, ref: ref));
                    },
                    actionButtonLabel: 'Xác nhận đến',
                    actionIcon: Icons.location_on,
                    isEnabled: status.canDriverConfirmArrived,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                  //case 3
                  buildConfirmationSection(
                    title: imagesSourceCompleted.isNotEmpty
                        ? 'Đã hoàn tất giao hàng'
                        : 'Xác nhận giao hàng',
                    imagePublicIds: imagePublicIds3.value,
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
                      bookingAsync.isRefreshing;

                      // context.router.push(DriverDetailScreenRoute(
                      //     job: job, bookingStatus: status, ref: ref));
                      // context.router.popUntil((route) =>
                      //     route.settings.name == 'DriversScreenRoute');
                      // context.router.push(DriverDetailScreenRoute(
                      //     job: job, bookingStatus: status, ref: ref));
                    },
                    actionButtonLabel: 'Xác nhận giao hàng',
                    actionIcon: Icons.check_circle,
                    isEnabled: status.canDriverCompleteDelivery,
                    // isEnabled: status.canDriverConfirmArrived,
                    showCameraButton: true,
                    request: request.value,
                  ),
                ],
              ),
            ),
          ),
          // Full screen image viewer
          // if (fullScreenImage.value != null)
          //   Positioned.fill(
          //     child: GestureDetector(
          //       onTap: () => fullScreenImage.value = null,
          //       child: Container(
          //         color: Colors.black.withOpacity(0.9),
          //         child: Stack(
          //           children: [
          //             Center(
          //               child: Image.network(
          //                 fullScreenImage.value!,
          //                 fit: BoxFit.contain,
          //               ),
          //             ),
          //             Positioned(
          //               top: 40,
          //               right: 16,
          //               child: IconButton(
          //                 icon: const Icon(
          //                   Icons.close,
          //                   color: Colors.white,
          //                   size: 30,
          //                 ),
          //                 onPressed: () => fullScreenImage.value = null,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
