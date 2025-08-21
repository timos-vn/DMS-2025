import 'package:flutter/material.dart';

class DataTableWidget extends StatefulWidget {
  const DataTableWidget({key});

  @override
  _DataTableWidgetState createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  List<Employee> employees = [
    Employee(
        id: 'GĐ001',
        name: 'Nguyễn Văn A',
        position: 'Giám đốc',
        department: ''),
    Employee(
        id: 'NV001',
        name: 'Nguyễn Văn B',
        position: 'Nhân viên',
        department: 'HCNS'),
  ];

  void _addEmployee() {
    setState(() {
      employees.add(Employee(
        id: 'NV${(employees.length + 1).toString().padLeft(3, '0')}',
        name: 'Nhân viên Mới',
        position: 'Nhân viên',
        department: '',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(color: Colors.grey),
        columns: [
          DataColumn(label: Text('STT')),
          DataColumn(label: Text('Mã NS')),
          DataColumn(label: Text('Tên NS')),
          DataColumn(label: Text('Chức vụ')),
          DataColumn(label: Text('Phòng ban')),
        ],
        rows: [
          ...List.generate(employees.length, (index) {
            return DataRow(cells: [
              DataCell(Text((index + 1).toString())),
              DataCell(Text(employees[index].id)),
              DataCell(Text(employees[index].name)),
              DataCell(Text(employees[index].position)),
              DataCell(Text(employees[index].department)),
            ]);
          }),
          DataRow(cells: [
            DataCell(
              InkWell(
                onTap: _addEmployee,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
          ]),
        ],
      ),
    );
  }
}

class Employee {
  final String id;
  final String name;
  final String position;
  final String department;

  Employee(
      {required this.id,
      required this.name,
      required this.position,
      required this.department});
}
