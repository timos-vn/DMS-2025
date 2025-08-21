import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:table_calendar/table_calendar.dart';

import 'constant.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({key, required this.date});

  final DateTime date;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final kToday = DateTime.now();

  @override
  void initState() {
    _selectedDay = widget.date;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
              locale: 'vi_VN',
              firstDay: DateTime(2022),
              lastDay: DateTime(kToday.year + 1, kToday.month, kToday.day),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              headerStyle: HeaderStyle(
                  headerMargin: EdgeInsets.zero,
                  titleTextStyle:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: black),
                  titleTextFormatter: (date, locale) =>
                      DateFormat('MMMM yyyy', locale).format(date).capitalize(),
                  formatButtonVisible: false,
                  titleCentered: true),
              daysOfWeekHeight: 30,
              daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                      color: Color(0xffE53434), fontSize: 16, fontWeight: FontWeight.bold),
                  weekdayStyle: TextStyle(
                      color: Color(0xff777777), fontSize: 16, fontWeight: FontWeight.bold)),
              weekendDays: const [DateTime.sunday],
              calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue),
                      shape: BoxShape.circle),
                  todayTextStyle: const TextStyle(fontSize: 15, color: black),
                  selectedDecoration: const BoxDecoration(color: orange, shape: BoxShape.circle),
                  selectedTextStyle: const TextStyle(color: white, fontSize: 15),
                  defaultTextStyle: const TextStyle(fontSize: 15, color: black)),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  Navigator.pop(context, selectedDay);
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
