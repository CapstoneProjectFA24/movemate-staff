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
    print('loanh ânhr  ${bookingNotifier.getImages(roomType)}');
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
                    child: SizedBox(
                      width: 50, // Chiều rộng nhỏ hơn
                      height: 50, // Chiều cao nhỏ hơn
                      child: hasImages
                          ? const Icon(
                              Icons.add,
                              color: AssetsConstants.greyColor,
                              size: 24, // Giảm kích thước icon
                            )
                          : const Text(
                              'Thêm ảnh',
                              style: TextStyle(
                                color: AssetsConstants.greyColor,
                                fontSize: 12, // Giảm kích thước font chữ
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
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
//dkpnkjnxs
//dve1zpp4s
      if (pickedFile != null) {
        final cloudinary =
            CloudinaryPublic('dkpnkjnxs', 'movemate', cache: false);
        try {
          print('loanh ânhr');
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
          print(imageData.url);
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
