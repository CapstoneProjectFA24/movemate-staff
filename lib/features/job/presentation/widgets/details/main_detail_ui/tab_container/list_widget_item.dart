import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/assignment_response_entity.dart';
import 'package:movemate_staff/features/profile/domain/entities/profile_entity.dart';
import 'package:movemate_staff/features/profile/presentation/controllers/profile_controller/profile_controller.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';

// Navigation function cho cả Driver và Porter
void navigateToChatScreen({
  required BuildContext context,
  required String userId,
  required String name,
  required String? avatarUrl,
  required String role, // 'driver' hoặc 'porter'
}) {
  if (role == 'driver') {
    context.router.push(
      ChatWithDriverScreenRoute(
        driverId: userId,
        driverName: name,
        driverAvatar: avatarUrl,
      ),
    );
  } else if (role == 'porter') {
    context.router.push(
      ChatWithPorterScreenRoute(
        porterId: userId,
        porterName: name,
        porterAvatar: avatarUrl,
      ),
    );
  }
}

// Widget được sửa đổi để thêm chức năng chat
class ListItemWidget extends HookConsumerWidget {
  final AssignmentsResponseEntity item;
  final AssignmentsResponseEntity? selectedValue;
  final ValueNotifier<AssignmentsResponseEntity?> selectionNotifier;
  final IconData icon;
  final Color iconColor;
  final String subtitle;
  final String role; // Thêm role để xác định loại người dùng

  const ListItemWidget({
    super.key,
    required this.item,
    required this.selectedValue,
    required this.selectionNotifier,
    required this.icon,
    required this.iconColor,
    required this.subtitle,
    required this.role,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = selectedValue == item;

    // Use the Hook within the build method
    final userProfile = useFetchObject<ProfileEntity>(
      function: (context) => ref
          .read(profileControllerProvider.notifier)
          .getUserInfo(item.userId, context),
      context: context,
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          selectionNotifier.value = isSelected ? null : item;
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: userProfile.data?.avatarUrl != null &&
                        userProfile.data!.avatarUrl!.isNotEmpty
                    ? Image.network(
                        userProfile.data!.avatarUrl!,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Hiển thị Icon nếu có lỗi khi tải hình ảnh
                          return Icon(
                            icon, // Biến `icon` nên được định nghĩa trước đây
                            color: iconColor,
                            size: 20,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                      )
                    : Icon(
                        icon, // Biến `icon` nên được định nghĩa trước đây
                        color: iconColor,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ' ${userProfile.data?.name ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '-',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          userProfile.data?.phone ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Thêm nút chat
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  if (userProfile.data != null) {
                    navigateToChatScreen(
                      context: context,
                      userId: item.userId.toString(),
                      name: userProfile.data!.name ?? '',
                      avatarUrl: userProfile.data!.avatarUrl,
                      role: role,
                    );
                  }
                },
              ),
              Radio<AssignmentsResponseEntity>(
                value: item,
                groupValue: selectedValue,
                onChanged: (value) {
                  selectionNotifier.value = isSelected ? null : value;
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
