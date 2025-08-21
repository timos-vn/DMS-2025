import 'package:flutter/material.dart';

class BuildRow extends StatelessWidget {
  final String label;
  final String value;

  const BuildRow({
    key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
        ),
      ],
    );
  }
}
