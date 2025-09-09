// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:dms/screen/dms/customer_care/customer_care_bloc.dart';
import 'package:dms/screen/dms/customer_care/customer_care_event.dart';
import 'package:dms/screen/dms/customer_care/customer_care_state.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../custom_lib/view_only_image.dart';
import '../../../model/network/response/manager_customer_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/utils.dart';
import '../../../widget/text_field_widget2.dart';
import '../../customer/search_customer/search_customer_screen.dart';
import '../../sell/component/input_address_popup.dart';

// Import custom components
import 'constants/customer_care_strings.dart';
import 'models/customer_care_form_data.dart';
import 'services/image_service.dart';
import 'utils/customer_care_validator.dart';
import 'widgets/care_type_section.dart';
import 'widgets/custom_input_field.dart';
import 'widgets/custom_submit_button.dart';
import 'widgets/customer_info_section.dart';
import 'widgets/image_attachment_section.dart';
import '../customer_care/survey/customer_survey_screen.dart';


class AddNewCustomerCareScreen extends StatefulWidget {

  final String? idCustomer;

  const AddNewCustomerCareScreen({Key? key, this.idCustomer}) : super(key: key);

  @override
  _AddNewCustomerCareScreenState createState() => _AddNewCustomerCareScreenState();
}

class _AddNewCustomerCareScreenState extends State<AddNewCustomerCareScreen> {

  late CustomerCareBloc _bloc;
  
  // Form data model
  late CustomerCareFormData _formData;
  
  // Controllers
  final noteController = TextEditingController();
  final feedbackController = TextEditingController();
  final nameCustomerController = TextEditingController();
  final addressCustomerController = TextEditingController();
  final phoneCustomerController = TextEditingController();
  
  // Focus nodes
  final noteFocus = FocusNode();
  final feedbackFocus = FocusNode();
  final nameCustomerFocus = FocusNode();
  final addressCustomerFocus = FocusNode();
  final phoneCustomerFocus = FocusNode();

  // Image quality setting
  double percentQuantityImage = 0.65; // 65% quality



  void _updateFormData() {
    _formData = _formData.copyWith(
      customerName: nameCustomerController.text,
      customerPhone: phoneCustomerController.text,
      customerAddress: addressCustomerController.text,
      content: noteController.text,
      feedback: feedbackController.text,
      isPhone: _bloc.isPhone,
      isEmail: _bloc.isEmail,
      isSMS: _bloc.isSMS,
      isMXH: _bloc.isMXH,
      isOther: _bloc.isOther,
      otherCareType: _bloc.noteSell,
      images: _bloc.listFileInvoice,
    );
  }

  void _onCustomerSelected(ManagerCustomerResponseData customer) {
    nameCustomerController.text = customer.customerName ?? '';
    phoneCustomerController.text = customer.phone ?? '';
    addressCustomerController.text = customer.address ?? '';
    _formData = _formData.copyWith(
      customerName: customer.customerName ?? '',
      customerPhone: customer.phone ?? '',
      customerAddress: customer.address ?? '',
      customerCode: customer.customerCode,
    );
    setState(() {});
  }

  void _onAddressChanged(String address) {
    addressCustomerController.text = address;
    _formData = _formData.copyWith(customerAddress: address);
    setState(() {});
  }

  void _onCareTypeChanged(int index) {
    _bloc.add(CheckInTransferEvent(index: index));
    setState(() {});
  }

  void _onOtherNoteChanged(String note) {
    _bloc.add(AddNote(note: note));
    setState(() {});
  }

  void _onImageTap(int index, File file) {
    openImageFullScreen(index, file);
  }

  void _onRemoveImage(int index) {
    setState(() {
      _formData.removeImage(index);
      _bloc.listFileInvoice.removeAt(index);
    });
  }

