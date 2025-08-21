import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/screen/dms/delivery/delivery_plan_detail/delivery_plan_detail.dart';
import 'package:dms/screen/options_input/options_input_screen.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';


import 'delivery_plan_bloc.dart';
import 'delivery_plan_event.dart';
import 'delivery_plan_state.dart';


class DeliveryPlanScreen extends StatefulWidget {
  const DeliveryPlanScreen({Key? key}) : super(key: key);

  @override
  _DeliveryPlanScreenState createState() => _DeliveryPlanScreenState();
}

class _DeliveryPlanScreenState extends State<DeliveryPlanScreen> {
  late DeliveryPlanBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  final bool _hasReachedMax = true;

  String dateFrom = DateTime.now().add(const Duration(days: -30)).toString();
  String dateTo = DateTime.now().toString();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = DeliveryPlanBloc(context);
    _bloc.add(GetPrefsDeliveryPlan());
    _scrollController = ScrollController();


    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListDeliveryPlan(dateFrom: dateFrom, dateTo:dateTo.toString(),isLoadMore:true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeliveryPlanBloc,DeliveryPlanState>(
      bloc: _bloc,
      listener: (context,state){
        if(state is DeliveryPlanFailure){
          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, ${state.error}');
        }else if(state is GetPrefsSuccess){
          _bloc.add(GetListDeliveryPlan(dateFrom: dateFrom, dateTo:dateTo.toString(),));
        }
      },
      child: BlocBuilder<DeliveryPlanBloc,DeliveryPlanState>(
        bloc: _bloc,
        builder: (BuildContext context, DeliveryPlanState state){
          return Scaffold(
            body: Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is GetListDeliveryPlanEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is DeliveryPlanLoading,
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
                offset: Offset(2, 4),
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
                "Kế hoạch giao hàng",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: ()=>  showDialog(
                context: context,
                builder: (context) => OptionsFilterDate()).then((value){
              if(value != null){
                if(value[1] != null && value[2] != null){
                  dateFrom = Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT).toString();
                  dateTo = Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT).toString();
                  _bloc.listDeliveryPlan.clear();
                  _bloc.add(GetListDeliveryPlan(dateFrom: dateFrom, dateTo:dateTo.toString()));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vui lòng nhập nội dung từ ngày đến ngày');
                }
              }
            }),
            child: Container(
              width: 40,
              height: 50,
              child: Icon(
                Icons.event,
                size: 25,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  buildBody(BuildContext context,DeliveryPlanState state){
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
                    _bloc.listDeliveryPlan.clear();
                    _bloc.add(GetListDeliveryPlan(dateFrom: dateFrom, dateTo:dateTo.toString()));
                  },
                  child: SizedBox(height: double.infinity,width: double.infinity,child: buildListStage(context)))),
        ],
      ),
    );
  }

  Widget buildListStage(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(left: 8,right: 8,bottom: 55),
      child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: _bloc.listDeliveryPlan.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index){
            return GestureDetector(
              onTap: (){
                PersistentNavBarNavigator.pushNewScreen(context, screen: DeliveryPlanDetailScreen(
                  sttRec: _bloc.listDeliveryPlan[index].sttRec,soCt:  _bloc.listDeliveryPlan[index].soCt,ngayCt:  _bloc.listDeliveryPlan[index].ngayCt,
                  ngayGiao: _bloc.listDeliveryPlan[index].ngayGiao, maKH: _bloc.listDeliveryPlan[index].maKH, maVc: _bloc.listDeliveryPlan[index].maVc, nguoiGiao: _bloc.listDeliveryPlan[index].nguoiGiao,
                )).then((value){
                  _bloc.listDeliveryPlan.clear();
                  _bloc.add(GetListDeliveryPlan(dateFrom: dateFrom, dateTo:dateTo.toString()));
                });
              },
              child: Card(
                elevation: 10,
                shadowColor: Colors.blueGrey.withOpacity(0.5),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 12),
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
                                Text('KH: ${_bloc.listDeliveryPlan[index].tenKH?.trim()}', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),),
                                SizedBox(height: 10,),
                                Text('Người giao: ${_bloc.listDeliveryPlan[index].tenNguoiGiao?.trim()}', style: TextStyle(color: Colors.black,fontSize: 12),),
                                SizedBox(height: 10,),
                                Row(
                                  children: [
                                    Icon(Icons.event_note,color: Colors.grey,size: 12,),
                                    SizedBox(width: 3,),
                                    Text('${_bloc.listDeliveryPlan[index].dienGiai == '' ?'Không có diễn giải' : _bloc.listDeliveryPlan[index].dienGiai}', style: TextStyle(color: Colors.grey,fontSize: 12),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text('${Utils.parseStringDateToString(_bloc.listDeliveryPlan[index].ngayCt.toString(), Const.DATE_SV, Const.DATE_FORMAT_1)}', style: TextStyle(color: Colors.black,fontSize: 12),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
