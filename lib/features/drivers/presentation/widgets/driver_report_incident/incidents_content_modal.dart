import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

class DriverIncidentReportModal extends HookConsumerWidget {
  final BookingResponseEntity order;
  final VoidCallback? onClose;
  const DriverIncidentReportModal({
    super.key,
    required this.order,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      height: screenHeight * 0.8,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Báo cáo sự cố & Cập nhật dịch vụ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Incident Notification Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          shape: BoxShape.circle,
                        ),
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.report_problem,
                          color: Colors.orange[700],
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Thông báo quan trọng',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vui lòng cung cấp thông tin chi tiết về sự cố hoặc yêu cầu dịch vụ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Reporting Guidelines
                Text(
                  'Hướng dẫn báo cáo:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckListItem('Mô tả rõ ràng và chính xác sự cố'),
                    _buildCheckListItem(
                        'Cung cấp hình ảnh minh chứng (nếu có)'),
                    _buildCheckListItem(
                        'Ghi rõ vị trí và thời gian xảy ra sự cố'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Thông tin chi tiết và chính xác sẽ giúp chúng tôi xử lý yêu cầu của bạn nhanh chóng và hiệu quả.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Action Buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to detailed incident report screen
                    context.router.push(IncidentsScreenRoute(order: order));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[500],
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục báo cáo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Close the modal

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange[700],
                    side: BorderSide(color: Colors.orange[700]!, width: 1),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const FittedBox(
                    child: Text(
                      'Hủy bỏ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 14,
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

  // Reusable checklist item widget
  Widget _buildCheckListItem(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, color: Colors.orange[500], size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
