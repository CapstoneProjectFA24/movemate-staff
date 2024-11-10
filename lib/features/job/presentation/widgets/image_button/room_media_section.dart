import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/image_data.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'room_image.dart';
import 'add_image_button.dart';

class RoomMediaSection extends ConsumerWidget {
  final String roomTitle;
  final RoomType roomType;
  

  const RoomMediaSection({
    super.key,
    required this.roomTitle,
    required this.roomType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingNotifier = ref.read(bookingProvider.notifier);
    final List<ImageData> images = bookingNotifier.getImages(roomType);
    final bool canAddMoreImages = bookingNotifier.canAddImage(roomType);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(
          content: roomTitle,
          size: AssetsConstants.buttonFontSize + 1,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: images.length + (canAddMoreImages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < images.length) {
                return RoomImage(
                  imageData: images[index],
                  roomType: roomType,
                );
              }
              if (canAddMoreImages) {
                return AddImageButton(
                  roomType: roomType,
                  hasImages: images.isNotEmpty,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        if (images.length >= BookingNotifier.maxImages)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Bạn đã đạt giới hạn tối đa ${BookingNotifier.maxImages} hình ảnh.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
