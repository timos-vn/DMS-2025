import 'package:flutter/material.dart';

class StatusDropdownStatus extends StatefulWidget {
  final int? initialValue;
  final Function(int) onChanged;

  const StatusDropdownStatus({Key? key, this.initialValue, required this.onChanged}) : super(key: key);

  @override
  _StatusDropdownStatusState createState() => _StatusDropdownStatusState();
}

class _StatusDropdownStatusState extends State<StatusDropdownStatus> {
  final List<Map<String, dynamic>> _statuses = [
    {'id': 1, 'name': 'Cần duyệt TBP'},
    {'id': 2, 'name': 'Cần duyệt HCNS đơn vị'},
    {'id': 3, 'name': 'Cần duyệt TGĐ'},
    {'id': 4, 'name': 'Đã duyệt'},
    {'id': 9, 'name': 'Hủy'},
  ];

  int? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialValue ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Trạng thái phiếu',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 12)
      ),
      items: _statuses.map((status) {
        return DropdownMenuItem<int>(
          value: status['id'],
          child: Text(status['name']),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedStatus = newValue;
        });
        if (newValue != null) {
          widget.onChanged(newValue);
        }
      },
    );
  }
}


class StatusDropdownIsMorning extends StatefulWidget {
  final int? initialValue;
  final Function(int) onChanged;

  const StatusDropdownIsMorning({Key? key, this.initialValue, required this.onChanged}) : super(key: key);

  @override
  _StatusDropdownIsMorningState createState() => _StatusDropdownIsMorningState();
}

class _StatusDropdownIsMorningState extends State<StatusDropdownIsMorning> {
  final List<Map<String, dynamic>> _statuses = [
    {'id': 1, 'name': 'Buổi sáng'},
    {'id': 2, 'name': 'Buổi chiều'}
  ];

  int? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialValue ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Thời gian',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 12)
      ),
      items: _statuses.map((status) {
        return DropdownMenuItem<int>(
          value: status['id'],
          child: Text(status['name'],style: TextStyle(fontSize: 12,color: Colors.black),),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedStatus = newValue;
        });
        if (newValue != null) {
          widget.onChanged(newValue);
        }
      },
    );
  }
}