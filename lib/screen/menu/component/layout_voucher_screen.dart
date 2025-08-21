import 'package:dms/model/database/data_local.dart';
import 'package:dms/widget/custom_choose_function.dart';
import 'package:dms/widget/custom_dropdown.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../options_input/options_input_screen.dart';
import '../../qr_code/component/view_infor_card.dart';
import '../menu_bloc.dart';
import '../menu_event.dart';
import '../menu_state.dart';

class LayOutVoucherScreen extends StatefulWidget {
  const LayOutVoucherScreen({Key? key}) : super(key: key);

  @override
  State<LayOutVoucherScreen> createState() => _LayOutVoucherScreenState();
}

class _LayOutVoucherScreenState extends State<LayOutVoucherScreen> with TickerProviderStateMixin{
  late MenuBloc _bloc;
  late TabController tabController;
  String voucherCode = '';
  String voucherName = '';
  String statusCode = '';
  String statusName = '';
  String key = '';
  bool actionView  = false;
  bool actionUpdate  = false;
  bool actionDelete  = false;
  List<String> listKey = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: DataLocal.listTypeVoucher.length, vsync: this);
    _bloc = MenuBloc(context);
    _bloc.add(GetPrefsMenuEvent());
    if(DataLocal.listTypeVoucher.isNotEmpty){
      voucherCode = DataLocal.listTypeVoucher[0].codeVoucher.toString();
      voucherName = DataLocal.listTypeVoucher[0].nameVoucher.toString();
    }

    tabController.addListener(() {
      print("Selected Index: " + tabController.index.toString());
      _bloc.listVoucher.clear();
      voucherCode = DataLocal.listTypeVoucher[tabController.index].codeVoucher.toString();
      voucherName = DataLocal.listTypeVoucher[tabController.index].nameVoucher.toString();
      _bloc.add(GetDynamicListVoucherEvent(
        voucherCode: voucherCode,
        status: statusCode,
        dateFrom: _bloc.dateFrom,
        dateTo: _bloc.dateTo,));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<MenuBloc,MenuState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetDynamicListVoucherEvent(
              voucherCode: voucherCode,
              status: statusCode,
              dateFrom: _bloc.dateFrom,
              dateTo: _bloc.dateTo,));
          }
          else if(state is MenuFailure){
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error);
          }
          else if(state is GetListTypeVoucherSuccess){
            if(_bloc.listStatus.isNotEmpty){
              statusCode = _bloc.listStatus[0].status.toString();
              statusName = _bloc.listStatus[0].statusname.toString();
              key = _bloc.listStatus[0].key.toString();
              actionView  = _bloc.listStatus[0].view??false;
              actionUpdate  = _bloc.listStatus[0].update??false;
              actionDelete  = _bloc.listStatus[0].delete??false;
            }
          }
          else if(state is GetInformationCardSuccess){
            if(key.toString().trim().replaceAll('null', '').isNotEmpty &&key.toString().trim().replaceAll('null', '') != null){
              if(key.contains(',')){
                listKey =  key.split(',');
              }
              else{
                listKey = [];
              }
              if(listKey.isNotEmpty){
                showDialog(
                    context: context,
                    builder: (context) {
                      return WillPopScope(
                        onWillPop: () async => false,
                        child: CustomChooseFunction(
                          title: 'Chức năng Phiếu',
                          content: 'Vui lòng chọn chức năng để thao tác', keyFnc: key.toString(),
                        ),
                      );
                    }).then((value) {
                  if(!Utils.isEmpty(value) && value[0] == 'Yeah'){
                    key = value[1];
                    pushNewScreen();
                  }
                });
              }
              else{
                pushNewScreen();
              }
            }
            else{
              Utils.showCustomToast(context, Icons.warning_amber, 'Chức năng này sếp chưa duyệt');
            }
          }
        },
        child: BlocBuilder(
          bloc: _bloc,
          builder: (BuildContext context, MenuState state){
            return  Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is MenuLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void pushNewScreen(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewInformationCardScreen(
      ruleActionInformationCard: _bloc.ruleActionInformationCard,
      listItemCard: _bloc.listItemCard,
      masterInformationCard: _bloc.masterInformationCard,
      keyFunction: key ,
      nameCard:  voucherName,
      formatProvider: _bloc.formatProvider,
    )));
  }

  buildBody(BuildContext context,MenuState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: RefreshIndicator(
              color: mainColor,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 2));
                // _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
              },
              child: SizedBox(
                height: double.infinity,width: double.infinity,
                child: TabBarView(
                    controller: tabController,
                    children: List<Widget>.generate(DataLocal.listTypeVoucher.length, (int index) {
                      for (int i = 0; i <= DataLocal.listTypeVoucher.length; i++) {
                        if (i == index) {
                          return buildChildScreen(
                               DataLocal.listTypeVoucher[index].codeVoucher.toString(),
                              state
                          );
                        }
                      }
                      return const Text('');
                    })),
              ),
            ),
          ),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }

  Widget buildChildScreen(String codeVoucher, MenuState state){
    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: (){
                   _bloc.add(GetInformationCardEvent(idCard: _bloc.listVoucher[index].sttRec.toString(), key: ''));
                    // print(_bloc.listVoucher[index].sttRec);
                  },
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.blueGrey.withOpacity(0.5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text('[${_bloc.listVoucher[index].maKh.toString().trim().replaceAll('null', '')}] ${_bloc.listVoucher[index].tenKh.toString().trim().replaceAll('null', '')}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),)),
                                        const SizedBox(width: 10,),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: _bloc.listVoucher[index].statusname.toString().trim(),
                                                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.purple),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(EneftyIcons.code_2_outline,color: accent,size: 20),
                                              const SizedBox(width: 5,),
                                              Text(_bloc.listVoucher[index].soCt.toString().trim().replaceAll('null', ''), style:const  TextStyle(color: Colors.black),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                            ],
                                          ),
                                        ),
                                        Text(Utils.parseStringDateToString(_bloc.listVoucher[index].ngayCt.toString().trim().replaceAll('null', ''), Const.DATE_SV, Const.DATE_FORMAT_1), style:const  TextStyle(color: Colors.black),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                          const SizedBox(height: 8,),
                          const Divider(),
                          const SizedBox(height: 8,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Số lượng: ${_bloc.listVoucher[index].tSoLuong}', style: const TextStyle(color: Colors.black,fontSize: 12),),
                              Text('Tổng tiền: ${Utils.formatMoneyStringToDouble(_bloc.listVoucher[index].tTien??0)} VNĐ', style: const TextStyle(color: Colors.black,fontSize: 12),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => Container(),
              itemCount:_bloc.listVoucher.length),
        ),
        Visibility(
          visible: state is GetListTypeVoucherEmpty,
          child: const Center(
            child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
          ),
        ),
      ],
    );
  }

  buildAppBar(){
    return Container(
      height: 153,
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
      child: Column(
        children: [
          Row(
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
                child: Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Phiếu ${voucherName.toString()}',
                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                      maxLines: 1,overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: (){
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
                                        Expanded(
                                          child: ListView(
                                            padding: const EdgeInsets.only(left: 16,right: 16,bottom: 0),
                                            children: [
                                              InkWell(
                                                onTap: ()=>  showDialog(
                                                    context: context,
                                                    builder: (context) => const OptionsFilterDate()).then((value){
                                                  if(value != 'CANCEL'){
                                                    myState(() {
                                                      _bloc.dateFrom =  Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT);
                                                      _bloc.dateTo =  Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT);
                                                    });
                                                  }
                                                }),
                                                child: SizedBox(
                                                  height: 35,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Từ ngày: ${Utils.parseDateToString(_bloc.dateFrom, Const.DATE_FORMAT_1)}',style:const  TextStyle(color: Colors.black),),
                                                      Text('Đến ngày: ${Utils.parseDateToString(_bloc.dateTo, Const.DATE_FORMAT_1)}',style:const  TextStyle(color: Colors.black),),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.only(top: 8,bottom: 12),
                                                child: Divider(),
                                              ),
                                              SizedBox(
                                                height:35,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text('Trạng thái phiếu',style: TextStyle(color: Colors.black),),
                                                    _bloc.listStatus.isEmpty
                                                        ? const Text('Úi, Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12))
                                                        :
                                                    Expanded(
                                                      child: PopupMenuButton(
                                                        shape: const TooltipShape(),
                                                        padding: EdgeInsets.zero,
                                                        offset: const Offset(0, 40),
                                                        itemBuilder: (BuildContext context) {
                                                          return <PopupMenuEntry<Widget>>[
                                                            PopupMenuItem<Widget>(
                                                              child: Container(
                                                                decoration: ShapeDecoration(
                                                                    color: Colors.white,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(10))),
                                                                height: 250,
                                                                width: 200,
                                                                child: Scrollbar(
                                                                  child: ListView.builder(
                                                                    padding: const EdgeInsets.only(top: 10,),
                                                                    itemCount: _bloc.listStatus.length,
                                                                    itemBuilder: (context, index) {
                                                                      final trans = _bloc.listStatus[index].statusname.toString().trim();
                                                                      return ListTile(
                                                                        minVerticalPadding: 1,
                                                                        title: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Flexible(
                                                                              child: Text(
                                                                                trans.toString(),
                                                                                style: const TextStyle(
                                                                                  fontSize: 12,
                                                                                ),
                                                                                maxLines: 1,overflow: TextOverflow.fade,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              '#${_bloc.listStatus[index].status.toString().trim()}',
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        subtitle:const Divider(height: 1,),
                                                                        onTap: () {
                                                                          // _bloc.add(PickFilterEvent(
                                                                          //   statusCode: _bloc.listStatus[index].status.toString(),
                                                                          //   statusName: _bloc.listStatus[index].statusname.toString(),
                                                                          //   voucherCode: voucherCode.toString(),
                                                                          //   voucherName: voucherName.toString(),
                                                                          // ));
                                                                          statusCode = _bloc.listStatus[index].status.toString();
                                                                          statusName = _bloc.listStatus[index].statusname.toString();
                                                                          key = _bloc.listStatus[index].key.toString();
                                                                          actionView  = _bloc.listStatus[index].view??false;
                                                                          actionUpdate  = _bloc.listStatus[index].update??false;
                                                                          actionDelete  = _bloc.listStatus[index].delete??false;
                                                                          myState(() {});
                                                                          Navigator.pop(context);
                                                                        },
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ];
                                                        },
                                                        child: SizedBox(
                                                          height: 35,width: double.infinity,
                                                          child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: Text(statusName.toString(),style: const TextStyle(color: subColor),textAlign: TextAlign.center,),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16,right: 16,bottom: 12),
                                          child: GestureDetector(
                                            onTap: (){
                                              Navigator.pop(context,['Yeah',voucherCode,voucherName,statusCode,statusName]);
                                            },
                                            child: Container(
                                              height: 45, width: double.infinity,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  color: subColor
                                              ),
                                              child: const Center(
                                                child: Text('Áp dụng', style: TextStyle(color: Colors.white,fontSize: 12.5),),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                  ).then((value) => _bloc.add(GetDynamicListVoucherEvent(
                    voucherCode: voucherCode,
                    status: statusCode,
                    dateFrom: _bloc.dateFrom,
                    dateTo: _bloc.dateTo,)));
                },
                child: const SizedBox(
                  width: 40,
                  height: 50,
                  child: Icon(Icons.filter_list, color: Colors.white,size: 25,),
                ),
              )
            ],
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Container(
                padding: const EdgeInsets.all(4),
                height: 43,
                width: double.infinity,
                decoration: BoxDecoration(border: Border.all(width: 0.8, color: white), borderRadius: const BorderRadius.all(Radius.circular(16))),
                child: TabBar(
                  controller: tabController,
                  unselectedLabelColor: white,
                  labelColor: orange,
                  labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  isScrollable: DataLocal.listTypeVoucher.length <= 3 ? false : true,
                  indicator:const BoxDecoration(color: white, borderRadius:  BorderRadius.all(Radius.circular(12))),
                  tabs: List<Widget>.generate(DataLocal.listTypeVoucher.length, (int index) {
                    return  Tab(
                      text: DataLocal.listTypeVoucher[index].nameVoucher.toString(),
                    );
                  }),
                )
            ),
          ),
        ],
      ),
    );
  }
}
