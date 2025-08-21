import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dms/screen/personnel/proposal/proposal_bloc.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as dateFormating;
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../driver_transfer/helper/constant.dart';
import '../../create_proposal/widget/build_row_with_date_picker.dart';
import 'dropdown_status_dynamic.dart';
import 'image_viewer_popup.dart';
import 'look_up_dynamic_form.dart';


class DynamicScreen extends StatefulWidget {
  final String title;
  final String controller;
  final String sttRec;
  final int status;
  final int actionView;
  final List<Map<String, dynamic>> listRequestDetail;
  const DynamicScreen({key, required this.title, required this.controller, required this.actionView,required this.listRequestDetail,required this.sttRec, required this.status});

  @override
  State<DynamicScreen> createState() => _DynamicCRUDScreenState();
}

class _DynamicCRUDScreenState extends State<DynamicScreen> {

  late ProposalBloc _bloc;
  var formDefines;
  var fields;
  var grids;
  TextEditingController addressStartEditingController = TextEditingController();
  TextEditingController addressEndEditingController = TextEditingController();
  TextEditingController titleEditingController = TextEditingController();
  TextEditingController descEditingController = TextEditingController();
  TextEditingController requestOtherEditingController = TextEditingController();
  TextEditingController memberJoinEditingController = TextEditingController();
  TextEditingController peopleJoinEditingController = TextEditingController();
  TextEditingController nameCustomerEditingController = TextEditingController();
  TextEditingController phoneCustomerEditingController = TextEditingController();
  List<Map<String, dynamic>> fieldsConvert = [];

  Map<String, List<Map<String, dynamic>>> tableData = {};
  Map<String, Set<int>> selectedRows = {};
  Map<String, dynamic> formDataDynamic = {};
  Map<String, TextEditingController> controllersTextEdit = {};


  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();
  DateTime dateRequest = DateTime.now();

  int isMorningFrom = 1;
  int isMorningTo = 1;
  String codeLeaveLetter = '';String nameLeaveLetter = '';
  String soNgay = "0";
  double soGio = 0;

  var dateFormat = dateFormating.DateFormat("yyyy-MM-dd");

  TimeOfDay? selectedTimeStart;
  TimeOfDay? selectedTimeEnd;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dialOnly;
  Orientation? orientation;

  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  TextDirection textDirection = TextDirection.ltr;
  bool use24HourTime = false;
  var timeFormat = dateFormating.DateFormat("hh:mm a");

  bool isCheckRequest = false;
  bool isCheckHQBK = false;
  bool isCheckDU = false;
  bool isCheckMC = false;

