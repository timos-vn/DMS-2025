import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/themes/colors.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../detail_approval/detail_approval_screen.dart';
import 'approval_bloc.dart';
import 'approval_event.dart';
import 'approval_sate.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({Key? key}) : super(key: key);

  @override
  _ApprovalScreenState createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen>with TickerProviderStateMixin {

  late ApprovalBloc _bloc;

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  @override
  void initState() {
    super.initState();
    _bloc = ApprovalBloc(context);
    _scrollController = ScrollController();
    _bloc.add(GetPrefs());

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListApprovalEvent(isLoadMore: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context)=>_bloc,
        child: BlocListener<ApprovalBloc,ApprovalState>(
          listener: (context, state){
            if(state is GetPrefsSuccess){
              _bloc.add(GetListApprovalEvent());
            }
          },
            child: BlocBuilder(
                bloc:  _bloc,
              builder: (BuildContext context,ApprovalState state){
                int length = _bloc.listApprovalDisplay.length;
                if (state is GetListApprovalEmpty){
                  _hasReachedMax = length < _bloc.currentPage * 20;
                }
                return Stack(
                  children: [
                    buildBody(context,state,length),
                    Visibility(
                      visible: state is GetListApprovalEmpty,
                      child:const Center(
                        child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                      ),
                    ),
                    Visibility(
                      visible: state is ApprovalLoading,
                      child: const PendingAction(),
                    )
                  ],
                );
              },),
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
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
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
                'Duyệt phiếu tổng hợp',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          Container(width: 50,)
        ],
      ),
    );
  }

  buildBody(BuildContext context,ApprovalState state,int length){
    return Column(
      children: [
        buildAppBar(),
        Expanded(
          child: RefreshIndicator(
            color: mainColor,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 2));
              _bloc.add(GetListApprovalEvent());
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 60,top: 10),
              color: Colors.grey.withOpacity(.1),
              child:  ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.only(top: 10),
                itemBuilder: (BuildContext context, int index){
                  return GestureDetector(
                    onTap: (){
                      PersistentNavBarNavigator.pushNewScreen(context, screen: DetailApprovalScreen(idApproval: _bloc.listApprovalDisplay[index].loaiDuyet.toString(),nameApproval:  _bloc.listApprovalDisplay[index].tenLoai.toString(),),withNavBar: true).then((value){
                        _bloc.listApprovalDisplay.clear();
                        _bloc.add(GetListApprovalEvent());
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8,right: 8),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18,top: 18,right: 10,bottom: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.description),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_bloc.listApprovalDisplay[index].tenLoai.toString().trim()}',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Text('${_bloc.listApprovalDisplay[index].pendingApproval.toString().trim()}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.blueGrey),),
                              const SizedBox(width: 10,),
                              Icon(Icons.chevron_right,size: 25,color: Colors.grey,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index)=> Container(),
                itemCount: length == 0
                    ? length
                    : _hasReachedMax ? length : length + 1,
              ),
            ),
          ),
        )
      ],
    );
  }
}
