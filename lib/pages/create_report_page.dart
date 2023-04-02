import 'dart:async';
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
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:swiftresponse/pages/camera_page.dart';
import 'package:swiftresponse/pages/reportTracker.dart';
import 'package:swiftresponse/utils/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreateReportPage extends StatefulWidget {
  final XFile image;
  // final XFile picture;
  const CreateReportPage({Key? key, required this.image}) : super(key: key);

  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage>
    with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  late Bool smp;
  final _storage = FlutterSecureStorage();
  final plateTextController = TextEditingController(text: "");
  final licenseTextController = TextEditingController(text: "");
  final carModelTextController = TextEditingController(text: "");
  final placeOfAccidentTextController = TextEditingController(text: "");
  final accidentCauseTextController = TextEditingController(text: "");
  TimeOfDay _selectedTime = TimeOfDay.now();
  late String userId;
  final storageRef = FirebaseStorage.instance.ref();
  bool _isUploading = false;
  late String newReportId;
  late Timer _timer;
  late StreamSubscription<Position> _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  void startLocationUpdates() {
    LocationSettings locSetting = new LocationSettings(
        distanceFilter: 10, accuracy: LocationAccuracy.high);
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locSetting
                // desiredAccuracy: LocationAccuracy.high,
                // distanceFilter: 10, // Update location every 10 meters
                )
            .listen((position) {
      final location = [position.latitude, position.longitude];
      FirebaseFirestore.instance
          .collection('reports')
          .doc(newReportId)
          .update({'location': location});
    });
  }

  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
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

  Future<String?> pickAndUploadFile(BuildContext context) async {
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
          _createReport(context, path);
          // Handle successful uploads on complete
          print("SUCESS CHECK FIREBASE NOW");
          break;
      }
    });
  }

  // Future<void> _createReport(BuildContext context, path) async {
  void _createReport(BuildContext context, path) async {
    final imageUrl = await storageRef.child(path).getDownloadURL();
    CollectionReference reports = db.collection('reports');

    if (accidentCauseTextController.text.isEmpty ||
        carModelTextController.text.isEmpty ||
        licenseTextController.text.isEmpty ||
        placeOfAccidentTextController.text.isEmpty ||
        plateTextController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please include all required details.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade400,
          textColor: Colors.white,
          fontSize: 16.0);
    }

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
      'user_id': userId,
    });

    newReportId = newReportRef.id;
    await newReportRef.update({
      'status': 'active',
      'reportId': newReportId,
      'created_at': DateTime.now(),
    });
    await _storage.write(key: 'report_id', value: newReportId);
    await _storage.write(key: 'report_status', value: 'open');
    startLocationUpdates();
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ReportTracker()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        startTimer();
        break;
      case AppLifecycleState.paused:
        stopTimer();
        break;
      default:
        break;
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      checkReportStatus();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void checkReportStatus() async {
    final reportId = await _storage.read(key: 'report_id');
    final reportStatus = await _storage.read(key: 'report_status');

    if (reportId != null && reportStatus == 'open') {
      // Check the report status in Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .get();

      if (snapshot.exists && snapshot.data()!['status'] == 'closed') {
        stopLocationUpdates();
        await _storage.write(key: 'report_status', value: 'closed');
      }
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to submit the report?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                // onSubmit();
                pickAndUploadFile(context);
              },
            ),
          ],
        );
      },
    );
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
                      controller: accidentCauseTextController,
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
                            onTap: () => _showConfirmationDialog(context),
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
