import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        color: isSelected ? null : Colors.white,
        elevation: isSelected ? 4 : 2,
        shadowColor: isSelected
            ? AssetsConstants.primaryLight.withOpacity(0.3)
            : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isSelected
                ? AssetsConstants.primaryLight
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AssetsConstants.primaryLight,
                      AssetsConstants.primaryLight.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: LabelText(
                        content: subService.name,
                        size: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    ServiceTrailingWidget(
                      quantity: quantity,
                      addService: !subService.isQuantity,
                      quantityMax: subService.quantityMax,
                      onQuantityChanged: onQuantityChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    subService.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black54,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
