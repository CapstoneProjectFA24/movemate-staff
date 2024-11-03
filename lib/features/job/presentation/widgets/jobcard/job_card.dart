import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/screen/job_details_screen/job_details_screen.dart';

class JobCard extends StatelessWidget {
  final BookingResponseEntity job;
  final VoidCallback onCallback;
  final bool isReviewOnline;
  final String currentTab;

  const JobCard({
    super.key,
    required this.onCallback,
    required this.job,
    required this.isReviewOnline,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                _getStatusIcon(job.status),
                color: _getStatusColor(job.status),
                size: 24,
              ),
              Container(
                height: 60,
                width: 2,
                color: _getStatusColor(job.status).withOpacity(0.4),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailsScreen(job: job),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getCardGradientColors(job.status),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mã đơn dọn nhà: ${job.id}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(job.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              job.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildDateInfo(),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 18),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              job.pickupAddress,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.flag,
                              color: Colors.white70, size: 18),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              job.deliveryAddress,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Deposit: ${job.deposit.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Total: ${job.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo() {
    if (currentTab == "Đang đợi đánh giá") {
      if (isReviewOnline) {
        return Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
            const SizedBox(width: 5),
            Text(
              'Ngày đặt: ${_formatTime(job.bookingAt)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        );
      } else {
        return Row(
          children: [
            const Icon(Icons.rate_review, color: Colors.white70, size: 18),
            const SizedBox(width: 5),
            Text(
              'Review Date: ${_formatTime(job.reviewAt)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        );
      }
    } else if (currentTab == "Đã đánh giá") {
      if (!isReviewOnline) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rate_review, color: Colors.white70, size: 18),
                const SizedBox(width: 5),
                Text(
                  'Ngày đánh giá: ${_formatTime(job.reviewAt)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 18),
                const SizedBox(width: 5),
                Text(
                  'Thời gian ước tính: ${job.estimatedDeliveryTime ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        );
      } else {
        return Row(
          children: [
            const Icon(Icons.rate_review, color: Colors.white70, size: 18),
            const SizedBox(width: 5),
            Text(
              'Ngày đặt: ${_formatTime(job.bookingAt)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }

  String _formatTime(String? time) {
    if (time == null) return "N/A";
    try {
      DateTime dateTime = DateFormat("MM/dd/yyyy HH:mm:ss").parse(time);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${DateFormat('dd/MM/yyyy').format(dateTime)}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'ASSIGNED':
        return Icons.assignment_turned_in;
      case 'IN_PROGRESS':
        return Icons.local_shipping;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ASSIGNED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.teal;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Color> _getCardGradientColors(String status) {
    switch (status) {
      case 'PENDING':
        return [Colors.orange.shade700, Colors.orange.shade400];
      case 'ASSIGNED':
        return [Colors.blue.shade700, Colors.blue.shade400];
      case 'IN_PROGRESS':
        return [Colors.teal.shade700, Colors.teal.shade400];
      case 'COMPLETED':
        return [Colors.green.shade700, Colors.green.shade400];
      case 'CANCELLED':
        return [Colors.red.shade700, Colors.red.shade400];
      default:
        return [Colors.grey.shade700, Colors.grey.shade400];
    }
  }
}
