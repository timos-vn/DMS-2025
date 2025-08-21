import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/screen/menu/component/seen_approval.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';

import '../../../options_input/options_input_screen.dart';
import 'detail_approval_bloc.dart';
import 'detail_approval_event.dart';
import 'detail_approval_state.dart';

class DetailApprovalScreen extends StatefulWidget {
  final String idApproval;
  final String nameApproval;

  const DetailApprovalScreen({Key? key,required this.idApproval,required this.nameApproval}) : super(key: key);
  @override
  _DetailApprovalScreenState createState() => _DetailApprovalScreenState();
}

class _DetailApprovalScreenState extends State<DetailApprovalScreen> {
  late DetailApprovalBloc _detailApprovalBloc;


  int status = 10;
  int option = 1;
  int lastPage=0;
  int selectedPage=1;

  String nameStatus='Chờ duyệt';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _detailApprovalBloc = DetailApprovalBloc(context);
    _detailApprovalBloc.add(GetPrefsDetailApproval());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DetailApprovalBloc, DetailApprovalState>(
          bloc: _detailApprovalBloc,
          listener: (context, state) {
            if(state is GetPrefsSuccess){
              _detailApprovalBloc.add(GetStatusApprovalEvent(widget.idApproval));
            }
            else if(state is GetListStatusApprovalSuccess){
              _detailApprovalBloc.add(GetListDetailApprovalEvent(widget.idApproval,status,option.toString(),selectedPage));
            }
            if (state is DetailApprovalFailure){
              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, ${state.error}');
            }
            else if (state is SelectedSuccess){
            }
          },
          child: BlocBuilder(
            bloc: _detailApprovalBloc,
            builder: (BuildContext context, DetailApprovalState state) {
              return Stack(
                children: [
                  buildBody(context,state),
                  Visibility(
                    visible: state is GetListDetailApprovalEmpty,
                    child: const  Center(
                      child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                    ),
                  ),
                  Visibility(
                    visible: state is DetailApprovalLoading,
                    child: const PendingAction(),
                  ),
                ],
              );
            },
          )),
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
            child: Center(
              child: Text(
                "${widget.nameApproval.toString()}".toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: ()=>  showDialog(
                context: context,
                builder: (context) => OptionsFilterDate(
                  listStatus: _detailApprovalBloc.listStatusApproval
                )).then(
                    (value){
                      print(value);
                  if(value != null){
                    if(!Utils.isEmpty(value[0]) || !Utils.isEmpty(value[1]) || !Utils.isEmpty(value[2]) || !Utils.isEmpty(value[3])){
                      if(!Utils.isEmpty(value[0])){
                        option = value[0];
                      }
                      if(!Utils.isEmpty(value[1])){
                        status = value[1];
                      }
                      if(!Utils.isEmpty(value[5])){
                        setState(() {
                          nameStatus = value[5];
                        });
                      }
                      _detailApprovalBloc.add(GetListDetailApprovalEvent(widget.idApproval,status,option.toString(),selectedPage));
                    }else{
                    }
                  }
                }),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.filter_alt_outlined,
                size: 25,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  buildBody(BuildContext context,DetailApprovalState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 15,),
          Row(
            children: [
              const Expanded(child: Divider()),
              Text(
                'Danh sách phiếu: ${nameStatus.toString()}',
                style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 13,),maxLines: 1,overflow: TextOverflow.ellipsis,
              ),
              const Expanded(child: Divider())
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: RefreshIndicator(
                  color: mainColor,
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 2));
                    _detailApprovalBloc.add(GetListDetailApprovalEvent(widget.idApproval,status,option.toString(),selectedPage));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index){
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>
                              SeenApproval(
                                tile: widget.nameApproval,
                                sttRec: _detailApprovalBloc.listDetailApprovalDisplay[index].sttRec.toString(),
                                idApproval: widget.idApproval,
                                status: int.parse(_detailApprovalBloc.listDetailApprovalDisplay[index].status.toString()),
                              ))).then((value){
                            if(value != null && value[0] == 'Reload'){
                              _detailApprovalBloc.add(GetListDetailApprovalEvent(widget.idApproval,status,option.toString(),selectedPage));
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4,right: 4),
                          child: Card(
                            elevation: 5,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.description),
                                  const SizedBox(width: 10,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Người lập: ${_detailApprovalBloc.listDetailApprovalDisplay[index].userName.toString().trim()}',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(fontWeight: FontWeight.bold,),
                                        ),
                                        const SizedBox(height: 5,),
                                        Text('Ngày lập: ${Utils.parseDateTToString(_detailApprovalBloc.listDetailApprovalDisplay[index].ngayCt.toString().trim(), Const.DATE_FORMAT_1)}'
                                          ,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.normal,color: Colors.grey),),
                                        const SizedBox(height: 5,),
                                        Text('Yêu cầu từ: ${ _detailApprovalBloc.listDetailApprovalDisplay[index].dateFrom.toString().trim().replaceAll('null', '').isNotEmpty ?
                                            Utils.parseDateTToString(_detailApprovalBloc.listDetailApprovalDisplay[index].dateFrom.toString().trim(), Const.DATE_FORMAT_1) : ''}'
                                            '  đến  ${ _detailApprovalBloc.listDetailApprovalDisplay[index].dateTo.toString().trim().replaceAll('null', '').isNotEmpty ?
                                        Utils.parseDateTToString(_detailApprovalBloc.listDetailApprovalDisplay[index].dateTo.toString().trim(), Const.DATE_FORMAT_1) : ''}'
                                          ,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.normal,color: Colors.grey),),
                                        const SizedBox(height: 5,),
                                        Text('Mô tả: ${_detailApprovalBloc.listDetailApprovalDisplay[index].desc.toString().trim()}'
                                          ,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.normal,color: Colors.grey),),
                                        const SizedBox(height: 5,),
                                        Text('Trạng thái: ${_detailApprovalBloc.listDetailApprovalDisplay[index].statusname.toString().trim()}'
                                          ,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.normal,color: Colors.blue),),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,size: 25,color: Colors.blueGrey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index)=> Container(),
                    itemCount: _detailApprovalBloc.listDetailApprovalDisplay.length,
                  ))),
          _detailApprovalBloc.totalMyPager > 1 ? _getDataPager() : Container(),
          const SizedBox(height: 55,)
        ],
      ),
    );
  }

  Widget _getDataPager() {
    return Center(
      child: SizedBox(
        height: 57,
        width: double.infinity,
        child: Column(
          children: [
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: (){
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = 1;
                          });
                          _detailApprovalBloc.add(GetListDetailApprovalEvent(widget.idApproval,status,option.toString(),selectedPage));
                        },
                        child: const Icon(Icons.skip_previous_outlined,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          if(selectedPage > 1){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage - 1;
                            });
                            _detailApprovalBloc.add(GetListDetailApprovalEvent(widget.idApproval,status,option.toString(),selectedPage));
                          }
                        },
                        child: const Icon(Icons.navigate_before_outlined,color: Colors.grey,)),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index){
                            return InkWell(
                              onTap: (){
                                setState(() {
                                  lastPage = selectedPage;
                                  selectedPage = index+1;
                                });
                                _detailApprovalBloc.add(GetListDetailApprovalEvent(widget.idApproval,status,option.toString(),selectedPage));
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: selectedPage == (index + 1) ?  Colors.orange : Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(48))
                                ),
                                child: Center(
                                  child: Text((index + 1).toString(),style: TextStyle(color: selectedPage == (index + 1) ?  Colors.white : Colors.black),),
                                ),
                              ),
                            );
                          },
                          separatorBuilder:(BuildContext context, int index)=> Container(width: 6,),
                          itemCount: _detailApprovalBloc.totalMyPager),
                    ),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          if(selectedPage < _detailApprovalBloc.totalMyPager){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage + 1;
                            });
                            _detailApprovalBloc.add(GetListDetailApprovalEvent(widget.idApproval,status,option.toString(),selectedPage));
                          }
                        },
                        child: const Icon(Icons.navigate_next_outlined,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = _detailApprovalBloc.totalMyPager;
                          });
                          _detailApprovalBloc.add(GetListDetailApprovalEvent(widget.idApproval,status,option.toString(),selectedPage));
                        },
                        child: const Icon(Icons.skip_next_outlined,color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}