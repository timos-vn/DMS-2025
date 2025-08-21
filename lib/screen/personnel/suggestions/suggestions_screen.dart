// import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms/screen/personnel/suggestions/suggestions_bloc.dart';
import 'package:dms/screen/personnel/suggestions/suggestions_event.dart';
import 'package:dms/screen/personnel/suggestions/suggestions_state.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as dateFormating;

import '../../../model/network/request/create_leave_letter_request.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../filter/filter_page.dart';
import '../component/create_dnc.dart';
import '../component/list_dnc.dart';


class SuggestionsScreen extends StatefulWidget {
  final int keySuggestion;
  final String title;

  const SuggestionsScreen({Key? key, required this.keySuggestion,required this.title}) : super(key: key);
  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  FocusNode focusNodeContent = FocusNode();

  FocusNode focusNodeCar = FocusNode();
  FocusNode dateNodeCar = FocusNode();
  final TextEditingController _carController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? departmentCode,departmentName;
  String codeLeaveLetter = '';String nameLeaveLetter = '';
  String codeCongLetter = '';String nameCongLetter = '';
  TimeOfDay? selectedTimeStart;
  TimeOfDay? selectedTimeEnd;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dialOnly;
  Orientation? orientation;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  TextDirection textDirection = TextDirection.ltr;
  bool use24HourTime = false;
  var dateFormat = dateFormating.DateFormat("hh:mm a");
  late SuggestionsBloc _bloc;
  bool isTangCa = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SuggestionsBloc(context);
    dateController.text = '1';
    _bloc.add(GetPrefsSuggestions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SuggestionsBloc,SuggestionsState>(
        bloc: _bloc,
        listener: (context, state){
          if(state is CreateLeaveLetterSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Tạo phiếu thành công');
            Navigator.pop(context,['ReloadScreen']);
          }else if(state is SuggestionsFailure){
            Utils.showCustomToast(context, Icons.check_circle_outline, state.error.toString());
          }
        },
        child: BlocBuilder<SuggestionsBloc,SuggestionsState>(
          bloc: _bloc,
          builder: (BuildContext context, SuggestionsState state){
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is GetListDNCEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is SuggestionsLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      )
    );
  }

  buildBody(BuildContext context,SuggestionsState state){
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: widget.keySuggestion == 1 ? buildLeave(context) : (widget.keySuggestion == 2 ? buildMoney(context)  : buildCar(context)),
          )
        ],
      ),
    );
  }

  buildAppBar(){
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
              colors: [subColor,Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.pop(context),
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
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
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

  Widget buildLeave(BuildContext context){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Từ ngày: ${Utils.parseDateToString(_bloc.dateFrom, Const.DATE_SV_FORMAT_2)}')),
                ),
                const SizedBox(width: 5,),
                SizedBox(
                  height: 45,
                  width: 50,
                  child: InkWell(
                    onTap: (){
                      Utils.dateTimePickerCustom(context).then((value){
                        if(value != null){
                          setState(() {
                            _bloc.dateFrom = Utils.parseStringToDate(Utils.safeFormatDate(value.toString()), Const.DATE_SV_FORMAT);
                          });
                        }
                      });
                    },
                    child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Tới ngày: ${Utils.parseDateToString(_bloc.dateTo, Const.DATE_SV_FORMAT_2)}',overflow: TextOverflow.ellipsis,maxLines: 1,)),
                ),
                const SizedBox(width: 5,),
                SizedBox(
                  height: 45,
                  width: 50,
                  child: InkWell(
                    onTap: (){
                      Utils.dateTimePickerCustom(context).then((value){
                        if(value != null){
                          setState(() {
                            _bloc.dateTo = Utils.parseStringToDate(Utils.safeFormatDate(value.toString()), Const.DATE_SV_FORMAT);
                          });
                        }
                      });
                    },
                    child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Số ngày',overflow: TextOverflow.ellipsis,maxLines: 1,)),
                ),
                const SizedBox(width: 15,),
                Expanded(
                  flex: 5,
                  child: GestureDetector(
                    onTap: ()=> FocusScope.of(context).requestFocus(dateNodeCar),
                    child:  Container(
                      height: 35 ,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.grey,width: 0.5)
                      ),
                      child: TextField(
                        maxLines: 1,
                        //obscureText: true,
                        controller: dateController,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, ),
                          ),
                          contentPadding: EdgeInsets.all(8),
                          hintText: 'Vui lòng nhập số ngày nghỉ',
                          hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.grey,fontSize: 12),
                        ),
                        focusNode: dateNodeCar,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 14),
                        //textInputAction: TextInputAction.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15,),
            Visibility(
              visible: isTangCa == true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
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
                            const Text('Giờ BĐ:'),
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
                            const Text('Giờ KT:'),
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
              ),
            ),
            Row(
              children: [
                const Expanded(
                    flex: 1,
                    child: Text('Lý do   ')),
                Expanded(
                  flex: 4,
                  child:InkWell(
                    onTap: (){
                      showDialog(
                          context: context,
                          builder: (context) => const FilterScreen(controller: 'hrdmloainghi_lookup',
                            listItem: null,show: false,)).then((value){
                        if(value != null){
                          setState(() {
                            codeLeaveLetter = value[0];
                            nameLeaveLetter = value[1];
                            if(codeLeaveLetter.toString().trim().contains('TC')){
                              isTangCa = true;
                            }else{
                              isTangCa = false;
                            }
                          });
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(nameLeaveLetter.toString(),style: const TextStyle(color: Colors.black,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.search,color: Colors.grey,),
                        ],
                      ),
                    ),
                  )
                )
              ],
            ),
            const SizedBox(height: 30,),
            Row(
              children: [
                const Expanded(
                    flex: 1,
                    child: Text('Công     ')),
                Expanded(
                  flex: 4,
                  child:InkWell(
                    onTap: (){
                      showDialog(
                          context: context,
                          builder: (context) => const FilterScreen(controller: 'dmcong_lookup',
                            listItem: null,show: false,)).then((value){
                        if(value != null){
                          setState(() {
                            codeCongLetter = value[0];
                            nameCongLetter = value[1];
                          });
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(nameCongLetter.toString(),style: const TextStyle(color: Colors.black,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.search,color: Colors.grey,),
                        ],
                      ),
                    ),
                  )
                )
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Số ngày nghỉ phép còn lại'),
                Text('${_bloc.remainingDaysOff} ngày'),
              ],
            ),
            const SizedBox(height: 20,),
            const Align(alignment:Alignment.centerLeft,child: Text('Mô tả')),
            const SizedBox(height: 10,),
            GestureDetector(
              onTap: ()=> FocusScope.of(context).requestFocus(focusNodeContent),
              child:  Container(
                height: 150 ,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: TextField(
                  maxLines: 10,
                  //obscureText: true,
                  controller: _contentController,
                  decoration:  const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, ),
                    ),
                    contentPadding: EdgeInsets.all(8),
                    hintText: 'Vui lòng nhập mô tả',
                    hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.grey),
                  ),
                  focusNode: focusNodeContent,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 14),
                  //textInputAction: TextInputAction.none,
                ),
              ),
            ),
            const SizedBox(height: 30,),
            GestureDetector(
              onTap: (){
                if(_bloc.dateFrom.toString().isNotEmpty && _bloc.dateTo.toString().isNotEmpty && codeLeaveLetter.isNotEmpty){
                  CreateLeaveLetterRequest request = CreateLeaveLetterRequest(
                    dateFrom: Utils.parseDateToString(_bloc.dateFrom, Const.DATE_SV_FORMAT),
                    dateTo:Utils.parseDateToString(_bloc.dateTo, Const.DATE_SV_FORMAT),
                    leaveType: codeLeaveLetter,
                    description: _contentController.text,
                    maCong: codeCongLetter,
                    date: double.parse(dateController.text.toString()),
                    timeFrom: "${selectedTimeStart?.hour.toString().trim()}:${selectedTimeStart?.minute.toString().trim()}",
                    timeTo: "${selectedTimeEnd?.hour.toString().trim()}:${selectedTimeEnd?.minute.toString().trim()}",
                  );
                  _bloc.add(CreateLeaveLetterEvent(request: request));
                }else{
                  Utils.showCustomToast(context, Icons.warning, 'Vui lòng nhập đầy đủ thông tin');
                }
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 100.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      color: mainColor
                  ),
                  child: const Center(
                    child: Text(
                      'Gửi',
                      style: TextStyle( fontSize: 16, color: Colors.white,),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildMoney(BuildContext context){
    return Column(
      children: [
        const SizedBox(height: 12,),
        GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateDNCScreen())), child: buildItem(context, 'Tạo mới Đề Nghị Chi', Colors.purple.withOpacity(0.7), Icons.transfer_within_a_station)),
        GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ListDNC())), child: buildItem(context, 'Danh sách Đề Nghị Chi', Colors.grey.withOpacity(0.7), Icons.switch_account)),
      ],
    );
  }

  Widget buildCar(BuildContext context){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Từ ngày')),
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: ()async {
                            // final DateTime result = await showDialog<dynamic>(
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //       return DateRangePicker(
                            //         // _bloc.dateFrom ??
                            //         DateTime.now(),
                            //         null,
                            //         minDate: DateTime.now().subtract(const Duration(days: 10000)),
                            //         maxDate:
                            //         DateTime.now().add(const Duration(days: 10000)),
                            //         displayDate:// _bloc.dateFrom ??
                            //         DateTime.now(),
                            //       );
                            //     });
                            // if (result != null) {
                            //   // _bloc.add(DateFrom(result));
                            // }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.6),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(child: Text(
                                  // !Utils.isEmpty(_bloc.dateFrom) ?
                                  // DateFormat('yyyy-MM-dd').format(_bloc.dateFrom) :
                                    ''
                                    ,style: TextStyle(color: Colors.grey,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis)),
                                Icon(Icons.event,color: Colors.grey,),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Đến ngày',overflow: TextOverflow.ellipsis,maxLines: 1,)),
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: ()async {
                            // final DateTime result = await showDialog<dynamic>(
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //       return DateRangePicker(
                            //         // _bloc.dateTo ??
                            //         DateTime.now(),
                            //         null,
                            //         minDate: DateTime.now().subtract(const Duration(days: 10000)),
                            //         maxDate:
                            //         DateTime.now().add(const Duration(days: 10000)),
                            //         displayDate: //_bloc.dateTo ??
                            //         DateTime.now(),
                            //       );
                            //     });
                            // if (result != null) {
                            //   // _bloc.add(DateTo(result));
                            // }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.6),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(child: Text(
                                  // !Utils.isEmpty(_bloc.dateTo) ? DateFormat('yyyy-MM-dd').format(_bloc.dateTo) :
                                    '',style: TextStyle(color: Colors.grey,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis)),
                                Icon(Icons.event,color: Colors.grey,),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30,),
            Row(
              children: [
                const Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Địa điểm đi',overflow: TextOverflow.ellipsis,maxLines: 1,)),
                ),
                const SizedBox(width: 5,),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: ()=> FocusScope.of(context).requestFocus(focusNodeCar),
                    child:  Container(
                      height: 40 ,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        // border: Border.all(color: Colors.grey,width: 0.5)
                      ),
                      child: TextField(
                        maxLines: 1,
                        //obscureText: true,
                        controller: _carController,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, ),
                          ),
                          contentPadding: EdgeInsets.all(8),
                          hintText: 'Vui lòng nhập địa điểm đi',
                          hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.grey,fontSize: 12),
                        ),
                        focusNode: focusNodeCar,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 14),
                        //textInputAction: TextInputAction.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30,),
            Row(
              children: [
                const Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Địa điểm đến',overflow: TextOverflow.ellipsis,maxLines: 1,)),
                ),
                const SizedBox(width: 5,),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: ()=> FocusScope.of(context).requestFocus(focusNodeCar),
                    child:  Container(
                      height: 40 ,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        // border: Border.all(color: Colors.grey,width: 0.5)
                      ),
                      child: TextField(
                        maxLines: 1,
                        //obscureText: true,
                        controller: _carController,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, ),
                          ),
                          contentPadding: EdgeInsets.all(8),
                          hintText: 'Vui lòng nhập địa điểm đến',
                          hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.grey,fontSize: 12),
                        ),
                        focusNode: focusNodeCar,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 14),
                        //textInputAction: TextInputAction.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30,),
            Row(
              children: [
                const Expanded(
                    flex: 1,
                    child: Text('Gửi đến')),
                Expanded(
                    flex: 2,
                    child:InkWell(
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) => const FilterScreen(controller: 'dmbp_lookup',
                              listItem: null,show: false,)).then((value){
                          if(value != ''){
                            setState(() {
                              departmentCode = value[0];
                              departmentName = value[1];
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(departmentName?.toString()??'',style: const TextStyle(color: Colors.grey,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis)),
                            const Icon(Icons.search,color: Colors.grey,),
                          ],
                        ),
                      ),
                    )
                )
              ],
            ),
            const SizedBox(height: 20,),
            const Align(alignment:Alignment.centerLeft,child: Text('Mô tả')),
            const SizedBox(height: 10,),
            GestureDetector(
              onTap: ()=> FocusScope.of(context).requestFocus(focusNodeContent),
              child:  Container(
                height: 150 ,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: TextField(
                  maxLines: 10,
                  //obscureText: true,
                  controller: _contentController,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, ),
                    ),
                    contentPadding: EdgeInsets.all(8),
                    hintText: 'Vui lòng nhập mô tả',
                    hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.grey),
                  ),
                  focusNode: focusNodeContent,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 14),
                  //textInputAction: TextInputAction.none,
                ),
              ),
            ),
            const SizedBox(height: 30,),
            GestureDetector(
              onTap: (){
                //login(hostIdController.text,usernameController.text,passwordController.text,isChecked);
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 100.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      color: mainColor
                  ),
                  child: const Center(
                    child: Text(
                      'Gửi',
                      style: TextStyle( fontSize: 16, color: Colors.white,),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, String name, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Card(
        elevation: 5,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: color,
                  ),
                  child: Center(
                      child: Icon(
                        icon,
                        size: 15,
                        color: Colors.white,
                      ))),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  name,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
