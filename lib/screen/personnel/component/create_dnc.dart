import 'dart:io';
import 'dart:math';

import 'package:dms/widget/pending_action.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../model/network/request/create_dnc_request.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../filter/filter_page.dart';
import '../suggestions/suggestions_bloc.dart';
import '../suggestions/suggestions_event.dart';
import '../suggestions/suggestions_state.dart';

class CreateDNCScreen extends StatefulWidget {
  const CreateDNCScreen({Key? key}) : super(key: key);

  @override
  _CreateDNCScreenState createState() => _CreateDNCScreenState();
}

class _CreateDNCScreenState extends State<CreateDNCScreen> {

  late SuggestionsBloc _bloc;

  FocusNode focusNodeContent = FocusNode();
  TextEditingController _contentController = TextEditingController();

  List<ListDNCDataDetail2> _listDNCDataDetail = [];

  static const _locale = 'en';
  String _formatNumber(String s) => NumberFormat.decimalPattern(_locale).format(int.parse(s));

  String get _currency => NumberFormat.compactSimpleCurrency(locale: 'vi').currencySymbol;


  List<String> listTypePayment = ['Chuyển khoản', 'Tiền mặt'];
  List<String> listTypeTransaction = ['Tạm ứng', 'Chi tiền'];

  String typePayment = 'Chuyển khoản';
  String typeTransaction = 'Tạm ứng';

  String? idPayment;
  String? idTransaction;

  int totalFile = 0;
  String departmentCode = '';
  String departmentName = '';

  String customerCode = '';
  String customerName = '';

