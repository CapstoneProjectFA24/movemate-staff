import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movemate_staff/features/job/presentation/widgets/tabItem/input_field.dart';
import 'package:movemate_staff/utils/commons/widgets/snack_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

// Validation messages constants
class ValidationMessages {
  static const String pleaseSelectDateTime = 'Vui lòng chọn cả ngày và giờ';
  static const String dateTimeTooLate =
      'Không được chọn ngày và giờ sau thời gian đặt lịch';
  static const String timeInPast = 'Không được chọn giờ trong quá khứ';
}

// Dialog styles remain the same as in the original code
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
  final String bookingAt;
  final String? orderId;

  const ScheduleDialog({
    super.key,
    required this.onDateTimeSelected,
    required this.bookingAt,
    this.orderId,
  });

  // Factory constructor for creating ScheduleDialog with default parameters
  factory ScheduleDialog.create({
    Key? key,
    required Function(DateTime) onDateTimeSelected,
    required String bookingAt,
    String? orderId,
  }) {
    return ScheduleDialog(
      key: key,
      onDateTimeSelected: onDateTimeSelected,
      bookingAt: bookingAt,
      orderId: orderId ?? '1234',
    );
  }

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  late DateTime selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController timeController = TextEditingController();
  late DateTime bookingDateTime;
  late DateTime currentDateTime;

  @override
  void initState() {
    super.initState();
    // Parse the bookingAt timestamp
    bookingDateTime = DateFormat('MM/dd/yyyy HH:mm:ss').parse(widget.bookingAt);
    selectedDate = DateTime.now();
    currentDateTime = DateTime.now();
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
        // Reset time selection when date changes
        selectedTime = null;
        timeController.clear();
      });
    }
  }

  Future<void> handleTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
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

    // Validation checks
    if (combinedDateTime == null) {
      showSnackBar(
        context: context,
        content: ' ${ValidationMessages.pleaseSelectDateTime}',
        icon: AssetsConstants.iconError,
        backgroundColor: Colors.red,
        textColor: AssetsConstants.whiteColor,
      );
      return;
    }

    // Check if selected datetime is in the past (even for the current day)
    if (combinedDateTime.isBefore(currentDateTime)) {
      showSnackBar(
        context: context,
        content: ' ${ValidationMessages.timeInPast}',
        icon: AssetsConstants.iconError,
        backgroundColor: Colors.red,
        textColor: AssetsConstants.whiteColor,
      );
      return;
    }

    // Check if selected datetime is after booking datetime
    if (combinedDateTime.isAfter(bookingDateTime)) {
      showSnackBar(
        context: context,
        content: ' ${ValidationMessages.dateTimeTooLate}',
        icon: AssetsConstants.iconError,
        backgroundColor: Colors.red,
        textColor: AssetsConstants.whiteColor,
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
void showScheduleDialog(BuildContext context,
    Function(DateTime) onDateTimeSelected, String bookingAt,
    {String orderId = '1234'}) {
  showDialog(
    context: context,
    builder: (context) => ScheduleDialog(
      onDateTimeSelected: onDateTimeSelected,
      bookingAt: bookingAt,
      orderId: orderId,
    ),
  );
}
