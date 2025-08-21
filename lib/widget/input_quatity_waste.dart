import 'package:dms/screen/filter/filter_page.dart';
import 'package:dms/themes/colors.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as dateFormating;


class UpdateQuantityWaste extends StatefulWidget {
  final double quantity;
  const UpdateQuantityWaste({Key? key, required this.quantity}) : super(key: key);


  @override
  _UpdateQuantityWasteState createState() => _UpdateQuantityWasteState();
}

class _UpdateQuantityWasteState extends State<UpdateQuantityWaste> {

  TextEditingController quantityController = TextEditingController();

  FocusNode quantityFocus = FocusNode();
  String codeStore = '';String nameStore = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    quantityController.text = widget.quantity.toString();

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
                                        'Cập nhật thông tin cho Phế liệu',
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
                                      onTap: () => FocusScope.of(context).requestFocus(quantityFocus),
                                      child: Container(
                                        height: 35,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: TextField(
                                          maxLines: 1,
                                          autofocus: true,
                                          // obscureText: true,
                                          controller: quantityController,
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
                                                builder: (context) => const FilterScreen(controller: 'dmkho_lookup',
                                                  listItem: null,show: false,)).then((value){
                                              if(value != null){
                                                setState(() {
                                                  codeStore = value[0];
                                                  nameStore = value[1];
                                                });
                                              }
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              const Text('Kho:',style: TextStyle(color: Colors.blueGrey,fontSize: 12),),
                                              Expanded( flex: 1,child: Align(alignment: Alignment.center,child: Text(nameStore.toString().trim()))),
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
                                quantityController.text,codeStore,nameStore
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
