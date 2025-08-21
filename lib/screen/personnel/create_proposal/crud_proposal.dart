// import 'package:dms/screen/personnel/create_proposal/widget/build_row_with_date_picker.dart';
// import 'package:dms/screen/personnel/create_proposal/widget/build_row_with_text_field.dart';
// import 'package:dms/screen/personnel/create_proposal/widget/data_table_widget.dart';
// import 'package:dms/themes/colors.dart';
// import 'package:dms/utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../widget/pending_action.dart';
// import '../proposal/proposal_bloc.dart';
//
//
// class DynamicScreen extends StatefulWidget {
//   final String title;
//   final String controller;
//   const DynamicScreen({super.key, required this.title, required this.controller});
//
//   @override
//   State<DynamicScreen> createState() => _DynamicCRUDScreenState();
// }
//
// class _DynamicCRUDScreenState extends State<DynamicScreen> {
//
//   late ProposalBloc _bloc;
//   var formDefines;
//   var fields;
//   var grids;
//
//   Map<String, List<Map<String, dynamic>>> tableData = {};
//
//   // Dữ liệu giả lập cho AutoComplete
//   final List<Map<String, String>> employeeLookup = [
//     {
//       "ma_nv": "E001",
//       "ten_nv": "Nguyễn Văn A",
//       "chuc_vu": "IT",
//       "phong_ban": "Phòng Công Nghệ"
//     },
//     {
//       "ma_nv": "E002",
//       "ten_nv": "Trần Thị B",
//       "chuc_vu": "Kế toán",
//       "phong_ban": "Phòng Tài Chính"
//     },
//     {
//       "ma_nv": "E003",
//       "ten_nv": "Lê Văn C",
//       "chuc_vu": "Nhân sự",
//       "phong_ban": "Phòng Nhân Sự"
//     }
//   ];
//   Map<String,Set<int>> selectedRows = {};
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _bloc = ProposalBloc(context);
//     _bloc.add(GetPrefsProposal());
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener<ProposalBloc, ProposalState>(
//         bloc: _bloc,
//         listener: (context, state) {
//           if (state is ProposalFailure) {
//             Utils.showCustomToast(context, Icons.check_circle_outline, state.error.toString());
//           }
//           else if (state is GetPrefsSuccess) {
//             _bloc.add(GetFormDynamicEvent(controller: widget.controller));
//           }
//           else if(state is GetFormDynamicSuccess){
//             formDefines = _bloc.jsonListData['data']['formDefines'];
//             fields = formDefines['fields'];
//             grids = formDefines['grids'];
//             for (var grid in _bloc.jsonListData["data"]["formDefines"]["grids"]) {
//               tableData[grid["controller"]] = [];
//               selectedRows[grid["controller"]] = {};
//             }
//           }
//         },
//         child: BlocBuilder<ProposalBloc, ProposalState>(
//           bloc: _bloc,
//           builder: (BuildContext context, ProposalState state) {
//             return Stack(
//               children: [
//                 buildBody(context, state),
//                 Visibility(
//                   visible: state is GetListProposalEmpty,
//                   child: const Center(
//                     child: Text('Úi, Không có gì ở đây cả!!!',
//                         style: TextStyle(color: Colors.blueGrey)),
//                   ),
//                 ),
//                 Visibility(
//                   visible: state is ProposalLoading,
//                   child: const PendingAction(),
//                 )
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   buildBody(BuildContext context, ProposalState state) {
//     return Container(
//       height: double.infinity,
//       width: double.infinity,
//       padding: const EdgeInsets.only(bottom: 0),
//       child: Column(
//         children: [
//           buildAppBar(),
//           const SizedBox(
//             height: 10,
//           ),
//           Expanded(
//             child: Stack(
//               children: [
//                 buildBusiness(context),
//                 Positioned(
//                   right: 20,
//                   bottom: 20,
//                   child: Row(
//                     children: [
//                       Container(
//                           width: 65,
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             color: dark_text,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             "Huỷ",
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                             ),
//                           )),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Container(
//                           width: 65,
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             color: kSecondaryColor,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             "Gửi",
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                             ),
//                           )),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   buildAppBar() {
//     return Container(
//       height: 83,
//       width: double.infinity,
//       decoration: BoxDecoration(
//           boxShadow: <BoxShadow>[
//             BoxShadow(
//                 color: Colors.grey.shade200,
//                 offset: const Offset(2, 4),
//                 blurRadius: 5,
//                 spreadRadius: 2)
//           ],
//           gradient: const LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
//       padding: const EdgeInsets.fromLTRB(5, 35, 12, 0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           InkWell(
//             onTap: () => Navigator.pop(context),
//             child: const SizedBox(
//               width: 40,
//               height: 50,
//               child: Icon(
//                 Icons.arrow_back_rounded,
//                 size: 25,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Center(
//               child: Text(
//                 widget.title[0].toUpperCase() + widget.title.substring(1),
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 17,
//                   color: Colors.white,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),
//           const SizedBox(
//             width: 10,
//           ),
//           const SizedBox(
//             width: 40,
//             height: 50,
//             child: Icon(
//               Icons.check,
//               size: 25,
//               color: Colors.transparent,
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget buildBusiness(BuildContext context) {
//     if (_bloc.jsonListData.isEmpty) {
//       return Scaffold(body: Center());
//     }
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ...fields.map<Widget>((field) => buildInputField(field)).toList(),
//         SizedBox(height: 20),
//         Expanded(
//           child: ListView(
//             children: grids.map<Widget>((grid) {
//               return buildTable(grid["controller"], grid["fields"]);
//             }).toList(),
//           ),
//         ),
//         // ...grids.map<Widget>((grid) => buildTable(grid)).toList(),
//       ],
//     );
//   }
//
//   /// **Hàm tạo các input field từ JSON**
//   Widget buildInputField(Map<String, dynamic> field) {
//     String type = field['type'];
//     String title = field['title'];
//     bool readOnly = field['readOnly'];
//     var props = field['props'];
//
//     if (props != null && props['style'] == 'DropDownList') {
//       List<dynamic> items = props['item'];
//       return DropdownButtonFormField(
//         decoration:
//         InputDecoration(labelText: title, border: OutlineInputBorder()),
//         items: items.map((item) {
//           return DropdownMenuItem(
//               value: item['value'], child: Text(item['text']));
//         }).toList(),
//         onChanged: readOnly ? null : (value) {},
//       );
//     }
//
//     return TextFormField(
//       decoration:
//       InputDecoration(labelText: title, border: OutlineInputBorder()),
//       readOnly: readOnly,
//     );
//   }
//
//   /// **Hàm tạo bảng từ JSON**
//   Widget buildTable1(String controller, List<dynamic> fields) {
//     // var fields = grid['fields'];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Text(grid['controller'],
//         //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: DataTable(
//               columnSpacing: 20,
//               columns: fields.map<DataColumn>((field) {
//                 return DataColumn(
//                     label: Text(field['title'],
//                         style: TextStyle(fontWeight: FontWeight.bold)));
//               }).toList(),
//               rows: [
//                 ...tableData[controller]!.map<DataRow>((row) {
//                   return DataRow(
//                     selected: selectedRow[controller]!.contains(row.values.first),
//                       cells: fields.map<DataCell>((field) {
//                         return DataCell(SizedBox(
//                           width: 150, // Đặt chiều rộng cho từng ô
//                           child: buildTableCell(field, row),
//                         ));
//                       }).toList());
//                 }),
//
//               ],
//             ),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             setState(() {
//               tableData[controller]!.add({});
//             });
//           },
//           child: Text("Thêm dòng"),
//         ),
//         SizedBox(width: 10,),
//         ElevatedButton(
//           onPressed: () {
//             setState(() {
//               // tableData[controller]!.removeWhere((_,index));
//             });
//           },
//           child: Text("Xoá dòng đã chọn"),
//         ),
//       ],
//     );
//   }
//
//   Widget buildTable(String controller, List<dynamic> fields) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(controller, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             columns: [
//               DataColumn(label: Text("Chọn")),
//               ...fields.map((field) => DataColumn(label: Text(field['title']))).toList(),
//             ],
//             rows: List.generate(tableData[controller]!.length, (index) {
//               var row = tableData[controller]![index];
//               return DataRow(
//                 selected: selectedRows[controller]!.contains(index),
//                 onSelectChanged: (selected) {
//                   setState(() {
//                     if (selected == true) {
//                       selectedRows[controller]!.add(index);
//                     } else {
//                       selectedRows[controller]!.remove(index);
//                     }
//                   });
//                 },
//                 cells: [
//                   DataCell(Checkbox(
//                     value: selectedRows[controller]!.contains(index),
//                     onChanged: (bool? value) {
//                       setState(() {
//                         if (value == true) {
//                           selectedRows[controller]!.add(index);
//                         } else {
//                           selectedRows[controller]!.remove(index);
//                         }
//                       });
//                     },
//                   )),
//                   ...fields.map((field) => DataCell(buildTableCell(field, row, controller))).toList(),
//                 ],
//               );
//             }),
//           ),
//         ),
//         Row(
//           children: [
//             ElevatedButton(onPressed: () => addRow(controller), child: Text("Thêm dòng")),
//             SizedBox(width: 10),
//             ElevatedButton(
//               onPressed: selectedRows[controller]!.isNotEmpty ? () => deleteSelectedRows(controller) : null,
//               child: Text("Xóa dòng đã chọn"),
//             ),
//           ],
//         ),
//         SizedBox(height: 20),
//       ],
//     );
//   }
//
//   /// **Hàm tạo từng ô trong bảng**
//   Widget buildTableCell(Map<String, dynamic> field, Map<String, dynamic> row,
//       {bool isNewRow = false}) {
//     String type = field['type'];
//     bool readOnly = field['readOnly'];
//     var props = field['props'];
//
//     if (props != null && props['style'] == 'AutoComplete') {
//       return GestureDetector(
//         onTap: () => showEmployeeLookup(context, field, row),
//         child: Text(row[field['name']] ?? "Chọn nhân viên"),
//       );
//     }
//
//     return TextField(
//       controller: TextEditingController(text: row[field['name']] ?? ""),
//       readOnly: readOnly,
//       decoration: InputDecoration(border: InputBorder.none),
//       onChanged: (value) {
//         row[field['name']] = value;
//       },
//     );
//   }
//
//   /// **Hàm hiển thị Popup tìm kiếm nhân viên**
//   void showEmployeeLookup(BuildContext context, Map<String, dynamic> field,
//       Map<String, dynamic> row) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Chọn nhân viên"),
//           content: Container(
//             width: double.maxFinite,
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: employeeLookup.length,
//               itemBuilder: (context, index) {
//                 var emp = employeeLookup[index];
//                 return ListTile(
//                   title: Text(emp['ten_nv']!),
//                   subtitle: Text("${emp['chuc_vu']} - ${emp['phong_ban']}"),
//                   onTap: () {
//                     setState(() {
//                       row[field['name']] = emp['ma_nv'];
//                       List<String> referenceFields =
//                       field['props']['referenceTo'].split(",");
//                       for (var refField in referenceFields) {
//                         row[refField.trim()] = emp[refField.trim()];
//                       }
//                     });
//                     Navigator.pop(context);
//                   },
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
