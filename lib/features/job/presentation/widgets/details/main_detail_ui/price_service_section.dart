import 'package:flutter/material.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/update_status_button.dart';

class PriceDetailsContainer extends StatelessWidget {
  final BookingResponseEntity job;

  const PriceDetailsContainer({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'chi tiết giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Hiển thị chi tiết loại xe tải
          ...job.bookingDetails
              .where((detail) => detail.type == "TRUCK")
              .map((truckDetail) => buildItem(
                    imageUrl:
                        'https://storage.googleapis.com/a1aa/image/9rjSBLSWxmoedSK8EHEZx3zrEUxndkuAofGOwCAMywzUTWlTA.jpg',
                    title: truckDetail.name ?? 'Xe Tải',
                    description: truckDetail.description ?? 'Không có mô tả',
                  )),

          // Hiển thị danh sách chi tiết giá của từng dịch vụ
          ...job.bookingDetails.map((detail) => buildPriceItem(
              detail.name ?? 'Dịch vụ không xác định',
              formatPrice(detail.price))),

          // Phần tổng chi phí
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Tổng',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  job.totalReal.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Ghi chú',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          UpdateStatusButton(job: job),
        ],
      ),
    );
  }
}

Widget buildItem(
    {required String imageUrl,
    required String title,
    required String description}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Image.network(imageUrl, width: 80, height: 80),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    ),
  );
}



Widget buildPriceItem(String description, String price) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          // Sử dụng Expanded để cho phép text chiếm không gian còn lại
          child: Text(
            description,
            maxLines: 2, // Giới hạn số dòng là 2
            overflow: TextOverflow
                .ellipsis, // Hiển thị dấu "..." nếu vượt quá 5 ký tự
            style: const TextStyle(
                fontSize: 14), // Bạn có thể tùy chỉnh kích thước chữ
          ),
        ),
        Row(
          children: [
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8), // Thêm khoảng cách giữa price và icon
            const Icon(Icons.sync_alt, color: Colors.black),
          ],
        ),
      ],
    ),
  );
}

String formatPrice(String? price) {
  if (price == null) return '0 đ';
  double? numericPrice = double.tryParse(price);
  if (numericPrice == null) return '$price đ';
  return '${numericPrice.toStringAsFixed(0)} đ';
}
