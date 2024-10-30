import 'package:flutter/material.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

class SelectionModal extends StatelessWidget {
  final String title;
  final List<String> items;
  final ValueChanged<String> onItemSelected;
  final String? selectedItem;

  const SelectionModal({
    super.key,
    required this.title,
    required this.items,
    required this.onItemSelected,
    this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AssetsConstants.whiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == selectedItem;
                  return ListTile(
                    title: Text(
                      item,
                      style: const TextStyle(color: AssetsConstants.blackColor),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check,
                            color: Colors.blue) // Biểu tượng dấu kiểm
                        : null,
                    onTap: () {
                      onItemSelected(item);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
