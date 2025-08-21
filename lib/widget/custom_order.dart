import 'package:flutter/material.dart';

import '../../model/database/data_local.dart';
import '../../model/network/response/list_status_order_response.dart';
import '../../themes/colors.dart';

class CustomOrderComponent extends StatefulWidget {
  final IconData? iconData;
  final String? title;
  final String? content;

  const CustomOrderComponent({
    super.key,
    this.iconData,
    this.title,
    this.content,});
  @override
  _CustomOrderComponentState createState() => _CustomOrderComponentState();
}

class _CustomOrderComponentState extends State<CustomOrderComponent> {
  // bool lapCT = true;
  // bool choD = false;
  ListStatusOrderResponseData currentDecodingTypeName = ListStatusOrderResponseData();
  int idStatus = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(DataLocal.listStatusToOrderCustom.isNotEmpty){
      currentDecodingTypeName = DataLocal.listStatusToOrderCustom[0];
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
              height: DataLocal.listStatusToOrderCustom.isNotEmpty == true ? 270 : 240,
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius:const BorderRadius.all( Radius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10,),
                        Center(
                          child: Container(
                              padding:const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                borderRadius:const BorderRadius.all(Radius.circular(40)),
                                color: subColor,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.shade200,
                                      offset: const Offset(2, 4),
                                      blurRadius: 5,
                                      spreadRadius: 2)
                                ],),
                              child: Icon(widget.iconData ,size: 50,color: Colors.white,)),
                        ),
                        const SizedBox(height: 15,),
                        Center(child: Text(widget.title.toString(),style:  const TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: subColor),textAlign: TextAlign.center,)),
                        const SizedBox(height: 12,),
                        Text(widget.content.toString(),style: const TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),
                        // Container(
                        //   padding: const EdgeInsets.only(left: 10),
                        //   width: double.infinity,
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Expanded(
                        //         child: ElevatedButton(
                        //             style: ElevatedButton.styleFrom(
                        //                 primary: Colors.transparent,
                        //                 shadowColor: Colors.transparent),
                        //             onPressed: (){
                        //               setState(() {
                        //                 if(lapCT == true){
                        //                   lapCT = false;
                        //                   choD = true;
                        //                 }else{
                        //                   lapCT = true;
                        //                   choD = false;
                        //                 }
                        //               });
                        //             },
                        //             child: _buildCheckboxList('Lập CT',lapCT)),
                        //       ),
                        //       Expanded(
                        //         child: ElevatedButton(
                        //             style: ElevatedButton.styleFrom(
                        //                 primary: Colors.transparent,
                        //                 shadowColor: Colors.transparent),
                        //             onPressed: (){
                        //               setState(() {
                        //                 if(lapCT == true){
                        //                   lapCT = false;
                        //                   choD = true;
                        //                 }else{
                        //                   lapCT = true;
                        //                   choD = false;
                        //                 }
                        //               });
                        //             },
                        //             child: _buildCheckboxList('Chờ duyệt',choD)),
                        //       ),
                        //       const SizedBox(width: 0,height: 10,)
                        //     ],
                        //   ),
                        // ),
                        DataLocal.listStatusToOrderCustom.isNotEmpty == true ? Padding(
                          padding: const EdgeInsets.only(top: 7,bottom: 9),
                          child: Container(
                            height: 45,
                            margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: grey, width: 1)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Trạng thái đơn',
                                    style: TextStyle(fontSize: 13,color: accent)),
                                DropdownButton<ListStatusOrderResponseData>(
                                    value: currentDecodingTypeName,
                                    icon: const Icon(Icons.arrow_drop_down, color: subColor),
                                    iconSize: 24, elevation: 16,
                                    style: const TextStyle(color: Colors.black, fontSize: 13),
                                    underline: Container(
                                      height: 1,
                                      color: subColor,
                                    ),
                                    onChanged: (data) {
                                      if (data != null) {
                                        currentDecodingTypeName = data;
                                        idStatus = int.parse(
                                            currentDecodingTypeName.status.toString().trim().replaceAll('*', '').replaceAll('null', '').isNotEmpty ?
                                            currentDecodingTypeName.status.toString().trim().replaceAll('*', '').replaceAll('null', '') : '0'
                                        );
                                        setState(() {});
                                      }
                                    },
                                    items: DataLocal.listStatusToOrderCustom
                                        .map<DropdownMenuItem<ListStatusOrderResponseData>>(
                                            (e) => DropdownMenuItem<ListStatusOrderResponseData>(
                                          value: e,
                                          child: Text(
                                            e.statusname.toString().trim(),
                                            style: TextStyle(
                                                color: e.status == idStatus.toString()
                                                    ? subColor
                                                    : null),
                                          ),
                                        ))
                                        .toList()),
                              ],
                            ),
                          ),
                        ) : Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Container(),
                        ),
                        _submitButton2(context),
                      ],
                    ),
                  )),
            ),
          ),
        ));
  }

  Widget _submitButton2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12,right: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: ()=>Navigator.pop(context,'Cancel'),
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
            onTap: (){
              Navigator.pop(context,['Yeah',idStatus]);
            },
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
              child: const Text( 'Đồng ý' ,
                style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomOrderError extends StatefulWidget {
  final IconData? iconData;
  final String? title;
  final String? content;

  const CustomOrderError({
    Key? key,
    this.iconData,
    this.title,
    this.content,}) : super(key: key);
  @override
  _CustomOrderErrorState createState() => _CustomOrderErrorState();
}

class _CustomOrderErrorState extends State<CustomOrderError> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
              height: 300,
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius:const BorderRadius.all( Radius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10,),
                        Center(
                          child: Container(
                              padding:const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                borderRadius:const BorderRadius.all(Radius.circular(40)),
                                color: subColor,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.shade200,
                                      offset: const Offset(2, 4),
                                      blurRadius: 5,
                                      spreadRadius: 2)
                                ],),
                              child: Icon(widget.iconData ,size: 50,color: Colors.white,)),
                        ),
                        const SizedBox(height: 15,),
                        Center(child: Text(widget.title.toString(),style:  const TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: subColor),textAlign: TextAlign.center,)),
                        const SizedBox(height: 12,),
                        Expanded(
                          child: ListView(
                           children: [
                             Align( alignment: Alignment.center,
                               child: Text(
                                 widget.content.toString(),
                                 style: const TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),
                             ),
                           ],
                          ),
                        ),
                        const Divider(),
                        _submitButtonError(context),
                        const SizedBox(height: 12,),
                      ],
                    ),
                  )),
            ),
          ),
        ));
  }

  Widget _submitButtonError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12,right: 12,top: 16),
      child:  GestureDetector(
        onTap: (){
          Navigator.pop(context,);
        },
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
          child: const Text( 'Xác nhận' ,
            style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}



