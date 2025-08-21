import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';


import '../../../../model/database/data_local.dart';
import '../../../../model/network/response/list_item_suggest_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../options_input/options_input_screen.dart';
import '../../sell_bloc.dart';
import '../../sell_event.dart';
import '../../sell_state.dart';
import 'create_order_for_suggest.dart';

class HistoryOrderForSuggestScreen extends StatefulWidget {

  final String userId;

  const HistoryOrderForSuggestScreen({Key? key, required this.userId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HistoryOrderForSuggestScreenState createState() => _HistoryOrderForSuggestScreenState();
}

class _HistoryOrderForSuggestScreenState extends State<HistoryOrderForSuggestScreen>  with TickerProviderStateMixin {

  late SellBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  final bool _hasReachedMax = true;
  late PageController _pageController;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _bloc = SellBloc(context);
    // Const.dateFrom =  DateTime.now().add(const Duration(days: -7));
    // Const.dateTo =  DateTime.now();
    _bloc.add(GetListHistoryOrder(
        status: 0,
        dateFrom: Const.dateFrom,
        dateTo: Const.dateTo,
        isLoadMore: false,
        userId:  widget.userId, typeLetterId: 'suggestion_transfer'
    ));
    _scrollController = ScrollController();
    _pageController = PageController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListHistoryOrder(
            status: 0,
            dateFrom: Const.dateFrom,
            dateTo: Const.dateTo,
            isLoadMore: true,
            userId:  widget.userId, typeLetterId: 'suggestion_transfer'
        ));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: subColor,
        onPressed: ()async{
          PersistentNavBarNavigator.pushNewScreen(context, screen: const CreateOrderForSuggestScreen(isEdit: false,),withNavBar: false).then((value){
            if(value != null && value[0] == 'isReLoad'){
              _bloc.add(GetListHistoryOrder(
                  status: 0,
                  dateFrom: Const.dateFrom,
                  dateTo: Const.dateTo,
                  isLoadMore: false,
                  userId:  widget.userId, typeLetterId: 'suggestion_transfer'
              ));
            }
          });
        },
        child:  Icon(MdiIcons.plusBoxOutline,color: Colors.white,),
      ),
      body: BlocListener<SellBloc,SellState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is DetailOrderSuggestSuccess){
            if(_bloc.listDetail != null){
              DataLocal.listSuggestSave.clear();
              _bloc.listDetail?.forEach((element) {
                ListItemSuggestResponseData item = ListItemSuggestResponseData(
                  sttRec: element.sttRec.toString().trim(),
                    maVt: element.maVt.toString().trim(),
                    tenVt: element.tenVt.toString().trim(),
                    dvt: element.dvt.toString().trim(),
                    qty: element.soLuong
                );
                DataLocal.listSuggestSave.add(item);
              });
            }
            PersistentNavBarNavigator.pushNewScreen(context, screen: CreateOrderForSuggestScreen(isEdit: true,master: _bloc.master,listDetail: _bloc.listDetail,),withNavBar: false).then((value){
            print(value);
              if(value != null && value[0] == 'isReLoad'){
                _bloc.add(GetListHistoryOrder(
                    status: 0,
                    dateFrom: Const.dateFrom,
                    dateTo: Const.dateTo,
                    isLoadMore: false,
                    userId:  widget.userId, typeLetterId: 'suggestion_transfer'
                ));
              }
            });
          }
          else if(state is SellFailure){
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error);
          }
        },
        child: BlocBuilder(
          bloc: _bloc,
          builder: (BuildContext context, SellState state){
            return  Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetListHistoryOrderEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is SellLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,SellState state){
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
                child: buildPageReport(context),
              ),
            ),
          ),const SizedBox(height: 10,),
        ],
      ),
    );
  }

  Widget buildPageReport(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: ListView.separated(
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: (){
                _bloc.add(GetDetailOrderSuggest(sttRec: _bloc.list[index].sttRec.toString().trim()));
              },
              // onTap: ()=>pushNewScreen(context, screen: HistoryOrderDetailScreen(
              //   sttRec: listOrder[index].sttRec,
              //   title: listOrder[index].tenKh,
              //   status: (i != 0 && i != 1) ? false : true,
              //   dateOrder: listOrder[index].ngayCt.toString(),
              //   codeCustomer: listOrder[index].maKh.toString().trim(),
              //   nameCustomer:  listOrder[index].tenKh.toString().trim(),
              //   addressCustomer:  listOrder[index].diaChiKH.toString().trim(),
              //   phoneCustomer:  listOrder[index].dienThoaiKH.toString().trim(),
              //   dateEstDelivery: listOrder[index].dateEstDelivery.toString(),
              // ),withNavBar: false).then((value){
              //   if(value == Const.REFRESH){
              //     _bloc.add(GetListHistoryOrder(status: i,dateFrom: Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'ORDERLIST'));
              //   }
              // }),
              child: Card(
                elevation: 10,
                shadowColor: Colors.blueGrey.withOpacity(0.5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
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
                                    Expanded(child: Text('SCT [${_bloc.list[index].soCt}]', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),)),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Ngày tạo ',
                                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                0xff555a55)),
                                          ),
                                          TextSpan(
                                            text: Utils.parseStringDateToString('${_bloc.list[index].ngayCt}', Const.DATE_SV, Const.DATE_FORMAT_1),
                                            style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Người tạo: ',
                                        style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                            0xff555a55)),
                                      ),
                                      TextSpan(
                                        text: _bloc.list[index].comment.toString(),
                                        style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => Container(),
          itemCount: _bloc.list.length),
    );
  }

  buildAppBar(){
    return Container(
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
            child: Container(
              padding: const EdgeInsets.only(top: 16),
              child: const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Lịch sử đơn hàng",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                  maxLines: 1,overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: ()=>  showDialog(
                context: context,
                builder: (context) => const OptionsFilterDate()).then((value){
              if(value != 'CANCEL'){
                Const.dateFrom =  Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT);
                Const.dateTo =  Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT);
                _bloc.add(GetListHistoryOrder(status: 0,dateFrom: Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'suggestion_transfer'));
              }
            }),
            child: const SizedBox(
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
}
