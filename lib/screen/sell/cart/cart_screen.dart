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
      //_bloc.add(TotalDiscountAndMoneyForAppEvent(listProduct: widget.listOrder!,viewUpdateOrder: false,reCalculator: true));
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
          if(widget.viewUpdateOrder == true){
            _bloc.totalProductGift = 0;
            for (var element in DataLocal.listProductGift) {
              _bloc.totalProductGift += element.count!;
            }
          }
          if(state.keyLoad == 'First'){

            /// Check xem list sản phẩm đã chọn CK chưa nếu chọn rồi thì thay thế nó vào req mới.

            if(DataLocal.listObjectDiscount.isNotEmpty){
              for (var element in DataLocal.listObjectDiscount) {
                if(listItem.split(',').any((item) => item.toString().trim() == element.itemProduct.toString().trim()) == true){
                  if(_bloc.listPromotion.isNotEmpty){
                    int indexItem = -1;
                    String reListPromotion = _bloc.listPromotion;
                    for(int i = 0; i<= _bloc.listPromotion.split(',').length;){
                      if(_bloc.listPromotion.split(',')[i].toString().trim() == element.itemDiscountOld.toString().trim()){
                        indexItem = i;
                        break;
                      }
                      break;
                    }
                    if(indexItem >= 0){
                      reListPromotion = reListPromotion.split(',').removeAt(indexItem);
                      reListPromotion = '$reListPromotion,${element.itemDiscountNew}';
                      _bloc.listPromotion = reListPromotion;
                      DataLocal.listCKVT = DataLocal.listCKVT.split(',').removeAt(indexItem);
                      DataLocal.listCKVT = '${DataLocal.listCKVT},${'${element.itemDiscountNew.toString().trim()}-${element.itemProduct.toString().trim()}'}';
                    }
                    // final ids = [1, 4, 4, 4, 5, 6, 6];
                    // final distinctIds = [...{...ids}];
                    // print(distinctIds);
                  }
                }
              }

            }

            for (var a in DataLocal.listOrderDiscount) {
              _bloc.listOrder[_bloc.listOrder.indexWhere((b) => a.code.toString().trim() == b.code.toString().trim())] = a;
            }
            _bloc.add(GetListItemApplyDiscountEvent(
                listCKVT: DataLocal.listCKVT,
                listPromotion: _bloc.listPromotion,
                listItem: listItem,
                listQty: listQty,
                listPrice: listPrice,
                listMoney: listMoney,
                warehouseId: codeStore,
                customerId: _bloc.codeCustomer.toString(),
                keyLoad: 'Second' //false
            ));
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
          _bloc.add(TotalDiscountAndMoneyForAppEvent(listProduct: _bloc.listProductOrderAndUpdate,viewUpdateOrder:false,reCalculator: true));
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
                                  if(DataLocal.listProductGift.isNotEmpty && Const.chooseStockBeforeOrderWithGiftProduction == true) {
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
                        padding:  EdgeInsets.only(top: 0),
                        child: Icon(Icons.description,size: 20,color: Colors.red,),
                      )),
                ),
                const SizedBox(width: 20,),
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
                        padding:  EdgeInsets.only(top: 0),
                        child: Icon(Icons.discount,size: 20,color: Colors.red,),
                      )),
                ),
                const SizedBox(width: 20,),
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
                              _bloc.add(DeleteAllProductEvent());
                            }
                          }
                        });
                      },
                      child:const Icon(Icons.delete_forever, size: 20)),
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
                  visible: Const.discountSpecial == true,
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
                      _bloc.totalProductGift = _bloc.totalProductGift - DataLocal.listProductGift[index].count!;
                      _bloc.add(AddOrDeleteProductGiftEvent(false,DataLocal.listProductGift[index]));
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
                onTap: (){
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
                                    Const.lockStockInItem == false
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
              startActionPane: (Const.freeDiscount == false || widget.isContractCreateOrder == true) ? null : ActionPane(
                motion: const ScrollMotion(),
                // extentRatio: 0.25,
                dragDismissible: false,
                children: [
                  Visibility(
                    visible: _bloc.listOrder[index].gifProduct != true,
                    child: SlidableAction(
                      onPressed:(_) {
                        setState(() {
                          if(_bloc.listOrder[index].discountByHand == true){
                            double sl = _bloc.listOrder[index].count!;
                            double price = 0;
                            if(_bloc.allowTaxPercent == true){
                              price = _bloc.listOrder[index].priceAfterTax!;
                            }else{
                              price = (/*_bloc.listOrder[index].giaGui > 0 ? _bloc.listOrder[index].giaGui :*/ _bloc.listOrder[index].giaSuaDoi);
                            }
                            double a = ((price * sl) * _bloc.listOrder[index].discountPercentByHand)/100;
                            _bloc.listOrder[index].discountByHand = false;
                            _bloc.totalDiscount = _bloc.totalDiscount -  a;
                            _bloc.totalPayment  = _bloc.totalPayment   + a;
                            _bloc.listOrder[index].discountPercentByHand = 0;
                            _bloc.listOrder[index].ckntByHand = 0;
                            _bloc.listOrder[index].priceAfter = (/*_bloc.listOrder[index].giaGui > 0 ? _bloc.listOrder[index].giaGui :*/ _bloc.listOrder[index].giaSuaDoi);;
                            _bloc.add(CalculatorDiscountEvent(addOnProduct: false,product: _bloc.listOrder[index],reLoad: false, addTax: Const.useTax));
                            Utils.showCustomToast(context, Icons.check_circle_outline, 'Huỷ áp dụng chiết khấu tự do');
                          }
                          else{
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) {
                                  return InputDiscountPercent(
                                    title: 'Vui lòng nhập tỉ lệ chiết khấu',
                                    subTitle: 'Vui lòng nhập tỉ lệ chiết khấu',
                                    typeValues: '%',
                                    percent: _bloc.listOrder[index].discountPercentByHand,
                                  );
                                }).then((value){
                              if(value[0] == 'BACK'){
                                _bloc.listOrder[index].discountByHand = true;
                                double sl = _bloc.listOrder[index].count!;
                                double price = /*_bloc.allowTaxPercent == true ?  _bloc.listOrder[index].priceAfterTax! :*/ _bloc.listOrder[index].giaSuaDoi;
                                _bloc.listOrder[index].discountPercentByHand = double.parse(value[1].toString());
                                _bloc.totalPayment = _bloc.totalPayment -  (price * sl * value[1] )/100;
                                _bloc.listOrder[index].ckntByHand = (price * sl * value[1] )/100;
                                _bloc.listOrder[index].giaSuaDoi = price;
                                _bloc.listOrder[index].priceAfter =
                                    // _bloc.listOrder[index].giaGui > 0
                                    //     ?
                                    // (_bloc.listOrder[index].giaGui - ((_bloc.listOrder[index].giaGui * 1) * value[1])/100)
                                    //     :
                                (_bloc.listOrder[index].giaSuaDoi - ((_bloc.listOrder[index].giaSuaDoi * 1) * value[1])/100);


                                Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã áp dụng chiết khấu tự do');
                                _bloc.add(CalculatorDiscountEvent(addOnProduct: true,product: _bloc.listOrder[index],reLoad: false, addTax: Const.useTax));
                              }
                            });
                          }
                        });
                      },
                      borderRadius:const BorderRadius.all(Radius.circular(8)),
                      padding:const EdgeInsets.all(10),
                      backgroundColor: _bloc.listOrder[index].discountByHand == true
                          ?
                      const Color(0xFFC7033B)
                          : const Color(0xFFA8B1A6),
                      foregroundColor: Colors.white,
                      icon: Icons.discount,
                      label: 'Chiết khấu',
                    ),
                  ),
                  const SizedBox(width: 2,),
                  Visibility(
                    visible: Const.isVv == true,
                    child: SlidableAction(
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
                  )
                ],
              ),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                dragDismissible: false,
                children: [
                  Visibility(
                    visible: !Utils.isEmpty(_bloc.listOrder[index].listDiscount??[]),
                    child: SlidableAction(
                      onPressed:(_) {
                        if(_bloc.listOrder.any((element) => element.maVtGoc.toString().trim() == _bloc.listOrder[index].code.toString().trim()) == true){
                          SearchItemResponseData itemExits =  _bloc.listOrder.firstWhere((element) => element.maVtGoc.toString().trim() == _bloc.listOrder[index].code.toString().trim());
                          if(itemExits.code  != ''){
                            _bloc.maHangTangOld = itemExits.code.toString().trim();
                            _bloc.codeDiscountOld = itemExits.maCkOld.toString().trim();
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
                                    listDiscountTotal: const [],
                                    maHangTangOld: _bloc.maHangTangOld,
                                    codeDiscountOld: _bloc.codeDiscountOld,
                                    listDiscount: _bloc.listOrder[index].listDiscount??[],
                                  )
                              );
                            }).then((value){
                              print(value);
                          if(value != '' && value[0] == 'Yeah'){
                            /// add list
                            /// check trùng
                            /// xoá list
                            ListCk itemCKs = value[4] as ListCk;
                            ListCk itemCKOld = ListCk();
                            if(value[5] != null){
                              itemCKOld = value[5] as ListCk;
                            }
                            if(_bloc.listPromotion.isNotEmpty && _bloc.listPromotion.contains(itemCKOld.sttRecCk.toString().trim()) == true){
                              _bloc.listPromotion = _bloc.listPromotion.replaceFirst(itemCKOld.sttRecCk.toString().trim(), itemCKs.sttRecCk.toString().trim(),index);
                              _bloc.codeDiscountSelecting = itemCKs.sttRecCk.toString().trim();
                            }
                            else{
                              _bloc.listPromotion = _bloc.listPromotion == '' ? itemCKs.sttRecCk.toString() : '${_bloc.listPromotion},${itemCKs.sttRecCk.toString()}';
                              _bloc.codeDiscountSelecting = itemCKs.sttRecCk.toString().trim();
                            }
                            if(DataLocal.listCKVT.isNotEmpty && DataLocal.listCKVT.contains('${itemCKOld.sttRecCk.toString().trim()}-${itemCKOld.maVt.toString().trim()}') == true){
                              DataLocal.listCKVT = DataLocal.listCKVT.replaceFirst('${itemCKOld.sttRecCk.toString().trim()}-${itemCKOld.maVt.toString().trim()}', '${itemCKs.sttRecCk.toString().trim()}-${itemCKs.maVt.toString().trim()}',index);
                            }
                            else{
                              DataLocal.listCKVT = DataLocal.listCKVT == '' ? '${itemCKs.sttRecCk.toString().trim()}-${itemCKs.maVt.toString().trim()}' : '${DataLocal.listCKVT},${'${itemCKs.sttRecCk.toString().trim()}-${itemCKs.maVt.toString().trim()}'}';
                            }
                            if(_bloc.listOrder.any((a) => a.code.toString().trim() == itemCKs.maVt.toString().trim() && a.gifProduct != true) == true){
                              int indexWhere = _bloc.listOrder.indexWhere((b) => b.code.toString().trim() == itemCKs.maVt.toString().trim() && b.gifProduct != true);
                              if(_bloc.listOrder[indexWhere].maCk.toString().isNotEmpty && _bloc.listOrder[indexWhere].maCk!.contains(value[1])){
                                _bloc.listOrder[indexWhere].maCk?.replaceAll(value[1], value[2]);
                                _bloc.listOrder[indexWhere].maCkOld?.replaceAll(value[1], value[2]);
                              }else {
                                _bloc.listOrder[indexWhere].maCk = _bloc.listOrder[indexWhere].maCk == '' ? value[2] : '${_bloc.listOrder[indexWhere].maCk},${value[2]}';
                                _bloc.listOrder[indexWhere].maCkOld = _bloc.listOrder[indexWhere].maCkOld == '' ? value[2] : '${_bloc.listOrder[indexWhere].maCkOld},${value[2]}';
                              }
                              _bloc.listOrder[indexWhere].maVtGoc = itemCKs.maVt.toString();
                              _bloc.listOrder[indexWhere].sctGoc = itemCKs.sttRecCk.toString().trim();
                            }
                            _bloc.allowed2 = true;

                            ObjectDiscount ojb = ObjectDiscount(
                                itemProduct: _bloc.listOrder[index].code.toString(),
                                itemDiscountNew: itemCKs.sttRecCk.toString().trim(),
                                itemDiscountOld: itemCKOld.sttRecCk.toString().trim()
                            );

                            if(DataLocal.listObjectDiscount.any((c) => c.itemProduct.toString().trim() == ojb.itemProduct.toString().trim()) == false){
                              DataLocal.listObjectDiscount.add(ojb);
                            }
                            else{
                              DataLocal.listObjectDiscount.removeWhere((d) => d.itemProduct.toString().trim() == ojb.itemProduct.toString().trim());
                              DataLocal.listObjectDiscount.add(ojb);
                            }
                            if(DataLocal.listOrderDiscount.any((c) => c.code.toString().trim() == _bloc.listOrder[index].code.toString().trim()) == false){
                              DataLocal.listOrderDiscount.add(_bloc.listOrder[index]);
                            }
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
                      },
                      borderRadius:const BorderRadius.all(Radius.circular(8)),
                      padding:const EdgeInsets.all(10),
                      backgroundColor: const Color(0xFF0EBB00),
                      foregroundColor: Colors.white,
                      icon: Icons.gif_box_outlined,
                      label: 'CK',
                    ),
                  ),
                  const SizedBox(width: 2,),
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
                        if(DataLocal.listCKVT.isNotEmpty && DataLocal.listCKVT.contains('${itemSelect.sttRecCK.toString().trim()}-${itemSelect.code.toString().trim()}') == true){
                          DataLocal.listCKVT = DataLocal.listCKVT.replaceAll('${itemSelect.sctGoc.toString().trim()}-${itemSelect.code.toString().trim()}', '');
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
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:'Giá bán: \$${Utils.formatMoneyStringToDouble(_bloc.listOrder[index].giaSuaDoi)}',
                                                      style: const TextStyle(color: Colors.blueGrey,fontSize: 12, overflow: TextOverflow.ellipsis,),
                                                    ),
                                                    TextSpan(
                                                      text: _bloc.listOrder[index].discountPercentByHand >0 ? '  (-${_bloc.listOrder[index].discountPercentByHand} %)'
                                                          :
                                                      _bloc.listOrder[index].discountPercent! > 0 ?
                                                      '  (-${_bloc.listOrder[index].discountPercent} %)' : '',
                                                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 11, color: Colors.red),
                                                    ),
                                                  ],
                                                ),
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
                                                    (_bloc.listOrder[index].discountPercentByHand == 0 && _bloc.listOrder[index].discountPercent! == 0 ) ?
                                                    Container()
                                                        :
                                                    Text(
                                                      _bloc.listOrder[index].giaSuaDoi
                                                          == 0 ? 'Giá đang cập nhật' : '\$ ${
                                                      Utils.formatMoneyStringToDouble(_bloc.listOrder[index].giaSuaDoi * _bloc.listOrder[index].count!)} ',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(color:
                                                      (_bloc.listOrder[index].price??0) == 0
                                                          ?
                                                      Colors.grey : Colors.grey, fontSize: 10, decoration: ((widget.currencyCode == "VND"
                                                          ?
                                                      _bloc.listOrder[index].price??0
                                                          :
                                                      _bloc.listOrder[index].price??0)) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                                    ),
                                                    const SizedBox(width: 5,),
                                                    Text(
                                                      (_bloc.listOrder[index].giaSuaDoi > 0 && (_bloc.listOrder[index].discountPercentByHand == 0 && _bloc.listOrder[index].discountPercent! == 0)) ?
                                                      '\$ ${Utils.formatMoneyStringToDouble((_bloc.listOrder[index].giaSuaDoi) * _bloc.listOrder[index].count!)}'
                                                      :
                                                      '\$ ${Utils.formatMoneyStringToDouble(
                                                          (/*_bloc.listOrder[index].giaSuaDoi != _bloc.listOrder[index].price ? _bloc.listOrder[index].giaSuaDoi :*/ _bloc.listOrder[index].priceAfter??0)
                                                      * _bloc.listOrder[index].count!)}',
                                                      textAlign: TextAlign.left, style: const TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
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
                  "${_bloc.codeDiscountTD.toString().trim()} ${_bloc.listCkTongDon.isEmpty ? '0 ₫'
                      :
                  '- ${Utils.formatMoneyStringToDouble(_bloc.listCkTongDon[0].tCkTt)} ₫'}"
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
      // Nếu có phần thập phân thì hiển thị với 1 chữ số thập phân
      return taxRate.toStringAsFixed(1);
    }
  }

}