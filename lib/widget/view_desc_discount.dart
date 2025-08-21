// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../../model/network/response/apply_discount_response.dart';
import '../../themes/colors.dart';

class CustomViewDiscountComponent extends StatefulWidget {
  final IconData? iconData;
  final String? title;
  final List<ListCkTongDon> listDiscountTotal;
  final List<ListCk> listDiscount;
  final String? maHangTangOld;
  final String? codeDiscountOld;
  final String? sttRecCKOld;


  const CustomViewDiscountComponent({Key? key,this.iconData, this.title,required this.listDiscountTotal,required this.listDiscount, this.maHangTangOld, this.codeDiscountOld, this.sttRecCKOld}) : super(key: key);
  @override
  _CustomViewDiscountComponentState createState() => _CustomViewDiscountComponentState();
}

class _CustomViewDiscountComponentState extends State<CustomViewDiscountComponent> {

  int indexOld = 0;
  String codeDiscountOld = '';
  String codeDiscountNew = '';
  String typeDiscount = '';
  ListCk? itemCKMatHangOld;
  ListCk? itemCKMatHangNew;

  String sttRecCKOld = '';
  String sttRecCKNew = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.listDiscount.isNotEmpty){
      List<ListCk> listItem = widget.listDiscount;
      for(int i = 0; i < listItem.length; i ++){
        listItem[i].isMark = 0 ;
        if(widget.codeDiscountOld.toString().trim() == listItem[i].maCk.toString().trim()){
          itemCKMatHangOld = listItem[i];
          codeDiscountOld = listItem[i].maCk.toString().trim();
          listItem[i].isMark = 1;
          indexOld = i;
        }
      }
    }
    if(widget.listDiscountTotal.isNotEmpty){
      List<ListCkTongDon> listItem = widget.listDiscountTotal;
      for(int i = 0; i < listItem.length; i ++){
        listItem[i].isMark = 0 ;
        if(widget.codeDiscountOld.toString().trim() == listItem[i].maCk.toString().trim()){
          // itemCKMatHangOld = listItem[i];
          codeDiscountOld = listItem[i].maCk.toString().trim();
          sttRecCKOld = listItem[i].sttRecCk.toString().trim();
          listItem[i].isMark = 1;
          indexOld = i;
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // ListGarageTimeResponseData valuesTime = ListGarageTimeResponseData();
    // List<ListGarageTimeResponseData> listValuesTime = [];
    // listValuesTime.addAll(_bloc.listGarageTimes);
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: const BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(16))),
              height: (widget.listDiscount.length > 2 || widget.listDiscountTotal.length > 2) ? 370 : 310,
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5,right: 5,top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(30)),
                              color:  const Color(0xFF0EBB00),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    offset: const Offset(2, 4),
                                    blurRadius: 5,
                                    spreadRadius: 2)
                              ],),
                            child: Icon(widget.iconData ,size: 16,color: Colors.white,)),
                        const SizedBox(height: 10,),
                        Text(widget.title.toString(),style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: subColor),textAlign: TextAlign.start,maxLines: 2,overflow: TextOverflow.ellipsis,),
                        const SizedBox(height: 5,),
                        const Text('Hãy lựa chọn CTKM dành cho sản phẩm của bạn',style: TextStyle(color: Colors.grey,fontSize: 10),textAlign: TextAlign.center,),
                        const SizedBox(height: 10,),
                        widget.listDiscountTotal.isNotEmpty ?
                        SizedBox(
                          height: widget.listDiscountTotal.length <= 2 ? 150 :200,
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              // physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.listDiscountTotal.length,
                              itemBuilder: (context,index){
                                return GestureDetector(
                                  onTap: (){
                                    // if(widget.listDiscountTotal[indexOld].isMark == 1){
                                    //   widget.listDiscountTotal[indexOld].isMark = 0;
                                    //   widget.listDiscountTotal[index].isMark = 1;
                                    // }else{
                                    //   widget.listDiscountTotal[index].isMark = 1;
                                    // }
                                    // indexOld = index;
                                    // //codeDiscountOld = widget.listDiscountTotal[indexOld].maCk.toString();
                                    // codeDiscountNew = widget.listDiscountTotal[index].maCk.toString();
                                    // setState(() {});
                                    if(widget.listDiscountTotal[indexOld].isMark == 1){
                                      widget.listDiscountTotal[indexOld].isMark = 0;
                                      widget.listDiscountTotal[index].isMark = 1;
                                    }else{
                                      widget.listDiscountTotal[index].isMark = 1;
                                    }
                                    indexOld = index;
                                    //codeDiscountOld = widget.listDiscount[indexOld].maCk.toString();
                                    codeDiscountNew = widget.listDiscountTotal[index].maCk.toString();
                                    sttRecCKNew = widget.listDiscountTotal[index].sttRecCk.toString();
                                    typeDiscount = widget.listDiscountTotal[index].kieuCK.toString();
                                    //itemCKMatHangOld = widget.listDiscount[indexOld];
                                    //itemCKMatHangNew = widget.listDiscountTotal[index];
                                    setState(() {});
                                  },
                                  child: Card(
                                    color: widget.listDiscountTotal[index].isMark == 0 ? Colors.white : subColor.withOpacity(0.1),
                                    semanticContainer: true,
                                    margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8,right: 6,top: 3,bottom: 3),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none, children: [
                                            Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: mainColor,
                                                  borderRadius:const BorderRadius.all(Radius.circular(6),)
                                              ),
                                              child: Center(child: Text('${widget.listDiscountTotal[index].maCk?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
                                            ),
                                          ],
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${widget.listDiscountTotal[index].maCk}',
                                                          textAlign: TextAlign.left,
                                                          style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Column(
                                                        children:  [
                                                          Text(
                                                            '${widget.listDiscountTotal[index].tlCkTt} %',
                                                            textAlign: TextAlign.left,
                                                            style:const TextStyle(color: grey, fontSize: 10, decoration:TextDecoration.none),
                                                          ),
                                                          const SizedBox(height: 3,),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Mã CK: ${widget.listDiscountTotal[index].maCk}',
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                            0xff358032)),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }

                          ),
                        )
                            :
                        SizedBox(
                          height: widget.listDiscount.length <= 2 ? 150 :200,
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              // physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.listDiscount.length,
                              itemBuilder: (context,index){
                                return GestureDetector(
                                  onTap: (){
                                    if(widget.listDiscount[indexOld].isMark == 1){
                                      widget.listDiscount[indexOld].isMark = 0;
                                      widget.listDiscount[index].isMark = 1;
                                    }else{
                                      widget.listDiscount[index].isMark = 1;
                                    }
                                    indexOld = index;
                                    //codeDiscountOld = widget.listDiscount[indexOld].maCk.toString();
                                    codeDiscountNew = widget.listDiscount[index].maCk.toString();
                                    typeDiscount = widget.listDiscount[index].kieuCk.toString();
                                    //itemCKMatHangOld = widget.listDiscount[indexOld];
                                    itemCKMatHangNew = widget.listDiscount[index];
                                    setState(() {});
                                  },
                                  child:
                                  widget.listDiscount[index].kieuCk == 'HH' ?
                                  Card(
                                    color: widget.listDiscount[index].isMark == 0 ? Colors.white : subColor.withOpacity(0.1),
                                    semanticContainer: true,
                                    margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8,right: 6,top: 3,bottom: 3),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none, children: [
                                            Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: mainColor,
                                                  borderRadius:const BorderRadius.all(Radius.circular(6),)
                                              ),
                                              child: Center(child: Text('${widget.listDiscount[index].tenCk?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
                                            ),
                                          ],
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${widget.listDiscount[index].tenCk}',
                                                          textAlign: TextAlign.left,
                                                          style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      const Column(
                                                        children: [
                                                          Text(
                                                            '0 đ',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: grey, fontSize: 10, decoration:TextDecoration.none),
                                                          ),
                                                          SizedBox(height: 3,),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Mã CK: ${widget.listDiscount[index].maCk}',
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                            0xff358032)),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'SL tặng:',
                                                            style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
                                                            textAlign: TextAlign.left,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text("${widget.listDiscount[index].soLuong?.toInt()??0} ${widget.listDiscount[index].dvt.toString().trim()}",
                                                            style: const TextStyle(color: blue, fontSize: 12),
                                                            textAlign: TextAlign.left,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                      :
                                  Card(
                                    color: widget.listDiscount[index].isMark == 0 ? Colors.white : subColor.withOpacity(0.1),
                                    semanticContainer: true,
                                    margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8,right: 6,top: 3,bottom: 3),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none, children: [
                                            Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: mainColor,
                                                  borderRadius:const BorderRadius.all(Radius.circular(6),)
                                              ),
                                              child: Center(child: Text('${widget.listDiscount[index].maCk?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
                                            ),
                                          ],
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${widget.listDiscount[index].maCk}',
                                                          textAlign: TextAlign.left,
                                                          style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      const Column(
                                                        children: [
                                                          Text(
                                                            '',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: grey, fontSize: 10, decoration:TextDecoration.none),
                                                          ),
                                                          SizedBox(height: 3,),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Discount: ${widget.listDiscount[index].tlCk} %',
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                            0xff358032)),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            '',
                                                            style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
                                                            textAlign: TextAlign.left,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          const Text('',
                                                            style: TextStyle(color: blue, fontSize: 12),
                                                            textAlign: TextAlign.left,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ) ,
                                );
                              }

                          ),
                        ),
                        const SizedBox(height: 10,),
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
      padding: const EdgeInsets.only(left: 16,right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
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
              if(codeDiscountNew.isNotEmpty){
                Navigator.pop(context,['Yeah',codeDiscountOld,codeDiscountNew,typeDiscount,itemCKMatHangNew,itemCKMatHangOld,sttRecCKOld, sttRecCKNew]);
              }else{
                Navigator.pop(context,'Cancel');
              }
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



