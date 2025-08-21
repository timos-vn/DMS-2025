import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../options_input/options_input_screen.dart';
import '../sell_bloc.dart';
import '../sell_event.dart';
import '../sell_state.dart';
import 'create_item_holder_screen.dart';
import 'get_item_holder_detail_screen.dart';

class ListKeepCardScreen extends StatefulWidget {
  const ListKeepCardScreen({Key? key}) : super(key: key);

  @override
  State<ListKeepCardScreen> createState() => _ListKeepCardScreenState();
}

class _ListKeepCardScreenState extends State<ListKeepCardScreen> {

  late SellBloc _bloc;

  DateTime dateFrom = DateTime.now().add(const Duration(days: -30));
  DateTime dateTo = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SellBloc(context);
    _bloc.add(GetListHistoryOrder(status: 0,dateFrom: dateFrom, dateTo: dateTo,userId:  _bloc.userCode, typeLetterId: 'ITEMHOLDER'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          backgroundColor: subColor,
          onPressed: ()async{
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const CreateItemHolderScreen())).then((value){
              _bloc.add(GetListHistoryOrder(status: 0,dateFrom: dateFrom, dateTo: dateTo,userId:  _bloc.userCode, typeLetterId: 'ITEMHOLDER'));
            });
          },
          child: const Icon(Icons.add,color: Colors.white,),
        ),
      ),
      body: BlocListener<SellBloc,SellState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is DeleteItemHolderSuccess){
            Utils.showCustomToast(context, EneftyIcons.trash_outline, 'Xoá phiếu thành công');
            _bloc.add(GetListHistoryOrder(status: 0,dateFrom: dateFrom, dateTo: dateTo,userId:  _bloc.userCode, typeLetterId: 'ITEMHOLDER'));
          }else if(state is SellFailure){
            Utils.showCustomToast(context, EneftyIcons.warning_2_outline, state.error.toString());
          }
        },
        child: BlocBuilder<SellBloc,SellState>(
          bloc: _bloc,
          builder: (BuildContext context, SellState state){
            return Stack(
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

  Widget buildBody(BuildContext context, SellState state) {
    return Column(
      children: [
        buildAppBar(),
        Expanded(
          child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>GetItemHolderDetail(sttRec: _bloc.list[index].sttRec.toString())));
                  },
                  child: Slidable(
                    key: const ValueKey(0),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      dragDismissible: false,
                      children: [
                        SlidableAction(
                          onPressed:(_) {
                            _bloc.add(DeleteItemHolderEvent(sttRec: _bloc.list[index].sttRec.toString()));
                          },
                          borderRadius:const BorderRadius.all(Radius.circular(8)),
                          padding:const EdgeInsets.all(10),
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: EneftyIcons.trash_outline,
                          label: 'Xoá',
                        ),
                      ],
                    ),
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
                                          Expanded(child: Text('${_bloc.list[index].tenKh}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),)),
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
                                      const SizedBox(height: 3,),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Icon(Icons.phone_iphone_rounded,color: Colors.grey,size: 12,),
                                                const SizedBox(width: 3,),
                                                Text(_bloc.list[index].dienThoaiKH??'null', style: const TextStyle(color: Colors.grey,fontSize: 12),),
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
                                                  text: Utils.parseStringDateToString('${_bloc.list[index].dateEstDelivery}', Const.DATE_SV, Const.DATE_FORMAT_1),
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
                                          Expanded(child: Text('${_bloc.list[index].diaChiKH}', style:const  TextStyle(color: Colors.grey,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis,)),
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
                                Text('Tổng tiền: ${Utils.formatMoneyStringToDouble(_bloc.list[index].tTtNt??0)} VNĐ', style: const TextStyle(color: Colors.red,fontSize: 12),),
                                Text('${_bloc.list[index].statusname}', style: const TextStyle(color: Colors.black,fontSize: 12),),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => Container(),
              itemCount: _bloc.list.length),
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
          Expanded(
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>GetItemHolderDetail(sttRec: 'A000000825HIA')));
              },
              child: Center(
                child: Text(
                  "Danh sách lịch sử giữ hàng",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                  maxLines: 1,overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: ()=>showDialog(
                context: context,
                builder: (context) => OptionsFilterDate(dateFrom: dateFrom.toString(),dateTo: dateTo.toString())).then((value){
              if(value != null){
                if(value[1] != null && value[2] != null){
                  if(value[1] != null && value[2] != null){
                    dateFrom = DateTime.parse(value[3]);
                    dateTo = DateTime.parse(value[4]);
                    if(_bloc.list.isNotEmpty){
                      _bloc.list.clear();
                    }
                    _bloc.add(GetListHistoryOrder(status: 0,dateFrom: dateFrom, dateTo: dateTo,userId:  _bloc.userCode, typeLetterId: 'ITEMHOLDER'));
                  }else{
                    Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy chọn từ ngày đến ngày');
                  }
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy chọn từ ngày đến ngày');
                }
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
