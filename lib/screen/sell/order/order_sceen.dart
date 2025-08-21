// ignore_for_file: library_private_types_in_public_api

import 'package:dms/model/entity/entity.dart';
import 'package:dms/widget/custom_dropdown.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/input_quantity_popup_order.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../model/entity/product.dart';
import '../../../model/network/response/search_list_item_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/images.dart';
import '../../../utils/utils.dart';
import '../cart/cart_screen.dart';
import '../component/search_product.dart';
import 'order_bloc.dart';
import 'order_event.dart';
import 'order_sate.dart';

class OrderScreen extends StatefulWidget {
  final String? codeCustomer;
  final String? nameCustomer;
  final String? phoneCustomer;
  final String? addressCustomer;

  const OrderScreen({Key? key, this.codeCustomer, this.nameCustomer, this.phoneCustomer, this.addressCustomer}) : super(key: key);


  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with TickerProviderStateMixin {
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
  late SearchItemResponseData itemSelect;
  late int indexSelect;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _totalController.text = '0';
    _orderBloc = OrderBloc(context);
    if(Const.listKeyGroupProduct.isNotEmpty){
      Const.listKeyGroupProduct.clear();
    }
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
            }
            else if(state is GetCountProductSuccess){
              if(state.firstLoad == true){
                _orderBloc.add(GetListOderEvent(idCustomer: widget.codeCustomer.toString(),searchValues: itemGroupCode,codeCurrency: currencyCode, pageIndex: selectedPage,listCodeGroupProduct: _orderBloc.listGroupProductCode));
              }
            }
            else if(state is OrderFailure){
              Utils.showCustomToast(context, Icons.warning_amber_outlined, state.toString());
            }
            else if (state is GetListOrderSuccess) {
              _list = _orderBloc.listItemOrder;
              _orderBloc.add(GetListGroupProductEvent());
            }
            else if(state is GetListGroupProductSuccess){
              _orderBloc.add(GetListItemGroupEvent(codeGroupProduct: codeGroupProduct));
            }
            else if(state is PickCurrencyNameSuccess){
              _orderBloc.listItemOrder.clear();
              _orderBloc.add(GetListOderEvent(idCustomer: widget.codeCustomer.toString(),searchValues: itemGroupCode,codeCurrency: state.codeCurrency,listCodeGroupProduct: _orderBloc.listGroupProductCode,isReLoad: true, pageIndex: selectedPage));
            }
            else if(state is PickupGroupProductSuccess){
              codeGroupProduct = state.codeGroup;
              Const.codeGroup = codeGroupProduct;
              _orderBloc.add(GetListItemGroupEvent(codeGroupProduct: codeGroupProduct));
            }
            else if(state is GetListItemProductSuccess){
              if(Const.woPrice == true && Const.listTransactionsOrder.isNotEmpty && Const.wholesale == true){
                for (var element in Const.listTransactionsOrder) {
                  _orderBloc.typePriceCode = element.maGd.toString().trim();
                  _orderBloc.typePriceName = element.tenGd.toString().trim();
                  if(element.tenGd.toString().contains('buôn')){
                    Const.isWoPrice = true;
                    break;
                  }else{
                    Const.isWoPrice = false;
                  }
                }
                _orderBloc.add(PickTypePriceName(typePriceCode: _orderBloc.typePriceCode,typePriceName: _orderBloc.typePriceName));
              }
            }
            else if(state is PickTypePriceNameSuccess){
              // _orderBloc.add(GetListOderEvent(searchValues: itemGroupCode, codeCurrency: currencyCode,idGroup: codeGroupProduct, pageIndex: selectedPage));
            }
            else if(state is ItemScanSuccess){
              // Navigator.push(
              //     context,
                  // MaterialPageRoute(
                  //     builder: (context) => CartPageNew(
                  //       viewUpdateOrder: false,
                  //       viewDetail: false,
                  //       listOrder: DataLocal.listStore,
                  //       currencyCode: !Utils.isEmpty(currencyCode) ? currencyCode : Const.currencyList[0].currencyCode.toString(),
                  //     )));
            }
            else if(state is AddCartSuccess){
              Const.listKeyGroupCheck = Const.listKeyGroup;
              Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm vào giỏ hàng thành công');
              _orderBloc.add(GetCountProductEvent(false));
            }
            else if(state is GetListStockEventSuccess){
              if(Const.inStockCheck == true){
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return InputQuantityPopupOrder(
                        title: 'Thêm vào giỏ',
                        inventoryStore: false,
                        quantity: 0,
                        quantityStock: itemSelect.stockAmount??0,
                        findStock: true,
                        listStock: _orderBloc.listStockResponse,
                        listDvt: itemSelect.allowDvt == true ? itemSelect.contentDvt!.split(',').toList() : [],
                        allowDvt: itemSelect.allowDvt,
                        nameProduction: itemSelect.name.toString(),
                        price: Const.isWoPrice == false ? itemSelect.price??0 :itemSelect.woPrice??0,
                        codeProduction: itemSelect.code.toString(), listObjectJson: itemSelect.jsonOtherInfo.toString(),
                        updateValues: true, listQuyDoiDonViTinh: _orderBloc.listQuyDoiDonViTinh,
                        nuocsx:  _list[indexSelect].nuocsx.toString(),
                        quycach:  _list[indexSelect].quycach.toString(),
                        tenThue:  _list[indexSelect].tenThue,thueSuat:  _list[indexSelect].thueSuat,
                      );
                    }).then((value){
                  if(value != null){
                    if(double.parse(value[0].toString()) > 0){
                      _list[indexSelect].count = double.parse(value[0].toString());
                      _list[indexSelect].stockCode = (value[2].toString());
                      _list[indexSelect].stockName = (value[3].toString());
                      _list[indexSelect].isSanXuat = (value[5] == 1 ? true : false);
                      _list[indexSelect].isCheBien = (value[5] == 2 ? true : false);
                      _list[indexSelect].giaSuaDoi = double.parse(value[4].toString());
                      _list[indexSelect].giaGui = double.parse(value[6].toString());
                      // _list[indexSelect].price = Const.editPrice == true ? (_list[indexSelect].price! >= 0 ? _list[indexSelect].price : double.parse(value[6].toString()))
                      //  : _list[indexSelect].price;
                      _list[indexSelect].note = value[10].toString();
                      _list[indexSelect].jsonOtherInfo = value[11].toString();
                      _list[indexSelect].name =  (value[7].toString().isNotEmpty && value[7].toString() != 'null') ? value[7].toString() : itemSelect.name;
                      _list[indexSelect].priceMin = _orderBloc.listStockResponse.isNotEmpty ? _orderBloc.listStockResponse[0].priceMin??0 : 0;
                      _list[indexSelect].idNVKD = value[13].toString();
                      _list[indexSelect].nameNVKD = value[14].toString();
                      _list[indexSelect].nuocsx = value[15].toString();
                      _list[indexSelect].quycach = value[16].toString();
                      _list[indexSelect].contentDvt = value[17].toString();
                      _list[indexSelect].allowDvt =  itemSelect.allowDvt;
                      Product production = Product(
                          code: itemSelect.code,
                          name:  (value[7].toString().isNotEmpty && value[7].toString() != 'null') ? value[7].toString() : itemSelect.name,
                          name2:itemSelect.name2,
                          dvt:value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  itemSelect.dvt,
                          description:itemSelect.descript,
                          price: Const.isWoPrice == false ? itemSelect.price : itemSelect.woPrice,
                          priceAfter: Const.isWoPrice == false ?  itemSelect.priceAfter : itemSelect.woPriceAfter ,
                          discountPercent:itemSelect.discountPercent,
                          stockAmount:itemSelect.stockAmount,
                          taxPercent:itemSelect.taxPercent,
                          imageUrl:itemSelect.imageUrl ?? '',
                          count:itemSelect.count,
                          isMark:1,
                          discountMoney:itemSelect.discountMoney ?? '0',
                          discountProduct:itemSelect.discountProduct ?? '0',
                          budgetForItem:itemSelect.budgetForItem ?? '',
                          budgetForProduct:itemSelect.budgetForProduct ?? '',
                          residualValueProduct:itemSelect.residualValueProduct ?? 0,
                          residualValue:itemSelect.residualValue ?? 0,
                          unit:itemSelect.unit ?? '',
                          unitProduct:itemSelect.unitProduct ?? '',
                          dsCKLineItem:itemSelect.maCk.toString(),
                          allowDvt: itemSelect.allowDvt == true ? 1 :0 ,
                          contentDvt: itemSelect.contentDvt ?? '',
                          kColorFormatAlphaB: itemSelect.kColorFormatAlphaB?.value,
                          codeStock: value[2].toString(),
                          nameStock: value[3].toString(),
                          isSanXuat: (value[5] == 1 ? 1 : 0),
                          isCheBien: (value[5] == 2 ? 1 : 0),
                          giaSuaDoi: double.parse(value[4].toString()),
                          giaGui: double.parse(value[6].toString()),
                          priceMin: _orderBloc.listStockResponse.isNotEmpty ? _orderBloc.listStockResponse[0].priceMin??0 : 0,
                          note: value[10].toString(),
                          jsonOtherInfo: value[11].toString(),
                          heSo: value[12],
                          idNVKD: value[13],
                          nameNVKD:value[14],
                          nuocsx:value[15],
                          quycach:value[16],
                          maThue: itemSelect.maThue,
                          tenThue: itemSelect.tenThue,
                          thueSuat: itemSelect.thueSuat,
                          applyPriceAfterTax: itemSelect.applyPriceAfterTax == true ? 1 : 0,
                          discountByHand: itemSelect.discountByHand == true ? 1 : 0,
                          discountPercentByHand: itemSelect.discountPercentByHand,
                          ckntByHand: itemSelect.ckntByHand,
                          priceOk: itemSelect.priceOk,
                          woPrice: itemSelect.woPrice,
                          woPriceAfter: itemSelect.woPriceAfter,
                      );
                      _orderBloc.add(AddCartEvent(productItem: production));
                    }
                  }
                });
              }
              else{
                if(itemSelect.stockAmount!>0){
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return InputQuantityPopupOrder(
                          title: 'Thêm vào giỏ',
                          inventoryStore: false,
                          quantity: 0,
                          quantityStock: itemSelect.stockAmount??0,
                          findStock: true,
                          listStock: _orderBloc.listStockResponse,
                          listDvt: itemSelect.allowDvt == true ? itemSelect.contentDvt!.split(',').toList() : [],
                          allowDvt: itemSelect.allowDvt,
                          nameProduction: itemSelect.name.toString(),
                          price: Const.isWoPrice == false ? itemSelect.price??0 :itemSelect.woPrice??0,
                            listQuyDoiDonViTinh: _orderBloc.listQuyDoiDonViTinh,
                          codeProduction: itemSelect.code.toString(),
                          listObjectJson: itemSelect.jsonOtherInfo.toString(),
                          updateValues: true,
                          nuocsx:  _list[indexSelect].nuocsx.toString(),
                          quycach:  _list[indexSelect].quycach.toString(),
                          tenThue:  _list[indexSelect].tenThue,thueSuat:  _list[indexSelect].thueSuat,
                        );
                      }).then((value){
                    if(double.parse(value[0].toString()) > 0){
                      _list[indexSelect].count = double.parse(value[0].toString());
                      _list[indexSelect].dvt = (value[1].toString());
                      _list[indexSelect].stockCode = (value[2].toString());
                      _list[indexSelect].stockName = (value[3].toString());
                      _list[indexSelect].isSanXuat = (value[5] == 1 ? true : false);
                      _list[indexSelect].isCheBien = (value[5] == 2 ? true : false);
                      _list[indexSelect].giaSuaDoi = double.parse(value[4].toString());
                      _list[indexSelect].giaGui = double.parse(value[6].toString());
                      // _list[indexSelect].price = Const.editPrice == true ? (_list[indexSelect].price! >= 0 ? _list[indexSelect].price : double.parse(value[6].toString()))
                      //     : _list[indexSelect].price;
                      _list[indexSelect].note = value[10].toString();
                      _list[indexSelect].jsonOtherInfo = value[11].toString();
                      _list[indexSelect].name = (value[7].toString().isNotEmpty && value[7].toString() != 'null') ? value[7].toString() : itemSelect.name;
                      _list[indexSelect].priceMin = _orderBloc.listStockResponse.isNotEmpty ? _orderBloc.listStockResponse[0].priceMin??0 : 0;
                      _list[indexSelect].idNVKD = value[13].toString();
                      _list[indexSelect].nameNVKD = value[14].toString();
                      _list[indexSelect].nuocsx = value[15].toString();
                      _list[indexSelect].quycach = value[16].toString();
                      _list[indexSelect].contentDvt = value[17].toString();
                      Product production = Product(
                          code: itemSelect.code,
                          name:  (value[7].toString().isNotEmpty && value[7].toString() != 'null') ? value[7].toString() : itemSelect.name,
                          name2:itemSelect.name2,
                          dvt:value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  itemSelect.dvt,
                          description:itemSelect.descript,
                          price: Const.isWoPrice == false ? itemSelect.price : itemSelect.woPrice,
                          priceAfter: Const.isWoPrice == false ?  itemSelect.priceAfter : itemSelect.woPriceAfter ,
                          discountPercent:itemSelect.discountPercent,
                          stockAmount:itemSelect.stockAmount,
                          taxPercent:itemSelect.taxPercent,
                          imageUrl:itemSelect.imageUrl ?? '',
                          count:itemSelect.count,
                          isMark:1,
                          discountMoney:itemSelect.discountMoney ?? '0',
                          discountProduct:itemSelect.discountProduct ?? '0',
                          budgetForItem:itemSelect.budgetForItem ?? '',
                          budgetForProduct:itemSelect.budgetForProduct ?? '',
                          residualValueProduct:itemSelect.residualValueProduct ?? 0,
                          residualValue:itemSelect.residualValue ?? 0,
                          unit:itemSelect.unit ?? '',
                          unitProduct:itemSelect.unitProduct ?? '',
                          dsCKLineItem:itemSelect.maCk.toString(),
                          allowDvt: itemSelect.allowDvt == true ? 1 : 0,
                          contentDvt: itemSelect.contentDvt ?? '',
                          kColorFormatAlphaB: itemSelect.kColorFormatAlphaB?.value,
                          codeStock: value[2].toString(),
                          nameStock: value[3].toString(),
                          isSanXuat: (value[5] == 1 ? 1 : 0),
                          isCheBien: (value[5] == 2 ? 1 : 0),
                          giaSuaDoi: double.parse(value[4].toString()),
                          giaGui: double.parse(value[6].toString()),
                          priceMin: _orderBloc.listStockResponse.isNotEmpty ? _orderBloc.listStockResponse[0].priceMin??0 : 0,
                          note: value[10].toString(),
                          jsonOtherInfo: value[11].toString(),
                          heSo: value[12],
                          idNVKD: value[13],
                          nameNVKD:value[14],
                          nuocsx:value[15],
                          quycach:value[16],
                          maThue: itemSelect.maThue,
                          tenThue: itemSelect.tenThue,
                          thueSuat: itemSelect.thueSuat,
                          applyPriceAfterTax: itemSelect.applyPriceAfterTax == true ? 1 : 0,
                          discountByHand: itemSelect.discountByHand == true ? 1 : 0,
                          discountPercentByHand: itemSelect.discountPercentByHand,
                          ckntByHand: itemSelect.ckntByHand,
                          priceOk: itemSelect.priceOk,
                          woPrice: itemSelect.woPrice,
                          woPriceAfter: itemSelect.woPriceAfter,
                      );
                      _orderBloc.add(AddCartEvent(productItem: production));
                    }
                  });
                }
                else{
                  showDialog(
                      context: context,
                      builder: (context) {
                        return WillPopScope(
                            onWillPop: () async => true,
                            child:  const CustomQuestionComponent(
                              showTwoButton: false,
                              iconData: Icons.warning_amber_outlined,
                              title: 'Úi, sản phẩm đã hết hàng!',
                              content: 'Vui lòng liên hệ với Đại lý.',
                            )
                        );
                      });
                }
              }
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
                          _orderBloc.add(GetListOderEvent(idCustomer: widget.codeCustomer.toString(),searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
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
                            _orderBloc.add(GetListOderEvent(idCustomer: widget.codeCustomer.toString(),searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
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
                                _orderBloc.add(GetListOderEvent(idCustomer: widget.codeCustomer.toString(),searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
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
                            _orderBloc.add(GetListOderEvent(idCustomer: widget.codeCustomer.toString(),searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
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
                          _orderBloc.add(GetListOderEvent(idCustomer: widget.codeCustomer.toString(),searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
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

  String codeTypeGroup = '';

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
                              if(_orderBloc.listGroupProductCode.any((element) => element.toString().trim() == _orderBloc.listGroupProduct[index].groupCode.toString().trim()) == true){
                                _orderBloc.listGroupProduct[index].isChecked = true;
                              }
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
                                              bool deleteItem = false;
                                              int indexItemGroup = 0;
                                              if(Const.listKeyGroupProduct.isNotEmpty){
                                                for(int i = 0; i <= Const.listKeyGroupProduct.length; i++){
                                                  if(Const.listKeyGroupProduct[i].key.toString().trim() == _orderBloc.listGroupProduct[index].groupCode.toString().trim()){
                                                    indexItemGroup = i;
                                                    deleteItem = true;
                                                    break;
                                                  }
                                                }
                                              }
                                              if(deleteItem == true){
                                                Const.listKeyGroupProduct.removeAt(indexItemGroup);
                                              }
                                            }
                                            else{
                                              if(_orderBloc.listGroupProductCode.any((element) => element.toString().trim() == _orderBloc.listGroupProduct[index].groupCode.toString().trim()) == false){
                                                _orderBloc.listGroupProductCode.add(_orderBloc.listGroupProduct[index].groupCode.toString());
                                                Const.listGroupProductCode.add(_orderBloc.listGroupProduct[index].groupCode.toString());
                                              }
                                              codeTypeGroup = _orderBloc.listGroupProduct[index].groupCode.toString();
                                              EntityClass item = EntityClass(
                                                  key: _orderBloc.listGroupProduct[index].groupCode.toString(),
                                                  values: ''
                                              );
                                              Const.listKeyGroupProduct.add(item);
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
                                    bool deleteItem = false;
                                    int indexItemGroup = 0;
                                    if(Const.listKeyGroupProduct.isNotEmpty){
                                      for(int i = 0; i <= Const.listKeyGroupProduct.length; i++){
                                        if(Const.listKeyGroupProduct[i].key.toString().trim() == _orderBloc.listGroupProduct[index].groupCode.toString().trim()){
                                          indexItemGroup = i;
                                          deleteItem = true;
                                          break;
                                        }
                                      }
                                    }
                                    if(deleteItem == true){
                                      Const.listKeyGroupProduct.removeAt(indexItemGroup);
                                    }
                                  }
                                  else{
                                    if(_orderBloc.listGroupProductCode.any((element) => element.toString().trim() == _orderBloc.listGroupProduct[index].groupCode.toString().trim()) == false){
                                      _orderBloc.listGroupProductCode.add(_orderBloc.listGroupProduct[index].groupCode.toString());
                                      Const.listGroupProductCode.add(_orderBloc.listGroupProduct[index].groupCode.toString());
                                    }
                                    codeTypeGroup = _orderBloc.listGroupProduct[index].groupCode.toString();
                                    EntityClass item = EntityClass(
                                        key: _orderBloc.listGroupProduct[index].groupCode.toString(),
                                        values: ''
                                    );
                                    Const.listKeyGroupProduct.add(item);
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
          Text(_orderBloc.listGroupProductCode.isEmpty ? 'Tất cả' : 'Loại nhóm: ${_orderBloc.listGroupProductCode.join(',').toString()}'),
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

  bool changeIsWoPrice = false;
  int indexIsWoPrice = 0 ;

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
                                                                          bottom: 12, top: 8)
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

                                    bool updateItem = false;
                                    int indexItemGroup = 0;
                                    EntityClass item = EntityClass();
                                    if(Const.listKeyGroupProduct.isNotEmpty){
                                      for(int i = 0; i <= Const.listKeyGroupProduct.length; i++){
                                        if(Const.listKeyGroupProduct[i].key.toString().trim() == codeTypeGroup.trim()){
                                          item.key = codeTypeGroup;
                                          item.values = itemGroupCode;
                                          updateItem = true;
                                          indexItemGroup = i;
                                          break;
                                        }
                                      }
                                    }

                                    if(updateItem == true){
                                      Const.listKeyGroupProduct.removeAt(indexItemGroup);
                                      Const.listKeyGroupProduct.add(item);
                                    }

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
                                    _orderBloc.add(GetListOderEvent(idCustomer: widget.codeCustomer.toString(),searchValues: '',codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage ));
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

                                            bool updateItem = false;
                                            int indexItemGroup = 0;
                                            EntityClass item = EntityClass();
                                            if(Const.listKeyGroupProduct.isNotEmpty){
                                              for(int i = 0; i <= Const.listKeyGroupProduct.length; i++){
                                                if(Const.listKeyGroupProduct[i].key.toString().trim() == codeTypeGroup.trim()){
                                                  item.key = codeTypeGroup;
                                                  item.values = itemGroupCode;
                                                  updateItem = true;
                                                  indexItemGroup = i;
                                                  break;
                                                }
                                              }
                                            }

                                            if(updateItem == true){
                                              Const.listKeyGroupProduct.removeAt(indexItemGroup);
                                              Const.listKeyGroupProduct.add(item);
                                            }

                                            _orderBloc.add(GetListOderEvent(idCustomer: widget.codeCustomer.toString(),searchValues: '',codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage ));
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
                padding: const EdgeInsets.only(left: 10, right: 8, top: 12, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh sách sản phẩm',
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        _orderBloc.typePriceName = Const.isWoPrice == true ? 'Bán buôn' : 'Bán lẻ';
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
                                  heightFactor: 0.35,
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
                                                padding: const EdgeInsets.only(top: 8.0,left: 16,right: 8),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Icon(Icons.check,color: Colors.white,),
                                                    const Text('Tuỳ chọn',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),),
                                                    InkWell(
                                                        onTap: ()=> Navigator.pop(context),
                                                        child: const Icon(Icons.close,color: Colors.black,)),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 5,),
                                              const Divider(color: Colors.blueGrey,),
                                              const SizedBox(height: 5,),
                                              Expanded(
                                                child: ListView(
                                                  padding: const EdgeInsets.only(left: 16,right: 16,bottom: 0),
                                                  children: [
                                                    SizedBox(
                                                      height:35,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text('Loại tiền tệ',style: TextStyle(color: Colors.black),),
                                                          Const.currencyList.isEmpty
                                                              ? const Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12))
                                                              :
                                                          Expanded(
                                                            child: PopupMenuButton(
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
                                                                                Const.tyGiaQuyDoi =  Const.currencyList[index].tyGia;
                                                                                myState(() {});
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
                                                              child: SizedBox(
                                                                height: 35,width: double.infinity,
                                                                child: Align(
                                                                  alignment: Alignment.centerRight,
                                                                  child: Text(_orderBloc.currencyName.toString(),style: const TextStyle(color: subColor),textAlign: TextAlign.center,),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.only(top: 8,bottom: 12),
                                                      child: Divider(),
                                                    ),
                                                    Visibility(
                                                      visible: Const.woPrice == true,
                                                      child: SizedBox(
                                                        height: 35,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const Text('Loại Giá',style: TextStyle(color: Colors.black),),
                                                            Const.listTransactionsOrder.isEmpty
                                                                ? const Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)) :
                                                            Expanded(
                                                              child: PopupMenuButton(
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
                                                                            itemCount: Const.listTransactionsOrder.length,
                                                                            itemBuilder: (context, index) {
                                                                              final trans = Const.listTransactionsOrder[index].tenGd.toString().trim();
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
                                                                                      Const.listTransactionsOrder[index].maGd.toString().trim(),
                                                                                      style: const TextStyle(
                                                                                        fontSize: 12,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                subtitle:const Divider(height: 1,),
                                                                                onTap: () {
                                                                                  if(Const.listTransactionsOrder[index].maGd.toString().trim() == '1'){
                                                                                    changeIsWoPrice = false;
                                                                                    indexIsWoPrice = index;
                                                                                    //Const.isWoPrice = false;
                                                                                  }else{
                                                                                    changeIsWoPrice = true;
                                                                                    indexIsWoPrice = index;
                                                                                    // Const.isWoPrice = true;
                                                                                  }
                                                                                  _orderBloc.typePriceName = Const.listTransactionsOrder[indexIsWoPrice].tenGd.toString();
                                                                                  myState(() {});
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
                                                                child: SizedBox(
                                                                  height: 35,width: double.infinity,
                                                                  child: Align(
                                                                    alignment: Alignment.centerRight,
                                                                    child: Text(_orderBloc.typePriceName.toString(),style: const TextStyle(color: subColor),textAlign: TextAlign.center,),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 16,right: 16,bottom: 12),
                                                child: GestureDetector(
                                                  onTap: (){
                                                    // _orderBloc.add(GetListOderEvent(searchValues: itemGroupCode, codeCurrency: currencyCode,listCodeGroupProduct: _orderBloc.listGroupProductCode, pageIndex: selectedPage));
                                                    Navigator.pop(context,['Yeah']);
                                                  },
                                                  child: Container(
                                                    height: 45, width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: subColor
                                                    ),
                                                    child: const Center(
                                                      child: Text('Áp dụng', style: TextStyle(color: Colors.white,fontSize: 12.5),),
                                                    ),
                                                  ),
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
                            if(value[0] == 'Yeah'){
                              if(changeIsWoPrice == true){
                                Const.isWoPrice = true;
                              }else{
                                Const.isWoPrice = false;
                              }
                              _orderBloc.add(PickTypePriceName(typePriceCode: Const.listTransactionsOrder[indexIsWoPrice].maGd.toString(),typePriceName: Const.listTransactionsOrder[indexIsWoPrice].tenGd.toString()));
                            }
                          }
                        });
                      },
                      child: const SizedBox(
                        height: 30,width: 35,
                        child: Icon(Icons.filter_list, color: Colors.black,size: 20,),
                      ),
                    )
                    // buildCurrency()
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index){
                      return GestureDetector(
                          onTap: ()
                          {
                            itemSelect = _list[index];
                            indexSelect = index;
                            _orderBloc.add(GetListStockEvent(
                              itemCode: _list[index].code.toString(),
                              checkStockEmployee: Const.checkStockEmployee,
                            ));
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
                                                  Const.isWoPrice == false ?
                                                  (_list[index].price == _list[index].priceAfter && _list[index].price! > 0) ? Container() :
                                                  Text(
                                                    (currencyCode == "VND"
                                                        ?
                                                    Utils.formatMoneyStringToDouble(_list[index].price??0)
                                                        :
                                                    Utils.formatMoneyStringToDouble(_list[index].price??0)).toString().trim()
                                                    == '0' ? 'Giá đang cập nhật' : (currencyCode == "VND"
                                                        ?
                                                    '${Utils.formatMoneyStringToDouble(_list[index].price??0)} ₫'
                                                        :
                                                    '${Utils.formatMoneyStringToDouble(_list[index].price??0)} ₫')
                                                    ,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(color: grey, fontSize: 10, decoration: (currencyCode == "VND"
                                                        ?
                                                    Utils.formatMoneyStringToDouble(_list[index].price??0)
                                                        :
                                                    Utils.formatMoneyStringToDouble(_list[index].price??0)).toString().trim() == '0' ? TextDecoration.none : TextDecoration.lineThrough),
                                                  )
                                                      :
                                                  (_list[index].woPrice == _list[index].woPriceAfter && _list[index].woPrice! > 0) ? Container() : Text(
                                                    (currencyCode == "VND"
                                                        ?
                                                    Utils.formatMoneyStringToDouble(_list[index].woPrice??0)
                                                        :
                                                    Utils.formatMoneyStringToDouble(_list[index].woPrice??0)).toString().trim()
                                                        == '0' ? 'Giá đang cập nhật' : (currencyCode == "VND"
                                                        ?
                                                    '${Utils.formatMoneyStringToDouble(_list[index].woPrice??0)} ₫'
                                                        :
                                                    '${Utils.formatMoneyStringToDouble(_list[index].woPrice??0)} ₫')
                                                    ,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(color: grey, fontSize: 10, decoration: (currencyCode == "VND"
                                                        ?
                                                    Utils.formatMoneyStringToDouble(_list[index].woPrice??0)
                                                        :
                                                    Utils.formatMoneyStringToDouble(_list[index].woPrice??0)).toString().trim() == '0' ? TextDecoration.none : TextDecoration.lineThrough),
                                                  ),
                                                  const SizedBox(height: 3,),
                                                  Const.isWoPrice == false ? Visibility(
                                                    visible: _list[index].price! > 0,
                                                    child: Text(
                                                      currencyCode == "VND"
                                                          ?
                                                      '${Utils.formatMoneyStringToDouble(_list[index].priceAfter??0)} ₫'
                                                          :
                                                      '${Utils.formatMoneyStringToDouble(_list[index].priceAfter??0)} ₫',
                                                      textAlign: TextAlign.left,
                                                      style:const TextStyle(color: Color(
                                                          0xff067902), fontSize: 13,fontWeight: FontWeight.w700),
                                                    ),
                                                  ) : Visibility(
                                                    visible: _list[index].woPrice! > 0,
                                                    child: Text(
                                                      currencyCode == "VND"
                                                          ?
                                                      '${Utils.formatMoneyStringToDouble(_list[index].woPriceAfter??0)} ₫'
                                                          :
                                                      '${Utils.formatMoneyStringToDouble(_list[index].woPriceAfter??0)} ₫',
                                                      textAlign: TextAlign.left,
                                                      style:const TextStyle(color: Color(
                                                          0xff067902), fontSize: 13,fontWeight: FontWeight.w700),
                                                    ),
                                                  ) ,
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
              _orderBloc.totalPager > 1 ? _getDataPager() : Container(),
              const SizedBox(height: 5,),
            ],
          ),
        )
      ],
    );
  }

  int indexSelectAdvOrder2 = 0;

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
              width: 40,
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
                    idCustomer: widget.codeCustomer.toString(), /// Chỉ có thêm tồn kho ở check-in mới thêm idCustomer
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
                child: Row(
                  children:[
                    const Icon(
                      Icons.search,
                      size: 18,
                      color: white,
                    ),
                    Expanded(
                        child: Text( Const.typeOrder == true ?
                          'Tìm kiếm SP ${Const.nameTypeAdvOrder.toString().trim()}' : 'Tìm kiếm sản phẩm',
                          style: const TextStyle(color: white,fontSize: 13,fontStyle: FontStyle.normal,),maxLines: 1,
                        )),
                    const Icon(
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
          InkWell(
            onTap: (){
              Const.currencyCode = !Utils.isEmpty(currencyCode) ? currencyCode : Const.currencyList[0].currencyCode.toString();
              Const.itemGroupCode = itemGroupCode;

              PersistentNavBarNavigator.pushNewScreen(context, screen: CartScreen(
                viewUpdateOrder: false,
                viewDetail: false,
                listIdGroupProduct: _orderBloc.listGroupProductCode,
                itemGroupCode:itemGroupCode,
                listOrder: _orderBloc.listProduct,
                orderFromCheckIn: false,
                title: 'Đặt hàng',
                currencyCode: !Utils.isEmpty(currencyCode) ? currencyCode : Const.currencyList[0].currencyCode.toString(),
                nameCustomer: widget.nameCustomer,
                idCustomer: widget.codeCustomer,
                phoneCustomer: widget.phoneCustomer,
                addressCustomer: widget.addressCustomer,
                codeCustomer: widget.codeCustomer, loadDataLocal: true,
              ),withNavBar: false).then((value) {
                _orderBloc.add(GetCountProductEvent(false));
              });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none, alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.local_grocery_store,
                    color: white,
                    size: 20,
                  ),
                  Visibility(
                    visible: Const.numberProductInCart > 0,
                    child: Positioned(
                      top: -10,
                      right: -7,
                      child: Container(
                        alignment: Alignment.center,
                        padding:const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: blue,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        constraints:const BoxConstraints(
                          minWidth: 17,
                          minHeight: 17,
                        ),
                        child: Text(
                          "${Const.numberProductInCart}",
                          style:const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5,),
          Visibility(
            visible: Const.typeOrder == true,
            child: InkWell(
              onTap: (){
                indexSelectAdvOrder2 = Const.indexSelectAdvOrder;
                Const.listTransactionsTAH[indexSelectAdvOrder2].isMark = true;
                showModalBottomSheet(
                    context: context,
                    isDismissible: false,
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
                          heightFactor: 0.45,
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
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0,left: 16,right: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.check,color: Colors.white,),
                                            Text('Tuỳ chọn loại hàng hoá',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),),
                                            Icon(Icons.close,color: Colors.transparent,),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5,),
                                      const Divider(color: Colors.blueGrey,),
                                      const SizedBox(height: 5,),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: Const.listTransactionsTAH.length,
                                          padding: const EdgeInsets.only(left: 16,right: 16,bottom: 0),
                                          itemBuilder: (BuildContext context, int index) {
                                            return InkWell(
                                              onTap: (){
                                                myState((){
                                                  Const.listTransactionsTAH[indexSelectAdvOrder2].isMark = false;
                                                  indexSelectAdvOrder2 = index;
                                                  Const.listTransactionsTAH[index].isMark = true;
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height:35,
                                                    child: Row(
                                                      children: [
                                                        Visibility(
                                                            visible: Const.listTransactionsTAH[index].isMark == true,
                                                            child: const Padding(
                                                              padding: EdgeInsets.only(left: 10),
                                                              child: Icon(Icons.check, color: Colors.red,),
                                                            )),
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(Const.listTransactionsTAH[index].tenGd.toString().trim(),style: const TextStyle(color: Colors.black),),
                                                              Text(Const.listTransactionsTAH[index].maGd.toString().trim(),style: const TextStyle(color: Colors.black),),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(top: 8,bottom: 12),
                                                    child: Divider(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16,right: 16,bottom: 12),
                                        child: GestureDetector(
                                          onTap: (){
                                            Navigator.pop(context,['Yeah',]);
                                          },
                                          child: Container(
                                            height: 45, width: double.infinity,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: subColor
                                            ),
                                            child: const Center(
                                              child: Text('Áp dụng', style: TextStyle(color: Colors.white,fontSize: 12.5),),
                                            ),
                                          ),
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
                    setState(() {
                      if(value[0] == 'Yeah'){
                        Const.indexSelectAdvOrder = indexSelectAdvOrder2;
                        Const.idTypeAdvOrder = Const.listTransactionsTAH[Const.indexSelectAdvOrder].maGd.toString();
                        Const.nameTypeAdvOrder = Const.listTransactionsTAH[Const.indexSelectAdvOrder].tenGd.toString();
                      }else{
                        Const.listTransactionsTAH[indexSelectAdvOrder2].isMark = false;
                        print(Const.listTransactionsTAH[indexSelectAdvOrder2].isMark);
                      }
                    });
                  }else{
                    Const.listTransactionsTAH[indexSelectAdvOrder2].isMark = false;
                    print(Const.listTransactionsTAH[indexSelectAdvOrder2].isMark);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.filter_list,
                  color: white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}