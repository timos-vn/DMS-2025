import 'package:flutter/material.dart';

import 'custom_progress_bar.dart';

class ProgressBarCustom extends StatelessWidget {
  const ProgressBarCustom({super.key, required this.title, required this.value, required this.percent, required this.color});

  final String title, value;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Row(
        children: [
          Text(title,style: const TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w400),),
          const Spacer(),
          Text(value,style: const TextStyle(color: Colors.white38,fontSize: 11,fontWeight: FontWeight.w600),),
        ],
      ),
      const SizedBox(height: 5,),
      SizedBox(
        height: 7,width: double.infinity,
        child: CustomProgressBar(
          percentage: 0.7,
          progressColor: Colors.green,
          backgroundColor: Colors.grey[300]!,
          height: 8,
          margin: const EdgeInsets.only(left: 8, right: 8),
        ),

      )
    ],));
  }
}
