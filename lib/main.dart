import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:swiftresponse/pages/bottom_bar.dart';

List<CameraDescription> cameras = [];
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint(e.description);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swiftresponse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BottomBar(),
    );
  }
}
