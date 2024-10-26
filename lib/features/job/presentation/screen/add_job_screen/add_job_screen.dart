import 'package:animate_do/animate_do.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:movemate_staff/features/job/domain/entities/task_entity.dart';
import 'package:movemate_staff/features/job/presentation/widgets/add_job/button_add.dart';
import 'package:movemate_staff/features/job/presentation/widgets/add_job/calender.dart';
import 'package:movemate_staff/features/job/presentation/widgets/add_job/participant.dart';
import 'package:movemate_staff/features/job/presentation/widgets/add_job/task.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';


@RoutePage()
class AddJobScreen extends StatefulWidget {
  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  Map<DateTime, List<Task>> tasksByDay = {};
  List<Map<String, String>> participants = [];
  final List<Map<String, String>> fakeEmployees = [
    {'name': 'John Doe', 'image': 'https://via.placeholder.com/150'},
    {'name': 'Jane Smith', 'image': 'https://via.placeholder.com/150'},
    {'name': 'Alice Johnson', 'image': 'https://via.placeholder.com/150'},
    {'name': 'Bob Brown', 'image': 'https://via.placeholder.com/150'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: const CustomAppBar(
        backgroundColor: AssetsConstants.mainColor,
        title: "Job details",
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CalendarWidget(
              //   focusedDay: focusedDay,
              //   selectedDay: selectedDay,
              //   onDaySelected: (selected, focused) {
              //     setState(() {
              //       selectedDay = selected;
              //       focusedDay = focused;
              //     });
              //   },
              // ),
              FadeInRight(
                child: TaskListWidget(
                  tasks: tasksByDay[selectedDay] ?? [],
                  selectedDay: selectedDay,
                ),
              ),
              AddTaskButton(onPressed: _showAddTaskDialog),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();
    String selectedPriority = 'High';

    showDialog(
      context: context,
      builder: (context) {
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
                _buildFormInput('Task Title', titleController),
                _buildFormInput('Description', descriptionController,
                    isMultiline: true),
                _buildTimeInputs(startTimeController, endTimeController),
                _buildPriorityGroup((priority) {
                  selectedPriority = priority;
                }),
                _buildParticipants(),
                SizedBox(height: 20),
                _buildCreateTaskButton(() {
                  _addTask(
                    titleController.text,
                    descriptionController.text,
                    startTimeController.text,
                    endTimeController.text,
                    selectedPriority,
                  );
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return FadeInLeft(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back),
          Text(
            'Add New Task',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Icon(Icons.more_vert),
        ],
      ),
    );
  }

  Widget _buildFormInput(String label, TextEditingController controller,
      {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FadeInDown(
        child: TextField(
          controller: controller,
          maxLines: isMultiline ? 4 : 1,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInputs(TextEditingController startTimeController,
      TextEditingController endTimeController) {
    return FadeInUp(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimeInput('Start Time', startTimeController),
          const SizedBox(
            width: 10,
          ),
          _buildTimeInput('End Time', endTimeController),
        ],
      ),
    );
  }

  Widget _buildTimeInput(String label, TextEditingController controller) {
    return FadeInUp(
      child: Container(
        width: 140,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Icon(Icons.access_time),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityGroup(ValueChanged<String> onPrioritySelected) {
    const priorities = ['Low', 'Medium', 'High'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FadeInUp(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: priorities.map((priority) {
            return GestureDetector(
              onTap: () => onPrioritySelected(priority),
              child: Container(
                width: 90,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    priority,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCreateTaskButton(VoidCallback onCreate) {
    return FadeInUp(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onCreate,
        child: Center(
          child: Text(
            '+ Create Task',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildParticipants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          child: const Text('Participants',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            FadeInUp(
              child: GestureDetector(
                onTap: _addParticipant,
                child: buildAddParticipantButton(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: participants.asMap().entries.map((entry) {
                    int index = entry.key;
                    var participant = entry.value;
                    return _buildParticipant(
                      participant['name']!,
                      participant['image']!,
                      index,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipant(String name, String image, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(image)),
          const SizedBox(width: 5),
          Text(name),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _removeParticipant(index),
          ),
        ],
      ),
    );
  }

  void _addParticipant() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: fakeEmployees.length,
          itemBuilder: (context, index) {
            final employee = fakeEmployees[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(employee['image']!),
              ),
              title: Text(employee['name']!),
              onTap: () {
                setState(() {
                  participants.add(employee);
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _removeParticipant(int index) {
    setState(() {
      participants.removeAt(index);
    });
  }

  void _addTask(String title, String description, String startTime,
      String endTime, String priority) {
    if (title.isEmpty || startTime.isEmpty || endTime.isEmpty) return;

    final newTask = Task(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      priority: priority,
      participants: List.from(participants),
    );

    setState(() {
      tasksByDay[selectedDay] ??= [];
      tasksByDay[selectedDay]!.add(newTask);
      participants.clear();
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
