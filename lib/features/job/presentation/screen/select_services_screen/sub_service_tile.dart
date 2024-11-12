import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/sub_service_entity.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/widgets/select_services/button_quantity/service_trailing_widget.dart';
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

class SubServiceTile extends StatelessWidget {
  final ServicesPackageEntity subService;
  final bool isSelected;
  final int quantity;
  final Function(int) onQuantityChanged;

  const SubServiceTile({
    super.key,
    required this.subService,
    required this.isSelected,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? AssetsConstants.primaryLight : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: LabelText(
          content: subService.name,
          size: 16,
          fontWeight: FontWeight.w400,
          color: isSelected ? Colors.white : Colors.black,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            subService.description,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.black,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: ServiceTrailingWidget(
          quantity: quantity,
          addService: !subService.isQuantity,
          quantityMax: subService.quantityMax,
          onQuantityChanged: onQuantityChanged,
        ),
      ),
    );
  }
}