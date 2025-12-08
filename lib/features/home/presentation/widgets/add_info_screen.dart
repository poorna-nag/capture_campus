import 'package:capture_campus/features/home/data/event_info.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_bloc.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AddInfoScreen extends StatefulWidget {
  final List<XFile> images;
  const AddInfoScreen({super.key, required this.images});

  @override
  State<AddInfoScreen> createState() => _AddInfoScreenState();
}

class _AddInfoScreenState extends State<AddInfoScreen> {
  final eventNameController = TextEditingController();
  final eventInfoController = TextEditingController();
  final userNameController = TextEditingController();
  final dateControllerController = TextEditingController();

  Future<void> pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dateControllerController.text =
          "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Campus')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Event Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: eventNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Event Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: eventInfoController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Enter Event Information',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: userNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Your Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: dateControllerController,
                  readOnly: true,
                  onTap: pickDate,
                  decoration: InputDecoration(
                    hintText: "Select Date",
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () {
                    // if (eventNameController.text.isEmpty &&
                    //     eventInfoController.text.isEmpty &&
                    //     userNameController.text.isEmpty &&
                    //     dateControllerController.text.isEmpty) {
                    final eventInfo = EventInfo(
                      eventName: eventNameController.text,
                      eventInfo: eventInfoController.text,
                      userName: userNameController.text,
                      date: dateControllerController.text,
                      images: widget.images,
                    );

                    // context.read<HomeBloc>().add(OpenCameraEvent());
                    Navigator.pop(context, eventInfo);
                    Navigator.pop(context, eventInfo);

                    // }
                  },
                  child: Container(
                    height: 60,
                    width: 300,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: Colors.amberAccent, width: 2),
                    ),
                    child: const Text(
                      "Upload to Campus Drive",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(NavToHomeScreen());
                  },
                  child: const Text(
                    'Go to Home >>',
                    style: TextStyle(color: Colors.white),
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
