// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:dms/utils/const.dart';
import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:dms/widget/text_field_widget2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../custom_lib/view_only_image.dart';
import '../../../themes/colors.dart';
import '../../../utils/utils.dart';
import '../dms_bloc.dart';
import '../dms_event.dart';
import '../dms_state.dart';
import '../check_in/search_province/search_province_screen.dart';
import '../check_in/search_tour/search_tour_screen.dart';


class RequestOpenStoreDetailScreen extends StatefulWidget {

  final String idRequestOpenStore;

  const RequestOpenStoreDetailScreen({Key? key , required this.idRequestOpenStore}) : super(key: key);

  @override
  _RequestOpenStoreDetailScreenState createState() => _RequestOpenStoreDetailScreenState();
}

class _RequestOpenStoreDetailScreenState extends State<RequestOpenStoreDetailScreen> {

  late DMSBloc _bloc;

  final _addressController = TextEditingController();
  final FocusNode _addressFocus = FocusNode();

  final _nameCustomerController = TextEditingController();
  final FocusNode _nameCustomerFocus = FocusNode();

  final _phoneCustomerController = TextEditingController();
  final FocusNode _phoneCustomerFocus = FocusNode();

  final _phoneCustomer2Controller = TextEditingController();
  final FocusNode _phoneCustomer2Focus = FocusNode();

  final _nameStoreController = TextEditingController();
  final FocusNode _nameStoreFocus = FocusNode();

  final _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  final _descController = TextEditingController();
  final FocusNode _descFocus = FocusNode();

  final _nameTourController = TextEditingController();
  final FocusNode _nameTourFocus = FocusNode();

  final _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  final _mstController = TextEditingController();
  final FocusNode _mstFocus = FocusNode();

  final _birthDayController = TextEditingController();
  final FocusNode _birthDayFocus = FocusNode();

  final _provinceController = TextEditingController();
  String idProvince = '';

  final _districtController = TextEditingController();
  String idDistrict = '';

  final _communeController = TextEditingController();
  String idCommune = '';

  final _areaController = TextEditingController();
  String idArea = '';

  final _typeStoreController = TextEditingController();
  String idTypeStore = '';

  final _storeFormController = TextEditingController();
  String idStoreForm = '';

