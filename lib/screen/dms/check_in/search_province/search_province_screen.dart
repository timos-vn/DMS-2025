// ignore_for_file: unnecessary_null_comparison, unrelated_type_equality_checks

import 'package:dms/screen/dms/check_in/search_province/search_province_bloc.dart';
import 'package:dms/screen/dms/check_in/search_province/search_province_event.dart';
import 'package:dms/screen/dms/check_in/search_province/search_province_state.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../model/network/response/list_area_response.dart';
import '../../../../model/network/response/list_commune_respons.dart';
import '../../../../model/network/response/list_district_response.dart';
import '../../../../model/network/response/list_hinh_thuc_response.dart';
import '../../../../model/network/response/list_province_response.dart';
import '../../../../model/network/response/list_tour_response.dart';
import '../../../../model/network/response/list_type_store_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/debouncer.dart';

class SearchProvinceScreen extends StatefulWidget {
  final String? idProvince;
  final String? idDistrict;
  final String title;
  final int typeGetList;
  final String idArea;

  const SearchProvinceScreen({Key? key, this.idProvince,this.idDistrict, required this.title,required this.typeGetList,required this.idArea}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchProvinceScreenState();
  }
}

class SearchProvinceScreenState extends State<SearchProvinceScreen> {

  late SearchProvinceBloc _bloc;

  final focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  final Debounce onSearchDebounce =  Debounce(delay:  const Duration(milliseconds: 1000));

  List<ListProvinceResponseData> _dataListSearchProvince = [];
  List<ListDistrictResponseData> _dataListSearchDistrict = [];
  List<ListCommuneResponseData> _dataListSearchCommune = [];

  List<ListAreaResponseData> _dataListSearchArea = [];

