import 'dart:async';
import 'dart:io';

import 'package:dms/model/network/request/order_create_checkin_request.dart';
import 'package:dms/model/network/response/contract_reponse.dart';
import 'package:dms/screen/sell/contract/component/detail_contract.dart';
import 'package:dms/screen/sell/contract/component/popup_update_quantity_contract.dart';
import 'package:dms/widget/InputDiscountPercent.dart';
import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/custom_dropdown.dart';
import 'package:dms/widget/custom_order.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/input_quantity_popup_order.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:dms/widget/text_field_widget2.dart';
import 'package:dms/widget/view_desc_discount.dart';
import 'package:dms/widget/ckn_discount_selection_dialog.dart';
import 'package:dms/widget/ckn_gift_product_selection_dialog.dart';
import 'package:dms/screen/sell/cart/widgets/discount_voucher_selection_sheet.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../custom_lib/view_only_image.dart';
import '../../../model/database/data_local.dart';
import '../../../model/entity/entity.dart';
import '../../../model/entity/product.dart';
import '../../../model/network/request/create_order_request.dart';
import '../../../model/network/request/update_order_request.dart';
import '../../../model/network/response/apply_discount_response.dart';
import '../../../model/network/response/data_default_response.dart';
import '../../../model/network/response/list_tax_response.dart';
import '../../../model/network/response/manager_customer_response.dart';
import '../../../model/network/response/search_list_item_response.dart';
import '../../../model/network/response/setting_options_response.dart';
import '../../../model/network/response/gift_product_list_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../customer/search_customer/search_customer_screen.dart';
import '../component/input_address_popup.dart';
import '../component/search_product.dart';
import '../component/search_vv_hd.dart';
import 'cart_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import 'component/custom_order.dart';
import 'component/quantity_info_box.dart';

class CartScreen extends StatefulWidget {
  final String? sttRec;
  final bool? viewUpdateOrder;
  final List<Product>? listOrder;
  final String? currencyCode;
  final bool? viewDetail;
  final String? idCustomer;
  final String? codeCustomer;
  final String? nameCustomer;
  final String? phoneCustomer;
  final String? addressCustomer;
  final String? nameStore;
  final String? codeStore;
  final String? dateOrder;
  final String? itemGroupCode;
  final List<String>? listIdGroupProduct;
  final bool orderFromCheckIn;
  final bool? addInfoCheckIn;
  final String title;
  final String? description;
  final bool loadDataLocal;
  final String? sttRectHD; // Truyền về stt_rec Hợp đồng của bên MPV để khi lưu đơn sẽ ánh xạ ngược về hợp đồng nào
  final bool? isContractCreateOrder;
  final ContractItem? contractMaster;

