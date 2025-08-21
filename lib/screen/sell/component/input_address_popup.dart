import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InputAddressPopup extends StatefulWidget {
  final String note;
  final String title;
  final String desc;
  final bool inputNumber;
  final bool convertMoney;

  const InputAddressPopup({Key? key,required this.note,required this.title,required this.desc,required this.inputNumber,required this.convertMoney}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _InputAddressPopupState createState() => _InputAddressPopupState();
}

class _InputAddressPopupState extends State<InputAddressPopup> {

  TextEditingController contentController = TextEditingController();

  FocusNode focusNodeContent = FocusNode();

  static const _locale = 'en';
  String _formatNumber(String s) => NumberFormat.decimalPattern(_locale).format(int.parse(s));

  String get _currency => NumberFormat.compactSimpleCurrency(locale: 'vi').currencySymbol;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contentController.text = widget.note;
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
              height: 180,
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius:const  BorderRadius.all( Radius.circular(16)),
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
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
                                        widget.title,
                                        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      InkWell(
                                        onTap: ()=> Navigator.pop(context),
                                        child: const Icon(Icons.clear,color: Colors.black,),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
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
                                          decoration: const  InputDecoration(
                                            //suffixText: widget.convertMoney == true ? 'Nghìn vnđ' : ' cái, thùng, chiếc',
                                            isDense: true,
                                            //hintText: widget.desc??'',
                                            hintStyle: TextStyle( color: Colors.grey),
                                          ),
                                          // focusNode: focusNodeContent,
                                          keyboardType: widget.inputNumber == true ? TextInputType.number : TextInputType.text,
                                          onChanged: (string) {
                                            if(string != '' && widget.convertMoney == true){
                                              if(widget.inputNumber == true){
                                                string = _formatNumber(string.replaceAll(',', ''));
                                                contentController.value = TextEditingValue(
                                                  text: string,
                                                  selection: TextSelection.collapsed(offset: string.length),
                                                );
                                              }
                                            }
                                          },
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
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: TextButton(
                          onPressed: (){
                            Navigator.pop(context,contentController.text);
                          },
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            decoration: const BoxDecoration(color: Colors.orange,borderRadius: BorderRadius.all(Radius.circular(10))),
                            child: const Center(
                              child: Text(
                                'Xong',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15,),
                    ],
                  )),
            ),
          ],
        ));
  }
}
