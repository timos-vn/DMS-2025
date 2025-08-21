import 'package:flutter/material.dart';

import '../../api/models/employee_model.dart';
import '../../helper/constant.dart';

class EmployeeMarker extends StatelessWidget {
  const EmployeeMarker({key, required this.listKey, required this.listEmployee});

  final List<GlobalKey> listKey;
  final List<EmployeeModel> listEmployee;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: List.generate(listKey.length, (index) {
        return RepaintBoundary(
          key: listKey[index],
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: white.withOpacity(0.8), borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: setText(
                    '${listEmployee[index].firstName!} ${listEmployee[index].lastName!}', 11,
                    color: black, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Image(image: locationAsset, height: 40)
            ],
          ),
        );
      }),
    ));
  }
}
