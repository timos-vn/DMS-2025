import 'dart:math';

import 'package:dms/model/database/data_local.dart';
import 'package:dms/screen/menu/stage/component/search_semi_production_screen.dart';
import 'package:dms/widget/custom_input_timer.dart';
import 'package:dms/widget/custom_update_quantity_materials.dart';
import 'package:dms/widget/custom_update_quantity_semi.dart';
import 'package:dms/widget/input_quatity_waste.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as dateFormating;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../model/network/request/create_manufacturing_request.dart';
import '../../../../model/network/response/get_item_materials_response.dart';
import '../../../../model/network/response/get_voucher_transaction_response.dart';
import '../../../../model/network/response/report_field_lookup_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/utils.dart';
import '../../../filter/filter_page.dart';
import '../../../sell/component/input_address_popup.dart';
import '../stage_statistic/stage_statistic_bloc.dart';
import '../stage_statistic/stage_statistic_event.dart';
import '../stage_statistic/stage_statistic_state.dart';

class StageStatisticV2Screen extends StatefulWidget {
  const StageStatisticV2Screen({Key? key}) : super(key: key);

  @override
  State<StageStatisticV2Screen> createState() => _StageStatisticV2ScreenState();
}

class _StageStatisticV2ScreenState extends State<StageStatisticV2Screen> with TickerProviderStateMixin{

  late StageStatisticBloc _bloc;
  late TextEditingController quantityWorkerController  =  TextEditingController();
  late TextEditingController contentController  =  TextEditingController();
  bool expanded = false;
  late TabController tabController;
  List<IconData> listIcons = [
    FluentIcons.production_20_filled,
    FluentIcons.content_settings_20_filled,
    EneftyIcons.receipt_item_outline,
    FluentIcons.device_meeting_room_remote_20_filled];
  VoucherTransactionResponseData giaoDich = VoucherTransactionResponseData();
  String codePX = '';String namePX = '';String maLoTrinh = '';String ghiChu = '';
  String codeWorker = '';String nameWorker = '';
  String codeCa = '';String nameCa = '';
  String codeLsx = '';String nameLsx = '';
  String codeCD = '';String nameCD = '';

  TimeOfDay? selectedTimeStart;
  TimeOfDay? selectedTimeEnd;

  String? gioBD;
  String? gioKT;

