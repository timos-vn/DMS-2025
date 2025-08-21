// ignore_for_file: library_private_types_in_public_api

// import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms/widget/text_field_widget.dart';
import 'package:dms/widget/text_field_widget2.dart';
import 'package:flutter/material.dart';
import 'package:dms/model/network/response/report_field_lookup_response.dart';
import 'package:dms/model/network/response/report_layout_response.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../report/result_report/result_report_screen.dart';
import 'option_report_filter.dart';

class ValueReportFilter extends StatefulWidget {
  final List<DataReportLayout> listRPLayout;
  final String idReport;
  final String title;
  final bool? isBack;

  const ValueReportFilter({Key? key, required this.listRPLayout,required this.idReport,required this.title, this.isBack}) : super(key: key);
  @override
  _ValueReportFilterState createState() => _ValueReportFilterState();
}

class _ValueReportFilterState extends State<ValueReportFilter> {
  final TextEditingController dateFrom = TextEditingController();
  final TextEditingController dateTo = TextEditingController();
  final TextEditingController dateOther = TextEditingController();
  final TextEditingController type4 = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: buildBody(context),
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
                offset:const  Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient:const  LinearGradient(
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
            child:const  SizedBox(
              width: 40,
              height: 50,
              child:Icon(
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
                style:const  TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          const SizedBox(
            height: 50,
            child: Icon(
              Icons.filter_alt_outlined,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  buildBody(BuildContext context){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child:widget.listRPLayout.isEmpty
                ? const Center(
              child:Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),)
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (BuildContext context, int index) {
                  ///Text
                  if (int.parse(widget.listRPLayout[index].type.toString()) == 1) {
                    //if(widget.listRPLayout[index].field == 'so_ct1'){
                    return textInput(context, index);
                    // }
                  }
                  ///Numeric
                  else if (int.parse(widget.listRPLayout[index].type.toString()) == 2) {
                    return numberInput(context,index);
                  }
                  ///Datetime
                  else if (int.parse(widget.listRPLayout[index].type.toString()) == 3) {
                    if (widget.listRPLayout[index].field == 'DateFrom') {
                      return dateTimeFrom(context,index);
                    }
                    if (widget.listRPLayout[index].field == 'DateTo') {
                      return dateTimeTo(context,index);
                    }
                    if(widget.listRPLayout[index].field != 'DateFrom' && widget.listRPLayout[index].field != 'DateTo'){
                      return dateTimeOther(context,index);
                    }
                  }
                  ///AutoComplete
                  else if (int.parse(widget.listRPLayout[index].type.toString()) == 4) {
                    return filterAutoComplete(context, index);
                  }
                  ///Lookup
                  else if (int.parse(widget.listRPLayout[index].type.toString()) == 5) {
                    return filterLookup(context, index);
                  }
                  ///Checkbox
                  else if (int.parse(widget.listRPLayout[index].type.toString()) == 6) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            if(widget.listRPLayout[index].c == true){
                              widget.listRPLayout[index].c = false;
                              widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: '0', name: '0',);
                            }else {
                              widget.listRPLayout[index].c = true;
                              widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: '1', name: '1',);
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: widget.listRPLayout[index].defaultValue != null
                                  ? (widget.listRPLayout[index].defaultValue?.trim() == '0' ? false : true)
                                  : widget.listRPLayout[index].c,
                              onChanged: (bool? newValue) {
                                setState(() {//0 - false
                                  if(widget.listRPLayout[index].c == true){
                                    widget.listRPLayout[index].c = false;
                                    widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: '0', name: '0',);
                                  }else{
                                    widget.listRPLayout[index].c = true;
                                    widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: '1', name: '1',);
                                  }
                                });
                              },
                            ),
                            Row(
                              children: [
                                Text(widget.listRPLayout[index].name.toString().trim(),style: TextStyle(fontSize: 12,color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey),),
                                const SizedBox(width: 4,),
                                Visibility(
                                    visible: widget.listRPLayout[index].isNull == false ,
                                    child:const  Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  ///DropDown
                  else if (int.parse(widget.listRPLayout[index].type.toString()) == 7) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Column(
                        children: [
                          Visibility(
                            visible: widget.listRPLayout[index].selectValue != null || widget.listRPLayout[index].defaultValue != null,
                            child: Row(
                              children: [
                                Text('${widget.listRPLayout[index].name}',style: TextStyle(color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey,fontSize: 11),),
                                const SizedBox(width: 4,),
                                Visibility(
                                    visible: widget.listRPLayout[index].isNull == false ,
                                    child:const  Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: double.infinity,
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                // alignedDropdown: true,
                                child: DropdownButton<String>(
                                  underline: Container(color:Colors.red, height:10.0),
                                  value:  widget.listRPLayout[index].selectValue != null ? widget.listRPLayout[index].selectValue?.code
                                      // ignore: prefer_null_aware_operators
                                      :(widget.listRPLayout[index].defaultValue != null? widget.listRPLayout[index].defaultValue?.trim() : null ),
                                  iconSize: 25,
                                  icon: (null),
                                  style:const  TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                  hint:  Text(
                                    widget.listRPLayout[index].name.toString().trim() +
                                        (widget.listRPLayout[index].isNull == false? ' *' : ''),
                                    style: TextStyle(color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey,fontSize: 11),),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: newValue, name: newValue,);
                                      widget.listRPLayout[index].c  = true;
                                    });
                                  },
                                  items: widget.listRPLayout[index].dropDownList?.map((item) {
                                    return DropdownMenuItem(
                                      value: item.value.toString().trim(),
                                      child: Text(
                                        item.text.toString().trim(),
                                        style:const  TextStyle(fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                    );
                                  }).toList() ?? [],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 0,),
                          Container(color:Colors.grey, height:1.0)
                        ],
                      ),
                    );
                  }
                  return Container();
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Container(),
                itemCount: widget.listRPLayout.length),
          ),
          widget.listRPLayout.isEmpty ? Container() : button(context),
        ],
      ),
    );
  }

  dateTimeOther(BuildContext context,int index){
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: SizedBox(
        height: 55,
        child: Column(
          children: [
            Row(
              children: [
                Text(widget.listRPLayout[index].name?.trim()??'',
                    style: TextStyle(fontSize: 11, color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey)),
                const SizedBox(width: 4,),
                Visibility(
                    visible: widget.listRPLayout[index].isNull == false ,
                    child: const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
              ],
            ),
            const SizedBox(height: 5,),
            Expanded(
              child: Container(
                padding:const EdgeInsets.only(left: 12,right: 2,top: 10,bottom: 10),
                height: 55,
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
                          Text('Báo cáo ${widget.listRPLayout[index].name?.trim()??''}: ',style:  const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,),
                          const SizedBox(width: 5,),
                          Text(dateOther.text.toString(),style: const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      SizedBox(
                        width: 50,
                        child: InkWell(
                          onTap: (){
                            Utils.dateTimePickerCustom(context).then((value){
                              if(value != null){
                                setState(() {
                                  widget.listRPLayout[index].textEditingController = TextEditingController();
                                  widget.listRPLayout[index].textEditingController.text = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                  dateOther.text = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                  widget.listRPLayout[index].selectValue = ReportFieldLookupResponseData(
                                    code: widget.listRPLayout[index].textEditingController.text,
                                    name: widget.listRPLayout[index].textEditingController.text,
                                  );
                                  widget.listRPLayout[index].c  = true;
                                });
                              }
                            });
                          },
                          child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dateTimeFrom(BuildContext context,int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: SizedBox(
        height: 55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Từ ngày',
                    style: TextStyle(fontSize: 11, color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey)),
                const SizedBox(width: 4,),
                Visibility(
                    visible: widget.listRPLayout[index].isNull == false ,
                    child: const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
              ],
            ),
            const SizedBox(height: 5,),
            Expanded(
              child: Container(
                padding:const EdgeInsets.only(left: 12,right: 2,top: 10,bottom: 10),
                height: 55,
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
                          Text('${widget.isBack != true ? 'Báo cáo từ ngày:' : '' } ',style:  TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,),
                          const SizedBox(width: 5,),
                          Text(dateFrom.text.toString(),style: const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      SizedBox(
                        width: 50,
                        child: InkWell(
                          onTap: (){
                            Utils.dateTimePickerCustom(context).then((value){
                              if(value != null){
                                setState(() {
                                  dateFrom.text = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                  widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: dateFrom.text, name: dateFrom.text,);
                                  widget.listRPLayout[index].c  = true;
                                });
                              }
                            });
                          },
                          child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dateTimeTo(BuildContext context,int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 25,bottom: 10),
      child: SizedBox(
        height: 55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Tới ngày',
                    style: TextStyle(fontSize: 11, color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey)),
                const SizedBox(width: 4,),
                Visibility(
                    visible: widget.listRPLayout[index].isNull == false ,
                    child: const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
              ],
            ),
            const SizedBox(height: 5,),
            Expanded(
              child: Container(
                padding:const EdgeInsets.only(left: 12,right: 2,top: 10,bottom: 10),
                height: 55,
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
                          Text('${widget.isBack != true ? 'Báo cáo tới ngày:' : ''} ',style:  TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,),
                          const SizedBox(width: 5,),
                          Text(dateTo.text.toString(),style: const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      SizedBox(
                        width: 50,
                        child: InkWell(
                          onTap: (){
                            Utils.dateTimePickerCustom(context).then((value){
                              if(value != null){
                                setState(() {
                                  dateTo.text = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                  widget.listRPLayout[index].selectValue = ReportFieldLookupResponseData(code: dateTo.text, name: dateTo.text,);
                                  widget.listRPLayout[index].c  = true;
                                });
                              }
                            });
                          },
                          child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterLookup(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: SizedBox(
        height: 50,
        child: Column(
          children: [
            Visibility(
              visible: widget.listRPLayout[index].selectValue != null ||
              widget.listRPLayout[index].defaultValue != null,
              child: Row(
                children: [
                  Text('${widget.listRPLayout[index].name}',style: TextStyle(color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey,fontSize: 11),),
                  const SizedBox(width: 4,),
                  Visibility(
                      visible: widget.listRPLayout[index].isNull == false ,
                      child: const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
                ],
              ),
            ),
            Stack(
              children: [
                TextFieldWidget2(
                  isEnable: true,
                  textInputAction: TextInputAction.done,
                  controller: TextEditingController(),
                  isNull : widget.listRPLayout[index].isNull ,
                  color: widget.listRPLayout[index].selectValue != null ? black : Colors.grey,
                  onChanged: (text){
                    widget.listRPLayout[index].listItemPush = text;
                  },
                  labelText: widget.listRPLayout[index].selectValue != null ? null
                      : (
                      widget.listRPLayout[index].defaultValue ?? widget.listRPLayout[index].name),

                ),
                Positioned(
                    top: 0,right: 0,bottom: 1,
                    child: Container(
                      height: 50,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8)
                      ),
                      child: InkWell(
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (context) => OptionReportFilter(controller: widget.listRPLayout[index].controller!,
                                  listItem: widget.listRPLayout[index].listItemPush != null
                                      ?
                                  widget.listRPLayout[index].listItemPush.toString() : '',show: true,)).then((value) {//listItem: widget.listRPLayout[index].selectValue.code
                              if (!Utils.isEmpty(value)) {
                                setState(() {
                                  List<String> geek = <String>[];
                                  widget.listRPLayout[index].listItem = value;
                                  widget.listRPLayout[index].listItem?.forEach((element) {
                                    ///sau co sửa code hay name thì tuỳ
                                    geek.add(element.code.toString());
                                  });
                                  String geek2 = geek.join(",");
                                  widget.listRPLayout[index].textEditingController = TextEditingController();
                                  widget.listRPLayout[index].textEditingController.text = geek2;
                                  widget.listRPLayout[index].listItemPush = geek2;
                                  widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: geek2, name: '',);
                                  // widget.listRPLayout[index].listItem = value;
                                  widget.listRPLayout[index].c = true;
                                  print('valueSelect = ${widget.listRPLayout[index].selectValue?.name}');
                                });
                              }
                            });
                          },
                          child: const Icon(Icons.search)),
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget filterAutoComplete(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: widget.listRPLayout[index].selectValue != null || widget.listRPLayout[index].defaultValue != null,
              child: Row(
                children: [
                  Text('${widget.listRPLayout[index].name}',style: TextStyle(color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey,fontSize: 11),),
                  const SizedBox(width: 4,),
                  Visibility(
                      visible: widget.listRPLayout[index].isNull == false ,
                      child:const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
                ],
              ),
            ),
            Stack(
              children: [
                TextFieldWidget2(
                  maxLine: 1,
                  isEnable: true,
                  textInputAction: TextInputAction.done,
                  isNull : widget.listRPLayout[index].isNull ,
                  color: widget.listRPLayout[index].selectValue != null ? black : Colors.grey,
                  controller: widget.listRPLayout[index].textEditingController,
                  onChanged: (text){
                    widget.listRPLayout[index].textEditingController = TextEditingController();
                    widget.listRPLayout[index].textEditingController.text = text!;
                  },
                  labelText: widget.listRPLayout[index].selectValue != null ?
                  null
                      : (widget.listRPLayout[index].defaultValue ?? widget.listRPLayout[index].name),
                ),
                Positioned(
                    top: 0,right: 0,bottom: 1,
                    child: Container(
                      height: 50,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8)
                      ),
                      child: InkWell(
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (context) => OptionReportFilter(controller: widget.listRPLayout[index].controller!,show: false, listItem: '',)).then((value) {
                              if (value != null) {
                                setState(() {
                                  widget.listRPLayout[index].textEditingController = TextEditingController();
                                  widget.listRPLayout[index].textEditingController.text =  '${value[0].toString().trim()} ( ${value[1].toString().trim()} )';
                                  widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: value[0].toString(), name: value[1].toString(),);
                                  widget.listRPLayout[index].c = true;
                                });
                              }
                            });
                          },
                          child:const Icon(Icons.search,size: 18,)),
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget textInput(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Container(
        color: Colors.transparent,
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: widget.listRPLayout[index].selectValue != null || widget.listRPLayout[index].defaultValue != null,
              child: Row(
                children: [
                  Text('${widget.listRPLayout[index].name}',style: TextStyle(color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey,fontSize: 13),),
                  const SizedBox(width: 4,),
                  Visibility(
                      visible: widget.listRPLayout[index].isNull == false ,
                      child: const Text('*',style: TextStyle(fontSize: 12,color: Colors.red),)),
                ],
              ),
            ),
            Stack(
              children: [
                TextFieldWidget2(
                  isEnable: true,
                  controller: TextEditingController(),
                  isNull : widget.listRPLayout[index].isNull ,
                  color: widget.listRPLayout[index].selectValue != null ? black : (widget.listRPLayout[index].defaultValue != null ? Colors.grey : Colors.black) ,//,
                  hintText: (widget.listRPLayout[index].defaultValue ?? widget.listRPLayout[index].name),
                  onChanged: (text){
                    widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: text, name: text,);
                    widget.listRPLayout[index].c = true;
                  },
                ),
                const Positioned(
                    top: 0,right: 0,bottom: 0,
                    child: SizedBox(
                      height: 50,
                      width: 40,
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget numberInput(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 45,
        child: Column(
          children: [
            Visibility(
              visible: widget.listRPLayout[index].selectValue != null || widget.listRPLayout[index].defaultValue != null,
              child: Row(
                children: [
                  Text('${widget.listRPLayout[index].name}',style: TextStyle(color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey,fontSize: 13),),
                  const SizedBox(width: 4,),
                  Visibility(
                      visible: widget.listRPLayout[index].isNull == false ,
                      child: const Text('*',style: TextStyle(fontSize: 12,color: Colors.red),)),
                ],
              ),
            ),
            Stack(
              children: [
                TextFieldWidget2(
                  isEnable: true,
                  controller: TextEditingController(),
                  isNull : widget.listRPLayout[index].isNull ,
                  color: widget.listRPLayout[index].selectValue != null ? black : widget.listRPLayout[index].defaultValue != null ? Colors.grey : Colors.black ,
                  hintText: (widget.listRPLayout[index].defaultValue ?? widget.listRPLayout[index].name),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  inputFormatter: [Const.FORMAT_DECIMA_NUMBER],
                  onChanged: (text){
                    widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: text, name: text,);
                    widget.listRPLayout[index].c = true;
                  },
                ),
                const Positioned(
                    top: 0,right: 0,bottom: 0,
                    child: SizedBox(
                      height: 50,
                      width: 40,
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget textInput2(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: SizedBox(
        height: 40,
        width: double.infinity,
        child: Column(
          children: [
            Visibility(
              visible: widget.listRPLayout[index].selectValue != null,
              child: Row(
                children: [
                  Text('${widget.listRPLayout[index].name}',style: TextStyle(color: widget.listRPLayout[index].isNull == false? Colors.red : Colors.grey,fontSize: 11),),
                  const SizedBox(width: 4,),
                  Visibility(
                      visible: widget.listRPLayout[index].isNull == false ,
                      child: const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
                ],
              ),
            ),
            Stack(
              children: [
                TextFieldWidget2(
                  controller: TextEditingController(),
                  //errorText: (widget.listRPLayout[index].c  == true ? null : 'Không được để trống'),
                  isEnable: true,
                  hintText: widget.listRPLayout[index].name! + (widget.listRPLayout[index].isNull == false? '  *' : ''),
                  isNull : widget.listRPLayout[index].isNull ,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  onChanged: (text){
                    widget.listRPLayout[index].selectValue = ReportFieldLookupResponseData(code: text.toString(), name: text.toString(),);
                    widget.listRPLayout[index].c = true;
                  },
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget numberInput2(BuildContext context, String hintTitle,int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 40,
        child: TextFieldWidget(
          readOnly: false,
          controller: TextEditingController(),
          errorText: widget.listRPLayout[index].isNull == false? (widget.listRPLayout[index].selectValue != null ? '' : 'Úi, Không có gì ở đây cả!!!') : null,
          hintText: hintTitle,
          isEnable: true,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.phone,
          inputFormatters: [Const.FORMAT_DECIMA_NUMBER],
          onChanged: (text){
            widget.listRPLayout[index].selectValue =  ReportFieldLookupResponseData(code: text.toString(), name: text.toString(),);
            widget.listRPLayout[index].c = true;
          },
        ),
      ),
    );
  }

  Widget button(BuildContext context) {
    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0), color: grey
                  ),
                  child: const Center(
                    child: Text(
                      'Huỷ',
                      style: TextStyle(
                        fontSize: 13,
                        color: white,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8,),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if(widget.isBack != true){
                    List list = [];
                    bool isEmpty = true;
                    for(int i = 0; i <= widget.listRPLayout.length-1; i++){
                      list.add(ReportResultResponseData(
                          field: widget.listRPLayout[i].field,
                          value: widget.listRPLayout[i].selectValue != null
                              ? widget.listRPLayout[i].selectValue?.code : (widget.listRPLayout[i].defaultValue ?? '')));
                      if(widget.listRPLayout[i].defaultValue != null){
                        widget.listRPLayout[i].isNull = true;
                      }
                      if(widget.listRPLayout[i].c == false && widget.listRPLayout[i].isNull == false){
                        isEmpty = false;
                      }
                    }
                    if(isEmpty == true){
                      if(!Utils.isEmpty(widget.idReport)){
                        ///ResultReportPage
                        PersistentNavBarNavigator.pushNewScreen(context, screen: ResultReportScreen(
                          idReport: widget.idReport,listRequestValue: list,title: widget.title,
                        ),withNavBar: false);
                      }else{
                        widget.listRPLayout.clear();
                        Navigator.pop(context,[list]);
                      }
                    }
                    else{
                      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn đang nhập thiếu thông tin kìa!');
                    }
                  }
                  else{
                    final generatedList = [];


                    bool isEmpty = true;
                    for(int i = 0; i <= widget.listRPLayout.length-1; i++){
                      generatedList.add({
                        "variable": widget.listRPLayout[i].field,
                        "type": "Text",
                        "value": widget.listRPLayout[i].selectValue != null
                            ? widget.listRPLayout[i].selectValue?.code : (widget.listRPLayout[i].defaultValue ?? ''),
                      });
                      if(widget.listRPLayout[i].defaultValue != null){
                        widget.listRPLayout[i].isNull = true;
                      }
                      if(widget.listRPLayout[i].c == false && widget.listRPLayout[i].isNull == false){
                        isEmpty = false;
                      }
                    }
                    if(isEmpty == true){
                      Navigator.pop(context,[generatedList]);
                    }
                    else{
                      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn đang nhập thiếu thông tin kìa!');
                    }
                  }
                },
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0), color: orange),
                  child: Center(
                    child: Text(
                      Utils.isEmpty(widget.idReport) ? 'Lọc' :
                      'Tiếp tục',
                      style: const TextStyle(
                        fontSize: 13,
                        color: white,
                          fontWeight: FontWeight.bold
                      ),
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
}
