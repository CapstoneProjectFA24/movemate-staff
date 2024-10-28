import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movemate_staff/features/job/presentation/widgets/tabItem/input_field.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

class ScheduleDialog extends StatefulWidget {
  final Function(DateTime) onDateTimeSelected;

  const ScheduleDialog({
    super.key,
    required this.onDateTimeSelected,
  });

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  late DateTime selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    timeController.dispose();
    super.dispose();
  }

  DateTime? _combineDateAndTime() {
    if (selectedTime == null) return null;

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
  }

  Future<void> _handleDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _handleTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        // Format the time using the context to get proper localization
        timeController.text = picked.format(context);
      });
    }
  }

  void _handleSubmit() {
    final DateTime? combinedDateTime = _combineDateAndTime();
    if (combinedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn cả ngày và giờ')),
      );
      return;
    }

    widget.onDateTimeSelected(combinedDateTime);
    Navigator.pop(context);
  }

  Widget _buildHeader() {
    return FadeInLeft(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
          const Text(
            'Tạo lịch cho đơn booking',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildCreateTaskButton() {
    return FadeInUp(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _handleSubmit,
        child: const Center(
          child: Text(
            'Tạo lịch hẹn',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AssetsConstants.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            MyInputField(
              title: "Ngày",
              hint: DateFormat('dd/MM/yyyy').format(selectedDate),
              widget: IconButton(
                onPressed: _handleDatePicker,
                icon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 16),
            MyInputField(
              title: "Giờ",
              hint: "9:30 AM",
              controller: timeController,
              widget: IconButton(
                onPressed: _handleTimePicker,
                icon: const Icon(Icons.access_time_rounded),
              ),
            ),
            const SizedBox(height: 20),
            _buildCreateTaskButton(),
          ],
        ),
      ),
    );
  }
}

// Helper function to show dialog
void showScheduleDialog(
    BuildContext context, Function(DateTime) onDateTimeSelected) {
  showDialog(
    context: context,
    builder: (context) => ScheduleDialog(
      onDateTimeSelected: onDateTimeSelected,
    ),
  );
}
