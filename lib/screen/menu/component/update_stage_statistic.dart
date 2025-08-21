// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:dms/utils/utils.dart';

import '../../../model/network/response/detail_stage_statistic_response.dart';

class UpdateStageQuantityPopup extends StatefulWidget {
  final int idStage;
  final DetailStageStatisticResponseData item;
  final String title;
  final String mvt;
  const UpdateStageQuantityPopup({Key? key,required this.idStage,required this.item,required this.title,required this.mvt}) : super(key: key);

  @override
  _UpdateStageQuantityPopupState createState() => _UpdateStageQuantityPopupState();
}

class _UpdateStageQuantityPopupState extends State<UpdateStageQuantityPopup> {

  TextEditingController quantityTTController = TextEditingController();
  TextEditingController quantityCPController = TextEditingController();
  TextEditingController quantityDATController = TextEditingController();

  TextEditingController quantityHONGInController = TextEditingController();
  TextEditingController quantityHONGSONGController = TextEditingController();
  TextEditingController quantityHONGBXController = TextEditingController();
  TextEditingController quantityHONGCBController = TextEditingController();
  TextEditingController quantityHONGHTController = TextEditingController();

  FocusNode quantityTTFocus = FocusNode();
  FocusNode quantityCPFocus = FocusNode();
  FocusNode quantityDATFocus = FocusNode();
  FocusNode quantityHONGINFocus = FocusNode();

  FocusNode quantityHONGSONGFocus = FocusNode();
  FocusNode quantityHONGBXFocus = FocusNode();
  FocusNode quantityHONGCBFocus = FocusNode();
  FocusNode quantityHONGHTFocus = FocusNode();

  double slDat=0;

