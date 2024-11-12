import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/screen/select_services_screen/sub_service_tile.dart';
import 'package:movemate_staff/features/job/presentation/widgets/select_services/button_quantity/service_trailing_widget.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ServicePackageTile extends HookConsumerWidget {
  final ServicesPackageEntity servicePackage;
  final BookingResponseEntity job;
  final ValueNotifier<List<ServicesPackageEntity>> selectedServices;
  final ValueNotifier<Map<String, int>> quantities;

  const ServicePackageTile({
    super.key,
    required this.servicePackage,
    required this.job,
    required this.selectedServices,
    required this.quantities,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingNotifier = ref.read(bookingProvider.notifier);
    final bookingState = ref.watch(bookingProvider);

    // Check if the current service package is in the selectedServices list
    final isSelected = selectedServices.value.contains(servicePackage);

    quantities.value.forEach((key, value) => print("key: $key, value: $value"));

    print('check ${quantities}');
    // quantities  => {32: 1, 20: 1, 19: 1, 18: 1, 9: 1, 10: 4, 2: 1, 3: 2, 4: 1, 5: 3}
    //             string is id off isSelected , value int is the quantity to show

    final currentPackage = bookingState.selectedPackages.firstWhere(
      (p) => p.id == servicePackage.id,
      orElse: () => servicePackage.copyWith(quantity: 0),
    );
    // final int quantity = quantities.value[servicePackage.id.toString()] ??
    //     currentPackage.quantity ??
    //     0;
    print('check ${currentPackage.quantity}');
    final int quantity = quantities.value[servicePackage.id.toString()] ??
        currentPackage.quantity ??
        0;
    var isExpanded = useState(isSelected).value;

    // Handler for quantity changes
    void handleQuantityChanged(int newQuantity) {
      // Update quantities map
      quantities.value = {
        ...quantities.value,
        servicePackage.id.toString(): newQuantity,
      };

      // Update selected services list
      if (newQuantity > 0 && !isSelected) {
        selectedServices.value = [...selectedServices.value, servicePackage];
      } else if (newQuantity == 0 && isSelected) {
        selectedServices.value = selectedServices.value
            .where((service) => service.id != servicePackage.id)
            .toList();
      }

      // Update booking provider
      bookingNotifier.updateServicePackageQuantity(servicePackage, newQuantity);
      bookingNotifier.calculateAndUpdateTotalPrice();
    }

    if (servicePackage.inverseParentService.isNotEmpty) {
      // Display package with sub-services
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (bool expanded) {
            isExpanded = expanded;
          },
          title: Text(
            servicePackage.name.trim(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            servicePackage.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (servicePackage.discountRate > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${servicePackage.discountRate}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0, // 180-degree rotation
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: FaIcon(
                  isExpanded
                      ? FontAwesomeIcons.circleChevronDown
                      : FontAwesomeIcons.circleChevronUp,
                  color: isExpanded
                      ? AssetsConstants.greyColor
                      : AssetsConstants.primaryDark,
                  size: 20, // Kích thước của icon
                ),
              ),
            ],
          ),
          children: servicePackage.inverseParentService.map((subService) {
            // Get quantity for sub-service from quantities map
            final subQuantity = quantities.value[subService.id.toString()] ?? 0;

            return SubServiceTile(
              subService: subService,
              isSelected: selectedServices.value.contains(subService),
              quantity: subQuantity,
              onQuantityChanged: (newQuantity) {
                // Update quantities map for sub-service
                quantities.value = {
                  ...quantities.value,
                  subService.id.toString(): newQuantity,
                };

                // Update booking provider for sub-service
                bookingNotifier.updateSubServiceQuantity(
                    subService, newQuantity);
                bookingNotifier.calculateAndUpdateTotalPrice();
              },
            );
          }).toList(),
        ),
      );
    } else {
      // Display package without sub-services
      return Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            servicePackage.name.trim(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              servicePackage.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: ServiceTrailingWidget(
            quantity: quantity,
            addService: !servicePackage.isQuantity,
            quantityMax: servicePackage.quantityMax,
            onQuantityChanged: handleQuantityChanged,
          ),
        ),
      );
    }
  }
}
