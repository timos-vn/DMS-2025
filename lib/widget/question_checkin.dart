// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../themes/colors.dart';

class CustomQuestionCheckInComponent extends StatefulWidget {
  final IconData? iconData;
  final String? title;
  final String? content;
  final bool showTwoButton;
  final String? nameButtonOne;
  final String? nameButtonTwo;

  const CustomQuestionCheckInComponent({Key? key,this.iconData, this.title, this.content,required this.showTwoButton,this.nameButtonOne, this.nameButtonTwo}) : super(key: key);
  @override
  _CustomQuestionCheckInComponentState createState() => _CustomQuestionCheckInComponentState();
}

class _CustomQuestionCheckInComponentState extends State<CustomQuestionCheckInComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
              height: widget.nameButtonOne != '' ? 270 :250,
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16,right: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10,),
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
                            child: Icon(widget.iconData ,size: 50,color: Colors.white,)),
                        const SizedBox(height: 10,),
                        Flexible(child: Text(widget.title.toString(),style:  TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: subColor),textAlign: TextAlign.start,maxLines: 2,overflow: TextOverflow.ellipsis,)),
                        const SizedBox(height: 10,),
                        Text(widget.content.toString(),style:  const TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),
                        const SizedBox(height: 25,),
                        widget.showTwoButton == false ?
                        _submitButton(context) : _submitButton2(context),
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
            onTap: ()=>Navigator.pop(context,'Yeah'),
            child: Container(
              width: 130,
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xfffbb448), Color(0xfff7892b)])),
              child: Text('Đồng ý',
                style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0,right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: ()=>Navigator.pop(context,'View'),
            child: Container(
              width: 130,
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: Colors.grey,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.shade200,
                      offset: Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
              ),
              child: Text( '${widget.nameButtonOne != '' ? widget.nameButtonOne : 'Huỷ'}',
                style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 15,),
          GestureDetector(
            onTap: ()=>Navigator.pop(context,'Yeah'),
            child: Container(
              width: 130,
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xfffbb448), Color(0xfff7892b)])),
              child: Text( '${widget.nameButtonTwo != '' ? widget.nameButtonTwo : 'Đồng ý'}' ,
                style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



