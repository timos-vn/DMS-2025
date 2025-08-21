// ignore_for_file: unnecessary_null_comparison, unrelated_type_equality_checks

import 'package:dms/screen/dms/check_in/search_tour/search_tour_bloc.dart';
import 'package:dms/screen/dms/check_in/search_tour/search_tour_event.dart';
import 'package:dms/screen/dms/check_in/search_tour/search_tour_state.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


import '../../../../model/network/response/list_state_customer.dart';
import '../../../../model/network/response/list_tour_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/debouncer.dart';

class SearchTourScreen extends StatefulWidget {
  final String idTour;
  final String title;
  final String idState;
  final bool isTour;

  const SearchTourScreen({Key? key,required this.idTour,required this.title,required this.idState,required this.isTour,}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchTourScreenState();
  }
}

class SearchTourScreenState extends State<SearchTourScreen> {

  late SearchTourBloc _bloc;

  final focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  final Debounce onSearchDebounce =  Debounce(delay:  const Duration(milliseconds: 1000));

  List<GetListTourResponseData> _dataListSearchTour = [];
  List<ListStateCustomerData> _dataListSearchState = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SearchTourBloc(context);
    _bloc.add(GetPrefsSearchTour());

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListTourAndStateEvent(searchKey: Utils.convertKeySearch(_searchController.text),isLoadMore: true, isTour: widget.isTour,));
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
        child: BlocListener<SearchTourBloc,SearchTourState>(
            bloc: _bloc,
            listener: (context, state) {
              if(state is GetPrefsSuccess){
                _bloc.add(GetListTourAndStateEvent(searchKey: '', isTour: widget.isTour));
              }
            },
            child: BlocBuilder<SearchTourBloc,SearchTourState>(
                bloc: _bloc,
                builder: (BuildContext context, SearchTourState state) {
                  return widget.isTour == true ? buildBodyTour(context, state) : buildBodyState(context, state);
                })),
      ),
    );
  }


  buildBodyTour(BuildContext context,SearchTourState state){
    _dataListSearchTour = _bloc.searchResultsTour;
    int length = _dataListSearchTour.length;
    if (state is GetListSuccess) {
      _hasReachedMax = length < _bloc.currentPage * 20;
    } else {
      _hasReachedMax = false;
    }
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: Stack(children: <Widget>[
              ListView.builder(
                  padding: const EdgeInsets.all(0),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index){
                    return index >= length
                        ? Container(
                      height: 100.0,
                      color: white,
                      child: const PendingAction(),
                    )
                        :
                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context,['Yeah',_dataListSearchTour[index].maTuyen?.toString().trim(),_dataListSearchTour[index].tenTuyen?.toString().trim()]);
                      },
                      child: Card(
                        semanticContainer: true,
                        margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${_dataListSearchTour[index].tenTuyen?.toString().trim()}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '${_dataListSearchTour[index].maTuyen?.toString().trim()}',
                                            textAlign: TextAlign.left,
                                            style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 10.5,color:  Color(
                                                0xff358032)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
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
                  },
                  //separatorBuilder: (BuildContext context, int index)=> Container(),
                  itemCount: length
              ),
              Visibility(
                visible: state is GetListEmpty,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
              Visibility(
                visible: state is SearchLoading,
                child: const PendingAction(),
              ),
            ]),
          )
        ],
      ),
    );
  }

  buildBodyState(BuildContext context,SearchTourState state){
    _dataListSearchState = _bloc.searchResultsState;
    int length = _dataListSearchState.length;
    if (state is GetListSuccess) {
      _hasReachedMax = length < _bloc.currentPage * 20;
    } else {
      _hasReachedMax = false;
    }
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: Stack(children: <Widget>[
              ListView.builder(
                  padding: const EdgeInsets.all(0),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index){
                    return index >= length
                        ? Container(
                      height: 100.0,
                      color: white,
                      child: const PendingAction(),
                    )
                        :
                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context,['Yeah',_dataListSearchState[index].maTinhTrang?.toString().trim(),_dataListSearchState[index].tenTinhTrang?.toString().trim()]);
                      },
                      child: Card(
                        semanticContainer: true,
                        margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${_dataListSearchState[index].tenTinhTrang?.toString().trim()}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '${_dataListSearchState[index].maTinhTrang?.toString().trim()}',
                                            textAlign: TextAlign.left,
                                            style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 10.5,color:  Color(
                                                0xff358032)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
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
                  },
                  //separatorBuilder: (BuildContext context, int index)=> Container(),
                  itemCount: length
              ),
              Visibility(
                visible: state is GetListEmpty,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
              Visibility(
                visible: state is SearchLoading,
                child: const PendingAction(),
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
                          onChanged: (text) => onSearchDebounce.debounce(
                                () {
                              if(text != null)  _bloc.add(GetListTourAndStateEvent(searchKey: Utils.convertKeySearch(_searchController.text), isTour: widget.isTour));
                            },
                          ),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: transparent,
                              hintText: widget.title.toString(),
                              hintStyle: const TextStyle(color: Colors.white),
                              contentPadding: const EdgeInsets.only(
                                  bottom: 10, top: 14)
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _bloc.isShowCancelButton,
                      child: InkWell(
                          child: Icon(
                            MdiIcons.close,
                            color: Colors.white,
                            size: 28,
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
