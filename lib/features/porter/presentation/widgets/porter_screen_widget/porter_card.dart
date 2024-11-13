import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';

class PorterCard extends HookConsumerWidget {
  final BookingResponseEntity job;

  const PorterCard({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startTime = DateFormat('MM/dd/yyyy HH:mm:ss').parse(job.bookingAt);
    final endTime = startTime.add(
      Duration(
        minutes: int.parse(job.estimatedDeliveryTime ?? '0'),
      ),
    );
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final bookingStatus =
        useBookingStatus(bookingAsync.value, job.isReviewOnline);

    Color cardColor;
    String statusText;

    if (bookingStatus.isCompleted) {
      cardColor = Colors.green.shade400;
      statusText = 'Đã vận chuyển';
    } else if (bookingStatus.isInProgress) {
      cardColor = Colors.orange.shade400;
      statusText = 'Đang vận chuyển';
    } else {
      cardColor = const Color.fromARGB(255, 244, 190, 54);
      statusText = 'Mới';
    }

    return GestureDetector(
      onTap: () {
        context.router.push(PorterDetailScreenRoute(job: job));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardColor.withOpacity(0.8),
                cardColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    job.id.toString(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat.Hm().format(startTime)} - ${DateFormat.Hm().format(endTime)}',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.pickupAddress,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.flag, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.deliveryAddress,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
