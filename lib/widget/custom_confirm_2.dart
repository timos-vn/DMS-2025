// ignore_for_file: library_private_types_in_public_api

// import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

import '../../themes/colors.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';


class CustomConfirm2 extends StatefulWidget {
  final String? title;
  final String? content;

  const CustomConfirm2({Key? key, this.title, this.content}) : super(key: key);
  @override
  _CustomConfirmState createState() => _CustomConfirmState();
}

class _CustomConfirmState extends State<CustomConfirm2> {
  int groupValue = 0;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
              height: 250,
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius:const BorderRadius.all(Radius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 15,),
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
                            child:const Icon(Icons.warning_amber_outlined ,size: 50,color: Colors.white,)),
                        const SizedBox(height: 20,),
                        Flexible(child: Text(widget.title.toString(),style:  const TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: subColor),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                        const SizedBox(height: 40,),
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
            onTap: ()=>Navigator.pop(context,['Back']),
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
              // print(Utils.parseStringToDate('2022-12-12', Const.DATE_SV_FORMAT));
              Navigator.pop(context,['confirm']);
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
              child: const Text( 'Xác nhận',
                style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



