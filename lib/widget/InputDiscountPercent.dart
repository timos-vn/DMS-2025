// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../themes/colors.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';

class InputDiscountPercent extends StatefulWidget {
  final double percent;
  final String typeValues;
  final String title;
  final String subTitle;
  const InputDiscountPercent({Key? key,required this.title,required this.subTitle,required this.typeValues,required this.percent, }) : super(key: key);

  @override
  _InputDiscountPercentState createState() => _InputDiscountPercentState();
}

class _InputDiscountPercentState extends State<InputDiscountPercent> {

  late TextEditingController contentController;

  FocusNode focusNodeContent = FocusNode();

  double valueInput = 0;

  static const _locale = 'en';
  String _formatNumber(String s) => NumberFormat.decimalPattern(_locale).format(int.parse(s));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contentController =  TextEditingController();
    if(widget.percent > 0){
      contentController.text = widget.percent.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration:const BoxDecoration(color: Colors.white,),
              height: 180,
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
                                        widget.subTitle.toString(),
                                        style:const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      InkWell(
                                        onTap: ()=> Navigator.pop(context,['Close','0']),
                                        child:const Icon(Icons.clear,color: Colors.black,),
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
                                                decoration: InputDecoration(
                                                  hintText: '0',
                                                  suffixText: widget.typeValues == 'vnd' ? 'Nghìn vnđ' : '%',
                                                  hintStyle: const TextStyle( color: Colors.grey,fontSize: 12,),
                                                ),
                                                // focusNode: focusNodeContent,
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(fontSize: 13),
                                                onChanged: (string){
                                                  if(string != '' ){
                                                    if(string.contains(',')){
                                                      valueInput = double.parse(string.replaceAll(',', ''));
                                                    }else{
                                                      valueInput = double.parse(string);
                                                    }
                                                    string = _formatNumber(string.replaceAll(',', ''));
                                                    contentController.value = TextEditingValue(
                                                      text: string,
                                                      selection: TextSelection.collapsed(offset: string.length),
                                                    );

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
                                ],
                              ),
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: TextButton(
                          onPressed: (){
                            if(valueInput > 0){
                              Navigator.pop(context,["BACK",valueInput]);
                            }
                            else{
                              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn không được để trống hoặc giá trị bằng 0');
                            }
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: subColor
                            ),
                            child: Center(
                              child: Text(
                                widget.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }
}
