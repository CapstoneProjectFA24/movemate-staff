import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

class ContactInfoSection extends StatelessWidget {
  final ValueNotifier<bool> isExpanded;
  final Function() toggleDropdown;
  final BookingResponseEntity job;

  const ContactInfoSection({
    Key? key,
    required this.isExpanded,
    required this.toggleDropdown,
    required this.job,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin liên hệ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  isExpanded.value
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: Colors.black54,
                ),
                onPressed: toggleDropdown,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isExpanded.value) ...[
            buildInfoItem('Họ và tên', 'NGUYEN VAN ANH'),
            buildInfoItem('Mã số', '${job.userId}'),
            buildInfoItem('Số điện thoại', '0900123456'),
            buildInfoItem('Email', 'nguyenvananh@gmail.com'),
          ],
        ],
      ),
    );
  }

  Widget buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: FadeInUp(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