  void _openCustomerSurvey() {
    if (_formData.customerCode == null || _formData.customerCode!.isEmpty) {
      Utils.showCustomToast(
        context,
        Icons.warning_amber_outlined,
        'Vui lòng chọn khách hàng trước khi thêm khảo sát',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerSurveyScreen(
          sttRec: '',
          customerName: _formData.customerName ?? 'Khách hàng', customerId: _formData.customerCode.toString(),
        ),
      ),
    ).then((result) {
      if (result == 'SUCCESS') {
        Utils.showCustomToast(
          context,
          Icons.check_circle_outline,
          'Khảo sát đã được thêm thành công!',
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc = CustomerCareBloc(context);
    _formData = CustomerCareFormData();
    _bloc.add(GetPrefsCustomerCareEvent());
  }

  Future<void> getImage(bool isCamera) async {
    final File? image = await ImageService.pickImage(
      isCamera: isCamera,
      percentQuantityImage: _formData.percentQuantityImage,
    );
    if (image != null) {
      setState(() {
        _formData.addImage(image);
        _bloc.listFileInvoice.add(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: BlocListener<CustomerCareBloc,CustomerCareState>(
              bloc: _bloc,
              listener: (context,state){
                if(state is GetPrefsCustomerCareSuccess){

                }
                else if(state is PickInfoCustomerSuccess){
                  nameCustomerController.text = _bloc.customerName.toString();
                  phoneCustomerController.text = _bloc.phoneCustomer.toString();
                  addressCustomerController.text = _bloc.addressCustomer.toString();
                  _updateFormData();
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
          ),
          // Bottom Submit Button
          BottomSubmitButton(
            onPressed: () async {
              _updateFormData();
              if (_formData.isValid) {
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
                  },
                ).then((value) {
                  if (!Utils.isEmpty(value) && value == 'Yeah') {
                    _bloc.add(AddNewCustomerCareEvent(
                      typeCare: _formData.careTypesString,
                      idCustomer: _formData.customerCode ?? '',
                      description: _formData.content,
                      feedback: _formData.feedback,
                      otherTypeCare: _formData.otherCareType ?? '',
                    ));
                  }
                });
              } else {
                final errors = _formData.validationErrors;
                final errorMessage = errors.isNotEmpty ? errors.first : 'Vui lòng nhập đầy đủ nội dung';
                Utils.showCustomToast(context, Icons.warning_amber_outlined, errorMessage);
              }
            },
            isLoading: false, // Có thể cập nhật dựa trên state
            isEnabled: true,
            text: 'Tạo phiếu CSKH',
            icon: MdiIcons.plusBoxOutline,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Giảm padding
            buttonHeight: 50, // Giảm chiều cao button
            bottomPadding: 20, // Padding bottom tùy chỉnh
          ),
        ],
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

  Widget buildScreen(BuildContext context, CustomerCareState state) {
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
                    // Customer Info Section
                    CustomerInfoSection(
                      nameCustomerController: nameCustomerController,
                      addressCustomerController: addressCustomerController,
                      phoneCustomerController: phoneCustomerController,
                      nameCustomerFocus: nameCustomerFocus,
                      addressCustomerFocus: addressCustomerFocus,
                      phoneCustomerFocus: phoneCustomerFocus,
                      onCustomerSelected: _onCustomerSelected,
                      onAddressChanged: _onAddressChanged,
                    ),
                    buildLine(),
                    
                    // Care Content Section
                    const Padding(
                      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                      child: Text(
                        CustomerCareStrings.careContentTitle,
                        style: TextStyle(color: subColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    // Care Type Section
                    CareTypeSection(
                      isPhone: _bloc.isPhone,
                      isEmail: _bloc.isEmail,
                      isSMS: _bloc.isSMS,
                      isMXH: _bloc.isMXH,
                      isOther: _bloc.isOther,
                      otherNote: _bloc.noteSell,
                      onCareTypeChanged: _onCareTypeChanged,
                      onOtherNoteChanged: _onOtherNoteChanged,
                    ),
                    
                    // Content Input
                    CustomInputField(
                      title: CustomerCareStrings.contentLabel,
                      hintText: CustomerCareStrings.contentPlaceholder,
                      controller: noteController,
                      focusNode: noteFocus,
                      textInputAction: TextInputAction.newline,
                      isRequired: true,
                      isMultiline: false,
                      maxLength: 100,
                    ),
                    
                    // Feedback Section
                    const Padding(
                      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                      child: Text(
                        CustomerCareStrings.feedbackTitle,
                        style: TextStyle(color: subColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    // Feedback Input
                    CustomInputField(
                      title: CustomerCareStrings.feedbackLabel,
                      hintText: CustomerCareStrings.feedbackPlaceholder,
                      controller: feedbackController,
                      focusNode: feedbackFocus,
                      textInputAction: TextInputAction.newline,
                      isRequired: true,
                      isMultiline: true,
                      maxLength: 1000,
                    ),
                    buildLine(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Khảo sát khách hàng',
                            style: TextStyle(color: subColor, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _openCustomerSurvey(),
                            icon: const Icon(Icons.quiz, size: 18),
                            label: const Text('Thêm khảo sát'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: subColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    buildLine(),
                    // Image Attachment Section
                    ImageAttachmentSection(
                      imageFiles: _bloc.listFileInvoice,
                      isLoading: state is CustomerCareLoading,
                      onAddImage: () => _bloc.add(GetCameraEvent()),
                      onRemoveImage: _onRemoveImage,
                      onImageTap: _onImageTap,
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                CustomerCareStrings.appBarTitle,
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


  // to open gallery image in full screen
  void openImageFullScreen(final int indexOfImage, File fileImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageViewWrapperViewOnly(
          titleGallery: CustomerCareStrings.zoomImageTitle,
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