  const CartScreen({Key? key,this.sttRec,this.addInfoCheckIn,this.viewUpdateOrder,this.listOrder,this.currencyCode,this.viewDetail,this.nameCustomer,this.idCustomer,
    this.phoneCustomer,this.addressCustomer,this.nameStore,this.codeStore,this.codeCustomer,this.itemGroupCode,this.listIdGroupProduct, this.dateOrder,
    required this.orderFromCheckIn, required this.title, this.description, required this.loadDataLocal, this.sttRectHD, this.isContractCreateOrder = false,this.contractMaster}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin{
  late CartBloc _bloc;
  late TabController tabController;
  List<IconData> listIcons = [EneftyIcons.receipt_edit_outline,EneftyIcons.personalcard_outline,EneftyIcons.bill_outline];
  String? dateTransfer;String? timeTransfer; late int indexValuesTax;
  final nameCompanyController = TextEditingController();final noteCompanyController = TextEditingController();final mstController = TextEditingController();
  final addressCompanyController = TextEditingController();final nameCompanyFocus = FocusNode();
  final mstFocus = FocusNode();final addressFocus = FocusNode();final noteFocus = FocusNode();
  final nameCustomerController = TextEditingController();final addressCustomerController = TextEditingController();
  final phoneCustomerController = TextEditingController();final nameCustomerFocus = FocusNode();
  final addressCustomerFocus = FocusNode();final phoneCustomerFocus = FocusNode();
  final noteController = TextEditingController();final addressController = TextEditingController();
  String nameStore = '';String codeStore = '';
  late SearchItemResponseData itemSelect;
  late Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  int start = 3;bool waitingLoad = false;
  bool _isProcessing = false; // Biến để ngăn chặn double-tap
  
  // CKN flow state
  String? _pendingDiscountName;
  double? _pendingMaxQuantity;
  List<ListCkMatHang>? _pendingDiscountItems;
  String? _pendingDiscountType; // 'CKN' or 'CKTDTH'
  
  // Flag to re-apply HH after API reload (từ CKG check/uncheck)
  bool _needReapplyHHAfterReload = false;
  
  // Loading dialog state
  bool _isLoadingGiftProducts = false;
  
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {
          waitingLoad = false;
          setState(() {});
          timer.cancel();
        } else {
          start--;
        }
      },
    );
  }
  String listItem = '';String listQty = '';String listPrice = '';String listMoney = '';
  late int indexSelect;late int indexSelectGift;bool gift = false;bool lockChooseStore = false;
  final imagePicker = ImagePicker();
  Future getImage()async {
    PersistentNavBarNavigator.pushNewScreen(context, screen: const CameraCustomUI()).then((value){
      if(value != null){
        XFile image = value;
      setState(() {
          if(image != null){
            start = 2;waitingLoad  = true;
        _bloc.listFileInvoice.add(File(image.path));
        ListImageInvoice itemImage = ListImageInvoice(
            pathBase64: Utils.base64Image(File(image.path)).toString(),
            nameImage: image.name
        );
        _bloc.listFileInvoiceSave.add(itemImage);
        startTimer();
          }
      });
      }
    });
  }
  Future<void> getDiscountProduct(String key)async {

    if(key != 'Second'){
      _bloc.listPromotion = '';
      DataLocal.listCKVT = '';
      _bloc.listOrder.clear();
    }
    listItem = '';
    listQty = '';
    listPrice = '';
    listMoney = '';

    _bloc.listCkMatHang.clear();
    _bloc.listCkTongDon.clear();
    _bloc.totalProductBuy = 0;
    _bloc.totalProductView = 0;
    for (var element in _bloc.listProductOrderAndUpdate) {
      if(element.isMark == 1){
        _bloc.totalProductBuy += 1;
        _bloc.totalProductView += element.count!;
        double x = ((/*element.giaGui > 0 ? element.giaGui :*/ element.giaSuaDoi) * element.count!);
        listItem = listItem == '' ? element.code.toString() : '$listItem,${element.code.toString()}';
        listQty = listQty == '' ? element.count.toString() : '$listQty,${element.count.toString()}';
        listPrice = listPrice == ''
            ?
        (/*element.giaGui > 0 ? element.giaGui :*/ element.giaSuaDoi.toString() )
            :
        '$listPrice,${(/*element.giaGui > 0 ? element.giaGui :*/ element.giaSuaDoi.toString())}';
        listMoney = listMoney == '' ? x.toString() : '$listMoney,${x.toString()}';
      }
      else if(element.isMark == 0){
        // double x = (element.price! * element.count!);
        listItem = listItem == '' ? element.code.toString() : '$listItem,${element.code.toString()}';
        listQty = listQty == '' ? element.count.toString() : '$listQty,${element.count.toString()}';
        listPrice = listPrice == '' ?  '0' : '$listPrice,0';
        listMoney = listMoney == '' ? '0' : '$listMoney,0';
      }
    }
    if(_bloc.totalProductBuy == _bloc.listProductOrderAndUpdate.length){
      _bloc.checkAllProduct = true;
    }else{
      _bloc.checkAllProduct = false;
    }
    if(listItem.isNotEmpty){
      _bloc.add(GetListItemApplyDiscountEvent(
        listCKVT: DataLocal.listCKVT,
        listPromotion: _bloc.listPromotion,
        listItem: listItem,
        listQty: listQty,
        listPrice: listPrice,
        listMoney: listMoney,
        warehouseId: codeStore,
        customerId: _bloc.codeCustomer.toString(),
        keyLoad: (key == '' && key.isEmpty) ? 'First' : key,
      ));
    }
  }
  void calculationDiscount(){
    if(DataLocal.listProductGift.isNotEmpty){
      _bloc.totalProductGift = 0;
      for (var element in DataLocal.listProductGift) {
        _bloc.totalProductGift += element.count!;
        if(Const.enableViewPriceAndTotalPriceProductGift == true){
          _bloc.totalMoneyProductGift = _bloc.totalMoneyProductGift + (
              ((element.price.toString().isNotEmpty && element.price.toString() != 'null') ? element.price! : 0)
                  *
                  ((element.count.toString().isNotEmpty && element.count.toString() != 'null') ? element.count! : 0)
          );
        }
      }
    }
    if(widget.orderFromCheckIn == false){
      if(_bloc.listProductOrder.isNotEmpty) {
        _bloc.listProductOrder.clear();
      }
      _bloc.listProductOrder = widget.listOrder!;
      if(Const.stockList.isNotEmpty){
        _bloc.storeCode = Const.stockList[_bloc.storeIndex].stockCode;
      }
      _bloc.add(GetListProductFromDB(addOrderFromCheckIn: widget.orderFromCheckIn, getValuesTax: false,key: ''));

    }
    else{
      if(_bloc.listProductOrder.isNotEmpty) {
        _bloc.listProductOrder.clear();
      }
      _bloc.listProductOrder = widget.listOrder!;
      if(Const.stockList.isNotEmpty){
        _bloc.storeCode = Const.stockList[_bloc.storeIndex].stockCode;
      }
      _bloc.add(GetListProductFromDB(addOrderFromCheckIn: widget.orderFromCheckIn, getValuesTax: false,key: ''));
    }
    if(widget.viewUpdateOrder == true){
      int indexTransaction = 0;
      if(Const.listTransactionsOrder.isNotEmpty && DataLocal.nameTransition.isNotEmpty){
        indexTransaction = Const.listTransactionsOrder.indexWhere((element) => element.tenGd.toString().contains(DataLocal.nameTransition));
      }

      _bloc.add(PickTransactionName(indexTransaction,DataLocal.nameTransition,DataLocal.transactionYN));
      if(Const.chooseAgency == true && _bloc.showSelectAgency == true){
        _bloc.nameAgency = '';
        _bloc.codeAgency = '';
      }
      _bloc.storeCode = DataLocal.maDL;
      if(Const.stockList.isNotEmpty){
        for (var element in Const.stockList) {
          if(element.stockCode.toString().trim() == DataLocal.maDL.toString().trim()){
            _bloc.add(PickStoreName(Const.stockList.indexOf(element)));
            break;
          }
        }
      }
      if(Const.useTax == true){
        if(DataLocal.listTax.isNotEmpty){
          for (var element in DataLocal.listTax) {
            if(element.maThue.toString().trim() == DataLocal.codeTax.toString().trim()){
              indexValuesTax = DataLocal.listTax.indexOf(element);
              DataLocal.indexValuesTax = indexValuesTax;
              DataLocal.taxPercent = element.thueSuat!.toDouble();
              DataLocal.taxCode = element.maThue.toString().trim();
              _bloc.add(PickTaxAfter(DataLocal.indexValuesTax,DataLocal.taxPercent));
              break;
            }
          }
        }
      }
      _bloc.idVv = DataLocal.maVV;
      _bloc.nameVv = (DataLocal.tenVV.isNotEmpty && DataLocal.tenVV != 'null' && DataLocal.tenVV.toString().replaceAll('null', '').isNotEmpty) ? DataLocal.tenVV : '' ;
      _bloc.idHd = (DataLocal.maHD.isNotEmpty && DataLocal.maHD != 'null' && DataLocal.maHD.toString().replaceAll('null', '').isNotEmpty) ? DataLocal.maHD : '' ;
      _bloc.nameHd = DataLocal.tenHD;
      if(Const.chooseTypePayment == true){
        if(DataLocal.typePaymentList.isNotEmpty){
          for (var element in DataLocal.typePaymentList) {
            if(element.toString().trim() == DataLocal.typePayment.toString().trim()){
              _bloc.add(PickTypePayment(DataLocal.typePaymentList.indexOf(element), element));
              if(element.toString().contains('Công nợ')){
                _bloc.showDatePayment = true;
                if(DataLocal.dueDatePayment.toString().replaceAll('null', '').isNotEmpty){
                  DataLocal.datePayment = Utils.safeFormatDate(DataLocal.dueDatePayment);
                      // Jiffy.parse(DataLocal.dueDatePayment).format(pattern: 'dd-MM-yyyy');
                }
              }
              break;
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = CartBloc(context);

    tabController = TabController(vsync: this, length: listIcons.length);
    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
      });
    });
    DataLocal.dateEstDelivery = Utils.parseDateToString(DateTime.now(), Const.DATE_FORMAT_2);
    if(widget.viewUpdateOrder == true){
      _bloc.showWarning = false;
    }
    _bloc.allowed = true;
    _bloc.add(GetPrefs());
    if(Const.listTransactionsOrder.isNotEmpty){
      DataLocal.transactionCode = Const.listTransactionsOrder[0].maGd.toString();
      if(Const.woPrice == true){
        if(Const.isWoPrice == true){
          DataLocal.transactionCode = '2';
        }else{
          DataLocal.transactionCode = '1';
        }
      }
    }
    noteController.text = (widget.description.toString().isNotEmpty && widget.description.toString() != '' && widget.description.toString() != 'null') ? widget.description.toString() : '';
    DataLocal.noteSell = noteController.text;
    if(widget.codeCustomer.toString().trim().replaceAll('null', '').isNotEmpty){
      nameCustomerController.text = widget.nameCustomer.toString();
      phoneCustomerController.text = widget.phoneCustomer.toString();
      addressCustomerController.text = widget.addressCustomer.toString();
      _bloc.customerName = widget.nameCustomer;
      _bloc.codeCustomer = widget.codeCustomer;
      _bloc.addressCustomer = widget.addressCustomer;
      _bloc.phoneCustomer = widget.phoneCustomer;
    }
    if(Const.isDefaultCongNo && Const.chooseTypePayment){
      _bloc.showDatePayment = true;
      DataLocal.valuesTypePayment = "Công nợ";
      _bloc.add(PickTypePayment(DataLocal.typePaymentList.indexOf("Công nợ"),  DataLocal.valuesTypePayment));
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc,CartState>(
      listener: (context,state){
        if(state is GetPrefsSuccess){
          if((Const.isVvHd == true || Const.isVv == true || Const.isHd == true)){ // && (DataLocal.listVv.isEmpty || DataLocal.listHd.isEmpty)
            _bloc.add(GetListVVHD());
          }
          else{
            calculationDiscount();
          }
          _bloc.add(PickInfoCustomer(
            customerName: (DataLocal.infoCustomer.customerName.toString().isNotEmpty && DataLocal.infoCustomer.customerName.toString() != 'null') ? DataLocal.infoCustomer.customerName : _bloc.customerName,
            phone: (DataLocal.infoCustomer.phone.toString().isNotEmpty && DataLocal.infoCustomer.phone.toString() != 'null') ? DataLocal.infoCustomer.phone : _bloc.phoneCustomer,
            address: (DataLocal.infoCustomer.address.toString().isNotEmpty && DataLocal.infoCustomer.address.toString() != "null") ? DataLocal.infoCustomer.address : _bloc.addressCustomer,
            codeCustomer: (DataLocal.infoCustomer.customerCode.toString().isNotEmpty && DataLocal.infoCustomer.customerCode.toString() != 'null') ? DataLocal.infoCustomer.customerCode : _bloc.codeCustomer,
          ));
        }
        else if(state is GetListVvHdSuccess){
          calculationDiscount();
        }
        else if(state is DeleteAllProductEventSuccess){
          _bloc.add(GetListProductFromDB(addOrderFromCheckIn: widget.orderFromCheckIn, getValuesTax: false,key: ''));
        }
        else if(state is CartFailure){
          _isProcessing = false; // Reset flag khi có lỗi
          showDialog(
              context: context,
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: CustomOrderError(
                    iconData: MdiIcons.shopping,
                    title: 'Cảnh báo đặt đơn',
                    content:  state.error.toString().trim().replaceAll('Úi, null', '\nCó lỗi xảy ra'),
                  ),
                );
              });
        }
        else if(state is PickTransactionSuccess){
          if(state.showSelectAgency == false && Const.chooseAgency == true){
            _bloc.chooseAgencyCode = false;
            _bloc.add(PickInfoAgency(typeDiscount: '',codeAgency: '', nameAgency: '',cancelAgency: true));
          }
        }
        else if(state is GetListProductFromDBSuccess){
          if(_bloc.listProductOrderAndUpdate.isNotEmpty){
            getDiscountProduct(state.key);
          }
          else {
            _bloc.listItemOrder.clear();
            _bloc.listOrder.clear();
            _bloc.listCkTongDon.clear();
            _bloc.listCkMatHang.clear();
            _bloc.totalMoney = 0;
            _bloc.totalDiscount = 0;
            _bloc.totalPayment = 0;
            Const.listKeyGroupCheck = '';
            Const.listKeyGroup = '';
          }

        }
        else if(state is PickTaxAfterSuccess  || state is PickTaxBeforeSuccess){
          _bloc.chooseTax = true;
          _bloc.add(UpdateListOrder());
        }
        else if(state is CalculatorDiscountSuccess){
          _bloc.add(UpdateListOrder());
        }
        else if(state is PickTaxBeforeSuccess){
          _bloc.chooseTax = true;
        }
        else if(state is ApplyDiscountSuccess){
          // ✅ DEBUG: Check prices BEFORE any processing
          if(state.keyLoad == 'Second') {
            print('💰 === API Response Received (keyLoad=Second) ===');
            print('💰 listOrder.length = ${_bloc.listOrder.length}');
            for (var item in _bloc.listOrder) {
              if (item.gifProduct != true) {
                print('💰 Product: ${item.code}');
                print('    giaSuaDoi=${item.giaSuaDoi} (giá gốc)');
                print('    priceAfter=${item.priceAfter} (giá sau CK)');
                print('    discountPercent=${item.discountPercent}');
                print('    count=${item.count}');
                print('    → Total hiển thị: ${(item.priceAfter ?? 0) * (item.count ?? 0)}');
                print('    → Expected: ${(item.giaSuaDoi ?? 0) * (item.count ?? 0) * (1 - (item.discountPercent ?? 0) / 100)}');
              }
            }
          }
          
          // ✅ FIX: Re-apply HH gifts after API reload (từ CKG check/uncheck)
          if(state.keyLoad == 'Second' && _needReapplyHHAfterReload) {
            print('💰 Re-applying HH gifts after API reload');
            _applyAllHH(_bloc.selectedHHIds);
            _needReapplyHHAfterReload = false;
            
            // ✅ Đảm bảo totalProductGift được cập nhật đúng (bao gồm CKN, CKTDTH, HH, manual gifts)
            _bloc.totalProductGift = 0;
            for (var gift in DataLocal.listProductGift) {
              _bloc.totalProductGift += gift.count ?? 0;
            }
            print('💰 Updated totalProductGift after API reload: ${_bloc.totalProductGift} (from ${DataLocal.listProductGift.length} gifts)');
            
            // ✅ DIRECT SYNC: Copy listOrder → listProductOrderAndUpdate
            print('💰 Direct sync: listOrder → listProductOrderAndUpdate');
            _syncListOrderToUI();
            
            // Force UI rebuild
            setState(() {});
          }
          
          // ✅ Đảm bảo totalProductGift được cập nhật đúng khi keyLoad == 'Second' (kể cả khi không có _needReapplyHHAfterReload)
          if(state.keyLoad == 'Second') {
            _bloc.totalProductGift = 0;
            for (var gift in DataLocal.listProductGift) {
              _bloc.totalProductGift += gift.count ?? 0;
            }
            print('💰 Updated totalProductGift after API response: ${_bloc.totalProductGift} (from ${DataLocal.listProductGift.length} gifts)');
            setState(() {});
          }
          
          if(widget.viewUpdateOrder == true){
            _bloc.totalProductGift = 0;
            for (var element in DataLocal.listProductGift) {
              _bloc.totalProductGift += element.count!;
            }
          }
          if(state.keyLoad == 'First'){
            _syncListOrderToUI();
            setState(() {});
          }
          else if(state.keyLoad != 'First' && Const.freeDiscount == true && _bloc.chooseTax == true){
            _bloc.add(CalculatorDiscountEvent(addOnProduct: false,reLoad: true, addTax: true));
            _bloc.chooseTax = false;
          }
          else{
            if(Const.chooseAgency == true && _bloc.showSelectAgency == true){
              // _bloc.nameAgency = DataLocal.tenDL;
              // _bloc.codeAgency = DataLocal.maDL;
              _bloc.chooseAgencyCode = true;
              _bloc.add(PickInfoAgency(typeDiscount: DataLocal.typeDiscount,codeAgency: DataLocal.maDL, nameAgency: DataLocal.tenDL,cancelAgency: false));
            }
            if(widget.viewUpdateOrder == true && Const.freeDiscount == true){
              if(_bloc.listOrder.isNotEmpty){
                for (int index = 0; index < _bloc.listOrder.length ; index++) {
                  _bloc.listOrder[index].discountByHand = true;
                  double sl = _bloc.listOrder[index].count!;
                  double price = /*_bloc.allowTaxPercent == true ?  _bloc.listOrder[index].priceAfterTax! :*/ _bloc.listOrder[index].price ?? 0;
                  _bloc.listOrder[index].discountPercentByHand = _bloc.listOrder[index].discountPercent??0;
                  _bloc.totalPayment = _bloc.totalPayment - (price * sl * _bloc.listOrder[index].discountPercentByHand )/100;
                  _bloc.listOrder[index].ckntByHand = (price * sl * _bloc.listOrder[index].discountPercentByHand )/100;
                  _bloc.listOrder[index].priceAfter2 = price;//_bloc.listOrder[index].priceAfter;
                  _bloc.listOrder[index].priceAfter = ((/*_bloc.listOrder[index].giaGui > 0 ? _bloc.listOrder[index].giaGui :*/
                      _bloc.listOrder[index].giaSuaDoi) - (((/*_bloc.listOrder[index].giaGui > 0 ? _bloc.listOrder[index].giaGui :*/
                      _bloc.listOrder[index].giaSuaDoi) * 1) * _bloc.listOrder[index].discountPercentByHand)/100);
                  Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã áp dụng chiết khấu tự do');
                }
                //_bloc.add(CalculatorDiscountEvent(addOnProduct: false,reLoad: true, addTax: false));
              }
            }
            _bloc.add(CalculatorDiscountEvent(addOnProduct: false,reLoad: true, addTax: false));
          }
          if(Const.autoAddDiscount == true && Const.freeDiscount == true && state.keyLoad != 'First'){
            _bloc.add(AutoDiscountEvent());
          }
          if(state.keyLoad != 'First' && widget.loadDataLocal == true){
            if(DataLocal.transaction.maGd != null && DataLocal.transaction.tenGd.toString() != "null"&& DataLocal.transaction.tenGd.toString().isNotEmpty){
              _bloc.add(PickTransactionName(Const.listTransactionsOrder.indexOf(DataLocal.transaction),DataLocal.transaction.tenGd.toString(),DataLocal.transaction.chonDLYN??0));
            }
            if(DataLocal.indexValuesTax >=0){
              _bloc.add(PickTaxAfter(DataLocal.indexValuesTax,DataLocal.taxPercent));
            }
            if(DataLocal.valuesTypePayment.isNotEmpty && DataLocal.valuesTypePayment != 'null' && DataLocal.valuesTypePayment != ''){
              _bloc.add(PickTypePayment(DataLocal.typePaymentList.indexOf(DataLocal.valuesTypePayment),  DataLocal.valuesTypePayment));
            }
            _bloc.firstLoadUpdateOrder = 0;
          }
          _bloc.add(CalculatorTaxForItemEvent());

        }
        else if(state is GetListItemUpdateOrderSuccess){
          _bloc.add(CheckDisCountWhenUpdateEvent(widget.sttRec.toString(),true,codeCustomer: widget.codeCustomer.toString(),codeStore: widget.codeStore.toString()));
        }
        else if(state is PickInfoCustomerSuccess){
          if(_bloc.customerName.toString().trim() != 'null' && _bloc.customerName.toString().trim().isNotEmpty){
            nameCustomerController.text = _bloc.customerName.toString();
            phoneCustomerController.text = _bloc.phoneCustomer.toString();
            addressCustomerController.text = _bloc.addressCustomer.toString();
            _bloc.listDiscount.clear();
            print(_bloc.listOrder.length);
            getDiscountProduct('First');
          }
        }
        else if(state is CreateOrderSuccess){
          _isProcessing = false; // Reset flag khi thành công
          Const.numberProductInCart = 0;
          Const.listKeyGroupCheck = '';
          Const.listKeyGroup = '';
          DataLocal.listObjectDiscount.clear();
          DataLocal.listOrderDiscount.clear();
          DataLocal.infoCustomer = ManagerCustomerResponseData();
          DataLocal.transactionCode = "";
          DataLocal.transaction = ListTransaction();
          DataLocal.indexValuesTax = -1;
          DataLocal.taxPercent = 0;
          DataLocal.taxCode = '';
          DataLocal.valuesTypePayment = '';
          DataLocal.datePayment = '';DataLocal.noteSell = '';
          // Reset all discount selections
          _bloc.selectedCknProductCode = null;
          _bloc.selectedCknSttRecCk = null;
          _bloc.selectedDiscountGroup = null;
          _bloc.selectedCknGroups.clear();
          _bloc.listCkn.clear();
          _bloc.hasCknDiscount = false;
          _bloc.selectedCkgIds.clear();
          _bloc.listCkg.clear();
          _bloc.hasCkgDiscount = false;
          _bloc.selectedHHIds.clear();
          _bloc.listHH.clear();
          _bloc.hasHHDiscount = false;
          _bloc.selectedCktdttIds.clear();
          _bloc.listCktdtt.clear();
          _bloc.hasCktdttDiscount = false;
          _bloc.selectedCktdthGroups.clear();
          _bloc.listCktdth.clear();
          _bloc.hasCktdthDiscount = false;
          _bloc.add(DeleteAllProductFromDB());
          Utils.showCustomToast(context, Icons.check_circle_outline, widget.title.toString().contains('Đặt hàng') ? 'Yeah, Tạo đơn thành công' : 'Yeah, Cập nhật đơn thành công');

        }
        else if(state is CreateOrderFromCheckInSuccess){
          DataLocal.listOrderProductIsChange = false;
          DataLocal.listOrderCalculatorDiscount.clear();
          DataLocal.listProductGift.clear();
          Const.listKeyGroupCheck = '';
          Const.listKeyGroup = '';
          DataLocal.listObjectDiscount.clear();
          DataLocal.listOrderDiscount.clear();
          DataLocal.infoCustomer = ManagerCustomerResponseData();
          DataLocal.transactionCode = "";
          DataLocal.transaction = ListTransaction();
          DataLocal.indexValuesTax = -1;
          DataLocal.taxPercent = 0;
          DataLocal.taxCode = '';
          DataLocal.valuesTypePayment = '';
          DataLocal.datePayment = '';
          DataLocal.noteSell = '';
          // Reset all discount selections
          _bloc.selectedCknProductCode = null;
          _bloc.selectedCknSttRecCk = null;
          _bloc.selectedDiscountGroup = null;
          _bloc.selectedCknGroups.clear();
          _bloc.listCkn.clear();
          _bloc.hasCknDiscount = false;
          _bloc.selectedCkgIds.clear();
          _bloc.listCkg.clear();
          _bloc.hasCkgDiscount = false;
          _bloc.selectedHHIds.clear();
          _bloc.listHH.clear();
          _bloc.hasHHDiscount = false;
          _bloc.selectedCktdttIds.clear();
          _bloc.listCktdtt.clear();
          _bloc.hasCktdttDiscount = false;
          _bloc.selectedCktdthGroups.clear();
          _bloc.listCktdth.clear();
          _bloc.hasCktdthDiscount = false;
          Utils.showCustomToast(context, Icons.check_circle_outline, widget.title.toString().contains('Đặt hàng') ? 'Yeah, Tạo đơn thành công' : 'Yeah, Cập nhật đơn thành công');
          Navigator.of(context).pop(Const.REFRESH);
        }
        else if(state is DeleteAllProductFromDBSuccess){
          DataLocal.listOrderCalculatorDiscount.clear();
          DataLocal.listProductGift.clear();
          Const.listKeyGroupCheck = '';
          Const.listKeyGroup = '';
          DataLocal.listObjectDiscount.clear();
          DataLocal.listOrderDiscount.clear();
          DataLocal.infoCustomer = ManagerCustomerResponseData();
          DataLocal.transactionCode = "";
          DataLocal.transaction = ListTransaction();
          DataLocal.indexValuesTax = -1;
          DataLocal.taxPercent = 0;
          DataLocal.taxCode = '';
          DataLocal.valuesTypePayment = '';
          DataLocal.datePayment = '';DataLocal.noteSell = '';
          // Reset all discount selections
          _bloc.selectedCknProductCode = null;
          _bloc.selectedCknSttRecCk = null;
          _bloc.selectedDiscountGroup = null;
          _bloc.selectedCknGroups.clear();
          _bloc.listCkn.clear();
          _bloc.hasCknDiscount = false;
          _bloc.selectedCkgIds.clear();
          _bloc.listCkg.clear();
          _bloc.hasCkgDiscount = false;
          _bloc.selectedHHIds.clear();
          _bloc.listHH.clear();
          _bloc.hasHHDiscount = false;
          _bloc.selectedCktdttIds.clear();
          _bloc.listCktdtt.clear();
          _bloc.hasCktdttDiscount = false;
          _bloc.selectedCktdthGroups.clear();
          _bloc.listCktdth.clear();
          _bloc.hasCktdthDiscount = false;
          // Utils.showCustomToast(context, Icons.check_circle_outline, widget.title.toString().contains('Đặt hàng') ? 'Yeah, Tạo đơn thành công' : 'Yeah, Cập nhật đơn thành công');
          // Nếu tạo đơn từ hợp đồng, quay về detail_contract với thông tin refresh
          if (widget.isContractCreateOrder == true) {
            Navigator.of(context).pop({'refresh': true});
          }else{
            Navigator.of(context).pop(Const.REFRESH);
          }
        }
        else if(state is PickStoreNameSuccess){}
        else if(state is UpdateProductCountOrderFromCheckInSuccess){
          getDiscountProduct('Second');
        }
        else if(state is GrantCameraPermission){
          getImage();
        }
        else if(state is GetListStockEventSuccess){
          if(gift == false){
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return InputQuantityPopupOrder(
                    title: 'Cập nhật thông tin',
                    quantity: itemSelect.count??0,
                    quantityStock: _bloc.ton13,
                    listDvt:   itemSelect.contentDvt.toString().split(',').toList(),
                    inventoryStore: false,
                    findStock: true,
                    listStock: _bloc.listStockResponse,
                    allowDvt: itemSelect.allowDvt,
                    price: itemSelect.giaSuaDoi,
                    giaGui: itemSelect.giaGui,
                    typeValues: itemSelect.isSanXuat == true ? 'Sản xuất' : itemSelect.isCheBien == true ? 'Chế biến' :'Thường',
                    nameProduction: itemSelect.name.toString(),
                    codeProduction: itemSelect.code.toString(), listObjectJson: itemSelect.jsonOtherInfo.toString(),
                    updateValues: true, listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh,
                    nuocsx: _bloc.listOrder[indexSelect].nuocsx.toString(),quycach: _bloc.listOrder[indexSelect].quycach.toString(),
                    idNVKD: _bloc.listOrder[indexSelect].idNVKD.toString(),
                    nameNVKD: _bloc.listOrder[indexSelect].nameNVKD.toString(),
                    tenThue:  _bloc.listOrder[indexSelect].tenThue,thueSuat:  _bloc.listOrder[indexSelect].thueSuat,
                  );
                }).then((value){
              if(value != null){
                if(double.parse(value[0].toString()) > 0){
                  String codeStockOld = itemSelect.stockCode.toString().trim();
                  _bloc.listOrder[indexSelect].count = double.parse(value[0].toString());
                  _bloc.listOrder[indexSelect].stockCode = (value[2].toString().isNotEmpty && !value[3].toString().contains('Chọn kho xuất hàng')) ? value[2].toString() : _bloc.listOrder[indexSelect].stockCode;
                  _bloc.listOrder[indexSelect].stockName = (value[3].toString().isNotEmpty && !value[3].toString().contains('Chọn kho xuất hàng')) ? value[3].toString() : _bloc.listOrder[indexSelect].stockName;
                  _bloc.listOrder[indexSelect].isSanXuat = (value[5] == 1 ? true : false);
                  _bloc.listOrder[indexSelect].isCheBien = (value[5] == 2 ? true : false);
                  _bloc.listOrder[indexSelect].giaSuaDoi = double.parse(value[4].toString());
                  // _bloc.listOrder[indexSelect].price = Const.editPrice == true ? ( _bloc.listOrder[indexSelect].price! >= 0 ?  _bloc.listOrder[indexSelect].price : double.parse(value[6].toString()))
                  //     :  _bloc.listOrder[indexSelect].price;
                  _bloc.listOrder[indexSelect].giaGui = double.parse(value[6].toString());
                  _bloc.listOrder[indexSelect].priceMin = _bloc.listStockResponse.isNotEmpty ? _bloc.listStockResponse[0].priceMin??0 : 0;
                  _bloc.listOrder[indexSelect].name =  (value[7].toString().isNotEmpty && value[7].toString() != 'null') ? value[7].toString() : itemSelect.name;
                  _bloc.listOrder[indexSelect].note = value[10].toString();
                  _bloc.listOrder[indexSelect].jsonOtherInfo = value[11].toString();
                  _bloc.listOrder[indexSelect].heSo = value[12].toString();
                  _bloc.listOrder[indexSelect].idNVKD = value[13].toString();
                  _bloc.listOrder[indexSelect].nameNVKD = value[14].toString();
                  _bloc.listOrder[indexSelect].nuocsx = value[15].toString();
                  _bloc.listOrder[indexSelect].quycach = value[16].toString();
                  _bloc.listOrder[indexSelect].contentDvt = value[17].toString();
                  _bloc.listOrder[indexSelect].allowDvt =  itemSelect.allowDvt;

                  _bloc.listOrder[indexSelect].dvt = value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() : _bloc.listOrder[indexSelect].dvt ;
                  bool editPrices = false;
                  if(itemSelect.price != double.parse(value[4].toString())){
                    _bloc.listOrder[indexSelect].priceAfter = double.parse(value[4].toString());
                    _bloc.listOrder[indexSelect].price = double.parse(value[4].toString());
                    if(DataLocal.listCKVT.isNotEmpty && DataLocal.listCKVT.contains('${itemSelect.sttRecCK.toString().trim()}-${itemSelect.code.toString().trim()}') == true && itemSelect.maCkOld.toString().trim() != 'CTKMTH'){
                      DataLocal.listCKVT = DataLocal.listCKVT.replaceAll('${itemSelect.sctGoc.toString().trim()}-${itemSelect.code.toString().trim()}', '');
                    }
                    editPrices = true;
                  }
                  Product production = Product(
                      code: itemSelect.code,
                      sttRec0: itemSelect.sttRec0,
                      name: (value[7].toString().isNotEmpty && value[7].toString() != 'null') ? value[7].toString() : itemSelect.name,
                      name2:itemSelect.name2,
                      dvt: value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  itemSelect.dvt,
                      description:itemSelect.descript,
                      price: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice,
                      priceAfter:  itemSelect.priceAfter ,
                      discountPercent:itemSelect.discountPercent,
                      stockAmount:itemSelect.stockAmount,
                      taxPercent:itemSelect.taxPercent,
                      imageUrl:itemSelect.imageUrl ?? '',
                      count:itemSelect.count,
                      isMark: itemSelect.isMark,
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
                      contentDvt: itemSelect.contentDvt ?? value[17],
                      kColorFormatAlphaB: itemSelect.kColorFormatAlphaB?.value,
                      codeStock: (value[2].toString().isNotEmpty && !value[3].toString().contains('Chọn kho xuất hàng')) ? value[2].toString() : itemSelect.stockCode,
                      nameStock: (value[3].toString().isNotEmpty && !value[3].toString().contains('Chọn kho xuất hàng')) ? value[3].toString() : itemSelect.stockName,
                      editPrice: editPrices == true ? 1 : 0,
                      isSanXuat: (value[5] == 1 ? 1 : 0),
                      isCheBien: (value[5] == 2 ? 1 : 0),
                      giaSuaDoi: double.parse(value[4].toString()),
                      giaGui: double.parse(value[6].toString()),
                      priceMin: _bloc.listStockResponse.isNotEmpty ? _bloc.listStockResponse[0].priceMin??0 : 0,
                      note: value[10].toString(),
                      jsonOtherInfo: value[11].toString(),
                      heSo: value[12].toString(),
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

                  _bloc.add(UpdateProductCount(
                    index: indexSelect,
                    count: double.parse(value[0].toString()),
                    addOrderFromCheckIn:  widget.orderFromCheckIn,
                    product: production,
                    stockCodeOld: codeStockOld,
                  ));
                }
              }
            });
          }
          else{
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return InputQuantityPopupOrder(
                    title: 'Cập nhật SL tặng',
                    quantity: DataLocal.listProductGift[indexSelectGift].count??0,
                    quantityStock: DataLocal.listProductGift[indexSelectGift].stockAmount??0,
                    listDvt: DataLocal.listProductGift[indexSelectGift].contentDvt.toString().split(',').toList(),inventoryStore: false,
                    findStock: true,
                    listStock: _bloc.listStockResponse,
                    allowDvt: DataLocal.listProductGift[indexSelectGift].allowDvt,
                    nameProduction: DataLocal.listProductGift[indexSelectGift].name.toString(),
                    price: Const.isWoPrice == false ?  DataLocal.listProductGift[indexSelectGift].price??0 : DataLocal.listProductGift[indexSelectGift].woPrice??0,
                    codeProduction: DataLocal.listProductGift[indexSelectGift].code.toString(),
                    listObjectJson: DataLocal.listProductGift[indexSelectGift].jsonOtherInfo.toString(),
                    updateValues: true, listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh,nuocsx: '',quycach: '',
                    tenThue:  _bloc.listOrder[indexSelectGift].tenThue,thueSuat:  _bloc.listOrder[indexSelectGift].thueSuat,
                  );
                }).then((value){
              if(double.parse(value[0].toString()) > 0){
                setState(() {
                  _bloc.totalProductGift = _bloc.totalProductGift - DataLocal.listProductGift[indexSelectGift].count!;
                  DataLocal.listProductGift[indexSelectGift].count = double.parse(value[0].toString());
                  DataLocal.listProductGift[indexSelectGift].stockCode = (value[2].toString());
                  DataLocal.listProductGift[indexSelectGift].stockName = (value[3].toString());
                  DataLocal.listProductGift[indexSelectGift].name = (value[7].toString().isNotEmpty && value[7].toString() != 'null') ? value[7].toString() :  DataLocal.listProductGift[indexSelectGift].name;
                  DataLocal.listProductGift[indexSelectGift].jsonOtherInfo =  value[11];
                  DataLocal.listProductGift[indexSelectGift].heSo =  value[12];
                  DataLocal.listProductGift[indexSelectGift].dvt =  value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() : DataLocal.listProductGift[indexSelectGift].dvt;
                  _bloc.totalProductGift = _bloc.totalProductGift + DataLocal.listProductGift[indexSelectGift].count!;
                });
              }
            });
          }
        }
        else if(state is CheckIsMarkProductSuccess){
          _bloc.totalPayment = (_bloc.totalMoney - _bloc.totalDiscount) + _bloc.totalTax;
        }
        else if(state is CheckAllIsMarkProductSuccess){
          if(state.isMarkAll == true){
            _bloc.listOrder.clear();
            _bloc.listItemOrder.clear();
            _bloc.listCkMatHang.clear();
            _bloc.listCkTongDon.clear();
            _bloc.listPromotion = '';
            _bloc.totalMoney = 0;
            _bloc.totalDiscount = 0;
            _bloc.totalProductBuy = 0;
            _bloc.totalProductView = 0;
            _bloc.add(GetListProductFromDB(addOrderFromCheckIn: false, getValuesTax: false,key: ''));
          }else{
            _bloc.totalMoney = 0;
            _bloc.totalDiscount = 0;
            _bloc.totalPayment = 0;
          }
        }
        else if(state is AutoDiscountEventSuccess || state is AddDiscountForProductEventSuccess){
          _bloc.add(CalculatorDiscountEvent(addOnProduct: false,reLoad: true, addTax: false));
        }
        else if(state is AddOrDeleteProductGiftSuccess){
          // Refresh UI when gift products are added/removed
          setState(() {});
        }
        else if(state is GetGiftProductListSuccess){
          // ✅ Ẩn loading dialog
          _hideLoadingDialog();
          
          // API đã trả về danh sách hàng tặng, show popup step 2
          if(_pendingDiscountName != null && _pendingMaxQuantity != null && _pendingDiscountItems != null){
            _showGiftProductSelectionPopup(
              discountName: _pendingDiscountName!,
              maxQuantity: _pendingMaxQuantity!,
              discountItems: _pendingDiscountItems!,
              discountType: _pendingDiscountType ?? 'CKN', // Default to CKN for backward compatibility
            );
            // Clear pending state
            _pendingDiscountName = null;
            _pendingMaxQuantity = null;
            _pendingDiscountItems = null;
            _pendingDiscountType = null;
          }
        }
        else if(state is CartFailure){
          // ✅ Ẩn loading dialog khi có lỗi (nếu đang loading)
          _hideLoadingDialog();
        }
      },
      bloc: _bloc,
      child: BlocBuilder<CartBloc,CartState>(
        bloc: _bloc,
        builder: (BuildContext context,CartState state){
          return Stack(
            children: [
              buildScreen(context, state),
              Visibility(
                visible: state is CartLoading,
                child: const PendingAction(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildScreen(BuildContext context,CartState state){
    return Scaffold(
      backgroundColor: grey_100,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildAppBar(),
          Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.0),
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2)),
                      ),
                      child: TabBar(
                        controller: tabController,
                        unselectedLabelColor: Colors.grey.withOpacity(0.8),
                        labelColor: Colors.red,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                        isScrollable: false,
                        indicatorPadding: const EdgeInsets.all(0),
                        indicatorColor: Colors.red,
                        dividerColor: Colors.red,automaticIndicatorColorAdjustment: true,
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                        indicator: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                style: BorderStyle.solid,
                                color: Colors.red,
                                width: 2
                            ),
                          ),
                        ),
                        tabs: List<Widget>.generate(listIcons.length, (int index) {
                          return Tab(
                            icon: Icon( listIcons[index]),
                          );
                        }),
                        onTap: (index){
                          // setState(() {
                          //   tabIndex = index;
                          // });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          color: grey_100,
                          child: TabBarView(
                              controller: tabController,
                              children: List<Widget>.generate(listIcons.length, (int index) {
                                for (int i = 0; i <= listIcons.length; i++) {
                                  if(index == 0){
                                  return buildListProduction();
                                  }else if(index == 1){
                                  return buildInfo();
                                  }else{
                                return buildBill();
                                  }
                                }
                                return const Text('');
                              })),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 70,width: double.infinity,
                    padding: const EdgeInsets.only(left: 16,right: 16,bottom: 20,top: 8),
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(16),topLeft: Radius.circular(16))
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total price',style: TextStyle(color: grey,fontSize: 12.5),),
                            const SizedBox(height: 4,),
                            Text('\$${Utils.formatMoneyStringToDouble(_bloc.totalPayment)}',style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
                          ],
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                            child: GestureDetector(
                            onTap: (){
                              if(tabController.index == 0 || tabController.index == 1){
                                Future.delayed(const Duration(milliseconds: 200)).then((value)=>tabController.animateTo((tabController.index + 1) % 10));
                                tabIndex = tabController.index + 1;
                              }else{
                                if(Const.chooseStockBeforeOrder == true){
                                  if(_bloc.listOrder.isNotEmpty) {
                                    for (var element in _bloc.listOrder) {
                                      if(Const.typeProduction == true && int.parse((DataLocal.transactionCode.toString().trim().isNotEmpty && DataLocal.transactionCode.toString().trim() != '') ? DataLocal.transactionCode.toString().trim() : "0") == 2){
                                        lockChooseStore = true;
                                        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Vui lòng chọn kho cho SP bạn bán');
                                        break;
                                      }
                                      if(Const.typeProduction == false && (element.stockCode.toString().isEmpty || element.stockCode == '' || element.stockCode == 'null')){
                                        lockChooseStore = true;
                                        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Vui lòng chọn kho cho SP bạn bán');
                                        break;
                                      }
                                      else{
                                        lockChooseStore = false;
                                      }
                                    }
                                  }
                                  if(DataLocal.listProductGift.isNotEmpty && Const.chooseStockBeforeOrderWithGiftProduction == true && Const.lockStockInItemGift == false) {
                                    for (var element in DataLocal.listProductGift) {
                                      if(element.stockCode.toString().isEmpty || element.stockCode == '' || element.stockCode == 'null'){
                                        lockChooseStore = true;
                                        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Vui lòng chọn kho cho SP bạn tặng');
                                        break;
                                      }else{
                                        lockChooseStore = false;
                                      }
                                    }
                                  }
                                  if(lockChooseStore == false){
                                    logic();
                                  }
                                }
                                else {
                                  logic();
                                }
                              }
                            },
                                child: Container(
                                  // margin: EdgeInsets.only(bottom: 10),
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(24)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text((tabIndex != 2) ? 'Tiếp tục' : 'Đặt hàng',style: const TextStyle(color: Colors.white),),
                                      const SizedBox(width: 8,),
                                      Icon((tabIndex != 2) ? Icons.arrow_right_alt_outlined : FluentIcons.cart_16_filled,color: Colors.white,)
                                    ],
                          ),
                        )
                            )
                        )
                      ],
                    ),
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }

  void logic(){
    // Ngăn chặn double-tap
    if (_isProcessing) {
      print('DEBUG: Đang xử lý, bỏ qua tap');
      return;
    }
    
    _isProcessing = true;
    
    // Tự động reset flag sau 1 giây để tránh trường hợp bị kẹt
    Timer(const Duration(seconds: 1), () {
      if (_isProcessing) {
        print('DEBUG: Tự động reset _isProcessing sau 1 giây');
        _isProcessing = false;
      }
    });
    
    if (Const.chooseAgency == true){
      if(_bloc.transactionName.contains('Đại lý')){
        if(_bloc.codeAgency.toString() != '' && _bloc.codeAgency.toString() != 'null'){
          createOrder();
        }else{
          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn chưa chọn Đại lý kìa');
          _isProcessing = false; // Reset flag khi có lỗi
        }
      }else{
        createOrder();
      }
    }
    else{
      if(Const.chooseTypePayment == true){
        if(_bloc.showDatePayment == true){
          if(DataLocal.datePayment.toString().isNotEmpty && DataLocal.datePayment.toString() != 'null'){
            createOrder();
          }else{
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn chưa chọn ngày thanh toán kìa');
            _isProcessing = false; // Reset flag khi có lỗi
          }
        }else{
          createOrder();
        }
      }else{
        createOrder();
      }
    }
  }

  void createOrder(){
    if(!Utils.isEmpty(_bloc.listProductOrderAndUpdate)){
      if(_bloc.codeCustomer != null && _bloc.codeCustomer != ''){
        // Kiểm tra sttRectHD khi isContractCreateOrder = true
        if(widget.isContractCreateOrder == true && (widget.sttRectHD == null || widget.sttRectHD!.isEmpty)){
          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Lỗi: sttRectHD không được để trống khi tạo đơn từ hợp đồng');
          return;
        }
        
        // Kiểm tra danh sách sản phẩm có hợp lệ không
        for (var item in _bloc.listProductOrderAndUpdate) {
          if (item.code == null || item.code!.isEmpty) {
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Lỗi: Mã sản phẩm không được để trống');
            return;
          }
          if (item.count == null || item.count! <= 0) {
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Lỗi: Số lượng sản phẩm phải lớn hơn 0');
            return;
          }
        }
        if(widget.viewUpdateOrder == true){
          ItemTotalMoneyUpdateRequestData val = ItemTotalMoneyUpdateRequestData();
          val.preAmount = _bloc.totalMNProduct.toString();
          val.discount = _bloc.totalMNDiscount.toString();
          val.totalMNProduct = _bloc.totalMNProduct.toString();
          val.totalMNDiscount = _bloc.totalMNDiscount.toString();
          val.totalMNPayment = _bloc.totalMNPayment.toString();
          if(Const.chooseStatusToCreateOrder == true){
            showDialog(
                context: context,
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: CustomOrderComponent(
                      iconData: MdiIcons.shopping,
                      title: 'Xác nhận đơn hàng',
                      content: Const.chooseStatusToCreateOrder == true
                          ?
                      'Chọn trạng thái đơn trước khi tạo mới' : 'Kiểm tra kỹ thông tin trước khi đặt hàng nhé',
                    ),
                  );
                }).then((value)async{
              if(value != null){
                if(!Utils.isEmpty(value) && value[0] == 'Yeah'){
                  int valuesStatus = 0;
                  valuesStatus = int.parse(value[1].toString());
                  _bloc.add(UpdateOderEvent(
                    sttRec: widget.sttRec,
                    code: _bloc.codeCustomer,
                    storeCode: !Utils.isEmpty(_bloc.storeCode.toString()) ? _bloc.storeCode :  Const.stockList[0].stockCode,
                    currencyCode: widget.currencyCode,
                    listOrder: _bloc.listProductOrderAndUpdate,
                    totalMoney: val,
                    dateEstDelivery: DataLocal.dateEstDelivery,
                    dateOrder: widget.dateOrder.toString(),
                    valuesStatus: valuesStatus,
                    nameCompany: nameCompanyController.text,
                    mstCompany: mstController.text,
                    addressCompany: addressCompanyController.text,
                    noteCompany: noteCompanyController.text,
                    sttRectHD: widget.sttRectHD
                  ));
                }
              }
            });
          }
          else{
            _bloc.add(UpdateOderEvent(
              sttRec: widget.sttRec,
              code: _bloc.codeCustomer,
              storeCode: !Utils.isEmpty(_bloc.storeCode.toString()) ? _bloc.storeCode : Const.stockList.isNotEmpty ? Const.stockList[0].stockCode : '',
              currencyCode: widget.currencyCode,
              listOrder: _bloc.listProductOrderAndUpdate,
              totalMoney: val,
              dateEstDelivery: DataLocal.dateEstDelivery,
              dateOrder: widget.dateOrder.toString(),
              valuesStatus:0,
              nameCompany: nameCompanyController.text,
              mstCompany: mstController.text,
              addressCompany: addressCompanyController.text,
              noteCompany: noteCompanyController.text,
              sttRectHD: widget.sttRectHD
            ));
          }
        }
        else{
          ItemTotalMoneyRequestData val = ItemTotalMoneyRequestData();
          val.preAmount = _bloc.totalMNProduct.toString();
          val.discount = _bloc.totalMNDiscount.toString();
          val.totalMNProduct = _bloc.totalMNProduct.toString();
          val.totalMNDiscount = _bloc.totalMNDiscount.toString();
          val.totalMNPayment = _bloc.totalMNPayment.toString();
          if(Const.chooseStatusToCreateOrder == true){
            showDialog(
                context: context,
                builder: (context) {
                  return PopScope(
                    canPop: false,
                    child: CustomOrderComponent(
                      iconData: MdiIcons.shopping,
                      title: 'Xác nhận đơn hàng',
                      content: 'Chọn trạng thái đơn trước khi tạo mới',
                    ),
                  );
                }).then((value)async{
              if(value != null){
                if(!Utils.isEmpty(value) && value[0] == 'Yeah'){
                  int valuesStatus = 0;
                  valuesStatus = int.parse(value[1].toString());
                  _bloc.add(CreateOderEvent(
                    code: _bloc.codeCustomer,
                    storeCode: !Utils.isEmpty(_bloc.storeCode.toString()) ? _bloc.storeCode :  Const.stockList[0].stockCode,
                    currencyCode: widget.currencyCode,
                    listOrder: _bloc.listProductOrderAndUpdate,
                    totalMoney: val,
                    comment:noteController.text,
                    dateEstDelivery: DataLocal.dateEstDelivery,
                    valuesStatus: valuesStatus,
                    nameCompany: nameCompanyController.text,
                    mstCompany: mstController.text,
                    addressCompany: addressCompanyController.text,
                    noteCompany: noteCompanyController.text,
                      sttRectHD: widget.sttRectHD
                  ));
                }
              }
            });
          }
          else{
            _bloc.add(CreateOderEvent(
              code: _bloc.codeCustomer,
              storeCode: !Utils.isEmpty(_bloc.storeCode.toString()) ? _bloc.storeCode :  Const.stockList[0].stockCode,
              currencyCode: widget.currencyCode,
              listOrder: _bloc.listProductOrderAndUpdate,
              totalMoney: val,
              dateEstDelivery: DataLocal.dateEstDelivery,
              comment:noteController.text,
              valuesStatus:0,
              nameCompany: nameCompanyController.text,
              mstCompany: mstController.text,
              addressCompany: addressCompanyController.text,
              noteCompany: noteCompanyController.text,
                sttRectHD: widget.sttRectHD
            ));
          }
        }
      }
      else{
        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Thông tin Khách hàng không được để trống');
      }
    }
    else{
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Giỏ hàng của bạn đâu có gì?');
    }
  }

  int tabIndex = 0;

  buildListProduction(){
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
            child: Text('Hãy kiểm tra lại danh sách sản phẩm trước khi lên đơn hàng nhé bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5,color: Colors.grey),),
          ),
          buildListCart(), 
          Utils.buildLine(),
          Visibility(
              visible: Const.discountSpecial == true,
              child: buildListProductGiftCart()),
        ],
      ),
    );
  }

  buildListCart(){
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10,left: 10,right: 14),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        //color: Colors.blue,
                        width: 22,
                        height: 22,
                        child: Transform.scale(
                          scale: 1,
                          alignment: Alignment.topLeft,
                          child: Checkbox(
                            value: true,
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
                            }), onChanged: (bool? value) {  },
                          ),
                        ),
                      ),
                      const SizedBox(width: 6,),
                      Text('Sản phẩm (${Utils.formatQuantity(_bloc.totalProductView)})',style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                const SizedBox(width: 20,),
                  Visibility(
                  // Hiển thị khi có ít nhất 1 loại chiết khấu (CKN, CKG, HH, CKTDTT, CKTDTH)
                  visible: (_bloc.hasCknDiscount || _bloc.hasCkgDiscount || _bloc.hasHHDiscount || _bloc.hasCktdttDiscount || _bloc.hasCktdthDiscount) && _bloc.listOrder.isNotEmpty,
                  child: InkWell( 
                      onTap: () => _showDiscountFlow(), 
                      child:const Padding(
                        padding:  EdgeInsets.only(top: 0),
                        child: Icon(Icons.card_giftcard_rounded,size: 20,color: Colors.green,),
                      )),
                ),
                Visibility(
                  visible: Const.isVv == true && _bloc.listOrder.isNotEmpty,
                  child: InkWell(
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return WillPopScope(
                                onWillPop: () async => false,
                                child: const CustomQuestionComponent(
                                  showTwoButton: true,
                                  iconData: Icons.warning_amber_outlined,
                                  title: 'Chương trình bán hàng',
                                  content: 'Thêm CTBH cho tất cả các sản phẩm được tích chọn',
                                ),
                              );
                            }).then((value)async{
                          if(value != null){
                            if(!Utils.isEmpty(value) && value == 'Yeah'){
                              showModalBottomSheet(
                                  context: context,
                                  isDismissible: true,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
                                  ),
                                  backgroundColor: Colors.white,
                                  builder: (builder){
                                    return buildPopupVvHd();
                                  }
                              ).then((value){
                                if(value != null){
                                  if(value[0] == 'ReLoad' && value[1] != '' && value[1] !='null'){
                                    _bloc.add(AddAllHDVVProductEvent(
                                      idVv: _bloc.idVv,
                                      idHd: _bloc.idHd,
                                      nameVv: _bloc.nameVv,
                                      nameHd: _bloc.nameHd,
                                      idHdForVv: _bloc.idHdForVv,
                                    ));
                                  }
                                }
                              });
                            }
                          }
                        });
                      },
                      child:const Padding(
                        padding:  EdgeInsets.only(left: 20),
                        child: Icon(Icons.description,size: 20,color: Colors.red,),
                      )),
                ),

                Visibility(
                  visible: Const.enableAutoAddDiscount == true && _bloc.listOrder.isNotEmpty,
                  child: InkWell(
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return WillPopScope(
                                onWillPop: () async => false,
                                child: const CustomQuestionComponent(
                                  showTwoButton: true,
                                  iconData: Icons.warning_amber_outlined,
                                  title: 'Thêm chiết khấu',
                                  content: 'Thêm chiết khấu cho tất cả các sản phẩm được tích chọn',
                                ),
                              );
                            }).then((value)async{
                          if(value != null){
                            if(!Utils.isEmpty(value) && value == 'Yeah'){
                              showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (context) {
                                    return const InputDiscountPercent(
                                      title: 'Vui lòng nhập tỉ lệ chiết khấu',
                                      subTitle: 'Vui lòng nhập tỉ lệ chiết khấu',
                                      typeValues: '%',
                                      percent: 0,
                                    );
                                  }).then((value){
                                if(value[0] == 'BACK'){
                                  Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã áp dụng chiết khấu tự do');
                                  _bloc.add(AddDiscountForProductEvent(discountValues: double.parse(value[1].toString())));
                                }
                              });
                            }
                          }
                        });
                      },
                      child:const Padding(
                        padding:  EdgeInsets.only(left: 20),
                        child: Icon(Icons.discount,size: 20,color: Colors.red,),
                      )),
                ),

                Visibility(
                  visible: _bloc.listOrder.isNotEmpty,
                  child: InkWell(
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return WillPopScope(
                                onWillPop: () async => false,
                                child: const CustomQuestionComponent(
                                  showTwoButton: true,
                                  iconData: Icons.warning_amber_outlined,
                                  title: 'Xoá sản phẩm',
                                  content: 'Bạn sẽ xoá tất cả sản phẩm trong giỏ hàng',
                                ),
                              );
                            }).then((value)async{
                          if(value != null){
                            if(!Utils.isEmpty(value) && value == 'Yeah'){
                              _bloc.listItemOrder.clear();
                              _bloc.listCkMatHang.clear();
                              _bloc.listCkTongDon.clear();
                              _bloc.listPromotion = '';
                              _bloc.totalMoney = 0;
                              _bloc.totalDiscount = 0;
                              _bloc.totalPayment = 0;
                              _bloc.totalProductBuy = 0;
                              _bloc.totalProductView = 0;
                              DataLocal.listObjectDiscount.clear();
                              DataLocal.listOrderDiscount.clear();
                              DataLocal.infoCustomer = ManagerCustomerResponseData();
                              DataLocal.transactionCode = "";
                              DataLocal.transaction = ListTransaction();
                              DataLocal.indexValuesTax = -1;
                              DataLocal.taxPercent = 0;
                              DataLocal.taxCode = '';
                              DataLocal.valuesTypePayment = '';
                              DataLocal.datePayment = '';DataLocal.noteSell = '';
                              DataLocal.listCKVT = '';
                              // Reset CKN selection
                              _bloc.selectedCknProductCode = null;
                              _bloc.selectedCknSttRecCk = null;
                              _bloc.listCkn.clear();
                              _bloc.hasCknDiscount = false;
                              _bloc.add(DeleteAllProductEvent());
                            }
                          }
                        });
                      },
                      child:Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete_forever, size: 20),
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8,),
          Visibility(
            visible: _bloc.listOrder.isNotEmpty,
            child: buildListViewProduct(),
          ),
          Visibility(
            visible: _bloc.listOrder.isEmpty,
            child: const SizedBox(
                height: 100,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Úi, Không có gì ở đây cả.',style: TextStyle(color: Colors.black,fontSize: 11.5)),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Gợi ý: Bấm nút ',style: TextStyle(color: Colors.blueGrey,fontSize: 10.5)),
                        Icon(Icons.search_outlined,color: Colors.blueGrey,size: 18,),
                        Text(' để thêm sản phẩm của bạn',style: TextStyle(color: Colors.blueGrey,fontSize: 10.5)),
                      ],
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  buildListProductGiftCart(){
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0,left: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.cubeOutline,color: mainColor,),
                    const SizedBox(width: 6,),
                    Text('Sản phẩm tặng (${_bloc.totalProductGift})',style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                  ],
                ),
                Visibility(
                  visible: Const.discountSpecialAdd == true,
                  child: InkWell(
                    onTap: (){
                      PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProductScreen(
                          idCustomer: widget.codeCustomer.toString(), /// Chỉ có thêm tồn kho ở check-in mới thêm idCustomer
                          currency: widget.currencyCode ,
                          viewUpdateOrder: false,
                          listIdGroupProduct: widget.listIdGroupProduct,
                          itemGroupCode: '',//widget.itemGroupCode, -> Salonzo bỏ tìm theo nhóm mặt hàng khi thêm hàng tặng, cho phép tìm được tất cả sản phẩm
                          inventoryControl: false,
                          addProductFromCheckIn: false,
                          addProductFromSaleOut: false,
                          giftProductRe: true,
                          lockInputToCart: true,checkStockEmployee: Const.checkStockEmployee,
                          listOrder: _bloc.listProductOrderAndUpdate, backValues: false, isCheckStock: false,),withNavBar: false).then((value){
                        if(value[0] == 'Yeah'){
                          SearchItemResponseData item = value[1] as SearchItemResponseData;
                          item.gifProductByHand = true;
                          if(Const.enableViewPriceAndTotalPriceProductGift != true){
                            item.price = 0;
                            item.priceAfter = 0;
                          }
                          _bloc.totalProductGift += item.count!;
                          _bloc.add(AddOrDeleteProductGiftEvent(true,item));
                        }
                      });
                    },
                    child: const SizedBox(
                      height: 30,
                      width: 50,
                      child: Icon(Icons.addchart_outlined,color: Colors.black,size: 20,),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8,),
          Visibility(
            visible: DataLocal.listProductGift.isNotEmpty,
            child: buildListViewProductGift(),
          ),
          Visibility(
            visible: DataLocal.listProductGift.isEmpty,
            child: const SizedBox(
                height: 100,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Úi, Không có gì ở đây cả.',style: TextStyle(color: Colors.black,fontSize: 11.5)),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Gợi ý: Bấm nút ',style: TextStyle(color: Colors.blueGrey,fontSize: 10.5)),
                        Icon(Icons.addchart_outlined,color: Colors.blueGrey,size: 16,),
                        Text(' để thêm sản phẩm tặng của bạn',style: TextStyle(color: Colors.blueGrey,fontSize: 10.5)),
                      ],
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  buildPopupVvHd(){
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25)
          )
      ),
      margin: MediaQuery.of(context).viewInsets,
      child: FractionallySizedBox(
        heightFactor: 0.65,
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
                        padding: const EdgeInsets.only(left: 8,right: 0,bottom: 0),
                        children: [
                          Visibility(
                            visible: Const.isVv == true || Const.isVvHd == true,
                            child: SizedBox(
                              height:35,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      _bloc.idVv = '';
                                      _bloc.nameVv = 'Chọn Chương trình bán hàng';
                                      _bloc.idHdForVv = '';
                                      myState(() {});
                                    },
                                    child: SizedBox(
                                      height: 35,width: 30,
                                      child: Center(child: Icon(MdiIcons.deleteSweepOutline,size: 20,color: Colors.black,)),
                                    ),
                                  ),
                                  const SizedBox(width: 3,),
                                  const Text('Chương trình bán hàng',style: TextStyle(color: Colors.black,fontSize: 13),),
                                  const SizedBox(width: 10,),
                                  DataLocal.listVv.isEmpty
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
                                              width: 320,
                                              child: Scrollbar(
                                                child: ListView.builder(
                                                  padding: const EdgeInsets.only(top: 10,),
                                                  itemCount: DataLocal.listVv.length,
                                                  itemBuilder: (context, index) {
                                                    final trans = DataLocal.listVv[index].tenVv.toString().trim();
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
                                                            DataLocal.listVv[index].maVv.toString().trim().length > 10 ?
                                                            '${DataLocal.listVv[index].maVv.toString().trim().substring(0,10)}...' : DataLocal.listVv[index].maVv.toString().trim(),
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle:const Divider(height: 1,),
                                                      onTap: () {
                                                        _bloc.idVv = DataLocal.listVv[index].maVv.toString().trim();
                                                        _bloc.nameVv = DataLocal.listVv[index].tenVv.toString().trim();
                                                        _bloc.idHdForVv = DataLocal.listVv[index].maDmhd.toString().trim();
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
                                          child: Text(_bloc.nameVv.toString() == '' ? 'Chọn Chương trình bán hàng' : _bloc.nameVv.toString(),style: const TextStyle(color: subColor,fontSize: 12.5)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      PersistentNavBarNavigator.pushNewScreen(context, screen: const SearchVVHDScreen(isVV: true),withNavBar: false).then((value){
                                        if(value != '' && value[0] == 'Accept'){
                                          _bloc.idVv = value[1];
                                          _bloc.nameVv = value[2];
                                          _bloc.idHdForVv = value[3];
                                          myState(() {});
                                        }
                                      });
                                    },
                                    child: const SizedBox(
                                      height: 35,width: 45,
                                      child: Center(child: Icon(Icons.search,size: 20,color: Colors.black,)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 8,bottom: 12),
                            child: Divider(),
                          ),
                          Visibility(
                            visible: Const.isHd == true || Const.isVvHd == true,
                            child: SizedBox(
                              height: 35,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      _bloc.idHd = '';
                                      _bloc.nameHd = 'Chọn loại Hợp đồng';
                                      myState(() {});
                                    },
                                    child: SizedBox(
                                      height: 35,width: 30,
                                      child: Center(child: Icon(MdiIcons.deleteSweepOutline,size: 20,color: Colors.black,)),
                                    ),
                                  ),
                                  const SizedBox(width: 3,),
                                  const Text('Loại hợp đồng',style: TextStyle(color: Colors.black,fontSize: 13),),
                                  const SizedBox(width: 10,),
                                  DataLocal.listHd.isEmpty
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
                                              width: 320,
                                              child: Scrollbar(
                                                child: ListView.builder(
                                                  padding: const EdgeInsets.only(top: 10,),
                                                  itemCount: DataLocal.listHd.length,
                                                  itemBuilder: (context, index) {
                                                    final trans = DataLocal.listHd[index].tenHd.toString().trim();
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
                                                            DataLocal.listHd[index].maHd.toString().trim().length > 10 ?
                                                            '${DataLocal.listHd[index].maHd.toString().trim().substring(0,10)}...' : DataLocal.listHd[index].maHd.toString().trim(),
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle:const Divider(height: 1,),
                                                      onTap: () {
                                                        _bloc.nameHd = DataLocal.listHd[index].tenHd.toString().trim();
                                                        _bloc.idHd = DataLocal.listHd[index].maHd.toString().trim();
                                                        Navigator.pop(context);
                                                        myState(() {});
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
                                              child: Text(_bloc.nameHd.toString() == '' ? 'Chọn loại Hợp đồng' : _bloc.nameHd.toString(),style: const TextStyle(color: subColor,fontSize: 12.5)))),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      PersistentNavBarNavigator.pushNewScreen(context, screen: const SearchVVHDScreen(isVV: false),withNavBar: false).then((value){
                                        if(value != '' && value[0] == 'Accept'){
                                          _bloc.nameHd = value[1];
                                          _bloc.idHd = value[2];
                                          myState(() {});
                                        }
                                      });
                                    },
                                    child: const SizedBox(
                                      height: 35,width: 45,
                                      child: Center(child: Icon(Icons.search,size: 20,color: Colors.black,)),
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
                          Navigator.pop(context,['ReLoad',_bloc.idVv,_bloc.nameVv,_bloc.idHd,_bloc.nameHd,_bloc.idHdForVv]);
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

  // Main discount flow - Show voucher selection bottom sheet (E-commerce style)
  void _showDiscountFlow() async {
    // ✅ Reload danh sách chiết khấu từ backend trước khi mở sheet
    // Đảm bảo dữ liệu mới nhất sau khi user sửa số lượng sản phẩm
    print('💰 Reloading discounts before opening sheet...');
    _reloadDiscountsFromBackend();
    
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocProvider.value(
        value: _bloc,
        child: BlocBuilder<CartBloc, CartState>(
          buildWhen: (previous, current) {
            // ✅ Rebuild khi có ApplyDiscountSuccess hoặc khi state thay đổi
            return current is ApplyDiscountSuccess || previous != current;
          },
          builder: (context, state) {
            // ✅ Rebuild sheet khi state thay đổi (khi có dữ liệu mới từ API)
            print('💰 BlocBuilder rebuilding sheet - state: ${state.runtimeType}');
            print('💰 Current discounts - CKG: ${_bloc.listCkg.length}, CKTDTT: ${_bloc.listCktdtt.length}, CKN: ${_bloc.listCkn.length}');
            return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => DiscountVoucherSelectionSheet(
          listCkn: _bloc.listCkn,
          listCkg: _bloc.listCkg,
          listHH: _bloc.listHH,
                listCktdtt: _bloc.listCktdtt,
                listCktdth: _bloc.listCktdth,
          selectedCknGroups: _bloc.selectedCknGroups,
          selectedCkgIds: _bloc.selectedCkgIds,
          selectedHHIds: _bloc.selectedHHIds,
                selectedCktdttIds: _bloc.selectedCktdttIds,
                selectedCktdthGroups: _bloc.selectedCktdthGroups,
          currentCart: _bloc.listOrder,
          onSelectCknGroup: (String groupKey, List<ListCkMatHang> items, double totalQuantity) {
            // Gọi trực tiếp _handleCKNSelection khi user click vào CKN checkbox
            _handleCKNSelection({
              'groupKey': groupKey,
              'items': items,
              'totalQuantity': totalQuantity,
            });
          },
          onRemoveCknGroup: (String groupKey) {
            // Gọi trực tiếp _handleRemoveCKN khi user bỏ chọn CKN checkbox
            _handleRemoveCKN({
              'groupKey': groupKey,
            });
          },
          onSelectCkg: (String ckgId, ListCk ckgItem) {
            // Gọi trực tiếp _handleCKGSelection khi user click vào CKG checkbox
            print('💰 🔔 CALLBACK: onSelectCkg called with ckgId=$ckgId');
            _handleCKGSelection(ckgId, ckgItem);
          },
          onRemoveCkg: (String ckgId, ListCk ckgItem) {
            // Gọi trực tiếp _handleRemoveCKG khi user bỏ chọn CKG checkbox
            _handleRemoveCKG(ckgId, ckgItem);
          },
          onSelectCktdtt: (String cktdttId, ListCkTongDon cktdttItem) {
            // Gọi trực tiếp _handleCKTDTTSSelection khi user click vào CKTDTT checkbox
            print('💰 🔔 CALLBACK: onSelectCktdtt called with cktdttId=$cktdttId');
            _handleCKTDTTSSelection(cktdttId, cktdttItem);
          },
          onRemoveCktdtt: (String cktdttId, ListCkTongDon cktdttItem) {
            // Gọi trực tiếp _handleRemoveCKTDTTS khi user bỏ chọn CKTDTT checkbox
            _handleRemoveCKTDTTS(cktdttId, cktdttItem);
          },
          onSelectCktdthGroup: (String groupKey, List<ListCkMatHang> items, double totalQuantity) {
            // Gọi trực tiếp _handleCKTDTTHSelection khi user click vào CKTDTH checkbox
            _handleCKTDTTHSelection({
              'groupKey': groupKey,
              'items': items,
              'totalQuantity': totalQuantity,
            });
          },
          onRemoveCktdthGroup: (String groupKey) {
            // Gọi trực tiếp _handleRemoveCKTDTTH khi user bỏ chọn CKTDTH checkbox
            _handleRemoveCKTDTTH({
              'groupKey': groupKey,
            });
          },
              ),
            );
          },
        ),
      ),
    );

    if (result == null) {
      // ✅ User đóng bottom sheet mà không click "Áp dụng"
      // KHÔNG gọi API - chỉ giữ lại các thay đổi local đã được apply
      print('💰 Bottom sheet closed without apply button - keeping local changes only');
      return;
    }

    print('💰 Voucher Action: ${result['action']}');

    // Handle actions based on result
    switch (result['action']) {
      case 'apply_all':
        _handleApplyAllDiscounts(result);
        break;
      case 'select_ckn':
        _handleCKNSelection(result);
        break;
      case 'remove_ckn':
        _handleRemoveCKN(result);
        break;
    }
  }
  
  // Handle remove CKN group gifts
  void _handleRemoveCKN(Map<String, dynamic> result) {
    final String groupKey = result['groupKey'];
    
    print('💰 CKN: Removing gifts from group $groupKey');
    
    // Remove all CKN gifts from this group
    int removedCount = 0;
    DataLocal.listProductGift.removeWhere((item) {
      // Check by group_dk stored in gift (we need to track this)
      // For now, remove by checking sttRecCK matching the group
      var matchingCkn = _bloc.listCkn.where((ckn) => 
        ckn.group_dk?.toString() == groupKey
      ).toList();
      
      if (matchingCkn.isNotEmpty && item.typeCK == 'CKN') {
        bool isFromThisGroup = matchingCkn.any((ckn) => 
          ckn.sttRecCk?.trim() == item.sttRecCK?.trim()
        );
        if (isFromThisGroup) {
          _bloc.totalProductGift -= item.count ?? 0;
          removedCount++;
          print('💰 CKN: Removed ${item.code} from group $groupKey');
          return true;
        }
      }
      return false;
    });
    
    // Note: CKN gifts don't affect totalPayment (they're free),
    // but we update UI to show/hide them correctly
    
    if (removedCount > 0) {
      Utils.showCustomToast(
        context,
        Icons.info,
        'Đã bỏ $removedCount quà tặng',
      );
      print('💰 CKN: Removed $removedCount gifts - totalProductGift=${_bloc.totalProductGift}');
    }
    
    setState(() {});
  }
  
  // Handle apply all discounts (from bottom button)
  void _handleApplyAllDiscounts(Map<String, dynamic> result) async {
    Set<String> selectedCkgIds = result['selectedCkgIds'] ?? {};
    Set<String> selectedHHIds = result['selectedHHIds'] ?? {};
    Set<String> selectedCknGroups = result['selectedCknGroups'] ?? {};
    Set<String> selectedCktdttIds = result['selectedCktdttIds'] ?? {};
    Set<String> selectedCktdthGroups = result['selectedCktdthGroups'] ?? {};

    print('💰 Apply All: CKG=${selectedCkgIds.length}, HH=${selectedHHIds.length}, CKN=${selectedCknGroups.length} groups, CKTDTT=${selectedCktdttIds.length}, CKTDTH=${selectedCktdthGroups.length}');

    // Update BLoC state
    _bloc.selectedCkgIds = selectedCkgIds;
    _bloc.selectedHHIds = selectedHHIds;
    _bloc.selectedCknGroups = selectedCknGroups;
    _bloc.selectedCktdttIds = selectedCktdttIds;
    _bloc.selectedCktdthGroups = selectedCktdthGroups;

    // ✅ Apply all CKTDTT discounts (cộng dồn totalDiscountForOder)
    if (selectedCktdttIds.isNotEmpty) {
      print('💰 Applying ${selectedCktdttIds.length} CKTDTT discounts');
      _applyAllCKTDTT(selectedCktdttIds);
    }

    // ✅ Gọi API để sync tất cả thay đổi (CKG, CKTDTT, HH) với backend
    // Chỉ gọi API nếu có thay đổi
    bool hasChanges = selectedCkgIds.isNotEmpty || selectedCktdttIds.isNotEmpty || selectedHHIds.isNotEmpty;
    if (hasChanges) {
      print('💰 Calling API to sync all discount changes to backend');
      _needReapplyHHAfterReload = true;
      _reloadDiscountsFromBackend();
    } else {
      print('💰 No discount changes to sync');
    }

    // Apply HH gifts (sẽ được re-apply sau API response nếu cần)
    if (selectedHHIds.isNotEmpty) {
      print('💰 Applying HH gifts');
      _applyAllHH(selectedHHIds);
    }

    // ✅ CKN và CKTDTH: Đảm bảo totalProductGift được cập nhật đúng
    // (Gifts đã được thêm khi user click checkbox và chọn sản phẩm)
    if (selectedCknGroups.isNotEmpty || selectedCktdthGroups.isNotEmpty) {
      print('💰 Updating totalProductGift for CKN/CKTDTH gifts');
      _bloc.totalProductGift = 0;
      for (var gift in DataLocal.listProductGift) {
        _bloc.totalProductGift += gift.count ?? 0;
      }
      print('💰 Updated totalProductGift: ${_bloc.totalProductGift} (from ${DataLocal.listProductGift.length} gifts)');
    }
    
    int totalApplied = selectedCkgIds.length + selectedHHIds.length + selectedCknGroups.length + selectedCktdttIds.length + selectedCktdthGroups.length;
    Utils.showCustomToast(
      context,
      Icons.check_circle,
      'Đã áp dụng $totalApplied ưu đãi',
    );

    setState(() {});
  }

  // Apply all selected CKG discounts
  void _applyAllCKG(Set<String> selectedIds) {
    print('💰 Applying ${selectedIds.length} CKG discounts');
    print('💰 Selected IDs: $selectedIds');
    
    bool hasAdditions = false;
    bool hasRemovals = false;
    
    for (var ckgItem in _bloc.listCkg) {
      String sttRecCk = ckgItem.sttRecCk?.trim() ?? '';
      String productCode = ckgItem.maVt?.trim() ?? '';
      
      // ✅ Build ckgId với format giống DiscountVoucherSelectionSheet: "sttRecCk_productCode"
      String ckgId = '${sttRecCk}_$productCode';
      bool shouldApply = selectedIds.contains(ckgId);
      
      // ✅ discountKey dùng format "-" (vì DataLocal.listCKVT dùng format này)
      String discountKey = '${sttRecCk}-${productCode}';
      
      print('💰 Processing CKG: ckgId=$ckgId, sttRecCk=$sttRecCk, productCode=$productCode, shouldApply=$shouldApply');
      
      // ✅ Check if discountKey already exists (exact match in list)
      List<String> ckvtList = DataLocal.listCKVT.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      bool ckvtExists = ckvtList.contains(discountKey);
      
      // ✅ Check if sttRecCk already exists in listPromotion (exact match in list)
      List<String> promoList = _bloc.listPromotion.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      bool promoExists = promoList.contains(sttRecCk);
      
      // Find ALL products with this code (có thể có nhiều items cùng code)
      for (int i = 0; i < _bloc.listOrder.length; i++) {
        String cartProductCode = (_bloc.listOrder[i].code ?? '').trim();
        String searchProductCode = productCode.trim();
        
        if (cartProductCode == searchProductCode && _bloc.listOrder[i].gifProduct != true) {
          if (shouldApply) {
            // ✅ ADD discount
            if (!ckvtExists) {
              // Add to List_ckvt
              DataLocal.listCKVT = DataLocal.listCKVT.isEmpty 
                ? discountKey 
                : '${DataLocal.listCKVT},$discountKey';
              ckvtExists = true; // Update flag
              
              // ✅ CRITICAL: Add to List_promo (backend needs this!)
              if (!promoExists) {
                _bloc.listPromotion = _bloc.listPromotion.isEmpty
                  ? sttRecCk
                  : '${_bloc.listPromotion},$sttRecCk';
                promoExists = true; // Update flag
              }
            }
            
            // ✅ ALWAYS update product discount info (even if already in list)
            // This ensures UI is updated immediately
              final product = _bloc.listOrder[i];
            
            // ✅ Get original price (giá gốc) - ưu tiên giaSuaDoi, sau đó price, cuối cùng giaGoc từ CKG
            double originalPrice = product.giaSuaDoi ?? 0;
            if (originalPrice == 0) {
              originalPrice = product.price ?? 0;
            }
            if (originalPrice == 0 && ckgItem.giaGoc != null && ckgItem.giaGoc! > 0) {
              originalPrice = ckgItem.giaGoc!.toDouble();
            }
            
            // ✅ Validate: Nếu originalPrice = 0, không thể apply discount
            if (originalPrice == 0) {
              print('💰 ⚠️ WARNING: originalPrice = 0 for product ${product.code}, cannot apply discount');
              continue; // Skip this product
            }
            
            // ✅ Calculate discount và priceAfter
              final tlCk = (ckgItem.tlCk ?? 0).toDouble();
              final ckValue = (ckgItem.ck ?? 0).toDouble();
              final ckNtValue = (ckgItem.ckNt ?? 0).toDouble();
            double priceAfter = originalPrice;
            double discountPercent = 0;

              if (tlCk > 0) {
              // Trường hợp có tỉ lệ chiết khấu (%)
                discountPercent = tlCk;
              priceAfter = originalPrice - (originalPrice * discountPercent / 100);
              } else if ((ckgItem.giaSauCk ?? 0) > 0) {
              // Trường hợp có giá sau chiết khấu
                priceAfter = (ckgItem.giaSauCk ?? 0).toDouble();
              discountPercent = originalPrice > 0 ? ((originalPrice - priceAfter) / originalPrice) * 100 : 0;
              } else if (ckValue > 0) {
              // Trường hợp có số tiền chiết khấu
              priceAfter = originalPrice - ckValue;
              discountPercent = originalPrice > 0 ? (ckValue / originalPrice) * 100 : 0;
              }
            
              if (priceAfter < 0) {
                priceAfter = 0;
              }

            // ✅ Update product fields - ĐẢM BẢO UI HIỂN THỊ ĐÚNG
            product.giaSuaDoi = originalPrice; // Giá gốc (để hiển thị với gạch ngang)
            product.price = originalPrice; // Giá gốc
            product.priceAfter = priceAfter; // Giá sau chiết khấu (hiển thị đậm)
            product.priceAfter2 = priceAfter;
            product.discountPercent = discountPercent; // Phần trăm chiết khấu (hiển thị -X%)
              product.discountByHand = false;
              product.discountPercentByHand = 0;
              product.ckntByHand = 0;
              product.ck = ckValue;
              product.cknt = ckNtValue;
              product.maCk = ckgItem.maCk;
              product.maCkOld = ckgItem.maCk;
              product.sttRecCK = ckgItem.sttRecCk;
              product.typeCK = 'CKG';
              product.maVtGoc = ckgItem.maVt;
              product.sctGoc = ckgItem.sttRecCk;
              
              hasAdditions = true;
            print('💰 ✅ Added CKG to product[$i]: code=${product.code}, originalPrice=$originalPrice, priceAfter=$priceAfter, discountPercent=$discountPercent%');
          } else {
            // ✅ UNCHECK: REMOVE discount
            if (ckvtExists) {
              // Remove from List_ckvt
              ckvtList.removeWhere((item) => item.trim() == discountKey);
              DataLocal.listCKVT = ckvtList.join(',');
              ckvtExists = false; // Update flag
              
              // ✅ CRITICAL: Remove from List_promo (backend needs this!)
              // Check if there are other CKG items with same sttRecCk before removing
              bool hasOtherCkgWithSameStt = false;
              for (var otherCkg in _bloc.listCkg) {
                if (otherCkg.sttRecCk?.trim() == sttRecCk && otherCkg.maVt?.trim() != productCode) {
                  String otherKey = '${sttRecCk}-${otherCkg.maVt?.trim()}';
                  if (ckvtList.contains(otherKey)) {
                    hasOtherCkgWithSameStt = true;
                    break;
                  }
                }
              }
              
              if (!hasOtherCkgWithSameStt && promoExists) {
                promoList.removeWhere((item) => item.trim() == sttRecCk);
              _bloc.listPromotion = promoList.join(',');
              }
              
              hasRemovals = true;
              print('💰 Removed CKG - listCKVT: $discountKey, listPromotion: ${_bloc.listPromotion}');
            }
            
            // ✅ IMMEDIATE RESET (không đợi API) - Reset về giá gốc
            // Kiểm tra nếu sản phẩm này đang có CKG discount từ cùng sttRecCk hoặc productCode
            if ((_bloc.listOrder[i].sttRecCK == sttRecCk || 
                (_bloc.listOrder[i].typeCK == 'CKG' && _bloc.listOrder[i].code == productCode))) {
              print('💰 [${i}] Resetting ${productCode}: discountPercent=${_bloc.listOrder[i].discountPercent} → 0');
              
              // ✅ Get original price (giá gốc) trước khi reset
              double originalPrice = _bloc.listOrder[i].giaSuaDoi ?? 0;
              if (originalPrice == 0) {
                originalPrice = _bloc.listOrder[i].price ?? 0;
              }
              
              // Reset ALL discount fields
              _bloc.listOrder[i].typeCK = '';
              _bloc.listOrder[i].maCk = '';
              _bloc.listOrder[i].sttRecCK = '';
              _bloc.listOrder[i].maVtGoc = '';
              _bloc.listOrder[i].sctGoc = '';
              _bloc.listOrder[i].discountPercent = 0;
              _bloc.listOrder[i].discountPercentByHand = 0;
              _bloc.listOrder[i].ckntByHand = 0;
              _bloc.listOrder[i].ck = 0;
              _bloc.listOrder[i].cknt = 0;
              _bloc.listOrder[i].discountByHand = false;
              
              // ✅ Reset về giá gốc - ĐẢM BẢO UI HIỂN THỊ ĐÚNG
              _bloc.listOrder[i].giaSuaDoi = originalPrice; // Giá gốc
              _bloc.listOrder[i].price = originalPrice; // Giá gốc
              _bloc.listOrder[i].priceAfter = originalPrice; // Giá sau = giá gốc (không còn chiết khấu)
              _bloc.listOrder[i].priceAfter2 = originalPrice;
              
              DataLocal.listOrderCalculatorDiscount.removeWhere(
                (element) => element.code.toString().trim() == productCode.toString().trim()
              );
              
              hasRemovals = true; // Ensure hasRemovals is set
              print('💰 [${i}] RESET DONE: originalPrice=$originalPrice, priceAfter=$originalPrice, discountPercent=0');
            }
          }
        }
      }
    }
    
    // ✅ FORCE UI UPDATE NGAY
    if (hasRemovals || hasAdditions) {
      print('💰 Force UI rebuild - hasRemovals=$hasRemovals, hasAdditions=$hasAdditions');
      
      // ✅ CRITICAL: Tính lại total LOCAL (không cần gọi backend vì backend không nhận discount info)
      _recalculateTotalLocal();
      
      setState(() {});
    }
    
    // ✅ CHỈ GỌI API KHI CÓ ADDITIONS (không gọi khi chỉ remove)
    if (hasAdditions) {
      print('💰 Calling API to apply new discounts');
      _needReapplyHHAfterReload = true;
      _reloadDiscountsFromBackend();
    }
  }
  
  
  // Reload discounts from backend after changing selection
  void _reloadDiscountsFromBackend() {
    // Build list items, qty, price, money
  String listItem = '';
  String listQty = '';
  String listPrice = '';
  String listMoney = '';
    
    for (var element in _bloc.listProductOrderAndUpdate) {
      if (element.isMark == 1) {
        double x = (element.giaSuaDoi) * (element.count ?? 0);
        listItem = listItem.isEmpty ? element.code.toString() : '$listItem,${element.code.toString()}';
        listQty = listQty.isEmpty ? element.count.toString() : '$listQty,${element.count.toString()}';
        listPrice = listPrice.isEmpty ? element.giaSuaDoi.toString() : '$listPrice,${element.giaSuaDoi.toString()}';
        listMoney = listMoney.isEmpty ? x.toString() : '$listMoney,${x.toString()}';
      }
    }
    
    if (listItem.isNotEmpty) {
      // ✅ DEBUG: Log request parameters
      print('💰 === Calling API with parameters ===');
      print('💰 listCKVT: ${DataLocal.listCKVT}');
      print('💰 listItem: $listItem');
      print('💰 listQty: $listQty');
      print('💰 listPrice: $listPrice');
      print('💰 listMoney: $listMoney');
      
      // Call API to recalculate discounts
      _bloc.add(GetListItemApplyDiscountEvent(
        listCKVT: DataLocal.listCKVT,
        listPromotion: _bloc.listPromotion,
        listItem: listItem,
        listQty: listQty,
        listPrice: listPrice,
        listMoney: listMoney,
        warehouseId: codeStore,
        customerId: _bloc.codeCustomer.toString(),
        keyLoad: 'Second',  // Not first load
      ));
      
      print('💰 Called GetListItemApplyDiscountEvent');
    }
  }
  
  // Recalculate total payment locally (sau khi check/uncheck discount)
  void _recalculateTotalLocal() {
    print('💰 === Recalculating Total Locally ===');
    
    double totalMoney = 0;
    double totalDiscount = 0;
    
    // Loop through all products
    for (var element in _bloc.listOrder) {
      if (element.isMark == 1 && element.gifProduct != true) {
        double originalPrice = element.giaSuaDoi ?? 0;
        if (originalPrice == 0) {
          originalPrice = element.price ?? 0;
        }
        double priceAfter = element.priceAfter ?? originalPrice;
        double quantity = element.count ?? 0;
        
        totalMoney += originalPrice * quantity;  // Original total
        
        // ✅ Calculate discount từ sự khác biệt giữa originalPrice và priceAfter
        // Điều này đảm bảo tính đúng cho mọi trường hợp (tlCk, giaSauCk, ckValue)
        if (priceAfter < originalPrice && originalPrice > 0) {
          double lineDiscount = (originalPrice - priceAfter) * quantity;
          totalDiscount += lineDiscount;
        }
        
        double discountPercent = (element.discountPercentByHand ?? 0) > 0 
          ? (element.discountPercentByHand ?? 0) 
          : (element.discountPercent ?? 0);
        
        print('💰 Product ${element.code}: qty=$quantity, originalPrice=$originalPrice, priceAfter=$priceAfter, discountPercent=$discountPercent%, lineDiscount=${(originalPrice - priceAfter) * quantity}');
      }
    }
    
    // ✅ Trừ cả totalDiscountForOder (chiết khấu tổng đơn từ CKTDTT)
    double totalPayment = totalMoney - totalDiscount - (_bloc.totalDiscountForOder ?? 0);
    
    // Update BLoC
    _bloc.totalMoney = totalMoney;
    _bloc.totalDiscount = totalDiscount;
    _bloc.totalPayment = totalPayment;
    
    print('💰 Total Calculated:');
    print('    totalMoney = $totalMoney');
    print('    totalDiscount = $totalDiscount');
    print('    totalDiscountForOder (CKTDTT) = ${_bloc.totalDiscountForOder ?? 0}');
    print('    totalPayment = $totalPayment (totalMoney - totalDiscount - totalDiscountForOder)');
  }
  
  // Sync listOrder to listProductOrderAndUpdate for UI update
  void _syncListOrderToUI() {
    print('💰 Syncing ${_bloc.listOrder.length} items to UI data');
    
    // Clear and rebuild listProductOrderAndUpdate from listOrder
    _bloc.listProductOrderAndUpdate.clear();
    
    for (var element in _bloc.listOrder) {
      Product production = Product(
        code: element.code,
        name: element.name,
        name2: element.name2,
        dvt: element.dvt,
        description: element.descript,
        price: element.price,
        priceMin: element.priceMin,
        priceAfterTax: element.priceAfterTax,
        taxPercent: element.taxPercent,
        valuesTax: element.valuesTax,
        applyPriceAfterTax: element.applyPriceAfterTax == true ? 1 : 0,
        discountByHand: element.discountByHand == true ? 1 : 0,
        discountPercentByHand: element.discountPercentByHand,
        ckntByHand: element.ckntByHand,
        giaSuaDoi: element.giaSuaDoi,
        priceOk: element.priceOk,
        woPrice: element.woPrice,
        woPriceAfter: element.woPriceAfter,
        discountPercent: element.discountPercent,
        priceAfter: element.priceAfter,
        imageUrl: element.imageUrl ?? '',
        count: element.count,
        countMax: element.countMax,
        so_luong_kd: element.so_luong_kd,
        maVt2: element.maVt2,
        sttRec0: element.sttRec0,
        isMark: 1,
        discountMoney: element.discountMoney ?? '0',
        discountProduct: element.discountProduct ?? '0',
        budgetForItem: element.budgetForItem ?? '',
        budgetForProduct: element.budgetForProduct ?? '',
        residualValueProduct: element.residualValueProduct ?? 0,
        residualValue: element.residualValue ?? 0,
        unit: element.unit ?? '',
        unitProduct: element.unitProduct ?? '',
        dsCKLineItem: element.maCk.toString(),
        allowDvt: element.allowDvt == true ? 0 : 1,
        contentDvt: element.contentDvt ?? '',
        kColorFormatAlphaB: element.kColorFormatAlphaB?.value,
        codeStock: element.stockCode,
        nameStock: element.stockName,
        stockAmount: element.stockAmount,
        heSo: element.heSo.toString(),
        idNVKD: element.idNVKD,
        nameNVKD: element.nameNVKD,
        nuocsx: element.nuocsx,
        quycach: element.quycach,
        maThue: element.maThue,
        tenThue: element.tenThue,
        thueSuat: element.thueSuat,
      );
      
      _bloc.listProductOrderAndUpdate.add(production);
      
      // Also save to DB for persistence
      _bloc.db.updateProduct(production, production.codeStock.toString(), false);
    }
    
    print('💰 Synced ${_bloc.listProductOrderAndUpdate.length} items to UI');
  }

  // Apply all selected HH gifts
  void _applyAllHH(Set<String> selectedIds) {
    print('💰 Applying ${selectedIds.length} HH gifts - START totalProductGift=${_bloc.totalProductGift}');
    
    int removedCount = 0;
    
    // ✅ Remove all HH gifts first (prevent duplicate)
    DataLocal.listProductGift.removeWhere((item) {
      if (item.typeCK == 'HH') {
        _bloc.totalProductGift -= item.count ?? 0;
        removedCount++;
        print('💰 Removed old HH gift: ${item.code} x${item.count}');
        return true;
      }
      return false;
    });
    
    print('💰 Removed $removedCount old HH gifts');
    
    // Rebuild listPromotion for HH
    List<String> promoList = _bloc.listPromotion.split(',').where((s) => s.isNotEmpty).toList();
    
    // Add selected HH gifts
    int addedCount = 0;
    for (var hhItem in _bloc.listHH) {
      // ✅ FIX: Dùng unique ID (sttRecCk + tenVt) để match với selection
      String hhId = '${hhItem.sttRecCk?.trim() ?? ''}_${hhItem.tenVt?.trim() ?? ''}';
      String sttRecCk = hhItem.sttRecCk?.trim() ?? '';
      
      if (selectedIds.contains(hhId)) {
        // ✅ CRITICAL: Add to List_promo nếu chưa có
        if (!promoList.contains(sttRecCk)) {
          promoList.add(sttRecCk);
        }
        SearchItemResponseData gift = SearchItemResponseData(
          code: hhItem.tenVt ?? '',
          sttRec0: hhItem.sttRecCk?.trim() ?? '',
          name: hhItem.tenVt ?? 'Quà tặng',
          name2: hhItem.tenVt ?? 'Quà tặng',
          dvt: hhItem.dvt ?? '',
          price: 0,
          discountPercent: 0,
          priceAfter: 0,
          count: hhItem.soLuong ?? 0,
          maCk: hhItem.maCk?.trim() ?? '',
          maCkOld: hhItem.maCk ?? '',
          maVtGoc: hhItem.maVt?.trim() ?? '',
          sctGoc: hhItem.sttRecCk?.trim() ?? '',
          sttRecCK: hhItem.sttRecCk?.trim() ?? '',
          typeCK: 'HH',
          gifProduct: true,
          stockAmount: 0,
          isMark: 1,
        );

        DataLocal.listProductGift.add(gift);
        _bloc.totalProductGift += hhItem.soLuong ?? 0;
        addedCount++;
        print('💰 Added HH gift: ${hhItem.tenVt} x${hhItem.soLuong}');
      } else {
        // ✅ Remove from List_promo nếu không được chọn
        promoList.removeWhere((item) => item.trim() == sttRecCk);
      }
    }
    
    // ✅ Update listPromotion
    _bloc.listPromotion = promoList.join(',');
    
    print('💰 HH gifts complete - Added $addedCount items, END totalProductGift=${_bloc.totalProductGift}');
    print('💰 Updated listPromotion: ${_bloc.listPromotion}');
  }

  // Apply all selected CKTDTT discounts (cộng dồn totalDiscountForOder)
  void _applyAllCKTDTT(Set<String> selectedIds) {
    print('💰 Applying ${selectedIds.length} CKTDTT discounts - START totalDiscountForOder=${_bloc.totalDiscountForOder ?? 0}');
    
    // Reset totalDiscountForOder và codeDiscountTD để tính lại từ đầu
    double totalDiscountForOder = 0;
    List<String> codeDiscountList = [];
    List<String> sttRecCKList = [];
    
    // Parse listPromotion và listCKVT hiện tại
    List<String> promoList = _bloc.listPromotion.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    List<String> ckvtList = DataLocal.listCKVT.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    // Duyệt qua tất cả CKTDTT đã chọn
    for (var cktdttItem in _bloc.listCktdtt) {
      String sttRecCk = (cktdttItem.sttRecCk ?? '').trim();
      
      // ✅ Build cktdttId với format giống DiscountVoucherSelectionSheet: "sttRecCk"
      String cktdttId = sttRecCk;
      bool shouldApply = selectedIds.contains(cktdttId);
      
      if (shouldApply && sttRecCk.isNotEmpty) {
        print('💰 Processing CKTDTT: cktdttId=$cktdttId, sttRecCk=$sttRecCk, tCkTtNt=${cktdttItem.tCkTtNt ?? 0}');
        
        // ✅ Cộng dồn totalDiscountForOder
        double discountAmount = cktdttItem.tCkTtNt ?? 0;
        totalDiscountForOder += discountAmount;
        
        // ✅ Thêm sttRecCk vào listPromotion nếu chưa có
        if (!promoList.contains(sttRecCk)) {
          promoList.add(sttRecCk);
        }
        
        // ✅ Thêm sttRecCk vào listCKVT nếu chưa có
        if (!ckvtList.contains(sttRecCk)) {
          ckvtList.add(sttRecCk);
        }
        
        // ✅ Lưu maCk và sttRecCk
        String maCk = (cktdttItem.maCk ?? '').trim();
        if (maCk.isNotEmpty && !codeDiscountList.contains(maCk)) {
          codeDiscountList.add(maCk);
        }
        if (sttRecCk.isNotEmpty && !sttRecCKList.contains(sttRecCk)) {
          sttRecCKList.add(sttRecCk);
        }
        
        print('💰 CKTDTT: Added discount ${discountAmount} - Running total: $totalDiscountForOder');
      } else {
        // ✅ Remove nếu không được chọn
        promoList.removeWhere((item) => item.trim() == sttRecCk);
        ckvtList.removeWhere((item) => item.trim() == sttRecCk);
      }
    }
    
    // ✅ Update BLoC state
    _bloc.totalDiscountForOder = totalDiscountForOder;
    _bloc.listPromotion = promoList.join(',');
    DataLocal.listCKVT = ckvtList.join(',');
    
    // ✅ Set codeDiscountTD (lấy mã đầu tiên hoặc join nếu cần)
    if (codeDiscountList.isNotEmpty) {
      _bloc.codeDiscountTD = codeDiscountList.first; // Hoặc có thể join: codeDiscountList.join(',')
    } else {
      _bloc.codeDiscountTD = '';
    }
    
    // ✅ Set sttRecCKOld (lấy sttRecCk đầu tiên)
    if (sttRecCKList.isNotEmpty) {
      _bloc.sttRecCKOld = sttRecCKList.first;
    } else {
      _bloc.sttRecCKOld = '';
    }
    
    print('💰 CKTDTT complete - Applied ${selectedIds.length} discounts, totalDiscountForOder=$totalDiscountForOder');
    print('💰 Updated listPromotion: ${_bloc.listPromotion}');
    print('💰 Updated listCKVT: ${DataLocal.listCKVT}');
    print('💰 Updated codeDiscountTD: ${_bloc.codeDiscountTD}');
    
    // Recalculate totals
    _recalculateTotalLocal();
  }

  // Handle CKN selection (when user clicks checkbox and needs to select gifts)
  void _handleCKNSelection(Map<String, dynamic> result) async {
    final String groupKey = result['groupKey'];
    final List<ListCkMatHang> items = result['items'];
    final double totalQuantity = result['totalQuantity'];

    print('💰 CKN: User selecting gifts for group $groupKey');

    // Save selected discount group (legacy)
    _bloc.selectedDiscountGroup = groupKey;
    
    // Add to multiple selection set
    _bloc.selectedCknGroups.add(groupKey);

    // Save pending state for BLocListener
    setState(() {
      _pendingDiscountName = (items.first.ten_ck?.toString() ?? 'CKN');
      _pendingMaxQuantity = totalQuantity;
      _pendingDiscountItems = items;
      _pendingDiscountType = 'CKN'; // Mark as CKN type
    });

    // ✅ Hiển thị loading dialog
    _showLoadingDialog('Đang tải danh sách sản phẩm tặng...');

    // Call API to get gift product list
    _bloc.add(GetGiftProductListEvent(maNhom: groupKey));
  }

  // Handle CKTDTH selection (when user clicks checkbox and needs to select gifts)
  void _handleCKTDTTHSelection(Map<String, dynamic> result) async {
    final String groupKey = result['groupKey'];
    final List<ListCkMatHang> items = result['items'];
    final double totalQuantity = result['totalQuantity'];

    print('💰 CKTDTH: User selecting gifts for group $groupKey');
    
    // Add to multiple selection set
    _bloc.selectedCktdthGroups.add(groupKey);

    // Save pending state for BLocListener
    setState(() {
      _pendingDiscountName = (items.first.ten_ck?.toString() ?? 'CKTDTH');
      _pendingMaxQuantity = totalQuantity;
      _pendingDiscountItems = items;
      _pendingDiscountType = 'CKTDTH'; // Mark as CKTDTH type
    });

    // ✅ Hiển thị loading dialog
    _showLoadingDialog('Đang tải danh sách sản phẩm tặng...');

    // Call API to get gift product list
    _bloc.add(GetGiftProductListEvent(maNhom: groupKey));
  }

  // Handle CKTDTH removal (when user unchecks checkbox)
  void _handleRemoveCKTDTTH(Map<String, dynamic> result) {
    final String groupKey = result['groupKey'];
    
    print('💰 CKTDTH: Removing gifts from group $groupKey');
    
    // Remove all CKTDTH gifts from this group
    int removedCount = 0;
    DataLocal.listProductGift.removeWhere((item) {
      // Check by group_dk stored in gift
      var matchingCktdth = _bloc.listCktdth.where((cktdth) => 
        cktdth.group_dk?.toString() == groupKey
      ).toList();
      
      if (matchingCktdth.isNotEmpty && item.typeCK == 'CKTDTH') {
        bool isFromThisGroup = matchingCktdth.any((cktdth) => 
          cktdth.sttRecCk?.trim() == item.sttRecCK?.trim()
        );
        if (isFromThisGroup) {
          _bloc.totalProductGift -= item.count ?? 0;
          removedCount++;
          print('💰 CKTDTH: Removed ${item.code} from group $groupKey');
          return true;
        }
      }
      return false;
    });
    
    // Remove from selected groups
    _bloc.selectedCktdthGroups.remove(groupKey);
    
    if (removedCount > 0) {
      Utils.showCustomToast(
        context,
        Icons.info_outline,
        'Đã xóa $removedCount sản phẩm tặng',
      );
    }
    
    setState(() {});
  }

  // Handle CKG selection (when user clicks checkbox - apply immediately)
  void _handleCKGSelection(String ckgId, ListCk ckgItem) {
    print('💰 ========== CKG SELECTION START ==========');
    print('💰 CKG: User selecting discount for ckgId=$ckgId');
    print('💰 CKG Item: sttRecCk=${ckgItem.sttRecCk}, maVt=${ckgItem.maVt}, tenCk=${ckgItem.tenCk}');
    print('💰 CKG Item: tlCk=${ckgItem.tlCk}, ck=${ckgItem.ck}, giaSauCk=${ckgItem.giaSauCk}');
    
    // Update BLoC state
    _bloc.selectedCkgIds.add(ckgId);
    print('💰 Updated selectedCkgIds: ${_bloc.selectedCkgIds}');
    
    // Apply CKG discount immediately
    _applySingleCKG(ckgId, ckgItem, shouldApply: true);
    
    print('💰 ========== CKG SELECTION END ==========');
  }

  // Handle CKG removal (when user unchecks checkbox - remove immediately)
  void _handleRemoveCKG(String ckgId, ListCk ckgItem) {
    print('💰 CKG: User removing discount for $ckgId');
    
    // Update BLoC state
    _bloc.selectedCkgIds.remove(ckgId);
    
    // Remove CKG discount immediately
    _applySingleCKG(ckgId, ckgItem, shouldApply: false);
  }

  // Handle CKTDTT selection (when user clicks checkbox - apply immediately)
  void _handleCKTDTTSSelection(String cktdttId, ListCkTongDon cktdttItem) {
    print('💰 ========== CKTDTT SELECTION START ==========');
    print('💰 CKTDTT: User selecting discount for cktdttId=$cktdttId');
    print('💰 CKTDTT Item: sttRecCk=${cktdttItem.sttRecCk}, maCk=${cktdttItem.maCk}');
    print('💰 CKTDTT Item: tCkTt=${cktdttItem.tCkTt}, tCkTtNt=${cktdttItem.tCkTtNt}, tlCkTt=${cktdttItem.tlCkTt}');
    
    // Update BLoC state
    _bloc.selectedCktdttIds.add(cktdttId);
    print('💰 Updated selectedCktdttIds: ${_bloc.selectedCktdttIds}');
    
    // Apply CKTDTT discount immediately
    _applySingleCKTDTT(cktdttId, cktdttItem, shouldApply: true);
    
    print('💰 ========== CKTDTT SELECTION END ==========');
  }

  // Handle CKTDTT removal (when user unchecks checkbox - remove immediately)
  void _handleRemoveCKTDTTS(String cktdttId, ListCkTongDon cktdttItem) {
    print('💰 CKTDTT: User removing discount for $cktdttId');
    
    // Update BLoC state
    _bloc.selectedCktdttIds.remove(cktdttId);
    
    // Remove CKTDTT discount immediately
    _applySingleCKTDTT(cktdttId, cktdttItem, shouldApply: false);
  }

  // Apply or remove a single CKTDTT discount
  void _applySingleCKTDTT(String cktdttId, ListCkTongDon cktdttItem, {required bool shouldApply}) {
    String sttRecCk = (cktdttItem.sttRecCk ?? '').trim();
    
    print('💰 _applySingleCKTDTT: cktdttId=$cktdttId, sttRecCk=$sttRecCk, shouldApply=$shouldApply');
    print('💰 Current listPromotion: ${_bloc.listPromotion}');
    print('💰 Current listCKVT: ${DataLocal.listCKVT}');
    
    // Check if sttRecCk already exists in listPromotion (exact match in list)
    List<String> promoList = _bloc.listPromotion.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    bool promoExists = promoList.contains(sttRecCk);
    
    // Check if sttRecCk already exists in listCKVT (exact match in list)
    List<String> ckvtList = DataLocal.listCKVT.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    bool ckvtExists = ckvtList.contains(sttRecCk);
    
    if (shouldApply) {
      // ✅ Cộng dồn totalDiscountForOder TRƯỚC KHI thêm vào listPromotion
      // Chỉ cộng thêm nếu sttRecCk chưa có trong listPromotion (chưa được apply)
      if (!promoExists) {
        double currentDiscount = _bloc.totalDiscountForOder ?? 0;
        double newDiscount = cktdttItem.tCkTtNt ?? 0;
        _bloc.totalDiscountForOder = currentDiscount + newDiscount;
        print('💰 CKTDTT: Added discount $newDiscount - Total: ${_bloc.totalDiscountForOder} (was $currentDiscount)');
      } else {
        print('💰 CKTDTT: sttRecCk $sttRecCk already exists in listPromotion, skipping discount addition');
      }
      
      // ✅ ADD CKTDTT discount to listPromotion và listCKVT
      if (!promoExists) {
        _bloc.listPromotion = _bloc.listPromotion.isEmpty
          ? sttRecCk
          : '${_bloc.listPromotion},$sttRecCk';
        promoExists = true;
      }
      
      if (!ckvtExists) {
        DataLocal.listCKVT = DataLocal.listCKVT.isEmpty
          ? sttRecCk
          : '${DataLocal.listCKVT},$sttRecCk';
        ckvtExists = true;
      }
      
      // ✅ Update codeDiscountTD (lấy mã đầu tiên hoặc giữ nguyên nếu đã có)
      if (_bloc.codeDiscountTD.isEmpty) {
        _bloc.codeDiscountTD = cktdttItem.maCk?.toString().trim() ?? '';
      }
      
      // ✅ Update sttRecCKOld (lấy sttRecCk đầu tiên)
      if (_bloc.sttRecCKOld.isEmpty) {
        _bloc.sttRecCKOld = sttRecCk;
      }
      
      print('💰 CKTDTT: listPromotion: ${_bloc.listPromotion}, listCKVT: ${DataLocal.listCKVT}');
      print('💰 CKTDTT: codeDiscountTD=${_bloc.codeDiscountTD}, sttRecCKOld=${_bloc.sttRecCKOld}, totalDiscountForOder=${_bloc.totalDiscountForOder}');
      
      // ✅ KHÔNG GỌI API NGAY KHI CLICK - Chỉ update UI local
      // API sẽ được gọi khi user đóng bottom sheet (batch update)
      // _reloadDiscountsFromBackend();
    } else {
      // ✅ REMOVE CKTDTT discount
      if (promoExists) {
        promoList.removeWhere((item) => item.trim() == sttRecCk);
        _bloc.listPromotion = promoList.join(',');
      }
      
      if (ckvtExists) {
        ckvtList.removeWhere((item) => item.trim() == sttRecCk);
        DataLocal.listCKVT = ckvtList.join(',');
      }
      
      // ✅ Tính lại totalDiscountForOder từ tất cả CKTDTT còn lại được chọn
      double totalDiscount = 0;
      List<String> codeDiscountList = [];
      List<String> sttRecCKList = [];
      
      for (var item in _bloc.listCktdtt) {
        String itemSttRecCk = (item.sttRecCk ?? '').trim();
        if (itemSttRecCk.isNotEmpty && _bloc.selectedCktdttIds.contains(itemSttRecCk)) {
          double discountAmount = item.tCkTtNt ?? 0;
          totalDiscount += discountAmount;
          
          String maCk = (item.maCk ?? '').trim();
          if (maCk.isNotEmpty && !codeDiscountList.contains(maCk)) {
            codeDiscountList.add(maCk);
          }
          if (itemSttRecCk.isNotEmpty && !sttRecCKList.contains(itemSttRecCk)) {
            sttRecCKList.add(itemSttRecCk);
          }
        }
      }
      
      _bloc.totalDiscountForOder = totalDiscount;
      
      // ✅ Reset codeDiscountTD và sttRecCKOld nếu không còn CKTDTT nào được chọn
      if (_bloc.selectedCktdttIds.isEmpty) {
        _bloc.codeDiscountTD = '';
        _bloc.sttRecCKOld = '';
        _bloc.totalDiscountForOder = 0;
      } else {
        // ✅ Set codeDiscountTD (lấy mã đầu tiên)
        if (codeDiscountList.isNotEmpty) {
          _bloc.codeDiscountTD = codeDiscountList.first;
        } else {
          _bloc.codeDiscountTD = '';
        }
        
        // ✅ Set sttRecCKOld (lấy sttRecCk đầu tiên)
        if (sttRecCKList.isNotEmpty) {
          _bloc.sttRecCKOld = sttRecCKList.first;
        } else {
          _bloc.sttRecCKOld = '';
        }
      }
      
      print('💰 CKTDTT: Removed - listPromotion: ${_bloc.listPromotion}, listCKVT: ${DataLocal.listCKVT}');
      print('💰 CKTDTT: codeDiscountTD=${_bloc.codeDiscountTD}, totalDiscountForOder=${_bloc.totalDiscountForOder}');
      
      // ✅ KHÔNG GỌI API NGAY KHI CLICK - Chỉ update UI local
      // API sẽ được gọi khi user đóng bottom sheet (batch update)
      // _reloadDiscountsFromBackend();
    }
    
    // Recalculate totals
    _recalculateTotalLocal();
    setState(() {});
  }

  // Apply or remove a single CKG discount
  void _applySingleCKG(String ckgId, ListCk ckgItem, {required bool shouldApply}) {
    // ✅ Parse ckgId: có thể là format "sttRecCk_productCode" hoặc chỉ "sttRecCk"
    String sttRecCk = ckgItem.sttRecCk?.trim() ?? '';
    String productCode = ckgItem.maVt?.trim() ?? '';
    
    // ✅ Nếu ckgId chứa dấu "_", parse để lấy sttRecCk và productCode
    if (ckgId.contains('_')) {
      List<String> parts = ckgId.split('_');
      if (parts.length >= 2) {
        sttRecCk = parts[0].trim();
        productCode = parts[1].trim();
      } else if (parts.length == 1) {
        sttRecCk = parts[0].trim();
      }
    } else {
      // Nếu không có dấu "_", ckgId có thể chỉ là sttRecCk
      sttRecCk = ckgId.trim();
    }
    
    // ✅ discountKey dùng format "-" (vì DataLocal.listCKVT dùng format này)
    String discountKey = '${sttRecCk}-${productCode}';
    
    print('💰 _applySingleCKG: ckgId=$ckgId, parsed sttRecCk=$sttRecCk, parsed productCode=$productCode, discountKey=$discountKey, shouldApply=$shouldApply');
    print('💰 Current listCKVT: ${DataLocal.listCKVT}');
    print('💰 Current listPromotion: ${_bloc.listPromotion}');
    print('💰 Cart has ${_bloc.listOrder.length} items');
    
    // Check if discountKey already exists (exact match in list)
    List<String> ckvtList = DataLocal.listCKVT.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    bool ckvtExists = ckvtList.contains(discountKey);
    
    // Check if sttRecCk already exists in listPromotion (exact match in list)
    List<String> promoList = _bloc.listPromotion.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    bool promoExists = promoList.contains(sttRecCk);
    
    // Find ALL products with this code
    bool hasChanges = false;
    int foundProducts = 0;
    
    // ✅ DEBUG: Log all product codes in cart
    print('💰 Searching for productCode: "$productCode"');
    print('💰 Available product codes in cart: ${_bloc.listOrder.map((e) => '${e.code} (gifProduct=${e.gifProduct})').toList()}');
    
    for (int i = 0; i < _bloc.listOrder.length; i++) {
      // ✅ Match product by code (case-insensitive, trim whitespace)
      String cartProductCode = (_bloc.listOrder[i].code ?? '').trim();
      String searchProductCode = productCode.trim();
      
      if (cartProductCode == searchProductCode && _bloc.listOrder[i].gifProduct != true) {
        foundProducts++;
        print('💰 ✅ Found product[$i]: code="${_bloc.listOrder[i].code}", name="${_bloc.listOrder[i].name}", giaSuaDoi=${_bloc.listOrder[i].giaSuaDoi}, price=${_bloc.listOrder[i].price}');
        
        if (shouldApply) {
          // ✅ ADD discount
          if (!ckvtExists) {
            // Add to List_ckvt
            DataLocal.listCKVT = DataLocal.listCKVT.isEmpty 
              ? discountKey 
              : '${DataLocal.listCKVT},$discountKey';
            ckvtExists = true; // Update flag
            
            // ✅ CRITICAL: Add to List_promo (backend needs this!)
            if (!promoExists) {
              _bloc.listPromotion = _bloc.listPromotion.isEmpty
                ? sttRecCk
                : '${_bloc.listPromotion},$sttRecCk';
              promoExists = true; // Update flag
            }
          }
          
          // ✅ ALWAYS update product discount info (even if already in list)
          // This ensures UI is updated immediately
            final product = _bloc.listOrder[i];
            
            // ✅ Get original price (giá gốc) - ưu tiên giaSuaDoi, sau đó price, cuối cùng giaGoc từ CKG
            double originalPrice = product.giaSuaDoi ?? 0;
            if (originalPrice == 0) {
              originalPrice = product.price ?? 0;
            }
            if (originalPrice == 0 && ckgItem.giaGoc != null && ckgItem.giaGoc! > 0) {
              originalPrice = ckgItem.giaGoc!.toDouble();
            }
            
            // ✅ Validate: Nếu originalPrice = 0, không thể apply discount
            if (originalPrice == 0) {
              print('💰 ⚠️ WARNING: originalPrice = 0 for product ${product.code}, cannot apply discount');
              continue; // Skip this product
            }
            
            // ✅ Calculate discount và priceAfter
            final tlCk = (ckgItem.tlCk ?? 0).toDouble();
            final ckValue = (ckgItem.ck ?? 0).toDouble();
            final ckNtValue = (ckgItem.ckNt ?? 0).toDouble();
            double priceAfter = originalPrice;
            double discountPercent = 0;

            if (tlCk > 0) {
              // Trường hợp có tỉ lệ chiết khấu (%)
              discountPercent = tlCk;
              priceAfter = originalPrice - (originalPrice * discountPercent / 100);
            } else if ((ckgItem.giaSauCk ?? 0) > 0) {
              // Trường hợp có giá sau chiết khấu
              priceAfter = (ckgItem.giaSauCk ?? 0).toDouble();
              discountPercent = originalPrice > 0 ? ((originalPrice - priceAfter) / originalPrice) * 100 : 0;
            } else if (ckValue > 0) {
              // Trường hợp có số tiền chiết khấu
              priceAfter = originalPrice - ckValue;
              discountPercent = originalPrice > 0 ? (ckValue / originalPrice) * 100 : 0;
            }
            
            if (priceAfter < 0) {
              priceAfter = 0;
            }
            
            print('💰 Calculating discount: originalPrice=$originalPrice, tlCk=$tlCk, ckValue=$ckValue, giaSauCk=${ckgItem.giaSauCk}, priceAfter=$priceAfter, discountPercent=$discountPercent%');

            // ✅ Check if values actually changed (for debugging)
            bool priceChanged = (product.priceAfter ?? 0) != priceAfter;
            bool discountChanged = (product.discountPercent ?? 0) != discountPercent;
            
            // ✅ Update product fields - ĐẢM BẢO UI HIỂN THỊ ĐÚNG
            product.giaSuaDoi = originalPrice; // Giá gốc (để hiển thị với gạch ngang)
            product.price = originalPrice; // Giá gốc
            product.priceAfter = priceAfter; // Giá sau chiết khấu (hiển thị đậm)
            product.priceAfter2 = priceAfter;
            product.discountPercent = discountPercent; // Phần trăm chiết khấu (hiển thị -X%)
            product.discountByHand = false;
            product.discountPercentByHand = 0;
            product.ckntByHand = 0;
            product.ck = ckValue;
            product.cknt = ckNtValue;
            product.maCk = ckgItem.maCk;
            product.maCkOld = ckgItem.maCk;
            product.sttRecCK = ckgItem.sttRecCk;
            product.typeCK = 'CKG';
            product.maVtGoc = ckgItem.maVt;
            product.sctGoc = ckgItem.sttRecCk;
            
            // ✅ Always set hasChanges when applying discount (to ensure UI update)
            hasChanges = true;
            print('💰 ✅ UPDATED product[$i]:');
            print('   code=${product.code}');
            print('   giaSuaDoi=${product.giaSuaDoi} (originalPrice)');
            print('   price=${product.price} (originalPrice)');
            print('   priceAfter=${product.priceAfter} (discounted price)');
            print('   discountPercent=${product.discountPercent}%');
            print('   typeCK=${product.typeCK}');
            print('   sttRecCK=${product.sttRecCK}');
            print('   maCk=${product.maCk}');
        } else {
          // ✅ REMOVE discount
          if (ckvtExists) {
            // Remove from List_ckvt
            ckvtList.removeWhere((item) => item.trim() == discountKey);
            DataLocal.listCKVT = ckvtList.join(',');
            ckvtExists = false; // Update flag
            
            // ✅ CRITICAL: Remove from List_promo (backend needs this!)
            // Check if there are other CKG items with same sttRecCk before removing
            bool hasOtherCkgWithSameStt = false;
            for (var otherCkg in _bloc.listCkg) {
              if (otherCkg.sttRecCk?.trim() == sttRecCk && otherCkg.maVt?.trim() != productCode) {
                String otherKey = '${sttRecCk}-${otherCkg.maVt?.trim()}';
                if (ckvtList.contains(otherKey)) {
                  hasOtherCkgWithSameStt = true;
                  break;
                }
              }
            }
            
            if (!hasOtherCkgWithSameStt && promoExists) {
              promoList.removeWhere((item) => item.trim() == sttRecCk);
              _bloc.listPromotion = promoList.join(',');
            }
            
            hasChanges = true;
            print('💰 Removed CKG - listCKVT: $discountKey, listPromotion: ${_bloc.listPromotion}');
          }
          
          // ✅ IMMEDIATE RESET (không đợi API) - Reset về giá gốc
          // Kiểm tra nếu sản phẩm này đang có CKG discount từ cùng sttRecCk
          if (_bloc.listOrder[i].sttRecCK == sttRecCk || 
              (_bloc.listOrder[i].typeCK == 'CKG' && _bloc.listOrder[i].code == productCode)) {
            print('💰 [${i}] Resetting ${productCode}: discountPercent=${_bloc.listOrder[i].discountPercent} → 0');
            
            // ✅ Get original price (giá gốc) trước khi reset
            double originalPrice = _bloc.listOrder[i].giaSuaDoi ?? 0;
            if (originalPrice == 0) {
              originalPrice = _bloc.listOrder[i].price ?? 0;
            }
            
            // Reset ALL discount fields
            _bloc.listOrder[i].typeCK = '';
            _bloc.listOrder[i].maCk = '';
            _bloc.listOrder[i].sttRecCK = '';
            _bloc.listOrder[i].maVtGoc = '';
            _bloc.listOrder[i].sctGoc = '';
            _bloc.listOrder[i].discountPercent = 0;
            _bloc.listOrder[i].discountPercentByHand = 0;
            _bloc.listOrder[i].ckntByHand = 0;
            _bloc.listOrder[i].ck = 0;
            _bloc.listOrder[i].cknt = 0;
            _bloc.listOrder[i].discountByHand = false;
            
            // ✅ Reset về giá gốc - ĐẢM BẢO UI HIỂN THỊ ĐÚNG
            _bloc.listOrder[i].giaSuaDoi = originalPrice; // Giá gốc
            _bloc.listOrder[i].price = originalPrice; // Giá gốc
            _bloc.listOrder[i].priceAfter = originalPrice; // Giá sau = giá gốc (không còn chiết khấu)
            _bloc.listOrder[i].priceAfter2 = originalPrice;
            
            DataLocal.listOrderCalculatorDiscount.removeWhere(
              (element) => element.code.toString().trim() == productCode.toString().trim()
            );
            
            hasChanges = true;
            print('💰 [${i}] RESET DONE: originalPrice=$originalPrice, priceAfter=$originalPrice, discountPercent=0');
          }
        }
      }
    }
    
    print('💰 _applySingleCKG result: foundProducts=$foundProducts, hasChanges=$hasChanges');
    if (foundProducts == 0) {
      print('💰 ⚠️ WARNING: No products found with code=$productCode in cart!');
      print('💰 Available product codes: ${_bloc.listOrder.map((e) => e.code).toList()}');
      print('💰 ⚠️ This means the discount will NOT be applied!');
    }
    
    // ✅ FORCE UI UPDATE NGAY - LUÔN gọi setState() khi có product được tìm thấy
    if (foundProducts > 0) {
      print('💰 ✅ Found $foundProducts product(s), applying discount changes');
      print('💰 Force UI rebuild for CKG change (hasChanges=$hasChanges, foundProducts=$foundProducts)');
      
      // ✅ CRITICAL: Tính lại total LOCAL
      _recalculateTotalLocal();
      // ✅ Đồng bộ listOrder -> listProductOrderAndUpdate để UI dùng chung dữ liệu mới nhất
      _syncListOrderToUI();
      
      // ✅ KHÔNG GỌI API NGAY KHI CLICK - Chỉ update UI local
      // API sẽ được gọi khi user đóng bottom sheet (batch update)
      // if (shouldApply) {
      //   print('💰 Calling API to apply new CKG discount');
      //   _needReapplyHHAfterReload = true;
      //   _reloadDiscountsFromBackend();
      // }
      
      // ✅ CRITICAL: LUÔN gọi setState() để force UI rebuild khi có product được update
      print('💰 Calling setState() to rebuild UI');
      setState(() {});
    } else {
      print('💰 ⚠️ WARNING: No products found! hasChanges=$hasChanges, foundProducts=$foundProducts');
      print('💰 ⚠️ UI will NOT be updated because no products were found!');
      // Still call setState to ensure UI is aware of the change attempt
      setState(() {});
    }
  }

  // Note: Hệ thống voucher mới cho phép user chọn NHIỀU chiết khấu cùng lúc:
  // - CKG: Checkbox selection (MULTIPLE - chọn nhiều CKG)
  // - HH: Checkbox selection (MULTIPLE - chọn nhiều HH)
  // - CKN: Checkbox selection (MULTIPLE - chọn nhiều nhóm CKN) + gift dialog
  void _showCknDiscountFlow() async {
    // Step 1: Show discount name selection popup
    final discountResult = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CknDiscountSelectionDialog(
        listCknDiscounts: _bloc.listCkn,
        selectedDiscountName: _bloc.selectedDiscountGroup,
      ),
    );

    if (discountResult == null) return;

    final String discountName = discountResult['discountName'];
    final String groupDk = discountResult['groupDk'];
    final double totalQuantity = discountResult['totalQuantity'];
    final List<ListCkMatHang> discountItems = discountResult['items'];

    // Save selected discount group
    _bloc.selectedDiscountGroup = groupDk;

    // Save pending state for BlocListener
    setState(() {
      _pendingDiscountName = discountName;
      _pendingMaxQuantity = totalQuantity;
      _pendingDiscountItems = discountItems;
    });

    // Step 2: Call API to get gift product list (truyền group_dk vào API)
    // BlocListener sẽ tự động show popup khi có GetGiftProductListSuccess
    // ✅ Hiển thị loading dialog
    _showLoadingDialog('Đang tải danh sách sản phẩm tặng...');
    _bloc.add(GetGiftProductListEvent(maNhom: groupDk));
  }

  // Hiển thị loading dialog
  void _showLoadingDialog(String message) {
    if (!_isLoadingGiftProducts) {
      _isLoadingGiftProducts = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false, // Ngăn user đóng dialog bằng back button
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  // Ẩn loading dialog
  void _hideLoadingDialog() {
    if (_isLoadingGiftProducts) {
      _isLoadingGiftProducts = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showGiftProductSelectionPopup({
    required String discountName,
    required double maxQuantity,
    required List<ListCkMatHang> discountItems,
    required String discountType, // 'CKN' or 'CKTDTH'
  }) async {
    // Load existing selections
    Map<String, double> initialSelections = {};
    final currentSttRecCk = discountItems.first.sttRecCk?.toString().trim();
    
    print('🔍 $discountType Debug: Loading initial selections for sttRecCk: $currentSttRecCk');
    print('🔍 $discountType Debug: DataLocal.listProductGift has ${DataLocal.listProductGift.length} items');
    
    for (var gift in DataLocal.listProductGift) {
      print('🔍 $discountType Debug: Checking gift - code: ${gift.code}, typeCK: ${gift.typeCK}, sttRecCK: ${gift.sttRecCK}, maCk: ${gift.maCk}');
      if (gift.typeCK == discountType && gift.sttRecCK?.toString().trim() == currentSttRecCk) {
        final code = (gift.code ?? '').trim();
        initialSelections[code] = gift.count ?? 0;
        print('🔍 $discountType Debug: ✅ Found matching $discountType - code: $code, quantity: ${gift.count}');
      }
    }
    
    print('🔍 CKN Debug: initialSelections: $initialSelections');

    // Show popup
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => CknGiftProductSelectionDialog(
        giftProducts: _bloc.listGiftProducts,
        discountName: discountName,
        maxQuantity: maxQuantity,
        initialSelections: initialSelections,
      ),
    );

    if (result == null || result.isEmpty) return;

    // Process selected products
    _processSelectedGiftProducts(result, discountItems.first, discountType);
  }

  void _processSelectedGiftProducts(
    Map<String, double> selectedQuantities,
    ListCkMatHang discountItem,
    String discountType, // 'CKN' or 'CKTDTH'
  ) {
    try {
      print('🎁 $discountType Debug: Processing selected gift products');
      print('🎁 $discountType Debug: Discount maCk: ${discountItem.maCk}');
      print('🎁 $discountType Debug: Before - listProductGift has ${DataLocal.listProductGift.length} items');
      
      // Step 1: Remove all existing products from same discount group (CKN or CKTDTH)
      int removedCount = 0;
      DataLocal.listProductGift.removeWhere((item) {
        if (item.typeCK == discountType && item.sttRecCK == discountItem.sttRecCk.toString().trim()) {
          _bloc.totalProductGift -= item.count ?? 0;
          removedCount++;
          print('🎁 $discountType Debug: ❌ Removed old product: ${item.code} (qty: ${item.count})');
          return true;
        }
        return false;
      });
      print('🎁 $discountType Debug: Removed total: $removedCount products');

      // Step 2: Add all newly selected products
      int addedCount = 0;
      for (var entry in selectedQuantities.entries) {
        final productCode = entry.key.trim();
        final quantity = entry.value;
        
        if (quantity <= 0) continue;

        // Find product info from API result
        final giftProduct = _bloc.listGiftProducts.firstWhere(
          (item) => (item.maVt ?? '').trim() == productCode,
          orElse: () => GiftProductItem(),
        );

        final productName = giftProduct.tenVt ?? 'Sản phẩm tặng';

        // Create gift product object
        SearchItemResponseData gift = SearchItemResponseData(
          code: productCode,
          sttRec0: discountItem.sttRecCk.toString().trim(),
          name: productName,
          name2: productName,
          dvt: '',
          price: 0,
          discountPercent: 0,
          priceAfter: 0,
          count: quantity,
          maCk: discountItem.maCk.toString().trim(),
          maCkOld: discountItem.maCk.toString(),
          maVtGoc: discountItem.maVt.toString().trim(),
          sctGoc: discountItem.sttRecCk.toString().trim(),
          sttRecCK: discountItem.sttRecCk.toString().trim(),
          typeCK: discountType, // 'CKN' or 'CKTDTH'
          gifProduct: true,
          stockAmount: 0,
          isMark: 1,
        );

        print('🎁 $discountType Debug: ✅ Adding product: $productCode (qty: $quantity)');
        
        // Add directly to list (old products already removed above)
        DataLocal.listProductGift.add(gift);
        _bloc.totalProductGift += quantity;
        addedCount++;
      }

      print('🎁 $discountType Debug: After - listProductGift has ${DataLocal.listProductGift.length} items');
      print('🎁 $discountType Debug: Total products added: $addedCount');

      // Step 3: Trigger UI update via setState (no need for BLoC event)
      setState(() {});

      if (addedCount > 0) {
        Utils.showCustomToast(
          context,
          Icons.check_circle_outline,
          'Đã cập nhật $addedCount sản phẩm tặng'
        );
      }
    } catch (e) {
      print('🎁 CKN Debug: ❌ Error: $e');
      Utils.showCustomToast(
        context,
        Icons.error_outline,
        'Có lỗi xảy ra: $e'
      );
    }
  }

  buildListViewProductGift(){
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: DataLocal.listProductGift.length,
        itemBuilder: (context,index){
          return Slidable(
              key: const ValueKey(1),
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                // extentRatio: 0.25,
                dragDismissible: false,
                children: [
                  Visibility(
                    visible: Const.isVv == true,
                    child: SlidableAction(
                      onPressed:(_) {
                        setState(() {
                          if(DataLocal.listProductGift[index].chooseVuViec == true){
                            DataLocal.listProductGift[index].chooseVuViec = false;
                            DataLocal.listProductGift[index].idVv = '';
                            DataLocal.listProductGift[index].idHd = '';
                            DataLocal.listProductGift[index].nameVv = '';
                            DataLocal.listProductGift[index].nameHd = '';
                            DataLocal.listProductGift[index].idHdForVv = '';
                            Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã huỷ áp dụng CTBH cho mặt hàng này');
                          }
                          else{
                            showModalBottomSheet(
                                context: context,
                                isDismissible: true,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
                                ),
                                backgroundColor: Colors.white,
                                builder: (builder){
                                  return buildPopupVvHd();
                                }
                            ).then((value){
                              if(value != null){
                                if(value[0] == 'ReLoad' && value[1] != '' && value[1] !='null'){
                                  setState(() {
                                    DataLocal.listProductGift[index].chooseVuViec = true;
                                    DataLocal.listProductGift[index].idVv = _bloc.idVv;
                                    DataLocal.listProductGift[index].nameVv = _bloc.nameVv;
                                    DataLocal.listProductGift[index].idHd = _bloc.idHd;
                                    DataLocal.listProductGift[index].nameHd = _bloc.nameHd;
                                    DataLocal.listProductGift[index].idHdForVv = _bloc.idHdForVv;
                                  });
                                }else{
                                  DataLocal.listProductGift[index].chooseVuViec = false;
                                }
                              }else{
                                DataLocal.listProductGift[index].chooseVuViec = false;
                              }
                            });
                          }
                        });
                      },
                      borderRadius:const BorderRadius.all(Radius.circular(8)),
                      backgroundColor: DataLocal.listProductGift[index].chooseVuViec == false ? const Color(0xFFA8B1A6) : const Color(
                          0xFF2DC703),
                      foregroundColor: Colors.white,
                      icon: Icons.description,
                      label: 'CTBH',
                    ),
                  )
                ],
              ),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                // extentRatio: 0.25,
                dragDismissible: false,
                children: [
                  SlidableAction(
                    onPressed:(_) {
                      final deletedItem = DataLocal.listProductGift[index];
                      
                      // Reset CKN selection if deleting a CKN product
                      if(deletedItem.typeCK == 'CKN'){
                        final deletedSttRecCk = deletedItem.sttRecCK?.toString().trim();
                        
                        // Check if there are any other CKN products with same sttRecCK
                        final hasOtherProductsInSameGroup = DataLocal.listProductGift.any((item) =>
                          item.typeCK == 'CKN' && 
                          item.sttRecCK?.toString().trim() == deletedSttRecCk &&
                          item.code != deletedItem.code
                        );
                        
                        print('🔍 CKN Debug: Deleting CKN product - code: ${deletedItem.code}, sttRecCk: $deletedSttRecCk');
                        print('🔍 CKN Debug: hasOtherProductsInSameGroup: $hasOtherProductsInSameGroup');
                        
                        // If this is the last product in the group, clear selection
                        if (!hasOtherProductsInSameGroup) {
                          print('🔍 CKN Debug: Last product in group! Clearing selectedDiscountGroup');
                          _bloc.selectedDiscountGroup = null;
                        }
                        
                        _bloc.selectedCknProductCode = null;
                        _bloc.selectedCknSttRecCk = null;
                      }
                      
                      _bloc.totalProductGift = _bloc.totalProductGift - deletedItem.count!;
                      _bloc.add(AddOrDeleteProductGiftEvent(false, deletedItem));
                    },
                    borderRadius:const BorderRadius.all(Radius.circular(8)),
                    backgroundColor: const Color(0xFFC90000),
                    foregroundColor: Colors.white,
                    icon: Icons.delete_forever,
                    label: 'Delete',
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: Const.lockStockInItemGift == true ? null : (){
                  gift = true;
                  indexSelectGift = index;
                  _bloc.add(GetListStockEvent(
                      itemCode: DataLocal.listProductGift[index].code.toString(),
                      getListGroup: false,
                      lockInputToCart: true,
                      checkStockEmployee: Const.checkStockEmployee == true ? true : false));
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
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(6)),
                              color:  const Color(0xFF0EBB00),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    offset: const Offset(2, 4),
                                    blurRadius: 5,
                                    spreadRadius: 2)
                              ],),
                            child: const Icon(Icons.card_giftcard_rounded ,size: 16,color: Colors.white,)),
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
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '[${DataLocal.listProductGift[index].code.toString().trim()}] ',
                                                style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                    0xff555a55)),
                                              ),
                                              TextSpan(
                                                text: DataLocal.listProductGift[index].name.toString().trim(),
                                                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                    const SizedBox(width: 10,),
                                    Column(
                                      children: [
                                        (DataLocal.listProductGift[index].price! > 0 && DataLocal.listProductGift[index].price == DataLocal.listProductGift[index].priceAfter ) ?
                                        Container()
                                            :
                                        Text(
                                          ((widget.currencyCode == "VND"
                                              ?
                                          DataLocal.listProductGift[index].price
                                              :
                                          DataLocal.listProductGift[index].price))
                                              == 0 ? 'Giá đang cập nhật' : '${widget.currencyCode == "VND"
                                              ?
                                          Utils.formatMoneyStringToDouble(DataLocal.listProductGift[index].price??0)
                                              :
                                          Utils.formatMoneyStringToDouble(DataLocal.listProductGift[index].price??0)} ₫'
                                          ,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(color:
                                          ((widget.currencyCode == "VND"
                                              ?
                                          DataLocal.listProductGift[index].price
                                              :
                                          DataLocal.listProductGift[index].price)) == 0
                                              ?
                                          Colors.grey : Colors.red, fontSize: 10, decoration: ((widget.currencyCode == "VND"
                                              ?
                                          DataLocal.listProductGift[index].price
                                              :
                                          DataLocal.listProductGift[index].price)) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                        ),
                                        const SizedBox(height: 3,),
                                        Visibility(
                                          visible: DataLocal.listProductGift[index].priceAfter! > 0,
                                          child: Text(
                                            '${Utils.formatMoneyStringToDouble(DataLocal.listProductGift[index].priceAfter??0)} ₫',
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
                                    Const.lockStockInItemGift == false
                                        ? Flexible(
                                        child:
                                        Padding(padding:const EdgeInsets.only(right: 20), child:Text(
                                          '${(DataLocal.listProductGift[index].stockName.toString().isNotEmpty && DataLocal.listProductGift[index].stockName.toString() != 'null') ? DataLocal.listProductGift[index].stockName : 'Chọn kho xuất hàng'}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:
                                          (DataLocal.listProductGift[index].stockName.toString().isNotEmpty && DataLocal.listProductGift[index].stockName.toString() != 'null')
                                              ?
                                          const Color(0xff358032)
                                              :
                                          Colors.red
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),)) :
                                    Container(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'KL Tặng:',
                                          style: TextStyle(color: DataLocal.listProductGift[index].gifProduct == true ? Colors.red : Colors.black.withOpacity(0.7), fontSize: 11),
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text("${DataLocal.listProductGift[index].count??0} (${DataLocal.listProductGift[index].dvt.toString().trim()})",
                                          style: TextStyle(color: DataLocal.listProductGift[index].gifProduct == true ? Colors.red : blue, fontSize: 12),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: Const.noteForEachProduct == true,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Ghi chú: ${DataLocal.listProductGift[index].note}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color: Colors.grey
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: Const.isVv == true || Const.isHd == true,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: Const.lockStockInItem == false ? 0 : 5),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Visibility(
                                                visible: Const.isVv == true,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Chương trình bán hàng:',
                                                      style: TextStyle(color: Colors.blueGrey, fontSize: 11),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Flexible(
                                                        child:
                                                        Text(
                                                          '${(DataLocal.listProductGift[index].idVv.toString() != '' && DataLocal.listProductGift[index].idVv.toString() != 'null') ? DataLocal.listProductGift[index].nameVv : 'Chọn Chương trình bán hàng'}',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:
                                                          (DataLocal.listProductGift[index].idVv.toString() != '' && DataLocal.listProductGift[index].idVv.toString() != 'null')
                                                              ?
                                                          Colors.blueGrey
                                                              :
                                                          Colors.red
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: Const.isHd == true,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Hợp đồng:',
                                                      style: TextStyle(color: Colors.blueGrey, fontSize: 11),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Flexible(
                                                        child:
                                                        Text(
                                                          '${(DataLocal.listProductGift[index].idHd.toString().isNotEmpty && DataLocal.listProductGift[index].idHd.toString() != 'null') ? DataLocal.listProductGift[index].nameHd : 'Chọn hợp đồng'}',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:
                                                          (DataLocal.listProductGift[index].idHd.toString().isNotEmpty && DataLocal.listProductGift[index].idHd.toString() != 'null') == true
                                                              ?
                                                          Colors.blueGrey
                                                              :
                                                          Colors.red
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 5,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'KL Tặng:',
                                              style: TextStyle(color: DataLocal.listProductGift[index].gifProduct == true ? Colors.red : Colors.black.withOpacity(0.7), fontSize: 11),
                                              textAlign: TextAlign.left,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text("${DataLocal.listProductGift[index].count??0} (${DataLocal.listProductGift[index].dvt.toString().trim()})",
                                              style: TextStyle(color: DataLocal.listProductGift[index].gifProduct == true ? Colors.red : blue, fontSize: 12),
                                              textAlign: TextAlign.left,
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
                ),
              )
          );
        }

    );
  }

  buildListViewProduct(){
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _bloc.listOrder.length,
        itemBuilder: (context,index){
          return Slidable(
              key: const ValueKey(1),
              startActionPane: Const.isVv == true
                  ? ActionPane(
                      motion: const ScrollMotion(),
                      dragDismissible: false,
                      children: [
                        SlidableAction(
                          onPressed:(_) {
                            setState(() {
                              if(_bloc.listOrder[index].chooseVuViec == true){
                                _bloc.listOrder[index].chooseVuViec = false;
                                _bloc.listOrder[index].idVv = '';
                                _bloc.listOrder[index].idHd = '';
                                _bloc.listOrder[index].nameVv = '';
                                _bloc.listOrder[index].nameHd = '';
                                _bloc.listOrder[index].idHdForVv = '';
                                Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã huỷ áp dụng CTBH cho mặt hàng này');
                              }
                              else{
                                showModalBottomSheet(
                                    context: context,
                                    isDismissible: true,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
                                    ),
                                    backgroundColor: Colors.white,
                                    builder: (builder){
                                      return buildPopupVvHd();
                                    }
                                ).then((value){
                                  if(value != null){
                                    if(value[0] == 'ReLoad' && value[1] != '' && value[1] !='null'){
                                      _bloc.listOrder[index].chooseVuViec = true;
                                      _bloc.listOrder[index].idVv = _bloc.idVv;
                                      _bloc.listOrder[index].nameVv = _bloc.nameVv;
                                      _bloc.listOrder[index].idHd = _bloc.idHd;
                                      _bloc.listOrder[index].nameHd = _bloc.nameHd;
                                      _bloc.listOrder[index].idHdForVv = _bloc.idHdForVv;
                                      _bloc.add(CalculatorDiscountEvent(addOnProduct: true,product: _bloc.listOrder[index],reLoad: false, addTax: false));
                                    }else{
                                      _bloc.listOrder[index].chooseVuViec = false;
                                    }
                                  }
                                  else{
                                    _bloc.listOrder[index].chooseVuViec = false;
                                  }
                                });
                              }
                            });
                          },
                          borderRadius:const BorderRadius.all(Radius.circular(8)),
                          padding:const EdgeInsets.all(10),
                          backgroundColor: _bloc.listOrder[index].chooseVuViec == false ? const Color(0xFFA8B1A6) : const Color(0xFF2DC703),
                          foregroundColor: Colors.white,
                          icon: Icons.description,
                          label: 'CTBH', /// VV & HĐ
                        ),
                      ],
                    )
                  : null,
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                dragDismissible: false,
                children: [
                  Visibility(
                    visible: _bloc.listOrder[index].gifProduct != true,
                    child: SlidableAction(
                      onPressed:(_) {
                        if(widget.isContractCreateOrder == true){
                          // Tìm giá trị LỚN NHẤT của availableQuantity trong các items cùng maVt2
                          // Đây mới là TỔNG khả dụng gốc ban đầu
                          double totalAvailableForMaVt2 = 0;
                          for (var item in _bloc.listOrder) {
                            if (item.maVt2 == _bloc.listOrder[index].maVt2) {
                              double itemAvailable = item.availableQuantity ?? item.so_luong_kd;
                              if (itemAvailable > totalAvailableForMaVt2) {
                                totalAvailableForMaVt2 = itemAvailable;
                              }
                            }
                          }
                          
                          // Tính TỔNG số lượng đã đặt của TẤT CẢ items cùng maVt2
                          double totalOrderedForMaVt2 = 0;
                          for (var item in _bloc.listOrder) {
                            if (item.maVt2 == _bloc.listOrder[index].maVt2) {
                              totalOrderedForMaVt2 += item.count ?? 0;
                            }
                          }
                          
                          // B = Số còn lại CHUNG = Tổng khả dụng - Tổng đã đặt (TẤT CẢ)
                          double remainingAvailableForAll = (totalAvailableForMaVt2 - totalOrderedForMaVt2).clamp(0, totalAvailableForMaVt2);
                          
                          // Tính TỔNG số lượng đã đặt của các items KHÁC (để tính Max)
                          double totalOrderedExcludingCurrent = 0;
                          for (var item in _bloc.listOrder) {
                            if (item.maVt2 == _bloc.listOrder[index].maVt2 && item.sttRec0 != _bloc.listOrder[index].sttRec0) {
                              totalOrderedExcludingCurrent += item.count ?? 0;
                            }
                          }
                          
                          // Max = Tổng khả dụng - Số đã đặt (items KHÁC)
                          double maxCanOrder = totalAvailableForMaVt2 - totalOrderedExcludingCurrent;
                          
                          showChangeQuantityPopup(
                            context: context,
                            originalQuantity: maxCanOrder, // Max validation
                            productName: _bloc.listOrder[index].name,
                            onConfirmed: (newQty) {
                              gift = false;
                              _bloc.listOrder[index].count = newQty;
                              indexSelect = index;
                              itemSelect = _bloc.listOrder[index];
                              Product production = Product(
                                code: itemSelect.code,
                                sttRec0: itemSelect.sttRec0,
                                name: itemSelect.name,
                                name2:itemSelect.name2,
                                dvt:  itemSelect.dvt,
                                description:itemSelect.descript,
                                price: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice,
                                priceAfter:  itemSelect.priceAfter ,
                                discountPercent:itemSelect.discountPercent,
                                stockAmount:itemSelect.stockAmount,
                                taxPercent:itemSelect.taxPercent,
                                imageUrl:itemSelect.imageUrl ?? '',
                                count:itemSelect.count,
                                countMax: itemSelect.countMax,
                                isMark: itemSelect.isMark,
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
                                availableQuantity: totalAvailableForMaVt2, // Giữ tổng khả dụng gốc cho maVt2
                                contentDvt: itemSelect.contentDvt,
                                kColorFormatAlphaB: itemSelect.kColorFormatAlphaB?.value,
                                codeStock: itemSelect.stockCode,
                                nameStock: itemSelect.stockName,
                                editPrice:  0,
                                isSanXuat: ( 0),
                                isCheBien: ( 0),   
                                giaSuaDoi: itemSelect.giaSuaDoi,
                                giaGui: itemSelect.giaGui,
                                priceMin: _bloc.listStockResponse.isNotEmpty ? _bloc.listStockResponse[0].priceMin??0 : 0,
                                note: itemSelect.note,
                                jsonOtherInfo: itemSelect.jsonOtherInfo,
                                heSo: itemSelect.heSo,
                                idNVKD: itemSelect.idNVKD,
                                nameNVKD:itemSelect.nameNVKD,
                                nuocsx:itemSelect.nuocsx,
                                quycach:itemSelect.quycach,
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
                                maVt2: itemSelect.maVt2,
                                so_luong_kd: itemSelect.so_luong_kd,
                              );
                              _bloc.add(UpdateProductCount(
                                index: indexSelect,
                                count: double.parse(newQty.toString()),
                                addOrderFromCheckIn:  widget.orderFromCheckIn,
                                product: production,
                                stockCodeOld: itemSelect.stockCode.toString().trim(),
                              ));
                            },
                            maVt2: _bloc.listOrder[index].maVt2 ?? '',
                            listOrder: _bloc.listOrder,
                            currentQuantity: _bloc.listOrder[index].count ?? 0,
                            availableQuantity: maxCanOrder, // A + B = Tối đa có thể đặt
                          );
                        }else{
                          gift = false;
                          indexSelect = index;
                          itemSelect = _bloc.listOrder[index];
                          _bloc.add(GetListStockEvent(
                              itemCode: _bloc.listOrder[index].code.toString(),
                              getListGroup: false,
                              lockInputToCart: false,
                              checkStockEmployee: Const.checkStockEmployee == true ? true : false));
                        }
                      },
                      borderRadius:const BorderRadius.all(Radius.circular(8)),
                      padding:const EdgeInsets.all(10),
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.edit_calendar_outlined,
                      label: 'Sửa',
                    ),
                  ),
                  const SizedBox(width: 2,),
                  Visibility(
                    visible: _bloc.listOrder[index].gifProduct != true,
                    child: SlidableAction(
                      onPressed:(_) {
                        itemSelect = _bloc.listOrder[index];
                        
                        // ✅ FIX: Clean up DataLocal.listCKVT properly khi xóa product
                        if(DataLocal.listCKVT.isNotEmpty) {
                          String productCode = itemSelect.code.toString().trim();
                          
                          // Remove ALL discounts related to this product (check cả sttRecCK và sctGoc)
                          List<String> ckList = DataLocal.listCKVT.split(',').where((s) => s.isNotEmpty).toList();
                          ckList.removeWhere((item) {
                            // Format: "sttRecCk-productCode"
                            return item.endsWith('-$productCode');
                          });
                          DataLocal.listCKVT = ckList.join(',');
                          
                          print('💰 Removed product $productCode from listCKVT, new value: ${DataLocal.listCKVT}');
                          
                          // Also clear from BLoC state
                          _bloc.selectedCkgIds.removeWhere((id) => 
                            _bloc.listCkg.any((ckg) => 
                              ckg.sttRecCk == id && ckg.maVt?.trim() == productCode
                            )
                          );
                        }
                        
                        _bloc.add(DeleteProductFromDB(false,index,_bloc.listOrder[index].code.toString(),_bloc.listOrder[index].stockCode.toString()));
                        _bloc.add(GetListProductFromDB(addOrderFromCheckIn: false, getValuesTax: false,key: ''));
                      },
                      borderRadius:const BorderRadius.all(Radius.circular(8)),
                      padding:const EdgeInsets.all(10),
                      backgroundColor: const Color(0xFFC90000),
                      foregroundColor: Colors.white,
                      icon: Icons.delete_forever,
                      label: 'Xoá',
                    ),
                  ),
                ],
              ),
              child: Card(
                semanticContainer: true,
                margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _bloc.listOrder[index].gifProduct == true  || _bloc.listOrder[index].gifProductByHand == true?
                        Container(
                            width: 100,
                            height: 130,
                            padding: const EdgeInsets.all(5),
                            child: const Icon(EneftyIcons.gift_outline ,size: 32,color: Color(0xFF0EBB00),))
                            :
                        Container(
                          width: 100,
                          height: 130,
                          decoration: const BoxDecoration(
                              borderRadius:BorderRadius.all( Radius.circular(6),)
                          ),
                          child: const Icon(EneftyIcons.image_outline,size: 50,weight: 0.6,),
                          //Image.network('https://i.pinimg.com/564x/49/77/91/4977919321475b060fcdd89504cee992.jpg',fit: BoxFit.contain,),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5,right: 6,bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '[${_bloc.listOrder[index].code.toString().trim()}] ${_bloc.listOrder[index].name.toString().toUpperCase()}',
                                  style:const TextStyle(color: subColor, fontSize: 14, fontWeight: FontWeight.w600,),
                                  maxLines: 2,overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5,),
                                Visibility(
                                  visible: (_bloc.listOrder[index].thueSuat ?? 0.0) > 0,
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
                                          'Thuế: ${_formatTaxRate(_bloc.listOrder[index].thueSuat ?? 0)}%',
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _bloc.listOrder[index].gifProduct == true || _bloc.listOrder[index].gifProductByHand == true? const Icon(EneftyIcons.card_tick_outline,color: Color(0xFF0EBB00),size: 15,) : const Icon(FluentIcons.cart_16_filled),
                                    const SizedBox(width: 5,),
                                    Expanded(
                                      flex: 3,
                                      child: SizedBox(
                                        height: 13,
                                        child:(_bloc.listOrder[index].gifProduct != true  && _bloc.listOrder[index].gifProductByHand != true)
                                            ?
                                        Text(
                                          '${(_bloc.listOrder[index].stockName.toString().isNotEmpty && _bloc.listOrder[index].stockName.toString() != 'null') ? _bloc.listOrder[index].stockName : 'Chọn kho xuất hàng'}',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(color: Colors.blueGrey,fontSize: 12
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                            :
                                        const Text('Hàng khuyến mãi kèm theo',style: TextStyle(color: Color(0xFF0EBB00),fontSize: 13),),
                                      ),
                                    ),
                                    Const.typeProduction == true ? Expanded(
                                      flex: 4,
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 10,),
                                          Container(
                                            height: 13,
                                            width: 1.5,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text(
                                              'Loại: ${_bloc.listOrder[index].isSanXuat == true ? 'Sản xuất' : _bloc.listOrder[index].isCheBien == true ? 'Chế biến' :'Thường'}',
                                              style:const TextStyle(color: Colors.blueGrey,fontSize: 12), textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      )
                                    ) : Container()
                                  ],
                                ),
                                Visibility(
                                  visible: Const.isVv == true || Const.isHd == true,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(FluentIcons.clipboard_task_list_ltr_20_filled),
                                        const SizedBox(width: 5,),
                                        Visibility(
                                          visible: Const.isVv == true,
                                          child: Expanded(
                                            child: SizedBox(
                                                height: 13,
                                                child:   Text(
                                                  '${(_bloc.listOrder[index].idVv.toString() != '' && _bloc.listOrder[index].idVv.toString() != 'null') ? _bloc.listOrder[index].nameVv : 'Chương trình bán hàng'}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(color: Colors.blueGrey,fontSize: 12
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                )
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: Const.isHd == true,
                                          child: Expanded(
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 10,),
                                                Container(
                                                  height: 13,
                                                  width: 1.5,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 10,),
                                                Text(
                                                  '${(_bloc.listOrder[index].idHd.toString().isNotEmpty && _bloc.listOrder[index].idHd.toString() != 'null') ? _bloc.listOrder[index].nameHd : 'Hợp đồng'}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(color: Colors.blueGrey,fontSize: 12
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _bloc.listOrder[index].giaGui  > 0 ||  _bloc.listOrder[index].giaSuaDoi > 0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(EneftyIcons.money_recive_bold),
                                        const SizedBox(width: 5,),
                                        Expanded(
                                          flex: 3,
                                          child: _bloc.listOrder[index].giaSuaDoi > 0 ? SizedBox(
                                              height: 13,
                                              child: Builder(
                                                builder: (context) {
                                                  final discountPercent = _bloc.listOrder[index].discountPercentByHand > 0 
                                                    ? _bloc.listOrder[index].discountPercentByHand 
                                                    : (_bloc.listOrder[index].discountPercent ?? 0);
                                                  
                                                  return Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:'Giá bán: \$${Utils.formatMoneyStringToDouble(_bloc.listOrder[index].giaSuaDoi)}',
                                                      style: const TextStyle(color: Colors.blueGrey,fontSize: 12, overflow: TextOverflow.ellipsis,),
                                                    ),
                                                        if (discountPercent > 0)
                                                    TextSpan(
                                                            text: '  (-${discountPercent.toStringAsFixed(1)} %)',
                                                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 11, color: Colors.red),
                                                    ),
                                                  ],
                                                ),
                                                  );
                                                },
                                              )
                                          )
                                              :
                                          SizedBox(
                                              height: 13,
                                              child: Text('Giá Gửi: \$${Utils.formatMoneyStringToDouble(_bloc.listOrder[index].giaGui??0)}',
                                                textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis,)
                                          ),
                                        ),
                                        Visibility(
                                          visible: _bloc.listOrder[index].giaGui > 0 &&  _bloc.listOrder[index].giaSuaDoi > 0,
                                          child: Expanded(
                                            flex: 4,
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 10,),
                                                Container(
                                                  height: 13,
                                                  width: 1.5,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 10,),
                                                SizedBox(
                                                    height: 13,
                                                    child: Text('Giá thu: \$${Utils.formatMoneyStringToDouble(_bloc.listOrder[index].giaGui)}',
                                                      textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: (_bloc.listOrder[index].giaGui > 0 ||  _bloc.listOrder[index].giaSuaDoi > 0) ? 0 : 5),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 35,
                                          padding: const EdgeInsets.only(left: 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Visibility(
                                                visible: _bloc.listOrder[index].gifProduct != true  && _bloc.listOrder[index].gifProductByHand != true,
                                                child: Row(
                                                  children: [
                                                    // ✅ Hiển thị giá gốc với gạch ngang khi có discount
                                                    Builder(
                                                      builder: (context) {
                                                        final discountPercent = _bloc.listOrder[index].discountPercentByHand > 0 
                                                          ? _bloc.listOrder[index].discountPercentByHand 
                                                          : (_bloc.listOrder[index].discountPercent ?? 0);
                                                        final hasDiscount = discountPercent > 0;
                                                        final originalPrice = _bloc.listOrder[index].giaSuaDoi ?? 0;
                                                        
                                                        if (!hasDiscount || originalPrice == 0) {
                                                          return Container();
                                                        }
                                                        
                                                        return Text(
                                                          '\$ ${Utils.formatMoneyStringToDouble(originalPrice * (_bloc.listOrder[index].count ?? 0))} ',
                                                      textAlign: TextAlign.left,
                                                          style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 10,
                                                            decoration: TextDecoration.lineThrough,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 5,),
                                                    // ✅ Hiển thị giá sau chiết khấu (hoặc giá gốc nếu không có discount)
                                                    Builder(
                                                      builder: (context) {
                                                        final discountPercent = _bloc.listOrder[index].discountPercentByHand > 0 
                                                          ? _bloc.listOrder[index].discountPercentByHand 
                                                          : (_bloc.listOrder[index].discountPercent ?? 0);
                                                        final hasDiscount = discountPercent > 0;
                                                        final originalPrice = _bloc.listOrder[index].giaSuaDoi ?? 0;
                                                        final priceAfter = _bloc.listOrder[index].priceAfter ?? 0;
                                                        
                                                        // ✅ Nếu có discount:
                                                        //   - Nếu priceAfter > 0 → hiển thị priceAfter
                                                        //   - Nếu priceAfter = 0 nhưng có discountPercent → tính lại từ originalPrice
                                                        //   - Nếu không có discount → hiển thị giá gốc
                                                        double displayPrice;
                                                        if (hasDiscount) {
                                                          if (priceAfter > 0) {
                                                            displayPrice = priceAfter;
                                                          } else if (originalPrice > 0 && discountPercent > 0) {
                                                            // Tính lại priceAfter từ originalPrice và discountPercent
                                                            displayPrice = originalPrice - (originalPrice * discountPercent / 100);
                                                            if (displayPrice < 0) displayPrice = 0;
                                                          } else {
                                                            displayPrice = originalPrice;
                                                          }
                                                        } else {
                                                          displayPrice = originalPrice;
                                                        }
                                                        
                                                        return Text(
                                                          displayPrice == 0 && originalPrice == 0
                                                            ? 'Giá đang cập nhật'
                                                            : '\$ ${Utils.formatMoneyStringToDouble(displayPrice * (_bloc.listOrder[index].count ?? 0))}',
                                                          textAlign: TextAlign.left,
                                                          style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      QuantityInfoBox(
                                        quantity: _bloc.listOrder[index].count?.toString() ?? '0',
                                        unit: _bloc.listOrder[index].dvt.toString(),
                                        isShowInfo: widget.isContractCreateOrder == true ? true : false,
                                        contractQuantity: widget.isContractCreateOrder == true
                                            ? () {
                                          // A = Số lượng hiện tại của item này
                                          double currentCount = _bloc.listOrder[index].count ?? 0;

                                          // Tìm giá trị LỚN NHẤT của availableQuantity trong các items cùng maVt2
                                          // Đây mới là TỔNG khả dụng gốc ban đầu
                                          double totalAvailableForMaVt2 = 0;
                                          for (var item in _bloc.listOrder) {
                                            if (item.maVt2 == _bloc.listOrder[index].maVt2) {
                                              double itemAvailable = item.availableQuantity ?? item.so_luong_kd;
                                              if (itemAvailable > totalAvailableForMaVt2) {
                                                totalAvailableForMaVt2 = itemAvailable;
                                              }
                                            }
                                          }

                                          // Tính TỔNG số lượng đã đặt của TẤT CẢ items cùng maVt2
                                          double totalOrderedForMaVt2 = 0;
                                          for (var item in _bloc.listOrder) {
                                            if (item.maVt2 == _bloc.listOrder[index].maVt2) {
                                              totalOrderedForMaVt2 += item.count ?? 0;
                                            }
                                          }

                                          // B = Số lượng còn lại CHUNG = Tổng khả dụng - Tổng đã đặt
                                          double remainingAvailable = (totalAvailableForMaVt2 - totalOrderedForMaVt2).clamp(0, totalAvailableForMaVt2);

                                          return '${Utils.formatQuantity(currentCount)}/${Utils.formatQuantity(remainingAvailable)}';
                                        }()
                                            : null,
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
                    Visibility(
                      visible: Const.noteForEachProduct == true && _bloc.listOrder[index].note.toString().trim().replaceAll('null', '').isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10,right: 10,top: 0,bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Ghi chú: ${_bloc.listOrder[index].note}',
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color: Colors.grey
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible:  Const.isBaoGia,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                        child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Thuế: ${_bloc.listOrder[index].tenThue.toString()}'),
                                  Text(_bloc.listOrder[index].thueSuat.toString()),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Nhân viên kinh doanh'),
                                  Text(_bloc.listOrder[index].nameNVKD.toString()),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Nước sản xuất'),
                                  Text(_bloc.listOrder[index].nuocsx.toString()),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Quy cách'),
                                  Text(_bloc.listOrder[index].quycach.toString()),
                                ],
                              ),
                            ]
                        ),
                      ),
                    ),
                  ],
                ),
              )
          );
        }
    );
  }

  buildInfo(){
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
            child: Text('Hãy kiểm tra thông tin khách hàng, ghi chú của đơn hàng trước khi lên đơn hàng nhé bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5,color: Colors.grey),),
          ),
          buildMethodReceive(),
        ],
      ),
    );
  }

  buildBill(){
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
            child: Text('Hãy kiểm tra thông tin thanh toán của đơn hàng trước khi lên đơn hàng nhé bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5,color: Colors.grey),),
          ),
          buildPaymentDetail(),
          Utils.buildLine(),
          buildOtherRequest(),
        ],
      ),
    );
  }

  buildMethodReceive(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16,right: 8,top: 10,bottom: 6),
          child: Row(
            children: [
              Icon(MdiIcons.truckFast,color: mainColor,),
              const SizedBox(width: 10,),
              const Text('Thông tin & Phương thức nhận hàng',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16,right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Thông tin nhận hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
              buildInfoCallOtherPeople(),
              const SizedBox(height: 14,),
              Utils.buildLine(),
              InkWell(
                onTap: (){
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return InputAddressPopup(note: (DataLocal.noteSell != '' && DataLocal.noteSell != "null") ? DataLocal.noteSell.toString() : "",
                          title: 'Thêm ghi chú cho đơn hàng',desc: 'Vui lòng nhập ghi chú',convertMoney: false, inputNumber: false,);
                      }).then((note){
                    if(note != null){
                      _bloc.add(AddNote(
                        note: note,
                      ));
                    }
                  });
                },
                child: SizedBox(
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5,left: 16,right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ghi chú:',style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic,decoration: TextDecoration.underline,fontSize: 12),),
                        const SizedBox(width: 12,),
                        Expanded(child: Align(
                            alignment: Alignment.centerRight,
                            child: Text((DataLocal.noteSell.isNotEmpty && DataLocal.noteSell != '' && DataLocal.noteSell != "null") ? DataLocal.noteSell.toString() : "Viết tin nhắn...",style: const TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,))),
                      ],
                    ),
                  ),
                ),
              ),
              Utils.buildLine(),
              Visibility(
                visible: Const.typeTransfer == true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14,),
                    Text('Loại giao dịch:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                    const SizedBox(height: 10,),
                    Container(
                        height: 45,
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey)
                        ),
                        child: (Const.woPrice == true && Const.allowsWoPriceAndTransactionType == false) ? Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text( Const.isWoPrice == false ? 'Bán lẻ' : 'Bán buôn',style: const TextStyle(fontSize: 12,color: Colors.black),),
                        )
                            :
                        transactionWidget()
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: maGD.toString().replaceAll('null', '').isNotEmpty && (maGD.toString().replaceAll('null', '') == '5' || maGD.toString().replaceAll('null', '') == '6'),
                child: CustomOrder(bloc: _bloc, idCustomer: DataLocal.infoCustomer.customerCode.toString(),),
              ),
              Visibility(
                  visible: Const.typeOrder == true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14,bottom: 10),
                    child: Text('Loại đơn hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                  )),
              Visibility(
                visible: Const.typeOrder == true,
                child: Padding(
                  padding:const EdgeInsets.only(top:10),
                  child: Container(
                      height: 45,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey)
                      ),
                      child: typeOrderWidget()
                  ),
                )
              ),
              Visibility(
                  visible: Const.chooseAgency == true && _bloc.showSelectAgency == true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14,bottom: 10),
                    child: Text('Thông tin đại lý:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                  )),
              Visibility(
                visible: Const.chooseAgency == true && _bloc.showSelectAgency == true,
                child: GestureDetector(
                  onTap: (){
                    PersistentNavBarNavigator.pushNewScreen(context, screen: const SearchCustomerScreen(selected: true,allowCustomerSearch: false,typeName: true, inputQuantity: false,),withNavBar: false).then((value){
                      if(value != null){
                        _bloc.chooseAgencyCode = false;
                        _bloc.add(PickInfoAgency(typeDiscount: '',codeAgency: '', nameAgency: '',cancelAgency: true));

                        ManagerCustomerResponseData infoCustomer = value;
                        _bloc.chooseAgencyCode = true;
                        _bloc.add(PickInfoAgency(typeDiscount: infoCustomer.typeDiscount,codeAgency: infoCustomer.customerCode, nameAgency: infoCustomer.customerName,cancelAgency: false));
                      }
                    });
                  },
                  child: Container(
                    height: 45,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey)
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_bloc.nameAgency??'Chọn đại lý bán hàng',style: const TextStyle(color: Colors.black,fontSize: 13),)),
                        _bloc.chooseAgencyCode == false ? const Icon(Icons.search, color: Colors.blueGrey,size: 20,) : InkWell(
                            onTap: (){
                              _bloc.chooseAgencyCode = false;
                              _bloc.add(PickInfoAgency(typeDiscount: '',codeAgency: '', nameAgency: '',cancelAgency: true));
                            },
                            child: const Icon(Icons.cancel_outlined, color: Colors.blueGrey,size: 20,)),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                  visible: Const.lockStockInCart == false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text('Kho xuất hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                  )),
              Visibility(
                  visible: Const.lockStockInCart == false,
                  child: const SizedBox(height: 10,)),
              Visibility(
                visible: Const.lockStockInCart == false,
                child: Container(
                    height: 45,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey)
                    ),
                    child: genderWidget()
                ),
              ),
              Visibility(
                visible: Const.isVvHd == true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10,top: 14),
                  child: Text('Loại Chương trình bán hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                ),
              ),
              Visibility(
                visible: Const.isVvHd == true,
                child: GestureDetector(
                  onTap: (){
                    showModalBottomSheet(
                        context: context,
                        isDismissible: true,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
                        ),
                        backgroundColor: Colors.white,
                        builder: (builder){
                          return buildPopupVvHd();
                        }
                    ).then((value){
                      if(value != null){
                        if(value[0] == 'ReLoad'){
                          setState(() {
                            _bloc.idVv = value[1];
                            _bloc.nameVv = value[2];
                            _bloc.idHd = value[3];
                            _bloc.nameHd = value[4];
                            _bloc.idHdForVv = value[5];
                          });
                        }
                      }
                    });
                  },
                  child: Container(
                      height: 45,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: Text((_bloc.nameVv.toString().trim() != '' && _bloc.nameVv.toString().trim() != 'null') ? _bloc.nameVv.toString().trim() : 'Chọn Chương trình bán hàng', style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                          const SizedBox(width: 8,),
                          Flexible(child: Text((_bloc.nameHd.toString().trim() != '' && _bloc.nameHd.toString().trim() != 'null') ? _bloc.nameHd.toString().trim() : 'Chọn loại hợp đồng', style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,))
                        ],
                      )
                  ),
                ),
              ),
              Visibility(
                  visible: Const.useTax == true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14,bottom: 10),
                    child: Text( Const.afterTax == true ? 'Áp dụng thuế sau chiết khấu cho đơn hàng:' : 'Áp dụng thuế trước chiết khấu cho đơn hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                  )),
              Visibility(
                visible: Const.useTax == true,
                child: Container(
                    height: 45,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey)
                    ),
                    child: genderTaxWidget()
                ),
              ),
              Visibility(
                  visible: Const.chooseTypePayment == true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14,bottom: 10),
                    child: Text('Loại hình thức thanh toán:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                  )),
              Visibility(
                visible: Const.chooseTypePayment == true,
                child: Container(
                    height: 45,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey)
                    ),
                    child: Row(
                      children: [
                        Expanded(child: typePaymentWidget()),
                        Visibility(
                            visible: _bloc.showDatePayment == true,
                            child: InkWell(
                              onTap: (){
                                Utils.dateTimePickerCustom(context).then((value){
                                  if(value != null){
                                    setState(() {
                                      DataLocal.datePayment = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                    });
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    Text(DataLocal.datePayment, style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                    const SizedBox(width: 5,),
                                    Icon(Icons.calendar_today_rounded,color: mainColor,size: 19,),
                                  ],
                                ),
                              ),
                            )
                        ),
                      ],
                    )
                ),
              ),
              Visibility(
                  visible: Const.chooseTypeDelivery == true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14,bottom: 10),
                    child: Text('Loại hình vận chuyển:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                  )),
              Visibility(
                visible: Const.chooseTypeDelivery == true,
                child: Container(
                    height: 45,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey)
                    ),
                    child: Row(
                      children: [
                        Expanded(child: typeChooseTypeDelivery()),
                      ],
                    )
                ),
              ),
              Visibility(
                  visible: Const.dateEstDelivery == true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14,bottom: 10),
                    child: Text('Dự kiến giao hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                  )),
              Visibility(
                visible: Const.dateEstDelivery == true,
                child: Container(
                  padding:const EdgeInsets.only(left: 12,right: 2,top: 10,bottom: 10),
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: grey.withOpacity(0.8),width: 1),
                      borderRadius: const BorderRadius.all(Radius.circular(8))
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            const Text('Ngày dự kiến giao hàng: ',style:  TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,),
                            const SizedBox(width: 5,),
                            Text(DataLocal.dateEstDelivery,style: const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                        SizedBox(
                          width: 50,
                          child: InkWell(
                            onTap: (){
                              Utils.dateTimePickerCustom(context).then((value){
                                if(value != null){
                                  setState(() {
                                    DataLocal.dateEstDelivery = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                  });
                                }
                              });
                            },
                            child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                          ),
                        ),
                      ]),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  buildInfoCallOtherPeople(){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(10),
              height: 40,
              width: double.infinity,
              color: Colors.amber.withOpacity(0.4),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Thông tin khách hàng',style: TextStyle(color: Colors.black,fontSize: 13),),
              ),
            ),
            const SizedBox(height: 22,),
            GestureDetector(
              onTap:(){
                if(widget.isContractCreateOrder == true){
                  return;
                }
                if((widget.orderFromCheckIn == false && widget.addInfoCheckIn != true)){
                  PersistentNavBarNavigator.pushNewScreen(context, screen: const SearchCustomerScreen(selected: true,allowCustomerSearch: true, inputQuantity: false,),withNavBar: false).then((value){
                    if(value != null){
                      DataLocal.infoCustomer = value;
                      _bloc.add(PickInfoCustomer(customerName: DataLocal.infoCustomer.customerName,phone: DataLocal.infoCustomer.phone,address: DataLocal.infoCustomer.address,codeCustomer: DataLocal.infoCustomer.customerCode));
                    }
                  });
                }
              },
              child: Stack(
                children: [
                  inputWidget(title:'Tên khách hàng',hideText: "Nguyễn Văn A",controller: nameCustomerController,focusNode: nameCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
                  Positioned(
                      top: 20,right: 10,
                      child: (widget.orderFromCheckIn == false && widget.addInfoCheckIn != true) ?  Icon(Icons.search_outlined,color: widget.isContractCreateOrder == true ? Colors.transparent : Colors.grey,size: 20,) : Container())
                ],
              ),
            ),
            inputWidget(title:"SĐT khách hàng",hideText: '0963 xxx xxx ',controller: phoneCustomerController,focusNode: phoneCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true),
            GestureDetector(
              onTap:(){
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      // ignore: unnecessary_null_comparison
                      return InputAddressPopup(note: addressCustomerController.text != null ? addressCustomerController.text.toString() : "",title: 'Địa chỉ KH',desc: 'Vui lòng nhập địa chỉ KH',convertMoney: false, inputNumber: false,);
                    }).then((note){
                  if(note != null){
                    setState(() {
                      addressCustomerController.text = note;
                    });
                  }
                });
              },
              child: Stack(
                children: [
                  inputWidget(title:'Địa chỉ khách hàng',hideText: "Vui lòng nhập địa chỉ KH",controller: addressCustomerController,focusNode: addressCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
                  const Positioned(
                      top: 20,right: 10,
                      child: Icon(Icons.edit,color: Colors.grey,size: 20,))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget typePaymentWidget() {
    return Utils.isEmpty(DataLocal.typePaymentList)
        ? const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        : DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          isDense: true,
          // iconEnabledColor: _bloc.showDatePayment == true ? Colors.transparent : Colors.black54,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: DataLocal.typePaymentList[_bloc.typePaymentIndex],
          items: DataLocal.typePaymentList.map((value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            DataLocal.valuesTypePayment = value.toString();
            _bloc.add(PickTypePayment(DataLocal.typePaymentList.indexOf(value!),  DataLocal.valuesTypePayment));
          }),
    );
  }

  Widget typeChooseTypeDelivery() {
    return Utils.isEmpty(DataLocal.listTypeDelivery)
        ? const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        : DropdownButtonHideUnderline(
      child: DropdownButton<ListTypeDelivery>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: DataLocal.listTypeDelivery[_bloc.typeDeliveryIndex < 0 ? 0 : _bloc.typeDeliveryIndex],
          items: DataLocal.listTypeDelivery.map((value) => DropdownMenuItem<ListTypeDelivery>(
            value: value,
            child: Text(value.nameTypeDelivery.toString(), style: const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            ListTypeDelivery item = value??ListTypeDelivery();
            _bloc.add(PickListTypeDeliveryEvent(item,DataLocal.listTypeDelivery.indexOf(item)));
          }),
    );
  }

  String maGD = '';
  Widget transactionWidget() {
    return Utils.isEmpty(Const.listTransactionsOrder)
        ?
    const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        :
    DropdownButtonHideUnderline(
      child: DropdownButton<ListTransaction>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: Const.listTransactionsOrder[_bloc.transactionIndex < 0 ? 0 : _bloc.transactionIndex],
          items: Const.listTransactionsOrder.map((value) => DropdownMenuItem<ListTransaction>(
            value: value,
            child: Text(value.tenGd.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            DataLocal.transaction = value!;
            DataLocal.transactionCode = DataLocal.transaction.maGd.toString();
            DataLocal.transactionYN = DataLocal.transaction.chonDLYN??0;
            maGD = value.maGd.toString().trim();

            _bloc.add(PickTransactionName(Const.listTransactionsOrder.indexOf(DataLocal.transaction),DataLocal.transaction.tenGd.toString(),DataLocal.transaction.chonDLYN??0));
          }),
    );
  }

  Widget typeOrderWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child:  Text(Const.nameTypeAdvOrder.toString().trim().replaceAll('null', '').isNotEmpty ?
      Const.nameTypeAdvOrder.toString() : 'Vui lòng chọn loại đơn hàng',style: const TextStyle(color: Colors.blueGrey,fontSize: 12)),
    );
  }

  Widget genderTaxWidget() {
    return
      Utils.isEmpty(DataLocal.listTax)
          ?
      const Padding(
        padding: EdgeInsets.only(top: 6),
        child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
      )
          :
      DropdownButtonHideUnderline(
        child: DropdownButton<GetListTaxResponseData>(
            isDense: true,
            isExpanded: true,
            style: const TextStyle(
              color: black,
              fontSize: 12.0,
            ),
            value: DataLocal.listTax[_bloc.taxIndex],
            items: DataLocal.listTax.map((value) => DropdownMenuItem<GetListTaxResponseData>(
              value: value,
              child: Text(
                value.tenThue.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
            )).toList(),
            onChanged: (value) {
              GetListTaxResponseData tax = value!;
              if(tax.maThue.toString().trim() == '#000'){
                _bloc.allowTaxPercent = false;
              }else{
                _bloc.allowTaxPercent = true;
              }
              indexValuesTax = DataLocal.listTax.indexOf(value);
              DataLocal.indexValuesTax = indexValuesTax;
              DataLocal.taxPercent = tax.thueSuat!.toDouble();
              DataLocal.taxCode = tax.maThue.toString().trim();
              if(Const.afterTax == true){
                _bloc.add(PickTaxAfter(DataLocal.indexValuesTax,DataLocal.taxPercent));
              }else{
                _bloc.add(PickTaxBefore(DataLocal.indexValuesTax,DataLocal.taxPercent));
              }
            }),
      );
  }

  Widget genderWidget() {
    return Utils.isEmpty(Const.stockList)
        ? const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        : DropdownButtonHideUnderline(
      child: DropdownButton<StockList>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: Const.stockList[_bloc.storeIndex],
          items: Const.stockList.map((value) => DropdownMenuItem<StockList>(
            value: value,
            child: Text(value.stockName.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            StockList stocks = value!;
            _bloc.storeCode = stocks.stockCode;
            _bloc.add(PickStoreName(Const.stockList.indexOf(value)));
          }),
    );
  }

  Widget inputWidget({String? title,String? hideText,IconData? iconPrefix,IconData? iconSuffix, bool? isEnable,
    TextEditingController? controller,Function? onTapSuffix, Function? onSubmitted,FocusNode? focusNode,
    TextInputAction? textInputAction,bool inputNumber = false,bool note = false,bool isPassWord = false}){
    return Padding(
      padding: const EdgeInsets.only(top: 0,left: 10,right: 10,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title??'',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,color: Colors.black),
              ),
              Visibility(
                visible: note == true,
                child: const Text(' *',style: TextStyle(color: Colors.red),),
              )
            ],
          ),
          const SizedBox(height: 5,),
          Container(
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8)
            ),
            child: TextFieldWidget2(
              controller: controller!,
              suffix: iconSuffix,
              textInputAction: textInputAction!,
              isEnable: isEnable ?? true,
              keyboardType: inputNumber == true ? TextInputType.phone : TextInputType.text,
              hintText: hideText,
              focusNode: focusNode,
              onSubmitted: (text)=> onSubmitted,
              isPassword: isPassWord,
              isNull: true,
              color: Colors.blueGrey,

            ),
          ),
        ],
      ),
    );
  }

  buildOtherRequest(){
    return Padding(
      padding: const EdgeInsets.only(left: 16,right: 16,top: 10,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Yêu cầu khác:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
          const SizedBox(height: 16,),
          GestureDetector(
              onTap: ()=>_bloc.add(CheckInTransferEvent(index: 4)),
              child: _buildCheckboxList('Đính kèm hoá đơn (nếu có)',_bloc.attachInvoice,4)),
          Visibility(
            visible: _bloc.attachInvoice == true,
            child: buildAttachFileInvoice(),),
          const SizedBox(height: 16,),
          GestureDetector(
              onTap: ()=>_bloc.add(CheckInTransferEvent(index: 5)),
              child: _buildCheckboxList('Xuất hoá đơn cho công ty',_bloc.exportInvoice,5)),
          Visibility(
            visible: _bloc.exportInvoice == true,
            child: buildInfoInvoice(),),
        ],
      ),
    );
  }

  Widget buildPaymentDetail(){
    return Padding(
      padding: const EdgeInsets.only(left: 16,right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:const EdgeInsets.only(top: 10,bottom: 6,),
            child: Row(
              children: [
                Icon(MdiIcons.idCard,color: mainColor,),
                const SizedBox(width: 10,),
                const Text('Thanh toán',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold,),maxLines: 1,overflow: TextOverflow.ellipsis,),
              ],
            ),
          ),
          customWidgetPayment('Tổng tiền đặt hàng:','${Utils.formatMoneyStringToDouble(_bloc.totalMoney)} ₫',0,''),
          Visibility(
              visible: Const.enableViewPriceAndTotalPriceProductGift == true && DataLocal.listProductGift.isNotEmpty,
              child: customWidgetPayment('Tổng tiền hàng được khuyến mại:','${Utils.formatMoneyStringToDouble(_bloc.totalMoneyProductGift)} ₫',0,'')),
          customWidgetPayment('Thuế:','${Utils.formatMoneyStringToDouble((_bloc.totalTax + _bloc.totalTax2))} ₫',0,''),
customWidgetPayment('Chiết khấu:','- ${Utils.formatMoneyStringToDouble(_bloc.totalDiscount)} ₫',0,''),
          InkWell(
              onTap: (){
                if(_bloc.listCkTongDon.isNotEmpty && _bloc.listCkTongDon.length > 1){
                  for (var element in _bloc.listCkTongDon) {
                    if(_bloc.listPromotion.split(',').any((values) => values.toString().trim() == element.sttRecCk.toString().trim()) == true){
                      _bloc.codeDiscountOld = element.maCk.toString().trim();
                    }
                  }
                  showDialog(
                      context: context,
                      builder: (context) {
                        return WillPopScope(
                            onWillPop: () async => true,
                            child:  CustomViewDiscountComponent(
                              iconData: Icons.card_giftcard_rounded,
                              title: 'Chương trình Khuyến Mại',
                              listDiscount: const [],
                              codeDiscountOld: _bloc.codeDiscountOld,
                              listDiscountTotal: _bloc.listCkTongDon,
                            )
                        );
                      }).then((value){
                    if(value != '' && value[0] == 'Yeah'){
                      /// add list
                      /// check trùng
                      /// xoá list
                      if(_bloc.listPromotion.isNotEmpty && _bloc.listPromotion.contains(value[6].toString().trim())){
                        _bloc.listPromotion = _bloc.listPromotion.replaceAll(value[6].toString().trim(), value[7].toString().trim());
                        // _bloc.listCKVT = _bloc.listCKVT.replaceAll('${value[6].toString().trim()}-', value[7].toString().trim());
                      }else{
                        _bloc.listPromotion = _bloc.listPromotion == '' ? value[7].toString().trim() : '${_bloc.listPromotion},${value[7].toString().trim()}';
                      }
                      _bloc.codeDiscountTD = value[2];
                      _bloc.sttRecCKOld = value[7];
                      _bloc.listCkMatHang.clear();
                      _bloc.add(GetListItemApplyDiscountEvent(
                          listCKVT: DataLocal.listCKVT,
                          listPromotion: _bloc.listPromotion,
                          listItem: listItem,
                          listQty: listQty,
                          listPrice: listPrice,
                          listMoney: listMoney,
                          warehouseId: codeStore,
                          customerId: _bloc.codeCustomer.toString(),
                          keyLoad: 'Second'
                      ));
                    }
                  });
                }
              },
              child: customWidgetPayment('Voucher:','',1 ,
                  _bloc.codeDiscountTD.isEmpty
                      ?
                  'FreeShip'
                      :
                  "${_bloc.codeDiscountTD.toString().trim()} ${(_bloc.totalDiscountForOder ?? 0) == 0 ? '0 ₫'
                      :
                  '- ${Utils.formatMoneyStringToDouble(_bloc.totalDiscountForOder ?? 0)} ₫'}"
              )),
          Padding(
            padding: const EdgeInsets.only(top: 15,bottom: 6,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng Thanh toán',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold,),maxLines: 1,overflow: TextOverflow.ellipsis,),
                Text('${Utils.formatMoneyStringToDouble(_bloc.totalPayment)} ₫',style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold,),maxLines: 1,overflow: TextOverflow.ellipsis,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxList(String title,bool value,int index) {
    return Row(
      children: [
        SizedBox(
          height: 10,
          child: Transform.scale(
            scale: 1,
            alignment: Alignment.topLeft,
            child: Checkbox(
              value: value,
              onChanged: (b){
                // if(index == 1){
                //   _bloc.add(CheckInTransferEvent(index: 1));
                // }else if(index == 2){
                //   _bloc.add(CheckInTransferEvent(index: 2));
                // }else if(index == 3){
                //   _bloc.add(CheckInTransferEvent(index: 3));
                // }else
                if(index == 4){
                  _bloc.add(CheckInTransferEvent(index: 4));
                }else if(index == 5){
                  _bloc.add(CheckInTransferEvent(index: 5));
                }
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
        Text(title,style: const TextStyle(color: Colors.blueGrey,fontSize: 12),),
      ],
    );
  }

  buildAttachFileInvoice(){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                getImage();
                // _bloc.add(GetCameraEvent());
              },
              child: Container(padding: const EdgeInsets.only(left: 10,right: 15,top: 8,bottom: 8),
                height: 40,
                width: double.infinity,
                color: Colors.amber.withOpacity(0.4),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ảnh của bạn',style: TextStyle(color: Colors.black,fontSize: 13),),
                    Icon(Icons.add_a_photo_outlined,size: 20,),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16,),
            // GalleryImage(imageUrls: [],),
            _bloc.listFileInvoice.isEmpty ? const SizedBox(height: 100,width: double.infinity,child: Center(child: Text('Hãy chọn thêm hình ảnh của bạn từ thư viện ảnh hoặc từ camera',style: TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),),) :
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _bloc.listFileInvoice.length,
                    itemBuilder: (context,index){
                      return (start > 1 && waitingLoad == true && _bloc.listFileInvoice.length == (index + 1)) ? const SizedBox(height: 100,width: 80,child: PendingAction()) : GestureDetector(
                        onTap: (){
                          openImageFullScreen(index,_bloc.listFileInvoice[index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: 115,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  child: Hero(
                                    tag: index,
                                    /*semanticContainer: true,
                                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),*/
                                    child: Image.file(
                                      _bloc.listFileInvoice[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,right: 6,
                                child: InkWell(
                                  onTap: (){
                                    setState(() {
                                      _bloc.listFileInvoice.removeAt(index);
                                      _bloc.listFileInvoiceSave.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    height: 20,width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black.withOpacity(.7),
                                    ),
                                    child: const Icon(Icons.clear,color: Colors.white,size: 12,),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // to open gallery image in full screen
  void openImageFullScreen(final int indexOfImage, File fileImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageViewWrapperViewOnly(
          titleGallery: "Zoom Image",
          galleryItemsFile: fileImage,
          viewNetWorkImage: false,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  buildInfoInvoice(){
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(10),
              height: 40,
              width: double.infinity,
              color: Colors.amber.withOpacity(0.4),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Thông tin xuất hoá đơn',style: TextStyle(color: Colors.black,fontSize: 13),),
              ),
            ),
            const SizedBox(height: 8,),
            inputWidget(title: "Công ty",hideText: 'Tên công ty',controller: nameCompanyController,focusNode: nameCompanyFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true),
            inputWidget(title: "Mã số thuế",hideText: 'Mã số thuế',controller: mstController,focusNode: mstFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true),
            inputWidget(title: "Địa chỉ",hideText: 'Địa chỉ',controller: addressCompanyController,focusNode: addressFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true),
            inputWidget(title: "Ghi chú",hideText: 'Ghi chú',controller: noteController,focusNode: noteFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: false),
          ],
        ),
      ),
    );
  }

  Widget customWidgetPayment(String title,String subtitle,int discount, String codeDiscount){
    return Padding(
      padding:const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,style: const TextStyle(fontSize: 12,color: Colors.blueGrey),),
              subtitle != '' ? Text(subtitle,style: const TextStyle(fontSize: 13,color: Colors.black),) :
              discount > 0 ?
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: DottedBorder(
                        dashPattern: const [5, 3],
                        color: Colors.red,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(2),
                        padding: const EdgeInsets.only(top: 2,bottom: 2,left: 10,right: 10),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Text(codeDiscount,style: const TextStyle(fontSize: 11,color: Colors.red),
                          ),
                        )
                    ),
                  )
                ],
              )
                  : Container(),
            ],
          ),
          const Divider(color: Colors.grey,)
        ],
      ),
    );
  }


  buildAppBar(){
    return Container(
      height: 83,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.of(context).pop(widget.currencyCode),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: (){
              },
              child: Center(
                child: Text(
                  widget.viewUpdateOrder == true ? widget.nameCustomer?.toString()??'' :'Giỏ hàng',
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.black,),
                  maxLines: 1,overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              if(widget.isContractCreateOrder == true){
                PersistentNavBarNavigator.pushNewScreen(context, screen: DetailContractScreen(
                  contractMaster: widget.contractMaster!, 
                  isSearchItem: true,
                  cartItems: _bloc.listOrder, // Truyền dữ liệu giỏ hàng hiện tại
                ),withNavBar: false).then((result){
                  if(result == 'refresh_cart'){
                    // Nếu có thêm sản phẩm mới, refresh lại giỏ hàng
                    _bloc.add(GetListProductFromDB(addOrderFromCheckIn: false, getValuesTax: false,key: ''));
                  }
                });
              }else
              if(widget.viewDetail == false && widget.orderFromCheckIn == false){

                PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProductScreen(
                 idCustomer: widget.codeCustomer.toString(), /// Chỉ có thêm tồn kho ở check-in mới thêm idCustomer
                 currency: widget.currencyCode ,
                 viewUpdateOrder: false,
                 listIdGroupProduct: widget.listIdGroupProduct,
                 itemGroupCode: widget.itemGroupCode,
                 inventoryControl: false,
                 addProductFromCheckIn: false,
                 addProductFromSaleOut: false,
                 giftProductRe: false,
                 lockInputToCart: false,checkStockEmployee: Const.checkStockEmployee,
                 listOrder: _bloc.listProductOrderAndUpdate, backValues: false, isCheckStock: false,),withNavBar: false).then((value){
                 _bloc.listOrder.clear();
                 _bloc.listItemOrder.clear();
                 _bloc.listCkMatHang.clear();
                 _bloc.listCkTongDon.clear();
                 _bloc.listPromotion = '';
                 _bloc.add(GetListProductFromDB(addOrderFromCheckIn: false, getValuesTax: false,key: ''));
               });
              }
            },
            child: SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.search,
                size: 25,
                color: widget.orderFromCheckIn == false ? Colors.black : Colors.transparent,
              ),
            ),
          )
        ],
      ),
    );
  }

  String _formatTaxRate(double taxRate) {
    // Nếu số là số nguyên thì hiển thị không có phần thập phân
    if (taxRate == taxRate.roundToDouble()) {
      return taxRate.round().toString();
    } else {
      // Nếu có phần thập phân thì hiển thị với 1 chữ   số thập phân
      return taxRate.toStringAsFixed(1);
    }
  }

}
