import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/house_type_controller/house_type_controller.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';

class HouseDetailsFetcher extends HookConsumerWidget {
  final BookingResponseEntity job;
  final void Function(HouseEntities?) onHouseTypeUpdate;

  const HouseDetailsFetcher({
    Key? key,
    required this.job,
    required this.onHouseTypeUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final houseTypeController = ref.read(houseTypeControllerProvider.notifier);
    final useFetchResult = useFetchObject<HouseEntities>(
      function: (context) =>
          houseTypeController.getHouseDetails(job.houseTypeId, context),
      context: context,
    );
    
    final houseTypeById = useFetchResult.data;

    useEffect(() {
      if (houseTypeById != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onHouseTypeUpdate(houseTypeById);
        });
      }
      return null;
    }, [houseTypeById]);

    return const SizedBox.shrink(); // This is a data fetcher widget, no UI needed
  }
}