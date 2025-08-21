// ignore_for_file: unnecessary_null_comparison, unrelated_type_equality_checks

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dms/widget/custom_order.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/input_quantity_popup_order.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:collection/collection.dart';
import '../../../model/database/data_local.dart';
import '../../../model/entity/product.dart';
import '../../../model/network/response/get_item_holder_detail_response.dart';
import '../../../model/network/response/search_list_item_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/debouncer.dart';
import '../../../utils/images.dart';
import '../../../utils/utils.dart';
import '../product_detail/product_detail_screen.dart';
import '../cart/cart_bloc.dart';
import '../cart/cart_event.dart';
import '../cart/cart_state.dart';


class SearchProductScreen extends StatefulWidget {
  final String? currency;
  final bool? viewUpdateOrder;
  final List<String>? listIdGroupProduct;
  final String? itemGroupCode;
  final List<Product> listOrder;
  final bool? inventoryControl;
  final bool? addProductFromCheckIn;
  final bool? addProductFromSaleOut;
  final bool? addProductGiftFromSaleOut;
  final String? idCustomer;
  final bool giftProductRe;
  final bool lockInputToCart;
  final bool backValues;
  final bool? checkStockEmployee;
  final bool? isCreateItemHolder;
  final bool isCheckStock;

  const SearchProductScreen({Key? key, this.currency,this.viewUpdateOrder,this.listIdGroupProduct,this.itemGroupCode,required this.isCheckStock,
    required this.listOrder,required this.inventoryControl,required this.addProductFromCheckIn,required this.addProductFromSaleOut ,
    this.addProductGiftFromSaleOut,required this.idCustomer, required this.giftProductRe,
    required this.lockInputToCart,required this.backValues, this.checkStockEmployee, this.isCreateItemHolder}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchProductScreenState();
  }
}

class SearchProductScreenState extends State<SearchProductScreen> {

  late CartBloc _bloc;

  final focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  List<Product> listOrderInCart = <Product>[];


  final Debounce onSearchDebounce =  Debounce(delay:  const Duration(milliseconds: 1000));

  List<SearchItemResponseData> _dataListSearch = [];

