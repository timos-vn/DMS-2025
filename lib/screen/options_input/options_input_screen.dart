import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../model/network/response/list_status_response.dart';
import '../../themes/colors.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';
import 'options_input_bloc.dart';
import 'options_input_event.dart';
import 'options_input_state.dart';


class OptionsFilterDate extends StatefulWidget {
  final List<ListStatusApprovalResponseData>? listStatus;

  final String? dateFrom;
  final String? dateTo;

  const OptionsFilterDate({Key? key, this.listStatus, this.dateFrom, this.dateTo}) : super(key: key);
  @override
  _OptionsFilterDateState createState() => _OptionsFilterDateState();
}

class _OptionsFilterDateState extends State<OptionsFilterDate> {

  late OptionsInputBloc _bloc;
  String statusTypeName = 'Chờ duyệt';
  int statusType = 0;
  String toDate ="";
  String fromDate="";
  ListStatusApprovalResponseData? itemData;

  String dateFrom = '';
  String dateTo = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = OptionsInputBloc(context);
    List<ListStatusApprovalResponseData> listStatus =widget.listStatus??[];

    if(widget.listStatus != null){

      // itemData = widget.listStatus?[0];
    }
    if(widget.dateFrom.toString().replaceAll('null', '').isNotEmpty){
      dateFrom =  widget.dateFrom.toString();
      _bloc.add(DateFrom(Utils.parseStringToDate(dateFrom, Const.DATE_FORMAT_2)));
    }else{
      dateFrom = DateTime.now().toString();
    }
    if(widget.dateTo.toString().replaceAll('null', '').isNotEmpty){
      dateTo =  widget.dateTo.toString();
      _bloc.add(DateTo(Utils.parseStringToDate(dateTo, Const.DATE_FORMAT_2)));
    }else{
      dateTo = DateTime.now().toString();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
        body: BlocListener<OptionsInputBloc,OptionsInputState>(
          bloc: _bloc,
            listener: (context, state){
              if (state is WrongDate) {
                Utils.showCustomToast(context, Icons.warning_amber_outlined, '\'Từ ngày\' phải là ngày trước \'Đến ngày\'');
              }else if(state is PickDateSuccess){
              }
            },
            child: BlocBuilder<OptionsInputBloc,OptionsInputState>(
              bloc: _bloc,
              builder: (BuildContext context, OptionsInputState state){
                return buildPage(context,state);
              },
            )
        )
    );
  }

  Widget buildPage(BuildContext context,OptionsInputState state){
    return Padding(
      padding: const EdgeInsets.only(top: 35,bottom: 35),
      child: AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Column(children: [
                Text('Bộ lọc',style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                Divider(),
                SizedBox(height: 10,),
            ],),
            Visibility(
              visible: widget.listStatus?.isNotEmpty == true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          const Text(
                            "Trạng thái",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Expanded(child: genderStatus2()),
                          const SizedBox(width: 5,)
                        ],
                      )
                  ),
                  SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          const Text(
                            "Loại           ",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Expanded(child: genderType()),
                          const SizedBox(width: 5,)
                        ],
                      )
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ///or
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          height: 1,
                          color: Colors.blue.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 3,),
                      const Text(
                        'Hoặc',
                        style: TextStyle(fontSize: 12,color: Colors.grey),
                      ),
                      const SizedBox(width: 3,),
                      Expanded(
                        child: Divider(
                          height: 1,
                          color: Colors.blue.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
            ///FromDate
            Container(
              padding:const EdgeInsets.only(left: 12,right: 2,top: 10,bottom: 10),
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: grey.withOpacity(0.8),width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(8))
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        const Text('Từ ngày: ',style:  TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,),
                        const SizedBox(width: 5,),
                        Text(Utils.parseStringDateToString(_bloc.dateFrom.toString(), Const.DATE_TIME_FORMAT,Const.DATE_FORMAT_1),style: const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),
                      ],
                    ),
                    SizedBox(
                      width: 50,
                      child: InkWell(
                        onTap: (){
                          Utils.dateTimePickerCustom(context).then((value){
                            if(value != null){
                              setState(() {
                                _bloc.add(DateFrom(value));
                              });
                            }
                          });
                        },
                        child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                      ),
                    ),
                  ]),
            ),
            const SizedBox(
              height: 10,
            ),
            ///ToDate
            Container(
              padding:const EdgeInsets.only(left: 12,right: 2,top: 10,bottom: 10),
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: grey.withOpacity(0.8),width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(8))
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        const Text('Tới ngày: ',style:  TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,),
                        const SizedBox(width: 5,),
                        Text(Utils.parseStringDateToString(_bloc.dateTo.toString(), Const.DATE_TIME_FORMAT,Const.DATE_FORMAT_1),style: const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),
                      ],
                    ),
                    SizedBox(
                      width: 50,
                      child: InkWell(
                        onTap: (){
                          Utils.dateTimePickerCustom(context).then((value){
                            if(value != null){
                              setState(() {
                                _bloc.add(DateTo(value));
                              });
                            }
                          });
                        },
                        child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                      ),
                    ),
                  ]),
            ),
            const SizedBox(height: 25,),
            ///Button
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 90.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0), color: grey),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Huỷ',
                            style: TextStyle(
                              fontSize: 12,
                              color: white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print(_bloc.getStringFromDateYMD(_bloc.dateTo));
                     Navigator.pop(context,[statusType,_bloc.statusCode,'',_bloc.getStringFromDateYMD(_bloc.dateFrom),_bloc.getStringFromDateYMD(_bloc.dateTo),statusTypeName]);
                    },
                    child: Container(
                      width: 90.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0), color: orange),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Chọn',
                            style: TextStyle(
                              fontSize: 12,
                              color: white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  List<String> typeStatus = ['Chờ duyệt','Đã duyệt'];

  Widget genderType() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          icon: Icon(
            MdiIcons.sortVariant,
            size: 15,
            color: black,
          ),
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: statusTypeName,
          items: typeStatus.map((value) => DropdownMenuItem<String>(
            value: value,
            child: Align(
                alignment: Alignment.center,
                child: Text(value.toString(), style: TextStyle(fontSize: 13.0, color: blue.withOpacity(0.6)),)),
          )).toList(),
          onChanged: (value) {
            setState(() {
              statusTypeName = value!;
            });
            if(value == 'Chờ duyệt'){
              statusType = 1;
            }else if(value == 'Đã duyệt'){
              statusType = 2;
            }
          }),
    );
  }


  Widget genderStatus2() {
    return widget.listStatus?.isEmpty == true
        ? const Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12))
        : DropdownButtonHideUnderline(
          child: DropdownButton<ListStatusApprovalResponseData>(
          icon: Icon(
            MdiIcons.sortVariant,
            size: 15,
            color: black,
          ),
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: itemData,
          items: widget.listStatus?.map((value) => DropdownMenuItem<ListStatusApprovalResponseData>(
            value: value,
            child: Align(
                alignment: Alignment.center,
                child: Text(value.uStatusName.toString(), style: TextStyle(fontSize: 13.0, color: blue.withOpacity(0.6)),)),
          )).toList() ?? [],
          onChanged: (value) {
            setState(() {
              itemData = value;
            });
            _bloc.add(PickGenderStatus(statusCode:  int.parse(itemData!.uStatus.toString()),statusName: itemData?.uStatusName));
          }),
    );
  }
}
