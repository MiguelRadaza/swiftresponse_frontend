import 'package:flutter/material.dart';

class ReportTracker extends StatefulWidget {
  const ReportTracker({Key? key}) : super(key: key);

  @override
  _ReportTrackerState createState() => _ReportTrackerState();
}

class _ReportTrackerState extends State<ReportTracker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text("report tracker"),
      ),
    );
  }
}
