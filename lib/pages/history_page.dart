import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:swiftresponse/pages/history_view_page.dart';
import 'package:swiftresponse/utils/app_info_list.dart';
import 'package:swiftresponse/widgets/big_text.dart';
import 'package:swiftresponse/widgets/small_text.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        Container(
          margin: EdgeInsets.only(left: 25, right: 25),
          child: Column(
            children: [
              Gap(50),
              Container(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [BigText(size: 30, text: "History")],
              )),
              Gap(15),
              Column(
                  children: historyList
                      .map((e) => HistoryViewPage(history: e))
                      .toList())
            ],
          ),
        ),
      ],
    ));
  }
}
