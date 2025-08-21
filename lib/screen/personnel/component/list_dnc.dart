import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../options_input/options_input_screen.dart';
import '../suggestions/suggestions_bloc.dart';
import '../suggestions/suggestions_event.dart';
import '../suggestions/suggestions_state.dart';
import 'create_dnc.dart';
import 'detail_dnc.dart';

class ListDNC extends StatefulWidget {
  const ListDNC({Key? key}) : super(key: key);

  @override
  _ListDNCState createState() => _ListDNCState();
}

class _ListDNCState extends State<ListDNC> {

  late SuggestionsBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  final bool _hasReachedMax = true;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SuggestionsBloc(context);
    _bloc.dateFrom =  DateTime.now().add(const Duration(days: -30));
    _bloc.dateTo =  DateTime.now();
    _bloc.add(GetPrefsSuggestions());

    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListDNC(dateFrom: Utils.parseDateToString(_bloc.dateFrom, Const.DATE_SV_FORMAT),dateTo: Utils.parseDateToString(_bloc.dateTo, Const.DATE_SV_FORMAT),isLoadMore:true,type: _bloc.transactionType));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 55),
        child: FloatingActionButton(
          child: Icon(Icons.add,color: Colors.white,),
          backgroundColor: subColor,
          onPressed: ()async{
            PersistentNavBarNavigator.pushNewScreen(context, screen: CreateDNCScreen()).then((value){
              if(value != null){
                if(value[0] == 'ReloadScreen'){
                  _bloc.add(GetListDNC(dateFrom: Utils.parseDateToString(_bloc.dateFrom, Const.DATE_SV_FORMAT),dateTo: Utils.parseDateToString(_bloc.dateTo, Const.DATE_SV_FORMAT),type: _bloc.transactionType));
                }
              }
            });
          },
        ),
      ),
      body: BlocListener<SuggestionsBloc,SuggestionsState>(
        bloc: _bloc,
        listener: (context, state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetListDNC(dateFrom: Utils.parseDateToString(_bloc.dateFrom, Const.DATE_SV_FORMAT),dateTo: Utils.parseDateToString(_bloc.dateTo, Const.DATE_SV_FORMAT),type: _bloc.transactionType));
          }
        },
        child: BlocBuilder<SuggestionsBloc,SuggestionsState>(
          bloc: _bloc,
          builder: (BuildContext context, SuggestionsState state){
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is GetListDNCEmpty,
                  child: const Center(
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

  buildBody(BuildContext context,SuggestionsState state){
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
                _bloc.add(GetListDNC(dateFrom: Utils.parseDateToString(_bloc.dateFrom, Const.DATE_SV_FORMAT),dateTo: Utils.parseDateToString(_bloc.dateTo, Const.DATE_SV_FORMAT),type: _bloc.transactionType));
              },
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index){return Container();},
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: _bloc.listDNC.length,
                  itemBuilder: (BuildContext context, int index){
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailDNC(
                          sttRec: _bloc.listDNC[index].sttRec.toString(),
                          levelApproval: _bloc.listDNC[index].capDuyet.toString(),
                          status: _bloc.listDNC[index].statusname.toString(),
                        ))).then((value) {
                          _bloc.add(GetListDNC(dateFrom: Utils.parseDateToString(_bloc.dateFrom, Const.DATE_SV_FORMAT),dateTo: Utils.parseDateToString(_bloc.dateTo, Const.DATE_SV_FORMAT),type: _bloc.transactionType));
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
                                        Text('Tiêu đề: ${_bloc.listDNC[index].dienGiai}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),),
                                        const SizedBox(height: 10,),
                                        Row(
                                          children: [
                                            const Icon(Icons.account_circle_outlined,color: Colors.grey,size: 12,),
                                            const SizedBox(width: 3,),
                                            Text(_bloc.listDNC[index].comment??'', style: const TextStyle(color: Colors.grey,fontSize: 12),),
                                          ],
                                        ),
                                        const SizedBox(height: 8,),
                                        Row(
                                          children: [
                                            const Icon(Icons.event_note,color: Colors.grey,size: 12,),
                                            const SizedBox(width: 3,),
                                            Expanded(child: Text('${_bloc.listDNC[index].statusname}', style: const TextStyle(color: Colors.grey,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(Utils.parseStringDateToString(_bloc.listDNC[index].ngayCt.toString(), Const.DATE_SV, Const.DATE_FORMAT_1), style: const TextStyle(color: Colors.black,fontSize: 12),),
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
          const SizedBox(height: 55,),
        ],
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
                "Danh sách đề nghị chi",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          InkWell(
            onTap: ()=>showDialog(
                context: context,
                builder: (context) => const OptionsFilterDate()).then((value){
              if(value != null){
                if(value[1] != null && value[2] != null){
                  _bloc.dateFrom =  Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT);
                  _bloc.dateTo =  Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT);
                  _bloc.add(GetListDNC(
                      dateFrom: _bloc.dateFrom.toString(),
                      dateTo: _bloc.dateTo.toString(),
                      type: _bloc.transactionType
                  ));
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