  List<ListAttachFile> listAttachFile = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SuggestionsBloc(context);
    _bloc.add(GetPrefsSuggestions());
    _bloc.dateCreateDNC = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _listDNCDataDetail.add(
      ListDNCDataDetail2(
        textEditingController: TextEditingController(),
        tienNt: 0,
        dienGiai: 'Nội dung mô tả'
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 55),
        child: FloatingActionButton(
          backgroundColor: subColor,
          onPressed: ()async{
            showModalBottomSheet(
                context: context,
                isDismissible: true,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
                ),
                backgroundColor: Colors.white,
                builder: (builder){
                  return Container(
                    height: MediaQuery.of(context).copyWith().size.height * 0.60,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25)
                        )
                    ),
                    margin: MediaQuery.of(context).viewInsets,
                    child: StatefulBuilder(
                      builder: (BuildContext context,StateSetter myState){
                        return Padding(
                          padding: const EdgeInsets.only(top: 10,bottom: 0),
                          child: Container(
                            decoration:const BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(25),
                                    topLeft: Radius.circular(25)
                                )
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0,left: 8,right: 18),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                          onTap: ()=> Navigator.pop(context),
                                          child: const Icon(Icons.close,color: Colors.white,)),
                                      const Text('Thêm tuỳ chọn',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),),
                                      InkWell(
                                          onTap: ()=> Navigator.pop(context),
                                          child: const Icon(Icons.check,color: Colors.black,)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5,),
                                const Divider(color: Colors.blueGrey,),
                                Expanded(
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                        ),
                                        padding: const EdgeInsets.only(left: 8,right: 8,top: 0,bottom: 16),
                                        child: Column(
                                          children: [
                                            /// Loại thanh toán
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Card(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 12,bottom: 12,left: 10,right: 10),
                                                  child: PopupMenuButton(
                                                      padding: EdgeInsets.zero,
                                                      offset: const Offset(4, 30),
                                                      itemBuilder: (BuildContext context) {
                                                        return <PopupMenuEntry<Widget>>[
                                                          PopupMenuItem<Widget>(
                                                            child: Container(
                                                              decoration: ShapeDecoration(
                                                                  color: Colors.white,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(10))),
                                                              height: 150,
                                                              width: 550,
                                                              child: Scrollbar(
                                                                child: ListView.builder(
                                                                  padding: const EdgeInsets.only(top: 10),
                                                                  itemCount: listTypePayment.length,
                                                                  itemBuilder: (context, index) {
                                                                    final trans = listTypePayment[index].toString();
                                                                    return ListTile(
                                                                      title: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Flexible(
                                                                            child: Text(
                                                                              trans.toString(),
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                              ),
                                                                              maxLines: 1,overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      subtitle: const Divider(height: 1,),
                                                                      onTap: () {
                                                                        myState(() {
                                                                          typePayment = trans;
                                                                        });
                                                                        Navigator.pop(context);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ];
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Expanded(
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.payment,color: subColor,size: 20,),
                                                                SizedBox(width: 5,),
                                                                Text('Loại thanh toán',style: TextStyle(color: Colors.black),),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Center(child: Text(typePayment,style: const TextStyle(color: Colors.blueGrey),)),
                                                              const SizedBox(width: 10,),
                                                              const Icon(Icons.arrow_drop_down,color: Colors.blueGrey,),
                                                            ],
                                                          ))
                                                        ],
                                                      )),
                                                ),
                                              ),
                                            ),
                                            ///Loại giao dịch
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: InkWell(
                                                onTap:()=>Navigator.pop(context,'2'),
                                                child: Card(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                                    child: PopupMenuButton(
                                                        padding: EdgeInsets.zero,
                                                        offset: const Offset(4, 30),
                                                        itemBuilder: (BuildContext context) {
                                                          return <PopupMenuEntry<Widget>>[
                                                            PopupMenuItem<Widget>(
                                                              child: Container(
                                                                decoration: ShapeDecoration(
                                                                    color: Colors.white,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(10))),
                                                                height: 150,
                                                                width: 550,
                                                                child: Scrollbar(
                                                                  child: ListView.builder(
                                                                    padding: const EdgeInsets.only(top: 10),
                                                                    itemCount: listTypeTransaction.length,
                                                                    itemBuilder: (context, index) {
                                                                      final trans = listTypeTransaction[index].toString();
                                                                      return ListTile(
                                                                        title: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Flexible(
                                                                              child: Text(
                                                                                trans.toString(),
                                                                                style: const TextStyle(
                                                                                  fontSize: 12,
                                                                                ),
                                                                                maxLines: 1,overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        subtitle: const Divider(height: 1,),
                                                                        onTap: () {
                                                                          myState(() {
                                                                            typeTransaction = trans;
                                                                          });
                                                                          Navigator.pop(context);
                                                                        },
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ];
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const Expanded(
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.transfer_within_a_station,color: subColor,size: 20,),
                                                                  SizedBox(width: 5,),
                                                                  Text('Loại giao dịch',style: TextStyle(color: Colors.black),),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Center(child: Text(typeTransaction,style: const TextStyle(color: Colors.blueGrey),)),
                                                                const SizedBox(width: 10,),
                                                                const Icon(Icons.arrow_drop_down,color: Colors.blueGrey,),
                                                              ],
                                                            ))
                                                          ],
                                                        )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: InkWell(
                                                onTap: ()async{
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) => const FilterScreen(controller: 'dmbp_lookup',
                                                        listItem: null,show: false,)).then((value){
                                                    if(value != null){
                                                      myState(() {
                                                        departmentCode = value[0];
                                                        departmentName = value[1];
                                                      });
                                                    }
                                                  });
                                                },
                                                child: Card(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Expanded(
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.account_circle_outlined,color: subColor,size: 20,),
                                                              SizedBox(width: 5,),
                                                              Text('Phòng ban',style: TextStyle(color: Colors.black),),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Center(child: Text(departmentName.isEmpty ? 'Chọn phòng ban' : '$departmentName',style: const TextStyle(color: Colors.blueGrey),)),
                                                            const SizedBox(width: 10,),
                                                            const Icon(Icons.arrow_drop_down,color: Colors.blueGrey,),
                                                          ],
                                                        ))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: InkWell(
                                                onTap: ()async{
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) => const FilterScreen(controller: 'dmkh_lookup',
                                                        listItem: null,show: false,)).then((value){
                                                    if(value != null){
                                                      myState(() {
                                                        customerCode = value[0];
                                                        customerName = value[1];
                                                      });
                                                    }
                                                  });
                                                },
                                                child: Card(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Expanded(
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.man_sharp,color: subColor,size: 20,),
                                                              SizedBox(width: 5,),
                                                              Text('Khách hàng',style: TextStyle(color: Colors.black),),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Center(child: Text(customerName.isEmpty ? 'Chọn khách hàng' : customerName,style: const TextStyle(color: Colors.blueGrey),maxLines: 1,)),
                                                            const SizedBox(width: 10,),
                                                            const Icon(Icons.arrow_drop_down,color: Colors.blueGrey,),
                                                          ],
                                                        ))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: InkWell(
                                                onTap:()=>Navigator.pop(context,'4'),
                                                child: Card(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Expanded(
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.calendar_today_outlined,color: subColor,size: 20,),
                                                              SizedBox(width: 5,),
                                                              Text('Ngày tạo phiếu',style: TextStyle(color: Colors.black),),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(child: InkWell(
                                                          onTap: (){
                                                            Utils.dateTimePickerCustom(context).then((value){
                                                              if(value != null){
                                                                myState(() {
                                                                  _bloc.dateCreateDNC = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                                                });
                                                              }
                                                            });
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Center(child: Text(_bloc.dateCreateDNC.toString().isEmpty ? 'Chọn ngày' : _bloc.dateCreateDNC.toString(),style: const TextStyle(color: Colors.blueGrey),maxLines: 1,)),
                                                              const SizedBox(width: 10,),
                                                              const Icon(Icons.event,color: Colors.blueGrey,size: 22),
                                                            ],
                                                          ),
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              child: InkWell(
                                                onTap: ()async{
                                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                    type: FileType.media,
                                                    // allowedExtensions: ['jpg', 'png',],
                                                    allowMultiple: true,
                                                  );
                                                  if(listAttachFile.isNotEmpty) {
                                                    listAttachFile.clear();
                                                  }
                                                  if(result!.files.isNotEmpty){
                                                    if(result.count < 3){
                                                      totalFile = result.count;
                                                    }else{
                                                      totalFile = 3;
                                                    }
                                                    double fileSize = 0;
                                                    result.files.forEach((element)async {
                                                      PlatformFile file = element;
                                                      fileSize = ((File(file.path.toString()).readAsBytesSync().lengthInBytes)/1024) + fileSize; /// Kb
                                                      // compressWithNativeImage(File(file.path.toString()),file.name,file.extension.toString(),file.size,fileSize);
                                                    });
                                                  } else {
                                                    // User canceled the picker
                                                  }
                                                  myState(() {});
                                                },
                                                child: Card(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Expanded(
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.attach_email_outlined,color: subColor,size: 20,),
                                                              SizedBox(width: 5,),
                                                              Text('File đính kèm',style: TextStyle(color: Colors.black),),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Center(child: Text(totalFile == 0 ? 'Tệp đính kèm' : 'Đã thêm $totalFile đính kèm',style: const TextStyle(color: Colors.blueGrey),)),
                                                            const SizedBox(width: 10,),
                                                            InkWell(
                                                                onTap: (){
                                                                  myState(() {
                                                                    if(listAttachFile.isNotEmpty) {
                                                                      listAttachFile.clear();
                                                                    }
                                                                    totalFile = 0;
                                                                  });
                                                                },
                                                                child: const Icon(Icons.delete_forever,color: Colors.blueGrey,)),
                                                          ],
                                                        ))
                                                      ],
                                                    ),
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

                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
            ).then((value)async{

            });
          },
          child: const Icon(Icons.addchart_outlined,color: Colors.white,),
        ),
      ),
      body: BlocListener<SuggestionsBloc,SuggestionsState>(
        bloc: _bloc,
        listener: (context, state){
          if(state is AddOrRemoveCoreWaterSuccess){
            _listDNCDataDetail = _bloc.listDNCDetail;
          }else if(state is CreateDNCSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Tạo phiếu thành công.');
            Navigator.pop(context,['ReloadScreen']);
          }
        },
        child: BlocBuilder<SuggestionsBloc,SuggestionsState>(
          bloc: _bloc,
          builder: (BuildContext context, SuggestionsState state){
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is SuggestionsLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,SuggestionsState state){
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 55),
        child: Column(
          children: [
            buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Tiêu đề          ',overflow: TextOverflow.ellipsis,maxLines: 1,)),
                                const SizedBox(width: 5,),
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: TextField(
                                        controller: _contentController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(color: grey, width: 1),
                                          ),
                                          contentPadding: const EdgeInsets.only(top: 20,bottom: 7,left: 10),
                                          isDense: true,
                                          focusColor: primaryColor,
                                          hintText: 'Vui lòng nhập tiêu đề...',
                                          hintStyle: const TextStyle(
                                            fontSize: 12,
                                            color: grey,
                                          ),
                                        ),
                                        onChanged: (text) {},
                                        style:const TextStyle(
                                          fontSize: 14,
                                          color: black,)
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 5,color: Colors.grey.withOpacity(0.2),),
                    coreWater(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  buildAppBar(){
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
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
              colors: [subColor,Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.pop(context,['Back']),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Tạo mới đề nghị",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              if(_bloc.listDNCDetail.isNotEmpty){
                if(_bloc.listDNCDetail[0].tienNt>0){
                  if(typePayment == 'Chuyển khoản'){
                    idPayment = "1";
                  }else if(typePayment == 'Tiền mặt'){
                    idPayment = "2";
                  }
                  if(typeTransaction == 'Tạm ứng'){
                    idTransaction = "1";
                  }else if(typeTransaction == 'Chi tiền'){
                    idTransaction = "2";
                  }
                  _bloc.add(CreateDNCEvent(
                      departmentCode: departmentCode,
                      typePayment: idPayment!,
                      typeTransaction: idTransaction!,
                      desc: _contentController.text,
                      attachFile: listAttachFile,customerCode: customerCode.toString()
                  ));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Hãy thêm đề nghị mới');
                }
              }else{
                Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy thêm đề nghị mới');
              }
            },
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.how_to_reg,
                size: 25,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget coreWater(){
    return Padding(
      padding: const EdgeInsets.only(top: 16,bottom: 10,left: 16,right: 16),
      child: Column(
        children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Thêm đề nghị chi tiền',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
          if(_bloc.listDNCDetail.isNotEmpty)
            for(var i in _bloc.listDNCDetail) Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10,bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nội dung số: ${_bloc.listDNCDetail.indexOf(i) + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12,color: Colors.black),
                          ),
                          InkWell(
                              onTap: ()=>_bloc.add(AddOrRemoveCoreWater(type: false,item: i,index: _bloc.listDNCDetail.indexOf(i))),
                              child: SizedBox(
                                  height: 30,width: 40,
                                  child: Icon(MdiIcons.deleteCircle,color: Colors.grey,))),
                        ],
                      ),
                      const SizedBox(height: 5,),
                      Container(
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: grey, width: 1),
                                ),
                                contentPadding: const EdgeInsets.only(top: 16,bottom: 10,left: 10),
                                isDense: true,
                                focusColor: primaryColor,
                                hintText: 'Nội dung đề nghị',
                                hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: grey,
                                ),
                              ),
                              onChanged: (text) {
                                i.dienGiai = text;
                              },
                              style:const TextStyle(
                                fontSize: 14,
                                color: black,)
                          )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Số tiền',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12,color: Colors.black),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: TextField(
                            controller: i.textEditingController,
                            decoration: InputDecoration(
                                prefixText: _currency,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: grey, width: 1),
                                ),
                                contentPadding: const EdgeInsets.only(top: 16,bottom: 10,left: 10),
                                isDense: true,
                                focusColor: primaryColor,
                                hintText: '1.000.000 vnđ',
                                hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: grey,
                                ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (string) {
                              if(string.isNotEmpty){
                                i.tienNt = string == '' ? 0 : double.parse( string.replaceAll(',', ''));
                                string = _formatNumber(string.replaceAll(',', ''));
                                i.textEditingController.value = TextEditingValue(
                                  text: string,
                                  selection: TextSelection.collapsed(offset: string.length),
                                );
                              }
                            },
                            style:const TextStyle(
                              fontSize: 14,
                              color: black,)
                          )
                      ),
                    )
                  ],
                ),
                const Divider(thickness: 2,)
              ],
            ),
          const SizedBox(height: 16,),
          InkWell(
              onTap: (){
                ListDNCDataDetail2 item = ListDNCDataDetail2(
                  textEditingController: TextEditingController(),
                  tienNt: 0,
                  dienGiai: ''
                );
                _bloc.add(AddOrRemoveCoreWater(type: true,item: item));
              },
              child: SizedBox(
                  height: 30,width: 40,
                  child: Icon(MdiIcons.plusCircleOutline,color: Colors.black,))),
        ],
      ),
    );
  }

  // void compressWithNativeImage(File? imageFile,String fileName, String fileExt, int fileSize, double totalFileSize) async {
  //   File? imageCompressed;
  //   await FlutterNativeImage.compressImage(
  //     imageFile!.path,
  //     quality: 35,
  //   )
  //       .then((response) {
  //     imageCompressed = response;
  //     var bytes = File(imageCompressed!.path).readAsBytesSync();
  //     var result = hex.encoder.convert(bytes);
  //     ListAttachFile itemAttachFile = ListAttachFile(
  //       fileName: fileName,
  //       fileExt: fileExt,
  //       fileSize: imageCompressed!.lengthSync().toString(),
  //       fileData: result,
  //     );
  //
  //     if(listAttachFile.length < 4 && ((totalFileSize/1024) < 5)){
  //       listAttachFile.add(itemAttachFile);
  //     }else {
  //       Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Chỉ được phép Attach tối đa 4 files và < 5Mb thôi!!!');
  //     }
  //   })
  //       .catchError((e) {
  //   });
  // }

  getFileSize(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    ///print(((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i]);
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
