import 'dart:ffi';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart';
import 'package:swiftresponse/pages/camera_page.dart';
import 'package:swiftresponse/utils/colors.dart';

class CreateReportPage extends StatefulWidget {
  final XFile image;
  // final XFile picture;
  const CreateReportPage({Key? key, required this.image}) : super(key: key);

  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  late Bool smp;
  final plateTextController = TextEditingController(text: '');
  final licenseTextController = TextEditingController(text: '');
  final carModelTextController = TextEditingController(text: '');
  final placeOfAccidentTextController = TextEditingController(text: '');
  final accidentCauseTextController = TextEditingController(text: '');
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtain a list of the available cameras on the device.

    return Scaffold(
        appBar: AppBar(
          title: const Text('Incident Report'),
        ),
        backgroundColor: AppColors.backgroundColor,
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(top: 24, left: 24, right: 24),
              child: Column(
                children: [
                  Container(
                    width: double.maxFinite,
                    height: 270,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.black12,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(File(widget.image.path)),
                        )),
                  ),
                  Gap(15),
                  TextField(
                    controller: plateTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Plate Details',
                    ),
                  ),
                  Gap(24),
                  TextField(
                    controller: licenseTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'License Details',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  Gap(24),
                  TextField(
                    controller: carModelTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Car Model',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  Gap(24),
                  TextField(
                    controller: placeOfAccidentTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Place Of Accident',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  Gap(24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time of Accident: ${_selectedTime?.format(context) ?? 'Not selected'}',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectTime(context),
                        child: Text('Select Time'),
                      ),
                    ],
                  ),
                  Gap(24),
                  TextField(
                    controller: plateTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Accident Cause',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  Gap(24),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 40,
                          width: 130,
                          child: Center(
                            child: Text(
                              "REPORT",
                              style: TextStyle(
                                  color: AppColors.backgroundColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ],
                    ),
                  ),
                  const Gap(15)
                ],
              ),
            ),
          ],
        ));
  }
}
