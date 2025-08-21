import 'package:flutter/material.dart';

class BuildRowWithDatePicker extends StatelessWidget {
  final String label;
  final String date;
  final bool? isTrueWidth;
  final VoidCallback? onTap;

  const BuildRowWithDatePicker({
    key,
    required this.label,
    required this.date, this.onTap,this.isTrueWidth
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: isTrueWidth == true ? 100 : 80,
            child: Text(label),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    date.toString().split(' ').first,
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.date_range,
                    color: Colors.blueGrey,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
