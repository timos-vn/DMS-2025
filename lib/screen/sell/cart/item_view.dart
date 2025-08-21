import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../themes/colors.dart';

class ItemView extends StatelessWidget {
  const ItemView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 130,
            decoration: const BoxDecoration(
                borderRadius:BorderRadius.all( Radius.circular(6),)
            ),
            child: const Icon(EneftyIcons.image_outline,size: 50,weight: 0.6,),
            //Image.network('https://i.pinimg.com/564x/49/77/91/4977919321475b060fcdd89504cee992.jpg',fit: BoxFit.contain,),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10,right: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "widget.nameProduction.toString().toUpperCase()",
                    style:TextStyle(color: subColor, fontSize: 14, fontWeight: FontWeight.w600,),
                    maxLines: 2,overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(FluentIcons.cart_16_filled),
                      const SizedBox(width: 5,),
                      Container(
                        height: 13, //width: double.infinity,
                        child:  const Text(
                          'Kho 1995',
                          style:TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 10,),
                            Container(
                              height: 13,
                              width: 1.5,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 10,),
                            const Text(
                              'Loại: Chế biến',
                              style:TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 35,
                          width: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                '\$ 123.000.00',
                                style:TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.transparent,
                                  width: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 35,
                        width: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: grey_100
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                                onTap: (){
                                  int qty = 0;
                                  // qty = int.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                  // if(qty > 1){
                                  //   setState(() {
                                  //     qty = qty - 1;
                                  //     contentController.text = qty.toString();
                                  //     valueInput = double.parse(contentController.text);
                                  //     priceInput = double.parse((qty * widget.price).toString());
                                  //     priceController.text = Utils.formatMoneyStringToDouble((qty * widget.price)).toString();
                                  //   });
                                  // }
                                },
                                child: const Icon(FluentIcons.subtract_12_filled,size: 15,)),
                            Container(
                              color: Colors.transparent,
                              width: 40,
                              child: TextField(
                                autofocus: false,
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.top,
                                style: const TextStyle(fontSize: 14, color: accent),
                                // onSubmitted: (text) {
                                //   _bloc.add(SearchProduct(text,widget.idGroup, widget.selectedId));
                                // },
                                // controller: contentController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                onChanged: (text){
                                  // if(contentController.text.toString().isNotEmpty && contentController.text.toString() != 'null'){
                                  //   int qty = 0;
                                  //   qty = int.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                  //   setState(() {
                                  //     contentController.text = qty.toString();
                                  //     valueInput = double.parse(contentController.text);
                                  //     priceInput = double.parse((qty * widget.price).toString());
                                  //     priceController.text = Utils.formatMoneyStringToDouble((qty * widget.price)).toString();
                                  //   });
                                  // }else{
                                  //   int qty = 1;
                                  //   setState(() {
                                  //     // contentController.text = qty.toString();
                                  //     valueInput = 1;
                                  //     priceInput = double.parse((qty * widget.price).toString());
                                  //     priceController.text = Utils.formatMoneyStringToDouble((qty * widget.price)).toString();
                                  //   });
                                  // }
                                },
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: transparent,
                                    hintText: "1",
                                    hintStyle: TextStyle(color: accent),
                                    contentPadding: EdgeInsets.only(
                                        bottom: 12, top: 0)
                                ),
                              ),
                            ),
                            InkWell(
                                onTap: (){
                                  int qty = 0;
                                  // qty = int.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                  // setState(() {
                                  //   qty = qty + 1;
                                  //   contentController.text = qty.toString();
                                  //   valueInput = double.parse(contentController.text);
                                  //   priceInput = double.parse((qty * widget.price).toString());
                                  //   priceController.text = Utils.formatMoneyStringToDouble((qty * widget.price)).toString();
                                  // });
                                },
                                child: const Icon(FluentIcons.add_12_filled,size: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
