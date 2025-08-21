import 'package:dms/screen/personnel/create_proposal/widget/build_row_with_date_picker.dart';
import 'package:dms/screen/personnel/create_proposal/widget/build_row_with_text_field.dart';
import 'package:dms/screen/personnel/create_proposal/widget/data_table_widget.dart';
import 'package:dms/themes/colors.dart';
import 'package:flutter/material.dart';

import 'widget/build_row.dart';

class CreateProposalScreen extends StatefulWidget {
  final String title;
  const CreateProposalScreen({key, required this.title});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        buildBody(context),
        // Visibility(
        //   visible: state is GetListProposalEmpty,
        //   child: const Center(
        //     child: Text('Úi, Không có gì ở đây cả!!!',
        //         style: TextStyle(color: Colors.blueGrey)),
        //   ),
        // ),
        // Visibility(
        //   visible: state is ProposalLoading,
        //   child: const PendingAction(),
        // )
      ],
    ));
  }

  buildBody(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Stack(
              children: [
                buildBusiness(context),
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Row(
                    children: [
                      Container(
                          width: 65,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: dark_text,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Huỷ",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                          width: 65,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: kSecondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Gửi",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildAppBar() {
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.title[0].toUpperCase() + widget.title.substring(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.check,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  Widget buildBusiness(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildRow(label: "Người đề xuất", value: "Nguyễn Văn A"),
            const SizedBox(
              height: 10,
            ),
            BuildRowWithDatePicker(label: "Từ ngày", date: '01/01/2021'),
            const SizedBox(
              height: 10,
            ),
            BuildRowWithDatePicker(label: "Đến ngày", date: '01/01/2021'),
            const SizedBox(
              height: 10,
            ),
            Text("Nội dung"),
            const SizedBox(
              height: 5,
            ),
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung công tác ...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            BuildRowWithTextField(label: "Mã phí", hint: "Search"),
            const SizedBox(
              height: 10,
            ),
            BuildRowWithTextField(label: "Giá trị", hint: ""),
            const SizedBox(
              height: 10,
            ),
            Text("Danh sách nhân sự tham gia công tác"),
            const SizedBox(
              height: 5,
            ),
            DataTableWidget(),
          ],
        ),
      ),
    );
  }
}
