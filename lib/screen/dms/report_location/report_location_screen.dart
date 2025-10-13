// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:dms/screen/customer/search_customer/search_customer_screen.dart';
import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../custom_lib/view_only_image.dart';
import '../../../model/network/response/manager_customer_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import 'report_location_bloc.dart';
import 'report_location_event.dart';
import 'report_location_sate.dart';

class ReportLocationScreen extends StatefulWidget {

  const ReportLocationScreen({Key? key}) : super(key: key);
  @override
  _ReportLocationScreenState createState() => _ReportLocationScreenState();
}

class _ReportLocationScreenState extends State<ReportLocationScreen> {

  late ReportLocationBloc _bloc;
  File? _fileImage;
  String? namePath;
  String? nameFile;

  String? day,time;
  String? codeCustomer,nameCustomer,phoneCustomer;

  final TextEditingController _noteController = TextEditingController();
  FocusNode _noteFocus = FocusNode();

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

  final imagePicker = ImagePicker();

  Future getImage()async {
    //final image = await imagePicker.pickImage(source: ImageSource.camera,imageQuality: 65);
    PersistentNavBarNavigator.pushNewScreen(context, screen: const CameraCustomUI()).then((value){
      if(value != null){
        XFile image = value;
        setState(() {
          if(image != null){
            start = 2;waitingLoad  = true;
            startTimer();
            _bloc.listFileInvoice.add(File(image.path));
          }
          if(_bloc.currentAddress.toString().replaceAll('null', '').isNotEmpty && _bloc.time.toString().replaceAll('null', '').isNotEmpty){
            _bloc.add(GetLocationEvent());
          }
        });
      }
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = ReportLocationBloc(context);
    _bloc.add(GetReportLocationPrefs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 249, 1),
      body: BlocListener<ReportLocationBloc,ReportLocationState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetLocationEvent());
          }
          if(state is GetUserInfoSuccess){
            codeCustomer = _bloc.codeCustomer;
            nameCustomer = _bloc.nameCustomer;
            phoneCustomer = _bloc.phoneCustomer;
          }
          else if(state is GrantCameraPermission){
            getImage();
          }
          if(state is GetImageSuccess){

          }
          if (state is EmployeeScanFailure) {
            _bloc.add(RefreshEvent());
          }
          if(state is ReportLocationSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Cập nhật dữ liệu thành công');
            Navigator.pop(context);
          }
          if(state is ReportLocationFailure){
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error);
          }
        },
        child: BlocBuilder<ReportLocationBloc,ReportLocationState>(
          bloc: _bloc,
          builder: (BuildContext context,ReportLocationState state){
            return buildPageMeetingCustomer(context, state);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: subColor,
        onPressed: () {
          _noteFocus.unfocus();
          
          // Kiểm tra điều kiện có cần chọn khách hàng không
          final bool needCustomerSelection = Const.reportLocationNoChooseCustomer != true;
          
          // Nếu cần chọn KH và chưa chọn -> hiển thị thông báo
          if (needCustomerSelection && _bloc.codeCustomer == null) {
            _showValidationDialog(
              'Thiếu thông tin',
              'Vui lòng chọn thông tin khách hàng để tiếp tục.'
            );
            return;
          }
          
          // Validate Nội dung
          if (_noteController.text.trim().isEmpty) {
            _showValidationDialog(
              'Thiếu nội dung',
              'Vui lòng nhập nội dung báo cáo để tiếp tục.'
            );
            return;
          }
          
          // Validate Image
          if (_bloc.listFileInvoice.isEmpty) {
            _showValidationDialog(
              'Thiếu hình ảnh',
              'Vui lòng chọn ít nhất 1 hình ảnh để tiếp tục.'
            );
            return;
          }
          
          // Thực hiện báo cáo vị trí
          reportLocation();
        },
        child: const Icon(Icons.check,color: Colors.white,),
      ),
    );
  }

  Widget buildPageMeetingCustomer(BuildContext context,ReportLocationState state){
    return Stack(
      children: [
        Column(
          children: [
            buildAppBar(),
            Expanded(child: SingleChildScrollView(
              child: Column(
                children: [
                  buildInfo(context),
                  const SizedBox(height: 15,),
                  inputWidget(title: "Nội dung",hideText: 'Vui lòng nhập nội dung',controller: _noteController,focusNode: _noteFocus,
                    textInputAction: TextInputAction.newline, onTapSuffix: (){},note: true,
                    onSubmitted: ()=>null,),
                  const SizedBox(height: 15,),
                  buildAttachFileInvoice()
                ],
              ),
            ))
          ],
        ),
        Visibility(
          visible: state is ReportLocationLoading,
          child: const PendingAction(),
        ),
      ],
    );
  }

  Widget buildInfo(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 30,right: 30),
              height: 35,
              child: const Center(child: Text('Ngày')),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.top,
              child: SizedBox(
                height: 35,
                // width: 32,
                child: Center(child: Text(DateFormat("dd/MM/yyyy").format(DateTime.now()).toString())),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const SizedBox(
              height: 35,
              child: Center(child: Text('Thời gian')),
            ),
            SizedBox(
              height: 35,
              child: Center(child: Text( _bloc.time?.toString()??'') ,),
            ),
          ],
        ),
        TableRow(
          children: [
            const SizedBox(
              height: 35,
              child: Center(child: Text('Khách hàng')),
            ),
            InkWell(
              onTap:(){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SearchCustomerScreen(selected: true,allowCustomerSearch: false, inputQuantity: false,))).then((value){
                  if(value != null && value != ''){
                    ManagerCustomerResponseData infoCustomer = value;
                    _bloc.add(GetUserInfoEvent(infoCustomer.customerCode.toString(), infoCustomer.customerName.toString(), infoCustomer.phone.toString()));
                  }
                });
              },
              child: SizedBox(
                height: 35,
                child: Row(
                  children: [
                    Expanded(child: Center(child: Text( nameCustomer?.toString()??''))),
                    const Icon(Icons.search,color: Colors.grey,),
                    const SizedBox(width: 10,),
                  ],
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const SizedBox(
              height: 35,
              child: Center(child: Text('Địa chỉ')),
            ),
            SizedBox(
              height: 35,
              child:Center(child: Text( _bloc.currentAddress?.toString()??'',style: const TextStyle(fontSize: 12),textAlign: TextAlign.center,maxLines: 2,overflow: TextOverflow.ellipsis,)) ,
            ),
          ],
        ),
      ],
    );
  }

  Widget inputWidget({String? title,String? hideText,IconData? iconPrefix,IconData? iconSuffix, bool? isEnable,
    TextEditingController? controller,Function? onTapSuffix, Function? onSubmitted,FocusNode? focusNode,
    TextInputAction? textInputAction,bool inputNumber = false,bool isPhone = false,bool note = false,bool isPassWord = false, bool cod = true,int? maxLength, bool customContainer = false}){
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
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12,color: Colors.black),
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
              minLines: 1,
              maxLines: null,
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
          gradient:const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.of(context).pop(),
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
                'Báo cáo vị trí',
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
              Icons.check,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  /// Hiển thị dialog cảnh báo validation
  void _showValidationDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: const Text('Đóng', style: TextStyle(fontSize: 15)),
            ),
          ],
        );
      },
    );
  }

  void reportLocation(){
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CustomQuestionComponent(
              showTwoButton: true,
              iconData: MdiIcons.mapMarkerRadius,
              title: 'Xác nhận báo cáo vị trí?',
              content: 'Hãy chắc chắn bạn muốn điều này?',
            ),
          );
        }).then((value)async{
      if(value != null){
        if(!Utils.isEmpty(value) && value == 'Yeah'){
          _bloc.add(ReportLocationFromUserEvent(
              DateTime.now().toString(),
              codeCustomer.toString(),
              _bloc.currentLocation.toString(),
              _bloc.currentAddress.toString(),
              '',
              _noteController.text,
          ));
        }
      }
    });
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
                _noteFocus.unfocus();
                getImage();
                // _bloc.add(GetCameraEvent());
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