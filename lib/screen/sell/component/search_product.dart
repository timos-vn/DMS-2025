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
import '../../../model/network/response/list_stock_response.dart';
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
  
  // Multi-select state for Const.addProductionSameQuantity
  Set<String> selectedProductCodes = {}; // Track selected product codes
  Map<String, SearchItemResponseData> selectedProducts = {}; // Store full product data

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
            listener: (context, state) async {
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
                // Kiểm tra nếu đang trong chế độ multi-select (chọn nhiều sản phẩm)
                if (selectedProductCodes.isNotEmpty && selectedProductCodes.length >= 1) {
                  // Hiện dialog chọn kho + số lượng cho nhiều sản phẩm
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => _MultiSelectQuantityDialog(
                      selectedProducts: selectedProducts.values.toList(),
                      listStock: _bloc.listStockResponse,
                    ),
                  );
                  
                  if (result != null && result['quantity'] != null && result['quantity'] > 0) {
                    // Lưu kho đã chọn vào DataLocal để dùng cho các sản phẩm tiếp theo
                    if (result['stockCode'] != null && result['stockCode'].toString().isNotEmpty) {
                      DataLocal.codeStockMater = result['stockCode'].toString();
                      DataLocal.nameStockMater = result['stockName']?.toString() ?? '';
                    }
                    // Add all selected products to cart with the same quantity
                    _addMultipleProductsToCart(result['quantity']);
                  }
                  return;
                }
                
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
                            // Lấy giá từ popup nếu có sửa (value[4]), nếu không thì lấy giá gốc
                            double finalPrice = double.parse(value[4].toString());
                            Product production = Product(
                                code: itemSelect.code,
                                name: (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : itemSelect.name,
                                name2:itemSelect.name2,
                                dvt: value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  itemSelect.dvt,
                                description:itemSelect.descript,
                                price: finalPrice, // Sử dụng giá đã sửa từ popup
                                priceAfter: finalPrice, // Cập nhật giá sau cũng bằng giá đã sửa
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
                                originalPrice: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice, // Lưu giá gốc ban đầu
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
                              originalPrice: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice, // Lưu giá gốc ban đầu
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
                              // Lấy giá từ popup nếu có sửa (value[4]), nếu không thì lấy giá gốc
                              double finalPrice = double.parse(value[4].toString());
                              Product production = Product(
                                  code: itemSelect.code,
                                name: (value[7].toString().isNotEmpty && value[7].toString().replaceAll('null', '').isNotEmpty) ? value[7].toString() : itemSelect.name,
                                  name2:itemSelect.name2,
                                  dvt:value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  itemSelect.dvt,
                                  description:itemSelect.descript,
                                  price: finalPrice, // Sử dụng giá đã sửa từ popup
                                  priceAfter: finalPrice, // Cập nhật giá sau cũng bằng giá đã sửa
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
                                  originalPrice: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice, // Lưu giá gốc ban đầu
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
                                originalPrice: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice, // Lưu giá gốc ban đầu
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
                    Card(
                      semanticContainer: true,
                      margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Checkbox for multi-select with larger tap area
                            Visibility(
                              visible: true,
                              child: InkWell(
                                onTap: () {
                                  // Toggle selection
                                  setState(() {
                                    final productCode = _dataListSearch[index].code ?? '';
                                    if (selectedProductCodes.contains(productCode)) {
                                      selectedProductCodes.remove(productCode);
                                      selectedProducts.remove(productCode);
                                    } else {
                                      selectedProductCodes.add(productCode);
                                      selectedProducts[productCode] = _dataListSearch[index];
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(right: 4),
                                  child: Icon(
                                    selectedProductCodes.contains(_dataListSearch[index].code)
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: selectedProductCodes.contains(_dataListSearch[index].code)
                                        ? Colors.green
                                        : Colors.grey.shade400,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            // Product content - clickable area
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque, // Make entire area tappable including whitespace
                                onTap: (){
                                  itemSelect = _dataListSearch[index];
                                  indexSelect = index;
                                  _bloc.add(GetListStockEvent(
                                      itemCode: _dataListSearch[index].code.toString(),
                                      getListGroup: true,lockInputToCart: widget.lockInputToCart,
                                      checkStockEmployee: widget.checkStockEmployee??false
                                  ));
                                },
                                child: Row(
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
                                              '[${_dataListSearch[index].code.toString().trim()}] ${_dataListSearch[index].name}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              maxLines: 4,
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
                                      Visibility(
                                        visible: (_dataListSearch[index].thueSuat ?? 0.0) > 0,
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 5),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffdc2626).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xffdc2626).withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.account_balance,
                                                size: 14,
                                                color: Color(0xffdc2626),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Thuế: ${_formatTaxRate(_dataListSearch[index].thueSuat ?? 0)}%',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11,
                                                  color: Color(0xffdc2626),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Visibility(
                                              visible: _dataListSearch[index].discountPercent! > 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xffe53e3e), Color(0xffc53030)],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xffe53e3e).withOpacity(0.3),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.local_offer,
                                                      size: 12,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Text(
                                                      'SALE',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 9,
                                                        color: Colors.white,
                                                        letterSpacing: 0.5,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      '${Utils.formatNumber(_dataListSearch[index].discountPercent!)}%',
                                                      textAlign: TextAlign.left,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 9,
                                                        color: Colors.white,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Tồn:',
                                                style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
                                                textAlign: TextAlign.left,
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text("${_dataListSearch[index].stockAmount?.toInt()??0}",
                                                style:const TextStyle(color: blue, fontSize: 12, fontWeight: FontWeight.w600),
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
                          ],
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
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                        focusNode: focusNode,
                        onSubmitted: (text) {
                          //_bloc.add(SearchProduct(Utils.convertKeySearch(_searchController.text),widget.idGroup!.toInt(), widget.itemGroupCode.toString(),widget.idCustomer.toString()));
                        },
                        controller: _searchController,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        minLines: 1,
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
                            contentPadding: EdgeInsets.only(bottom: 15)
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _bloc.isShowCancelButton,
                    child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0,top:0,right: 8,bottom: 0),
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
          // Cart icon for multi-select
          Stack(
            children: [
              InkWell(
                onTap: () => _showMultiSelectQuantityPopup(),
                child: Container(
                  width: 40,
                  height: 50,
                  padding: const EdgeInsets.only(bottom: 10),
                  child: const Icon(
                    Icons.shopping_cart,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
              // Badge showing count
              if (selectedProductCodes.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${selectedProductCodes.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTaxRate(double taxRate) {
    // Nếu số là số nguyên thì hiển thị không có phần thập phân
    if (taxRate == taxRate.roundToDouble()) {
      return taxRate.round().toString();
    } else {
      // Nếu có phần thập phân thì hiển thị với 1 chữ số thập phân
      return taxRate.toStringAsFixed(1);
    }
  }

  // Show popup to input quantity for selected products
  void _showMultiSelectQuantityPopup() async {
    if (selectedProductCodes.isEmpty) {
      Utils.showCustomToast(context, Icons.warning, 'Vui lòng chọn ít nhất 1 sản phẩm');
      return;
    }

    // Lấy danh sách kho từ sản phẩm đầu tiên được chọn
    final firstProduct = selectedProducts.values.first;
    if (firstProduct.code != null) {
      _bloc.add(GetListStockEvent(
        itemCode: firstProduct.code.toString(),
        getListGroup: false,
        lockInputToCart: widget.lockInputToCart,
        checkStockEmployee: widget.checkStockEmployee ?? false,
      ));
    } else {
      Utils.showCustomToast(context, Icons.warning, 'Không thể lấy thông tin sản phẩm');
    }
  }

  String _resolveStockCodeForProduct(SearchItemResponseData product) {
    final productCode = _sanitizeStockValue(product.stockCode);
    if (productCode.isNotEmpty) return productCode;

    final fallback = _sanitizeStockValue(DataLocal.codeStockMater);
    if (fallback.isNotEmpty) return fallback;

    final defaultOrderStock = widget.listOrder.isNotEmpty
        ? _sanitizeStockValue(widget.listOrder.first.codeStock)
        : '';
    return defaultOrderStock;
  }

  String _resolveStockNameForProduct(SearchItemResponseData product) {
    final productName = _sanitizeStockValue(product.stockName);
    if (productName.isNotEmpty) return productName;

    final fallback = _sanitizeStockValue(DataLocal.nameStockMater);
    if (fallback.isNotEmpty) return fallback;

    final defaultOrderStockName = widget.listOrder.isNotEmpty
        ? _sanitizeStockValue(widget.listOrder.first.nameStock)
        : '';
    return defaultOrderStockName;
  }

  String _sanitizeStockValue(String? value) {
    if (value == null) return '';
    final sanitized = value.replaceAll('null', '').trim();
    return sanitized;
  }

  // Add multiple products to cart
  void _addMultipleProductsToCart(double quantity) async {
    int successCount = 0;
    
    for (var product in selectedProducts.values) {
      final resolvedStockCode = _resolveStockCodeForProduct(product);
      final resolvedStockName = _resolveStockNameForProduct(product);

      if (resolvedStockCode.isEmpty) {
        Utils.showCustomToast(
          context,
          Icons.warning_amber_outlined,
          'Vui lòng chọn kho trước khi thêm nhiều sản phẩm'
        );
        return;
      }

      product.stockCode = resolvedStockCode;
      product.stockName = resolvedStockName;

      // Debug log giá sản phẩm
      print('DEBUG: Product ${product.code} - price: ${product.price}, woPrice: ${product.woPrice}, giaSuaDoi: ${product.giaSuaDoi}, priceAfter: ${product.priceAfter}, woPriceAfter: ${product.woPriceAfter}');
      
      // Set quantity for each product
      product.count = quantity;
      
      // Add to cart logic based on screen type - KHÔNG GỌI GetListStockEvent để tránh show popup
      if (widget.inventoryControl == true) {
        // Inventory control logic
        _bloc.add(UpdateProductCountInventory(product: product));
      } else if (widget.addProductFromCheckIn == true) {
        // Check-in logic - use SearchItemResponseData directly
        _bloc.add(AddProductCountFromCheckIn(product: product));
      } else if (widget.addProductFromSaleOut == true) {
        // Sale out logic
        // Lấy giá từ các nguồn khả dụng: giaSuaDoi > 0 thì dùng, không thì dùng price/woPrice
        double basePrice = Const.isWoPrice == false ? (product.price ?? 0) : (product.woPrice ?? 0);
        double giaBan = product.giaSuaDoi > 0 ? product.giaSuaDoi : basePrice;
        double giaSauCK = Const.isWoPrice == false ? (product.priceAfter ?? 0) : (product.woPriceAfter ?? 0);
        double giaGuiBan = product.giaGui > 0 ? product.giaGui : giaSauCK;
        
        // Kiểm tra nếu giá = 0 thì dùng priceAfter/woPriceAfter
        if (giaBan <= 0) {
          giaBan = giaSauCK;
        }
        
        Product production = Product(
          code: product.code,
          sttRec0: product.sttRec0,
          name: product.name,
          name2: product.name2,
          dvt: product.dvt,
          description: product.descript,
          price: basePrice,
          priceAfter: giaSauCK,
          discountPercent: product.discountPercent,
          stockAmount: product.stockAmount,
          taxPercent: product.taxPercent,
          imageUrl: product.imageUrl ?? '',
          count: quantity,
          giaSuaDoi: giaBan, // Fix: Thêm giaSuaDoi - ưu tiên giaSuaDoi nếu có
          giaGui: giaGuiBan, // Thêm giaGui
          originalPrice: basePrice, // Lưu giá gốc ban đầu
          codeStock: resolvedStockCode,
          nameStock: resolvedStockName,
        );
        _bloc.add(AddProductSaleOutEvent(productItem: production));
      } else {
        // Regular cart logic
        // Lấy giá từ các nguồn khả dụng: giaSuaDoi > 0 thì dùng, không thì dùng price/woPrice
        double basePrice = Const.isWoPrice == false ? (product.price ?? 0) : (product.woPrice ?? 0);
        double giaBan = product.giaSuaDoi > 0 ? product.giaSuaDoi : basePrice;
        double giaSauCK = Const.isWoPrice == false ? (product.priceAfter ?? 0) : (product.woPriceAfter ?? 0);
        double giaGuiBan = product.giaGui > 0 ? product.giaGui : giaSauCK;
        
        // Kiểm tra nếu giá = 0 thì dùng priceAfter/woPriceAfter
        if (giaBan <= 0) {
          giaBan = giaSauCK;
        }
        
        Product production = Product(
          code: product.code,
          sttRec0: product.sttRec0,
          name: product.name,
          name2: product.name2,
          dvt: product.dvt,
          description: product.descript,
          price: basePrice,
          priceAfter: giaSauCK,
          discountPercent: product.discountPercent,
          stockAmount: product.stockAmount,
          taxPercent: product.taxPercent,
          imageUrl: product.imageUrl ?? '',
          count: quantity,
          isMark: 1,
          discountMoney: product.discountMoney ?? '0',
          discountProduct: product.discountProduct ?? '0',
          budgetForItem: product.budgetForItem ?? '',
          budgetForProduct: product.budgetForProduct ?? '',
          residualValueProduct: product.residualValueProduct ?? 0,
          residualValue: product.residualValue ?? 0,
          unit: product.unit ?? '',
          unitProduct: product.unitProduct ?? '',
          dsCKLineItem: product.maCk.toString(),
          giaSuaDoi: giaBan, // Fix: Thêm giaSuaDoi - ưu tiên giaSuaDoi nếu có
          giaGui: giaGuiBan, // Thêm giaGui
          originalPrice: basePrice, // Giá gốc ban đầu
          maThue: product.maThue, // Mã thuế
          tenThue: product.tenThue, // Tên thuế
          thueSuat: product.thueSuat, // Thuế suất (%)
          codeStock: resolvedStockCode,
          nameStock: resolvedStockName,
        );
        _bloc.add(AddCartEvent(productItem: production));
      }
      
      successCount++;
      
      // Small delay between adds to avoid overwhelming the BLoC
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Clear selections after adding
    setState(() {
      selectedProductCodes.clear();
      selectedProducts.clear();
    });

    Utils.showCustomToast(
      context,
      Icons.check_circle_outline,
      'Đã thêm $successCount sản phẩm vào giỏ hàng'
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bloc.reset();
    super.dispose();
  }
}

// Dialog để nhập số lượng chung cho nhiều sản phẩm
class _MultiSelectQuantityDialog extends StatefulWidget {
  final List<SearchItemResponseData> selectedProducts;
  final List<ListStore>? listStock;

  const _MultiSelectQuantityDialog({
    required this.selectedProducts,
    this.listStock,
  });

  @override
  State<_MultiSelectQuantityDialog> createState() => _MultiSelectQuantityDialogState();
}

class _MultiSelectQuantityDialogState extends State<_MultiSelectQuantityDialog> {
  final TextEditingController _quantityController = TextEditingController(text: '1');
  double quantity = 1;
  ListStore? selectedStock;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_cart, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Nhập số lượng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected products summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.selectedProducts.length} sản phẩm đã chọn',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                // List of selected products (max 3, then show "...")
                ...widget.selectedProducts.take(3).map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.name ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                if (widget.selectedProducts.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '...và ${widget.selectedProducts.length - 3} sản phẩm khác',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stock selection
          if (widget.listStock != null && widget.listStock!.isNotEmpty) ...[
            const Text(
              'Chọn kho:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ListStore>(
                  isExpanded: true,
                  value: selectedStock,
                  hint: const Text('Chọn kho', style: TextStyle(color: Colors.grey)),
                  items: widget.listStock!.map((stock) {
                    return DropdownMenuItem<ListStore>(
                      value: stock,
                      child: Text(
                        stock.tenKho ?? stock.maKho ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStock = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          // Quantity input
          const Text(
            'Số lượng cho tất cả sản phẩm:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Minus button
                InkWell(
                  onTap: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                        _quantityController.text = quantity.toInt().toString();
                      });
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: quantity > 1 ? Colors.red.shade50 : Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Icon(
                      Icons.remove,
                      color: quantity > 1 ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
                // TextField
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      final newQuantity = double.tryParse(value) ?? 1;
                      if (newQuantity > 0) {
                        setState(() {
                          quantity = newQuantity;
                        });
                      }
                    },
                  ),
                ),
                // Plus button
                InkWell(
                  onTap: () {
                    setState(() {
                      quantity++;
                      _quantityController.text = quantity.toInt().toString();
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (quantity <= 0) {
              Utils.showCustomToast(context, Icons.warning, 'Số lượng phải lớn hơn 0');
              return;
            }
            if (widget.listStock != null && widget.listStock!.isNotEmpty && selectedStock == null) {
              Utils.showCustomToast(context, Icons.warning, 'Vui lòng chọn kho');
              return;
            }
            Navigator.pop(context, {
              'quantity': quantity,
              'stockCode': selectedStock?.maKho ?? '',
              'stockName': selectedStock?.tenKho ?? '',
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Xác nhận',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