  TimePickerEntryMode entryMode = TimePickerEntryMode.dialOnly;
  Orientation? orientation;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  TextDirection textDirection = TextDirection.ltr;
  bool use24HourTime = false;
  var dateFormat = dateFormating.DateFormat("hh:mm a");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = StageStatisticBloc(context);
    tabController = TabController(vsync: this, length: listIcons.length);
    DataLocal.listGetItemMaterialsResponse.clear();
    DataLocal.listSemiProduction.clear();
    _bloc.add(GetPrefs());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StageStatisticBloc,StageStatisticState>(
      bloc: _bloc,
      listener: (context,state){
        if(state is VoucherTransactionSuccess){
          if(state.type == 1){
            if(_bloc.listVoucherTransaction.isNotEmpty){
              giaoDich = _bloc.listVoucherTransaction[0];
            }
          }else{
            showBottomSheetInformation();
          }
        }
        if(state is CreateManufacturingSuccess){
          Utils.showCustomToast(context, Icons.check, 'Tạo phiếu thành công');
          _bloc.reset();
          DataLocal.listSemiProduction.clear();
          DataLocal.listWaste.clear();
          DataLocal.listGetItemMaterialsResponse.clear();
          DataLocal.listMachine.clear();
          giaoDich = VoucherTransactionResponseData();
          codePX = '';namePX = '';maLoTrinh = '';ghiChu = '';
          codeWorker = '';nameWorker = '';
          codeCa = '';nameCa = '';
          codeLsx = '';nameLsx = '';
          codeCD = '';nameCD = '';

        }
        else if(state is SearchSemiProductionSuccess){
          if(_bloc.searchResults.isNotEmpty){
            DataLocal.listSemiProduction.clear();
            for (var element in _bloc.searchResults) {
              DataLocal.listSemiProduction.add(element);
            }
          }
        }
        else if(state is GetPrefsSuccess){
          _bloc.add(GetListVoucherTransaction(vcCode: 'SF1', type: 1));
        }
      },
      child: BlocBuilder<StageStatisticBloc,StageStatisticState>(
        bloc: _bloc,
        builder: (BuildContext context, StageStatisticState state){
          return Scaffold(
            body: Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is GetListStageEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is StageStatisticLoading,
                  child: const PendingAction(),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  buildBody(BuildContext context,StageStatisticState state) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          expanded == true ? buildMasterExpanded() : buildMasterHide() ,
          const SizedBox(height: 4,),
          InkWell(
            onTap: (){
              setState(() {
                expanded = !expanded;
              });
            },
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  const SizedBox(width: 5,),
                  Text(expanded == false ? 'Mở rộng' : 'Thu gọn',style: const TextStyle(color: Colors.blueGrey,fontSize: 12.5),),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(expanded == false ? EneftyIcons.direct_down_outline : EneftyIcons.direct_up_outline,size: 15,),
                  ),
                  const Expanded(child: Divider()),

                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16,right: 16,top: 5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.0),
                border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2)),
              ),
              child: TabBar(
                controller: tabController,
                unselectedLabelColor: Colors.grey.withOpacity(0.8),
                labelColor: Colors.red,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                isScrollable: false,
                indicatorPadding: const EdgeInsets.all(0),
                indicatorColor: Colors.red,
                dividerColor: Colors.red,automaticIndicatorColorAdjustment: true,
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                indicator: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.red,
                        width: 2
                    ),
                  ),
                ),
                tabs: List<Widget>.generate(listIcons.length, (int index) {
                  return Tab(
                    icon: Icon( listIcons[index]),
                  );
                }),
                onTap: (index){
                  // setState(() {
                  //   tabIndex = index;
                  // });
                },
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  color: grey_100,
                  child: TabBarView(
                      controller: tabController,
                      children: List<Widget>.generate(listIcons.length, (int index) {
                        for (int i = 0; i <= listIcons.length; i++) {
                          if(index == 0){
                            return buildSemi(state);
                          }else if(index == 1){
                            return buildMaterials(state);
                          }else if(index == 2){
                            return buildWaste(state);
                          }else{
                            return buildMachine(state);
                          }
                        }
                        return const Text('');
                      })),
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 10),
            child: GestureDetector(
              onTap: (){
                if( giaoDich.maGd.toString().replaceAll('null', '').isNotEmpty && codePX.toString().replaceAll('null', '').isNotEmpty &&
                DataLocal.listSemiProduction.isNotEmpty
                    && codeLsx.toString().replaceAll('null', '').isNotEmpty
                    && gioBD.toString().replaceAll('null', '').isNotEmpty
                    && gioKT.toString().replaceAll('null', '').isNotEmpty
                    && codeWorker.toString().replaceAll('null', '').isNotEmpty &&
                    codeCa.toString().replaceAll('null', '').isNotEmpty && codeCD.toString().replaceAll('null', '').isNotEmpty &&
                    giaoDich.maGd.toString().isNotEmpty && giaoDich.maGd.toString() != 'null'){
                  _bloc.add(CreateManufacturingEvent(
                    giaoDich: giaoDich,
                    codePX: codePX,
                    maLoTrinh: maLoTrinh,
                    ghiChu: ghiChu,
                    codeWorker: codeWorker,
                    codeCa: codeCa,
                    quantityWorker: quantityWorkerController.text.toString().replaceAll('null', '').isNotEmpty ? quantityWorkerController.text.toString().replaceAll('null', '') : "1",
                    codeLsx: codeLsx,codeCD:codeCD,
                    timeStart: gioBD.toString(),
                    timeEnd:  gioKT.toString(),
                  ));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber, 'Úi, Kiểm tra lại thông tin bạn êi');
                }
              },
              child: Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24)
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Xác nhận'
                      ,style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildMasterHide(){
    return Padding(
      padding: const EdgeInsets.only(left: 8,right: 8,top: 10),
      child: Column(
        children: [
          InkWell(
            onTap: (){
              _bloc.add(GetListVoucherTransaction(vcCode: 'SF1', type: 0));
            },
            child: Row(
              children: [
                const Expanded(
                    flex: 2,
                    child: Text('Loại giao dịch:')),
                Expanded(
                    flex: 5,
                    child: Align(alignment: Alignment.center,child: Text((giaoDich.maGd.toString().isNotEmpty && giaoDich.maGd.toString() != 'null')
                        ?
                    '[${giaoDich.maGd.toString().trim()}] ${giaoDich.tenGd.toString().trim()}' : ''))),
                const Icon(EneftyIcons.search_normal_2_outline,color: accent,size: 15,),
                Container(width: 1,height: 22,color: Colors.transparent,),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 10,),
          InkWell(
            onTap: (){
              showDialog(
                  context: context,
                  builder: (context) => const FilterScreen(controller: 'dmpx_lookup',
                    listItem: null,show: false,)).then((value){
                if(value != null){
                    codePX = value[0];
                    namePX = value[1];
                    _bloc.add(RefreshUpdateItemBarCodeEvent());
                }
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2,
                          child: Text('P.Xưởng:')),
                      Expanded(
                          flex: 5,
                          child: Align(alignment: Alignment.center,child: Text(namePX.toString().trim()))),
                      const Icon(EneftyIcons.search_normal_2_outline,color: accent,size: 15,)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildMasterExpanded(){
    return Padding(
      padding: const EdgeInsets.only(left: 8,right: 8,top: 10),
      child: Column(
        children: [
          InkWell(
            onTap: (){
              _bloc.add(GetListVoucherTransaction(vcCode: 'SF1', type: 0));
            },
            child: Row(
              children: [
                const Expanded(
                    flex: 2,
                    child: Text('Loại giao dịch:')),
                Expanded(
                    flex: 5,
                    child: Align(alignment: Alignment.center,child: Text((giaoDich.maGd.toString().isNotEmpty && giaoDich.maGd.toString() != 'null')
                        ?
                    '[${giaoDich.maGd.toString().trim()}] ${giaoDich.tenGd.toString().trim()}' : ''))),
                const Icon(EneftyIcons.search_normal_2_outline,color: accent,size: 15,),
                Container(width: 1,height: 22,color: Colors.transparent,),
              ],
            ),
          ),
          const Divider(),
          InkWell(
            onTap: (){
              showDialog(
                  context: context,
                  builder: (context) => const FilterScreen(controller: 'dmpx_lookup',
                    listItem: null,show: false,)).then((value){
                if(value != null){
                    codePX = value[0];
                    namePX = value[1];
                    _bloc.add(RefreshUpdateItemBarCodeEvent());
                }
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2,
                          child: Text('P.Xưởng:')),
                      Expanded(
                          flex: 5,
                          child: Align(alignment: Alignment.center,child: Text(namePX.toString().trim()))),
                      const Icon(EneftyIcons.search_normal_2_outline,color: accent,size: 15,)
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const SearchSemiProductionScreen(
                typeView: 2,
                typeRequest: true,
              ))).then((value){
                if(value != null){
                  codeLsx = value[0]; nameLsx = value[1];
                  maLoTrinh = value[2];
                  codeCD = '';
                  nameCD = '';
                  _bloc.add(RefreshUpdateItemBarCodeEvent());
                }
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2,
                          child: Text('Lệnh sx:')),
                      Expanded(
                          flex: 5,
                          child: Align(alignment: Alignment.center,child: Text(nameLsx.toString()))),
                      const Icon(EneftyIcons.search_normal_2_outline,color: accent,size: 15,)
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: (){
                    if(codeLsx.isNotEmpty && codeLsx != 'null'){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchSemiProductionScreen(
                        typeView: 2,
                        typeRequest: false,
                        request: codeLsx.toString(),
                        route: maLoTrinh.toString(),
                      ))).then((value){
                        if(value != null){
                          codeCD = value[0]; nameCD = value[1];
                          if(codeLsx.isNotEmpty && codeLsx != 'null'){
                            DataLocal.listSemiProduction.clear();
                            DataLocal.listGetItemMaterialsResponse.clear();
                            _bloc.searchResults.clear();
                            _bloc.add(SearchSemiProduction(
                              isLoadMore: false,
                              lsx: codeLsx.toString(),
                              section: codeCD.toString(),
                              searchText: '',
                              isRefresh: false,));
                          }else {
                            _bloc.add(RefreshUpdateItemBarCodeEvent());
                          }
                        }
                      });
                    }else{
                      Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng chọn Yêu cầu sản xuất trước đó');
                    }
                  },
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2,
                          child: Text('Công đoạn:')),
                      Expanded( flex: 5,child: Align(alignment:Alignment.center,child: Text(nameCD.toString()))),
                      const Icon(EneftyIcons.search_normal_2_outline,color: accent,size: 15,)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16,right: 0),
                child: Container(width: 1,height: 18,color: Colors.blueGrey,),
              ),
              InkWell(
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (context) => const FilterScreen(controller: 'dmca_lookup',
                        listItem: null,show: false,)).then((value){
                    if(value != null){
                        codeCa = value[0];
                        nameCa = value[1];
                        gioBD = value[2];
                        gioKT = value[3];
                        _bloc.add(RefreshUpdateItemBarCodeEvent());
                    }
                  });
                },
                child: Container(
                  height: 35,
                  width: 90,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(nameCa.toString().trim()??'Ca'),
                    ],
                  ),
                ),
              ),
              const Icon(EneftyIcons.search_normal_2_outline,color: accent,size: 15,)
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (context) => const FilterScreen(controller: 'dmnc_lookup',
                          listItem: null,show: false,)).then((value){
                      if(value != null){
                        codeWorker = value[0];
                        nameWorker = value[1];
                        _bloc.add(RefreshUpdateItemBarCodeEvent());
                      }
                    });
                  },
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2,
                          child: Text('Vận hành:')),
                      Expanded( flex: 5,child: Align(alignment: Alignment.center,child: Text(nameWorker.toString().trim()))),
                      const Icon(EneftyIcons.search_normal_2_outline,color: accent,size: 15,)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16,right: 16),
                child: Container(width: 1,height: 18,color: Colors.blueGrey,),
              ),
              Container(
                height: 35,
                width: 90,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: grey_100
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                        onTap: (){
                          int qty = 0;
                          qty = int.parse(quantityWorkerController.text.toString().isNotEmpty == true ? quantityWorkerController.text.toString() : '1');
                          if(qty > 1){
                              qty = qty - 1;
                              quantityWorkerController.text = qty.toString();
                              _bloc.add(RefreshUpdateItemBarCodeEvent());
                          }
                        },
                        child: const SizedBox(
                            height: 35,width: 25,
                            child: Icon(FluentIcons.subtract_12_filled,size: 15,))),
                    Container(
                      color: Colors.transparent,
                      width: 35,
                      child: TextField(
                        autofocus: false,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(fontSize: 14, color: accent),
                        controller: quantityWorkerController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onChanged: (text){
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: transparent,
                            hintText: "1",
                            hintStyle: TextStyle(color: accent),
                            contentPadding: EdgeInsets.only(
                                bottom: 12, top: 0)
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: (){
                          int qty = 0;
                          qty = int.parse(quantityWorkerController.text.toString().isNotEmpty == true ? quantityWorkerController.text.toString() : '1');
                            qty = qty + 1;
                            quantityWorkerController.text = qty.toString();
                            _bloc.add(RefreshUpdateItemBarCodeEvent());
                        },
                        child: const SizedBox(
                            width: 25,
                            height: 35,child: Icon(FluentIcons.add_12_filled,size: 15))),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 5,),
          Row(
            children: [
              Expanded(
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
                    selectedTimeStart = time;
                    gioBD = selectedTimeStart != null ?
                    dateFormat.format(dateFormating.DateFormat("hh:mm").parse("${selectedTimeStart?.hour.toString()}:${selectedTimeStart?.minute.toString()}"))
                        : '';
                    _bloc.add(RefreshUpdateItemBarCodeEvent());
                  },
                  child: Row(
                    children: [
                      const Text('Time Start:'),
                      Expanded(
                          child: Align(alignment: Alignment.center,child: Text(
                              gioBD.toString().replaceAll('null', '')
                          ))),
                      const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16,right: 16),
                child: Container(width: 1,height: 18,color: Colors.blueGrey,),
              ),
              Expanded(
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
                    selectedTimeEnd = time;
                    gioKT = selectedTimeEnd != null ?
                    dateFormat.format(dateFormating.DateFormat("hh:mm").parse("${selectedTimeEnd?.hour.toString()}:${selectedTimeEnd?.minute.toString()}"))
                        : '';
                    _bloc.add(RefreshUpdateItemBarCodeEvent());
                  },
                  child: Row(
                    children: [
                      const Text('Time End:'),
                      Expanded(
                          child: Align(alignment: Alignment.center,child: Text(
                              gioKT.toString().replaceAll('null', '')
                          ))),
                      const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          InkWell(
            onTap: (){
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return InputAddressPopup(note: (ghiChu.toString().isNotEmpty && ghiChu != '' && ghiChu != "null") ? ghiChu.toString() : "",
                      title: 'Thêm ghi chú cho đơn hàng',desc: 'Vui lòng nhập ghi chú',convertMoney: false, inputNumber: false,);
                  }).then((note){
                if(note != null){
                  ghiChu = note;
                  _bloc.add(RefreshUpdateItemBarCodeEvent());
                }
              });
            },
            child: SizedBox(
              height: 35,
              child: Padding(
                padding: const EdgeInsets.only(top: 0,left: 4,right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ghi chú:',style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic,decoration: TextDecoration.underline,fontSize: 12),),
                    const SizedBox(width: 12,),
                    Expanded(child: Align(
                        alignment: Alignment.centerRight,
                        child: Text((ghiChu.toString().replaceAll('null', '').isNotEmpty) ? ghiChu.toString() : "Viết tin nhắn...",style: const TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showBottomSheetInformation(){
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
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25)
                )
            ),
            margin: MediaQuery.of(context).viewInsets,
            child: FractionallySizedBox(
              heightFactor: 0.35,
              child: StatefulBuilder(
                builder: (BuildContext context,StateSetter myState){
                  return Padding(
                    padding: const EdgeInsets.only(top: 10,bottom: 0),
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25),
                              topLeft: Radius.circular(25)
                          )
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0,left: 16,right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.check,color: Colors.white,),
                                const Text('Tuỳ chọn',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),),
                                InkWell(
                                    onTap: ()=> Navigator.pop(context),
                                    child: const Icon(Icons.close,color: Colors.black,)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5,),
                          const Divider(color: Colors.blueGrey,),
                          const SizedBox(height: 5,),
                          Expanded(child: ListView.builder(
                              itemCount: _bloc.listVoucherTransaction.length,
                              padding: const EdgeInsets.only(top: 10),
                              itemBuilder: (BuildContext context, int index){
                                return InkWell(
                                  onTap: (){
                                    Navigator.pop(context,_bloc.listVoucherTransaction[index]);
                                  },
                                  child: Card(
                                    semanticContainer: true,
                                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '#${_bloc.listVoucherTransaction[index].maGd.toString().trim()}',
                                            style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                            maxLines: 2,overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            _bloc.listVoucherTransaction[index].tenGd.toString().toUpperCase(),
                                            style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                            maxLines: 2,overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
    ).then((value){
      if(value != null){
        setState(() {
          giaoDich = value;
        });
      }
    });
  }

  buildSemi(StageStatisticState state){
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Danh sách bán thành phẩm'),
            )),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const SearchSemiProductionScreen(
                  typeView: 1,
                  typeRequest: false,
                ))).then((value) => _bloc.add(RefreshUpdateItemBarCodeEvent()));
              },
              child: const SizedBox(
                height: 30,
                width: 50,
                child: Icon(Icons.addchart_outlined,color: Colors.black,size: 20,),
              ),
            ),
          ],
        ),
        Expanded(
            child: ListView.builder(
                itemCount: DataLocal.listSemiProduction.length,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index){
                  return InkWell(
                    onTap: (){
                      showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return UpdateQuantitySemi(
                              nameWorker:  DataLocal.listSemiProduction[index].nameWorker.toString(),
                              nameGWorker:  DataLocal.listSemiProduction[index].nameGWorker.toString(),
                              codeGWorker:  DataLocal.listSemiProduction[index].codeGWorker.toString(),
                              codeWorker:  DataLocal.listSemiProduction[index].codeWorker.toString(),
                              quantity:  DataLocal.listSemiProduction[index].soLuong.toString(),
                            );
                          }).then((values){
                        if(values != null){
                          DataLocal.listSemiProduction[index].soLuong = double.parse(values[0].toString().isNotEmpty == true ? values[0].toString() : '0');
                          DataLocal.listSemiProduction[index].codeWorker = values[1];
                          DataLocal.listSemiProduction[index].nameWorker = values[2];
                          DataLocal.listSemiProduction[index].codeGWorker = values[3];
                          DataLocal.listSemiProduction[index].nameGWorker = values[3];
                          Utils.showCustomToast(context, EneftyIcons.check_outline, 'Cập nhật thành công');
                          _bloc.add(GetItemMaterialsEvent(
                            item: DataLocal.listSemiProduction[index].maVt.toString(),
                            itemValues: DataLocal.listSemiProduction[index],
                          ));
                        }
                      });
                    },
                    child: Card(
                      semanticContainer: true,
                      margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10,right: 6,bottom: 5,left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '[${DataLocal.listSemiProduction[index].maVt.toString().trim()}] ${DataLocal.listSemiProduction[index].tenVt.toString().toUpperCase()}',
                                    style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                    maxLines: 2,overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5,),
                                  SizedBox(
                                    height: 35,
                                    child: Row(
                                      children: [
                                        const Icon(EneftyIcons.profile_outline,color: accent,size: 15,),
                                        const SizedBox(width: 5,),
                                        Expanded(
                                          child: Text('KH: ${DataLocal.listSemiProduction[index].ten_kh.toString().replaceAll('null', '')}',
                                            textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 35,
                                    child:  Row(
                                      children: [
                                        Icon(MdiIcons.accountMultipleOutline,color: accent,size: 15,),
                                        const SizedBox(width: 5,),
                                        Expanded(
                                          child: Text('NVBH: ${DataLocal.listSemiProduction[index].ten_nvbh.toString().replaceAll('null', '')}',
                                            textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  SizedBox(
                                    height: 35,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(EneftyIcons.profile_outline,color: accent,size: 15,),
                                            const SizedBox(width: 5,),
                                            Text('Nhân công: ${DataLocal.listSemiProduction[index].nameWorker.toString().replaceAll('null', '')}',
                                              textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 5,),
                                        Row(
                                          children: [
                                            Icon(MdiIcons.accountMultipleOutline,color: accent,size: 15,),
                                            const SizedBox(width: 5,),
                                            Text('Nhóm nhân công: ${DataLocal.listSemiProduction[index].nameGWorker.toString().replaceAll('null', '')}',
                                              textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6,bottom: 5),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(EneftyIcons.receipt_edit_outline,color: Colors.grey,size: 20,),
                                        const SizedBox(width: 5,),
                                        Expanded(
                                          child: SizedBox(
                                            height: 35,
                                            child: Row(
                                              children: [
                                                Text(DataLocal.listSemiProduction[index].soLuong.toString(),
                                                  textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(width: 5,),
                                                Text(DataLocal.listSemiProduction[index].dvt??'Chưa cập nhật đơn vị tính',
                                                  textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                            onTap: (){
                                              _bloc.add(DeleteSemiItemEvent(item:  DataLocal.listSemiProduction[index]));
                                            },
                                            child: const Icon(EneftyIcons.trash_outline,color: accent,size: 20)),
                                      ],
                                    ),
                                  ),
                                ],
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
        Visibility(
          visible: state is EmptySearchSemiProductionState,
          child: const Center(
            child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
          ),
        ),
      ],
    );
  }

  buildMaterials(StageStatisticState state){
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Danh sách nguyên phụ liệu'),
            )),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const SearchSemiProductionScreen(
                  typeView: 1,
                  addToMaterials: true,
                ))).then((value) => _bloc.add(RefreshUpdateItemBarCodeEvent()));
              },
              child: const SizedBox(
                height: 30,
                width: 50,
                child: Icon(Icons.addchart_outlined,color: Colors.black,size: 20,),
              ),
            ),
          ],
        ),
        Expanded(
            child: ListView.builder(
                itemCount: DataLocal.listGetItemMaterialsResponse.length,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index){
                  return Card(
                    semanticContainer: true,
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10,right: 6,bottom: 5,left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '[${DataLocal.listGetItemMaterialsResponse[index].maVt.toString().trim()}] ${DataLocal.listGetItemMaterialsResponse[index].tenVt.toString().toUpperCase()}',
                                  style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                  maxLines: 2,overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5,),
                                InkWell(
                                  onTap: (){
                                    showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (context) {
                                          return const UpdateQuantityMaterials();
                                        }).then((value){
                                      if(value != null){
                                        GetItemMaterialsResponseData itemVl = GetItemMaterialsResponseData(
                                            maVt: DataLocal.listGetItemMaterialsResponse[index].maVt,
                                            tenVt: DataLocal.listGetItemMaterialsResponse[index].tenVt,
                                            soLuong: DataLocal.listGetItemMaterialsResponse[index].soLuong,
                                            dvt: DataLocal.listGetItemMaterialsResponse[index].dvt,
                                            ngayCt1: '',
                                            soLuongTiepNhan: double.parse(value[0]??'0'),
                                            soLuongSuDung: (double.parse(value[0]??'0') - (double.parse(value[1]??'0'))),
                                            soLuongConLai: double.parse(value[1]??'0')
                                        );
                                        if(DataLocal.listGetItemMaterialsResponse.isEmpty){
                                          DataLocal.listGetItemMaterialsResponse.add(itemVl);
                                        }
                                        else{
                                          int indexCheck = -1;
                                          for(int i = 0; i < DataLocal.listGetItemMaterialsResponse.length; i++){
                                            if(DataLocal.listGetItemMaterialsResponse[i].maVt.toString().trim() == itemVl.maVt.toString().trim()){
                                              indexCheck = i;
                                              itemVl.maVtSemi = DataLocal.listGetItemMaterialsResponse[i].maVtSemi;
                                              itemVl.soLuongBanDau = DataLocal.listGetItemMaterialsResponse[i].soLuongBanDau;
                                              itemVl.soLuong = DataLocal.listGetItemMaterialsResponse[i].soLuong;
                                            }
                                          }
                                          if(indexCheck >= 0){
                                            DataLocal.listGetItemMaterialsResponse.removeAt(indexCheck);
                                            DataLocal.listGetItemMaterialsResponse.insert(indexCheck,itemVl);
                                          }else{
                                            DataLocal.listGetItemMaterialsResponse.add(itemVl);
                                          }
                                        }
                                        Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm vào danh sách NPL thành công');
                                        _bloc.add(RefreshUpdateItemBarCodeEvent());
                                      }
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 6,bottom: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Icon(EneftyIcons.receipt_edit_outline,color: Colors.grey,size: 20,),
                                            const SizedBox(width: 5,),
                                            Expanded(
                                              child: SizedBox(
                                                height: 35,
                                                child: Row(
                                                  children: [
                                                    Text('SL định mức: ${DataLocal.listGetItemMaterialsResponse[index].soLuong.toString()}',
                                                      textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(width: 5,),
                                                    Text(DataLocal.listGetItemMaterialsResponse[index].dvt??'Chưa cập nhật đơn vị tính',
                                                      textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 6,bottom: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Icon(EneftyIcons.receipt_edit_outline,color: Colors.grey,size: 20,),
                                            const SizedBox(width: 5,),
                                            Expanded(
                                              child: SizedBox(
                                                height: 35,
                                                child: Row(
                                                  children: [
                                                    Text('SL tiếp nhận: ${DataLocal.listGetItemMaterialsResponse[index].soLuongTiepNhan.toString()}',
                                                      textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(width: 5,),
                                                    Text(DataLocal.listGetItemMaterialsResponse[index].dvt??'Chưa cập nhật đơn vị tính',
                                                      textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 6,bottom: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Icon(EneftyIcons.receipt_edit_outline,color: Colors.grey,size: 20,),
                                            const SizedBox(width: 5,),
                                            Expanded(
                                              child: SizedBox(
                                                height: 35,
                                                child: Row(
                                                  children: [
                                                    Text('Số lượng còn lại: ${DataLocal.listGetItemMaterialsResponse[index].soLuongConLai.toString()}',
                                                      textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(width: 5,),
                                                    Text(DataLocal.listGetItemMaterialsResponse[index].dvt??'Chưa cập nhật đơn vị tính',
                                                      textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 6,bottom: 5),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(EneftyIcons.receipt_edit_outline,color: Colors.grey,size: 20,),
                                      const SizedBox(width: 5,),
                                      Expanded(
                                        child: SizedBox(
                                          height: 35,
                                          child: Row(
                                            children: [
                                              Text('Số lượng sử dụng: ${DataLocal.listGetItemMaterialsResponse[index].soLuongSuDung.toString()}',
                                                textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(width: 5,),
                                              Text(DataLocal.listGetItemMaterialsResponse[index].dvt??'Chưa cập nhật đơn vị tính',
                                                textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                          onTap: (){
                                            DataLocal.listGetItemMaterialsResponse.removeAt(index);
                                            _bloc.add(RefreshUpdateItemBarCodeEvent());
                                          },
                                          child: const Icon(EneftyIcons.trash_outline,color: accent,size: 20)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
            ),
        ),
      ],
    );
  }

  buildWaste(StageStatisticState state){
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Danh sách Phế liệu'),
            )),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const SearchSemiProductionScreen(
                  typeView: 1,
                  addToMaterials: false,
                  addToWaste: true,
                ))).then((value) => _bloc.add(RefreshUpdateItemBarCodeEvent()));
              },
              child: const SizedBox(
                height: 30,
                width: 50,
                child: Icon(Icons.addchart_outlined,color: Colors.black,size: 20,),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
              itemCount: DataLocal.listWaste.length,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index){
                return Card(
                  semanticContainer: true,
                  margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10,right: 6,bottom: 5,left: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '[${DataLocal.listWaste[index].maVt.toString().trim()}] ${DataLocal.listWaste[index].tenVt.toString().toUpperCase()}',
                                style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                maxLines: 2,overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                children: [
                                  const Icon(EneftyIcons.story_outline,color: Colors.grey,size: 20,),
                                  const SizedBox(width: 10,),
                                  Text(DataLocal.listWaste[index].nameStore.toString(),
                                    textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 6,bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(EneftyIcons.receipt_edit_outline,color: Colors.grey,size: 20,),
                                    const SizedBox(width: 5,),
                                    Expanded(
                                      child: InkWell(
                                        onTap: (){
                                          showDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder: (context) {
                                                return UpdateQuantityWaste(quantity: DataLocal.listWaste[index].soLuong,);
                                              }).then((values){
                                            if(values != null){
                                              DataLocal.listWaste[index].soLuong = double.parse(values[0].toString().isNotEmpty == true ? values[0].toString() : '0');
                                              DataLocal.listWaste[index].codeStore = values[1];
                                              DataLocal.listWaste[index].nameStore = values[2];
                                              Utils.showCustomToast(context, EneftyIcons.check_outline, 'Cập nhật thành công');
                                              _bloc.add(GetItemMaterialsEvent(
                                                item: DataLocal.listWaste[index].maVt.toString(),
                                                itemValues: DataLocal.listWaste[index],
                                              ));
                                            }
                                          });
                                        },
                                        child: SizedBox(
                                          height: 35,
                                          child: Row(
                                            children: [
                                              Text(DataLocal.listWaste[index].soLuong.toString(),
                                                textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(width: 5,),
                                              Text(DataLocal.listWaste[index].dvt??'Chưa cập nhật đơn vị tính',
                                                textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 13),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                        onTap: (){
                                          DataLocal.listWaste.remove(DataLocal.listWaste[index]);
                                          _bloc.add(RefreshUpdateItemBarCodeEvent());
                                        },
                                        child: const Icon(EneftyIcons.trash_outline,color: accent,size: 20)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
          ),
        ),
      ],
    );
  }

  buildMachine(StageStatisticState state){
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Danh sách Máy'),
            )),
            InkWell(
              onTap: (){
                showDialog(
                    context: context,
                    builder: (context) => const FilterScreen(controller: 'dmmay_lookup',
                      listItem: null,show: true,)).then((value){
                  if(value != null){
                    List<ReportFieldLookupResponseData> listCheckedReport = <ReportFieldLookupResponseData>[];
                    listCheckedReport = value;
                    if(listCheckedReport.isNotEmpty){
                      for (var element in listCheckedReport) {
                        MachineTable itemMachine = MachineTable(
                            maMay: element.code,
                            tenMay: element.name,
                            soGio: 0
                        );
                        DataLocal.listMachine.add(itemMachine);
                      }
                    }
                    _bloc.add(RefreshUpdateItemBarCodeEvent());
                  }
                });
              },
              child: const SizedBox(
                height: 30,
                width: 50,
                child: Icon(Icons.addchart_outlined,color: Colors.black,size: 20,),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
              itemCount: DataLocal.listMachine.length,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index){
                return Card(
                  semanticContainer: true,
                  margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10,right: 6,bottom: 5,left: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap:(){
                                  showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (context) {
                                        return const CustomInputTimer();
                                      }).then((value){
                                    if(value != null){
                                      DataLocal.listMachine[index].soGio = double.parse(value[0]??'0');
                                      DataLocal.listMachine[index].gioBd = value[1];
                                      DataLocal.listMachine[index].gioKt = value[2];
                                      _bloc.add(RefreshUpdateItemBarCodeEvent());
                                    }
                                  });
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '[${DataLocal.listMachine[index].maMay.toString().trim()}] ${DataLocal.listMachine[index].tenMay.toString().toUpperCase()}',
                                      style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                      maxLines: 2,overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5,),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6,bottom: 5),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 35,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        const Text('Time Start:'),
                                                        Expanded(
                                                            child: Align(alignment: Alignment.center,child: Text(
                                                                '${(DataLocal.listMachine[index].gioBd != null && DataLocal.listMachine[index].gioBd != 'null') ? DataLocal.listMachine[index].gioBd :  ''}'
                                                            ))),
                                                        const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 16,right: 16),
                                                    child: Container(width: 1,height: 18,color: Colors.blueGrey,),
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        const Text('Time End:'),
                                                        Expanded(
                                                            child: Align(alignment: Alignment.center,child: Text(
                                                                '${(DataLocal.listMachine[index].gioKt != null && DataLocal.listMachine[index].gioKt != 'null') ? DataLocal.listMachine[index].gioKt :  ''}'
                                                            ))),
                                                        const Icon(EneftyIcons.calendar_3_outline,color: accent,size: 20,),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 6,bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(EneftyIcons.timer_2_outline,color: accent,size: 20,),
                                    const SizedBox(width: 5,),
                                    Expanded(
                                      child: Text('Số giờ: ${(DataLocal.listMachine[index].soGio.toString().replaceAll('null', '').isNotEmpty) ? DataLocal.listMachine[index].soGio :  '0'}',
                                        textAlign: TextAlign.left,
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    InkWell(
                                        onTap: (){
                                          DataLocal.listMachine.remove(DataLocal.listMachine[index]);
                                          _bloc.add(RefreshUpdateItemBarCodeEvent());
                                        },
                                        child: const Icon(EneftyIcons.trash_outline,color: accent,size: 20)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
          ),
        ),
      ],
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
          const Expanded(
            child: Center(
              child: Text(
                "Công đoạn",
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
}
