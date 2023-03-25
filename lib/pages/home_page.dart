import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:swiftresponse/pages/camera_page.dart';
import 'package:camera/camera.dart';
import 'package:swiftresponse/pages/create_report_page.dart';
import 'package:swiftresponse/pages/history_page.dart';
import 'package:swiftresponse/utils/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            decoration: BoxDecoration(color: Colors.white),
            padding: EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 15, right: 30),
                      child: Column(children: [
                        Text(
                          "———",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "———",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "———",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ]),
                    )
                  ],
                ),
                Container(
                  height: 570,
                  width: double.maxFinite,
                  padding: EdgeInsets.only(top: 390),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      image: DecorationImage(
                          image: AssetImage(
                              "assets/images/listing_main_car_crash_clipart-800x800__1_.png"))),
                  child: Column(
                    children: [
                      InkWell(
                          onTap: () async {
                            final image = await availableCameras()
                                .then((value) => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CameraPage(cameras: value)),
                                    ));
                          },
                          child: Container(
                            height: 50,
                            width: 200,
                            child: Center(child: Text("Report")),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.white),
                          )),
                      const Gap(15),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (Container) => HistoryPage()));
                        },
                        child: Container(
                          height: 50,
                          width: 200,
                          child: Center(child: Text("History")),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              ],
            )));
  }
}
