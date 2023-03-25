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
  late Stream<QuerySnapshot> _usersStream;
  @override
  void initState() {
    handleReportHistory();
  }

  Future<String?> handleReportHistory() async {
    print("documents");

    await FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        setState(() {
          userId = user.uid;
          _usersStream = FirebaseFirestore.instance
              .collection('reports')
              .where('uid', isEqualTo: userId.toString())
              .snapshots();
        });

        print('User is signed in!');
      }
    });
    print(userId);

    // FirebaseFirestore firestore = FirebaseFirestore.instance;
    // QuerySnapshot snapshot = await firestore
    //     .collection('reports')
    //     .where('uid', isEqualTo: userId.toString())
    //     .get();

    // List<DocumentSnapshot> documents = snapshot.docs;
    // print(documents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return ListTile(
              title: Text(data['address']),
              subtitle: Text(data['carModel']),
            );
          }).toList(),
        );
      },
    ));
  }
}