  String idTour ='';

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
    _bloc = DMSBloc(context);
    _bloc.add(GetPrefsDMSEvent());
  }

  final imagePicker = ImagePicker();

  Future getImage()async {
    // final image = await imagePicker.pickImage(source: ImageSource.camera,imageQuality: 45);
    PersistentNavBarNavigator.pushNewScreen(context, screen: const CameraCustomUI()).then((value){
      if(value != null){
        XFile image = value;
        setState(() {
          if(image != null){
            start = 2;waitingLoad  = true;
            startTimer();
            _bloc.listFileInvoice.add(File(image.path));
          }
        });
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: subColor,
        onPressed: ()async{
          if(_nameStoreController.text.isNotEmpty &&
              _nameCustomerController.text.isNotEmpty &&
              _addressController.text.isNotEmpty &&
              idArea.isNotEmpty &&
              idTypeStore.isNotEmpty &&
              idStoreForm.isNotEmpty && idProvince.isNotEmpty && idDistrict.isNotEmpty && idCommune.isNotEmpty
              && (Const.chooseStateWhenCreateNewOpenStore == true ? idState.isNotEmpty : idCommune.isNotEmpty)
          ){
            _bloc.add(UpdateRequestOpenStoreEvent(
              idRequestOpenStore: widget.idRequestOpenStore,
              nameCustomer: _nameCustomerController.text,
              phoneCustomer: _phoneCustomerController.text,
              email:_emailController.text,
              address: _addressController.text,
              note: _noteController.text,
              idTour: idTour,
              nameStore: _nameStoreController.text,
              mst:_mstController.text,
              desc:_descController.text,
              phoneStore:_phoneCustomer2Controller.text,
              idProvince:idProvince,
              idDistrict:idDistrict,
              idCommune:idCommune,
              gps:"",
              idArea:idArea,
              idTypeStore:idTypeStore,
              idStoreForm:idStoreForm,
              birthDay: _birthDayController.text,
              idState: idState
            ));
          }else{
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vui lòng nhập đầy đủ nội dung');
          }
        },
        child: const Icon(Icons.system_update,color: Colors.white,),
      ),
      body: BlocListener<DMSBloc,DMSState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetDetailOpenStoreEvent(widget.idRequestOpenStore));
          }
          else if(state is GrantCameraPermission){
            getImage();
          }else if(state is UpdateNewRequestOpenStoreSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Cập nhật yêu cầu thành công');
            Navigator.pop(context,'RELOAD');
          }else if(state is CancelRequestOpenStoreSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Xoá yêu cầu thành công');
            Navigator.pop(context,'RELOAD');
          }
          else if (state is GetDetailRequestOpenStoreSuccess){
          _nameCustomerController.text = _bloc.detailRequestOpenStore.nguoiLh.toString();
          _phoneCustomerController.text = _bloc.detailRequestOpenStore.dienThoaiDd.toString();
          _emailController.text = _bloc.detailRequestOpenStore.email.toString();
           _addressController.text = _bloc.detailRequestOpenStore.diaChi.toString();
           _noteController.text = _bloc.detailRequestOpenStore.ghiChu.toString();
          _nameTourController.text  = _bloc.detailRequestOpenStore.tenTuyen.toString();
           idTour = _bloc.detailRequestOpenStore.maTuyen.toString();
           _nameStoreController.text = _bloc.detailRequestOpenStore.hoTen.toString();
          _mstController.text = _bloc.detailRequestOpenStore.maSoThue.toString();
          _descController.text = _bloc.detailRequestOpenStore.moTa.toString();
          _phoneCustomer2Controller.text = _bloc.detailRequestOpenStore.dienThoai.toString();
          _provinceController.text = _bloc.detailRequestOpenStore.tenTinh.toString();
          idProvince = _bloc.detailRequestOpenStore.tinhThanh.toString();
          _districtController.text  = _bloc.detailRequestOpenStore.tenQuan.toString();
          idDistrict = _bloc.detailRequestOpenStore.quanHuyen.toString();
          _communeController.text =  _bloc.detailRequestOpenStore.tenPhuong.toString();
          idCommune = _bloc.detailRequestOpenStore.xaPhuong.toString();
          _areaController.text  = _bloc.detailRequestOpenStore.tenKhuVuc.toString();
          idArea = _bloc.detailRequestOpenStore.khuVuc.toString();
          _typeStoreController.text  = _bloc.detailRequestOpenStore.tenLoai.toString();
          idTypeStore = _bloc.detailRequestOpenStore.phanLoai.toString();
          _storeFormController.text  = _bloc.detailRequestOpenStore.tenHinhThuc.toString();
          idStoreForm = _bloc.detailRequestOpenStore.hinhThuc.toString();
           _birthDayController.text = _bloc.detailRequestOpenStore.ngaySinh.toString().isNotEmpty ? Utils.parseDateTToString(_bloc.detailRequestOpenStore.ngaySinh.toString(), Const.DATE_TIME_FORMAT) : '' ;
           idState = _bloc.detailRequestOpenStore.idState.toString();
          _nameStateController.text = _bloc.detailRequestOpenStore.nameState.toString();
          }
        },
        child: BlocBuilder<DMSBloc,DMSState>(
          bloc: _bloc,
          builder: (BuildContext context, DMSState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is DMSLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,DMSState state){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildAppBar(),
        const SizedBox(height: 10,),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                  child: Text('Thông tin người đề xuất',style: TextStyle(color: subColor,fontWeight: FontWeight.bold),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,bottom: 10,right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_bloc.detailRequestOpenStore.tenNvbh??'Đang cập nhật',style: const TextStyle(color: Colors.black,fontSize: 12),),
                      Text(_bloc.detailRequestOpenStore.maNvbh??'Đang cập nhật',style: const TextStyle(color: Colors.grey,fontSize: 12),),
                    ],
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                  child: Text('Thông tin khách hàng',style: TextStyle(color: subColor,fontWeight: FontWeight.bold),),
                ),
                inputWidget(title: "Tên người liên hệ",hideText: 'Tên khách hàng',controller: _nameCustomerController,focusNode: _nameCustomerFocus,
                  textInputAction: TextInputAction.next, onTapSuffix: (){},note: true,isNull: true,colors:  Colors.grey,
                  onSubmitted: ()=>Utils.navigateNextFocusChange(context,  _nameCustomerFocus, _phoneCustomerFocus),),
                inputWidget(title: "SĐT người liên hệ",hideText: 'Số điện thoại',controller: _phoneCustomerController,focusNode: _phoneCustomerFocus,enableMaxLine: true,
                    textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,inputNumber: true,isPhone: true,maxLength: 10,customContainer: true,isNull: true,colors:  Colors.grey,
                    onSubmitted: ()=>{}),

                GestureDetector(
                    onTap: (){
                      FocusScope.of(context).requestFocus(FocusNode());
                      Utils.dateTimePickerCustom(context).then((value){
                        if(value != null){
                          setState(() {
                            _birthDayController.text = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                          });
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0,left: 10,right: 10,bottom:  10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ngày sinh',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12,color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12)
                            ),
                            child: Stack(
                              children: [
                                const Positioned(
                                    right: 6,top: 0,
                                    child: Icon(Icons.arrow_drop_down_outlined,size: 20,color: Colors.black,)
                                ),
                                TextFieldWidget2(
                                  controller: _birthDayController,
                                  isEnable: false,
                                  keyboardType: TextInputType.text,
                                  hintText: '1995/03/04',
                                  isNull: true,
                                  color: Colors.grey,
                                  focusNode: _birthDayFocus,
                                  onChanged: (string){},
                                  isPassword: false,
                                  inputFormatter:  [FilteringTextInputFormatter.digitsOnly],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                ),

                inputWidget(title: "Tên cửa hàng",hideText: 'Tên cửa hàng',controller: _nameStoreController,focusNode: _nameStoreFocus,
                  textInputAction: TextInputAction.next, onTapSuffix: (){},note: true,isNull: true,colors:  Colors.grey,
                  onSubmitted: ()=>Utils.navigateNextFocusChange(context, _nameStoreFocus, _phoneCustomer2Focus),),

                inputWidget(title: "SĐT cửa hàng",hideText: 'Số điện thoại',controller: _phoneCustomer2Controller,focusNode: _phoneCustomer2Focus,enableMaxLine: true,
                    textInputAction: TextInputAction.next, onTapSuffix: (){},note: true,inputNumber: true,isPhone: true,maxLength: 10,customContainer: true,isNull: true,colors:  Colors.grey,
                    onSubmitted: ()=>Utils.navigateNextFocusChange(context, _phoneCustomer2Focus, _addressFocus)),

                inputWidget(title: "Địa chỉ",hideText: 'Địa chỉ',controller: _addressController,focusNode: _addressFocus,
                  textInputAction: TextInputAction.next, onTapSuffix: (){},note: true,isNull: true,colors:  Colors.grey,
                  onSubmitted: ()=>Utils.navigateNextFocusChange(context,  _addressFocus, _emailFocus),),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                          onTap: (){
                            FocusScope.of(context).unfocus();
                            PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProvinceScreen(idArea: idArea.toString(),
                              idProvince: '',idDistrict: '',title:'Danh sách Khu vực',typeGetList: 1,
                            ),withNavBar: false).then((value){
                              if(value[0] == 'Yeah'){
                                idArea = value[1].toString().trim();
                                _areaController.text = value[2].toString().trim();
                              }
                              setState(() {});
                            });
                          },
                          child: inputWidget(title: "Chọn Khu vực",hideText: 'Vui lòng chọn khu vực',controller: _areaController,
                            textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false,iconPrefix: Icons.search_outlined,isNull: true,colors:  Colors.grey,
                            onSubmitted: ()=>null,)
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                          onTap: (){
                            FocusScope.of(context).unfocus();
                            PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProvinceScreen( idArea: idArea.toString(),
                              idProvince: '',idDistrict: '',title:'Danh sách Tỉnh thành',typeGetList: 0,
                            ),withNavBar: false).then((value){
                              if(value[0] == 'Yeah'){
                                idProvince = value[1].toString().trim();
                                _provinceController.text = value[2].toString().trim();
                              }
                              setState(() {});
                            });
                          },
                          child: inputWidget(title: "Chọn Tỉnh/Thành",hideText: 'Vui lòng chọn tỉnh/thành',controller: _provinceController,
                            textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false,iconPrefix: Icons.search_outlined,isNull: true,colors:  Colors.grey,
                            onSubmitted: ()=>null,)
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                          onTap: (){
                            FocusScope.of(context).unfocus();
                            if(idProvince.isNotEmpty){
                              PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProvinceScreen( idArea: idArea.toString(),
                                idProvince: idProvince,idDistrict: '',title:'Danh sách Quận huyện',typeGetList: 0,
                              ),withNavBar: false).then((value){
                                if(value[0] == 'Yeah'){
                                  idDistrict = value[1].toString().trim();
                                  _districtController.text = value[2].toString().trim();
                                }
                                setState(() {});
                              });
                            }else{
                              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Vui lòng chọn Tỉnh/Thành trước');
                            }
                          },
                          child: inputWidget(title: "Chọn Quận/Huyện",hideText: 'Vui lòng chọn Quân/Huyện',controller: _districtController,
                            textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false,iconPrefix: Icons.search_outlined,isNull: true,colors:  Colors.grey,
                            onSubmitted: ()=>null,)
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                          onTap: (){
                            if(idDistrict.isNotEmpty){
                              PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProvinceScreen( idArea: idArea.toString(),
                                idProvince: idProvince,idDistrict: idDistrict,title:'Danh sách Xã phường',typeGetList: 0,
                              ),withNavBar: false).then((value){
                                if(value[0] == 'Yeah'){
                                  idCommune = value[1].toString().trim();
                                  _communeController.text = value[2].toString().trim();
                                }
                                setState(() {});
                              });
                            }else{
                              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Vui lòng chọn Quân/Huyện trước');
                            }
                          },
                          child: inputWidget(title: "Chọn Xã/Phường",hideText: 'Vui lòng chọn Xã/Phường',controller: _communeController,
                            textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false,iconPrefix: Icons.search_outlined,isNull: true,colors:  Colors.grey,
                            onSubmitted: ()=>null,)
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                          onTap: (){
                            FocusScope.of(context).unfocus();
                            PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProvinceScreen( idArea: idArea.toString(),
                              idProvince: idProvince,idDistrict: '',title:'Danh sách Phân loại',typeGetList: 3,
                            ),withNavBar: false).then((value){
                              if(value[0] == 'Yeah'){
                                idTypeStore = value[1].toString().trim();
                                _typeStoreController.text = value[2].toString().trim();
                              }
                              setState(() {});
                            });
                          },
                          child: inputWidget(title: "Chọn Phân loại",hideText: 'Vui lòng chọn phân loại',controller: _typeStoreController,
                            textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false,iconPrefix: Icons.search_outlined,isNull: true,colors:  Colors.grey,
                            onSubmitted: ()=>null,)
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                          onTap: (){
                            FocusScope.of(context).unfocus();
                            PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProvinceScreen(idArea: idArea.toString(),
                              idProvince: idProvince,idDistrict: idDistrict,title:'Danh sách Hình thức',typeGetList: 2,
                            ),withNavBar: false).then((value){
                              if(value[0] == 'Yeah'){
                                idStoreForm = value[1].toString().trim();
                                _storeFormController.text = value[2].toString().trim();
                              }
                              setState(() {});
                            });
                          },
                          child: inputWidget(title: "Chọn Hình thức",hideText: 'Vui lòng chọn hình thức',controller: _storeFormController,
                            textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false,iconPrefix: Icons.search_outlined,isNull: true,colors:  Colors.grey,
                            onSubmitted: ()=>null,)
                      ),
                    ),
                  ],
                ),
                inputWidget(title: "Email",hideText: 'Email',controller: _emailController,focusNode: _emailFocus,
                  textInputAction: TextInputAction.next, onTapSuffix: (){},note: false,isNull: true,colors:  Colors.grey,
                  onSubmitted: ()=>Utils.navigateNextFocusChange(context,  _emailFocus, _mstFocus),),

                inputWidget(title: "Mã số thuế",hideText: 'Mã số thuế',controller: _mstController,focusNode: _mstFocus,
                  textInputAction: TextInputAction.next, onTapSuffix: (){},note: false,isNull: true,colors:  Colors.grey,
                  onSubmitted: ()=>Utils.navigateNextFocusChange(context,  _mstFocus, _noteFocus),),

                inputWidget(title: "Ghi chú",hideText: 'Vui lòng nhập ghi chú nếu có',controller: _noteController,focusNode: _noteFocus,
                  textInputAction: TextInputAction.done, onTapSuffix: (){},note: false,isNull: true,colors:  Colors.grey,
                  onSubmitted: ()=>Utils.navigateNextFocusChange(context,  _noteFocus, _descFocus),),

                inputWidget(title: "Mô tả",hideText: 'Vui lòng nhập ghi chú nếu có',controller: _descController,focusNode: _descFocus,
                  textInputAction: TextInputAction.done, onTapSuffix: (){},note: false,isNull: true,colors:  Colors.grey,
                  onSubmitted: ()=>null,),

                InkWell(
                    onTap: (){
                      FocusScope.of(context).unfocus();
                      PersistentNavBarNavigator.pushNewScreen(context, screen: const SearchTourScreen(
                        idTour: '', idState: '',
                        title: 'Tìm kiếm Tour/Tuyến', isTour: true,
                      ),withNavBar: false).then((value){
                        if(value != null && value[0] == 'Yeah'){
                          idTour = value[1].toString().trim();
                          _nameTourController.text = value[2].toString().trim();
                        }
                        setState(() {});
                      });
                    },
                    child: inputWidget(title: "Chọn Tour/Tuyến",hideText: 'Vui lòng chọn Tour',controller: _nameTourController,focusNode: _nameTourFocus,
                      textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false,iconPrefix: Icons.search_outlined,isNull: true,colors:  Colors.grey,
                      onSubmitted: ()=>null,)
                ),
                Visibility(
                  visible: Const.chooseStateWhenCreateNewOpenStore == true,
                  child: InkWell(
                      onTap: (){
                        FocusScope.of(context).unfocus();
                        PersistentNavBarNavigator.pushNewScreen(context, screen:  const SearchTourScreen(
                          idState: '',
                          title: 'Tìm kiếm Trạng thái', idTour: '', isTour: false,
                        ),withNavBar: false).then((value){
                          if(value != null && value[0] == 'Yeah'){
                            idState = value[1].toString().trim();
                            _nameStateController.text = value[2].toString().trim();
                          }
                          setState(() {});
                        });
                      },
                      child: inputWidget(title: "Chọn Trạng thái",hideText: 'Vui lòng chọn Trạng thái',controller: _nameStateController,focusNode: _nameStateFocus,
                        textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false,iconPrefix: Icons.search_outlined,isNull: true,colors:  Colors.grey,
                        onSubmitted: ()=>null,)
                  ),
                ),

                buildAttachFileInvoice()
              ],
            ),
          ),
        )
      ],
    );
  }

  String idState ='';
  final _nameStateController = TextEditingController();
  final FocusNode _nameStateFocus = FocusNode();


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
                "Chi tiết Yêu cầu",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              if(_bloc.userRoles >= _bloc.leadRoles){
                checkOut();
              }
            },
            child: SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.delete_forever_outlined,
                size: 25,
                color: (_bloc.userRoles >= _bloc.leadRoles) == true ?  Colors.white : Colors.transparent,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget inputWidget({String? title,String? hideText,IconData? iconPrefix,IconData? iconSuffix, bool? isEnable,
    TextEditingController? controller,Function? onTapSuffix, Function? onSubmitted,FocusNode? focusNode,bool? isNull,Color? colors,bool? enableMaxLine,
    TextInputAction? textInputAction,bool inputNumber = false,bool isPhone = false,bool note = false,bool isPassWord = false, bool cod = true,int? maxLength, bool customContainer = false,}){
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
            height: customContainer == true ? 60 : 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12)
            ),
            child: TextFieldWidget2(
              controller: controller!,
              suffix: iconSuffix,
              textInputAction: textInputAction!,
              isEnable: isEnable ?? true,
              keyboardType: inputNumber == true ? TextInputType.phone : TextInputType.text,
              hintText: hideText,
              isNull: isNull,
              color: colors,
              enableMaxLine: enableMaxLine,
              focusNode: focusNode,
              onChanged: (string){},
              onSubmitted: (text)=> onSubmitted,
              isPassword: isPassWord,
              inputFormatter: customContainer == true ? [FilteringTextInputFormatter.digitsOnly]: [],
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

  void checkOut(){
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: const CustomQuestionComponent(
              showTwoButton: true,
              iconData: Icons.delete_forever_outlined,
              title: 'Bạn chuẩn bị xoá Yêu cầu',
              content: 'Hãy chắc chắn bạn muốn điều này xảy ra?',
            ),
          );
        }).then((value)async{
      if(value != null){
        if(!Utils.isEmpty(value) && value == 'Yeah'){
          _bloc.add(CancelOpenStoreEvent(widget.idRequestOpenStore,idTour));
        }
      }
    });
  }
}
