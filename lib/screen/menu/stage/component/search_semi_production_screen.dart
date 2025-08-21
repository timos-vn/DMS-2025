// ignore_for_file: unnecessary_null_comparison, unrelated_type_equality_checks

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:dms/widget/custom_confirm.dart';
import 'package:dms/widget/custom_update_quantity_materials.dart';
import 'package:dms/widget/input_quantity_shipping_popup.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:collection/collection.dart';
import '../../../../model/network/response/get_item_materials_response.dart';
import '../../../../model/network/response/request_section_route_item_response.dart';
import '../../../../model/network/response/semi_product_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/debouncer.dart';
import '../../../../utils/utils.dart';
import '../stage_statistic/stage_statistic_bloc.dart';
import '../stage_statistic/stage_statistic_event.dart';
import '../stage_statistic/stage_statistic_state.dart';


class SearchSemiProductionScreen extends StatefulWidget {
  final String? lsx;
  final String? section;
  final String? request;
  final String? route;
  final int typeView;
  final bool? typeRequest;
  final bool? addToMaterials;
  final bool? addToWaste;
  const SearchSemiProductionScreen({Key? key,this.addToWaste,this.lsx,this.section, required this.typeView,this.request, this.route, this.typeRequest, this.addToMaterials}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchSemiProductionScreenState();
  }
}

class SearchSemiProductionScreenState extends State<SearchSemiProductionScreen> {

  late StageStatisticBloc _bloc;

  final focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;


  final Debounce onSearchDebounce =  Debounce(delay:  const Duration(milliseconds: 1000));

  List<SemiProductionResponseData> _dataListSearch = [];
  List<RequestSectionRouteItemResponseData> _listRequestSectionAndRouteItem = [];