  late SearchItemResponseData itemSelect;
  late int indexSelect;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = CartBloc(context);
    listOrderInCart = widget.listOrder;
    _bloc.add(GetPrefs());

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(SearchProduct(Utils.convertKeySearch(
            _searchController.text),widget.listIdGroupProduct!,
          widget.itemGroupCode.toString(),widget.idCustomer.toString(),widget.isCheckStock,
          isLoadMore: true,
        ));
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
        child: BlocListener<CartBloc,CartState>(
            bloc: _bloc,
            listener: (context, state) {
              if(state is GetPrefsSuccess){
                if(widget.addProductFromCheckIn == true){
                  _bloc.add(SearchProduct('',widget.listIdGroupProduct!, widget.itemGroupCode.toString(),widget.idCustomer.toString(),widget.isCheckStock));
                }
              }
              else if (state is CartFailure) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return WillPopScope(
                        onWillPop: () async => false,
                        child: CustomOrderError(
                          iconData: MdiIcons.shopping,
                          title: 'Cảnh báo đặt đơn',
                          content:  state.error.toString().trim().replaceAll('CartFailure { error:', '').replaceAll('}', ''),
                        ),
                      );
                    });
              }
              else if (state is RequiredText) {
                Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vui lòng nhập kí tự cần tìm kiếm');
              }
              else if(state is AddCartSuccess){
                if(widget.backValues == true){
                  ListItemHolderDetailResponse item = ListItemHolderDetailResponse(
                    sttRec: '',
                    sttRec0: '',
                    maDVCS:_dataListSearch[indexSelect].codeUnit.toString().trim(),
                    tenDVCS:_dataListSearch[indexSelect].nameUnit.toString().trim(),
                    maVt: _dataListSearch[indexSelect].code.toString().trim(),
                    tenVt: _dataListSearch[indexSelect].name.toString().trim(),
                    dvt:  _dataListSearch[indexSelect].dvt.toString().trim(),
                    tenDvt: _dataListSearch[indexSelect].contentDvt,
                    soLuong: _dataListSearch[indexSelect].count,
                    gia: _dataListSearch[indexSelect].giaSuaDoi,
                    giaNT2:  _dataListSearch[indexSelect].giaSuaDoi * Const.tyGiaQuyDoi,
                    listCustomer: []
                  );
                  DataLocal.listItemHolderCreate.add(item);
                }else{
                  Const.listKeyGroupCheck = Const.listKeyGroup;
                }
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm vào giỏ hàng thành công');
              }
              else if(state is UpdateProductCountInventorySuccess){
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Thêm vào Sổ tồn thành công');
                DataLocal.listInventoryIsChange = true;
              }
              else if(state is AddProductCountFromCheckInSuccess){
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Thêm vào đơn hàng thành công');
                DataLocal.listOrderProductIsChange = true;
              }
              else if(state is AddProductSaleOutSuccess){
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Thêm sản phẩm thành công');
                DataLocal.listOrderProductIsChange = true;
              }
              else if(state is GetListStockEventSuccess){
                if(widget.inventoryControl == true){
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return InputQuantityPopupOrder(
                          title: widget.addProductFromCheckIn == true ? 'Thêm vào đơn hàng' : widget.addProductFromSaleOut == true ? 'Thêm sản phẩm' : 'Thêm vào giỏ',
                          quantity: 0,
                          quantityStock: _bloc.ton13,
                          findStock: true,
                          listStock: _bloc.listStockResponse,
                          inventoryStore: widget.inventoryControl,listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh,
                          allowDvt: itemSelect.allowDvt ,
                          listDvt: itemSelect.allowDvt == true ? itemSelect.contentDvt!.split(',').toList() : [],
                          nameProduction: itemSelect.name.toString(),
                          price: Const.isWoPrice == false ? itemSelect.price??0 :itemSelect.woPrice??0,
                          isCreateItemHolder:widget.isCreateItemHolder,
                          codeProduction: itemSelect.code.toString(),listObjectJson: itemSelect.jsonOtherInfo.toString(),
                          updateValues: true,
                          nuocsx: _dataListSearch[indexSelect].nuocsx.toString(), quycach: _dataListSearch[indexSelect].quycach.toString(),
                          tenThue:  _dataListSearch[indexSelect].tenThue,thueSuat:  _dataListSearch[indexSelect].thueSuat,
                        );
                      }).then((value){
                    if(double.parse(value[0].toString()) > 0){
                      _dataListSearch[indexSelect].count = double.parse(value[0].toString());
                      _dataListSearch[indexSelect].stockCode = (value[2].toString());
                      _dataListSearch[indexSelect].stockName = (value[3].toString());
                      _dataListSearch[indexSelect].isSanXuat = (value[5] == 1 ? true : false);
                      _dataListSearch[indexSelect].isCheBien = (value[5] == 2 ? true : false);
                      _dataListSearch[indexSelect].giaSuaDoi = double.parse(value[4].toString());
                      _dataListSearch[indexSelect].giaGui = double.parse(value[6].toString());
                      _dataListSearch[indexSelect].priceMin = _bloc.listStockResponse.isNotEmpty ? _bloc.listStockResponse[0].priceMin??0 : 0;
                      _dataListSearch[indexSelect].name =  (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : _dataListSearch[indexSelect].name;
                      _dataListSearch[indexSelect].codeUnit = value[8].toString();
                      _dataListSearch[indexSelect].nameUnit = value[9].toString();
                      _dataListSearch[indexSelect].note = value[10].toString();
                      _dataListSearch[indexSelect].jsonOtherInfo = value[11].toString();
                      _dataListSearch[indexSelect].heSo = value[12];
                      _dataListSearch[indexSelect].idNVKD = value[13];
                      _dataListSearch[indexSelect].nameNVKD = value[14];
                      _dataListSearch[indexSelect].nuocsx = value[15];
                      _dataListSearch[indexSelect].quycach = value[16];
                      print(value[12].toString(),);
                      if(widget.inventoryControl == true){
                        _bloc.add(UpdateProductCountInventory(product: itemSelect));
                      }
                    }
                  });
                }
                else if(widget.addProductGiftFromSaleOut == true){
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return InputQuantityPopupOrder(
                          title: widget.addProductFromCheckIn == true ? 'Thêm vào đơn hàng' : widget.addProductFromSaleOut == true ? 'Thêm sản phẩm' : 'Thêm vào giỏ',
                          quantity: 0,
                          quantityStock: _bloc.ton13,
                          listStock: _bloc.listStockResponse,
                          findStock: true,
                          inventoryStore: widget.inventoryControl,
                          allowDvt: itemSelect.allowDvt ,
                          listDvt: itemSelect.allowDvt == true ? itemSelect.contentDvt!.split(',').toList() : [],
                          nameProduction: itemSelect.name.toString(),listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh,
                          price: Const.isWoPrice == false ? itemSelect.price??0 :itemSelect.woPrice??0,
                          isCreateItemHolder:widget.isCreateItemHolder, codeProduction:  itemSelect.code.toString(), listObjectJson: itemSelect.jsonOtherInfo.toString(),
                          updateValues: true,
                          nuocsx: _dataListSearch[indexSelect].nuocsx.toString(), quycach: _dataListSearch[indexSelect].quycach.toString(),
                          tenThue:  _dataListSearch[indexSelect].tenThue,thueSuat:  _dataListSearch[indexSelect].thueSuat,
                        );
                      }).then((value){
                        if(double.parse(value[0].toString()) > 0){
                          _dataListSearch[indexSelect].price = 0;
                          _dataListSearch[indexSelect].priceAfter = 0;
                          _dataListSearch[indexSelect].gifProductByHand = true;
                          _dataListSearch[indexSelect].count = value[0];
                          _dataListSearch[indexSelect].isSanXuat = (value[5] == 1 ? true : false);
                          _dataListSearch[indexSelect].isCheBien = (value[5] == 2 ? true : false);
                          _dataListSearch[indexSelect].giaSuaDoi = double.parse(value[4].toString());
                          _dataListSearch[indexSelect].giaGui = double.parse(value[6].toString());
                          _dataListSearch[indexSelect].priceMin = _bloc.listStockResponse.isNotEmpty ? _bloc.listStockResponse[0].priceMin??0 : 0;
                          _dataListSearch[indexSelect].codeUnit = value[8].toString();
                          _dataListSearch[indexSelect].nameUnit = value[9].toString();
                          _dataListSearch[indexSelect].note = value[10].toString();
                          _dataListSearch[indexSelect].heSo = value[12];
                          _dataListSearch[indexSelect].idNVKD = value[13];
                          _dataListSearch[indexSelect].nameNVKD = value[14];
                          _dataListSearch[indexSelect].nuocsx = value[15];
                          _dataListSearch[indexSelect].quycach = value[16];

                          _dataListSearch[indexSelect].jsonOtherInfo = value[11].toString();
                          _dataListSearch[indexSelect].name =  (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : _dataListSearch[indexSelect].name;
                          if(DataLocal.listProductGiftSaleOut.isEmpty){
                            DataLocal.listProductGiftSaleOut.add(_dataListSearch[indexSelect]);
                          }else{
                            if(DataLocal.listProductGiftSaleOut.any((element) => element.code.toString().trim() == _dataListSearch[indexSelect].code.toString().trim()) == true){
                              DataLocal.listProductGiftSaleOut.remove(_dataListSearch[indexSelect]);
                              DataLocal.listProductGiftSaleOut.add(_dataListSearch[indexSelect]);
                            }else{
                              DataLocal.listProductGiftSaleOut.add(_dataListSearch[indexSelect]);
                            }
                          }
                          Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm sản phẩm tặng thành công');
                        }
                  });
                }
                else{
                  if(widget.giftProductRe == true){
                    showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) {
                          return InputQuantityPopupOrder(
                            title: 'Nhập số lượng hàng tặng',
                            quantity: 0,
                            quantityStock: _bloc.ton13,
                            listStock: _bloc.listStockResponse,
                            findStock: true,
                            inventoryStore: widget.inventoryControl,
                            allowDvt: itemSelect.allowDvt ,
                            listDvt: itemSelect.allowDvt == true ? itemSelect.contentDvt!.split(',').toList() : [],
                            nameProduction: itemSelect.name.toString(),
                            price: Const.isWoPrice == false ? itemSelect.price??0 :itemSelect.woPrice??0,
                            isCreateItemHolder:widget.isCreateItemHolder, codeProduction: itemSelect.code.toString(),
                            listObjectJson: itemSelect.jsonOtherInfo.toString(),listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh,
                            nuocsx: _dataListSearch[indexSelect].nuocsx.toString(), quycach: _dataListSearch[indexSelect].quycach.toString(),
                            tenThue:  _dataListSearch[indexSelect].tenThue,thueSuat:  _dataListSearch[indexSelect].thueSuat,
                          );
                        }).then((value){
                      if(double.parse(value[0].toString()) > 0){
                        _dataListSearch[indexSelect].count = double.parse(value[0].toString());
                        _dataListSearch[indexSelect].stockCode = (value[2].toString());
                        _dataListSearch[indexSelect].stockName = (value[3].toString());
                        _dataListSearch[indexSelect].isSanXuat = (value[5] == 1 ? true : false);
                        _dataListSearch[indexSelect].isCheBien = (value[5] == 2 ? true : false);
                        _dataListSearch[indexSelect].giaSuaDoi = double.parse(value[4].toString());
                        _dataListSearch[indexSelect].giaGui = double.parse(value[6].toString());
                        _dataListSearch[indexSelect].priceMin = _bloc.listStockResponse.isNotEmpty ? _bloc.listStockResponse[0].priceMin??0 : 0;
                        _dataListSearch[indexSelect].name =  (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : _dataListSearch[indexSelect].name;
                        _dataListSearch[indexSelect].codeUnit = value[8].toString();
                        _dataListSearch[indexSelect].nameUnit = value[9].toString();
                        _dataListSearch[indexSelect].note = value[10].toString();
                        _dataListSearch[indexSelect].jsonOtherInfo = value[11].toString();
                        _dataListSearch[indexSelect].heSo = value[12].toString();
                        _dataListSearch[indexSelect].idNVKD = value[13];
                        _dataListSearch[indexSelect].nameNVKD = value[14];
                        _dataListSearch[indexSelect].nuocsx = value[15];
                        _dataListSearch[indexSelect].quycach = value[16];
                        _dataListSearch[indexSelect].dvt = value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  _dataListSearch[indexSelect].dvt;
                        print(value[12].toString(),);
                        if(Const.enableViewPriceAndTotalPriceProductGift == true){
                          _dataListSearch[indexSelect].price = Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice;
                          _dataListSearch[indexSelect].priceAfter = Const.isWoPrice == false ?  itemSelect.priceAfter : itemSelect.woPriceAfter;
                        }
                        Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm sản phẩm tặng thành công');
                        Navigator.pop(context,['Yeah',itemSelect]);
                      }
                    });
                  }
                  else{
                    if(Const.inStockCheck == true){
                      showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return InputQuantityPopupOrder(
                              title: widget.addProductFromCheckIn == true ? 'Thêm vào đơn hàng' : widget.addProductFromSaleOut == true ? 'Thêm sản phẩm' : 'Thêm vào giỏ',
                              quantity: 0,
                              quantityStock: _bloc.ton13,
                              listStock: _bloc.listStockResponse,
                              findStock: true,
                              inventoryStore: widget.inventoryControl,
                              allowDvt: itemSelect.allowDvt ,
                              listDvt: itemSelect.allowDvt == true ? itemSelect.contentDvt!.split(',').toList() : [],
                              nameProduction: itemSelect.name.toString(),
                              price: Const.isWoPrice == false ? itemSelect.price??0 :itemSelect.woPrice??0,
                              isCreateItemHolder:widget.isCreateItemHolder, codeProduction: itemSelect.code.toString(),
                              listObjectJson: itemSelect.jsonOtherInfo.toString(),listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh,
                              updateValues: true,
                              nuocsx: _dataListSearch[indexSelect].nuocsx.toString(), quycach: _dataListSearch[indexSelect].quycach.toString(),
                              tenThue:  _dataListSearch[indexSelect].tenThue,thueSuat:  _dataListSearch[indexSelect].thueSuat,
                            );
                          }).then((value){
                        if(double.parse(value[0].toString()) > 0){
                          _dataListSearch[indexSelect].count = double.parse(value[0].toString());
                          _dataListSearch[indexSelect].isSanXuat = (value[5] == 1 ? true : false);
                          _dataListSearch[indexSelect].isCheBien = (value[5] == 2 ? true : false);
                          _dataListSearch[indexSelect].giaSuaDoi = double.parse(value[4].toString());
                          _dataListSearch[indexSelect].giaGui = double.parse(value[6].toString());
                          // _dataListSearch[indexSelect].price = Const.editPrice == true ? ( _dataListSearch[indexSelect].price! >= 0 ?  _dataListSearch[indexSelect].price : double.parse(value[6].toString()))
                          //     :  _dataListSearch[indexSelect].price;
                          _dataListSearch[indexSelect].priceMin = _bloc.listStockResponse.isNotEmpty ? _bloc.listStockResponse[0].priceMin??0 : 0;
                          _dataListSearch[indexSelect].name =  (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : _dataListSearch[indexSelect].name;
                          _dataListSearch[indexSelect].codeUnit = value[8].toString();
                          _dataListSearch[indexSelect].nameUnit = value[9].toString();
                          _dataListSearch[indexSelect].note = value[10].toString();
                          _dataListSearch[indexSelect].jsonOtherInfo = value[11].toString();
                          _dataListSearch[indexSelect].heSo = value[12].toString();
                          _dataListSearch[indexSelect].idNVKD = value[13];
                          _dataListSearch[indexSelect].nameNVKD = value[14];
                          _dataListSearch[indexSelect].nuocsx = value[15];
                          _dataListSearch[indexSelect].quycach = value[16];
                          _dataListSearch[indexSelect].dvt = value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  _dataListSearch[indexSelect].dvt;
                          if(widget.inventoryControl == true){
                            _bloc.add(UpdateProductCountInventory(product: itemSelect));
                          }else if(widget.addProductFromCheckIn == true){
                            _bloc.add(AddProductCountFromCheckIn(product: itemSelect));
                          }else if(widget.addProductFromSaleOut == true){
                            Product production = Product(
                                code: itemSelect.code,
                                name: (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : itemSelect.name,
                                name2:itemSelect.name2,
                                dvt: value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  itemSelect.dvt,
                                description:itemSelect.descript,
                                price: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice,
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
                                allowDvt: itemSelect.allowDvt == true ? 0 : 1,
                                kColorFormatAlphaB: itemSelect.kColorFormatAlphaB?.value,
                                codeStock: value[2].toString(),
                                nameStock: value[3].toString(),
                                isSanXuat: (value[5] == 1 ? 1 : 0),
                                isCheBien : (value[5] == 2 ? 1 : 0),
                                giaSuaDoi : double.parse(value[4].toString()),
                                giaGui : double.parse(value[6].toString()),
                                priceMin: _bloc.listStockResponse.isNotEmpty ? _bloc.listStockResponse[0].priceMin??0 : 0,
                                codeUnit: value[8].toString(),
                                nameUnit: value[9].toString(),
                                note: value[10].toString(),
                                jsonOtherInfo: value[11].toString(),
                                heSo: value[12].toString(),idNVKD: value[13],
                                nameNVKD: value[14],
                                nuocsx: value[15],
                                quycach: value[16],
                                contentDvt: itemSelect.contentDvt ?? value[17],
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
                            _bloc.add(AddProductSaleOutEvent(productItem: production));
                          }
                          else{
                            Product production = Product(
                              code: itemSelect.code,
                              name: (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : itemSelect.name,
                              name2:itemSelect.name2,
                              dvt:value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  itemSelect.dvt,
                              description:itemSelect.descript,
                              price: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice,
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
                              allowDvt: itemSelect.allowDvt == true ? 0 : 1,
                              kColorFormatAlphaB: itemSelect.kColorFormatAlphaB?.value,
                              codeStock: value[2].toString(),
                              nameStock: value[3].toString(),
                              isSanXuat: (value[5] == 1 ? 1 : 0),
                              isCheBien : (value[5] == 2 ? 1 : 0),
                              giaSuaDoi : double.parse(value[4].toString()),
                              giaGui : double.parse(value[6].toString()),
                              codeUnit: value[8].toString(),
                              nameUnit: value[9].toString(),
                              note: value[10].toString(),
                              jsonOtherInfo: value[11].toString(),
                              heSo: value[12].toString(),
                              idNVKD: value[13],
                              nameNVKD: value[14],
                              nuocsx: value[15],
                              quycach: value[16],
                              contentDvt: itemSelect.contentDvt ?? value[17],
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
                            print(value[12].toString(),);
                            _bloc.add(AddCartEvent(productItem: production));
                          }
                        }
                      });
                    }
                    else {
                      if(itemSelect.stockAmount! > 0){
                        showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) {
                              return InputQuantityPopupOrder(
                                title: widget.addProductFromCheckIn == true ? 'Thêm vào đơn hàng' : widget.addProductFromSaleOut == true ? 'Thêm sản phẩm' : 'Thêm vào giỏ',
                                quantity: 0,
                                quantityStock: _bloc.ton13,
                                findStock: true,
                                listStock: _bloc.listStockResponse,
                                inventoryStore: widget.inventoryControl,
                                allowDvt: itemSelect.allowDvt ,
                                listDvt: itemSelect.allowDvt == true ? itemSelect.contentDvt!.split(',').toList() : [],
                                nameProduction: itemSelect.name.toString(),
                                price: Const.isWoPrice == false ? itemSelect.price??0 :itemSelect.woPrice??0,
                                isCreateItemHolder:widget.isCreateItemHolder, codeProduction:itemSelect.code.toString(),
                                listObjectJson: itemSelect.jsonOtherInfo.toString(),listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh,
                                updateValues: true,
                                nuocsx: _dataListSearch[indexSelect].nuocsx.toString(), quycach: _dataListSearch[indexSelect].quycach.toString(),
                                tenThue:  _dataListSearch[indexSelect].tenThue,thueSuat:  _dataListSearch[indexSelect].thueSuat,
                              );
                            }).then((value){
                          if(double.parse(value[0].toString()) > 0){
                            _dataListSearch[indexSelect].count = double.parse(value[0].toString());
                            _dataListSearch[indexSelect].stockCode = (value[2].toString());
                            _dataListSearch[indexSelect].stockName = (value[3].toString());
                            _dataListSearch[indexSelect].isSanXuat = (value[5] == 1 ? true : false);
                            _dataListSearch[indexSelect].isCheBien = (value[5] == 2 ? true : false);
                            _dataListSearch[indexSelect].giaSuaDoi = double.parse(value[4].toString());
                            _dataListSearch[indexSelect].giaGui = double.parse(value[6].toString());
                            // _dataListSearch[indexSelect].price = Const.editPrice == true ? ( _dataListSearch[indexSelect].price! >= 0 ?  _dataListSearch[indexSelect].price : double.parse(value[6].toString()))
                            //     :  _dataListSearch[indexSelect].price;
                            _dataListSearch[indexSelect].priceMin = _bloc.listStockResponse.isNotEmpty ? _bloc.listStockResponse[0].priceMin??0 : 0;
                            _dataListSearch[indexSelect].name =  (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : _dataListSearch[indexSelect].name;
                            _dataListSearch[indexSelect].codeUnit = value[8].toString();
                            _dataListSearch[indexSelect].nameUnit = value[9].toString();
                            _dataListSearch[indexSelect].note = value[10].toString();
                            _dataListSearch[indexSelect].jsonOtherInfo = value[11].toString();
                            _dataListSearch[indexSelect].heSo = value[12].toString();
                            _dataListSearch[indexSelect].idNVKD = value[13];
                            _dataListSearch[indexSelect].nameNVKD = value[14];
                            _dataListSearch[indexSelect].nuocsx = value[15];
                            _dataListSearch[indexSelect].quycach = value[16];
                            _dataListSearch[indexSelect].contentDvt = value[17];
                            _dataListSearch[indexSelect].dvt = value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() : _dataListSearch[indexSelect].dvt;
                            if(widget.inventoryControl == true){
                              _bloc.add(UpdateProductCountInventory(product: itemSelect));
                            }
                            else if(widget.addProductFromCheckIn == true){
                              _bloc.add(AddProductCountFromCheckIn(product: itemSelect));
                            }
                            else if(widget.addProductFromSaleOut == true){
                              Product production = Product(
                                  code: itemSelect.code,
                                name: (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : itemSelect.name,
                                  name2:itemSelect.name2,
                                  dvt:value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  itemSelect.dvt,
                                  description:itemSelect.descript,
                                  price: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice,
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
                                  allowDvt: itemSelect.allowDvt == true ? 0 : 1,
                                  kColorFormatAlphaB: itemSelect.kColorFormatAlphaB?.value,
                                  codeStock: value[2].toString(),
                                  nameStock: value[3].toString(),
                                  isSanXuat: (value[5] == 1 ? 1 : 0),
                                  isCheBien : (value[5] == 2 ? 1 : 0),
                                  giaSuaDoi : double.parse(value[4].toString()),
                                  giaGui : double.parse(value[6].toString()),
                                  priceMin: _bloc.listStockResponse.isNotEmpty ? _bloc.listStockResponse[0].priceMin??0 : 0,
                                  codeUnit: value[8].toString(),
                                  nameUnit: value[9].toString(),
                                  note: value[10].toString(),
                                  maThue: itemSelect.maThue,
                                  tenThue: itemSelect.tenThue,
                                  thueSuat: itemSelect.thueSuat,
                                  jsonOtherInfo: value[11].toString(),
                                  heSo: value[12].toString(),
                                  idNVKD: value[13],
                                  nameNVKD: value[14],
                                  nuocsx: value[15],
                                  quycach: value[16],
                                  contentDvt: itemSelect.contentDvt ?? value[17],
                                  applyPriceAfterTax: itemSelect.applyPriceAfterTax == true ? 1 : 0,
                                  discountByHand: itemSelect.discountByHand == true ? 1 : 0,
                                  discountPercentByHand: itemSelect.discountPercentByHand,
                                  ckntByHand: itemSelect.ckntByHand,
                                  priceOk: itemSelect.priceOk,
                                  woPrice: itemSelect.woPrice,
                                  woPriceAfter: itemSelect.woPriceAfter,
                              );
                              _bloc.add(AddProductSaleOutEvent(productItem: production));
                            }
                            else{
                              Product production = Product(
                                code: itemSelect.code,
                                name: (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : itemSelect.name,
                                name2:itemSelect.name2,
                                dvt:value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  itemSelect.dvt,
                                description:itemSelect.descript,
                                price: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice,
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
                                allowDvt: itemSelect.allowDvt == true ? 0 : 1,
                                kColorFormatAlphaB: itemSelect.kColorFormatAlphaB?.value,
                                codeStock: value[2].toString(),
                                nameStock: value[3].toString(),
                                isSanXuat: (value[5] == 1 ? 1 : 0),
                                isCheBien : (value[5] == 2 ? 1 : 0),
                                giaSuaDoi : double.parse(value[4].toString()),
                                giaGui : double.parse(value[6].toString()),
                                codeUnit: value[8].toString(),
                                nameUnit: value[9].toString(),
                                note: value[10].toString(),
                                jsonOtherInfo: value[11].toString(),
                                heSo: value[12].toString(),
                                idNVKD: value[13],
                                nameNVKD: value[14],
                                nuocsx: value[15],
                                quycach: value[16],
                                contentDvt: itemSelect.contentDvt ?? value[17],
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
                              _bloc.add(AddCartEvent(productItem: production));
                            }
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
                }
              }
            },
            child: BlocBuilder<CartBloc,CartState>(
                bloc: _bloc,
                builder: (BuildContext context, CartState state) {
                  return buildBody(context, state);
                })),
      ),
    );
  }


  buildBody(BuildContext context,CartState state){

    _dataListSearch = _bloc.searchResults;
    int length = _dataListSearch.length;
    if (state is SearchProductSuccess) {
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
                    bool exits = Const.kColorForAlphaB.any((element) => element.keyText == _dataListSearch[index].name?.substring(0,1).toUpperCase());
                    if(exits == true){
                      var itemCheck = Const.kColorForAlphaB.firstWhere((item) => item.keyText == _dataListSearch[index].name?.substring(0,1).toUpperCase());
                      if(itemCheck != null){
                        _dataListSearch[index].kColorFormatAlphaB = itemCheck.color;
                      }
                    }
                    if(listOrderInCart.isNotEmpty){
                      if(widget.viewUpdateOrder == false){
                        String code = _dataListSearch[index].code.toString().trim();
                        final valueItemCount = listOrderInCart.firstWhereOrNull((item) => item.code == code);
                        if (valueItemCount != null) {
                          _dataListSearch[index].count = valueItemCount.count;
                        }
                      }
                      else {
                        final valueItemCount = listOrderInCart.firstWhereOrNull((item) => item.code == _dataListSearch[index].code,);
                        if (valueItemCount != null) {
                          _dataListSearch[index].count = valueItemCount.count;
                        }
                      }
                    }
                    if(_dataListSearch[index].count == null){
                      _dataListSearch[index].count = 0;
                    }
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
                        _bloc.add(GetListStockEvent(
                            itemCode: _dataListSearch[index].code.toString(),
                            getListGroup: true,lockInputToCart: widget.lockInputToCart,
                            checkStockEmployee: widget.checkStockEmployee??false
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
                              Stack(
                                clipBehavior: Clip.none, children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: (_dataListSearch[index].kColorFormatAlphaB == null) ? Colors.blueGrey : Color(_dataListSearch[index].kColorFormatAlphaB!.value),
                                      borderRadius: const BorderRadius.all(Radius.circular(6),)
                                  ),
                                  child: Center(child: Text('${_dataListSearch[index].name?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
                                ),
                                Visibility(
                                  visible: _dataListSearch[index].discountMoney != null,
                                  child: Positioned(
                                    top: -6,left: -6,
                                    child: Container(
                                      height: 20,width: 20,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          color: Colors.red
                                      ),
                                      child: const Center(child: Text('S',style: TextStyle(color: Colors.white,fontSize: 10),)),
                                    ),
                                  ),
                                ),
                              ],
                              ),
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
                                              '${_dataListSearch[index].name}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 10,),
                                          Column(
                                            children: [
                                              // price: Const.isWoPrice == false ? _dataListSearch[index].price : _dataListSearch[index].woPrice,
                                              // priceAfter: Const.isWoPrice == false ?  _dataListSearch[index].priceAfter : _dataListSearch[index].woPriceAfter ,
                                              Const.isWoPrice == false ?
                                              (_dataListSearch[index].price == _dataListSearch[index].priceAfter && _dataListSearch[index].price! > 0) ? Container() : Text(
                                                double.parse((Const.currencyCode == "VND"
                                                    ?
                                                NumberFormat(Const.amountFormat).format(_dataListSearch[index].price??0)
                                                    :
                                                NumberFormat(Const.amountNtFormat).format(_dataListSearch[index].price??0)))
                                                    == 0 ? 'Giá đang cập nhật' : (Const.currencyCode == "VND"
                                                    ?
                                                '${Utils.formatMoneyStringToDouble(_dataListSearch[index].price??0)} ₫'
                                                    :
                                                '${Utils.formatMoneyStringToDouble(_dataListSearch[index].price??0)} ₫')
                                                ,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: grey, fontSize: 10, decoration: double.parse((Const.currencyCode == "VND"
                                                    ?
                                                NumberFormat(Const.amountFormat).format(_dataListSearch[index].price??0)
                                                    :
                                                NumberFormat(Const.amountNtFormat).format(_dataListSearch[index].price??0))) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                              )
                                                  :
                                              (_dataListSearch[index].woPrice == _dataListSearch[index].woPriceAfter && _dataListSearch[index].woPrice! > 0) ? Container() : Text(
                                                double.parse((Const.currencyCode == "VND"
                                                    ?
                                                NumberFormat(Const.amountFormat).format(_dataListSearch[index].woPrice??0)
                                                    :
                                                NumberFormat(Const.amountNtFormat).format(_dataListSearch[index].woPrice??0)))
                                                    == 0 ? 'Giá đang cập nhật' : (Const.currencyCode == "VND"
                                                    ?
                                                '${Utils.formatMoneyStringToDouble(_dataListSearch[index].woPrice??0)} ₫'
                                                    :
                                                '${Utils.formatMoneyStringToDouble(_dataListSearch[index].woPrice??0)} ₫')
                                                ,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: grey, fontSize: 10, decoration: double.parse((Const.currencyCode == "VND"
                                                    ?
                                                NumberFormat(Const.amountFormat).format(_dataListSearch[index].woPrice??0)
                                                    :
                                                NumberFormat(Const.amountNtFormat).format(_dataListSearch[index].woPrice??0))) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                              ),
                                              const SizedBox(height: 3,),
                                              Const.isWoPrice == false ?
                                              Visibility(
                                                visible: _dataListSearch[index].price! > 0,
                                                child: Text(
                                                  Const.currencyCode == "VND"
                                                      ?
                                                  '${Utils.formatMoneyStringToDouble(_dataListSearch[index].priceAfter??0)} ₫'
                                                      :
                                                  '${Utils.formatMoneyStringToDouble(_dataListSearch[index].priceAfter??0)} ₫',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(color: Color(
                                                      0xff067902), fontSize: 13,fontWeight: FontWeight.w700),
                                                ),
                                              )
                                                  :
                                              Visibility(
                                                visible: _dataListSearch[index].woPrice! > 0,
                                                child: Text(
                                                  Const.currencyCode == "VND"
                                                      ?
                                                  '${Utils.formatMoneyStringToDouble(_dataListSearch[index].woPriceAfter??0)} ₫'
                                                      :
                                                  '${Utils.formatMoneyStringToDouble(_dataListSearch[index].woPriceAfter??0)} ₫',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(color: Color(
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
                                                    '${_dataListSearch[index].code}',
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
                                                visible: _dataListSearch[index].discountPercent! > 0,
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
                                                        '${Utils.formatNumber(_dataListSearch[index].discountPercent!)}%',
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
                                              Text("${_dataListSearch[index].stockAmount?.toInt()??0}",
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
                      ),
                    );
                  },
                  itemCount: length
              ),
              Visibility(
                visible: state is EmptySearchProductState,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                ),
              ),
              Visibility(
                visible: state is CartLoading,
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
                          //_bloc.add(SearchProduct(Utils.convertKeySearch(_searchController.text),widget.idGroup!.toInt(), widget.itemGroupCode.toString(),widget.idCustomer.toString()));
                        },
                        controller: _searchController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,

                        onChanged: (text) {
                          onSearchDebounce.debounce(
                                () {
                              if(text.isNotEmpty){
                                _bloc.add(SearchProduct(Utils.convertKeySearch(_searchController.text),widget.listIdGroupProduct!, widget.itemGroupCode.toString(),widget.idCustomer.toString(),widget.isCheckStock,));
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
    _bloc.reset();
    super.dispose();
  }
}
