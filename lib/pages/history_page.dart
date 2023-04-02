import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:swiftresponse/pages/history_view_page.dart';
import 'package:swiftresponse/utils/app_info_list.dart';
import 'package:swiftresponse/widgets/big_text.dart';
import 'package:swiftresponse/widgets/small_text.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late String userId;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _reportsStream;

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      String userId = auth.currentUser!.uid;
      _reportsStream = FirebaseFirestore.instance
          .collection('reports')
          .where('user_id', isEqualTo: userId)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: StreamBuilder<QuerySnapshot>(
          stream: _reportsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            print(snapshot.data?.docs.toList());
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Stack(
                children: [
                  Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ],
              ));
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text("No reports to show."),
              );
            }


            List<Report> reports = snapshot.data!.docs.map((doc) {
              return Report.fromSnapshot(doc);
            }).toList();

            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                Report report = reports[index];
                return ListTile(
                  title: Text(report.reportId),
                  subtitle: Text(report.address),
                  trailing: Text(report.status),
                  onTap: () {
                    //         // Navigate to the ReportDetailPage for the selected report.
                    // //         Navigator.push(
                    // //           context,
                    // //           MaterialPageRoute(
                    // //             builder: (context) => ListTile(
                    // //   title: Text(report.),
                    // //   subtitle: Text(report['carModel']),
                    // // ),
                    // //           ),
                    //         );
                  },
                );
              },
            );
          },
        ));
  }
  
}

class Report {
  late String reportId;
  late String address;
  late String status;

  Report({required this.reportId, required this.address, required this.status});

  Report.fromSnapshot(DocumentSnapshot snapshot) {
    reportId = snapshot['reportId'];
    address = snapshot['address'];
    status = snapshot['status'];
  }
}
