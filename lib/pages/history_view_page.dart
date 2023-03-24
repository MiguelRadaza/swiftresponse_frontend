import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/app_layout.dart';
import '../widgets/big_text.dart';
import '../widgets/small_text.dart';

class HistoryViewPage extends StatelessWidget {
  final Map<String, dynamic> history;
  const HistoryViewPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: size.width * 0.85,
      padding: EdgeInsets.only(
          top: AppLayout.getHeight(15),
          left: AppLayout.getWidth(15),
          right: AppLayout.getWidth(15)),
      decoration: BoxDecoration(
          color: Colors.orange, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigText(
            text: history['name'],
            size: 19,
          ),
          Gap(10),
          Container(child: Text(history['description'])),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallText(
                text: "Status: Open",
                color: Colors.black,
                size: 16,
              ),
              Text("2023-07-02")
            ],
          ),
        ],
      ),
    );
  }
}
