import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class CustomUpgradeComponent extends StatefulWidget {
  final IconData? iconData;
  final String? title;
  final String? content;
  final bool showTwoButton;

  const CustomUpgradeComponent({Key? key,this.iconData, this.title, this.content,required this.showTwoButton}) : super(key: key);
  @override
  _CustomUpgradeComponentState createState() => _CustomUpgradeComponentState();
}

class _CustomUpgradeComponentState extends State<CustomUpgradeComponent> {
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
                    padding: const EdgeInsets.only(left: 12,right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10,),
                        Center(
                          child: Container(
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
                              child: Icon(widget.iconData ,size: 50,color: Colors.white,)),
                        ),
                        SizedBox(height: 15,),
                        Center(child: Text(widget.title.toString(),style:  TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: subColor),textAlign: TextAlign.center,)),
                        SizedBox(height: 10,),
                        Text(widget.content.toString(),style:  TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),
                        SizedBox(height: 25,),
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
      padding: const EdgeInsets.only(left: 0,right: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: ()=>Navigator.pop(context,'cancel'),
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
              child: Text( 'Cancel',
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
              child: Text( 'Upgrade',
                style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



