import 'package:dms/screen/personnel/proposal/proposal_bloc.dart';
import 'package:dms/screen/personnel/proposal/widget/dynamic_form.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../menu/component/value_report_filter.dart';


class ProposalScreen extends StatefulWidget {
  final String title;
  final String controller;
  const ProposalScreen({key, required this.title, required this.controller});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  late ProposalBloc _bloc;
  int lastPage=0;
  int selectedPage=1;
  var resultFilter = [];
  @override
  void initState() {
    super.initState();
    _bloc = ProposalBloc(context);
    _bloc.add(GetPrefsProposal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProposalBloc, ProposalState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is ProposalFailure) {
            Utils.showCustomToast(
                context, Icons.check_circle_outline, state.error.toString());
          }
          else if(state is GetPrefsSuccess){
            _bloc.add(GetListProposalEvent(pageIndex: selectedPage,controller: widget.controller, listRequestDetail: resultFilter));
          }
          else if(state is GetListReportLayoutSuccess){
            resultFilter.clear();
            PersistentNavBarNavigator.pushNewScreen(context, screen: ValueReportFilter(
              listRPLayout: _bloc.listDataReportLayout,
              idReport: '',
              title: 'Lọc theo điều kiện',
              isBack: true,
            ),withNavBar: false).then((values){
              if(values != null){
                resultFilter = values[0];
                if(resultFilter.isNotEmpty){
                  _bloc.add(GetListProposalEvent(pageIndex: 1,controller: widget.controller, listRequestDetail: resultFilter));
                }
              }
            });
          }
        },
        child: BlocBuilder<ProposalBloc, ProposalState>(
          bloc: _bloc,
          builder: (BuildContext context, ProposalState state) {
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is GetListProposalEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',
                        style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is ProposalLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.controller == 'DayOff') {
            if (Const.phepCL > 0) {
              navigateToCreate();
            } else {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cảnh báo'),
                  content: const Text('Bạn đã nghỉ hết số phép năm này rồi :('),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('OK'),
                    )
                  ],
                ),
              );
            }
          } else {
            navigateToCreate();
          }
        },
        backgroundColor: subColor,
        child: const Icon(
          Icons.post_add,
          color: Colors.white,
        ),
      ),
    );
  }

  void navigateToCreate() {
    PersistentNavBarNavigator.pushNewScreen(context,
        screen: DynamicScreen(
          title: widget.title, controller: widget.controller, actionView: 0, listRequestDetail: [], sttRec: '', status: 2,
        ),
        withNavBar: true).then((value){
      if(value != null && value[0] == 'reload'){
        _bloc.add(GetListProposalEvent(pageIndex: selectedPage,controller: widget.controller, listRequestDetail: resultFilter));
      }
    });
  }

  buildBody(BuildContext context, ProposalState state) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(
            height: 10,
          ),
          Expanded(child: buildDynamicListData()),
          _bloc.totalPager > 1 ? _getDataPager() : Container(),
          const SizedBox(height: 5,),
        ],
      ),
    );
  }

  buildDynamicListData(){
    if (_bloc.jsonListData.isEmpty) {
      return Container();
    }
    var fields = _bloc.jsonListData['data']['gridDefine']['fields'];
    String keysViewDetail = _bloc.jsonListData['data']['gridDefine']['keys'];
    var data = _bloc.jsonListData['data']['gridData']['data'];

    return ListView.builder(
      itemCount: data.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        var row = data[index];
        return GestureDetector(
          onTap: (){
            List<Map<String, dynamic>> listRequestDetail = [];

            if(keysViewDetail.toString().replaceAll('null', '').isNotEmpty){
              keysViewDetail.toString().split(',').forEach((element){
                listRequestDetail.add({
                  "variable": element.toString().trim(),
                  "type": "",
                  "value": row[element.toString().trim()].toString().trim(),
                });
              });
            }

            if(listRequestDetail.isNotEmpty){
            for (var item in listRequestDetail) {
              var field = fields.firstWhere(
                    (f) => f["name"].toString().trim() == item["variable"].toString().trim(),
                orElse: () => {},
              );
              if (field.isNotEmpty) {
                item["variable"] = '${item["variable"].toString().trim()}_key_old';
                item["type"] = field["type"].toString().trim();
                if(item["type"] == 'DateTime' && item['value'].toString().replaceAll('null', '').isNotEmpty){
                  item['value'] =  item['value'].toString().trim().split('T').first.replaceAll('-', '').toString().trim();
                }
              }
            }}

            PersistentNavBarNavigator.pushNewScreen(context,
                screen: DynamicScreen(
                  title: widget.title, controller: widget.controller, actionView: 1,
                  listRequestDetail: listRequestDetail,
                  sttRec: row[widget.controller.contains('CheckinExplan') ? 'stt_rec_nv' : "stt_rec"].toString().trim(),
                  status: row[("status")].toString().trim().replaceAll('null', '').isNotEmpty
                      ?
                      int.parse(row[("status")].toString().trim().replaceAll('null', ''))
                      : 0,
                ),
                withNavBar: true).then((value){
              if(value != null && value[0] == 'reload'){
                _bloc.add(GetListProposalEvent(pageIndex: 1,controller: widget.controller, listRequestDetail: resultFilter));
              }
            });
          },
          child: Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fields
                    .where((field) => !field['hidden'])
                    .map<Widget>((field) {
                  var value = row[field['name']];
                      // Kiểm tra nếu field là DateTime, thì chuyển đổi định dạng
                  if (field['type'] == 'DateTime' && value is String) {
                    DateTime parsedDate = DateTime.parse(value);
                    value = "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "${field['header']}: $value",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        field['style']?.contains('bold: true') ?? false
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
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
                          _bloc.add(GetListProposalEvent(pageIndex: selectedPage,controller: widget.controller, listRequestDetail: resultFilter));
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
                            _bloc.add(GetListProposalEvent(pageIndex: selectedPage,controller: widget.controller, listRequestDetail: resultFilter));
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
                                _bloc.add(GetListProposalEvent(pageIndex: selectedPage,controller: widget.controller, listRequestDetail: resultFilter));
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: selectedPage == (index + 1) ?  mainColor : Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(48))
                                ),
                                child: Center(
                                  child: Text((index + 1).toString(),style: TextStyle(color: selectedPage == (index + 1) ?  Colors.white : Colors.black),),
                                ),
                              ),
                            );
                          },
                          separatorBuilder:(BuildContext context, int index)=> Container(width: 6,),
                          itemCount: _bloc.totalPager > 10 ? 10 : _bloc.totalPager),
                    ),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          if(selectedPage < _bloc.totalPager){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage + 1;
                            });
                            _bloc.add(GetListProposalEvent(pageIndex: selectedPage,controller: widget.controller, listRequestDetail: resultFilter));
                          }
                        },
                        child: const Icon(Icons.navigate_next_outlined,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = _bloc.totalPager;
                          });
                          _bloc.add(GetListProposalEvent(pageIndex: selectedPage,controller: widget.controller, listRequestDetail: resultFilter));
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

  buildAppBar() {
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
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
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
                "Danh sách phiếu ${widget.title}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: (){
              _bloc.add(GetLayoutSearchEvent(controller: widget.controller));
            },
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.search,
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
