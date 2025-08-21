import 'package:dms/themes/colors.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as dateFormating;

class CustomInputTimer extends StatefulWidget {


  const CustomInputTimer({Key? key}) : super(key: key);

  @override
  _CustomInputTimerState createState() => _CustomInputTimerState();
}

class _CustomInputTimerState extends State<CustomInputTimer> {

  TextEditingController soGioController = TextEditingController();

  FocusNode focusSoGio = FocusNode();
  TimeOfDay? selectedTimeStart;
  TimeOfDay? selectedTimeEnd;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dialOnly;
  Orientation? orientation;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  TextDirection textDirection = TextDirection.ltr;
  bool use24HourTime = false;
  var dateFormat = dateFormating.DateFormat("hh:mm a");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.white,),
              height: 200,
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Cập nhật thời gian cho từng máy sản xuất',
                                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      InkWell(
                                        onTap: ()=> Navigator.pop(context),
                                        child: const Icon(Icons.clear,color: Colors.black,),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8,),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => FocusScope.of(context).requestFocus(focusSoGio),
                                      child: Container(
                                        height: 35,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: TextField(
                                          maxLines: 1,
                                          autofocus: true,
                                          // obscureText: true,
                                          controller: soGioController,
                                          decoration: const InputDecoration(
                                            border: UnderlineInputBorder(borderSide: BorderSide(color: subColor, width: 1),),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: subColor, width: 1),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: subColor, width: 1),
                                            ),
                                            suffixIcon: Padding(
                                              padding: EdgeInsets.only(right: 8),
                                              child: Icon(EneftyIcons.edit_2_outline,size: 15,),
                                            ),
                                            suffixIconConstraints: BoxConstraints(maxWidth: 20),
                                            contentPadding: EdgeInsets.only(
                                                top: 10, right: 20,left: 0),
                                            isDense: false,
                                            focusColor: subColor,
                                            hintText: 'Vui lòng nhập số giờ',
                                            hintStyle: TextStyle( color: Colors.grey),
                                          ),
                                          // focusNode: focusNodeContent,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(fontSize: 13),
                                          //textInputAction: TextInputAction.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap:()async{
                                            final TimeOfDay? time = await showTimePicker(
                                              context: context,
                                              initialTime: selectedTimeStart ?? TimeOfDay.now(),
                                              initialEntryMode: entryMode,
                                              orientation: orientation,
                                              builder: (BuildContext context, Widget? child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    materialTapTargetSize: tapTargetSize,
                                                  ),
                                                  child: Directionality(
                                                    textDirection: textDirection,
                                                    child: MediaQuery(
                                                      data: MediaQuery.of(context).copyWith(
                                                        alwaysUse24HourFormat: use24HourTime,
                                                      ),
                                                      child: child!,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                            setState(() {
                                              selectedTimeStart = time;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              const Text('Time Start:'),
                                              Expanded(
                                                  child: Align(alignment: Alignment.center,child: Text(
                                                      selectedTimeStart != null ?
                                                      dateFormat.format(dateFormating.DateFormat("hh:mm").parse("${selectedTimeStart?.hour.toString()}:${selectedTimeStart?.minute.toString()}"))
                                                          : ''
                                                  ))),
                                              const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16,right: 16),
                                        child: Container(width: 1,height: 18,color: Colors.blueGrey,),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap:()async{
                                            final TimeOfDay? time = await showTimePicker(
                                              context: context,
                                              initialTime: selectedTimeEnd ?? TimeOfDay.now(),
                                              initialEntryMode: entryMode,
                                              orientation: orientation,
                                              builder: (BuildContext context, Widget? child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    materialTapTargetSize: tapTargetSize,
                                                  ),
                                                  child: Directionality(
                                                    textDirection: textDirection,
                                                    child: MediaQuery(
                                                      data: MediaQuery.of(context).copyWith(
                                                        alwaysUse24HourFormat: use24HourTime,
                                                      ),
                                                      child: child!,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                           setState(() {
                                             selectedTimeEnd = time;
                                           });
                                          },
                                          child: Row(
                                            children: [
                                              const Text('Time End:'),
                                              Expanded(
                                                  child: Align(alignment: Alignment.center,child: Text(
                                                      selectedTimeEnd != null ?
                                                      dateFormat.format(dateFormating.DateFormat("hh:mm").parse("${selectedTimeEnd?.hour.toString()}:${selectedTimeEnd?.minute.toString()}"))
                                                          : ''
                                                  ))),
                                              const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10,top: 10),
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: subColor,
                          ),
                          child: InkWell(
                            onTap: (){
                              Navigator.pop(context,[
                                soGioController.text,
                                selectedTimeStart != null ?
                                dateFormat.format(dateFormating.DateFormat("hh:mm").parse("${selectedTimeStart?.hour.toString().trim()}:${selectedTimeStart?.minute.toString().trim()}"))
                                    : '',
                                selectedTimeEnd != null ?
                                dateFormat.format(dateFormating.DateFormat("hh:mm").parse("${selectedTimeEnd?.hour.toString().trim()}:${selectedTimeEnd?.minute.toString().trim()}"))
                                    : ''
                              ]);
                            },
                            child: const Align(
                                alignment: Alignment.center,
                                child: Text('Xác nhận',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                    ],
                  )),
            ),
          ],
        ));
  }
}
