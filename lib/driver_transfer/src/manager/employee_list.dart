import 'package:flutter/material.dart';

import '../../api/models/employee_model.dart';
import '../../helper/constant.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({
    key,
    required this.onPick,
    required this.selectDate,
    this.employee,
    required this.listEmployee,
  });

  final ValueChanged<int> onPick;
  final Function() selectDate;
  final EmployeeModel? employee;
  final List<EmployeeModel> listEmployee;

  @override
  State<EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25), offset: const Offset(4, 0), blurRadius: 4)
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TextFormField(
                    controller: search,
                    style:
                        const TextStyle(fontSize: 14, color: black, fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        fillColor: const Color(0xffF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        filled: true,
                        hintText: 'Tìm kiếm theo tên',
                        hintStyle: const TextStyle(
                            fontSize: 14, color: gray, fontWeight: FontWeight.normal),
                        prefixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
                        prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Image(image: searchAsset, height: 20))),
                  ),
                )),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: widget.selectDate,
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Image(image: calendarAsset, height: 23),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 10, bottom: 35),
                  itemBuilder: (context, index) => _item(index),
                  separatorBuilder: (context, index) {
                    return Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 20),
                        height: 1,
                        color: const Color(0xffE8E8E8));
                  },
                  itemCount: widget.listEmployee.length),
            )
          ],
        ));
  }

  _item(int index) {
    final EmployeeModel item = widget.listEmployee[index];
    return GestureDetector(
      onTap: () {
        widget.onPick(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: //Image.asset(avatarAsset,height: 50,)
                Image(image: avatarAsset, height: 50),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                    height: 14,
                    width: 14,
                    decoration: BoxDecoration(
                        border: Border.all(color: white, width: 2),
                        color: green,
                        shape: BoxShape.circle)),
              )
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              setText('Tài xế', 14, color: gray),
              const SizedBox(height: 3),
              setText('${item.firstName!} ${item.lastName!}', 16,
                  fontWeight: FontWeight.w600, color: blue),
            ],
          )),
          Icon(Icons.radio_button_checked,
              color: widget.employee?.id == item.id ? orange : Colors.transparent)
        ],
      ),
    );
  }
}
