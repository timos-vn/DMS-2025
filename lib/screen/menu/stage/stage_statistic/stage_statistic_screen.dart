// ignore_for_file: library_private_types_in_public_api

import 'package:dms/widget/custom_dropdown.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/screen/menu/stage/stage_statistic/stage_statistic_bloc.dart';
import 'package:dms/screen/menu/stage/stage_statistic/stage_statistic_event.dart';
import 'package:dms/screen/menu/stage/stage_statistic/stage_statistic_state.dart';

import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';

import '../../../../model/network/response/manager_customer_response.dart';
import '../../../customer/search_customer/search_customer_screen.dart';
import '../detail_stage_statistic/detail_stage_statistic_screen.dart';

class StageStatisticScreen extends StatefulWidget {
  final String unitId;

  const StageStatisticScreen({Key? key, required this.unitId}) : super(key: key);
  @override
  _StageStatisticScreenState createState() => _StageStatisticScreenState();
}

class _StageStatisticScreenState extends State<StageStatisticScreen>  with SingleTickerProviderStateMixin{

  late StageStatisticBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  String? nameCustomer;
  String? idCustomer;

  List<String> choices = <String>[
    "1. Tổ sóng",
    "2. Tổ in",
    "3. Chế biến",
    "4. Lót vách",
    "5. Hoàn thiện"
  ];

  String nameStageStatistic = "Tổ sóng";
  int idStageStatistic = 1;

  void _select(String choice) {
    if(choice == '1. Tổ sóng'){
      nameStageStatistic = choice;
      idStageStatistic = 1;
      _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
    }else if(choice == '2. Tổ in'){
      nameStageStatistic = choice;
      idStageStatistic = 2;
      _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
    }else if(choice == '3. Chế biến'){
      nameStageStatistic = choice;
      idStageStatistic = 3;
      _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
    }else if(choice == '4. Lót vách'){
      nameStageStatistic = choice;
      idStageStatistic = 4;
      _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
    }else if(choice == '5. Hoàn thiện'){
      nameStageStatistic = choice;
      idStageStatistic = 5;
      _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = StageStatisticBloc(context);
    _bloc.add(GetPrefs());
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),isLoadMore:true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StageStatisticBloc,StageStatisticState>(
      bloc: _bloc,
      listener: (context,state){
        if(state is GetPrefsSuccess){
          _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
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
            child: Container(
              width: 40,
              height: 50,
              child: const Icon(
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
          Container(
            width: 40,
            height: 50,
            child: const Icon(
              Icons.event,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  buildBody(BuildContext context,StageStatisticState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Table(
            border: TableBorder.all(color: Colors.grey),
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 30,right: 30),
                    height: 35,
                    child: const Center(child: Text('Công đoạn')),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Container(
                      height: 35,
                      // width: 32,
                      child: Center(child: PopupMenuButton(
                        onSelected: _select,
                        shape: const TooltipShape(),
                        padding: EdgeInsets.zero,
                        offset: const Offset(20, 45),
                        itemBuilder: (BuildContext context) {
                          return choices.map((String choice) {
                            return  PopupMenuItem<String>(
                              height: 10,
                              padding: const EdgeInsets.only(left: 5,top: 5),
                              value: choice,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(choice,style: const TextStyle(fontSize: 12),),
                                  const Divider()
                                ],
                              ),
                            );}
                          ).toList();
                        },
                        child: Row(
                          children: [
                            Expanded(child: Center(child: Text(nameStageStatistic.toString(),style: const TextStyle(color: Colors.black),maxLines: 1,overflow: TextOverflow.visible,))),
                            const Icon(Icons.keyboard_arrow_down,color: Colors.grey,size: 22,),
                            const SizedBox(width: 10,),
                          ],
                        ),
                      )),
                    ),
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
                    onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const SearchCustomerScreen(selected: true,allowCustomerSearch: false, inputQuantity: false,))).then((value){
                      if(!Utils.isEmpty(value)){
                        ManagerCustomerResponseData infoCustomer = value;
                        setState(() {
                          nameCustomer = infoCustomer.customerName.toString();
                          idCustomer = infoCustomer.customerCode;
                        });
                      }
                    }),
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Expanded(child: Padding(
                            padding: const EdgeInsets.only(left: 3,top: 2,bottom: 2),
                            child: Center(child: Text( nameCustomer?.toString()??'',style: const TextStyle(fontSize: 12),)),
                          )),
                          const Icon(Icons.search,color: Colors.grey,size: 18,),
                          const SizedBox(width: 10,),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(child: Divider()),
                SizedBox(width: 5,),
                Text('Danh sách công đoạn',style: TextStyle(color: Colors.grey,fontSize: 13),),
                SizedBox(width: 5,),
                Expanded(child: Divider()),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: mainColor,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 2));
                _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
              },
              child: Container(
                height: double.infinity,width: double.infinity,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemCount: _bloc.listStage.length,
                    itemBuilder: (BuildContext context, int index){
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailStageStatisticScreen(
                            sttRec: _bloc.listStage[index].sttRec,
                            nameStage: _bloc.listStage[index].soLsx,
                            idStage: idStageStatistic,
                            nameCustomer: nameCustomer,
                            // idCustomer: idCustomer,
                          ))).then((value){
                            if(value == 'BackLoad'){
                              _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
                            }
                          });
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
                                          Text('Tiêu đề: ${_bloc.listStage[index].soLsx.toString().trim()}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),),
                                          const SizedBox(height: 10,),
                                          Row(
                                            children: [
                                              const Icon(Icons.event_note,color: Colors.grey,size: 12,),
                                              const SizedBox(width: 3,),
                                              Text(_bloc.listStage[index].dienGiai.toString().trim(), style: const TextStyle(color: Colors.grey,fontSize: 12),),
                                            ],
                                          ),
                                          const SizedBox(height: 8,),
                                          Row(
                                            children: [
                                              const Icon(Icons.account_circle_outlined,color: Colors.grey,size: 12,),
                                              const SizedBox(width: 3,),
                                              Expanded(child: Text(_bloc.listStage[index].comment.toString().trim(), style: const TextStyle(color: Colors.grey,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(Utils.parseStringDateToString(_bloc.listStage[index].ngayCt.toString(), Const.DATE_SV, Const.DATE_FORMAT_1), style: const TextStyle(color: Colors.black,fontSize: 12),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ),
          const SizedBox(height: 55,)
        ],
      ),
    );
  }
}
