// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../../themes/colors.dart';
import '../../utils/utils.dart';

class InputQuantityPopupRefundOrder extends StatefulWidget {
  final double quantity;
  final String title;

  const InputQuantityPopupRefundOrder({super.key,required this.title,required this.quantity,});

  @override
  _InputQuantityPopupRefundOrderState createState() => _InputQuantityPopupRefundOrderState();
}

class _InputQuantityPopupRefundOrderState extends State<InputQuantityPopupRefundOrder> {

  late TextEditingController contentController;

  FocusNode focusNodeContent = FocusNode();

  double valueInput = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contentController =  TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
      body: buildBody(context),
    );
  }

  buildBody(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration:const BoxDecoration(color: Colors.white,),
          height: 200,
          width: double.infinity,
          child: Material(
              animationDuration:const Duration(seconds: 3),
              borderRadius:const BorderRadius.all(Radius.circular(16)),
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                        decoration:const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.title.isEmpty ? 'Vui lòng nhập số lượng' : widget.title.toString(),
                                    style:const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  InkWell(
                                    onTap: ()=> Navigator.pop(context,['0','Close']),
                                    child:const SizedBox( height: 35,width: 45, child:  Icon(Icons.clear,color: Colors.black,)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => FocusScope.of(context).requestFocus(focusNodeContent),
                                        child: Container(
                                          // height: 100,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                          ),
                                          child: TextField(
                                            maxLines: 1,
                                            autofocus: true,
                                            // obscureText: true,
                                            controller: contentController,
                                            decoration:  const InputDecoration(
                                              hintText: '0',
                                              hintStyle: TextStyle( color: Colors.grey),
                                            ),
                                            // focusNode: focusNodeContent,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(fontSize: 13),
                                            onChanged: (text){
                                              if(text != ''){
                                                valueInput = double.parse(text);
                                              }
                                            },
                                            //textInputAction: TextInputAction.none,
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              const SizedBox(height: 15,),
                            ],
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextButton(
                      onPressed: (){
                        if(valueInput > 0){
                          if(valueInput <= widget.quantity && valueInput !=0){
                            Navigator.pop(context,[valueInput]);
                          }
                          else{
                            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vượt quá số lượng hiện có rồi');
                          }
                        }
                        else{
                          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn không được để trống hoặc bằng 0');
                        }
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: subColor
                        ),
                        child:const Center(
                          child: Text(
                            'Xác nhận',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }
}
