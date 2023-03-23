import 'dart:ffi';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:swiftresponse/pages/camera_page.dart';
import 'package:swiftresponse/utils/colors.dart';

class CreateReportPage extends StatefulWidget {
  // final XFile picture;
  const CreateReportPage({Key? key}) : super(key: key);

  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  late Bool smp;
  @override
  Widget build(BuildContext context) {
    // Obtain a list of the available cameras on the device.

    return Scaffold(
        appBar: AppBar(
          title: const Text('Incident Report'),
        ),
        backgroundColor: Color(0xFFFF7043),
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
                            image: AssetImage(
                                "assets/images/sample_collision.jpg"))),
                  ),
                  Gap(15),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24)),
                    padding: EdgeInsets.all(24),
                    child: TextField(
                      decoration: InputDecoration.collapsed(
                          hintText: "Enter your description here"),
                      maxLines: 8,
                    ),
                  ),
                  Gap(24),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 40,
                          width: 130,
                          child: Center(
                            child: Text("Submit"),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        GestureDetector(
                            onTap: () async {
                              await availableCameras().then((value) =>
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              CameraPage(cameras: value))));
                            },
                            // onTap: () async {
                            //   await availableCameras()
                            //       .then((value) => CameraPage(cameras: value));
                            // },
                            child: Container(
                              height: 40,
                              width: 130,
                              child: Center(
                                child: Text("Capture Image"),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(24)),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
