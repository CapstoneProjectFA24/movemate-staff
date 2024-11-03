import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/image_section.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/update_status_button.dart';
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

class CombinedInfoSection extends HookConsumerWidget {
  final BookingResponseEntity job;
  final FetchObjectResult<HouseEntities> useFetchHouseResult;
  final ValueNotifier<bool> isExpanded;
  final Function() toggleDropdown;
  final Map<String, List<String>> groupedImages;

  const CombinedInfoSection({
    Key? key,
    required this.job,
    required this.useFetchHouseResult,
    required this.isExpanded,
    required this.toggleDropdown,
    required this.groupedImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Thông tin dịch vụ', [
            _buildCombinedRow(
              'Loại nhà',
              useFetchHouseResult.data?.name ?? 'Không có thông tin',
              'Số tầng',
              job.floorsNumber.toString(),
              'Số phòng',
              job.roomNumber.toString(),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Địa điểm đón',
                job.pickupAddress ?? 'Không có địa chỉ'),
            _buildInfoRow(context, 'Địa điểm đến',
                job.deliveryAddress ?? 'Không có địa chỉ'),
          ]),
          const Divider(height: 32, thickness: 1),
          _buildSection('Thông tin khách hàng', [
            _buildInfoRow(context, 'Tên khách hàng', 'Vinh'),
            _buildInfoRow(context, 'Số điện thoại', '0382703625'),
          ]),
          const Divider(height: 32, thickness: 1),
          _buildImageSection(),
          const Divider(height: 32, thickness: 1),
          _buildPriceDetails(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryLighter),
        ),
        const SizedBox(height: 12),
        ...rows,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCombinedRow(String label1, String value1, String label2,
      String value2, String label3, String value3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildInfo(label1, value1)),
        const VerticalDivider(thickness: 1, color: Colors.grey, width: 20),
        Expanded(child: _buildInfo(label2, value2)),
        const VerticalDivider(thickness: 1, color: Colors.grey, width: 20),
        Expanded(child: _buildInfo(label3, value3)),
      ],
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Text(label,
                  style: const TextStyle(fontSize: 16, color: Colors.grey))),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (value.length > 20)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title:
                              Text(label, style: const TextStyle(fontSize: 18)),
                          backgroundColor: AssetsConstants.whiteColor,
                          content: SingleChildScrollView(
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const LabelText(
                                  content: "Đóng",
                                  size: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AssetsConstants.blackColor,
                                )),
                          ],
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Xem thêm',
                        style: TextStyle(
                          fontSize: 14,
                          color: AssetsConstants.primaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceHeader(),
          const SizedBox(height: 16),
          ...job.bookingDetails.map((detail) => buildPriceItem(
                detail.name ?? 'Dịch vụ không xác định',
                formatPrice(detail.price),
                detail.quantity.toString(),
                detail.type ?? 'Không có loại',
              )),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: DashedDivider(),
          ),
          _buildTotalPrice(),
        ],
      ),
    );
  }

  Widget _buildPriceHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: AssetsConstants.primaryLighter,
              borderRadius: BorderRadius.circular(8)),
          child: const Row(
            children: [
              Icon(Icons.receipt_long,
                  size: 20, color: AssetsConstants.blackColor),
              SizedBox(width: 4),
              Text(
                'Chi tiết giá',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AssetsConstants.blackColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPrice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AssetsConstants.primaryLighter,
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Tổng cộng',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AssetsConstants.whiteColor)),
          Text(
            '${formatPrice(job.totalReal.toString())}',
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AssetsConstants.whiteColor),
          ),
        ],
      ),
    );
  }

  Widget buildPriceItem(
      String description, String price, String quantity, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cleaning_services_outlined,
                      size: 18, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Số lượng: $quantity',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Loại: $type',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          LabelText(
            content: price,
            fontWeight: FontWeight.bold,
            size: 16,
            color: AssetsConstants.blackColor,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSectionHeader(),
          const SizedBox(height: 10),
          if (isExpanded.value) _buildExpandedImageSection(),
        ],
      ),
    );
  }

  Widget _buildImageSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const LabelText(
          content: 'Thông tin hình ảnh',
          size: 18,
          color: AssetsConstants.primaryLight,
          fontWeight: FontWeight.bold,
        ),
        IconButton(
          icon: Icon(
              isExpanded.value ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.black54,
              size: 24),
          onPressed: toggleDropdown,
        ),
      ],
    );
  }

  Widget _buildExpandedImageSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedImages.isEmpty
            ? [
                const Center(
                    child: Text('Không có hình ảnh',
                        style: TextStyle(fontSize: 16)))
              ]
            : groupedImages.entries
                .map((entry) => Section(
                    title: getDisplayTitle(entry.key), imageUrls: entry.value))
                .toList(),
      ),
    );
  }
}

String formatPrice(String? price) {
  if (price == null) return '0 đ';
  double? numericPrice = double.tryParse(price);
  return numericPrice != null
      ? '${numericPrice.toStringAsFixed(0)} đ'
      : '$price đ';
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

class DashedDivider extends StatelessWidget {
  const DashedDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => Container(
          width: 5,
          height: 1,
          color: index % 2 == 0 ? Colors.grey[300] : Colors.transparent,
        ),
        itemCount: 100,
      ),
    );
  }
}
