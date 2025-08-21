import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../dms_bloc.dart';
import '../dms_event.dart';
import '../dms_state.dart';
import 'ticket_detail_screen.dart';
import 'model/draft_ticket.dart';


class ListInventoryRequestScreen extends StatefulWidget {
  const ListInventoryRequestScreen({
    key,
  });

  @override
  _ListInventoryRequestScreenState createState() => _ListInventoryRequestScreenState();
}

class _ListInventoryRequestScreenState extends State<ListInventoryRequestScreen> {
  late DMSBloc _bloc;
  bool showSearch = false;
  TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  // Map Draft
  Map<String, DraftTicket> draftTickets = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = DMSBloc(context);
    _loadDraftTickets();
    _bloc.add(GetPrefsDMSEvent());
  }

  Future<void> _loadDraftTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('draftTickets');
    if (jsonString == null) return;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    setState(() {
      draftTickets = jsonMap.map((key, value) =>
          MapEntry(key, DraftTicket.fromJson(value)));
    });
  }

  // Lưu xuống SharedPreferences
  Future<void> _saveDraftTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = draftTickets.map((key, value) =>
        MapEntry(key, value.toJson()));
    final jsonString = jsonEncode(jsonMap);
    await prefs.setString('draftTickets', jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DMSBloc, DMSState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is GetPrefsSuccess) {
            _bloc.add(GetListInventoryRequest(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage));
          }
          else if (state is DMSFailure) {
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error.toString());
          }
        },
        child: BlocBuilder<DMSBloc, DMSState>(
          bloc: _bloc,
          builder: (BuildContext context, DMSState state) {
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is DMSLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context, DMSState state) {
    return Column(
      children: [
        buildAppBar(),
        Expanded(
          child: ListView.builder(
              itemCount: _bloc.listInventoryRequest.length,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index){
                final ticket = _bloc.listInventoryRequest[index];
                final draft = draftTickets[ticket.sttRec];
                final isDraft = draft != null && draft.historyList.isNotEmpty;
                return GestureDetector(
                  onTap: ()async{
                    final updatedDraft = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketDetailScreen(
                          ticket: ticket,
                          draft: draft,
                          onCompleteDraft: (sttRec) {
                            // Bấm Xác nhận & Gửi: Xoá ngay, không cần return draft nữa
                            draftTickets.remove(sttRec);
                            _saveDraftTickets();
                            _loadDraftTickets();
                          },
                        ),
                      ),
                    );

                    if (updatedDraft != null) {
                      // Trường hợp back bình thường: vẫn giữ draft, cập nhật lại
                      setState(() {
                        draftTickets[ticket.sttRec ?? ''] = updatedDraft;
                      });
                      await _saveDraftTickets();
                    }
                  },
                  child: Card(
                    semanticContainer: true,
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 5,
                            height: 70,
                            decoration: BoxDecoration(
                                color: Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
                                borderRadius:const BorderRadius.all( Radius.circular(6),)
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding:const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Mã: ${_bloc.listInventoryRequest[index].soCt.toString().trim()}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        'Ngày lập: ${(_bloc.listInventoryRequest[index].ngayCt.toString().isNotEmpty && _bloc.listInventoryRequest[index].ngayCt.toString() != 'null') ? Utils.safeFormatDate(_bloc.listInventoryRequest[index].ngayCt.toString().trim()).toString() : 'Đang cập nhật'}',
                                        textAlign: TextAlign.left,
                                        style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(
                                    'Thời gian kiểm kê: ${_bloc.listInventoryRequest[index].tgKk.toString().trim()}',
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.blueGrey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10,),
                                  isDraft
                                      ? Text('Đang làm dở: ${draft?.lastModified.toString().split('.').first}',style: TextStyle(color: Colors.pink,fontSize: 13),)
                                      : Container(),
                                  const SizedBox(height: 10,),
                                  Text(
                                    'Nội dung: ${_bloc.listInventoryRequest[index].dienGiai.toString().trim()}',
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
          ),
        ),
        _bloc.totalPager > 1 ? _getDataPager() : Container(),
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
          gradient:const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: StatefulBuilder(
        builder: (context, setState) {
          Timer? debounce;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: ()=> Navigator.of(context).pop(Const.currencyCode),
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
              Visibility(
                visible: !showSearch,
                child: const Expanded(
                  child: Center(
                    child: Text(
                      'Danh sách yêu cầu kiểm kê',
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                      maxLines: 1,overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              if (!showSearch)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _searchFocus.requestFocus();
                    setState(() => showSearch = true);},
                  child: SizedBox( height: 50,  width: 40,
                    child: const Icon(
                      EneftyIcons.search_normal_outline,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      focusNode: _searchFocus,
                      onChanged: (value) {
                        if (debounce?.isActive ?? false) debounce!.cancel();
                        debounce = Timer(const Duration(milliseconds: 500), () {
                          _bloc.listInventoryRequest.clear();
                          _bloc.add(GetListInventoryRequest(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage));
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'stt_rec, ngay_ct, so_ct ...',
                        hintStyle: const TextStyle(color: Colors.white70,fontSize: 13),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 1),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            Utils.dateTimePickerCustom(context).then((value){
                              if(value != null){
                                searchController.text = '';
                                _bloc.listInventoryRequest.clear();
                                searchController.text = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT_2);
                                _bloc.add(GetListInventoryRequest(searchKey: searchController.text,pageIndex: selectedPage));
                              }
                            });
                          },
                          child: const Icon(Icons.date_range, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              Visibility(
                visible: showSearch,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: (){
                    FocusScope.of(context).unfocus();
                    showSearch = false;
                    searchController.text = '';
                    _bloc.listInventoryRequest.clear();
                    _bloc.add(GetListInventoryRequest(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage));
                  },
                  child: SizedBox(
                    height: 50,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 10,top: 13),
                      child: Text('Huỷ bỏ',style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
                    ),
                  ),
                ),
              )
            ],
          );
        }
      ),
    );
  }

  int lastPage=0;
  int selectedPage=1;

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
                          _bloc.add(GetListInventoryRequest(searchKey: searchController.text,pageIndex: selectedPage));
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
                            _bloc.add(GetListInventoryRequest(searchKey: searchController.text,pageIndex: selectedPage));
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
                                _bloc.add(GetListInventoryRequest(searchKey: searchController.text,pageIndex: selectedPage));
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
                            _bloc.add(GetListInventoryRequest(searchKey: searchController.text,pageIndex: selectedPage));
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
                          _bloc.add(GetListInventoryRequest(searchKey: searchController.text,pageIndex: selectedPage));
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
