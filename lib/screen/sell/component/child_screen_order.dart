import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../model/network/response/list_history_order_response.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../sell_bloc.dart';
import '../sell_event.dart';
import '../sell_state.dart';
import 'history_order_detail_screen.dart';

class ChildScreenOrder extends StatefulWidget {
  final List<Values> listOrder;
  final int i;
  final String userId;
  final SellBloc bloc;

  const ChildScreenOrder({Key? key, required this.listOrder,required this.i,required this.userId,required this.bloc}) : super(key: key);

  @override
  State<ChildScreenOrder> createState() => _ChildScreenOrderState();
}

class _ChildScreenOrderState extends State<ChildScreenOrder> {

  // late SellBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  final bool _hasReachedMax = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.bloc.statusOrderList = widget.i;
    widget.bloc.list.clear();
    // _bloc = SellBloc(context);
    // Const.dateFrom =  DateTime.now().add(const Duration(days: -7));
    // Const.dateTo =  DateTime.now();
    widget.bloc.add(GetListHistoryOrder(status: widget.i,dateFrom: Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'ORDERLIST'));

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && widget.bloc.isScroll == true) {
        widget.bloc.add(GetListHistoryOrder(
            status: widget.bloc.statusOrderList,
            dateFrom: Const.dateFrom,
            dateTo: Const.dateTo,
            isLoadMore: true,
            userId:  widget.userId, typeLetterId: 'ORDERLIST'
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SellBloc,SellState>(
        bloc: widget.bloc,
        listener: (context, state){
          if(state is GetPrefsSuccess){
          }
          else if(state is DeleteOrderSuccess){
            // widget.bloc.add(GetListHistoryOrder(status: widget.i,dateFrom: Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId));
          }
        },
        child: BlocBuilder(
          bloc: widget.bloc,
          builder: (BuildContext context, SellState state){
            return Stack(
              children: [
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: ()=>PersistentNavBarNavigator.pushNewScreen(context, screen: HistoryOrderDetailScreen(
                            sttRec: widget.bloc.list[index].sttRec,
                            title: widget.bloc.list[index].tenKh,
                            status: (widget.bloc.list[index].status.toString().trim() != "0" && widget.bloc.list[index].status.toString().trim() != "1") ? false : true,
                            dateOrder: widget.bloc.list[index].ngayCt.toString(),
                            codeCustomer: widget.bloc.list[index].maKh.toString().trim(),
                            nameCustomer:  widget.bloc.list[index].tenKh.toString().trim(),
                            addressCustomer:  widget.bloc.list[index].diaChiKH.toString().trim(),
                            phoneCustomer:  widget.bloc.list[index].dienThoaiKH.toString().trim(),
                            dateEstDelivery: widget.bloc.list[index].dateEstDelivery.toString(),
                          ),withNavBar: false).then((value){
                            if(value == Const.REFRESH){
                              widget.bloc.add(GetListHistoryOrder(status: widget.i,dateFrom: Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'ORDERLIST'));
                            }
                          }),
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
                                                Expanded(child: Text('${widget.bloc.list[index].tenKh}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),)),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: 'Ngày tạo ',
                                                        style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                            0xff555a55)),
                                                      ),
                                                      TextSpan(
                                                        text: Utils.parseStringDateToString('${widget.bloc.list[index].ngayCt}', Const.DATE_SV, Const.DATE_FORMAT_1),
                                                        style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3,),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.phone_iphone_rounded,color: Colors.grey,size: 12,),
                                                      const SizedBox(width: 3,),
                                                      Text(widget.bloc.list[index].dienThoaiKH??'null', style: const TextStyle(color: Colors.grey,fontSize: 12),),
                                                    ],
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: 'Ngày giao ',
                                                        style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                            0xff555a55)),
                                                      ),
                                                      TextSpan(
                                                        text: Utils.parseStringDateToString('${widget.bloc.list[index].dateEstDelivery}', Const.DATE_SV, Const.DATE_FORMAT_1),
                                                        style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3,),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on_outlined,color: Colors.grey,size: 12,),
                                                const SizedBox(width: 3,),
                                                Expanded(child: Text('${widget.bloc.list[index].diaChiKH}', style:const  TextStyle(color: Colors.grey,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Tổng tiền: ${Utils.formatMoneyStringToDouble(widget.bloc.list[index].tTtNt??0)} VNĐ', style: const TextStyle(color: Colors.red,fontSize: 12),),
                                      Text('${widget.bloc.list[index].statusname}', style: const TextStyle(color: Colors.black,fontSize: 12),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => Container(),
                      itemCount: widget.bloc.list.length),
                ),
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
      ) ,
    );
  }
}
