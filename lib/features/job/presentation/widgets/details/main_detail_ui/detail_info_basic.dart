import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';

class DetailInfoBasicCard extends HookConsumerWidget {
  final BookingResponseEntity job;
  final FetchObjectResult<HouseEntities> useFetchHouseResult;

  const DetailInfoBasicCard({
    Key? key,
    required this.job,
    required this.useFetchHouseResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Center(
        child: Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF007bff),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                padding: const EdgeInsets.all(15),
                child: const Row(
                  children: [
                    Icon(FontAwesomeIcons.home, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Thông tin dịch vụ',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loại nhà : ${useFetchHouseResult.data?.name.toString()} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    buildAddressRow(
                      Icons.location_on_outlined,
                      '${job.pickupAddress}',
                    ),
                    const Divider(height: 12, color: Colors.grey, thickness: 1),
                    buildAddressRow(
                      Icons.location_searching,
                      '${job.deliveryAddress}',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildDetailColumn(FontAwesomeIcons.building,
                            '${job.floorsNumber} tầng'),
                        buildDetailColumn(FontAwesomeIcons.building,
                            '${job.roomNumber} phòng'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    buildPolicies(
                        FontAwesomeIcons.checkCircle, 'Miễn phí đặt lại'),
                    const SizedBox(height: 20),
                    buildPolicies(FontAwesomeIcons.checkCircle,
                        'Áp dụng chính sách đổi lịch'),
                    const SizedBox(height: 20),
                    buildBookingCode('Mã đặt chỗ', 'FD8UH6'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAddressRow(IconData icon, String address) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget buildDetailColumn(IconData icon, String detail) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(detail, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget buildPolicies(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget buildBookingCode(String label, String code) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Căn trái
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold), // Tiêu đề
              ),
              Text(code), // Mã đặt chỗ
            ],
          ),
          const Icon(FontAwesomeIcons.copy, color: Color(0xFF007bff)),
        ],
      ),
    );
  }
}
