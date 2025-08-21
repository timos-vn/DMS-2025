import 'dart:async';
import 'dart:io';

import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../custom_lib/view_only_image.dart';
import '../../../../driver_transfer/helper/location_service.dart';
import '../../../../model/network/response/time_keeping_data_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../time_keeping_bloc.dart';
import '../time_keeping_event.dart';
import '../time_keeping_state.dart';

class MoveScreen extends StatefulWidget {
  const MoveScreen({key});

  @override
  State<MoveScreen> createState() => _MoveScreenState();
}

class _MoveScreenState extends State<MoveScreen> {

  late TimeKeepingBloc _bloc;

  String timeIn = '';
  String timeOut = '';
  String reason = '';
  String description = '';
  late LatLng current;

  final _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = TimeKeepingBloc(context);
    _bloc.add(GetPrefsTimeKeeping());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimeKeepingBloc,TimeKeepingState>(
      bloc: _bloc,
      listener: (context, state){
        if(state is GetPrefsSuccess){

        }
        else if(state is TimeKeepingError){
          showDialog(
              context: context,
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: const CustomQuestionComponent(
                    showTwoButton: false,
                    iconData: Icons.wifi_off,
                    title: 'No Internet',
                    content: 'Vui lòng kiểm tra mạng Wifi của bạn',
                  ),
                );
              });
        }
        else if(state is TimeKeepingDataSuccess){
          if(_bloc.listDataTimeKeeping.any((element) => Utils.parseDateTToString(element.dateTime.toString(), Const.DATE_SV_FORMAT_2) == Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2)) == true){
            if( _bloc.listDataTimeKeeping.isNotEmpty){
              ListTimeKeepingHistory item = _bloc.listDataTimeKeeping.firstWhere((element) => Utils.parseDateTToString(element.dateTime.toString(), Const.DATE_SV_FORMAT_2) == Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2));
              if(item.id != null){
                timeIn = item.timeIn.toString().trim();
                timeOut = item.timeOut.toString().trim();
                reason = item.reason.toString().trim();
                description = item.description.toString().trim();
              }
            }
          }
        }
        else if(state is TimeKeepingSuccess){
          Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Đã ghi nhận thời gian chấm công 😘');
          Navigator.pop(context,['Yeah']);
          // _bloc.add(ListDataTimeKeepingFromUserEvent(datetime: DateTime.now().toString()));
        }
        else if(state is TimeKeepingFailure){
          Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error);
        }
        else if(state is CheckWifiSuccess){
          if(_bloc.publicIP.toString().replaceAll('null', '').trim() == _bloc.master.ipSettup.toString().replaceAll('null', '').trim()){
            _bloc.add(TimeKeepingFromUserEvent(datetime:  DateTime.now().toString(),qrCode:  '0',uId:  Const.uId, desc: '', isWifi: true, isMeetCustomer: true, isUserVIP: false));
          }
          else{
            Utils.showCustomToast(context, Icons.warning_amber, 'Úi, hãy đổi sang Wifi của CTY nhé 😘');
          }
        }
      },
      child: BlocBuilder<TimeKeepingBloc,TimeKeepingState>(
        bloc: _bloc,
        builder: (BuildContext context, TimeKeepingState state){
          return Stack(
            children: [
              buildBody(context, state),
              Visibility(
                visible: state is TimeKeepingLoading,
                child: const PendingAction(),
              )
            ],
          );
        },
      ),
    );
  }



  buildBody(BuildContext context, TimeKeepingState state){
    return Scaffold(
      body: Column(
        children: [
          buildAppBar(),
          Expanded(child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Vị trí: ${_bloc.currentAddress}',style: TextStyle(color: Colors.black,fontSize: 13),),
                ),
                buildAttachFileInvoice(),
                const SizedBox(height: 10,),
                Text('Mô tả công việc',style: TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.bold),),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 11),
                  width: double.infinity,
                  child:
                  TextFormField(
                    maxLines: 4,
                    controller: _noteController,
                    focusNode: _noteFocus,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Hãy ghi lại điều gì đó của bạn vào đây',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),

                ),
              ],
            ),
          )),
          GestureDetector(
            onTap: ()=>_bloc.add(TimeKeepingFromUserEvent(datetime:  DateTime.now().toString(),qrCode:  '0',uId:  Const.uId, desc: '', isWifi: false, isMeetCustomer: true, isUserVIP: false)),
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(vertical: 10),
              margin:  const EdgeInsets.symmetric(horizontal: 10,vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
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
                      colors: [Color(0xfffbb448), Color(0xfff7892b)])),
              child: const Text( 'Xác nhận' ,
                style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
              ),
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
            onTap: ()=> Navigator.pop(context),
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
          Expanded(
            child: Center(
              child: Text(
                'Đi công tác',
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
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

  Future getImage()async {
    PersistentNavBarNavigator.pushNewScreen(context, screen: const CameraCustomUI()).then((value){
      if(value != null){
        XFile image = value;
        setState(() {
          if(image != null){
            start = 2;waitingLoad  = true;
            startTimer();
            _bloc.listFileImage.add(File(image.path));
            // ListImageInvoice itemImage = ListImageInvoice(
            //     pathBase64: Utils.base64Image(File(image.path)).toString(),
            //     nameImage: image.name
            // );
            // _bloc.listFileInvoiceSave.add(itemImage);
          }
          if(_bloc.currentAddress.toString().isEmpty){
            init();
          }
        });
      }
    });
  }

  void init()async{
    location.getLocation().then((onValue)async{
      current = LatLng(onValue.latitude!, onValue.longitude!);
      List<Placemark> placePoint = await placemarkFromCoordinates(onValue.latitude!, onValue.longitude!);
      String currentAddress1 = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
      _bloc.lat = onValue.latitude!.toString();
      _bloc.long = onValue.longitude!.toString();
      _bloc.currentAddress = currentAddress1;
      setState(()=>print('New: ${_bloc.currentAddress}'));
    });
  }

  buildAttachFileInvoice(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                getImage();
                // _bloc.add(GetCameraEvent());
              },
              child: Container(padding: const EdgeInsets.only(left: 10,right: 15,top: 8,bottom: 8),
                height: 40,
                width: double.infinity,
                color: Colors.amber.withOpacity(0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Ảnh của bạn',style: TextStyle(color: Colors.black,fontSize: 13),),
                    Icon(Icons.add_a_photo_outlined,size: 20,),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16,),
            // GalleryImage(imageUrls: [],),
            _bloc.listFileImage.isEmpty ? const SizedBox(height: 100,width: double.infinity,child: Center(child: Text('Hãy chọn thêm hình ảnh của bạn từ thư viện ảnh hoặc từ camera',style: TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),),) :
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _bloc.listFileImage.length,
                    itemBuilder: (context,index){
                      return (start > 1 && waitingLoad == true && _bloc.listFileImage.length == (index + 1)) ? const SizedBox(height: 100,width: 80,child: PendingAction()) : GestureDetector(
                        onTap: (){
                          openImageFullScreen(index,_bloc.listFileImage[index]);
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
                                      _bloc.listFileImage[index],
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
                                      _bloc.listFileImage.removeAt(index);
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
            color: Colors.black,
          ),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
