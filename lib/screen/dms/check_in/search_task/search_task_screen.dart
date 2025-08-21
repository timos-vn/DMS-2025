// ignore_for_file: unnecessary_null_comparison, unrelated_type_equality_checks

import 'package:dms/screen/dms/check_in/search_task/search_task_bloc.dart';
import 'package:dms/screen/dms/check_in/search_task/search_task_event.dart';
import 'package:dms/screen/dms/check_in/search_task/search_task_state.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


import '../../../../model/entity/item_check_in.dart';
import '../../../../model/network/response/list_checkin_response.dart';
import '../../../../model/network/response/list_tour_response.dart';
import '../../../../model/network/response/search_item_taks_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/debouncer.dart';

class SearchTaskScreen extends StatefulWidget {
  final String dateTime;
  final List<ItemCheckInOffline> listCheckInOffline;

  const SearchTaskScreen({Key? key,required this.dateTime, required this.listCheckInOffline}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchTaskScreenState();
  }
}

class SearchTaskScreenState extends State<SearchTaskScreen> {

  late SearchTaskBloc _bloc;

  final focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  final Debounce onSearchDebounce =  Debounce(delay:  const Duration(milliseconds: 1000));

  List<SearchItemTaskResponseData> _dataListSearch = [];

  ListCheckIn? itemSelect;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SearchTaskBloc(context);
    _bloc.add(GetPrefsSearchTask());
    print('=? ${Const.checkInOnline}');
    if(Const.checkInOnline == false){
      _bloc.listCheckInOffline = widget.listCheckInOffline;
      _bloc.listItemReSearch = widget.listCheckInOffline;
    }
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListTaskEvent(searchKey: Utils.convertKeySearch(_searchController.text),dateTime: widget.dateTime,isLoadMore: true,));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus( FocusNode());
        },
        child: BlocListener<SearchTaskBloc,SearchTaskState>(
            bloc: _bloc,
            listener: (context, state) {
              if(state is GetPrefsSuccess){
                if(Const.checkInOnline == true){
                  // _bloc.add(GetListTaskEvent(searchKey: '',dateTime: widget.dateTime));
                }
              }
            },
            child: BlocBuilder<SearchTaskBloc,SearchTaskState>(
                bloc: _bloc,
                builder: (BuildContext context, SearchTaskState state) {
                  return Stack(
                    children: [
                      buildBody(context, state),
                      Visibility(
                        visible: state is SearchTaskLoading,
                        child: const PendingAction(),
                      ),
                    ],
                  );
                })),
      ),
    );
  }


  buildBody(BuildContext context,SearchTaskState state){
    int length = 0;
    if(Const.checkInOnline == true){
      _dataListSearch = _bloc.searchResults;
      length = _dataListSearch.length;
      print('Leng: $length');
      if (state is GetListTaskSuccess) {
        _hasReachedMax = length < _bloc.currentPage * 20;
      } else {
        _hasReachedMax = false;
      }
    }
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Const.checkInOnline == true
          ?
      Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: Stack(children: <Widget>[
              ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                controller: _scrollController,
                // physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                      itemSelect = ListCheckIn(
                          id: _dataListSearch[index].id,
                          tieuDe: _dataListSearch[index].tieuDe,
                          ngayCheckin: _dataListSearch[index].ngayCheckin,
                          maKh:_dataListSearch[index].maKh,
                          tenCh: _dataListSearch[index].tenCh,
                          diaChi: _dataListSearch[index].diaChi,
                          dienThoai: _dataListSearch[index].dienThoai,
                          gps: _dataListSearch[index].gps,
                          trangThai: _dataListSearch[index].trangThai,
                          tgHoanThanh: _dataListSearch[index].tgHoanThanh,
                          lastCheckOut: _dataListSearch[index].lastCheckOut,
                          isCheckInSuccessful: _dataListSearch[index].trangThai?.trim() == 'Hoàn thành' ? true : false,
                          latLong: _dataListSearch[index].latLong,
                          numberTimeCheckOut: (_dataListSearch[index].numberTimeCheckOut.toString() != null && _dataListSearch[index].numberTimeCheckOut.toString() != 'null' && _dataListSearch[index].numberTimeCheckOut.toString() != '' )
                              ? int.parse(_dataListSearch[index].numberTimeCheckOut.toString()) : 0
                      );
                      Navigator.pop(context,['Yeah',itemSelect]);
                    },
                    child: Container(
                        height: 126,width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width:13,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12),bottomLeft: Radius.circular(12)),
                                  color:   Colors.deepPurple
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: grey_100,
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(12),bottomRight: Radius.circular(12)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8,right: 12,top: 10,bottom: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(child: Text('${_dataListSearch[index].tieuDe}',style:const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),),
                                          const SizedBox(width: 5,),
                                          const Text(//'${_bloc.listCheckInToDay[index].gps != '' ? _bloc.listCheckInToDay[index].gps : 0}'
                                            '0 Km',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.red),)
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(MdiIcons.store,color: subColor,size: 16,),
                                          const SizedBox(width: 5,),
                                          Flexible(child: Text('${_dataListSearch[index].tenCh}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(MdiIcons.mapMarkerRadiusOutline,color: subColor,size: 16,),
                                          const SizedBox(width: 5,),
                                          Flexible(child: Text('${_dataListSearch[index].diaChi}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(MdiIcons.phoneClassic,color: subColor,size: 16,),
                                          const SizedBox(width: 5,),
                                          Flexible(child: Text('${_dataListSearch[index].dienThoai}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(MdiIcons.calendarCheckOutline,color: subColor,size: 16,),
                                              const SizedBox(width: 5,),
                                              Text(_dataListSearch[index].trangThai?.trim() == 'Hoàn thành'
                                                  ?
                                              'Đã viếng thăm lúc: ${(_dataListSearch[index].tgHoanThanh == null || _dataListSearch[index].tgHoanThanh == "") ? '' : Utils.parseDateTToString(_dataListSearch[index].tgHoanThanh.toString(), Const.TIME)}'
                                                  :
                                              'Chưa viếng thăm',
                                                style:TextStyle(
                                                    color: _dataListSearch[index].trangThai?.trim() == 'Hoàn thành' ? Colors.blueAccent : Colors.red,
                                                    fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                            ],
                                          ),
                                          Text((_dataListSearch[index].lastCheckOut != null && _dataListSearch[index].lastCheckOut != 'null')
                                              ?
                                          'Gầy đây: ${Utils.parseDateTToString(_dataListSearch[index].lastCheckOut.toString(), Const.TIME)}'
                                              :
                                          '.....',
                                            style:TextStyle(
                                                color: _dataListSearch[index].trangThai?.trim() == 'Hoàn thành' ? Colors.blueGrey : Colors.black,
                                                fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                    ),
                  );
                },
              ),
              Visibility(
                visible: state is GetListTaskEmpty,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
            ]),
          )
        ],
      )
          :
      Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: Stack(children: <Widget>[
              ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                // physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _bloc.listItemReSearch.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                      itemSelect = ListCheckIn(
                          id: (_bloc.listItemReSearch[index].idCheckIn != "null" && _bloc.listItemReSearch[index].idCheckIn != '') ? int.parse(_bloc.listItemReSearch[index].idCheckIn.toString()) : 0,
                          tieuDe: _bloc.listItemReSearch[index].tieuDe,
                          ngayCheckin: _bloc.listItemReSearch[index].ngayCheckin,
                          maKh: _bloc.listItemReSearch[index].maKh,
                          tenCh: _bloc.listItemReSearch[index].tenCh,
                          diaChi: _bloc.listItemReSearch[index].diaChi,
                          dienThoai: _bloc.listItemReSearch[index].dienThoai,
                          gps: _bloc.listItemReSearch[index].gps,
                          trangThai: _bloc.listItemReSearch[index].trangThai,
                          tgHoanThanh: _bloc.listItemReSearch[index].tgHoanThanh,
                          lastCheckOut: _bloc.listItemReSearch[index].lastChko,
                          isCheckInSuccessful: _bloc.listItemReSearch[index].trangThai?.trim() == 'Hoàn thành' ? true : false,
                          latLong: _bloc.listItemReSearch[index].latlong,
                          numberTimeCheckOut: _bloc.listItemReSearch[index].numberTimeCheckOut
                      );
                      Navigator.pop(context,['Yeah',itemSelect]);
                    },
                    child: Container(
                        height: 126,width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width:13,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12),bottomLeft: Radius.circular(12)),
                                  color:   Colors.deepPurple
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: grey_100,
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(12),bottomRight: Radius.circular(12)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8,right: 12,top: 10,bottom: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(child: Text('${_bloc.listItemReSearch[index].tieuDe}',style:const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),),
                                          const SizedBox(width: 5,),
                                          const Text(//'${_bloc.listCheckInToDay[index].gps != '' ? _bloc.listCheckInToDay[index].gps : 0}'
                                            '0 Km',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.red),)
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(MdiIcons.store,color: subColor,size: 16,),
                                          const SizedBox(width: 5,),
                                          Flexible(child: Text('${_bloc.listItemReSearch[index].tenCh}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(MdiIcons.mapMarkerRadiusOutline,color: subColor,size: 16,),
                                          const SizedBox(width: 5,),
                                          Flexible(child: Text('${_bloc.listItemReSearch[index].diaChi}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(MdiIcons.phoneClassic,color: subColor,size: 16,),
                                          const SizedBox(width: 5,),
                                          Flexible(child: Text('${_bloc.listItemReSearch[index].dienThoai}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(MdiIcons.calendarCheckOutline,color: subColor,size: 16,),
                                              const SizedBox(width: 5,),
                                              Text(_bloc.listItemReSearch[index].trangThai?.trim() == 'Hoàn thành'
                                                  ?
                                              'Đã viếng thăm lúc: ${(_bloc.listItemReSearch[index].tgHoanThanh == null || _bloc.listItemReSearch[index].tgHoanThanh == "") ? '' : Utils.parseDateTToString(_bloc.listItemReSearch[index].tgHoanThanh.toString(), Const.TIME)}'
                                                  :
                                              'Chưa viếng thăm',
                                                style:TextStyle(
                                                    color: _bloc.listItemReSearch[index].trangThai?.trim() == 'Hoàn thành' ? Colors.blueAccent : Colors.red,
                                                    fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                            ],
                                          ),
                                          Text((_bloc.listItemReSearch[index].lastChko != null && _bloc.listItemReSearch[index].lastChko != 'null')
                                              ?
                                          'Gầy đây: ${Utils.parseDateTToString(_bloc.listItemReSearch[index].lastChko.toString(), Const.TIME)}'
                                              :
                                          '.....',
                                            style:TextStyle(
                                                color: _bloc.listItemReSearch[index].trangThai?.trim() == 'Hoàn thành' ? Colors.blueGrey : Colors.black,
                                                fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                    ),
                  );
                },
              ),
              Visibility(
                visible: state is GetListTaskEmpty,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
            ]),
          )
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
      padding: const EdgeInsets.fromLTRB(5, 35, 5,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){
              Navigator.pop(context,['Back']);
            },
            child: Container(
              width: 40,
              height: 50,
              padding: const EdgeInsets.only(bottom: 10),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextField(
                          autofocus: true,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                          focusNode: focusNode,
                          onSubmitted: (text) {
                            //_bloc.add(GetListTourEvent(searchKey:_searchController.text));
                          },
                          controller: _searchController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onChanged: (text) {
                            if(Const.checkInOnline == true){
                              onSearchDebounce.debounce(
                                    () {
                                  if(text.isNotEmpty){
                                    _bloc.searchResults.clear();
                                    _bloc.add(GetListTaskEvent(searchKey: Utils.convertKeySearch(text),dateTime: widget.dateTime));
                                  }
                                },
                              );
                            }
                            else{
                              _bloc.add(SearchCustomerCheckInEvent(text));
                              setState(() {});
                            }
                            _bloc.add(CheckShowCloseEvent(text));
                          },
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: transparent,
                              hintText: "Tìm kiếm khách hàng check-in",
                              hintStyle: TextStyle(color: Colors.white),
                              contentPadding: EdgeInsets.only(
                                  bottom: 10, top: 15)
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _bloc.isShowCancelButton,
                      child: InkWell(
                          child:  Icon(
                            MdiIcons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                          onTap: () {
                            _searchController.text = "";
                            _bloc.add(CheckShowCloseEvent(""));
                          }),
                    )
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }
}
