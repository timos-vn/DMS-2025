import 'package:dms/screen/filter/filter_page.dart';
import 'package:dms/themes/colors.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as dateFormating;

class UpdateQuantitySemi extends StatefulWidget {
  final String codeWorker;final String nameWorker;
  final String codeGWorker;final String nameGWorker ;final String quantity ;

  const UpdateQuantitySemi({super.key, required this.codeWorker, required this.nameWorker, required this.codeGWorker, required this.nameGWorker, required this.quantity});


  @override
  _UpdateQuantitySemiState createState() => _UpdateQuantitySemiState();
}

class _UpdateQuantitySemiState extends State<UpdateQuantitySemi> {

  TextEditingController soLuongController = TextEditingController();

  FocusNode focusSoLuong = FocusNode();
  String codeWorker = '';String nameWorker = '';
  String codeGWorker = '';String nameGWorker = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    codeWorker = widget.codeWorker;
    codeGWorker = widget.codeGWorker;
    nameWorker = widget.nameWorker;
    nameGWorker = widget.nameGWorker;
    soLuongController.text = widget.quantity;

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
              height: 210,
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
                                        'Cập nhật thông tin cho Thành Phẩm',
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
                                      onTap: () => FocusScope.of(context).requestFocus(focusSoLuong),
                                      child: Container(
                                        height: 35,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: TextField(
                                          maxLines: 1,
                                          autofocus: true,
                                          // obscureText: true,
                                          controller: soLuongController,
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
                                                top: 10, right: 20,left: 0),
                                            isDense: false,
                                            focusColor: subColor,
                                            hintText: 'Vui lòng nhập số lượng',
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: (){
                                            showDialog(
                                                context: context,
                                                builder: (context) => const FilterScreen(controller: 'dmnc_lookup',
                                                  listItem: null,show: false,)).then((value){
                                              if(value != null){
                                                setState(() {
                                                  codeWorker = value[0];
                                                  nameWorker = value[1];
                                                  codeGWorker = '';
                                                  nameGWorker = '';
                                                });
                                              }
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              const Text('Vận hành:',style: TextStyle(color: Colors.blueGrey,fontSize: 12),),
                                              Expanded( flex: 1,child: Align(alignment: Alignment.center,child: Text(codeWorker.toString().trim()))),
                                              const Icon(EneftyIcons.search_normal_2_outline,color: accent,size: 13,)
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16,right: 16),
                                        child: Container(width: 1,height: 18,color: Colors.blueGrey,),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: (){
                                            showDialog(
                                                context: context,
                                                builder: (context) => const FilterScreen(controller: 'dmnnc_lookup',
                                                  listItem: null,show: false,)).then((value){
                                              if(value != null){
                                                setState(() {
                                                  codeGWorker = value[0];
                                                  nameGWorker = value[1];
                                                  codeWorker = '';
                                                  nameWorker = '';
                                                });
                                              }
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              const Text('Nhóm vận hành:',style: TextStyle(color: Colors.blueGrey,fontSize: 12),),
                                              Expanded( flex: 1,child: Align(alignment: Alignment.center,child: Text(codeGWorker.toString().trim()))),
                                              const Icon(EneftyIcons.search_normal_2_outline,color: accent,size: 13,)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10,top: 20),
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: subColor,
                          ),
                          child: InkWell(
                            onTap: (){
                              Navigator.pop(context,[
                                soLuongController.text,codeWorker,nameWorker,codeGWorker,nameGWorker
                              ]);
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
