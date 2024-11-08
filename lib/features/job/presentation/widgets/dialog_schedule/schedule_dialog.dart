import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movemate_staff/features/job/presentation/widgets/tabItem/input_field.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

// Validation messages constants
class ValidationMessages {
  static const String pleaseSelectDateTime = 'Vui lòng chọn cả ngày và giờ';
}

// Dialog styles
class DialogStyles {
  static final borderRadius = BorderRadius.circular(20);
  static const contentPadding = EdgeInsets.all(20);
  static const headerTextStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static final buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

class ScheduleDialog extends StatefulWidget {
  final Function(DateTime) onDateTimeSelected;
  final String? orderId;

  const ScheduleDialog({
    super.key,
    required this.onDateTimeSelected,
    this.orderId,
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

  DateTime? _combineDateAndTime(DateTime date, TimeOfDay? time) {
    if (time == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> handleDatePicker() async {
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

  Future<void> handleTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        timeController.text = picked.format(context);
      });
    }
  }

  void handleSubmit() {
    final DateTime? combinedDateTime = _combineDateAndTime(
      selectedDate,
      selectedTime,
    );
    if (combinedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ValidationMessages.pleaseSelectDateTime)),
      );
      return;
    }

    widget.onDateTimeSelected(combinedDateTime);
    Navigator.pop(context);
  }

  Widget buildHeader() {
    return FadeInLeft(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Text(
              'Tạo lịch cho đơn #${widget.orderId}',
              style: DialogStyles.headerTextStyle,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget buildCreateTaskButton() {
    return FadeInUp(
      child: ElevatedButton(
        style: DialogStyles.buttonStyle,
        onPressed: handleSubmit,
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
        borderRadius: DialogStyles.borderRadius,
      ),
      contentPadding: DialogStyles.contentPadding,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildHeader(),
            const SizedBox(height: 20),
            MyInputField(
              title: "Ngày",
              hint: DateFormat('dd/MM/yyyy').format(selectedDate),
              widget: IconButton(
                onPressed: handleDatePicker,
                icon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 16),
            MyInputField(
              title: "Giờ",
              hint: "9:30 AM",
              controller: timeController,
              widget: IconButton(
                onPressed: handleTimePicker,
                icon: const Icon(Icons.access_time_rounded),
              ),
            ),
            const SizedBox(height: 20),
            buildCreateTaskButton(),
          ],
        ),
      ),
    );
  }
}

// Helper function to show dialog
void showScheduleDialog(
    BuildContext context, Function(DateTime) onDateTimeSelected,
    {String orderId = '1234'}) {
  showDialog(
    context: context,
    builder: (context) => ScheduleDialog(
      onDateTimeSelected: onDateTimeSelected,
      orderId: orderId,
    ),
  );
}
