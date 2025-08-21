// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../themes/colors.dart';
import '../../utils/utils.dart';

class CustomCheckOutComponent extends StatefulWidget {
  final IconData? iconData;
  final String? title;
  final String? content;
  final bool showTwoButton;

  const CustomCheckOutComponent({Key? key,this.iconData, this.title, this.content,required this.showTwoButton}) : super(key: key);
  @override
  _CustomCheckOutComponentState createState() => _CustomCheckOutComponentState();
}

class _CustomCheckOutComponentState extends State<CustomCheckOutComponent> {

  final _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
              height: 270,
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
                        const SizedBox(height: 15,),
                        Text(widget.content.toString(),style: const TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),
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
                        const SizedBox(height: 15,),
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
      padding: const EdgeInsets.only(left: 0,right: 16),
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
              if(_noteController.text.isNotEmpty){
                Navigator.pop(context,['Yeah',_noteController.text]);
              }else{
                Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy điền nội dung công việc của bạn đi đã nào');
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



