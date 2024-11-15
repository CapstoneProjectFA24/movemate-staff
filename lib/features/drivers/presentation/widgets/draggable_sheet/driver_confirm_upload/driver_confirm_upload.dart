// File: driver_confirm_upload.dart

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/utils/commons/widgets/cloudinary/cloudinary_camera_upload_widget.dart';

@RoutePage()
class DriverConfirmUpload extends HookWidget {
  final BookingResponseEntity job;
  final BookingStatusResult status;

  const DriverConfirmUpload({
    super.key,
    required this.job,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
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
              ),
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
                  //case 1:
                  buildConfirmationSection(
                    title: 'Xác nhận đã đến',
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
                    onActionPressed: () {
                      // Xử lý khi tài xế xác nhận đã đến
                      print("Handling arrival confirmation");
                    },
                    actionButtonLabel: 'Xác nhận đến',
                    actionIcon: Icons.location_on,
                    isEnabled: status.canDriverConfirmArrived,
                    showCameraButton: true,
                  ),
                  const SizedBox(height: 16),
                  //case 2:
                  buildConfirmationSection(
                    title: 'Xác nhận vận chuyển',
                    imagePublicIds: imagePublicIds2.value,
                    onImageUploaded: (url, publicId) {
                      images2.value = [...images2.value, url];
                      imagePublicIds2.value = [
                        ...imagePublicIds2.value,
                        publicId
                      ];
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds2.value = imagePublicIds2.value
                          .where((id) => id != publicId)
                          .toList();
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,
                    onActionPressed: () {
                      // Xử lý khi bắt đầu vận chuyển
                      print("Handling transport confirmation");
                    },
                    actionButtonLabel: 'Bắt đầu vận chuyển',
                    actionIcon: Icons.local_shipping,
                    isEnabled: status.canDriverStartMoving,
                    // isEnabled: status.canDriverConfirmArrived,
                    showCameraButton: false,
                  ),
                  const SizedBox(height: 16),
                  //case 3:
                  buildConfirmationSection(
                    title: 'Xác nhận giao hàng',
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
                    onActionPressed: () {
                      // Xử lý khi giao hàng thành công
                      print("Handling delivery confirmation");
                    },
                    actionButtonLabel: 'Xác nhận giao hàng',
                    actionIcon: Icons.check_circle,
                    isEnabled: status.canDriverCompleteDelivery,
                    // isEnabled: status.canDriverConfirmArrived,
                    showCameraButton: true,
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
