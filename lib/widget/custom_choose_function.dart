import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class CustomChooseFunction extends StatefulWidget {
  final String? title;
  final String? content;
  final String keyFnc;

  const CustomChooseFunction({Key? key, this.title, this.content, required this.keyFnc,}) : super(key: key);
  @override
  _CustomChooseFunctionState createState() => _CustomChooseFunctionState();
}

class _CustomChooseFunctionState extends State<CustomChooseFunction> {
  TextEditingController contentController = TextEditingController();
  FocusNode focusNodeContent = FocusNode();

  List<String> listFunction = ['Tạo phiếu giao hàng','Phiếu nhập kho'];
  String function = 'Tạo phiếu giao hàng';
  String keyFunction = '#6';

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
                              child: const Icon(Icons.warning_amber ,size: 50,color: Colors.white,)),
                        ),
                        const SizedBox(height: 15,),
                        Center(child: Text(widget.title.toString(),style:  const TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: subColor),textAlign: TextAlign.center,)),
                        const SizedBox(height: 12,),
                        Text(widget.content.toString(),style: const TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),

                        Padding(
                          padding: const EdgeInsets.only(top: 7,bottom: 9),
                          child: Container(
                            height: 45,
                            margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: grey, width: 1)),
                            child: widget.keyFnc == '#9'
                                ?
                                const Center(child: Text('Tạo phiếu giao hàng'))
                                :
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Chọn chức năng',
                                    style: TextStyle(fontSize: 13,color: accent)),
                                DropdownButton<String>(
                                    value: function,
                                    icon: const Icon(Icons.arrow_drop_down, color: subColor),
                                    iconSize: 24, elevation: 16,
                                    style: const TextStyle(color: Colors.black, fontSize: 13),
                                    underline: Container(
                                      height: 1,
                                      color: subColor,
                                    ),
                                    onChanged: (data) {
                                      if (data != null) {
                                        function = data;
                                        if(function.contains('Tạo phiếu giao hàng')){
                                          keyFunction = '#6';
                                        }else{
                                          keyFunction = '#4';
                                        }
                                        setState(() {});
                                      }
                                    },
                                    items: listFunction
                                        .map<DropdownMenuItem<String>>(
                                            (e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(
                                            e.toString().trim(),
                                            style: TextStyle(
                                                color: e.contains(function)
                                                    ? subColor
                                                    : null),
                                          ),
                                        ))
                                        .toList()),
                              ],
                            ),
                          ),
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
              Navigator.pop(context,['Yeah',keyFunction]);
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