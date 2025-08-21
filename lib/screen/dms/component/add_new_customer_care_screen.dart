// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:dms/screen/dms/customer_care/customer_care_bloc.dart';
import 'package:dms/screen/dms/customer_care/customer_care_event.dart';
import 'package:dms/screen/dms/customer_care/customer_care_state.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:dms/widget/text_field_widget2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../custom_lib/view_only_image.dart';
import '../../../model/network/response/manager_customer_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/utils.dart';
import '../../customer/search_customer/search_customer_screen.dart';
import '../../sell/component/input_address_popup.dart';


class AddNewCustomerCareScreen extends StatefulWidget {

  final String? idCustomer;

  const AddNewCustomerCareScreen({Key? key, this.idCustomer}) : super(key: key);

  @override
  _AddNewCustomerCareScreenState createState() => _AddNewCustomerCareScreenState();
}

class _AddNewCustomerCareScreenState extends State<AddNewCustomerCareScreen> {

  late CustomerCareBloc _bloc;

  final nameCompanyController = TextEditingController();
  final noteController = TextEditingController();
  final feedbackController = TextEditingController();
  final addressController = TextEditingController();
  final nameCompanyFocus = FocusNode();
  final feedbackFocus = FocusNode();final addressFocus = FocusNode();final noteFocus = FocusNode();

  final nameCustomerController = TextEditingController();
  final addressCustomerController = TextEditingController();
  final phoneCustomerController = TextEditingController();
  final nameCustomerFocus = FocusNode();
  final addressCustomerFocus = FocusNode();
  final phoneCustomerFocus = FocusNode();


  late Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  int start = 3;

  bool waitingLoad = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {
          waitingLoad = false;
          setState(() {});
          timer.cancel();
        } else {
          start--;
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = CustomerCareBloc(context);
    _bloc.add(GetPrefsCustomerCareEvent());
  }

  final imagePicker = ImagePicker();