  Map<String, TextEditingController> controllers = {};
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void initializeControllers(List<Map<String, dynamic>> fields) {
    for (var field in fields) {
      String fieldName = field['name'];
      controllers[fieldName] = TextEditingController();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dateFrom = dateFormat.parse(DateTime.now().toString());
    dateTo = dateFormat.parse(DateTime.now().toString());
    _bloc = ProposalBloc(context);
    _bloc.add(GetPrefsProposal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProposalBloc, ProposalState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is ProposalFailure) {
            Utils.showCustomToast(context, Icons.check_circle_outline, state.error.toString());
          }
          else if (state is GetPrefsSuccess) {
           if(widget.actionView == 0){ /// create
             _bloc.add(GetFormDynamicEvent(controller: widget.controller));
           }
           else{ /// view detail
             _bloc.add(ViewDetailFormDynamicEvent(listRequestDetail: widget.listRequestDetail, controller: widget.controller));
           }
          }
          else if(state is GetFormDynamicSuccess){
            ///fix
            if(widget.actionView == 1){
              dateFrom = _bloc.formFixData.ngayTu.toString().replaceAll('null', '').isNotEmpty ? dateFormat.parse(_bloc.formFixData.ngayTu.toString()) : dateFormat.parse(DateTime.now().toString());
              dateTo = _bloc.formFixData.ngayDen.toString().replaceAll('null', '').isNotEmpty ? dateFormat.parse(_bloc.formFixData.ngayDen.toString()) : dateFormat.parse(DateTime.now().toString());
              dateRequest = _bloc.formFixData.ngayDeNghi.toString().replaceAll('null', '').isNotEmpty ? dateFormat.parse(_bloc.formFixData.ngayDeNghi.toString()) : dateFormat.parse(DateTime.now().toString());
              _bloc.so_luong_anh = _bloc.formFixData.so_luong_anh??0;
              if(widget.controller.contains('AdvanceRequest')){
                titleEditingController.text = _bloc.formFixData.dienGiai.toString().replaceAll('null', '');
              }else{
                descEditingController.text = _bloc.formFixData.dienGiai.toString().replaceAll('null', '').isNotEmpty
                    ? _bloc.formFixData.dienGiai.toString() :
                _bloc.formFixData.ghiChu.toString().replaceAll('null', '').isNotEmpty
                    ?
                _bloc.formFixData.ghiChu.toString().replaceAll('null', '') : _bloc.formFixData.lyDo.toString().replaceAll('null', '');
              }

              soNgay = _bloc.formFixData.soNgay.toString();
              isMorningFrom = _bloc.formFixData.caTu.toString().replaceAll('null', '').isNotEmpty ? int.tryParse(_bloc.formFixData.caTu.toString())! : 1;
              isMorningTo = _bloc.formFixData.caDen.toString().replaceAll('null', '').isNotEmpty ?  int.tryParse(_bloc.formFixData.caDen.toString())! : 1;
              codeLeaveLetter = _bloc.formFixData.loai.toString();
              nameLeaveLetter = _bloc.formFixData.tenLoai.toString();
              // status = _bloc.formFixData.status.toString().replaceAll('null', '').isNotEmpty ?  int.tryParse(_bloc.formFixData.status.toString())! : 1;

              soGio = _bloc.formFixData.tongGio.toString().replaceAll('null', '').isNotEmpty ?  double.tryParse(_bloc.formFixData.tongGio.toString())! : 0;
              selectedTimeStart = Utils.parseTimeOfDay(_bloc.formFixData.gioTu.toString());
              selectedTimeEnd = Utils.parseTimeOfDay(_bloc.formFixData.gioDen.toString());
              addressStartEditingController.text = _bloc.formFixData.diemDi.toString().replaceAll('null', '');
              addressEndEditingController.text = _bloc.formFixData.diemDen.toString().replaceAll('null', '');
              idCar = _bloc.formFixData.idCar.toString().replaceAll('null', '');
              nameCar = _bloc.formFixData.nameCar.toString().replaceAll('null', '');

              idRoom =  _bloc.formFixData.idRoom.toString().replaceAll('null', '');
              nameRoom =  _bloc.formFixData.nameRoom.toString().replaceAll('null', '');
              memberJoinEditingController.text =  _bloc.formFixData.soLuong.toString().replaceAll('null', '');
              peopleJoinEditingController.text =  _bloc.formFixData.thanhPhan.toString().replaceAll('null', '');
              requestOtherEditingController.text =  _bloc.formFixData.requestOther.toString().replaceAll('null', '');
              nameCustomerEditingController.text =  _bloc.formFixData.nameCustomer.toString().replaceAll('null', '');
              phoneCustomerEditingController.text =  _bloc.formFixData.phoneCustomer.toString().replaceAll('null', '');
              isCheckRequest =  _bloc.formFixData.request??false;
              isCheckHQBK =  _bloc.formFixData.request??false;
              isCheckDU =  _bloc.formFixData.request??false;
              isCheckMC =  _bloc.formFixData.request??false;
            }

            ///dynamic
            formDefines = _bloc.jsonListData['data']['formDefines'];
            fields = formDefines['fields'];
            grids = formDefines['grids'];
            formDataDynamic = _bloc.jsonListData['data']['formDatas']['formDataDynamic'] ?? {};

            for (var grid in _bloc.jsonListData['data']['formDefines']['grids']) {
              String controller = grid['controller'];
              tableData[controller] = [];
              tableData[controller] = List<Map<String, dynamic>>.from(
                  _bloc.jsonListData['data']['formDatas']["gridData${_bloc.jsonListData['data']['formDefines']['grids'].indexOf(grid) + 1}"] ??
                      []);
              selectedRows[controller] = {};
            }
            fieldsConvert = List<Map<String, dynamic>>.from(_bloc.jsonListData['data']['formDefines']['fields']);
            initializeControllers(fieldsConvert);
          }
          else if (state is ActionDynamicSuccess){
            if(widget.controller.contains('CheckinExplan') && _bloc.listFileImage.isNotEmpty && state.values.toString().replaceAll('null', '').isNotEmpty){
              _bloc.add(UploadFileEvent(keyUpload: state.values,controller: "CheckinExplan"));
            }else{
              Utils.showCustomToast(context, Icons.check, 'Cập nhật thành công');
              Navigator.pop(context,['reload']);
            }
          }
          else if (state is ActionUploadFileSuccess){
            Utils.showCustomToast(context, Icons.check, 'Cập nhật thành công');
            Navigator.pop(context,['reload']);
          }
        },
        child: BlocBuilder<ProposalBloc, ProposalState>(
          bloc: _bloc,
          builder: (BuildContext context, ProposalState state) {
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is GetListProposalEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',
                        style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is ProposalLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context, ProposalState state) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Stack(
              children: [
                buildDynamicBody(context),
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: widget.actionView == 0 ? buttonCF() :
                  widget.controller.contains('AdvanceRequest') ? buttonCF() :
                  widget.status <= 1 ? buttonCF()
                      : Container(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonCF(){
    return Row(
      children: [
        widget.actionView == 1 ?  GestureDetector(
          onTap:()=> onSave(controllers,formDataDynamic,2),
          child: Container(
              width: 100,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: dark_text,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Xoá phiếu",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              )),
        ) : Container(),
        const SizedBox(
          width: 10,
        ),
        GestureDetector(
          onTap: (){
            onSave(controllers,formDataDynamic,1);
          },
          child: Container(
              width: 100,
              padding: const EdgeInsets.symmetric(
                  vertical: 10,horizontal: 10
              ),
              decoration: BoxDecoration(
                color: kSecondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(widget.actionView == 0 ?
              "Gửi" : 'Cập nhật',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              )),
        ),
      ],
    );
  }

  void onSave(Map<String, TextEditingController> controllers, Map<String, dynamic> formDataDynamic,int action) {
    List<Map<String, dynamic>> gridsList =
    (_bloc.jsonListData['data']['formDefines']['grids'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    Map<String, dynamic> output = {};

    // Xử lý form values
    List<Map<String, dynamic>> formValues = [];

    if(widget.actionView == 1){
      // formValues.add({
      //   "variable": widget.controller.contains('CheckinExplan') ? 'stt_rec_nv' : "stt_rec",
      //   "type": "Text",
      //   "value": widget.sttRec.toString(),
      // });
      formValues.addAll(widget.listRequestDetail);
    }

    if(widget.controller.contains('BusinessTrip') && action == 1){
      formValues.add({
        "variable": "ngay_tu",
        "type": "DateTime",
        "value": dateFrom.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "ngay_den",
        "type": "DateTime",
        "value": dateTo.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "ca_tu",
        "type": "Int",
        "value": isMorningFrom,
      });formValues.add({
        "variable": "ca_den",
        "type": "Int",
        "value": isMorningTo,
      });
      formValues.add({
        "variable": "dien_giai",
        "type": "Text",
        "value": descEditingController.text.toString(),
      });
      formValues.add({
        "variable": "status",
        "type": "Int",
        "value": 1,
      });
    }
    else if(widget.controller.contains('DayOff') && action == 1){
      formValues.add({
        "variable": "ngay_tu",
        "type": "DateTime",
        "value": dateFrom.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "ngay_den",
        "type": "DateTime",
        "value": dateTo.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "ghi_chu",
        "type": "Text",
        "value": descEditingController.text.toString(),
      });
      formValues.add({
        "variable": "loai",
        "type": "Text",
        "value": codeLeaveLetter,
      });
      formValues.add({
        "variable": "status",
        "type": "Int",
        "value": 1,
      });formValues.add({
        "variable": "ca_tu",
        "type": "Int",
        "value": isMorningFrom,
      });formValues.add({
        "variable": "ca_den",
        "type": "Int",
        "value": isMorningTo,
      });formValues.add({
        "variable": "so_ngay",
        "type": "Int",
        "value": ((((dateTo.difference(dateFrom).inDays) + 1) * 2) -
            (isMorningFrom == 0 ? 1 : 0) - (isMorningTo == 1 ? 1 : 0)) * 0.5,
      });
    }
    else if(widget.controller.contains('OverTime') && action == 1){
      formValues.add({
        "variable": "ngay_tu",
        "type": "DateTime",
        "value": dateFrom.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "ngay_den",
        "type": "DateTime",
        "value": dateTo.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "ghi_chu",
        "type": "Text",
        "value": descEditingController.text.toString(),
      });
      formValues.add({
        "variable": "status",
        "type": "Int",
        "value": 1,
      });formValues.add({
        "variable": "gio_tu",
        "type": "Text",
        "value": "${selectedTimeStart?.hour.toString()}:${selectedTimeStart?.minute.toString()}",
      });formValues.add({
        "variable": "gio_den",
        "type": "Text",
        "value": "${selectedTimeEnd?.hour.toString()}:${selectedTimeEnd?.minute.toString()}",
      });formValues.add({
        "variable": "tong_gio",
        "type": "Decimal",
        "value": soGio,
      });
    }
    else if(widget.controller.contains('AdvanceRequest') && action == 1){
      formValues.add({
        "variable": "dien_giai",
        "type": "Text",
        "value": titleEditingController.text,
      });
    }
    else if(widget.controller.contains('CheckinExplan') && action == 1){
      formValues.add({
        "variable": "ngay_tu",
        "type": "DateTime",
        "value": dateFrom.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "ngay_den",
        "type": "DateTime",
        "value": dateTo.toString().replaceAll('-', '').split(' ').first,
      });    formValues.add({
        "variable": "ngay_dn",
        "type": "DateTime",
        "value": dateRequest.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "gio_tu",
        "type": "Text",
        "value": "${selectedTimeStart?.hour.toString()}:${selectedTimeStart?.minute.toString()}",
      });formValues.add({
        "variable": "gio_den",
        "type": "Text",
        "value": "${selectedTimeEnd?.hour.toString()}:${selectedTimeEnd?.minute.toString()}",
      });
      formValues.add({
        "variable": "ly_do",
        "type": "Text",
        "value": descEditingController.text,
      });
      formValues.add({
        "variable": "status",
        "type": "Int",
        "value": 1,
      });
    }
    else if(widget.controller.contains('CarRequest') && action == 1){
      formValues.add({
        "variable": "ngay_tu",
        "type": "DateTime",
        "value": dateFrom.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "ngay_den",
        "type": "DateTime",
        "value": dateTo.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "dien_giai",
        "type": "Text",
        "value": descEditingController.text,
      });formValues.add({
        "variable": "loai_xe",
        "type": "Text",
        "value": idCar.toString(),
      });formValues.add({
        "variable": "diem_di",
        "type": "Text",
        "value": addressStartEditingController.text.toString(),
      });formValues.add({
        "variable": "diem_den",
        "type": "Text",
        "value": addressEndEditingController.text.toString(),
      });
      formValues.add({
        "variable": "status",
        "type": "Int",
        "value": 1,
      });
      formValues.add({
        "variable": "gio_tu",
        "type": "Text",
        "value": "${selectedTimeStart?.hour.toString()}:${selectedTimeStart?.minute.toString()}",
      });formValues.add({
        "variable": "gio_den",
        "type": "Text",
        "value": "${selectedTimeEnd?.hour.toString()}:${selectedTimeEnd?.minute.toString()}",
      });formValues.add({
        "variable": "ten_kh",
        "type": "Text",
        "value": nameCustomerEditingController.text.toString(),
      });formValues.add({
        "variable": "sdt_lh",
        "type": "Text",
        "value": phoneCustomerEditingController.text.toString(),
      });
    }
    else if(widget.controller.contains('MeetingRoom') && action == 1){
      formValues.add({
        "variable": "ngay_tu",
        "type": "DateTime",
        "value": dateFrom.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "ngay_den",
        "type": "DateTime",
        "value": dateTo.toString().replaceAll('-', '').split(' ').first,
      });
      formValues.add({
        "variable": "dien_giai",
        "type": "Text",
        "value": descEditingController.text,
      });formValues.add({
        "variable": "ma_phong",
        "type": "Text",
        "value": idRoom.toString(),
      });formValues.add({
        "variable": "so_luong",
        "type": "Text",
        "value": memberJoinEditingController.text.toString(),
      });formValues.add({
        "variable": "thanhphan",
        "type": "Text",
        "value": peopleJoinEditingController.text.toString(),
      });
      formValues.add({
        "variable": "other",
        "type": "Text",
        "value": requestOtherEditingController.text.toString(),
      });
      formValues.add({
        "variable": "yccb_yn",
        "type": "CheckBox",
        "value": isCheckRequest == true ? 1 : 0,
      });
      formValues.add({
        "variable": "hqbk_yn",
        "type": "CheckBox",
        "value": isCheckHQBK == true ? 1 : 0,
      });
      formValues.add({
        "variable": "nuoc_yn",
        "type": "CheckBox",
        "value": isCheckDU == true ? 1 : 0,
      });
      formValues.add({
        "variable": "maychieu_yn",
        "type": "CheckBox",
        "value": isCheckMC == true ? 1 : 0,
      });
      formValues.add({
        "variable": "status",
        "type": "Int",
        "value": 1,
      });
      formValues.add({
        "variable": "gio_tu",
        "type": "Text",
        "value": "${selectedTimeStart?.hour.toString()}:${selectedTimeStart?.minute.toString()}",
      });formValues.add({
        "variable": "gio_den",
        "type": "Text",
        "value": "${selectedTimeEnd?.hour.toString()}:${selectedTimeEnd?.minute.toString()}",
      });
    }

    for (var field in fields) {
      String variable = field['name'];
      String type = field['type'];

      dynamic value;
      if (controllers.containsKey(variable)) {
        value = controllers[variable]!.text;
      } else if (formDataDynamic.containsKey(variable)) {
        value = formDataDynamic[variable];
      }

      if (type == "Int") {
        value = int.tryParse(value.toString()) ?? 0;
      } else if (type == "Double") {
        value = double.tryParse(value.toString()) ?? 0.0;
      }

      if (value != null && value.toString().isNotEmpty && action != 2) { /// action = 2 la xoa
        formValues.add({
          "variable": variable,
          "type": type,
          "value": value.toString() == "null" ? value.toString().replaceAll('null', '') : value,
        });
      }
    }
    output["formValues"] = formValues;

    // Xử lý grid values theo điều kiện external = false
    Map<String, List<String>> allowedFields = {};

    for (var grid in gridsList) {
      String tableName = grid["controller"];
      List<String> fields = grid["fields"]
          .where((field) => field["external"] == false) // Lọc external = false
          .map<String>((field) => field["name"].toString()) // Lấy tên trường
          .toList();

      allowedFields[tableName] = fields;
    }

    int gridIndex = 1;
    tableData.forEach((tableName, gridList) {
      // Kiểm tra bảng có trong danh sách cần lọc không
      if (!allowedFields.containsKey(tableName)) return;

      List<String> validFields = allowedFields[tableName]!;

      // Lọc dữ liệu chỉ giữ lại các trường hợp lệ
      List<Map<String, dynamic>> filteredRows = gridList.map((row) {
        return Map.fromEntries(
            row.entries.where((e) => validFields.contains(e.key)));
      }).toList();

      // Lưu vào output nếu còn dữ liệu hợp lệ v
      if ( action != 2) {//filteredRows.isNotEmpty &&
        if(gridIndex == 1){
          output["gridValues"] = filteredRows;
        }else{
          output["gridValues$gridIndex"] = filteredRows;
        }
        gridIndex++;
      }
    });

    // In ra console dưới dạng JSON
    print(output);

    if(widget.actionView == 0){
      _bloc.add(ActionDynamicEvent(controller: widget.controller,action: 'Creating',listRequestDetail: [],request: output));
    }else if(widget.actionView == 1){
      if(action == 1){
        _bloc.add(ActionDynamicEvent(controller: widget.controller,action: 'Updating',listRequestDetail: widget.listRequestDetail,request: output));
      }else{
        _bloc.add(ActionDynamicEvent(controller: widget.controller,action: 'Deleting',listRequestDetail: widget.listRequestDetail,request: output));
      }
    }
  }

  buildAppBar() {
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
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
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
                widget.title[0].toUpperCase() + widget.title.substring(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
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

  Widget buildDynamicBody(BuildContext context) {
    if (_bloc.jsonListData.isEmpty) {
      return const Scaffold(body: Center());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.controller.contains('BusinessTrip') ?
          buildBusiness(context)
              : widget.controller.contains('OverTime') ?
          Expanded(child: buildOverTime(context)) :
          widget.controller.contains('DayOff') ?
          Expanded(child: buildDayOff(context)) :
          widget.controller.contains('AdvanceRequest') ?
          buildAdvanceRequest(context) :
          widget.controller.contains('CheckinExplan') ?
          Expanded(child: buildGTCC(context)) :
          widget.controller.contains('CarRequest') ?
          Expanded(child: buildDKX(context)) :
          widget.controller.contains('MeetingRoom') ?
          Expanded(child: buildDKPH(context))
              : Container(),
          Visibility(
              visible: widget.controller.contains('BusinessTrip') ||  widget.controller.contains('AdvanceRequest')
              ,child: Expanded(
            child: Column(
              children: [
                const SizedBox(height: 10,),
                ...fields
                    .map<Widget>((field) =>
                    buildInputField(field, formDataDynamic, controllers))
                    .toList(),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: grids.map<Widget>((grid) {
                      return buildTable(grid["controller"], grid["fields"],grid["title"]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          )),

        ],
      ),
    );
  }

  Widget buildBusiness(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 45,width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: BuildRowWithDatePicker(label: "Từ ngày", date: dateFrom.toString(),onTap: (){
                  FocusScope.of(context).requestFocus(FocusNode());
                  Utils.dateTimePickerCustom(context).then((value){
                    if(value != null){
                      setState(() {
                        dateFrom = dateFormat.parse(value.toString());
                        if (dateFrom.isAfter(dateTo)) {
                          dateFrom = DateTime.now();
                          Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                        }
                      });
                    }
                  });
                },),
              ),
              SizedBox(
                height: 40,width: 120,
                child: StatusDropdownIsMorning(
                  initialValue: isMorningFrom, // Mặc định là 1 khi thêm mới
                  onChanged: (int newStatus) {
                    setState(() {
                      isMorningFrom = newStatus;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 45,width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: BuildRowWithDatePicker(label: "Đến ngày", date: dateTo.toString(),onTap: (){
                  FocusScope.of(context).requestFocus(FocusNode());
                  Utils.dateTimePickerCustom(context).then((value){
                    if(value != null){
                      setState(() {
                        dateTo = dateFormat.parse(value.toString());
                        if (dateFrom.isAfter(dateTo)) {
                          dateTo = DateTime.now();
                          Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                        }
                      });
                    }
                  });
                },),
              ),
              SizedBox(
                height: 40,width: 120,
                child: StatusDropdownIsMorning(
                  initialValue: isMorningTo, // Mặc định là 1 khi thêm mới
                  onChanged: (int newStatus) {
                    setState(() {
                      isMorningTo = newStatus;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
          height: 10,
        ),
        const Text("Nội dung"),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          maxLines: 4,
          controller: descEditingController,
          decoration: InputDecoration(
            hintText: 'Nhập nội dung công tác ...',
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDayOff(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 45,width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: BuildRowWithDatePicker(label: "Từ ngày", date: dateFrom.toString(),onTap: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    Utils.dateTimePickerCustom(context).then((value){
                      if(value != null){
                        setState(() {
                          dateFrom = dateFormat.parse(value.toString());
                          if (dateFrom.isAfter(dateTo)) {
                            dateFrom = DateTime.now();
                            Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                          }
                        });
                      }
                    });
                  },),
                ),
                SizedBox(
                  height: 40,width: 120,
                  child: StatusDropdownIsMorning(
                    initialValue: isMorningFrom, // Mặc định là 1 khi thêm mới
                    onChanged: (int newStatus) {
                      setState(() {
                        isMorningFrom = newStatus;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: BuildRowWithDatePicker(label: "Đến ngày", date: dateTo.toString(),onTap: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    Utils.dateTimePickerCustom(context).then((value){
                      if(value != null){
                        setState(() {
                          dateTo = dateFormat.parse(value.toString());
                          if (dateFrom.isAfter(dateTo)) {
                            dateTo = DateTime.now();
                            Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                          }
                        });
                      }
                    });
                  },),
                ),
                SizedBox(
                  height: 40,width: 120,
                  child: StatusDropdownIsMorning(
                    initialValue: isMorningTo, // Mặc định là 1 khi thêm mới
                    onChanged: (int newStatus) {
                      setState(() {
                        isMorningTo = newStatus;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Expanded(
                  flex: 1,
                  child: Text('Số ngày   ')),
              Expanded(
                  flex: 4,
                  child:Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.6),
                      ),
                    ),
                    child: Text((
                        ((dateTo.difference(dateFrom).inDays + 1) * 2 -
                            (isMorningFrom == 2 ? 1 : 0) - (isMorningTo == 1 ? 1 : 0)) * 0.5
                    )
          .toString(),
                        style: const TextStyle(color: Colors.black,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis),
                  )
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Expanded(
                  flex: 1,
                  child: Text('Lý do   ')),
              Expanded(
                  flex: 4,
                  child:InkWell(
                    onTap: (){
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: const LookUpDynamicFormScreen(
                            title: 'Loại Nghỉ Phép', controller: 'DayOffType',chooseValues: true,
                          ),
                          withNavBar: true).then((values){
                        if(values != null && values[0] == 'Yeah'){
                           setState(() {
                             codeLeaveLetter = values[1];
                             nameLeaveLetter = values[2];
                           });
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(nameLeaveLetter.toString(),style: const TextStyle(color: Colors.black,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.search,color: Colors.grey,),
                        ],
                      ),
                    ),
                  )
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("Nội dung"),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            maxLines: 4,
            controller: descEditingController,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung nghỉ phép ...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget buildOverTime(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 45,width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: BuildRowWithDatePicker(label: "Ngày BĐ", date: dateFrom.toString(),onTap: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    Utils.dateTimePickerCustom(context).then((value){
                      if(value != null){
                        setState(() {
                          dateFrom = dateFormat.parse(value.toString());
                          if (dateFrom.isAfter(dateTo)) {
                            dateFrom = DateTime.now();
                            Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                          }else{
                            calculateHours();
                          }
                        });
                      }
                    });
                  },),
                ),
                SizedBox(
                  height: 40,
                  child: InkWell(
                    onTap:()async{
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTimeStart ?? TimeOfDay.now(),
                        initialEntryMode: entryMode,
                        orientation: orientation,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              materialTapTargetSize: tapTargetSize,
                            ),
                            child: Directionality(
                              textDirection: textDirection,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: use24HourTime,
                                ),
                                child: child!,
                              ),
                            ),
                          );
                        },
                      );
                      setState(() {
                        selectedTimeStart = time;
                        calculateHours();
                      });
                    },
                    child: Row(
                      children: [
                        const Text('Giờ BĐ:'),const SizedBox(width: 10,),
                        Text(
                            selectedTimeStart != null ?
                            dateFormating.DateFormat("hh:mm a").format(dateFormating.DateFormat("HH:mm").parse("${selectedTimeStart?.hour.toString().padLeft(2, '0')}:${selectedTimeStart?.minute.toString().padLeft(2, '0')}"))
                                : ''
                        ),const SizedBox(width: 10,),
                        const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: BuildRowWithDatePicker(label: "Ngày KT", date: dateTo.toString(),onTap: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    Utils.dateTimePickerCustom(context).then((value){
                      if(value != null){
                        setState(() {
                          dateTo = dateFormat.parse(value.toString());
                          if (dateFrom.isAfter(dateTo)) {
                            dateTo = DateTime.now();
                            Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                          }else{
                            calculateHours();
                          }
                        });
                      }
                    });
                  },),
                ),
                SizedBox(
                  height: 40,
                  child: InkWell(
                    onTap:()async{
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTimeEnd ?? TimeOfDay.now(),
                        initialEntryMode: entryMode,
                        orientation: orientation,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              materialTapTargetSize: tapTargetSize,
                            ),
                            child: Directionality(
                              textDirection: textDirection,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: use24HourTime,
                                ),
                                child: child!,
                              ),
                            ),
                          );
                        },
                      );
                      setState(() {
                        selectedTimeEnd = time;
                        calculateHours();
                      });
                    },
                    child: Row(
                      children: [
                        const Text('Giờ KT:'),const SizedBox(width: 10,),
                        Text(
                            selectedTimeEnd != null ?
                            dateFormating.DateFormat("hh:mm a").format(dateFormating.DateFormat("HH:mm").parse("${selectedTimeEnd?.hour.toString().padLeft(2, '0')}:${selectedTimeEnd?.minute.toString().padLeft(2, '0')}"))
                                : ''
                        ),const SizedBox(width: 10,),
                        const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Expanded(
                  flex: 1,
                  child: Text('Số giờ   ')),
              Expanded(
                  flex: 4,
                  child:Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.6),
                      ),
                    ),
                    child: Text(soGio.toString(),
                        style: const TextStyle(color: Colors.black,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis),
                  )
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("Nội dung"),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            maxLines: 4,
            controller: descEditingController,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung ...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget buildAdvanceRequest(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Row(
        children: [
          const Expanded(
              flex: 1,
              child: Text('Tiêu đề   ')),
          Expanded(
              flex: 4,
              child:TextFormField(
                maxLines: 1,
                controller: titleEditingController,
                decoration: InputDecoration(
                  hintText: 'Nhập tiêu đề ...',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              )
          )
        ],
      ),
    );
  }

  Widget buildGTCC(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BuildRowWithDatePicker(isTrueWidth: true,label: "Ngày đề nghị", date: dateRequest.toString(),onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
            Utils.dateTimePickerCustom(context).then((value){
              if(value != null){
                setState(() {
                  dateRequest = dateFormat.parse(value.toString());
                });
              }
            });
          },),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,width: double.infinity,
            child: Row(
              children: [
                Flexible(
                  child: BuildRowWithDatePicker(isTrueWidth: true,label: "Ngày BĐ", date: dateFrom.toString(),onTap: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    Utils.dateTimePickerCustom(context).then((value){
                      if(value != null){
                        setState(() {
                          dateFrom = dateFormat.parse(value.toString());
                          if (dateFrom.isAfter(dateTo)) {
                            dateFrom = DateTime.now();
                            Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                          }else{
                            calculateHours();
                          }
                        });
                      }
                    });
                  },),
                ),
                InkWell(
                  onTap:()async{
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: selectedTimeStart ?? TimeOfDay.now(),
                      initialEntryMode: entryMode,
                      orientation: orientation,
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            materialTapTargetSize: tapTargetSize,
                          ),
                          child: Directionality(
                            textDirection: textDirection,
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                alwaysUse24HourFormat: use24HourTime,
                              ),
                              child: child!,
                            ),
                          ),
                        );
                      },
                    );
                    setState(() {
                      selectedTimeStart = time;
                    });
                  },
                  child: Row(
                    children: [
                      const Text('Giờ BĐ:'),
                      const SizedBox(width: 10,),
                      Text(
                          selectedTimeStart != null ?
                          dateFormating.DateFormat("hh:mm a").format(dateFormating.DateFormat("HH:mm").parse("${selectedTimeStart?.hour.toString().padLeft(2, '0')}:${selectedTimeStart?.minute.toString().padLeft(2, '0')}"))
                              : ''
                      ),
                      const SizedBox(width: 10,),
                      const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,width: double.infinity,
            child: Row(
              children: [
                Flexible(
                  child: BuildRowWithDatePicker(isTrueWidth: true,label: "Ngày KT", date: dateTo.toString(),onTap: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    Utils.dateTimePickerCustom(context).then((value){
                      if(value != null){
                        setState(() {
                          dateTo = dateFormat.parse(value.toString());
                          if (dateFrom.isAfter(dateTo)) {
                            dateTo = DateTime.now();
                            Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                          }else{
                            calculateHours();
                          }
                        });
                      }
                    });
                  },),
                ),
                SizedBox(
                  height: 40,
                  child: InkWell(
                    onTap:()async{
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTimeEnd ?? TimeOfDay.now(),
                        initialEntryMode: entryMode,
                        orientation: orientation,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              materialTapTargetSize: tapTargetSize,
                            ),
                            child: Directionality(
                              textDirection: textDirection,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: use24HourTime,
                                ),
                                child: child!,
                              ),
                            ),
                          );
                        },
                      );
                      setState(() {
                        selectedTimeEnd = time;
                        calculateHours();
                      });
                    },
                    child: Row(
                      children: [
                        const Text('Giờ KT:'),
                        const SizedBox(width: 10,),
                        Text(
                            selectedTimeEnd != null ?
                            dateFormating.DateFormat("hh:mm a").format(dateFormating.DateFormat("HH:mm").parse("${selectedTimeEnd?.hour.toString().padLeft(2, '0')}:${selectedTimeEnd?.minute.toString().padLeft(2, '0')}"))
                                : ''
                        ),
                        const SizedBox(width: 10,),
                        const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("Tệp đính kèm"),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (){
                  showImageSourcePicker(context);
                },
                child: Container(
                  height: 45,width: 180,
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue
                  ),
                  child: Center(child: Row(children: [const Icon(Icons.attach_file,color: Colors.white,size: 15,),const SizedBox(width: 5,),
                    Text(_bloc.so_luong_anh > 0 ? '${_bloc.so_luong_anh} File tải lên' : 'Tải lên',style: const TextStyle(color: Colors.white,fontSize: 13),)],),),
                ),
              ),
              InkWell(
                onTap: (){
                  // setState(() {
                  //   _bloc.so_luong_anh = 0;
                  //   _bloc.listFileImage.clear();
                  // });
                  showDialog(
                    context: context,
                    builder: (context) => ImageViewerPopup(
                      imageFiles: _bloc.listFileImage,
                      onDelete: (index) {
                        setState(() {
                          _bloc.listFileImage.removeAt(index);
                          _bloc.so_luong_anh = _bloc.listFileImage.length;
                        });
                      },
                    ),
                  );

                },
                child: const Center(child: Row(children: [Icon(Icons.view_carousel_outlined,color: Colors.blue,size: 22,),SizedBox(width: 5,),
                  Text('Xem file đính kèm',style: TextStyle(color: Colors.black,fontSize: 13),)],),),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("Nội dung"),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            maxLines: 4,
            controller: descEditingController,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung ...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  late Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  int start = 2;


  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {
          setState(() {});
          timer.cancel();
          cancelLoaderDialog(context);
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
        if(image != null){
          showLoaderDialog(context);
          start = 2;
          startTimer();
          _bloc.listFileImage.add(File(image.path));
          _bloc.so_luong_anh = _bloc.listFileImage.length;
        }
      }
    });
  }

  Future<void> showImageSourcePicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  Navigator.of(context).pop(); // đóng popup
                  pickAndAddMultipleImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh mới'),
                onTap: () async {
                  Navigator.of(context).pop(); // đóng popup
                  getImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> pickAndAddMultipleImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        for (var path in result.paths) {
          if (path != null) {
            start = 2;
            startTimer();
            showLoaderDialog(context);
            _bloc.listFileImage.add(File(path));
            _bloc.so_luong_anh = _bloc.listFileImage.length;
          }
        }
      } else {
        // cancelLoaderDialog(context);
        Utils.showCustomToast(context,Icons.warning_amber,' Không có ảnh nào được chọn');
      }
    } catch (e) {
      cancelLoaderDialog(context);
      Utils.showCustomToast(context,Icons.warning_amber,' Lỗi khi chọn ảnh: $e');
    }
  }

  String idCar = '';
  String nameCar = '';
  Widget buildDKX(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                  flex: 1,
                  child: Text('Loại xe   ')),
              Expanded(
                  flex: 4,
                  child:InkWell(
                    onTap: (){
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: const LookUpDynamicFormScreen(
                            title: 'Loại xe', controller: 'Vehicle',chooseValues: true,
                          ),
                          withNavBar: true).then((values){
                        if(values != null && values[0] == 'Yeah'){
                          setState(() {
                            idCar = values[1];
                            nameCar = values[2];
                          });
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(nameCar.toString(),style: const TextStyle(color: Colors.black,),maxLines: 1,overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.search,color: Colors.grey,),
                        ],
                      ),
                    ),
                  )
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: BuildRowWithDatePicker(label: "Ngày BĐ", date: dateFrom.toString(),onTap: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    Utils.dateTimePickerCustom(context).then((value){
                      if(value != null){
                        setState(() {
                          dateFrom = dateFormat.parse(value.toString());
                          if (dateFrom.isAfter(dateTo)) {
                            dateFrom = DateTime.now();
                            Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                          }else{
                            calculateHours();
                          }
                        });
                      }
                    });
                  },),
                ),
                SizedBox(
                  height: 40,
                  child: InkWell(
                    onTap:()async{
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTimeStart ?? TimeOfDay.now(),
                        initialEntryMode: entryMode,
                        orientation: orientation,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              materialTapTargetSize: tapTargetSize,
                            ),
                            child: Directionality(
                              textDirection: textDirection,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: use24HourTime,
                                ),
                                child: child!,
                              ),
                            ),
                          );
                        },
                      );
                      setState(() {
                        selectedTimeStart = time;
                      });
                    },
                    child: Row(
                      children: [
                        const Text('Giờ BĐ:'),
                        const SizedBox(width: 10,),
                        Text(
                            selectedTimeStart != null ?
                            dateFormating.DateFormat("hh:mm a").format(dateFormating.DateFormat("HH:mm").parse("${selectedTimeStart?.hour.toString().padLeft(2, '0')}:${selectedTimeStart?.minute.toString().padLeft(2, '0')}"))
                                : ''
                        ),
                        const SizedBox(width: 10,),
                        const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: BuildRowWithDatePicker(label: "Ngày KT", date: dateTo.toString(),onTap: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    Utils.dateTimePickerCustom(context).then((value){
                      if(value != null){
                        setState(() {
                          dateTo = dateFormat.parse(value.toString());
                          if (dateFrom.isAfter(dateTo)) {
                            dateTo = DateTime.now();
                            Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                          }else{
                            calculateHours();
                          }

                        });
                      }
                    });
                  },),
                ),
                SizedBox(
                  height: 40,
                  child: InkWell(
                    onTap:()async{
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTimeEnd ?? TimeOfDay.now(),
                        initialEntryMode: entryMode,
                        orientation: orientation,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              materialTapTargetSize: tapTargetSize,
                            ),
                            child: Directionality(
                              textDirection: textDirection,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: use24HourTime,
                                ),
                                child: child!,
                              ),
                            ),
                          );
                        },
                      );
                      setState(() {
                        selectedTimeEnd = time;
                        calculateHours();
                      });
                    },
                    child: Row(
                      children: [
                        const Text('Giờ KT:'),
                        const SizedBox(width: 10,),
                        Text(
                            selectedTimeEnd != null ?
                            dateFormating.DateFormat("hh:mm a").format(dateFormating.DateFormat("HH:mm").parse("${selectedTimeEnd?.hour.toString().padLeft(2, '0')}:${selectedTimeEnd?.minute.toString().padLeft(2, '0')}"))
                                : ''
                        ),
                        const SizedBox(width: 10,),
                        const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 45,
            child: Row(
              children: [
                const Expanded(
                    flex: 1,
                    child: Text('Điểm đi   ')),
                Expanded(
                    flex: 4,
                    child:TextFormField(
                      maxLines: 1,
                      controller: addressStartEditingController,style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Nhập điểm đi ...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 45,
            child: Row(
              children: [
                const Expanded(
                    flex: 1,
                    child: Text('Điểm đến   ')),
                Expanded(
                    flex: 4,
                    child:TextFormField(
                      maxLines: 1,
                      controller: addressEndEditingController,style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Nhập điểm đến ...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 45,
            child: Row(
              children: [
                const Expanded(
                    flex: 1,
                    child: Text('Tên KH   ')),
                Expanded(
                    flex: 4,
                    child:TextFormField(
                      maxLines: 1,
                      controller: nameCustomerEditingController,style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Nhập tên khách hàng ...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 65,
            child: Row(
              children: [
                const Expanded(
                    flex: 1,
                    child: Text('SĐT KH   ')),
                Expanded(
                    flex: 4,
                    child:TextFormField(
                      maxLines: 1,
                      controller: phoneCustomerEditingController,style: const TextStyle(fontSize: 13),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: 'Nhập SĐT khách hàng ...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                )
              ],
            ),
          ),
          const Text("Nội dung"),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            maxLines: 4,
            controller: descEditingController,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung ...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String idRoom = '';
  String nameRoom = '';
  Widget buildDKPH(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 45,width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: BuildRowWithDatePicker(label: "Ngày BĐ", date: dateFrom.toString(),onTap: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    Utils.dateTimePickerCustom(context).then((value){
                      if(value != null){
                        setState(() {
                          dateFrom = dateFormat.parse(value.toString());
                          if (dateFrom.isAfter(dateTo)) {
                            dateFrom = DateTime.now();
                            Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                          }else {
                            calculateHours();
                          }
                        });
                      }
                    });
                  },),
                ),
                SizedBox(
                  height: 40,
                  child: InkWell(
                    onTap:()async{
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTimeStart ?? TimeOfDay.now(),
                        initialEntryMode: entryMode,
                        orientation: orientation,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              materialTapTargetSize: tapTargetSize,
                            ),
                            child: Directionality(
                              textDirection: textDirection,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: use24HourTime,
                                ),
                                child: child!,
                              ),
                            ),
                          );
                        },
                      );
                      setState(() {
                        selectedTimeStart = time;
                        calculateHours();
                      });
                    },
                    child: Row(
                      children: [
                        const Text('Giờ BĐ:'),const SizedBox(width: 10,),
                        Text(
                            selectedTimeStart != null ?
                            dateFormating.DateFormat("hh:mm a").format(dateFormating.DateFormat("HH:mm").parse("${selectedTimeStart?.hour.toString().padLeft(2, '0')}:${selectedTimeStart?.minute.toString().padLeft(2, '0')}"))
                                : ''
                        ),const SizedBox(width: 10,),
                        const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: BuildRowWithDatePicker(label: "Ngày KT", date: dateTo.toString(),onTap: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                    Utils.dateTimePickerCustom(context).then((value){
                      if(value != null){
                        setState(() {
                          dateTo = dateFormat.parse(value.toString());
                          if (dateFrom.isAfter(dateTo)) {
                            dateTo = DateTime.now();
                            Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
                          }else{
                            calculateHours();
                          }
                        });
                      }
                    });
                  },),
                ),
                SizedBox(
                  height: 40,
                  child: InkWell(
                    onTap:()async{
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTimeEnd ?? TimeOfDay.now(),
                        initialEntryMode: entryMode,
                        orientation: orientation,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              materialTapTargetSize: tapTargetSize,
                            ),
                            child: Directionality(
                              textDirection: textDirection,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: use24HourTime,
                                ),
                                child: child!,
                              ),
                            ),
                          );
                        },
                      );
                      setState(() {
                        selectedTimeEnd = time;
                        calculateHours();
                      });
                    },
                    child: Row(
                      children: [
                        const Text('Giờ KT:'),const SizedBox(width: 10,),
                        Text(
                            selectedTimeEnd != null ?
                            dateFormating.DateFormat("hh:mm a").format(dateFormating.DateFormat("HH:mm").parse("${selectedTimeEnd?.hour.toString().padLeft(2, '0')}:${selectedTimeEnd?.minute.toString().padLeft(2, '0')}"))
                                : ''
                        ),const SizedBox(width: 10,),
                        const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Expanded(
                  flex: 1,
                  child: Text('Phòng họp ')),
              Expanded(
                  flex: 2,
                  child:InkWell(
                    onTap: (){
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: const LookUpDynamicFormScreen(
                            title: 'DS phòng họp', controller: 'MeetingRoom',chooseValues: true,
                          ),
                          withNavBar: true).then((values){
                        if(values != null && values[0] == 'Yeah'){
                          setState(() {
                            idRoom = values[1];
                            nameRoom = values[2];
                          });
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(nameRoom.toString(),style: const TextStyle(color: Colors.black,fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.search,color: Colors.grey,),
                        ],
                      ),
                    ),
                  )
              )
            ],
          ),

          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 40,
            child: Row(
              children: [
                const Expanded(
                    flex: 1,
                    child: Text('Số lượng tham gia  ')),
                Expanded(
                    flex: 2,
                    child:TextFormField(
                      maxLines: 1,
                      controller: memberJoinEditingController,
                      keyboardType:  TextInputType.number,style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(top: 5,left: 8),
                        hintText: 'Nhập số lượng tham gia ...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,fontSize: 13
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 40,
            child: Row(
              children: [
                const Expanded(
                    flex: 1,
                    child: Text('Thành phần tham gia  ')),
                Expanded(
                    flex: 2,
                    child:TextFormField(
                      maxLines: 1,
                      controller: peopleJoinEditingController,
                      keyboardType:  TextInputType.text,style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(top: 5,left: 8),
                        hintText: 'Nhập thành phần tham gia ...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,fontSize: 13
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                )
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(child: InkWell(
                onTap: (){
                  setState(() {
                    isCheckRequest = !isCheckRequest;
                  });
                },
                child: SizedBox(
                  height: 45,
                  child: Row(
                    children: [
                      Checkbox(
                        value: isCheckRequest,
                        onChanged: (bool? newValue){
                          setState(() {
                            isCheckRequest = newValue ?? false;
                          });
                        },
                      ),
                      const Text('Yêu cầu chuẩn bị  '),
                    ],
                  ),
                ),
              ),),
              Expanded(child: InkWell(
                onTap: (){
                  setState(() {
                    isCheckHQBK = !isCheckHQBK;
                  });
                },
                child: SizedBox(
                  height: 45,
                  child: Row(
                    children: [
                      Checkbox(
                        value: isCheckHQBK,
                        onChanged: (bool? newValue){
                          setState(() {
                            isCheckHQBK = newValue ?? false;
                          });
                        },
                      ),
                      const Text('Hoa quả, bánh kẹo'),

                    ],
                  ),
                ),
              ),)
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(child: InkWell(
                onTap: (){
                  setState(() {
                    isCheckDU = !isCheckDU;
                  });
                },
                child: SizedBox(
                  height: 45,
                  child: Row(
                    children: [
                      Checkbox(
                        value: isCheckDU,
                        onChanged: (bool? newValue){
                          setState(() {
                            isCheckDU = newValue ?? false;
                          });
                        },
                      ),
                      const Text('Đồ uống  '),
                    ],
                  ),
                ),
              ),),
              Expanded(child: InkWell(
                onTap: (){
                  setState(() {
                    isCheckMC = !isCheckMC;
                  });
                },
                child: SizedBox(
                  height: 45,
                  child: Row(
                    children: [
                      Checkbox(
                        value: isCheckMC,
                        onChanged: (bool? newValue){
                          setState(() {
                            isCheckMC = newValue ?? false;
                          });
                        },
                      ),
                      const Text('Máy chiếu'),
                    ],
                  ),
                ),
              ),)
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("Yêu cầu khác"),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: requestOtherEditingController,
            decoration: InputDecoration(
              hintText: 'Nhập yêu cầu ...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text("Mục đích"),
          ),
          TextFormField(
            maxLines: 4,
            controller: descEditingController,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung ...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  calculateHours(){
    if(selectedTimeStart.toString().replaceAll('null', '').isNotEmpty && selectedTimeEnd.toString().replaceAll('null', '').isNotEmpty)
      {
        // Chuyển TimeOfDay sang chuỗi "HH:mm" (24 giờ)
        String timeStringStart = "${selectedTimeStart?.hour.toString().padLeft(2, '0')}:${selectedTimeStart?.minute.toString().padLeft(2, '0')}";
        String timeStringEnd = "${selectedTimeEnd?.hour.toString().padLeft(2, '0')}:${selectedTimeEnd?.minute.toString().padLeft(2, '0')}";

        // Parse đúng định dạng 24 giờ
        DateTime parsedTimeStart = dateFormating.DateFormat("HH:mm").parse(timeStringStart);
        DateTime parsedTimeEnd = dateFormating.DateFormat("HH:mm").parse(timeStringEnd);

        // Chuyển về định dạng 12 giờ (AM/PM)
        String formattedTimeStart = dateFormating.DateFormat("hh:mm a").format(parsedTimeStart);
        String formattedTimeEnd = dateFormating.DateFormat("hh:mm a").format(parsedTimeEnd);

        print(formattedTimeStart); // ✅ Output: "12:00 PM"

        soGio = Utils.calculateHoursDifference(
            '${dateFrom.toString().split(' ').first} $formattedTimeStart',
            '${dateTo.toString().split(' ').first} $formattedTimeEnd',context)!;
      }
  }

  /// **Hàm tạo các input field từ JSON**
  Widget buildInputField(Map<String, dynamic> field, Map<String, dynamic> formDataDynamic,
      Map<String, TextEditingController> controllers) {
    String title = field['title'];
    bool readOnly = field['readOnly'];
    var props = field['props'] ?? {}; // Đảm bảo props không null
    String name = field['name']; // Lấy tên trường
    // Lấy giá trị mặc định từ formDataDynamic nếu có
    var initialValue =
    formDataDynamic.containsKey(name) ? formDataDynamic[name] : null;

    if (initialValue.toString().isNotEmpty) {
      controllers[name]!.text = initialValue.toString();
    }

    if (props != null && props['style'] == 'DropDownList') {
      List<dynamic> items = props['item'] ?? []; // Đảm bảo items không null
      return DropdownButtonFormField(
        value: initialValue?.toString(), // Giá trị mặc định
        decoration:
        InputDecoration(labelText: title, border: const OutlineInputBorder()),
        items: items.map((item) {
          return DropdownMenuItem(
              value: item['value'], child: Text(item['text']));
        }).toList(),
        onChanged: readOnly
            ? null
            : (value) {
          controllers[name]!.text = value.toString();
        },
      );
    }

    return TextFormField(
      controller: controllers[name],
      decoration:
      InputDecoration(labelText: title, border: const OutlineInputBorder()),
      readOnly: readOnly,
      initialValue: initialValue?.toString(), // Giá trị mặc định
    );
  }

  void addRow(String controller) {
    setState(() {
      var grid = _bloc.jsonListData['data']['formDefines']['grids']
          .firstWhere((g) => g['controller'] == controller);

      var newRow = <String, dynamic>{};
      for (var field in grid['fields']){
          newRow[field['name'] as String] = _getDefaultValue(field);
      }
      tableData[controller]!.add(newRow);

    });
  }

  void deleteSelectedRows(String controller) {
    setState(() {
      tableData[controller]!.removeWhere((row) => selectedRows[controller]!
          .contains(tableData[controller]!.indexOf(row)));
      selectedRows[controller]!.clear();
    });
  }

  dynamic _getDefaultValue(Map<String, dynamic> field) {
    String? type = field['type'] as String?;
    if (type == "Int") return 0; // Mặc định số nguyên là 0
    if (type == "Double") return 0.0; // Mặc định số thực là 0.0
    if (type == "Bool") return false; // Mặc định boolean là false
    return ""; // Mặc định các kiểu khác là chuỗi rỗng
  }

  /// **Hàm tạo bảng từ JSON**
  Widget buildTable(String controller, List<dynamic> fields, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: [
              ...fields.where((field) => !field['hidden'] == true)
                  .map((field) => DataColumn(label: Text(field['title']))),
            ],
            rows: List.generate(tableData[controller]!.length, (index) {
              var row = tableData[controller]![index];
              return DataRow(
                selected: selectedRows[controller]!.contains(index),
                onSelectChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      selectedRows[controller]!.add(index);
                    } else {
                      selectedRows[controller]!.remove(index);
                    }
                  });
                },
                cells: [
                  ...fields.where((field)=> field['hidden'] != true)
                      .map((field)=> DataCell(SizedBox(
                    // width: 150, // Đặt chiều rộng cho từng ô
                    child: buildTableCell(field, row, controller,index),
                  ))),
                ],
              );
            }),
          ),
        ),
        Row(
          children: [
            ElevatedButton(
                onPressed: () => addRow(controller), child: const Text("Thêm dòng")),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: selectedRows[controller]!.isNotEmpty
                  ? () => deleteSelectedRows(controller)
                  : null,
              child: const Text("Xóa dòng đã chọn"),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  final dateFormating.NumberFormat currencyFormat = dateFormating.NumberFormat("#,##0", "vi_VN");
  /// **Hàm tạo từng ô trong bảng**
  Widget buildTableCell(
      Map<String, dynamic> field, Map<String, dynamic> row, String controller, int rowIndex) {
    String fieldName = field['name'];
    bool readOnly = field['readOnly'];
    var props = field['props'];

    if (props != null && props['style'] == 'AutoComplete') {
      return GestureDetector(
        onTap: (){
          PersistentNavBarNavigator.pushNewScreen(context,
              screen: LookUpDynamicFormScreen(
                  title: widget.title, controller: props['controller'],
              ),
              withNavBar: true).then((values){
                if(values[0] == 'Yeah'){
                  List<Map<String, String>> lookupData = [];
                  lookupData = convertLookupData(values[1]);
                  setState(() {
                    if(lookupData.isNotEmpty){
                      var item = lookupData[values[2]];
                      row[field['name']] = item[field['name']];
                      if (field['props']?['referenceTo'] != null) {
                        List<String> referenceFields =
                        field['props']['referenceTo'].split(",");
                        for (var refField in referenceFields) {
                          row[refField.trim()] = item[refField.trim()];
                        }
                      }
                    }
                  });
                }
          });
        },
        child: Text(row[field['name']]
            .toString()
            .trim()
            .replaceAll("null", "")
            .isNotEmpty
            ? row[field['name']].toString().trim()
            : "Chọn dữ liệu"),
      );
    }

    // Nếu là số và có style 'Numeric', format tiền tệ
    if (props != null && (props['style'] == 'Numeric' || props['style'] == 'Int')) {
      String key = "${row.hashCode}-$fieldName";

      if (!controllersTextEdit.containsKey(key)) {
        controllersTextEdit[key] = TextEditingController();
      }

      // Cập nhật giá trị định dạng tiền tệ
      double value = (row[fieldName] ?? 0).toDouble();
      controllersTextEdit[key]!.text = currencyFormat.format(value);

      return TextField(
        controller: controllersTextEdit[key],
        keyboardType: TextInputType.number,
        inputFormatters: [], // Có thể thêm `FilteringTextInputFormatter.digitsOnly` nếu cần
        readOnly: readOnly,
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (value) {
          // Xóa ký tự không phải số trước khi cập nhật
          String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
          row[fieldName] = double.tryParse(newValue) ?? 0;
          controllersTextEdit[key]!.text = currencyFormat.format(row[fieldName]);
        },
      );
    }


    String key = "$rowIndex-$fieldName";
    // Nếu controller chưa tồn tại, tạo mới và gán giá trị từ row
    if (!controllersTextEdit.containsKey(key)) {
      controllersTextEdit[key] = TextEditingController(text: (row[fieldName] ?? "").toString());
    }else{
      controllersTextEdit[key]!.text = (row[fieldName] ?? "").toString();
    }
    return TextField(
      controller: controllersTextEdit[key],
      readOnly: readOnly,
      onChanged: (value) {
        setState(() {
          row[fieldName] = value;
        });
      },
      // decoration: InputDecoration(border: OutlineInputBorder()),
      decoration: const InputDecoration(border: InputBorder.none),
    );
  }

  List<Map<String, String>> convertLookupData(List<dynamic> rawData) {
    List<Map<String, String>> dynamicLookup = [];

    for (var item in rawData) {
      if (item is Map<String, dynamic>) {
        Map<String, String> convertedItem = {};
        item.forEach((key, value) {
          convertedItem[key] = value.toString().trim(); // Chuyển thành String và loại bỏ khoảng trắng
        });

        dynamicLookup.add(convertedItem);
      }
    }

    return dynamicLookup;
  }
}
