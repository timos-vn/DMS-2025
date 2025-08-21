import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../themes/colors.dart';

class PopupEntity extends StatefulWidget {
  final String? title;
  final String? content;

  const PopupEntity({Key? key, this.title, this.content,}) : super(key: key);
  @override
  _RegisterUseComponentState createState() => _RegisterUseComponentState();
}

class _RegisterUseComponentState extends State<PopupEntity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
              height: 250,
              width: double.infinity,
              child: Material(
                  animationDuration: Duration(seconds: 3),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20,),
                        Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(40)),
                                color: subColor,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.shade200,
                                      offset: Offset(2, 4),
                                      blurRadius: 5,
                                      spreadRadius: 2)
                                ],),
                            child: Icon(MdiIcons.phone ,size: 50,color: Colors.white,)),
                        SizedBox(height: 15,),
                        Text(widget.title.toString(),style:  TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: subColor),),
                        SizedBox(height: 10,),
                        Text(widget.content.toString(),style:  TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),
                        SizedBox(height: 30,),
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
          InkWell(
            onTap: ()=>Navigator.pop(context),
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
              child: Text( 'Huỷ',
                style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 15,),
          GestureDetector(
            onTap: ()=>Navigator.pop(context,'CALL'),
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
              child: Text( 'Đồng ý',
                style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