  Future getImage(bool isCamera)async {
    late final XFile? image;
    if(isCamera == true){
      image = await imagePicker.pickImage(source: ImageSource.camera,imageQuality: 65);
    }else{
      image = await imagePicker.pickImage(source: ImageSource.gallery,imageQuality: 65);
    }
    setState(() {
      if(image != null){
        start = 2;waitingLoad  = true;
        startTimer();
        _bloc.listFileInvoice.add(File(image.path));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: subColor,
        onPressed: ()async{
          if(noteController.text.isNotEmpty && feedbackController.text.isNotEmpty){
            showDialog(
                context: context,
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: const CustomQuestionComponent(
                      showTwoButton: true,
                      iconData: Icons.warning_amber_outlined,
                      title: 'Bạn đang tạo phiếu CSKH!',
                      content: 'Hãy chắc chắn là bạn muốn điều này!',
                    ),
                  );
                }).then((value) {
              if(!Utils.isEmpty(value) && value == 'Yeah'){
                _bloc.add(AddNewCustomerCareEvent(
                  typeCare: _bloc.typeCare.join(','),
                  idCustomer: _bloc.codeCustomer.toString(),
                  description: noteController.text,
                  feedback: feedbackController.text,
                  otherTypeCare: _bloc.noteSell.toString()
                ));
              }
            });
          }else{
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vui lòng nhập đầy đủ nội dung');
          }
        },
        child: Icon(MdiIcons.plusBoxOutline,color: Colors.white,),
      ),
      body: BlocListener<CustomerCareBloc,CustomerCareState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsCustomerCareSuccess){

          }
          else if(state is PickInfoCustomerSuccess){
            nameCustomerController.text = _bloc.customerName.toString();
            phoneCustomerController.text = _bloc.phoneCustomer.toString();
            addressCustomerController.text = _bloc.addressCustomer.toString();
          }
          else if(state is GrantCameraPermission){
            _showDialog(context);
          }
         else if(state is AddNewCustomerCareSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Thêm mới yêu cầu thành công');
            Navigator.pop(context,'RELOAD');
          }else if(state is CustomerCareFailure){
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error);
          }
        },
        child: BlocBuilder<CustomerCareBloc,CustomerCareState>(
          bloc: _bloc,
          builder: (BuildContext context, CustomerCareState state){
            return Stack(
              children: [

                buildScreen(context,state),
                Visibility(
                  visible: state is CustomerCareLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text("Ảnh đại diện"),
            actions: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text("Thư viện"),
                    onPressed: () {
                      getImage(false);
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    child:const Text("Máy Ảnh"),
                    onPressed: () {
                      getImage(true);
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          );
        });
  }

  Widget buildScreen(BuildContext context,CustomerCareState state){
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildAppBar(),
            Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildBody(height),
                      const Padding(
                        padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                        child: Text('Nội dung CS của NVCSKH',style: TextStyle(color: subColor,fontWeight: FontWeight.bold),),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                        child: Text('Loại CS',style: TextStyle(color: Colors.blueGrey,fontSize: 12),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16,bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent),
                                    onPressed: ()=>_bloc.add(CheckInTransferEvent(index: 1)),
                                    child: _buildCheckboxList('Phone',_bloc.isPhone,1)),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent),
                                    onPressed: ()=>_bloc.add(CheckInTransferEvent(index: 2)),
                                    child: _buildCheckboxList('Email',_bloc.isEmail,2)),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent),
                                    onPressed: ()=>_bloc.add(CheckInTransferEvent(index: 3)),
                                    child: _buildCheckboxList('SMS',_bloc.isSMS,3)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent),
                                    onPressed: ()=>_bloc.add(CheckInTransferEvent(index: 4)),
                                    child: _buildCheckboxList('Page',_bloc.isMXH,4)),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent),
                                    onPressed: (){
                                      _bloc.add(CheckInTransferEvent(index: 5));
                                      if(_bloc.isOther == true){
                                        _bloc.isOther = false;
                                      }else{
                                        _bloc.isOther = true;
                                        showDialog(
                                            barrierDismissible: true,
                                            context: context,
                                            builder: (context) {
                                              return InputAddressPopup(note: _bloc.noteSell != null ? _bloc.noteSell.toString() : "",title: 'Vui lòng nhập loại CS bạn sử dụng',desc: 'Vui lòng nhập loại CS bạn sử dụng',convertMoney: false, inputNumber: false,);
                                            }).then((note){
                                          if(note != null){
                                            _bloc.add(AddNote(
                                              note: note,
                                            ));
                                          }
                                        });
                                      }
                                    },
                                    child: _buildCheckboxList('Other',_bloc.isOther,5)),
                                const SizedBox(width: 100,height: 10,)
                              ],
                            )
                          ],
                        ),
                      ),
                      Visibility(
                          visible: _bloc.isOther == true,
                          child: const Divider(height: 1,)),
                      Visibility(
                        visible: _bloc.isOther == true,
                        child: GestureDetector(
                          onTap: (){
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) {
                                  return InputAddressPopup(note: _bloc.noteSell != null ? _bloc.noteSell.toString() : "",title: 'Vui lòng nhập loại CS bạn sử dụng',desc: 'Vui lòng nhập loại CS bạn sử dụng',convertMoney: false, inputNumber: false,);
                                }).then((note){
                              if(note != null){
                                _bloc.add(AddNote(
                                  note: note,
                                ));
                              }
                            });
                          },
                          child: SizedBox(
                            height: 45,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5,left: 8,right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Loại CS khác:',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                                  const SizedBox(width: 12,),
                                  Expanded(child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(( _bloc.noteSell != null && _bloc.noteSell != '') ? _bloc.noteSell.toString() : "Vui lòng nhập loại CS mà bạn sử dụng",
                                        style: const TextStyle(color: Colors.grey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,
                                      ))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1,),
                      inputWidget1(title: "Nội dung",hideText: 'Vui lòng nhập nội dung',controller: noteController,focusNode:noteFocus ,
                        textInputAction: TextInputAction.newline, onTapSuffix: (){},note: true,isMultiline: false,maxLength: 100,
                        onSubmitted: ()=>null,),
                      const Padding(
                        padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                        child: Text('Thông tin phản hồi của Khách hàng',style: TextStyle(color: subColor,fontWeight: FontWeight.bold),),
                      ),
                      inputWidget1(title: "Nội dung",hideText: 'Vui lòng nhập nội dung',controller: feedbackController,focusNode: feedbackFocus,
                        textInputAction: TextInputAction.newline, onTapSuffix: (){},note: true,isMultiline: true,maxLength: 1000,
                        onSubmitted: ()=>null,),
                      buildLine(),
                      const Padding(
                        padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                        child: Text('Đính kèm hình ảnh',style: TextStyle(color: subColor,fontWeight: FontWeight.bold),),
                      ),
                      buildAttachFileInvoice(),
                      const SizedBox(height: 70,)
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxList(String title,bool value,int index) {
    return SizedBox(
      height: 25,
      child: Row(
        children: [
          SizedBox(
            height: 10,
            child: Transform.scale(
              scale: 1,
              alignment: Alignment.topLeft,
              child: Checkbox(
                value: value,
                onChanged: (b){
                  if(index == 1){
                    _bloc.add(CheckInTransferEvent(index: 1));
                  }else if(index == 2){
                    _bloc.add(CheckInTransferEvent(index: 2));
                  }else if(index == 3){
                    _bloc.add(CheckInTransferEvent(index: 3));
                  }else if(index == 4){
                    _bloc.add(CheckInTransferEvent(index: 4));
                  }else if(index == 5){
                    _bloc.add(CheckInTransferEvent(index: 5));
                  }
                },
                activeColor: mainColor,
                hoverColor: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                ),
                side: MaterialStateBorderSide.resolveWith((states){
                  if(states.contains(MaterialState.pressed)){
                    return BorderSide(color: mainColor);
                  }else{
                    return BorderSide(color: mainColor);
                  }
                }),
              ),
            ),
          ),
          Text(title,style: const TextStyle(color: Colors.grey,fontSize: 12),),
        ],
      ),
    );
  }

  Widget buildBody(double height){
    return Column(
      children: [
        buildMethodReceive(),
        buildLine(),
      ],
    );
  }

  buildLine(){
    return Padding(
      padding: const EdgeInsets.only(top: 10,bottom: 10),
      child: Container(
        height: 8,
        width: double.infinity,
        color: grey_200,
      ),
    );
  }

  buildMethodReceive(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8,right: 8,top: 10,bottom: 6),
          child: Row(
            children: [
              Icon(MdiIcons.informationOutline,color: mainColor,),
              const SizedBox(width: 10,),
              const Text('Thông tin khách hàng',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8,right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Thông tin chi tiết:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
              buildInfoCallOtherPeople(),
            ],
          ),
        ),
      ],
    );
  }

  buildInfoCallOtherPeople(){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(10),
              height: 40,
              width: double.infinity,
              color: Colors.amber.withOpacity(0.4),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Thông tin khách hàng',style: TextStyle(color: Colors.black,fontSize: 13),),
              ),
            ),
            const SizedBox(height: 22,),
            GestureDetector(
              onTap:(){
                PersistentNavBarNavigator.pushNewScreen(context, screen: SearchCustomerScreen(selected: true,allowCustomerSearch: false, inputQuantity: false,),withNavBar: false).then((value){
                  if(value != null){
                    ManagerCustomerResponseData infoCustomer = value;
                    _bloc.add(PickInfoCustomer(customerName: infoCustomer.customerName,phone: infoCustomer.phone,address: infoCustomer.address,codeCustomer: infoCustomer.customerCode));
                  }
                });
              },
              child: Stack(
                children: [
                  inputWidget(title:'Tên khách hàng',hideText: "Nguyễn Văn A",controller: nameCustomerController,focusNode: nameCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
              const Positioned(
                      top: 20,right: 10,
                      child: Icon(Icons.search_outlined,color: Colors.grey,size: 20,) )
                ],
              ),
            ),
            inputWidget(title:"SĐT khách hàng",hideText: '0963 xxx xxx ',controller: phoneCustomerController,focusNode: phoneCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true),
            GestureDetector(
              onTap:(){
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      // ignore: unnecessary_null_comparison
                      return InputAddressPopup(note: addressCustomerController.text != null ? addressCustomerController.text.toString() : "",title: 'Địa chỉ KH',desc: 'Vui lòng nhập địa chỉ KH',convertMoney: false, inputNumber: false,);
                    }).then((note){
                  if(note != null){
                    setState(() {
                      addressCustomerController.text = note;
                    });
                  }
                });
              },
              child: Stack(
                children: [
                  inputWidget(title:'Địa chỉ khách hàng',hideText: "Vui lòng nhập địa chỉ KH",controller: addressCustomerController,focusNode: addressCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
                  const Positioned(
                      top: 20,right: 10,
                      child: Icon(Icons.edit,color: Colors.grey,size: 20,))
                ],
              ),
            ),
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
            onTap: ()=> Navigator.pop(context,),
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
                "Tạo phiếu CSKH",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.event,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  Widget inputWidget1({String? title,String? hideText,IconData? iconPrefix,IconData? iconSuffix, bool? isEnable,
    TextEditingController? controller,Function? onTapSuffix, Function? onSubmitted,FocusNode? focusNode,
    TextInputAction? textInputAction,bool inputNumber = false,bool isPhone = false,bool note = false,
    bool isPassWord = false, bool cod = true,int? maxLength, bool customContainer = false, bool isMultiline = false
  }){
    return Padding(
      padding: EdgeInsets.only(top: 10,left: 10,right: 10,bottom: customContainer == true ? 0 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title??'',
                style: const TextStyle(color: Colors.blueGrey,fontSize: 12),
              ),
              Visibility(
                visible: note == true,
                child: const Text(' *',style: TextStyle(color: Colors.red),),
              )
            ],
          ),
          const SizedBox(height: 5,),
          Container(
            // height: customContainer == true ? 60 : 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12)
            ),
            child: TextField(
              minLines: isMultiline == true ? 10 : 1,
              maxLines: null,
              maxLength: maxLength,
              controller: controller!,
              textInputAction: textInputAction!,
              keyboardType: TextInputType.multiline,
              focusNode: focusNode,
              onChanged: (string){},
              onSubmitted: (text)=> onSubmitted,
              style: const TextStyle(
                fontSize: 13,
                color: black,
              ),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: grey, width: 1),),
                  // enabledBorder: const UnderlineInputBorder(
                  //   borderSide: BorderSide(color: grey, width: 1),
                  // ),
                  // focusedBorder: const UnderlineInputBorder(
                  //   borderSide: BorderSide(color: grey, width: 1),
                  // ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 7,horizontal: 5),
                  isDense: true,
                  focusColor: primaryColor,
                  hintText: hideText,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: grey,
                  ),
                  errorStyle: const TextStyle(
                    fontSize: 10,
                    color: red,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputWidget({String? title,String? hideText,IconData? iconPrefix,IconData? iconSuffix, bool? isEnable,
    TextEditingController? controller,Function? onTapSuffix, Function? onSubmitted,FocusNode? focusNode,
    TextInputAction? textInputAction,bool inputNumber = false,bool note = false,bool isPassWord = false,
  }){
    return Padding(
      padding: const EdgeInsets.only(top: 0,left: 10,right: 10,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title??'',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,color: Colors.black),
              ),
              Visibility(
                visible: note == true,
                child: const Text(' *',style: TextStyle(color: Colors.red),),
              )
            ],
          ),
          const SizedBox(height: 5,),
          Container(
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8)
            ),
            child: TextFieldWidget2(
              controller: controller!,
              suffix: iconSuffix,
              textInputAction: textInputAction!,
              isEnable: isEnable ?? true,
              keyboardType: inputNumber == true ? TextInputType.phone : TextInputType.text,
              hintText: hideText,
              focusNode: focusNode,
              onSubmitted: (text)=> onSubmitted,
              isPassword: isPassWord,
              isNull: true,
              color: Colors.blueGrey,

            ),
          ),
        ],
      ),
    );
  }

  buildAttachFileInvoice(){
    return Padding(
      padding: const EdgeInsets.only(top: 10,left: 10,right: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                _bloc.add(GetCameraEvent());
              },
              child: Container(padding: const EdgeInsets.only(left: 10,right: 15,top: 8,bottom: 8),
                height: 40,
                width: double.infinity,
                color: Colors.amber.withOpacity(0.4),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ảnh của bạn',style: TextStyle(color: Colors.black,fontSize: 13),),
                    Icon(Icons.add_a_photo_outlined,size: 20,),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16,),
            _bloc.listFileInvoice.isEmpty ? const SizedBox(height: 100,child: Center(child: Text('Hãy chọn thêm hình của bạn từ thư viện ảnh hoặc camera',style: TextStyle(color: Colors.blueGrey,fontSize: 12),),),) :
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _bloc.listFileInvoice.length,
                    itemBuilder: (context,index){
                      return (start > 1 && waitingLoad == true && _bloc.listFileInvoice.length == (index + 1)) ? const SizedBox(height: 100,width: 80,child: PendingAction()) : GestureDetector(
                        onTap: (){
                          openImageFullScreen(index,_bloc.listFileInvoice[index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: 115,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  child: Hero(
                                    tag: index,
                                    /*semanticContainer: true,
                                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),*/
                                    child: Image.file(
                                      _bloc.listFileInvoice[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,right: 6,
                                child: InkWell(
                                  onTap: (){
                                    setState(() {
                                      _bloc.listFileInvoice.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    height: 20,width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black.withOpacity(.7),
                                    ),
                                    child: const Icon(Icons.clear,color: Colors.white,size: 12,),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // to open gallery image in full screen
  void openImageFullScreen(final int indexOfImage, File fileImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageViewWrapperViewOnly(
          titleGallery: "Zoom Image",
          galleryItemsFile: fileImage,
          viewNetWorkImage: false,
          backgroundDecoration: const BoxDecoration(
            color: Colors.white,
          ),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