  FocusNode focusNodeContent = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
              decoration: BoxDecoration(color: Colors.white,),
              height: 310,
              width: double.infinity,
              child: Material(
                  animationDuration: Duration(seconds: 3),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
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
                                        '${widget.title}',
                                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      InkWell(
                                        onTap: ()=> Navigator.pop(context),
                                        child: Icon(Icons.clear,color: Colors.black,),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Text(
                                    'Tạo phiếu thống kê CĐ',
                                    style: TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(height: 8,),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.code,color: Colors.grey,size: 12,),
                                              SizedBox(width: 3,),
                                              Text('MVT: ${widget.mvt.toString()}', style: TextStyle(color: Colors.black,fontSize: 12),),
                                            ],
                                          ),
                                          Divider(),
                                          buildStage(widget.item)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: InkWell(
                          onTap: (){
                            if(widget.idStage == 1){
                              Navigator.pop(context,[
                                quantityTTController.text == '' ? '0.0' : quantityTTController.text,
                                quantityCPController.text == '' ? '0.0' : quantityCPController.text,
                                quantityDATController.text == '' ? '0.0' : quantityDATController.text
                              ]);
                            }else if(widget.idStage == 2){
                              Navigator.pop(context,[
                                quantityTTController.text == '' ? '0.0' : quantityTTController.text,
                                quantityHONGInController.text == '' ? '0.0' : quantityHONGInController.text,
                                quantityHONGSONGController.text == '' ? '0.0' : quantityHONGSONGController.text,
                                quantityDATController.text == '' ? '0.0' : quantityDATController.text
                              ]);
                            }else if(widget.idStage == 3){
                              Navigator.pop(context,[
                                quantityTTController.text == '' ? '0.0' : quantityTTController.text,
                                quantityHONGInController.text == '' ? '0.0' : quantityHONGInController.text,
                                quantityHONGSONGController.text == '' ? '0.0' : quantityHONGSONGController.text,
                                quantityHONGBXController.text == '' ? '0.0' : quantityHONGBXController.text,
                                quantityDATController.text == '' ? '0.0' : quantityDATController.text
                              ]);
                            }else if(widget.idStage == 4){
                              Navigator.pop(context,[
                                quantityTTController.text == '' ? '0.0' : quantityTTController.text,
                                quantityHONGInController.text == '' ? '0.0' : quantityHONGInController.text,
                                quantityHONGSONGController.text == '' ? '0.0' : quantityHONGSONGController.text,
                                quantityHONGBXController.text == '' ? '0.0' : quantityHONGBXController.text,
                                quantityDATController.text == '' ? '0.0' : quantityDATController.text
                              ]);
                            }
                            else if(widget.idStage == 5){
                              Navigator.pop(context,[
                                quantityTTController.text == '' ? '0.0' : quantityTTController.text,
                                quantityHONGInController.text == '' ? '0.0' : quantityHONGInController.text,
                                quantityHONGCBController.text == '' ? '0.0' : quantityHONGCBController.text,
                                //quantityHONGBXController.text == '' ? '0.0' : quantityHONGBXController.text,
                                quantityHONGHTController.text == '' ? '0.0' : quantityHONGHTController.text,
                                quantityDATController.text == '' ? '0.0' : quantityDATController.text
                              ]);
                            }
                          },
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            decoration: BoxDecoration(color: Colors.orange,),
                            child: Center(
                              child: Text(
                                'Xong',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),
                    ],
                  )),
            ),
          ],
        ));
  }

  buildStage(DetailStageStatisticResponseData item){
    final double width = MediaQuery.of(context).size.width;
    return Expanded(
      child: widget.idStage == 1
          ?
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  DataTable(
          headingRowHeight: 40,
          dividerThickness: 1.0,
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: <DataColumn>[
            DataColumn(
              label: Container(
                width: width * .3,
                child: Center(
                  child: Text(
                    'Sản xuất',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .3,
                child: Center(
                  child: Text(
                    'Chuyển phế',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .3,
                child: Center(
                  child: Text(
                    'SL Đạt',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            // DataColumn(
            //   label: VerticalDivider(),
            // ),
            // DataColumn(
            //   label: Container(
            //     width: width * .2,
            //     child: Center(
            //       child: Text(
            //         'Kho',
            //         style: TextStyle(fontSize: 13),
            //       ),
            //     ),
            //   ),
            // ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityTTController,
                    focusNode:  quantityTTFocus,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    // focusNode: focusNodeContent,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        // if(quantityTTController.text == null)
                        slDat = (text == '' ? 0.0 : double.parse(text.toString()))
                            -
                            (quantityCPController.text == '' ? 0.0 : double.parse(quantityCPController.text.toString()));
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityTTFocus,  quantityCPFocus),
                    textInputAction: TextInputAction.next,
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityCPController,
                    focusNode: quantityCPFocus,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    onChanged: (text){
                      setState(() {
                        // if(quantityTTController.text == null)
                        slDat =  (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            (text == '' ? 0.0 : double.parse(text.toString()));
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    // focusNode: focusNodeContent,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    textInputAction: TextInputAction.done,
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    enabled: false,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityDATController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    // focusNode: focusNodeContent,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    //textInputAction: TextInputAction.none,
                  ),
                ))),
                // DataCell(VerticalDivider()),
                // DataCell(Center(child: Text('....'))),
              ],
            ),
          ],
        ),
      )
          :
      widget.idStage == 2
          ?
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  DataTable(
          headingRowHeight: 40,
          dividerThickness: 1.0,
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: <DataColumn>[
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Phôi vào',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng in',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng sóng',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'SL Đạt',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityTTController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityTTFocus,
                    onChanged: (text){
                      setState(() {
                        slDat = (text == '' ? 0.0 : double.parse(text.toString()))
                            -
                            (quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString())
                                +
                            (quantityHONGSONGController.text == '' ? 0.0 : double.parse(quantityHONGSONGController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityTTFocus,  quantityHONGINFocus),
                    textInputAction: TextInputAction.next,
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGInController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            ((text == '' ? 0.0 : double.parse(text.toString()))
                                +
                             (quantityHONGSONGController.text == '' ? 0.0 : double.parse(quantityHONGSONGController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    focusNode: quantityHONGINFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityHONGINFocus,  quantityHONGSONGFocus),
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGSONGController,
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            ((text == '' ? 0.0 : double.parse(text.toString()))
                                +
                                (quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityHONGSONGFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    textInputAction: TextInputAction.done,
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    enabled: false,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityDATController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    // focusNode: focusNodeContent,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    //textInputAction: TextInputAction.none,
                  ),
                ))),
              ],
            ),
          ],
        ),
      )
          :
      widget.idStage == 3
          ?
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  DataTable(
          headingRowHeight: 40,
          dividerThickness: 1.0,
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: <DataColumn>[
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Phôi vào',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng in',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng sóng',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng bế xẻ',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'SL Đạt',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityTTController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityTTFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      if(text != null){
                        setState(() {
                          slDat = (text == '' ? 0.0 : double.parse(text.toString()))
                              -
                              (   quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString())
                                  +
                                  (quantityHONGSONGController.text == '' ? 0.0 : double.parse(quantityHONGSONGController.text.toString()))
                                  +
                                  (quantityHONGBXController.text == '' ? 0.0 : double.parse(quantityHONGBXController.text.toString()))
                              );
                          quantityDATController.text = slDat.toString();
                        });
                      }
                    },
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityTTFocus,  quantityHONGINFocus),
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGInController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityHONGINFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            (   (text == '' ? 0.0 : double.parse(text.toString()))
                                +
                                (quantityHONGSONGController.text == '' ? 0.0 : double.parse(quantityHONGSONGController.text.toString()))
                                +
                                (quantityHONGBXController.text == '' ? 0.0 : double.parse(quantityHONGBXController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityHONGINFocus,  quantityHONGSONGFocus),
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGSONGController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityHONGSONGFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            (   (text == '' ? 0.0 : double.parse(text.toString()))
                                +
                                (quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString()))
                                +
                                (quantityHONGBXController.text == '' ? 0.0 : double.parse(quantityHONGBXController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityHONGSONGFocus,  quantityHONGBXFocus),
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGBXController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityHONGBXFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            (   (text == '' ? 0.0 : double.parse(text.toString()))
                                +
                                (quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString()))
                                +
                                (quantityHONGSONGController.text == '' ? 0.0 : double.parse(quantityHONGSONGController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.done,
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    enabled: false,
                    // obscureText: true,
                    controller: quantityDATController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    // focusNode: focusNodeContent,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    //textInputAction: TextInputAction.none,
                  ),
                ))),
              ],
            ),
          ],
        ),
      )
          :
      widget.idStage == 4
          ?
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  DataTable(
          headingRowHeight: 40,
          dividerThickness: 1.0,
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: <DataColumn>[
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Phôi vào',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng in',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng sóng',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng bế xẻ',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'SL Đạt',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityTTController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityTTFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (text == '' ? 0.0 : double.parse(text.toString()))
                            -
                            (   quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString())
                                +
                                (quantityHONGSONGController.text == '' ? 0.0 : double.parse(quantityHONGSONGController.text.toString()))
                                +
                                (quantityHONGBXController.text == '' ? 0.0 : double.parse(quantityHONGBXController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityTTFocus,  quantityHONGINFocus),
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGInController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityHONGINFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            (   (text == '' ? 0.0 : double.parse(text.toString()))
                                +
                                (quantityHONGSONGController.text == '' ? 0.0 : double.parse(quantityHONGSONGController.text.toString()))
                                +
                                (quantityHONGBXController.text == '' ? 0.0 : double.parse(quantityHONGBXController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityHONGINFocus,  quantityHONGSONGFocus),
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGSONGController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityHONGSONGFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            (   (text == '' ? 0.0 : double.parse(text.toString()))
                                +
                                (quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString()))
                                +
                                (quantityHONGBXController.text == '' ? 0.0 : double.parse(quantityHONGBXController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityHONGSONGFocus,  quantityHONGBXFocus),
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGBXController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityHONGBXFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            (   (text == '' ? 0.0 : double.parse(text.toString()))
                                +
                                (quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString()))
                                +
                                (quantityHONGSONGController.text == '' ? 0.0 : double.parse(quantityHONGSONGController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.done,
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    enabled: false,
                    controller: quantityDATController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    // focusNode: focusNodeContent,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    //textInputAction: TextInputAction.none,
                  ),
                ))),
              ],
            ),
          ],
        ),
      )
          :
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  DataTable(
          headingRowHeight: 40,
          dividerThickness: 1.0,
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: <DataColumn>[
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Phôi vào',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng in',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng chế biến',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'Hỏng hoàn thiện',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: Container(
                width: width * .2,
                child: Center(
                  child: Text(
                    'SL Đạt',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            // DataColumn(
            //   label: VerticalDivider(),
            // ),
            // DataColumn(
            //   label: Container(
            //     width: width * .2,
            //     child: Center(
            //       child: Text(
            //         'Kho',
            //         style: TextStyle(fontSize: 13),
            //       ),
            //     ),
            //   ),
            // ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityTTController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityTTFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (text == '' ? 0.0 : double.parse(text.toString()))
                            -
                            (   quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString())
                                +
                                (quantityHONGCBController.text == '' ? 0.0 : double.parse(quantityHONGCBController.text.toString()))
                                +
                                (quantityHONGHTController.text == '' ? 0.0 : double.parse(quantityHONGHTController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityTTFocus,  quantityHONGINFocus),
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGInController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityHONGINFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            (   (text == '' ? 0 : double.parse(text.toString()))
                                +
                                (quantityHONGCBController.text == '' ? 0.0 : double.parse(quantityHONGCBController.text.toString()))
                                +
                                (quantityHONGHTController.text == '' ? 0.0 : double.parse(quantityHONGHTController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityHONGINFocus,  quantityHONGCBFocus),
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGCBController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityHONGCBFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            (   (text == '' ? 0.0 : double.parse(text.toString()))
                                +
                                (quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString()))
                                +
                                (quantityHONGHTController.text == '' ? 0.0 : double.parse(quantityHONGHTController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_)=>Utils.navigateNextFocusChange(context,  quantityHONGCBFocus,  quantityHONGHTFocus),
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    // obscureText: true,
                    controller: quantityHONGHTController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    focusNode: quantityHONGHTFocus,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    onChanged: (text){
                      setState(() {
                        slDat = (quantityTTController.text == '' ? 0.0 : double.parse(quantityTTController.text.toString()))
                            -
                            (   (text == '' ? 0.0 : double.parse(text.toString()))
                                +
                                (quantityHONGInController.text == '' ? 0.0 : double.parse(quantityHONGInController.text.toString()))
                                +
                                (quantityHONGCBController.text == '' ? 0.0 : double.parse(quantityHONGCBController.text.toString()))
                            );
                        quantityDATController.text = slDat.toString();
                      });
                    },
                    textInputAction: TextInputAction.done,
                  ),
                ))),
                DataCell(VerticalDivider()),
                DataCell(Center(child: Container(
                  // height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    maxLines: 1,
                    autofocus: true,
                    enabled: false,
                    // obscureText: true,
                    controller: quantityDATController,
                    decoration: new InputDecoration(
                      hintText: '0.0',
                      hintStyle: TextStyle( color: Colors.grey),
                    ),
                    // focusNode: focusNodeContent,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                    //textInputAction: TextInputAction.none,
                  ),
                ))),
                // DataCell(VerticalDivider()),
                // DataCell(Center(child: Text('....'))),
              ],
            ),
          ],
        ),
      )
      ,
    );
  }
}
