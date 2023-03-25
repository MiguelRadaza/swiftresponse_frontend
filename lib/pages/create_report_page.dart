import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart';
import 'package:swiftresponse/pages/camera_page.dart';
import 'package:swiftresponse/utils/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateReportPage extends StatefulWidget {
  final XFile image;
  // final XFile picture;
  const CreateReportPage({Key? key, required this.image}) : super(key: key);

  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final db = FirebaseFirestore.instance;
  late Bool smp;
  final plateTextController = TextEditingController(text: "");
  final licenseTextController = TextEditingController(text: "");
  final carModelTextController = TextEditingController(text: "");
  final placeOfAccidentTextController = TextEditingController(text: "");
  final accidentCauseTextController = TextEditingController(text: "");
  TimeOfDay _selectedTime = TimeOfDay.now();
  late String userId;
  final storageRef = FirebaseStorage.instance.ref();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _handUserSession();
  }

  void _handUserSession() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        setState(() {
          userId = user.uid;
        });
        print('User is signed in!');
      }
    });
  }

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

  Future<String?> pickAndUploadFile() async {
    setState(() {
      _isUploading = true;
    });
    final metadata = SettableMetadata(contentType: "image/jpeg");
    File file = File(widget.image.path);
    final path =
        'images/report/' + userId.toString() + _selectedTime.toString();
    final uploadTask = storageRef.child(path).putFile(file, metadata);
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          print("Error upload");
          break;
        case TaskState.success:
          _createReport(path);
          // Handle successful uploads on complete
          print("SUCESS CHECK FIREBASE NOW");
          break;
      }
    });
  }

  void _createReport(path) async {
    final imageUrl = await storageRef.child(path).getDownloadURL();
    CollectionReference reports = db.collection('reports');

    DocumentReference newReportRef = await reports.add({
      'accidentCause': accidentCauseTextController.text.toString(),
      'address': "sa puso mo",
      'carModel': carModelTextController.text.toString(),
      'imageUrl': imageUrl,
      'licenseDetails': licenseTextController.text.toString(),
      'location': [17.0934, 14.23452],
      'timeOfAccident': _selectedTime.toString(),
      'placeOfAccident': placeOfAccidentTextController.text.toString(),
      'plateDetails': plateTextController.text.toString(),
      'userId': userId,
    });

    String newReportId = newReportRef.id;
    await newReportRef.update({
      'status': 'active',
      'reportId': newReportId,
      'created_at': DateTime.now(),
    });

    Fluttertoast.showToast(
        msg: "Report created successfully.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.teal,
        textColor: Colors.white,
        fontSize: 16.0);
    print("SUCESS CREATING REPORT CHECK FIREBASE NOW: " + newReportId);
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtain a list of the available cameras on the device.

    return Scaffold(
        appBar: AppBar(
          title: const Text('Incident Report'),
        ),
        backgroundColor: AppColors.backgroundColor,
        body: Stack(children: [
          ListView(
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
                          InkWell(
                            onTap: () => pickAndUploadFile(),
                            child: Container(
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
                          )
                        ],
                      ),
                    ),
                    const Gap(15)
                  ],
                ),
              ),
            ],
          ),
          _isUploading
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                )
              : SizedBox.shrink(),
          // progress indicator
          _isUploading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox.shrink(),
        ]));
  }
}
