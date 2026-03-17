// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/pending_action.dart';

import 'package:flutter/material.dart';
import 'package:dms/screen/menu/component/option_report_filter.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../custom_lib/view_only_image.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../dms_bloc.dart';
import '../dms_event.dart';
import '../dms_state.dart';
import '../check_in/search_province/search_province_screen.dart';
import '../check_in/search_tour/search_tour_screen.dart';

class AddNewRequestOpenStoreScreen extends StatefulWidget {
  final String? idRequestOpenStore;
  final bool isEdit;
  final List<String>? existingImageUrls;
 
  const AddNewRequestOpenStoreScreen({Key? key, this.idRequestOpenStore, this.isEdit = false, this.existingImageUrls}) : super(key: key);

  @override
  _AddNewRequestOpenStoreScreenState createState() => _AddNewRequestOpenStoreScreenState();
}

class _AddNewRequestOpenStoreScreenState extends State<AddNewRequestOpenStoreScreen> {
  late DMSBloc _bloc;
  bool get isEditMode => widget.isEdit && widget.idRequestOpenStore != null;
  final List<String> _existingImageUrls = [];

  // Controllers
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
  final _nameStateController = TextEditingController();
  final _emailController = TextEditingController();
  final _priceGroupController = TextEditingController();
  String _priceGroupCode = '';

  final FocusNode _emailFocus = FocusNode();
  final _mstController = TextEditingController();
  final FocusNode _mstFocus = FocusNode();
  final _birthDayController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _communeController = TextEditingController();
  final _areaController = TextEditingController();
  final _typeStoreController = TextEditingController();
  final _storeFormController = TextEditingController();

  // IDs
  String idProvince = '';
  String idDistrict = '';
  String idCommune = '';
  String idArea = '';
  String idTypeStore = '';
  String idStoreForm = '';
  String idTour = '';
  String idState = '';

  // State variables
  late Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  int start = 3;
  bool waitingLoad = false;

  // Chế độ địa chỉ: false = chế độ cũ (3 cấp), true = chế độ mới (2 cấp theo nghị định 7-2025)
  bool useNewRegulation = false;

  // Cache for step completion status
  final Map<int, bool> _stepCompletionCache = {};

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (start == 0) {
        waitingLoad = false;
        setState(() {});
        timer.cancel();
      } else {
        start--;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();

    // Dispose tất cả controllers
    _addressController.dispose();
    _addressFocus.dispose();
    _nameCustomerController.dispose();
    _nameCustomerFocus.dispose();
    _phoneCustomerController.dispose();
    _phoneCustomerFocus.dispose();
    _phoneCustomer2Controller.dispose();
    _phoneCustomer2Focus.dispose();
    _nameStoreController.dispose();
    _nameStoreFocus.dispose();
    _noteController.dispose();
    _noteFocus.dispose();
    _descController.dispose();
    _descFocus.dispose();
    _nameTourController.dispose();
    _nameStateController.dispose();
    _emailController.dispose();
    _priceGroupController.dispose();
    _emailFocus.dispose();
    _mstController.dispose();
    _mstFocus.dispose();
    _birthDayController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _communeController.dispose();
    _areaController.dispose();
    _typeStoreController.dispose();
    _storeFormController.dispose();

    // Clear cache
    _stepCompletionCache.clear();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc = DMSBloc(context);
    _bloc.add(GetPrefsDMSEvent());
    // Prefill images if passed from list screen
    if (isEditMode && widget.existingImageUrls != null) {
      _existingImageUrls
        ..clear()
        ..addAll(widget.existingImageUrls!);
    }
  }

  final imagePicker = ImagePicker();

