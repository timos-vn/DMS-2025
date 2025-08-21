import 'package:dms/screen/filter/filter_page.dart';
import 'package:dms/themes/colors.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputQuantityShipping extends StatefulWidget {
  final double? quantity;
  final String? title;
  final String? desc;
  final bool? isCreateItemHolder;
  const InputQuantityShipping({Key? key,this.quantity,this.title,this.desc,this.isCreateItemHolder}) : super(key: key);

  @override
  _InputQuantityShippingState createState() => _InputQuantityShippingState();
}

class _InputQuantityShippingState extends State<InputQuantityShipping> {

  TextEditingController contentController = TextEditingController();

  FocusNode focusNodeContent = FocusNode();
  String codeUnit = '';String nameUnit = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //contentController.text = widget.quantity.toString();
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
              decoration: const BoxDecoration(color: Colors.white,),
              height: widget.isCreateItemHolder == true ? 220 :160,
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                            height: 45,
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(color: Colors.transparent,
                                    height: 25,width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.title??'',
                                            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),
                                            maxLines: 1,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: ()=> Navigator.pop(context),
                                          child: const Icon(Icons.clear,color: Colors.black,),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    widget.desc??'',
                                    style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.normal),
                                  ),
                                  const SizedBox(height: 8,),
                                  Visibility(
                                    visible: widget.isCreateItemHolder == true,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10,bottom: 16),
                                      child: SizedBox(
                                        height: 25,
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Icon(FluentIcons.building_shop_16_filled),
                                            const SizedBox(width: 5,),
                                            Expanded(
                                              child: InkWell(
                                                onTap: (){
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) => const FilterScreen(controller: 'dmdvcs_lookup',
                                                        listItem: null,show: false,)).then((value){
                                                    if(value != null){
                                                      setState(() {
                                                        codeUnit = value[0];
                                                        nameUnit = value[1];
                                                      });
                                                    }
                                                  });
                                                },
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        nameUnit.isNotEmpty ? nameUnit : 'Vui lòng chọn đơn vị',
                                                        style: const TextStyle(color: Colors.blueGrey,fontSize: 12,fontWeight: FontWeight.normal),
                                                      ),
                                                    ),
                                                    const Icon(EneftyIcons.search_normal_outline,size: 15,color: accent,),
                                                    const SizedBox(width: 5,),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => FocusScope.of(context).requestFocus(focusNodeContent),
                                      child: Container(
                                        height: 25,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: TextField(
                                          maxLines: 1,
                                          autofocus: true,
                                          // obscureText: true,
                                          controller: contentController,
                                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                          ],
                                          decoration: const InputDecoration(
                                            border: UnderlineInputBorder(borderSide: BorderSide(color: subColor, width: 1),),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: subColor, width: 1),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: subColor, width: 1),
                                            ),
                                            contentPadding: EdgeInsets.only(top: 4,bottom: 4,right:30),
                                            isDense: true,
                                            focusColor: subColor,
                                            hintText: '0',
                                            hintStyle: TextStyle( color: Colors.grey),
                                          ),
                                          // focusNode: focusNodeContent,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(fontSize: 13),
                                          //textInputAction: TextInputAction.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: subColor,
                          ),
                          child: InkWell(
                            onTap: (){
                              Navigator.pop(context,[contentController.text,codeUnit,nameUnit]);
                            },
                            child: const Align(
                                alignment: Alignment.center,
                                child: Text('Xác nhận',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                    ],
                  )),
            ),
          ],
        ));
  }
}
