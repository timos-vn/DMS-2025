// ignore_for_file: library_private_types_in_public_api

import 'package:dms/widget/custom_dropdown.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../model/network/response/search_list_item_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/images.dart';
import '../../../utils/utils.dart';
import '../product_detail/product_detail_screen.dart';
import '../component/search_product.dart';
import '../order/order_bloc.dart';
import '../order/order_event.dart';
import '../order/order_sate.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with TickerProviderStateMixin {
  late OrderBloc _orderBloc;
  final TextEditingController _searchController = TextEditingController();
  int countProduct = 0;
  String currencyCode = 'VND';
  String itemGroupCode = '';
  int codeGroupProduct = 1;
  String user='all';
  int selectedIndex=0;
  final TextEditingController _totalController = TextEditingController();
  TextEditingController inputNumber = TextEditingController();

  List<SearchItemResponseData> _list = [];
  int lastPage=0;
  int selectedPage=1;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _totalController.text = '0';
    _orderBloc = OrderBloc(context);
    _orderBloc.add(GetPrefs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<OrderBloc, OrderState>(
          bloc: _orderBloc,
          listener: (context, state) {
            if(state is GetPrefsSuccess){
              _orderBloc.add(GetCountProductEvent(true));
            }else if(state is GetCountProductSuccess){
              if(state.firstLoad == true){
                _orderBloc.add(GetListOderEvent(searchValues: itemGroupCode,codeCurrency: currencyCode, pageIndex: selectedPage,listCodeGroupProduct: _orderBloc.listGroupProductCode));
              }
            }
            else if (state is GetListOrderSuccess) {
              _list = _orderBloc.listItemOrder;
              _orderBloc.add(GetListGroupProductEvent());
            }else if(state is GetListGroupProductSuccess){
              _orderBloc.add(GetListItemGroupEvent(codeGroupProduct: codeGroupProduct));
            }
            else if(state is PickCurrencyNameSuccess){
              _orderBloc.listItemOrder.clear();
              _orderBloc.add(GetListOderEvent(searchValues: itemGroupCode,codeCurrency: state.codeCurrency,listCodeGroupProduct: _orderBloc.listGroupProductCode,isReLoad: true, pageIndex: selectedPage));
            }
            else if(state is PickupGroupProductSuccess){
              _orderBloc.add(GetListItemGroupEvent(codeGroupProduct: codeGroupProduct));
            }
          },
          child: BlocBuilder<OrderBloc, OrderState>(
            bloc: _orderBloc,
            builder: (BuildContext context, OrderState state) {
              return Stack(
                children: [
                  buildBody(context, state),
                  Visibility(
                    visible: state is EmptyDataState,
                    child:const Center(
                      child: Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                    ),
                  ),
                  Visibility(
                    visible: state is OrderLoading,
                    child:const PendingAction(),
                  ),
                ],
              );
            },
          )),
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
                          _orderBloc.add(GetListOderEvent(searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
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
                            _orderBloc.add(GetListOderEvent(searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
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
                                _orderBloc.add(GetListOderEvent(searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
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
                          itemCount: _orderBloc.totalPager > 10 ? 10 : _orderBloc.totalPager),
                    ),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          if(selectedPage < _orderBloc.totalPager){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage + 1;
                            });
                            _orderBloc.add(GetListOderEvent(searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
                          }
                        },
                        child: const Icon(Icons.navigate_next_outlined,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = _orderBloc.totalPager;
                          });
                          _orderBloc.add(GetListOderEvent(searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
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

  buildGroupProduct(){
    return _orderBloc.listGroupProduct.isEmpty == true
        ? const Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12))
        :
    PopupMenuButton(
      shape: const TooltipShape(),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Widget>>[
          PopupMenuItem<Widget>(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter myState){
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  height: 250,
                  child: Column(
                    children: [
                      Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 10),
                            itemCount: _orderBloc.listGroupProduct.length,
                            itemBuilder: (context, index) {
                              final trans = _orderBloc.listGroupProduct[index].groupName??'';
                              return ListTile(
                                minVerticalPadding: 1,
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        trans.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,overflow: TextOverflow.fade,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                      child: Transform.scale(
                                        scale: 1,
                                        alignment: Alignment.topLeft,
                                        child: Checkbox(
                                          value: _orderBloc.listGroupProduct[index].isChecked,
                                          onChanged: (b){
                                            if(_orderBloc.listGroupProduct[index].isChecked == true){
                                              _orderBloc.listGroupProduct[index].isChecked = !_orderBloc.listGroupProduct[index].isChecked!;
                                              _orderBloc.listGroupProductCode.remove(_orderBloc.listGroupProduct[index].groupCode.toString());
                                              Const.listGroupProductCode.remove(_orderBloc.listGroupProduct[index].groupCode.toString());
                                              switch (_orderBloc.listGroupProduct[index].groupCode){
                                                case '1':
                                                  _orderBloc.listItemGroupProductCode1 = '';
                                                  break;
                                                case '2':
                                                  _orderBloc.listItemGroupProductCode2 = '';
                                                  break;
                                                case '3':
                                                  _orderBloc.listItemGroupProductCode3 = '';
                                                  break;
                                                case "4":
                                                  _orderBloc.listItemGroupProductCode4 = '';
                                                  break;
                                                case '5':
                                                  _orderBloc.listItemGroupProductCode5 = '';
                                                  break;
                                              }
                                            }
                                            else{
                                              if(_orderBloc.listGroupProductCode.any((element) => element.toString().trim() == _orderBloc.listGroupProduct[index].groupCode.toString().trim()) == false){
                                                _orderBloc.listGroupProductCode.add(_orderBloc.listGroupProduct[index].groupCode.toString());
                                                Const.listGroupProductCode.add(_orderBloc.listGroupProduct[index].groupCode.toString());
                                              }
                                              _orderBloc.listGroupProduct[index].isChecked = !_orderBloc.listGroupProduct[index].isChecked!;
                                            }
                                            myState(() {});
                                            _orderBloc.add(PickGroupProduct(codeGroupProduct: int.parse(_orderBloc.listGroupProduct[index].groupCode.toString())));
                                            Navigator.pop(context);
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
                                  ],
                                ),
                                subtitle: const Divider(height: 1,),
                                onTap: () {
                                  if(_orderBloc.listGroupProduct[index].isChecked == true){
                                    _orderBloc.listGroupProduct[index].isChecked = !_orderBloc.listGroupProduct[index].isChecked!;
                                    _orderBloc.listGroupProductCode.remove(_orderBloc.listGroupProduct[index].groupCode.toString());
                                    Const.listGroupProductCode.remove(_orderBloc.listGroupProduct[index].groupCode.toString());
                                    switch (_orderBloc.listGroupProduct[index].groupCode){
                                      case '1':
                                        _orderBloc.listItemGroupProductCode1 = '';
                                        break;
                                      case '2':
                                        _orderBloc.listItemGroupProductCode2 = '';
                                        break;
                                      case '3':
                                        _orderBloc.listItemGroupProductCode3 = '';
                                        break;
                                      case "4":
                                        _orderBloc.listItemGroupProductCode4 = '';
                                        break;
                                      case '5':
                                        _orderBloc.listItemGroupProductCode5 = '';
                                        break;
                                    }
                                  }
                                  else{
                                    if(_orderBloc.listGroupProductCode.any((element) => element.toString().trim() == _orderBloc.listGroupProduct[index].groupCode.toString().trim()) == false){
                                      _orderBloc.listGroupProductCode.add(_orderBloc.listGroupProduct[index].groupCode.toString());
                                      Const.listGroupProductCode.add(_orderBloc.listGroupProduct[index].groupCode.toString());
                                    }
                                    _orderBloc.listGroupProduct[index].isChecked = !_orderBloc.listGroupProduct[index].isChecked!;
                                  }
                                  myState(() {});
                                  _orderBloc.add(PickGroupProduct(codeGroupProduct: int.parse(_orderBloc.listGroupProduct[index].groupCode.toString())));
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ];
      },
      child: Row(
        children: [
          Text('Loại nhóm: ${_orderBloc.listGroupProductCode.join(',').toString()}'),
          const SizedBox(width: 8,),
          Icon(
            MdiIcons.sortVariant,
            size: 15,
            color: black,
          ),
        ],
      ),
    );
  }

  buildCurrency(){
    return Const.currencyList.isEmpty
        ? const Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12))
        :
    PopupMenuButton(
      shape: const TooltipShape(),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Widget>>[
          PopupMenuItem<Widget>(
            child: Container(
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              height: 250,
              width: 200,
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10,),
                  itemCount: Const.currencyList.length,
                  itemBuilder: (context, index) {
                    final trans = Const.currencyList[index].currencyName;
                    return ListTile(
                      minVerticalPadding: 1,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              trans.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              maxLines: 1,overflow: TextOverflow.fade,
                            ),
                          ),
                          Text(
                            Const.currencyList[index].currencyCode.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      subtitle:const Divider(height: 1,),
                      onTap: () {
                        _orderBloc.add(PickCurrencyName(currencyCode: Const.currencyList[index].currencyCode.toString(),currencyName: Const.currencyList[index].currencyName.toString()));
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ];
      },
      child: Text(_orderBloc.currencyName.toString(),style: const TextStyle(color: subColor),),
    );
  }

  buildBody(BuildContext context,OrderState state){
    int length = _list.length;
    return Column(
      children: [
        buildAppBar(),
        const Divider(height: 1,),
        Expanded(
          child: Column(
            children: [
              _orderBloc.listItemGroupProduct.isEmpty ? Container() : Container(
                height: 135,
                width: double.infinity,
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.all(5),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 15,left: 15,bottom: 15,right: 8),
                        color: Colors.blueGrey[50],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text('Nhóm Sản phẩm', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                                height: 20,
                                child: buildGroupProduct())
                          ],
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Row(
                          children: [
                            InkWell(
                              onTap:(){
                                showModalBottomSheet(
                                    context: context,
                                    isDismissible: true,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
                                    ),
                                    backgroundColor: Colors.white,
                                    builder: (builder){
                                      return Container(
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(25),
                                                topLeft: Radius.circular(25)
                                            )
                                        ),
                                        margin: MediaQuery.of(context).viewInsets,
                                        child: FractionallySizedBox(
                                          heightFactor: 0.9,
                                          child: StatefulBuilder(
                                            builder: (BuildContext context,StateSetter myState){
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 10,bottom: 0),
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                          topRight: Radius.circular(25),
                                                          topLeft: Radius.circular(25)
                                                      )
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 8.0,left: 16,right: 16),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const Icon(Icons.check,color: Colors.white,),
                                                            const Text('Danh sách nhóm sản phẩm',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),),
                                                            InkWell(
                                                                onTap: ()=> Navigator.pop(context),
                                                                child: const Icon(Icons.close,color: Colors.black,)),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5,),
                                                      const Divider(color: Colors.blueGrey,),
                                                      const SizedBox(height: 5,),
                                                      Container(
                                                        width: double.infinity,
                                                        margin: const EdgeInsets.only(right: 20,left: 20),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(color: accent),
                                                            borderRadius:
                                                            const BorderRadius.all( Radius.circular(20))),
                                                        padding:
                                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                                                                  style: const TextStyle(fontSize: 14, color: accent),
                                                                  // onSubmitted: (text) {
                                                                  //   _bloc.add(SearchProduct(text,widget.idGroup, widget.selectedId));
                                                                  // },
                                                                  controller: _searchController,
                                                                  keyboardType: TextInputType.text,
                                                                  textInputAction: TextInputAction.done,
                                                                  onChanged: (text){
                                                                    _orderBloc.add(SearchItemGroupEvent(text));
                                                                    myState((){});
                                                                  },
                                                                  decoration: const InputDecoration(
                                                                      border: InputBorder.none,
                                                                      filled: true,
                                                                      fillColor: transparent,
                                                                      hintText: "Tìm kiếm nhóm sản phẩm",
                                                                      hintStyle: TextStyle(color: accent),
                                                                      contentPadding: EdgeInsets.only(
                                                                          bottom: 10, top: 10)
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Visibility(
                                                              visible: _searchController.text.length > 1,
                                                              child: InkWell(
                                                                  child: Icon(
                                                                    MdiIcons.close,
                                                                    color: accent,
                                                                    size: 20,
                                                                  ),
                                                                  onTap: () {
                                                                    myState(()=>_searchController.text = "");
                                                                  }),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: ListView.separated(
                                                            separatorBuilder: (BuildContext context, int index)=>const Padding(
                                                              padding: EdgeInsets.only(left: 16,right: 16,),
                                                              child: Divider(),
                                                            ),
                                                            padding: const EdgeInsets.only(top: 14,bottom: 50,),
                                                            scrollDirection: Axis.vertical,
                                                            shrinkWrap: true,
                                                            itemCount: _orderBloc.listItemReSearch.length,
                                                            itemBuilder: (context,index) =>
                                                                GestureDetector(
                                                                  onTap: ()=> Navigator.pop(context,[_orderBloc.listItemReSearch[index].groupCode,_orderBloc.listItemReSearch[index].groupName]),
                                                                  child: Container(
                                                                    decoration: const BoxDecoration(
                                                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                      // color: Colors.blueGrey,
                                                                    ),
                                                                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                                                    child: Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                const CircleAvatar(backgroundImage: NetworkImage(img),radius: 14,),
                                                                                const SizedBox(width: 10,),
                                                                                Text(_orderBloc.listItemReSearch[index].groupName??'',style:const TextStyle(color: Colors.black),),
                                                                              ],
                                                                            ),
                                                                            Text(_orderBloc.listItemReSearch[index].groupCode??'',style:const TextStyle(color: Colors.black),),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                ).then((value){
                                  if(value != null){
                                    _orderBloc.listItemOrder.clear();
                                    itemGroupCode = value[0];
                                    switch (codeGroupProduct){
                                      case 1:
                                        _orderBloc.listItemGroupProductCode1 = '';
                                        _orderBloc.listItemGroupProductCode1 = itemGroupCode;
                                        break;
                                      case 2:
                                        _orderBloc.listItemGroupProductCode2 = '';
                                        _orderBloc.listItemGroupProductCode2 = itemGroupCode;
                                        break;
                                      case 3:
                                        _orderBloc.listItemGroupProductCode3 = '';
                                        _orderBloc.listItemGroupProductCode3 = itemGroupCode;
                                        break;
                                      case 4:
                                        _orderBloc.listItemGroupProductCode4 = '';
                                        _orderBloc.listItemGroupProductCode4 = itemGroupCode;
                                        break;
                                      case 5:
                                        _orderBloc.listItemGroupProductCode5 = '';
                                        _orderBloc.listItemGroupProductCode5 = itemGroupCode;
                                        break;
                                    }
                                    _orderBloc.add(GetListOderEvent(searchValues: '',codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage ));
                                  }
                                });
                              },
                              child: const SizedBox(
                                width: 45,
                                child: Icon(Icons.search_outlined,color: subColor,),
                              ),
                            ),
                            Flexible(
                              child: ListView.builder(
                                  padding: const EdgeInsets.only(top: 14,bottom: 14,),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: _orderBloc.listItemGroupProduct.length < 10 ? _orderBloc.listItemGroupProduct.length : 10,
                                  itemBuilder: (context,index) =>
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: GestureDetector(
                                          onTap: (){
                                            itemGroupCode = _orderBloc.listItemGroupProduct[index].groupCode!;
                                            selectedIndex = index;
                                            _orderBloc.listItemOrder.clear();
                                            switch (codeGroupProduct){
                                              case 1:
                                                _orderBloc.listItemGroupProductCode1 = '';
                                                _orderBloc.listItemGroupProductCode1 = itemGroupCode;
                                                break;
                                              case 2:
                                                _orderBloc.listItemGroupProductCode2 = '';
                                                _orderBloc.listItemGroupProductCode2 = itemGroupCode;
                                                break;
                                              case 3:
                                                _orderBloc.listItemGroupProductCode3 = '';
                                                _orderBloc.listItemGroupProductCode3 = itemGroupCode;
                                                break;
                                              case 4:
                                                _orderBloc.listItemGroupProductCode4 = '';
                                                _orderBloc.listItemGroupProductCode4 = itemGroupCode;
                                                break;
                                              case 5:
                                                _orderBloc.listItemGroupProductCode5 = '';
                                                _orderBloc.listItemGroupProductCode5 = itemGroupCode;
                                                break;
                                            }
                                            _orderBloc.add(GetListOderEvent(searchValues: '',codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage ));
                                          },
                                          child: Container(
                                            height: 10,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                                              color: selectedIndex == index ? subColor : Colors.blueGrey,
                                            ),
                                            padding: const EdgeInsets.only(right: 14,left: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const CircleAvatar(backgroundImage: NetworkImage(img),radius: 14,),
                                                const SizedBox(width: 5,),
                                                Text(_orderBloc.listItemGroupProduct[index].groupName??'',style: const TextStyle(color: Colors.white),),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1,color: Colors.blue.withOpacity(0.7),),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 16, top: 12, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh sách sản phẩm',
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),
                      ),
                    ),
                    buildCurrency()
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index){
                      return GestureDetector(
                          onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProductDetailScreen(itemCode: _list[index].code,currency:  currencyCode ,))),
                          child: Card(
                            semanticContainer: true,
                            margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: _list[index].kColorFormatAlphaB,
                                        borderRadius:const BorderRadius.all( Radius.circular(6),)
                                    ),
                                    child: Center(child: Text('${_list[index].name?.substring(0,1).toUpperCase()}',style:const TextStyle(color: Colors.white),),),
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
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${_list[index].name}',
                                                  textAlign: TextAlign.left,
                                                  style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 10,),
                                              Column(
                                                children: [
                                                  Text(
                                                    (currencyCode == "VND"
                                                        ?
                                                    NumberFormat(Const.amountFormat).format(_list[index].price??0)
                                                        :
                                                    NumberFormat(Const.amountNtFormat).format(_list[index].price??0))
                                                        == '0' ? 'Giá đang cập nhật' : (currencyCode == "VND"
                                                        ?
                                                    NumberFormat(Const.amountFormat).format(_list[index].price??0)
                                                        :
                                                    NumberFormat(Const.amountNtFormat).format(_list[index].price??0))
                                                    ,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(color: grey, fontSize: 10, decoration: (currencyCode == "VND"
                                                        ?
                                                    NumberFormat(Const.amountFormat).format(_list[index].price??0)
                                                        :
                                                    NumberFormat(Const.amountNtFormat).format(_list[index].price??0)) == '0' ? TextDecoration.none : TextDecoration.lineThrough),
                                                  ),
                                                  const SizedBox(height: 3,),
                                                  Visibility(
                                                    visible: _list[index].price! > 0,
                                                    child: Text(
                                                      currencyCode == "VND"
                                                          ?
                                                      NumberFormat(Const.amountFormat).format(_list[index].priceAfter??0)
                                                          :
                                                      NumberFormat(Const.amountNtFormat).format(_list[index].priceAfter??0),
                                                      textAlign: TextAlign.left,
                                                      style:const TextStyle(color: Color(
                                                          0xff067902), fontSize: 13,fontWeight: FontWeight.w700),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Mã SP:',
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10.5,color:  Color(
                                                            0xff358032)),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(width: 3,),
                                                      Text(
                                                        '${_list[index].code}',
                                                        textAlign: TextAlign.left,
                                                        style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 10.5,color:  Color(
                                                            0xff358032)),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 8,),
                                                  Visibility(
                                                    visible: _list[index].discountPercent! > 0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(color: Colors.red,width: 0.7)
                                                      ),
                                                      padding:const EdgeInsets.symmetric(horizontal: 7,vertical: 1),
                                                      child: Row(
                                                        children: [
                                                          const Text(
                                                            'SALE OFF',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10.5,color:  Color(
                                                                0xffe80000)),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(width: 3,),
                                                          Text(
                                                            '${Utils.formatNumber(_list[index].discountPercent!)}%',
                                                            textAlign: TextAlign.left,
                                                            style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 10.5,color:  Color(
                                                                0xffe80000)),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Tồn kho:',
                                                    style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text("${_list[index].stockAmount?.toInt()??0}",
                                                    style:const TextStyle(color: blue, fontSize: 12),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
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
                          )
                      );
                    }
                ),
              ),
              _orderBloc.totalPager > 0 ? _getDataPager() : Container(),
              const SizedBox(height: 5,),
            ],
          ),
        )
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
                offset:const Offset(2, 4),
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
            onTap: ()=> Navigator.pop(context),
            child: Container(
              padding:const EdgeInsets.only(bottom: 10),
              //width: 40,
              height: 50,
              child:const Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: GestureDetector(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProductScreen(
                    idCustomer: '', /// Chỉ có thêm tồn kho ở check-in mới thêm idCustomer
                    currency: currencyCode ,
                    viewUpdateOrder: false,
                    listIdGroupProduct: _orderBloc.listGroupProductCode,
                    itemGroupCode: itemGroupCode,
                    inventoryControl: false,
                    addProductFromCheckIn: false,
                    addProductFromSaleOut: false,
                    giftProductRe: false,
                    lockInputToCart: false,checkStockEmployee: Const.checkStockEmployee,
                    listOrder: const [], backValues: false, isCheckStock: false),withNavBar: false).then((value){
                  _orderBloc.add(GetCountProductEvent(false));
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(borderRadius:const BorderRadius.all( Radius.circular(16)), border: Border.all(width: 1, color: white)),
                child: const Row(
                  children:[
                    Icon(
                      Icons.search,
                      size: 18,
                      color: white,
                    ),
                    Expanded(
                        child: Text(
                          'Tìm kiếm sản phẩm',
                          style: TextStyle(color: white,fontSize: 14,fontStyle: FontStyle.normal),
                        )),
                    Icon(
                      Icons.cancel,
                      size: 18,
                      color: white,
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 5,),
        ],
      ),
    );
  }

}