  Future getImage() async {
    try {
      var result = await PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const CameraCustomUI()
      );

      if (result != null) {
        XFile image = result;
        setState(() {
          start = 2;
          waitingLoad = true;
          startTimer();
          _bloc.listFileInvoice.add(File(image.path));

          if (_addressController.text.toString().replaceAll('null', '').isEmpty) {
            _addressController.text = _bloc.currentAddress.toString();
          }
          
          // Clear cache để update progress indicator
          _clearStepCompletionCache();
        });
        
        // Auto map address từ GPS sau khi chụp ảnh
        _triggerAutoMapAddress();
      }
    } catch (e) {
      print('Error getting image: $e');
      Utils.showCustomToast(context, Icons.error, 'Không thể chụp ảnh. Vui lòng thử lại.');
    }
  }

  void _triggerAutoMapAddress() {
    // Chỉ auto map nếu chưa có dữ liệu địa chỉ
    if (idProvince.isEmpty && idCommune.isEmpty) {
      // Chế độ mới: không cần kiểm tra District
      if (useNewRegulation || idDistrict.isEmpty) {
        _bloc.add(AutoMapAddressFromGPSEvent(useNewRegulation: useNewRegulation));
      }
    }
  }

  void _showAutoMapErrorDialog(AutoMapAddressError state) {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng bằng cách tap bên ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.errorTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.errorMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              if (state.suggestion != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.suggestion!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đã hiểu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Validation helper
  bool _isFormValid() {
    _clearStepCompletionCache();

    bool customerInfoValid = _nameCustomerController.text.isNotEmpty &&
        _phoneCustomerController.text.isNotEmpty &&
        _phoneCustomerController.text.length == 10; /*&&
        _birthDayController.text.isNotEmpty;*/

    bool hasStoreImage = _bloc.listFileInvoice.isNotEmpty || _existingImageUrls.isNotEmpty || isEditMode;
    bool storeInfoValid = _nameStoreController.text.isNotEmpty &&
        _phoneCustomer2Controller.text.isNotEmpty &&
        _phoneCustomer2Controller.text.length == 10 &&
        hasStoreImage;

    bool locationValid = _addressController.text.isNotEmpty &&
        idArea.isNotEmpty &&
        idProvince.isNotEmpty &&
        idCommune.isNotEmpty &&
        (useNewRegulation ? true : idDistrict.isNotEmpty); // Chế độ mới không cần District

    bool additionalInfoValid = idTour.isNotEmpty &&
        (Const.chooseStateWhenCreateNewOpenStore == true ? idState.isNotEmpty : true);

    return customerInfoValid && storeInfoValid && locationValid && additionalInfoValid;
  }

  void _showValidationError() {
    String errorMessage = 'Vui lòng nhập đầy đủ thông tin bắt buộc:\n';
    List<String> missingFields = [];

    if (_nameCustomerController.text.isEmpty) missingFields.add('• Tên người liên hệ');
    if (_phoneCustomerController.text.isEmpty) missingFields.add('• SĐT người liên hệ');
    if (_phoneCustomerController.text.isNotEmpty && _phoneCustomerController.text.length != 10) {
      missingFields.add('• SĐT người liên hệ phải có 10 chữ số');
    }
  //  if (_birthDayController.text.isEmpty) missingFields.add('• Ngày sinh');
    if (_nameStoreController.text.isEmpty) missingFields.add('• Tên cửa hàng');
    if (_phoneCustomer2Controller.text.isEmpty) missingFields.add('• SĐT cửa hàng');
    if (_phoneCustomer2Controller.text.isNotEmpty && _phoneCustomer2Controller.text.length != 10) {
      missingFields.add('• SĐT cửa hàng phải có 10 chữ số');
    }
    if (_addressController.text.isEmpty) missingFields.add('• Địa chỉ');
    if (idArea.isEmpty) missingFields.add('• Khu vực');
    if (idProvince.isEmpty) missingFields.add('• Tỉnh/Thành');
    if (!useNewRegulation && idDistrict.isEmpty) missingFields.add('• Quận/Huyện');
    if (idCommune.isEmpty) missingFields.add('• Xã/Phường');
    if (idTour.isEmpty) missingFields.add('• Tour/Tuyến');
    if (Const.chooseStateWhenCreateNewOpenStore == true && idState.isEmpty) {
      missingFields.add('• Trạng thái');
    }
    if (!isEditMode && _bloc.listFileInvoice.isEmpty && _existingImageUrls.isEmpty) missingFields.add('• Ảnh cửa hàng');

    errorMessage += missingFields.join('\n');
    Utils.showCustomToast(context, Icons.warning_amber_outlined, errorMessage);
  }

  void _validateAndSubmit() {
    if (_isFormValid()) {
      if (isEditMode) {
        _bloc.add(UpdateRequestOpenStoreEvent(
            idRequestOpenStore: widget.idRequestOpenStore!,
            nameCustomer: _nameCustomerController.text,
            phoneCustomer: _phoneCustomerController.text,
            email: _emailController.text,
            address: _addressController.text,
            note: _noteController.text,
            idTour: idTour,
            nameStore: _nameStoreController.text,
            mst: _mstController.text,
            desc: _descController.text,
            phoneStore: _phoneCustomer2Controller.text,
            idProvince: idProvince,
            idDistrict: idDistrict,
            idCommune: idCommune,
            gps: "",
            idArea: idArea,
            idTypeStore: idTypeStore,
            idStoreForm: idStoreForm,
            birthDay: _birthDayController.text,
            idState: idState,
            nhomGia: _priceGroupCode));
      } else {
        _bloc.add(AddNewRequestOpenStoreEvent(
          nameCustomer: _nameCustomerController.text,
          phoneCustomer: _phoneCustomerController.text,
          email: _emailController.text,
          address: _addressController.text,
          note: _noteController.text,
          idTour: idTour,
          nameStore: _nameStoreController.text,
          mst: _mstController.text,
          desc: _descController.text,
          phoneStore: _phoneCustomer2Controller.text,
          idProvince: idProvince,
          idDistrict: idDistrict,
          idCommune: idCommune,
          gps: "",
          idArea: idArea,
          idTypeStore: idTypeStore,
          idStoreForm: idStoreForm,
          birthDay: _birthDayController.text,
          idState: idState,
          nhomGia: _priceGroupCode,
        ));
      }
    } else {
      _showValidationError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Ẩn bàn phím khi click ra ngoài
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent, // Đảm bảo gesture được detect ngay cả khi có widget con
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: BlocListener<DMSBloc, DMSState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is GetPrefsSuccess) {
            if (isEditMode) {
              _bloc.add(GetDetailOpenStoreEvent(widget.idRequestOpenStore!));
            }
          } else if (state is GrantCameraPermission) {
            _bloc.getUserLocation();
            getImage().then((value) {
              if (_addressController.text.toString().replaceAll('null', '').isEmpty) {
                _addressController.text = _bloc.currentAddress.toString();
              }
            });
          } else if (state is GetDetailRequestOpenStoreSuccess) {
            setState(() {
              _nameCustomerController.text = _bloc.detailRequestOpenStore.nguoiLh.toString();
              _phoneCustomerController.text = _bloc.detailRequestOpenStore.dienThoaiDd.toString();
              _emailController.text = _bloc.detailRequestOpenStore.email.toString();
              _addressController.text = _bloc.detailRequestOpenStore.diaChi.toString();
              _noteController.text = _bloc.detailRequestOpenStore.ghiChu.toString();
              _nameTourController.text = _bloc.detailRequestOpenStore.tenTuyen.toString();
              idTour = _bloc.detailRequestOpenStore.maTuyen.toString();
              _nameStoreController.text = _bloc.detailRequestOpenStore.hoTen.toString();
              _mstController.text = _bloc.detailRequestOpenStore.maSoThue.toString();
              _descController.text = _bloc.detailRequestOpenStore.moTa.toString();
              _phoneCustomer2Controller.text = _bloc.detailRequestOpenStore.dienThoai.toString();
              _provinceController.text = _bloc.detailRequestOpenStore.tenTinh.toString();
              idProvince = _bloc.detailRequestOpenStore.tinhThanh.toString();
              _districtController.text = _bloc.detailRequestOpenStore.tenQuan.toString();
              idDistrict = _bloc.detailRequestOpenStore.quanHuyen.toString();
              _communeController.text = _bloc.detailRequestOpenStore.tenPhuong.toString();
              idCommune = _bloc.detailRequestOpenStore.xaPhuong.toString();
              _areaController.text = _bloc.detailRequestOpenStore.tenKhuVuc.toString();
              idArea = _bloc.detailRequestOpenStore.khuVuc.toString();
              _typeStoreController.text = _bloc.detailRequestOpenStore.tenLoai.toString();
              idTypeStore = _bloc.detailRequestOpenStore.phanLoai.toString();
              _storeFormController.text = _bloc.detailRequestOpenStore.tenHinhThuc.toString();
              idStoreForm = _bloc.detailRequestOpenStore.hinhThuc.toString();
              _priceGroupController.text = _bloc.detailRequestOpenStore.nhomGiaTen?.toString() ?? '';
              _priceGroupCode = _bloc.detailRequestOpenStore.nhomGia?.toString() ?? '';
              _birthDayController.text = _bloc.detailRequestOpenStore.ngaySinh.toString().isNotEmpty
                  ? Utils.parseDateTToString(_bloc.detailRequestOpenStore.ngaySinh.toString(), Const.DATE_TIME_FORMAT)
                  : '';
              idState = _bloc.detailRequestOpenStore.idState.toString();
              _nameStateController.text = _bloc.detailRequestOpenStore.nameState.toString();
              // Lấy danh sách ảnh hiện có (hiển thị dạng network)
              final List<String> mergedUrls = [];
              // Ưu tiên dữ liệu được truyền từ danh sách
              if (widget.existingImageUrls != null && widget.existingImageUrls!.isNotEmpty) {
                mergedUrls.addAll(widget.existingImageUrls!);
              }
              // Nếu danh sách trong bloc có ảnh tương ứng id => gộp
              for (final item in _bloc.listDataRequest) {
                if (item.master?.keyValue.toString() == widget.idRequestOpenStore) {
                  if (item.imageListRequestOpenStore != null) {
                    mergedUrls.addAll(
                      item.imageListRequestOpenStore!
                          .map((e) => (e.pathL ?? '').toString())
                          .where((e) => e.isNotEmpty),
                    );
                  }
                  break;
                }
              }
              _existingImageUrls
                ..clear()
                ..addAll(mergedUrls.toSet()); // unique
              // Nếu Quận/Huyện trống thì chuyển sang chế độ 2 cấp
              if (idDistrict.isEmpty) {
                useNewRegulation = true;
              }
              _clearStepCompletionCache();  
            });
          } else if (state is AutoMapAddressSuccess) {
            // Auto fill các trường địa chỉ
            setState(() {
              idProvince = state.provinceId;
              // Chế độ mới: không cần District
              if (useNewRegulation) {
                idDistrict = ''; // Clear District trong chế độ mới
                _districtController.clear();
              } else {
                idDistrict = state.districtId;
                _districtController.text = state.districtName;
              }
              idCommune = state.communeId;
              _provinceController.text = state.provinceName;
              _communeController.text = state.communeName;
              _addressController.text = _bloc.currentAddress.toString();
              // Clear cache để update progress indicator
              _clearStepCompletionCache();
            });
            
            print('🔄 Progress indicator sẽ được update sau khi auto map address');
            
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã tự động điền địa chỉ từ GPS!');
          } else if (state is AutoMapAddressError) {
            // Hiển thị popup lỗi
            _showAutoMapErrorDialog(state);
          } else if (state is AddNewRequestOpenStoreSuccess) {
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm mới yêu cầu thành công!');
            Navigator.pop(context, 'RELOAD');
          } else if (state is UpdateNewRequestOpenStoreSuccess) {
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật yêu cầu thành công!');
            Navigator.pop(context, 'RELOAD');
          } else if (state is CancelRequestOpenStoreSuccess) {
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Xoá yêu cầu thành công!');
            Navigator.pop(context, 'RELOAD');
          } else if (state is DMSFailure) {
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error);
          }
        },
        child: BlocBuilder<DMSBloc, DMSState>(
          bloc: _bloc,
          builder: (BuildContext context, DMSState state) {
            return Stack(
              children: [
                buildBody(context, state),
                if (state is DMSLoading) const PendingAction(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: subColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isEditMode ? Icons.system_update_alt : Icons.add_business, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isEditMode ? 'Cập nhật yêu cầu' : 'Tạo yêu cầu',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context, DMSState state) {
    return Column(
      children: [
        _buildAppBar(),
        // Force rebuild progress indicator khi state thay đổi
        _buildProgressIndicator(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCustomerInfoSection(),
                const SizedBox(height: 16),
                _buildStoreInfoSection(),
                const SizedBox(height: 16),
                _buildLocationSection(),
                const SizedBox(height: 16),
                _buildAdditionalInfoSection(),
                const SizedBox(height: 16),
                if (_bloc.listFileInvoice.length > 1) _buildAdditionalImagesSection(),
                const SizedBox(height: 100), // Bottom padding for bottom bar
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    const int totalSteps = 4;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(totalSteps, (index) {
          bool isCompleted = _getStepCompletionStatus(index);
          
          // Debug log để kiểm tra
          print('Step $index completed: $isCompleted');

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted ? subColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  bool _getStepCompletionStatus(int step) {
    if (_stepCompletionCache.containsKey(step)) {
      return _stepCompletionCache[step]!;
    }

    bool isCompleted;
    switch (step) {
      case 0: // Customer Info
        isCompleted = _nameCustomerController.text.isNotEmpty &&
            _phoneCustomerController.text.isNotEmpty &&
            _birthDayController.text.isNotEmpty;
        break;
      case 1: // Store Info (including store image)
        isCompleted = _nameStoreController.text.isNotEmpty &&
            _phoneCustomer2Controller.text.isNotEmpty &&
            (_bloc.listFileInvoice.isNotEmpty || isEditMode);
        break;
      case 2: // Location
        isCompleted = idArea.isNotEmpty && idProvince.isNotEmpty &&
            idCommune.isNotEmpty &&
            (useNewRegulation ? true : idDistrict.isNotEmpty); // Chế độ mới không cần District
        break;
      case 3: // Additional
        isCompleted = idTour.isNotEmpty &&
            (Const.chooseStateWhenCreateNewOpenStore == true ? idState.isNotEmpty : true);
        break;
      default:
        isCompleted = false;
    }

    _stepCompletionCache[step] = isCompleted;
    return isCompleted;
  }

  void _clearStepCompletionCache() {
    _stepCompletionCache.clear();
  }

  // Helper functions để xác định màu border dựa trên validation
  Color _getBorderColor(String title, String value) {
    if (title.contains('SĐT') && value.isNotEmpty && value.length != 10) {
      return Colors.red; // Màu đỏ cho số điện thoại không hợp lệ
    }
    return Colors.grey[300]!; // Màu xám mặc định
  }

  double _getBorderWidth(String title, String value) {
    if (title.contains('SĐT') && value.isNotEmpty && value.length != 10) {
      return 2.0; // Border dày hơn cho số điện thoại không hợp lệ
    }
    return 1.0; // Border mặc định
  }

  Widget _buildCustomerInfoSection() {
    return _buildSectionCard(
      title: 'Thông tin khách hàng',
      icon: Icons.person_outline,
      children: [
        _buildInputField(
          title: "Tên người liên hệ",
          hint: 'Tên khách hàng',
          controller: _nameCustomerController,
          focusNode: _nameCustomerFocus,
          isRequired: true,
          onSubmitted: () => Utils.navigateNextFocusChange(context, _nameCustomerFocus, _phoneCustomerFocus),
        ),
        _buildInputField(
          title: "SĐT người liên hệ",
          hint: 'Số điện thoại',
          controller: _phoneCustomerController,
          focusNode: _phoneCustomerFocus,
          isRequired: true,
          inputType: TextInputType.phone,
          maxLength: 10,
        ),
        _buildDatePickerField(),
      ],
    );
  }

  Widget _buildStoreInfoSection() {
    return _buildSectionCard(
      title: 'Thông tin cửa hàng',
      icon: Icons.store_outlined,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildInputField(
                title: "Tên cửa hàng",
                hint: 'Tên cửa hàng',
                controller: _nameStoreController,
                focusNode: _nameStoreFocus,
                isRequired: true,
                onSubmitted: () => Utils.navigateNextFocusChange(context, _nameStoreFocus, _phoneCustomer2Focus),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildStoreImagePicker(),
            ),
          ],
        ),
        _buildInputField(
          title: "SĐT cửa hàng",
          hint: 'Số điện thoại',
          controller: _phoneCustomer2Controller,
          focusNode: _phoneCustomer2Focus,
          isRequired: true,
          inputType: TextInputType.phone,
          maxLength: 10,
          onSubmitted: () => Utils.navigateNextFocusChange(context, _phoneCustomer2Focus, _addressFocus),
        ),
        _buildInputField(
          title: "Email",
          hint: 'Email',
          controller: _emailController,
          focusNode: _emailFocus,
          inputType: TextInputType.emailAddress,
          onSubmitted: () => Utils.navigateNextFocusChange(context, _emailFocus, _mstFocus),
        ),
        _buildInputField(
          title: "Mã số thuế",
          hint: 'Mã số thuế',
          controller: _mstController,
          focusNode: _mstFocus,
          onSubmitted: () => Utils.navigateNextFocusChange(context, _mstFocus, _noteFocus),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSectionCard(
      title: 'Thông tin địa chỉ',
      icon: Icons.location_on_outlined,
      trailingWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            useNewRegulation ? 'Mới (2 cấp)' : 'Cũ (3 cấp)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subColor,
            ),
          ),
          const SizedBox(width: 6),
          Switch(
            value: useNewRegulation,
            onChanged: (value) {
              setState(() {
                useNewRegulation = value;
                // Clear dữ liệu địa chỉ khi chuyển chế độ
                idProvince = '';
                idDistrict = '';
                idCommune = '';
                _provinceController.clear();
                _districtController.clear();
                _communeController.clear();
                _addressController.clear();
                _clearStepCompletionCache();
              });
            },
            activeColor: subColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
      children: [
        if (useNewRegulation)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Theo nghị định mới (7-2025): Chỉ cần Tỉnh và Xã/Phường',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                title: "Địa chỉ",
                hint: 'Địa chỉ chi tiết',
                controller: _addressController,
                focusNode: _addressFocus,
                isRequired: true,
                onSubmitted: () => Utils.navigateNextFocusChange(context, _addressFocus, _emailFocus),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  _bloc.getUserLocation();
                  _triggerAutoMapAddress();
                },
                icon: const Icon(Icons.my_location, size: 16),
                label: const Text('Auto', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: subColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildSelectionField(
                title: "Khu vực",
                hint: 'Chọn khu vực',
                controller: _areaController,
                onTap: () => _selectArea(),
                isRequired: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSelectionField(
                title: "Tỉnh/Thành",
                hint: 'Chọn tỉnh/thành',
                controller: _provinceController,
                onTap: () => _selectProvince(),
                isRequired: true,
              ),
            ),
          ],
        ),
        // Ẩn Quận/Huyện nếu chế độ mới
        if (!useNewRegulation)
          Row(
            children: [
              Expanded(
                child: _buildSelectionField(
                  title: "Quận/Huyện",
                  hint: 'Chọn quận/huyện',
                  controller: _districtController,
                  onTap: () => _selectDistrict(),
                  enabled: idProvince.isNotEmpty,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSelectionField(
                  title: "Xã/Phường",
                  hint: 'Chọn xã/phường',
                  controller: _communeController,
                  onTap: () => _selectCommune(),
                  enabled: idDistrict.isNotEmpty,
                  isRequired: true,
                ),
              ),
            ],
          ),
        // Hiển thị Xã/Phường trực tiếp từ Tỉnh nếu chế độ mới
        if (useNewRegulation)
          _buildSelectionField(
            title: "Xã/Phường",
            hint: 'Chọn xã/phường',
            controller: _communeController,
            onTap: () => _selectCommune(),
            enabled: idProvince.isNotEmpty,
            isRequired: true,
          ),
        Row(
          children: [
            Expanded(
              child: _buildSelectionField(
                title: "Phân loại",
                hint: 'Chọn phân loại',
                controller: _typeStoreController,
                onTap: () => _selectTypeStore(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSelectionField(
                title: "Hình thức",
                hint: 'Chọn hình thức',
                controller: _storeFormController,
                onTap: () => _selectStoreForm(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return _buildSectionCard(
      title: 'Thông tin bổ sung',
      icon: Icons.info_outline,
      children: [
        _buildInputField(
          title: "Ghi chú",
          hint: 'Vui lòng nhập ghi chú nếu có',
          controller: _noteController,
          focusNode: _noteFocus,
          maxLines: 3,
          onSubmitted: () => Utils.navigateNextFocusChange(context, _noteFocus, _descFocus),
        ),
        _buildInputField(
          title: "Mô tả",
          hint: 'Vui lòng nhập mô tả nếu có',
          controller: _descController,
          focusNode: _descFocus,
          maxLines: 3,
        ),
        _buildSelectionField(
          title: "Tour/Tuyến",
          hint: 'Chọn tour/tuyến',
          controller: _nameTourController,
          onTap: () => _selectTour(),
          isRequired: true,
        ),
        if (DataLocal.hotIdName.toString().contains('namdung'))
          _buildSelectionField(
            title: "Nhóm giá",
            hint: 'Chọn nhóm giá',
            controller: _priceGroupController,
            onTap: () => _selectPriceGroup(),
          ),
        if (Const.chooseStateWhenCreateNewOpenStore == true)
          _buildSelectionField(
            title: "Trạng thái",
            hint: 'Chọn trạng thái',
            controller: _nameStateController,
            onTap: () => _selectState(),
            isRequired: true,
          ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailingWidget,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: subColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: subColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: subColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (trailingWidget != null) ...[
                  const SizedBox(width: 8),
                  trailingWidget,
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  static const _requiredText = Text(
    ' *',
    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
  );

  final _spacing8 = SizedBox(height: 8);

  Widget _buildInputField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isRequired = false,
    TextInputType? inputType,
    int? maxLength,
    int maxLines = 1,
    VoidCallback? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              if (isRequired) _requiredText,
            ],
          ),
          _spacing8,
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(title, controller.text),
                width: _getBorderWidth(title, controller.text),
              ),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: inputType ?? TextInputType.text,
              maxLength: maxLength,
              maxLines: maxLines,
              inputFormatters: inputType == TextInputType.phone 
                  ? [FilteringTextInputFormatter.digitsOnly] // Chỉ cho phép nhập số cho phone
                  : null,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                counterText: '',
              ),
              onChanged: (value) {
                // Clear cache khi text thay đổi để update progress indicator
                _clearStepCompletionCache();
                setState(() {}); // Force rebuild để update progress
              },
              onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
    bool enabled = true,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              if (isRequired) _requiredText,
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: enabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: enabled ? Colors.grey[50] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: enabled ? Colors.grey[300]! : Colors.grey[400]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? hint : controller.text,
                      style: TextStyle(
                        color: controller.text.isEmpty ? Colors.grey[500] : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: enabled ? Colors.grey[600] : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ngày sinh',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              Utils.dateTimePickerCustom(context).then((value) {
                if (value != null) {
                  setState(() {
                    _birthDayController.text = Utils.parseStringDateToString(
                      value.toString(),
                      Const.DATE_TIME_FORMAT,
                      Const.DATE_SV_FORMAT,
                    );
                    // Clear cache để update progress indicator
                    _clearStepCompletionCache();
                  });
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _birthDayController.text.isEmpty ? '1995/03/04' : _birthDayController.text,
                      style: TextStyle(
                        color: _birthDayController.text.isEmpty ? Colors.grey[500] : Colors.black87,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreImagePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ảnh cửa hàng',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (_bloc.listFileInvoice.isNotEmpty || _existingImageUrls.isNotEmpty) ? subColor : Colors.grey[300]!,
                width: (_bloc.listFileInvoice.isNotEmpty || _existingImageUrls.isNotEmpty) ? 2 : 1,
              ),
            ),
            child: _hasAnyImages()
                ? _buildStoreImagePreview()
                : _buildEmptyImagePicker(),
          ),
        ],
      ),
    );
  }

  bool _hasAnyImages() {
    return _bloc.listFileInvoice.isNotEmpty || _existingImageUrls.isNotEmpty;
  }

  Widget _buildEmptyImagePicker() {
    return InkWell(
      onTap: () {
        _bloc.getUserLocation();
        getImage();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: subColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 24,
              color: subColor,
            ),
            const SizedBox(height: 4),
            Text(
              'Thêm ảnh',
              style: TextStyle(
                fontSize: 12,
                color: subColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreImagePreview() {
    final bool useLocal = _bloc.listFileInvoice.isNotEmpty;
    final bool useNetwork = !useLocal && _existingImageUrls.isNotEmpty;
    final String? firstUrl = useNetwork ? _existingImageUrls.first : null;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              if (useLocal) {
                openImageFullScreen(0, _bloc.listFileInvoice.first);
              } else if (useNetwork && firstUrl != null) {
                openNetworkImageFullScreen(0, firstUrl);
              }
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: useLocal
                  ? Image.file(
                      _bloc.listFileInvoice.first,
                      fit: BoxFit.cover,
                    )
                  : useNetwork && firstUrl != null
                      ? Image.network(
                          firstUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _bloc.getUserLocation();
                    getImage();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _bloc.listFileInvoice.clear();
                      if (_existingImageUrls.isNotEmpty) {
                        _existingImageUrls.clear();
                      }
                      // Clear cache để update progress indicator
                      _clearStepCompletionCache();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_bloc.listFileInvoice.length > 1 || _existingImageUrls.length > 1)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: subColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${useLocal ? _bloc.listFileInvoice.length : _existingImageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalImagesSection() {
    return _buildSectionCard(
      title: 'Ảnh bổ sung',
      icon: Icons.photo_library_outlined,
      children: [
        Text(
          'Bạn có thể thêm nhiều ảnh khác của cửa hàng',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            _bloc.getUserLocation();
            getImage();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: subColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: subColor.withOpacity(0.3), style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 20,
                  color: subColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thêm ảnh khác',
                  style: TextStyle(
                    color: subColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          width: double.infinity,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: _bloc.listFileInvoice.isNotEmpty ? _bloc.listFileInvoice.length : _existingImageUrls.length,
            itemBuilder: (context, index) {
              if (_bloc.listFileInvoice.isNotEmpty) {
                return (start > 1 && waitingLoad == true && _bloc.listFileInvoice.length == (index + 1))
                    ? const SizedBox(
                        height: 100,
                        width: 80,
                        child: PendingAction(),
                      )
                    : _buildImageItem(index, _bloc.listFileInvoice[index]);
              } else {
                final url = _existingImageUrls[index];
                return _buildNetworkImageItem(index, url);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(int index, File file) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => openImageFullScreen(index, file),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _bloc.listFileInvoice.removeAt(index);
                  // Clear cache để update progress indicator
                  _clearStepCompletionCache();
                });
              },
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImageItem(int index, String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => openNetworkImageFullScreen(index, url),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _existingImageUrls.removeAt(index);
                  _clearStepCompletionCache();
                });
              },
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSelection({
    required String title,
    required int typeGetList,
    String? idProvince,
    String? idDistrict,
    String? idArea,
    required Function(String id, String name) onSuccess,
    String? errorMessage,
    bool useNewRegulationMode = false,
    bool forceCommuneLookup = false,
  }) {
    FocusScope.of(context).unfocus();

    if (errorMessage != null) {
      Utils.showCustomToast(context, Icons.warning_amber_outlined, errorMessage);
      return;
    }

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: SearchProvinceScreen(
        idArea: idArea ?? '',
        idProvince: idProvince ?? '',
        idDistrict: idDistrict ?? '',
        title: title,
        typeGetList: typeGetList,
        useNewRegulation: useNewRegulationMode,
        forceCommuneLookup: forceCommuneLookup,
      ),
      withNavBar: false,
    ).then((value) {
      if (value != null && value[0] == 'Yeah') {
        setState(() {
          String id = value[1].toString().trim();
          String name = value[2].toString().trim();
          onSuccess(id, name);
          _clearStepCompletionCache();
        });
      }
    });
  }

  void _selectArea() {
    _handleSelection(
      title: 'Danh sách Khu vực',
      typeGetList: 1,
      onSuccess: (id, name) {
        idArea = id;
        _areaController.text = name;
      },
    );
  }

  void _selectProvince() {
    _handleSelection(
      title: 'Danh sách Tỉnh thành',
      typeGetList: 0,
      useNewRegulationMode: useNewRegulation,
      onSuccess: (id, name) {
        setState(() {
          idProvince = id;
          _provinceController.text = name;
          // Clear District và Commune khi chọn Tỉnh mới
          idDistrict = '';
          idCommune = '';
          _districtController.clear();
          _communeController.clear();
          _clearStepCompletionCache();
        });
      },
    );
  }

  void _selectDistrict() {
    if (idProvince.isEmpty) {
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Vui lòng chọn Tỉnh/Thành trước');
      return;
    }

    _handleSelection(
      title: 'Danh sách Quận huyện',
      typeGetList: 0,
      idProvince: idProvince,
      useNewRegulationMode: useNewRegulation,
      onSuccess: (id, name) {
        idDistrict = id;
        _districtController.text = name;
        idCommune = '';
        _communeController.clear();
      },
    );
  }

  void _selectCommune() {
    // Chế độ mới: chỉ cần Tỉnh, không cần Quận/Huyện
    if (useNewRegulation) {
      if (idProvince.isEmpty) {
        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Vui lòng chọn Tỉnh/Thành trước');
        return;
      }
      
      // Chọn Xã/Phường trực tiếp từ Tỉnh (không cần District)
      _handleSelection(
        title: 'Danh sách Xã phường',
        typeGetList: 0,
        idProvince: idProvince,
        idDistrict: '', // Để trống trong chế độ mới
          useNewRegulationMode: useNewRegulation,
          forceCommuneLookup: true,
        onSuccess: (id, name) {
          idCommune = id;
          _communeController.text = name;
        },
      );
    } else {
      // Chế độ cũ: cần cả Tỉnh và Quận/Huyện
      if (idDistrict.isEmpty) {
        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Vui lòng chọn Quận/Huyện trước');
        return;
      }

      _handleSelection(
        title: 'Danh sách Xã phường',
        typeGetList: 0,
        idProvince: idProvince,
        idDistrict: idDistrict,
        useNewRegulationMode: useNewRegulation,
        onSuccess: (id, name) {
          idCommune = id;
          _communeController.text = name;
        },
      );
    }
  }

  void _selectTypeStore() {
    _handleSelection(
      title: 'Danh sách Phân loại',
      typeGetList: 3,
      idProvince: idProvince,
      onSuccess: (id, name) {
        idTypeStore = id;
        _typeStoreController.text = name;
      },
    );
  }

  void _selectStoreForm() {
    _handleSelection(
      title: 'Danh sách Hình thức',
      typeGetList: 2,
      idProvince: idProvince,
      idDistrict: idDistrict,
      onSuccess: (id, name) {
        idStoreForm = id;
        _storeFormController.text = name;
      },
    );
  }

  void _selectTour() {
    FocusScope.of(context).unfocus();
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const SearchTourScreen(
        idTour: '',
        idState: '',
        title: 'Tìm kiếm Tour/Tuyến',
        isTour: true,
      ),
      withNavBar: false,
    ).then((value) {
      if (value != null && value[0] == 'Yeah') {
        setState(() {
          idTour = value[1].toString().trim();
          _nameTourController.text = value[2].toString().trim();
          // Clear cache để update progress indicator
          _clearStepCompletionCache();
        });
      }
    });
  }

  void _selectPriceGroup() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (context) => const OptionReportFilter(
        controller: 'dmnhkh2_lookup',
        listItem: '',
        show: false,
      ),
    ).then((value) {
      if (value is List && value.length >= 2) {
        setState(() {
          _priceGroupCode = value[0].toString().trim();
          _priceGroupController.text = value[1].toString().trim();
          _clearStepCompletionCache();
        });
      }
    });
  }

  void _selectState() {
    FocusScope.of(context).unfocus();
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const SearchTourScreen(
        idState: '',
        title: 'Tìm kiếm Trạng thái',
        idTour: '',
        isTour: false,
      ),
      withNavBar: false,
    ).then((value) {
      if (value != null && value[0] == 'Yeah') {
        setState(() {
          idState = value[1].toString().trim();
          _nameStateController.text = value[2].toString().trim();
          // Clear cache để update progress indicator
          _clearStepCompletionCache();
        });
      }
    });
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [subColor, Color.fromARGB(255, 150, 185, 229)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                isEditMode ? "Chi tiết / Cập nhật yêu cầu" : "Thêm mới KH đề xuất mở điểm",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          isEditMode
              ? InkWell(
                  onTap: () {
                    if (_bloc.userRoles >= _bloc.leadRoles) {
                      _confirmDelete();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (_bloc.userRoles >= _bloc.leadRoles)
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_forever_outlined,
                      color: (_bloc.userRoles >= _bloc.leadRoles) ? Colors.white : Colors.transparent,
                      size: 20,
                    ),
                  ),
                )
              : const SizedBox(width: 40),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Row(
              children: [
                Icon(Icons.delete_forever_outlined, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bạn chuẩn bị xoá Yêu cầu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                )
              ],
            ),
            content: const Text('Hãy chắc chắn bạn muốn điều này xảy ra?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'NO'),
                child: const Text('Huỷ'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, 'Yeah'),
                child: const Text('Xoá'),
              )
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null && value == 'Yeah') {
        _bloc.add(CancelOpenStoreEvent(widget.idRequestOpenStore!, idTour));
      }
    });
  }

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

  void openNetworkImageFullScreen(final int indexOfImage, String pathImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageViewWrapperViewOnly(
          titleGallery: "Zoom Image",
          viewNetWorkImage: true,
          backgroundDecoration: const BoxDecoration(
            color: Colors.white,
          ),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal,
          galleryItemsNetWork: pathImage,
        ),
      ),
    );
  }
}
