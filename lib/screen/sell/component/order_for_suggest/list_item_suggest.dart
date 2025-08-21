// ignore_for_file: unnecessary_null_comparison, unrelated_type_equality_checks

import 'package:dms/screen/sell/sell_bloc.dart';
import 'package:dms/screen/sell/sell_state.dart';
import 'package:dms/screen/sell/sell_event.dart';
import 'package:dms/widget/input_quantity_popup_order.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../model/database/data_local.dart';
import '../../../../model/network/response/list_item_suggest_response.dart';
import '../../../../model/network/response/search_list_item_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/debouncer.dart';
import '../../../../utils/utils.dart';




class SearchProductSuggestScreen extends StatefulWidget {
final bool isSuggest ;
  const SearchProductSuggestScreen({Key? key, required this.isSuggest}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchProductSuggestScreenState();
  }
}

class SearchProductSuggestScreenState extends State<SearchProductSuggestScreen> {

  late SellBloc _bloc;

  final focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  final Debounce onSearchDebounce =  Debounce(delay:  const Duration(milliseconds: 1000));

  List<ListItemSuggestResponseData> _dataListSearch = [];
  List<SearchItemResponseData> _dataListSearch2 = [];

  late ListItemSuggestResponseData itemSelect;
  late int indexSelect;
  late SearchItemResponseData itemSelect2;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SellBloc(context);
    if(widget.isSuggest == true){
      print(widget.isSuggest);
      _bloc.add(SearchListProductSuggestEvent(Utils.convertKeySearch(_searchController.text)));
    }else{
      print(widget.isSuggest);
      _bloc.add(SearchListProductNoSuggestEvent(Utils.convertKeySearch(_searchController.text)));
    }

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        if(widget.isSuggest){
          _bloc.add(SearchListProductSuggestEvent(Utils.convertKeySearch(
              _searchController.text),
            isLoadMore: true,
          ));
        }else {
          if (widget.isSuggest) {
            _bloc.add(SearchListProductNoSuggestEvent(Utils.convertKeySearch(
                _searchController.text),
              isLoadMore: true,
            ));
          }
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
        child: BlocListener<SellBloc,SellState>(
            bloc: _bloc,
            listener: (context, state) {
              if(state is GetListSuggestSuccess){
                _dataListSearch = _bloc.listSuggest;
              }
              if(state is SearchProductSuccess){
                _dataListSearch2 = _bloc.searchResults;
              }
              if(state is GetListStockEventSuccess){
                if(widget.isSuggest == true){
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return InputQuantityPopupOrder(
                          title: 'Thêm vào giỏ',
                          inventoryStore: true,
                          quantity: 0,
                          quantityStock: 0,
                          findStock: true,
                          listStock: _bloc.listStockResponse,
                          listDvt: itemSelect.allowDvt == true ? itemSelect.contentDvt!.split(',').toList() : [],
                          allowDvt: itemSelect.allowDvt,
                          nameProduction: itemSelect.tenVt.toString(),
                          price: 0,listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh,
                          codeProduction: itemSelect.maVt.toString(),
                          listObjectJson: '', nuocsx: '', quycach: '',
                        );
                      }).then((value){
                    if(value != null){
                      if(double.parse(value[0].toString()) > 0){
                        setState(() {
                          if(DataLocal.listSuggestSave.any((element) => element.maVt.toString().trim().replaceAll('null', '') == itemSelect.maVt.toString().trim().replaceAll('null', ''))){
                            DataLocal.listSuggestSave.removeWhere((element) => element.maVt.toString().trim() ==  itemSelect.maVt.toString().trim());
                          }
                          _bloc.listSuggest[indexSelect].isChecked = true;
                          ListItemSuggestResponseData item  = ListItemSuggestResponseData(
                            qty: value[0],
                            maKho: value[2].toString(),
                            tenKho: value[3].toString(),
                            maVt: _bloc.listSuggest[indexSelect].maVt.toString().trim(),
                            tenVt: _bloc.listSuggest[indexSelect].tenVt.toString().trim(),
                            dvt: _bloc.listSuggest[indexSelect].dvt.toString().trim(),
                            chiTieu: _bloc.listSuggest[indexSelect].chiTieu.toString().trim(),
                          );
                          DataLocal.listSuggestSave.add(item);
                        });
                      }
                    }
                  });
                }else{
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return InputQuantityPopupOrder(
                          title: 'Thêm vào giỏ',
                          inventoryStore: true,
                          quantity: 0,
                          quantityStock: 0,
                          findStock: true,
                          listStock: _bloc.listStockResponse,
                          listDvt: itemSelect2.allowDvt == true ? itemSelect2.contentDvt!.split(',').toList() : [],
                          allowDvt: itemSelect2.allowDvt,
                          nameProduction: itemSelect2.name.toString(),
                          price: 0,
                          codeProduction: itemSelect2.code.toString(),
                          listObjectJson: '', listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh, nuocsx: '', quycach: '',
                        );
                      }).then((value){
                    if(value != null){
                      if(double.parse(value[0].toString()) > 0){
                        setState(() {
                          if(DataLocal.listSuggestSave.any((element) => element.maVt.toString().trim().replaceAll('null', '') == itemSelect2.code.toString().trim().replaceAll('null', ''))){
                            DataLocal.listSuggestSave.removeWhere((element) => element.maVt.toString().trim() ==  itemSelect2.code.toString().trim());
                          }
                          _bloc.searchResults[indexSelect].isChecked = true;
                          ListItemSuggestResponseData item  = ListItemSuggestResponseData(
                            qty: value[0],
                            maKho: value[2].toString(),
                            tenKho: value[3].toString(),
                            maVt: _bloc.searchResults[indexSelect].code.toString().trim(),
                            tenVt: _bloc.searchResults[indexSelect].name.toString().trim(),
                            dvt: _bloc.searchResults[indexSelect].dvt.toString().trim(),
                            chiTieu: '',
                          );
                          DataLocal.listSuggestSave.add(item);
                        });
                      }
                    }
                  });
                }
              }
            },
            child: BlocBuilder<SellBloc,SellState>(
                bloc: _bloc,
                builder: (BuildContext context, SellState state) {
                  return Stack(
                    children: [
                      buildBody(context, state),
                      Visibility(
                        visible: state is SellLoading,
                        child: const PendingAction(),
                      ),
                    ],
                  );
                })),
      ),
    );
  }


  buildBody(BuildContext context,SellState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child:  Column(
        children: [
          buildAppBar(),
          Expanded(
            child: widget.isSuggest == true ? buildListSuggest() : buildListNoSuggest()
          ),
          GestureDetector(
            onTap: (){
              // if(widget.chooseOneItemPart == true){
              //   if(itemSelected.isChecked == true){
              //     Navigator.pop(context,[itemSelected.name.toString().trim(),itemSelected.id.toString().trim()]);
              //   }else{
              //     Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng chọn part');
              //   }
              // }else{
                Navigator.pop(context);
              // }
            },
            child: Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: grey,width: 1)
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Chọn',style: TextStyle(color: Colors.black),)
                  ],
                )
            ),
          ),
        ],
      )
    );
  }

  buildListSuggest(){
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index)=>const Padding(
          padding: EdgeInsets.only(left: 8,right: 8,),
          child: Divider(color: Colors.grey,),
        ),
        padding: const EdgeInsets.only(top: 14,bottom: 50,),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _dataListSearch.length,
        itemBuilder: (context,index) {
          if(DataLocal.listSuggestSave.isNotEmpty){
            for (var element in DataLocal.listSuggestSave) {
              for (var item in _dataListSearch) {
                if(element.maVt.toString().trim() == item.maVt.toString().trim()){
                  item.isChecked = true;
                  item.qty = element.qty;
                  item.dvt = element.dvt.toString().trim().replaceAll('null', '');
                }
              }
            }
          }
          return GestureDetector(
            onTap: (){
              if(_dataListSearch[index].isChecked == false){
                itemSelect = _dataListSearch[index];
                indexSelect = index;
                _bloc.add(GetListStockEvent(
                  itemCode: _dataListSearch[index].maVt.toString(),
                  checkStockEmployee: true,
                ));
              }else{
                int indexItem = DataLocal.listSuggestSave.indexWhere((element)=> element.maVt.toString().trim() == _dataListSearch[index].maVt.toString().trim() );
                DataLocal.listSuggestSave.remove(DataLocal.listSuggestSave[indexItem]);
                _dataListSearch[index].isChecked = false;
                setState(() {});
              }
            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                // color: Colors.blueGrey,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              height: 10,
                              child: Transform.scale(
                                scale: 1,
                                alignment: Alignment.topLeft,
                                child: Checkbox(
                                  value: _dataListSearch[index].isChecked,
                                  onChanged: (b){
                                    setState(() {
                                      if(_bloc.listSuggest[index].isChecked == true){
                                        _bloc.listSuggest[index].isChecked = !_bloc.listSuggest[index].isChecked!;
                                        DataLocal.listSuggestSave.removeWhere((element) => element.maVt.toString().trim() ==  _bloc.listSuggest[index].maVt.toString().trim());
                                      }
                                      else{
                                        itemSelect = _dataListSearch[index];
                                        indexSelect = index;
                                        _bloc.add(GetListStockEvent(
                                          itemCode: _dataListSearch[index].maVt.toString(),
                                          checkStockEmployee: true,
                                        ));
                                      }
                                    });
                                  },
                                  activeColor: mainColor,
                                  hoverColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  side: MaterialStateBorderSide.resolveWith((states){
                                    if(states.contains(MaterialState.pressed)){
                                      return BorderSide(color: mainColor);
                                    }else{
                                      return BorderSide(color: mainColor);
                                    }
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(child: Text('[${_dataListSearch[index].maVt.toString().trim().replaceAll('null', '')??''}]${_dataListSearch[index].tenVt.toString().trim().replaceAll('null', '')??''}',style:const TextStyle(color: Colors.black),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Text('${
                          _dataListSearch[index].qty.toString().trim().replaceAll('null', '').isNotEmpty ?
                          _dataListSearch[index].qty.toString().trim().replaceAll('null', '')
                              : '0'
                      } ${_dataListSearch[index].dvt.toString().trim()}',style:const TextStyle(color: Colors.black),),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  buildListNoSuggest(){
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index)=>const Padding(
          padding: EdgeInsets.only(left: 8,right: 8,),
          child: Divider(color: Colors.grey,),
        ),
        padding: const EdgeInsets.only(top: 14,bottom: 50,),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _dataListSearch2.length,
        itemBuilder: (context,index) {
          if(DataLocal.listSuggestSave.isNotEmpty){
            for (var element in DataLocal.listSuggestSave) {
              for (var item in _dataListSearch2) {
                if(element.maVt.toString().trim() == item.code.toString().trim()){
                  item.isChecked = true;
                  item.count = element.qty;
                  item.dvt = element.dvt.toString().trim().replaceAll('null', '');
                }
              }
            }
          }
          return GestureDetector(
            onTap: (){
              if(_dataListSearch2[index].isChecked == false){
                itemSelect2 = _dataListSearch2[index];
                indexSelect = index;
                _bloc.add(GetListStockEvent(
                  itemCode: _dataListSearch2[index].code.toString(),
                  checkStockEmployee: true,
                ));
              }else{
                int indexItem = DataLocal.listSuggestSave.indexWhere((element)=> element.maVt.toString().trim() == _dataListSearch2[index].code.toString().trim() );
                DataLocal.listSuggestSave.remove(DataLocal.listSuggestSave[indexItem]);
                _dataListSearch2[index].isChecked = false;
                setState(() {});
              }
            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                // color: Colors.blueGrey,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              height: 10,
                              child: Transform.scale(
                                scale: 1,
                                alignment: Alignment.topLeft,
                                child: Checkbox(
                                  value: _dataListSearch2[index].isChecked,
                                  onChanged: (b){
                                    setState(() {
                                      if(_bloc.listSuggest[index].isChecked == true){
                                        _bloc.listSuggest[index].isChecked = !_bloc.listSuggest[index].isChecked!;
                                        DataLocal.listSuggestSave.removeWhere((element) => element.maVt.toString().trim() ==  _bloc.listSuggest[index].maVt.toString().trim());
                                      }
                                      else{
                                        itemSelect2 = _dataListSearch2[index];
                                        indexSelect = index;
                                        _bloc.add(GetListStockEvent(
                                          itemCode: _dataListSearch2[index].code.toString(),
                                          checkStockEmployee: true,
                                        ));
                                      }
                                    });
                                  },
                                  activeColor: mainColor,
                                  hoverColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  side: MaterialStateBorderSide.resolveWith((states){
                                    if(states.contains(MaterialState.pressed)){
                                      return BorderSide(color: mainColor);
                                    }else{
                                      return BorderSide(color: mainColor);
                                    }
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12,),
                            Expanded(child: Text('[${_dataListSearch2[index].code.toString().trim().replaceAll('null', '')??''}]${_dataListSearch2[index].name.toString().trim().replaceAll('null', '')??''}',style:const TextStyle(color: Colors.black,),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Text('${
                          _dataListSearch2[index].count.toString().trim().replaceAll('null', '').isNotEmpty ?
                          _dataListSearch2[index].count.toString().trim().replaceAll('null', '')
                              : '0'
                      } ${_dataListSearch2[index].dvt.toString().trim()}',style:const TextStyle(color: Colors.black),),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
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
                            //_bloc.add(SearchProduct(Utils.convertKeySearch(_searchController.text),widget.idGroup!.toInt(), widget.itemGroupCode.toString(),widget.idCustomer.toString()));
                          },
                          controller: _searchController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,

                          onChanged: (text) {
                            onSearchDebounce.debounce(
                                  () {
                                    if(widget.isSuggest){
                                      _bloc.add(SearchListProductSuggestEvent(Utils.convertKeySearch(_searchController.text)));
                                    }else {
                                      _bloc.add(SearchListProductNoSuggestEvent(Utils.convertKeySearch(_searchController.text)));
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

  @override
  void dispose() {
    // TODO: implement dispose
    // _bloc.reset();
    super.dispose();
  }
}