  List<ListTypeStoreResponseData> _dataListSearchTypeStore = [];
  List<ListStoreFormResponseData> _dataListSearchStoreForm = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SearchProvinceBloc(context);
    _bloc.add(GetPrefsSearchProvince());

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        if(widget.typeGetList == 0){
          _bloc.add(GetListProvinceEvent(idArea: widget.idArea.toString(),idProvince: widget.idProvince,typeGetList: widget.typeGetList,idDistrict: widget.idDistrict ,isLoadMore: true, keysText: '',));
        }
        else{
          _bloc.add(GetListProvinceEvent(
              idArea: widget.idArea.toString(),
              idProvince: widget.idProvince,
              typeGetList: widget.typeGetList,
              idDistrict: widget.idDistrict,
              keysText: Utils.convertKeySearch(_searchController.text),
              isLoadMore: true)
          );
        }
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
        child: BlocListener<SearchProvinceBloc,SearchProvinceState>(
            bloc: _bloc,
            listener: (context, state) {
              if(state is GetPrefsSuccess){
                _bloc.add(GetListProvinceEvent(idArea: widget.idArea.toString(),idProvince: widget.idProvince,typeGetList: widget.typeGetList,idDistrict: widget.idDistrict,keysText: ''));
              }
            },
            child: BlocBuilder<SearchProvinceBloc,SearchProvinceState>(
                bloc: _bloc,
                builder: (BuildContext context, SearchProvinceState state) {
                  return widget.typeGetList == 1 ? buildBodyArea(context,state) :
                  widget.typeGetList == 0?
                  ((widget.idProvince!.isEmpty && widget.idDistrict!.isEmpty) ?
                  buildBodyProvince(context, state) :
                  (widget.idProvince!.isNotEmpty && widget.idDistrict!.isEmpty) ?
                  buildBodyDistrict(context, state):buildBodyCommune(context, state)) :
                  widget.typeGetList == 2 ? buildBodyStoreForm(context, state) : buildBodyTypeStore(context, state);
                })),
      ),
    );
  }


  buildBodyProvince(BuildContext context,SearchProvinceState state){
    _dataListSearchProvince = _bloc.searchResultsProvince;
    int length = _dataListSearchProvince.length;
    if (state is GetListProvinceSuccess) {
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
                  controller: _scrollController,
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
                        Navigator.pop(context,['Yeah',_dataListSearchProvince[index].maTinh?.toString().trim(),_dataListSearchProvince[index].tenTinh?.toString().trim()]);
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
                                              '${_dataListSearchProvince[index].tenTinh?.toString().trim()}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '#${index + 1}',
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
                visible: state is GetListProvinceEmpty,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!! ',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
              Visibility(
                visible: state is SearchProvinceLoading,
                child: const PendingAction(),
              ),
            ]),
          )
        ],
      ),
    );
  }

  buildBodyDistrict(BuildContext context,SearchProvinceState state){
    _dataListSearchDistrict = _bloc.searchResultsDistrict;
    int length = _dataListSearchDistrict.length;
    if (state is GetListProvinceSuccess) {
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
                  controller: _scrollController,
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
                        Navigator.pop(context,['Yeah',_dataListSearchDistrict[index].maQuan?.toString().trim(),_dataListSearchDistrict[index].tenQuan?.toString().trim()]);
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
                                              '${_dataListSearchDistrict[index].tenQuan?.toString().trim()}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '#${index + 1}',
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
                visible: state is GetListProvinceEmpty,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!! ',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
              Visibility(
                visible: state is SearchProvinceLoading,
                child: const PendingAction(),
              ),
            ]),
          )
        ],
      ),
    );
  }

  buildBodyCommune(BuildContext context,SearchProvinceState state){
    _dataListSearchCommune = _bloc.searchResultsCommune;
    int length = _dataListSearchCommune.length;
    if (state is GetListProvinceSuccess) {
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
                  controller: _scrollController,
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
                        Navigator.pop(context,['Yeah',_dataListSearchCommune[index].maPhuong?.toString().trim(),_dataListSearchCommune[index].tenPhuong?.toString().trim()]);
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
                                              '${_dataListSearchCommune[index].tenPhuong?.toString().trim()}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '#${index + 1}',
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
                visible: state is GetListProvinceEmpty,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!! ',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
              Visibility(
                visible: state is SearchProvinceLoading,
                child: const PendingAction(),
              ),
            ]),
          )
        ],
      ),
    );
  }

  buildBodyArea(BuildContext context,SearchProvinceState state){
    _dataListSearchArea = _bloc.searchResultsArea;
    int length = _dataListSearchArea.length;
    if (state is GetListProvinceSuccess) {
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
                  controller: _scrollController,
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
                        Navigator.pop(context,['Yeah',_dataListSearchArea[index].maKhuVuc?.toString().trim(),_dataListSearchArea[index].tenKhuVuc?.toString().trim()]);
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
                                              '${_dataListSearchArea[index].tenKhuVuc?.toString().trim()}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '#${index + 1}',
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
                visible: state is GetListProvinceEmpty,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!! ',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
              Visibility(
                visible: state is SearchProvinceLoading,
                child: const PendingAction(),
              ),
            ]),
          )
        ],
      ),
    );
  }

  buildBodyTypeStore(BuildContext context,SearchProvinceState state){
    _dataListSearchTypeStore = _bloc.searchResultsTypeStore;
    int length = _dataListSearchTypeStore.length;
    if (state is GetListProvinceSuccess) {
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
                  controller: _scrollController,
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
                        Navigator.pop(context,['Yeah',_dataListSearchTypeStore[index].maLoai?.toString().trim(),_dataListSearchTypeStore[index].tenLoai?.toString().trim()]);
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
                                              '${_dataListSearchTypeStore[index].tenLoai?.toString().trim()}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '#${index + 1}',
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
                visible: state is GetListProvinceEmpty,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!! ',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
              Visibility(
                visible: state is SearchProvinceLoading,
                child: const PendingAction(),
              ),
            ]),
          )
        ],
      ),
    );
  }

  buildBodyStoreForm(BuildContext context,SearchProvinceState state){
    _dataListSearchStoreForm = _bloc.searchResultsStoreForm;
    int length = _dataListSearchStoreForm.length;
    if (state is GetListProvinceSuccess) {
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
                  controller: _scrollController,
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
                        Navigator.pop(context,['Yeah',_dataListSearchStoreForm[index].maHinhThuc?.toString().trim(),_dataListSearchStoreForm[index].tenHinhThuc?.toString().trim()]);
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
                                              '${_dataListSearchStoreForm[index].tenHinhThuc?.toString().trim()}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '#${index + 1}',
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
                visible: state is GetListProvinceEmpty,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!! ',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
              Visibility(
                visible: state is SearchProvinceLoading,
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
                            //_bloc.add(GetListTourEvent(idTour:_searchController.text));
                          },
                          controller: _searchController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onChanged: (text) => onSearchDebounce.debounce(
                                () {
                              if(text != null){
                                if(widget.typeGetList == 0){
                                  if((widget.idProvince!.isEmpty && widget.idDistrict!.isEmpty)){
                                    _bloc.add(SearchProvincesEvent(keysText:_searchController.text,));
                                  }else if((widget.idProvince!.isNotEmpty && widget.idDistrict!.isEmpty)){
                                    _bloc.add(SearchDistrictEvent(keysText:_searchController.text,));
                                  }else{
                                    _bloc.add(SearchCommuneEvent(keysText:_searchController.text,));
                                  }
                                }
                                else{
                                  /// {i} like N'%Cửa%' and {i} like N'%Hàng%'
                                  /// {i} like N'%kmm%' and {i} like N'%kmmo%' and {i} like N'%ml%'
                                  ///
                                  if(widget.typeGetList == 1){
                                    if(_bloc.searchResultsArea.isNotEmpty){
                                      _bloc.searchResultsArea.clear();
                                    }
                                  }else if(widget.typeGetList == 2){
                                    if(_bloc.searchResultsStoreForm.isNotEmpty){
                                      _bloc.searchResultsStoreForm.clear();
                                    }
                                  }else if(widget.typeGetList == 3){
                                    if(_bloc.searchResultsTypeStore.isNotEmpty){
                                      _bloc.searchResultsTypeStore.clear();
                                    }
                                  }
                                  _bloc.add(GetListProvinceEvent(idArea: widget.idArea.toString(),idProvince: widget.idProvince,typeGetList: widget.typeGetList,idDistrict: widget.idDistrict,keysText: Utils.convertKeySearch(_searchController.text)));
                                  //_bloc.add(SearchTypeStoreEvent(keysText:_searchController.text,type: widget.typeGetList));
                                }
                              }
                            },
                          ),
                          decoration:const InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: transparent,
                              hintText:
                              "Tìm kiếm điều gì đó ...",
                              hintStyle: TextStyle(color: Colors.white),
                              contentPadding: EdgeInsets.only(
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
