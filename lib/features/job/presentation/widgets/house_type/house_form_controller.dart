import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';

class HouseFormController extends HookConsumerWidget {
  final TextEditingController roomNumberController;
  final TextEditingController floorsNumberController;
  final void Function(HouseEntities?) onHouseTypeUpdate;
  final void Function(int) onRoomNumberUpdate;
  final void Function(int) onFloorsNumberUpdate;
  
  const HouseFormController({
    Key? key,
    required this.roomNumberController,
    required this.floorsNumberController,
    required this.onHouseTypeUpdate,
    required this.onRoomNumberUpdate,
    required this.onFloorsNumberUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);

    useEffect(() {
      void listener() {
        final roomText = roomNumberController.text;
        final floorsText = floorsNumberController.text;

        final roomNumber = int.tryParse(roomText);
        final floorsNumber = int.tryParse(floorsText);

        if (roomNumber != null) {
          onRoomNumberUpdate(roomNumber);
        }

        if (floorsNumber != null) {
          onFloorsNumberUpdate(floorsNumber);
        }
      }

      roomNumberController.addListener(listener);
      floorsNumberController.addListener(listener);

      return () {
        roomNumberController.removeListener(listener);
        floorsNumberController.removeListener(listener);
      };
    }, [roomNumberController, floorsNumberController]);

    useEffect(() {
      if (bookingState.numberOfRooms != null &&
          bookingState.numberOfRooms.toString() != roomNumberController.text) {
        roomNumberController.text = bookingState.numberOfRooms.toString();
      }

      if (bookingState.numberOfFloors != null &&
          bookingState.numberOfFloors.toString() != floorsNumberController.text) {
        floorsNumberController.text = bookingState.numberOfFloors.toString();
      }

      return null;
    }, [bookingState.numberOfRooms, bookingState.numberOfFloors]);

    return const SizedBox.shrink(); // This is a controller widget, no UI needed
  }
}