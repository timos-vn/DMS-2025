import 'package:dms/themes/colors.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpdateQuantityMaterials extends StatefulWidget {


  const UpdateQuantityMaterials({Key? key}) : super(key: key);

  @override
  _UpdateQuantityMaterialsState createState() => _UpdateQuantityMaterialsState();
}

class _UpdateQuantityMaterialsState extends State<UpdateQuantityMaterials> {

  TextEditingController sLTNController = TextEditingController();
  TextEditingController sLCLController = TextEditingController();

  FocusNode focusBarcode = FocusNode();
  FocusNode focusHSD = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // barcodeController.text = (widget.barcode.toString().isNotEmpty ? widget.barcode.toString() : null)!;
    // hsdController.text =(widget.hsd.toString().isNotEmpty ? widget.hsd.toString() : null)!;
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
              height: 200,
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Cập nhật số lượng cho BTP',
                                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      InkWell(
                                        onTap: ()=> Navigator.pop(context),
                                        child: const Icon(Icons.clear,color: Colors.black,),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8,),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => FocusScope.of(context).requestFocus(focusHSD),
                                      child: Container(
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: TextField(
                                          maxLines: 1,
                                          autofocus: true,
                                          // obscureText: true,
                                          controller: sLTNController,
                                          decoration: const InputDecoration(
                                            border: UnderlineInputBorder(borderSide: BorderSide(color: subColor, width: 1),),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: subColor, width: 1),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: subColor, width: 1),
                                            ),
                                            suffixIcon: Padding(
                                              padding: EdgeInsets.only(right: 8),
                                              child: Icon(EneftyIcons.edit_2_outline,size: 15,),
                                            ),
                                            suffixIconConstraints: BoxConstraints(maxWidth: 20),
                                            contentPadding: EdgeInsets.only(
                                                bottom: 0, right: 20,left: 0),
                                            isDense: false,
                                            focusColor: subColor,
                                            hintText: 'Vui lòng nhập số lượng đã tiếp nhận',
                                            hintStyle: TextStyle( color: Colors.grey),
                                          ),
                                          // focusNode: focusNodeContent,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(fontSize: 13),
                                          //textInputAction: TextInputAction.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => FocusScope.of(context).requestFocus(focusBarcode),
                                      child: Container(
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: TextField(
                                          maxLines: 1,
                                          autofocus: false,
                                          // obscureText: true,
                                          controller: sLCLController,
                                          decoration: const InputDecoration(
                                            border: UnderlineInputBorder(borderSide: BorderSide(color: subColor, width: 1),),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: subColor, width: 1),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: subColor, width: 1),
                                            ),
                                            isDense: false,
                                            suffixIcon: Padding(
                                              padding: EdgeInsets.only(right: 8),
                                              child: Icon(EneftyIcons.edit_2_outline,size: 15,),
                                            ),
                                            suffixIconConstraints: BoxConstraints(maxWidth: 20),
                                            contentPadding: EdgeInsets.only(
                                                bottom: 0, right: 20,left: 0),
                                            focusColor: subColor,
                                            hintText: 'Vui lòng nhập số lượng còn lại',
                                            hintStyle: TextStyle( color: Colors.grey),
                                          ),
                                          // focusNode: focusNodeContent,
                                          keyboardType: TextInputType.number,
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
                        padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10,top: 10),
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: subColor,
                          ),
                          child: InkWell(
                            onTap: (){
                              Navigator.pop(context,[sLTNController.text,sLCLController.text]);
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
