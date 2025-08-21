import 'dart:convert';
import 'package:flutter/material.dart';



class DynamicFormScreen extends StatefulWidget {
  @override
  _DynamicFormScreenState createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  Map<String, dynamic> jsonData = {};
  // List<Map<String, dynamic>> tableData = [];
  Map<String, List<Map<String, dynamic>>> tableData = {};

  // Dữ liệu giả lập cho AutoComplete
  final List<Map<String, String>> employeeLookup = [
    {
      "ma_nv": "E001",
      "ten_nv": "Nguyễn Văn A",
      "chuc_vu": "IT",
      "phong_ban": "Phòng Công Nghệ"
    },
    {
      "ma_nv": "E002",
      "ten_nv": "Trần Thị B",
      "chuc_vu": "Kế toán",
      "phong_ban": "Phòng Tài Chính"
    },
    {
      "ma_nv": "E003",
      "ten_nv": "Lê Văn C",
      "chuc_vu": "Nhân sự",
      "phong_ban": "Phòng Nhân Sự"
    }
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    String jsonString = '''{
      "data": {
        "formDefines": {
          "title": "Đề xuất đi công tác",
          "fields": [
          {
              "name": "uu_tien",
              "type": "Text",
              "title": "Ưu tiên",
              "readOnly": false,
              "props": {
                "style": "DropDownList",
                "item": [
                  {"value": "0", "text": "Bình thường"},
                  {"value": "1", "text": "Cao"},
                  {"value": "2", "text": "Thấp"}
                ]
              }
            }
          ],
          "grids": [
            {
              "controller": "BusinessTripDetail",
              "fields": [
                {
                  "name": "ma_nv",
                  "type": "Text",
                  "title": "Mã nhân sự",
                  "readOnly": false,
                  "props": {
                    "style": "AutoComplete",
                    "referenceTo": "ten_nv,chuc_vu,phong_ban"
                  }
                },
                {"name": "ten_nv", "type": "Text", "title": "Tên nhân sự", "readOnly": true},
                {"name": "chuc_vu", "type": "Text", "title": "Chức vụ", "readOnly": true},
                {"name": "phong_ban", "type": "Text", "title": "Phòng ban", "readOnly": true}
              ]
            },
            {
              "controller": "BusinessTripCostDetail",
              "fields": [
                {
                  "id": 1,
                  "name": "ma_phi",
                  "type": "Text",
                  "required": false,
                  "title": "Mã phí",
                  "readOnly": false,
                  "props": {
                    "style": "AutoComplete",
                    "referenceTo": "ten_phi",
                    "item": []
                  }
                },
                {"name": "ten_phi", "type": "Text", "title": "Tên phí", "readOnly": true},
                {"name": "tien", "type": "Int", "title": "Tiền", "readOnly": true}
              ]
            }
          ]
        }
      }
    }''';

    setState(() {
      jsonData = json.decode(jsonString);
      for (var grid in jsonData["data"]["formDefines"]["grids"]) {
        tableData[grid["controller"]] = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (jsonData.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    var formDefines = jsonData['data']['formDefines'];

    var fields = formDefines['fields'];
    var grids = formDefines['grids'];

    return Scaffold(
      appBar: AppBar(title: Text(formDefines['title'] ?? "Form động")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...fields.map<Widget>((field) => buildInputField(field)).toList(),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: grids.map<Widget>((grid) {
                return buildTable(grid["controller"], grid["fields"]);
              }).toList(),
            ),
          ),
          // ...grids.map<Widget>((grid) => buildTable(grid)).toList(),
        ],
      ),
    );
  }

  /// **Hàm tạo các input field từ JSON**
  Widget buildInputField(Map<String, dynamic> field) {
    String type = field['type'];
    String title = field['title'];
    bool readOnly = field['readOnly'];
    var props = field['props'];

    if (props != null && props['style'] == 'DropDownList') {
      List<dynamic> items = props['item'];
      return DropdownButtonFormField(
        decoration:
        InputDecoration(labelText: title, border: OutlineInputBorder()),
        items: items.map((item) {
          return DropdownMenuItem(
              value: item['value'], child: Text(item['text']));
        }).toList(),
        onChanged: readOnly ? null : (value) {},
      );
    }

    return TextFormField(
      decoration:
      InputDecoration(labelText: title, border: OutlineInputBorder()),
      readOnly: readOnly,
    );
  }

  /// **Hàm tạo bảng từ JSON**
  Widget buildTable(String controller, List<dynamic> fields) {
    // var fields = grid['fields'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(grid['controller'],
        //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 20,
              columns: fields.map<DataColumn>((field) {
                return DataColumn(
                    label: Text(field['title'],
                        style: TextStyle(fontWeight: FontWeight.bold)));
              }).toList(),
              rows: [
                ...tableData[controller]!.map<DataRow>((row) {
                  return DataRow(
                      cells: fields.map<DataCell>((field) {
                        return DataCell(SizedBox(
                          width: 150, // Đặt chiều rộng cho từng ô
                          child: buildTableCell(field, row),
                        ));
                      }).toList());
                }),
                // DataRow(
                //   cells: fields.map<DataCell>((field) {
                //     return DataCell(SizedBox(
                //       width: 150,
                //       child: buildTableCell(field, {}, isNewRow: true),
                //     ));
                //   }).toList(),
                // ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              tableData[controller]!.add({});
            });
          },
          child: Text("Thêm dòng"),
        ),
      ],
    );
  }

  /// **Hàm tạo từng ô trong bảng**
  Widget buildTableCell(Map<String, dynamic> field, Map<String, dynamic> row,
      {bool isNewRow = false}) {
    String type = field['type'];
    bool readOnly = field['readOnly'];
    var props = field['props'];

    if (props != null && props['style'] == 'AutoComplete') {
      return GestureDetector(
        onTap: () => showEmployeeLookup(context, field, row),
        child: Text(row[field['name']] ?? "Chọn nhân viên"),
      );
    }

    return TextField(
      controller: TextEditingController(text: row[field['name']] ?? ""),
      readOnly: readOnly,
      decoration: InputDecoration(border: InputBorder.none),
      onChanged: (value) {
        row[field['name']] = value;
      },
    );
  }

  /// **Hàm hiển thị Popup tìm kiếm nhân viên**
  void showEmployeeLookup(BuildContext context, Map<String, dynamic> field,
      Map<String, dynamic> row) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Chọn nhân viên"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: employeeLookup.length,
              itemBuilder: (context, index) {
                var emp = employeeLookup[index];
                return ListTile(
                  title: Text(emp['ten_nv']!),
                  subtitle: Text("${emp['chuc_vu']} - ${emp['phong_ban']}"),
                  onTap: () {
                    setState(() {
                      row[field['name']] = emp['ma_nv'];
                      List<String> referenceFields =
                      field['props']['referenceTo'].split(",");
                      for (var refField in referenceFields) {
                        row[refField.trim()] = emp[refField.trim()];
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
