import 'package:flutter/material.dart';

import '../../model/network/response/list_status_order_response.dart';
import '../../themes/colors.dart';

class ConfirmTypePayment extends StatefulWidget {
  final String? title;
  final String? content;
  final int? type;
  final  List<ListStatusOrderResponseData>? listStatus;

  const ConfirmTypePayment({Key? key, this.title, this.content, this.type, this.listStatus}) : super(key: key);
  @override
  _ConfirmSuccessPageState createState() => _ConfirmSuccessPageState();
}

class _ConfirmSuccessPageState extends State<ConfirmTypePayment> {
  TextEditingController contentController = TextEditingController();
  int groupValue = 0;
  FocusNode focusNodeContent = FocusNode();

  final List<String> codeStatusNames = [
    'Đã giao',
    'Thất bại',
    'Huỷ'
  ];
  final List<String> codeTypePayment = [
    'Công nợ',
    'Tiền mặt',
    'Chuyển khoản'
  ];

  String currentCodeTypePayment = 'Công nợ';
  ListStatusOrderResponseData currentCodecStatus = ListStatusOrderResponseData();
  int idTypePayment = 2;
  String idStatus = "";
  final _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.listStatus?.isNotEmpty == true){
      currentCodecStatus = widget.listStatus![0];
      idStatus = currentCodecStatus.status.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
              height:  widget.listStatus?.isNotEmpty == true
                  ?  350 : 300,
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius:const BorderRadius.all(Radius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5,),
                        Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(40)),
                              color: subColor,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    offset: const Offset(2, 4),
                                    blurRadius: 5,
                                    spreadRadius: 2)
                              ],),
                            child:const Icon(Icons.warning_amber_outlined ,size: 40,color: Colors.white,)),
                        const SizedBox(height: 15,),
                        Flexible(child: Text(widget.title.toString(),style:  const TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: subColor),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                        const SizedBox(height: 7,),
                        Container(
                          height: 45,
                          margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                          padding: const EdgeInsets.only(left: 8,right: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: grey, width: 1)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Loại thanh toán',
                                  style: TextStyle(fontSize: 13,color: accent)),
                              DropdownButton<String>(
                                  value: currentCodeTypePayment,
                                  icon: const Icon(Icons.arrow_drop_down, color: subColor),
                                  iconSize: 24, elevation: 16,
                                  style: const TextStyle(color: Colors.black, fontSize: 13),
                                  underline: Container(
                                    height: 1,
                                    color: subColor,
                                  ),
                                  onChanged: (data) {
                                    if (data != null) {
                                      currentCodeTypePayment = data;
                                      if(currentCodeTypePayment.contains('Công nợ')){
                                        idTypePayment = 2;
                                      }else if(currentCodeTypePayment.contains('Tiền mặt')){
                                        idTypePayment = 1;
                                      }else{
                                        idTypePayment = 3;
                                      }
                                      setState(() {});
                                    }
                                  },
                                  items: codeTypePayment
                                      .map<DropdownMenuItem<String>>(
                                          (e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: TextStyle(
                                              color: e == currentCodeTypePayment
                                                  ? subColor
                                                  : null),
                                        ),
                                      ))
                                      .toList()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12,),
                        widget.listStatus?.isNotEmpty == true
                            ?
                        Container(
                          height: 45,
                          margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                          padding: const EdgeInsets.only(left: 8,right: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: grey, width: 1)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Trạng thái phiếu',
                                  style: TextStyle(fontSize: 13,color: accent)),
                              DropdownButton<ListStatusOrderResponseData>(
                                  value: currentCodecStatus,
                                  icon: const Icon(Icons.arrow_drop_down, color: subColor),
                                  iconSize: 24, elevation: 16,
                                  style: const TextStyle(color: Colors.black, fontSize: 13),
                                  underline: Container(
                                    height: 1,
                                    color: subColor,
                                  ),
                                  onChanged: (data) {
                                    if (data != null) {
                                      currentCodecStatus = data;
                                      idStatus = currentCodecStatus.status.toString();
                                      setState(() {

                                      });
                                    }
                                  },
                                  items: widget.listStatus!
                                      .map<DropdownMenuItem<ListStatusOrderResponseData>>(
                                          (e) => DropdownMenuItem<ListStatusOrderResponseData>(
                                        value: e,
                                        child: Text(
                                          e.statusname.toString().trim(),
                                          style: TextStyle(
                                              color: e.status.toString().trim() == currentCodecStatus.status.toString().trim()
                                                  ? subColor
                                                  : null),
                                        ),
                                      ))
                                      .toList()),
                            ],
                          ),
                        )
                            :
                        Container(),
                        const SizedBox(height: 7,),
                        SizedBox(
                          height: 35,
                          width: double.infinity,
                          child:  TextField(
                            maxLines: 1,
                            controller: _noteController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(borderSide: BorderSide(color: grey, width: 1),),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: grey, width: 1),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: grey, width: 1),
                              ),
                              contentPadding: EdgeInsets.only(left: 8,bottom: 8),
                              hintText: 'Hãy ghi lại điều gì đó của bạn vào đây',
                              hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.grey,fontSize: 12,),
                            ),
                            focusNode: _noteFocus,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                            //textInputAction: TextInputAction.none,
                          ) ,
                        ),
                        const SizedBox(height: 22,),
                        _submitButton(context),
                      ],
                    ),
                  )),
            ),
          ),
        ));
  }
  Widget _submitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0,right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: ()=>Navigator.pop(context,['Cancel']),
            child: Container(
              width: 130,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                color: Colors.grey,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.shade200,
                      offset: const Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
              ),
              child: const Text( 'Huỷ',
                style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 15,),
          GestureDetector(
            onTap: ()=>Navigator.pop(context,['confirm',idStatus,idTypePayment,_noteController.text]),
            child: Container(
              width: 130,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
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
                      colors: [Color(0xfffbb448), Color(0xfff7892b)])),
              child: const Text( 'Xác nhận',
                style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget checkbox({String? title, bool? initValue, Function(bool boolValue)? onChanged}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Checkbox(value: initValue, onChanged: (b) => onChanged!(b!),activeColor: Colors.orange,),
          Text(title!),
        ]);
  }
}



