import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../suggestions/suggestions_bloc.dart';
import '../suggestions/suggestions_event.dart';
import '../suggestions/suggestions_state.dart';


class DetailDNC extends StatefulWidget {
  final String sttRec;
  final String levelApproval;
  final String status;
  const DetailDNC({Key? key,required this.sttRec,required this.levelApproval,required this.status}) : super(key: key);

  @override
  _DetailDNCState createState() => _DetailDNCState();
}

class _DetailDNCState extends State<DetailDNC> {

  late SuggestionsBloc _bloc;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SuggestionsBloc(context);
    _bloc.add(GetPrefsSuggestions());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SuggestionsBloc,SuggestionsState>(
        bloc: _bloc,
        listener: (context, state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetDetailDNC(sttRec: widget.sttRec));
          }
          else if(state is SuggestionsFailure){
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Có lỗi xảy ra');
          }else if(state is ConfirmDNCSuccess){
            if(state.actionConfirm == '1'){
              Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Duyệt phiếu thành công');
              Navigator.pop(context,['BackLoad']);
            }else if(state.actionConfirm == '2'){
              Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Bỏ duyệt thành công');
              Navigator.pop(context,['BackLoad']);
            } else if(state.actionConfirm == '3'){
              Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Huỷ phiếu thành công');
              Navigator.pop(context,['BackLoad']);
            }
          }else if(state is ConfirmDNCFailure){
            if(state.actionConfirm == '1'){
              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Duyệt phiếu lỗi rồi!');
            }else if(state.actionConfirm == '2'){
              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bỏ duyệt lỗi rồi');
            } else if(state.actionConfirm == '3'){
              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Huỷ phiếu lỗi rồi');
            }
          }
        },
        child: BlocBuilder<SuggestionsBloc,SuggestionsState>(
          bloc: _bloc,
          builder: (BuildContext context, SuggestionsState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetDetailDNCEmpty,
                  child:  const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is SuggestionsLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
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
                "Chi tiết đề nghị chi",
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

  buildBody(BuildContext context,SuggestionsState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 1,),
          Table(
            border: TableBorder.all(color: Colors.grey),
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
              4: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 30,right: 30),
                    height: 35,
                    child: const Center(child: Text('Ngày yêu cầu',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),)),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Container(
                      height: 35,
                      // width: 32,
                      child: Center(child: Text(_bloc.masterDNC == null ? '' : Utils.parseDateTToString(_bloc.masterDNC!.ngayLct.toString(), Const.DATE_TIME_FORMAT).split(' ')[0])),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Container(
                    height: 35,
                    child: const Center(child: Text('Loại giao dịch',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),)),
                  ),
                  Container(
                    height: 40,
                    child: Center(child: Text(_bloc.masterDNC == null ? '' :'${_bloc.masterDNC!.maGd?.trim() == '1' ? 'Tạm Ứng' : 'Chi tiền'}',style: const TextStyle(fontSize: 12),)),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Container(
                    height: 35,
                    child: const Center(child: Text('Loại thanh toán',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),)),
                  ),
                  Container(
                    height: 40,
                    child: Center(child: Text(
                      _bloc.masterDNC == null ? '' : '${_bloc.masterDNC!.loaiTt?.trim() == '1' ? 'Chuyển khoản' :
                      'Tiền mặt' }'
                      ,style: const TextStyle(fontSize: 12),)),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Container(
                    height: 35,
                    child: const Center(child: Text('Trạng thái',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),)),
                  ),
                  Container(
                    height: 40,
                    child: Center(child: Text(
                      '${widget.status}',
                      style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.pink),)),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Container(
                    height: 35,
                    child: const Center(child: Text('Lý do',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),)),
                  ),
                  Container(
                    height: 40,
                    child: Center(child: Text(
                      '${_bloc.masterDNC == null ? '' : _bloc.masterDNC!.dienGiai?.trim()??''}',
                      style: const TextStyle(fontSize: 12),)),
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
                Text('Chi tiết đề nghị',style: TextStyle(color: Colors.blueGrey,fontSize: 11),),
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
                _bloc.add(GetListDNC(dateFrom: Utils.parseDateToString(_bloc.dateFrom, Const.DATE_SV_FORMAT),dateTo: Utils.parseDateToString(_bloc.dateTo, Const.DATE_SV_FORMAT),type: _bloc.transactionType));
              },
              child: ListView.builder(
                  padding: const EdgeInsets.only(left: 6,right: 6),
                  shrinkWrap: true,
                  // controller: _scrollController,
                  itemCount: _bloc.detailListDNC?.length,
                  itemBuilder: (BuildContext context, int index){
                    return Card(
                      elevation: 10,
                      shadowColor: Colors.blueGrey.withOpacity(0.5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.history_edu,color: Colors.grey,size: 12,),
                                const SizedBox(width: 3,),
                                Expanded(child: Text('Nội dung: ${_bloc.detailListDNC![index].dienGiai??''}', style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.bold),maxLines: 5,overflow: TextOverflow.ellipsis,)),
                              ],
                            ),
                            const SizedBox(height: 5,),
                            Row(
                              children: [
                                const Icon(Icons.monetization_on_outlined,color: Colors.grey,size: 12,),
                                const SizedBox(width: 3,),
                                Text('Chi phí: ${
                                    Utils.isEmpty(_bloc.detailListDNC![index].tienNt.toString()) ? 'Null':
                                    Utils.formatMoney(double.parse(_bloc.detailListDNC![index].tienNt.toString()))
                                } vnđ', style: const TextStyle(color: Colors.blueGrey,fontSize: 12),),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ),
          const SizedBox(height: 55,),
        ],
      ),
    );
  }
}
