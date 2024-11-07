// add_image_button.dart
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/image_data.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

class AddImageButton extends ConsumerWidget {
  final RoomType roomType;
  final bool hasImages;

  const AddImageButton({
    super.key,
    required this.roomType,
    required this.hasImages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);
    final isUploading = booking.isUploadingLivingRoomImage ?? false;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: isUploading && roomType == RoomType.livingRoom
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AssetsConstants.primaryLight,
                  ),
                ),
              ),
            )
          : InkWell(
              onTap: () => _takePhoto(context, bookingNotifier),
              // child: const Icon(
              //   Icons.add_a_photo,
              //   color: AssetsConstants.primaryLight,
              // ),
              child: Container(
                width: 100, // Ensure size matches SizedBox
                height: 50, // Ensure size matches SizedBox
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DottedBorder(
                  color: AssetsConstants.greyColor,
                  strokeWidth: 2,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  dashPattern: const [8, 4],
                  child: Center(
                    child: hasImages
                        ? const Icon(Icons.add,
                            color: AssetsConstants.greyColor)
                        : const Text('Thêm ảnh',
                            style: TextStyle(color: AssetsConstants.greyColor)),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _takePhoto(
      BuildContext context, BookingNotifier bookingNotifier) async {
    try {
      if (roomType == RoomType.livingRoom) {
        bookingNotifier.setUploadingLivingRoomImage(true);
      }

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final cloudinary =
            CloudinaryPublic('dkpnkjnxs', 'movemate', cache: false);
        try {
          final CloudinaryResponse response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              pickedFile.path,
              folder: 'movemate/images',
              resourceType: CloudinaryResourceType.Image,
            ),
          );

          final imageData = ImageData(
            url: response.secureUrl,
            publicId: response.publicId,
          );

          await bookingNotifier.addImageToRoom(roomType, imageData);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không thể tải ảnh lên')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi chụp ảnh')),
        );
      }
    } finally {
      if (roomType == RoomType.livingRoom) {
        bookingNotifier.setUploadingLivingRoomImage(false);
      }
    }
  }
}