  late SemiProductionResponseData itemSelect;
  late int indexSelect;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = StageStatisticBloc(context);
    _bloc.add(GetPrefs());

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        if(widget.typeView == 1){
          _bloc.add(SearchSemiProduction(
            isLoadMore: true,
            lsx: widget.lsx.toString(), section: widget.section.toString(), searchText: Utils.convertKeySearch(_searchController.text), isRefresh: false,));
        }
        else{
          _bloc.add(GetListRequestSectionItemEvent(
            isLoadMore: true,
            request: widget.request.toString(), route: widget.route.toString(), isRefresh: false,));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus( FocusNode());
      },
      child: BlocListener<StageStatisticBloc,StageStatisticState>(
          bloc: _bloc,
          listener: (context, state) {
            if(state is GetPrefsSuccess){
              if(widget.typeView == 1){
                _bloc.reset();
                _bloc.add(SearchSemiProduction(
                  isLoadMore: false,
                  lsx: widget.lsx.toString(),
                  section: widget.section.toString(),
                  searchText: Utils.convertKeySearch(_searchController.text),
                  isRefresh: false,));
              }
              else{
                _bloc.reset();
                _bloc.add(GetListRequestSectionItemEvent(
                  isLoadMore: false,
                  request: widget.request.toString(), route: widget.route.toString(), isRefresh: false,));
              }
            }
            else if (state is StageStatisticFailure) {
              Utils.showCustomToast(context, Icons.warning_amber_outlined, state.toString());
            }
            else if (state is RequiredText) {
              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vui lòng nhập kí tự cần tìm kiếm');
            }
          },
          child: BlocBuilder<StageStatisticBloc,StageStatisticState>(
              bloc: _bloc,
              builder: (BuildContext context, StageStatisticState state) {
                return Scaffold(
                  backgroundColor: white,
                  body: Stack(
                    children: [
                      widget.typeView == 1 ? buildBody(context, state) :  buildRequestSectionAndRoute(context, state),
                      Visibility(
                        visible: state is EmptySearchSemiProductionState,
                        child: const Center(
                          child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                        ),
                      ),
                      Visibility(
                        visible: state is StageStatisticLoading,
                        child: const PendingAction(),
                      ),
                    ],
                  ),
                );
              })),
    );
  }


  buildBody(BuildContext context,StageStatisticState state){
    _dataListSearch = _bloc.searchResults;
    int length = _dataListSearch.length;
    if (state is SearchSemiProductionSuccess) {
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
                        itemSelect = _dataListSearch[index];
                        indexSelect = index;
                        if(widget.addToMaterials == true){
                          showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) {
                                return const UpdateQuantityMaterials();
                              }).then((value){
                            if(value != null){
                              GetItemMaterialsResponseData itemVl = GetItemMaterialsResponseData(
                                  maVt: _dataListSearch[index].maVt,
                                  tenVt: _dataListSearch[index].tenVt,
                                  soLuong: _dataListSearch[index].soLuong,
                                  dvt: _dataListSearch[index].dvt,
                                  ngayCt1: '',
                                  soLuongTiepNhan: double.parse(value[0]??'0'),
                                  soLuongSuDung: double.parse(value[1]??'0'),
                                  soLuongConLai: (double.parse(value[0]??'0') - double.parse(value[1]??'0'))
                              );

                              if(DataLocal.listGetItemMaterialsResponse.isEmpty){
                                DataLocal.listGetItemMaterialsResponse.add(itemVl);
                              }
                              else{
                                int indexCheck = -1;
                                for(int i = 0; i < DataLocal.listGetItemMaterialsResponse.length; i++){
                                  if(DataLocal.listGetItemMaterialsResponse[i].maVt.toString().trim() == itemVl.maVt.toString().trim()){
                                    indexCheck = i;
                                    itemVl.maVtSemi = DataLocal.listGetItemMaterialsResponse[i].maVtSemi;
                                    itemVl.soLuongBanDau = DataLocal.listGetItemMaterialsResponse[i].soLuongBanDau;
                                    itemVl.soLuong = DataLocal.listGetItemMaterialsResponse[i].soLuong;
                                  }
                                }
                                if(indexCheck >= 0){
                                  DataLocal.listGetItemMaterialsResponse.removeAt(indexCheck);
                                  DataLocal.listGetItemMaterialsResponse.insert(indexCheck,itemVl);
                                }else{
                                  DataLocal.listGetItemMaterialsResponse.add(itemVl);
                                }
                              }
                              Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm vào danh sách NPL thành công');
                            }
                          });
                        }
                        else{
                          if(widget.addToWaste == true){
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) {
                                  return InputQuantityShipping(
                                    title: _dataListSearch[index].tenVt.toString().trim(),
                                    desc: 'Vui lòng nhập số lượng',);
                                }).then((quantity){
                              if(quantity != null){
                                SemiProductionResponseData item = _dataListSearch[index];
                                item.soLuong = double.parse(quantity[0].toString().isNotEmpty == true ? quantity[0].toString() : '0');
                                int indexCheck = -1;
                                for(int i = 0; i < DataLocal.listWaste.length; i++){
                                  if(DataLocal.listWaste[i].maVt.toString().trim() == itemSelect.maVt.toString().trim()){
                                    indexCheck = i;
                                  }
                                }
                                if(indexCheck >= 0){
                                  DataLocal.listWaste.removeAt(indexCheck);
                                  DataLocal.listWaste.insert(indexCheck,item);
                                }else{
                                  DataLocal.listWaste.add(item);
                                }

                                Utils.showCustomToast(context, EneftyIcons.check_outline, 'Cập nhật thành công');
                              }
                            });
                          }
                          else{
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) {
                                  return const CustomConfirm(title: 'Thêm mới BTP',content: 'Thêm mới bán thành phẩm', type: 1,expireDate: false);
                                }).then((quantity){
                              if(quantity != null){
                                itemSelect = _dataListSearch[index];
                                indexSelect = index;
                                if(DataLocal.listSemiProduction.isEmpty){
                                  DataLocal.listSemiProduction.add(itemSelect);
                                }
                                else{
                                  int indexCheck = -1;
                                  for(int i = 0; i < DataLocal.listSemiProduction.length; i++){
                                    if(DataLocal.listSemiProduction[i].maVt.toString().trim() == itemSelect.maVt.toString().trim()){
                                      indexCheck = i;
                                    }
                                  }
                                  if(indexCheck >= 0){
                                    // DataLocal.listSemiProduction.removeAt(indexCheck);
                                    Utils.showCustomToast(context, Icons.warning_amber, 'Sản phẩm này đã tồn tại trong giỏ, vui lòng xoá trước khi thêm mới');
                                  }else{
                                    DataLocal.listSemiProduction.add(itemSelect);
                                  }
                                }
                                Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm vào danh sách Bán thành phẩm thành công');
                              }
                            });
                          }
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
                              const SizedBox(width: 10,),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10,right: 6,bottom: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '[${_dataListSearch[index].maVt.toString().trim()}] ${_dataListSearch[index].tenVt.toString().toUpperCase()}',
                                        style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                        maxLines: 2,overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5,),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 6,bottom: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Icon(EneftyIcons.receipt_edit_outline,color: Colors.grey,size: 15,),
                                            const SizedBox(width: 5,),
                                            Expanded(
                                              child: Text("Đơn vị tính: ${_dataListSearch[index].dvt??'Chưa cập nhật đơn vị tính'}",
                                                textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: length
              ),
            ]),
          )
        ],
      ),
    );
  }

  buildRequestSectionAndRoute(BuildContext context,StageStatisticState state){
    _listRequestSectionAndRouteItem = _bloc.listRequestSectionAndRouteItem;
    int length = _listRequestSectionAndRouteItem.length;
    if (state is GetListRequestSectionAndRouteItemSuccess) {
      _hasReachedMax = length < _bloc.currentPage * 20;
    } else {
      _hasReachedMax = false;
    }
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBarRequestSectionAndRoute(),
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
                        if(widget.typeRequest == true){
                          Navigator.pop(
                              context,
                              [_listRequestSectionAndRouteItem[index].maLsx.toString().trim(),
                                _listRequestSectionAndRouteItem[index].tenLsx.toString().trim(),
                                _listRequestSectionAndRouteItem[index].maLoTrinh.toString().trim(),
                              ]);
                        }else{
                          Navigator.pop(context,[_listRequestSectionAndRouteItem[index].maCd.toString().trim(),_listRequestSectionAndRouteItem[index].tenCd.toString().trim(),]);
                        }
                      },
                      child: Card(
                        semanticContainer: true,
                        margin: const EdgeInsets.only(left: 10,right: 0,top: 5,bottom: 5),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8,right: 8,top: 10,bottom: 10),
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
                              const SizedBox(width: 10,),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10,right: 6,bottom: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      widget.typeRequest == true ?
                                      Text(
                                        '[${_listRequestSectionAndRouteItem[index].maLsx.toString().trim()}] ${_listRequestSectionAndRouteItem[index].tenLsx.toString().toUpperCase()}',
                                        style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                        maxLines: 2,overflow: TextOverflow.ellipsis,
                                      )
                                          :
                                      Text(
                                        '[${_listRequestSectionAndRouteItem[index].maCd.toString().trim()}] ${_listRequestSectionAndRouteItem[index].tenCd.toString().toUpperCase()}',
                                        style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                        maxLines: 2,overflow: TextOverflow.ellipsis,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 0,bottom: 5,top: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Icon(EneftyIcons.calendar_3_outline,color: Colors.grey,size: 15,),
                                            const SizedBox(width: 5,),
                                            Expanded(
                                              child: Text(_listRequestSectionAndRouteItem[index].ngayCt??'Chưa cập nhật đơn vị tính',
                                                textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text('Mã Lộ Trình: ${_listRequestSectionAndRouteItem[index].maLoTrinh??'Chưa cập nhật đơn vị tính'}',
                                              textAlign: TextAlign.right, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: length
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
              FocusScope.of(context).unfocus();
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
                            //_bloc.add(SearchProduct(Utils.convertKeySearch(_searchController.text),widget.idGroup!.toInt(), widget.itemGroupCode.toString(),widget.idCustomer.toString()));
                          },
                          controller: _searchController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,

                          onChanged: (text) {
                            onSearchDebounce.debounce(
                                  () {
                                if(text.isNotEmpty){
                                  _bloc.add(SearchSemiProduction(
                                    isLoadMore: false,
                                    lsx: widget.lsx.toString(), section: widget.section.toString(), searchText: Utils.convertKeySearch(_searchController.text), isRefresh: true,));
                                }
                              },
                            );
                            _bloc.add(CheckShowCloseEvent(text));
                          },
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: transparent,
                              hintText: "Tìm kiếm sản phẩm",
                              hintStyle: TextStyle(color: Colors.white),
                              contentPadding: EdgeInsets.only(
                                  bottom: 10, top: 16.5)
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _bloc.isShowCancelButton,
                      child: InkWell(
                          child: Padding(
                            padding: EdgeInsets.only(left: 0,top:0,right: 8,bottom: 0),
                            child: Icon(
                              MdiIcons.close,
                              color: Colors.white,
                              size: 18,
                            ),
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

  buildAppBarRequestSectionAndRoute(){
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
            onTap: (){
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
              } ,
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
                widget.typeRequest == true ? "Lệnh sản xuất" : "Công đoạn",
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.event,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bloc.reset();
    super.dispose();
  }
}
