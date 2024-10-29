// house_type_selection_modal.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/presentation/controllers/house_type_controller/house_type_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/widgets/house_type/selection_modal.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';

// Import HouseTypeController

// Hooks
import 'package:movemate_staff/hooks/use_fetch.dart';

// Import your entities and widgets
import 'package:movemate_staff/models/request/paging_model.dart';

// Hooks

import 'package:flutter_hooks/flutter_hooks.dart';

//extension
import 'package:movemate_staff/utils/extensions/scroll_controller.dart';

class HouseTypeSelectionModal extends HookConsumerWidget {
  const HouseTypeSelectionModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider); // Watch the booking state
    final bookingNotifier = ref.read(bookingProvider.notifier);
    final scrollController = useScrollController();
    final state = ref.watch(bookingControllerProvider);

    final fetchResult = useFetch<HouseEntities>(
      function: (model, context) =>
          ref.read(bookingControllerProvider.notifier).getHouse(model, context),
      initialPagingModel: PagingModel(),
      context: context,
    );

    useEffect(() {
      scrollController.onScrollEndsListener(fetchResult.loadMore);
      return null;
    }, const []);

    if (state.isLoading && fetchResult.items.isEmpty) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else if (state.hasError) {
      return AlertDialog(
        title: const Text('Lỗi'),
        content: const Text('Không thể tải loại nhà ở'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          )
        ],
      );
    } else {
      final houseTypeEntities = fetchResult.items;
      final houseTypes = houseTypeEntities.map((e) => e.name).toList();

      return SelectionModal(
        title: 'Chọn loại nhà ở',
        items: houseTypes,
        onItemSelected: (selectedItem) {
          // Tìm đối tượng HouseTypeEntity được chọn
          final selectedHouseType = houseTypeEntities.firstWhere(
            (e) => e.name == selectedItem,
          );
          // Cập nhật trạng thái
          bookingNotifier.updateHouseType(selectedHouseType);
          Navigator.pop(context);
        },
      );
    }
  }
}
