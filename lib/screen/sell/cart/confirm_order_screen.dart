// ignore_for_file: library_private_types_in_public_api, unrelated_type_equality_checks

import 'dart:async';
import 'dart:io';

// import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms/model/network/response/apply_discount_response.dart';
import 'package:dms/model/network/response/gift_product_list_response.dart';
import 'package:dms/screen/sell/component/search_vv_hd.dart';
import 'package:dms/widget/InputDiscountPercent.dart';
import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/custom_dropdown.dart';
import 'package:dms/widget/custom_order.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/input_quantity_popup_order.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:dms/widget/text_field_widget2.dart';
import 'package:dms/widget/view_desc_discount.dart';
import 'package:dms/widget/ckn_gift_product_selection_dialog.dart';
import 'package:dms/screen/sell/cart/widgets/discount_voucher_selection_sheet.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as datetimepicker;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';


import '../../../custom_lib/view_only_image.dart';
import '../../../model/database/data_local.dart';
import '../../../model/entity/product.dart';
import '../../../model/network/request/create_order_request.dart';
import '../../../model/network/request/order_create_checkin_request.dart';
import '../../../model/network/request/update_order_request.dart';
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
import 'cart_bloc.dart';
import 'cart_state.dart';
import 'cart_event.dart';
import 'helpers/cart_draft_storage.dart';
import 'widgets/tax_selection_sheet.dart';


class ConfirmScreen extends StatefulWidget {
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


  const ConfirmScreen({Key? key,this.sttRec,this.addInfoCheckIn,this.viewUpdateOrder,this.listOrder,this.currencyCode,this.viewDetail,this.nameCustomer,this.idCustomer,
    this.phoneCustomer,this.addressCustomer,this.nameStore,this.codeStore,this.codeCustomer,this.itemGroupCode,this.listIdGroupProduct, this.dateOrder,
    required this.orderFromCheckIn, required this.title, this.description, required this.loadDataLocal
  }) : super(key: key);

  @override
  _ConfirmScreenState createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen>with TickerProviderStateMixin{

  late CartBloc _bloc;
  // ✅ Flag để đánh dấu đã đặt đơn thành công (ngăn không cho save draft sau đó)
  bool _orderCreatedSuccessfully = false;
  String? dateTransfer;
  String? timeTransfer;

  final nameCompanyController = TextEditingController();
  final noteCompanyController = TextEditingController();
  final mstController = TextEditingController();
  final addressCompanyController = TextEditingController();
  final nameCompanyFocus = FocusNode();
  final mstFocus = FocusNode();final addressFocus = FocusNode();final noteFocus = FocusNode();

  final nameCustomerController = TextEditingController();
  final addressCustomerController = TextEditingController();
  final phoneCustomerController = TextEditingController();
  final nameCustomerFocus = FocusNode();
  final addressCustomerFocus = FocusNode();
  final phoneCustomerFocus = FocusNode();
  final noteController = TextEditingController();
  final addressController = TextEditingController();

  String nameStore = '';
  String codeStore = '';
  late SearchItemResponseData itemSelect;
  late Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  int start = 3;

  bool waitingLoad = false;

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


  String listItem = '';
  String listQty = '';
  String listPrice = '';
  String listMoney = '';

  late int indexSelect;
  late int indexSelectGift;
  bool gift = false;
  bool lockChooseStore = false;

  // CKN flow state
  String? _pendingDiscountName;
  double? _pendingMaxQuantity;
  List<ListCkMatHang>? _pendingDiscountItems;
  String? _pendingDiscountType; // 'CKN' or 'CKTDTH'
  String? _pendingCknGroupKey;
  String? _pendingCktdthGroupKey;
  GlobalKey<DiscountVoucherSelectionSheetState>? _discountSheetKey;
  
  // ✅ Flag để re-apply HH gifts sau khi API reload
  bool _needReapplyHHAfterReload = false;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  final imagePicker = ImagePicker();

  Future getImage()async {
    // final image = await imagePicker.pickImage(source: ImageSource.camera,imageQuality: 45);

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DataLocal.dateEstDelivery = Utils.parseDateToString(DateTime.now(), Const.DATE_FORMAT_2);
    _bloc = CartBloc(context);
    if(DataLocal.indexValuesTax.toString().replaceAll('null', '').isNotEmpty && DataLocal.taxPercent.toString().replaceAll('null', '').isNotEmpty && DataLocal.taxPercent > 0 ){
      _bloc.add(PickTaxAfter(DataLocal.indexValuesTax,DataLocal.taxPercent));
    }
    _bloc.allowed = true;
    _bloc.add(GetPrefs());
    // _bloc.firstLoadUpdateOrder = 1;
    if(widget.viewUpdateOrder == true){
      _bloc.showWarning = false;
      // Khởi tạo totalProductGift từ danh sách khuyến mại khi sửa đơn
      _bloc.totalProductGift = 0;
      print('ConfirmScreen initState - viewUpdateOrder=true, DataLocal.listProductGift.length = ${DataLocal.listProductGift.length}');
      if(DataLocal.listProductGift.isNotEmpty){
        for (var element in DataLocal.listProductGift) {
          _bloc.totalProductGift += element.count ?? 0;
          print('ConfirmScreen initState - Gift product: ${element.code} - ${element.name}, count: ${element.count}');
        }
        print('ConfirmScreen initState - totalProductGift = ${_bloc.totalProductGift}');
      } else {
        print('ConfirmScreen initState - DataLocal.listProductGift is EMPTY!');
      }
    }
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
    if(widget.codeCustomer.toString().trim() != 'null' && widget.codeCustomer.toString().trim().isNotEmpty){
      nameCustomerController.text = widget.nameCustomer.toString();
      phoneCustomerController.text = widget.phoneCustomer.toString();
      addressCustomerController.text = widget.addressCustomer.toString();
      _bloc.customerName = widget.nameCustomer;
      _bloc.codeCustomer = widget.codeCustomer;
      _bloc.addressCustomer = widget.addressCustomer;
      _bloc.phoneCustomer = widget.phoneCustomer;
    }
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
          Utils.showCustomToast(context, Icons.warning, state.error.toString().trim());
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
        else if(state is PickTaxAfterSuccess || state is PickTaxBeforeSuccess){
          _bloc.chooseTax = true;
          _bloc.add(UpdateListOrder());
        } else if(state is CalculatorDiscountSuccess){
          // ✅ Tính lại totalProductGift từ DataLocal.listProductGift sau khi tính chiết khấu
          _bloc.totalProductGift = 0;
          print('💰 ConfirmScreen: After CalculatorDiscountSuccess, DataLocal.listProductGift.length=${DataLocal.listProductGift.length}');
          for (var gift in DataLocal.listProductGift) {
            _bloc.totalProductGift += gift.count ?? 0;
            print('  - Gift: ${gift.code} - ${gift.name}, count: ${gift.count}, typeCK: ${gift.typeCK}, gifProductByHand: ${gift.gifProductByHand}');
          }
          print('💰 ConfirmScreen: After CalculatorDiscountSuccess, totalProductGift=${_bloc.totalProductGift}');
          _bloc.add(UpdateListOrder());
        }
        else if(state is ApplyDiscountSuccess){
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
          }
          
          if(widget.viewUpdateOrder == true){
            _bloc.totalProductGift = 0;
            print('💰 ConfirmScreen: After ApplyDiscountSuccess, DataLocal.listProductGift.length=${DataLocal.listProductGift.length}');
            for (var element in DataLocal.listProductGift) {
              _bloc.totalProductGift += element.count ?? 0;
              print('  - Gift: ${element.code} - ${element.name}, count: ${element.count}, typeCK: ${element.typeCK}, gifProductByHand: ${element.gifProductByHand}');
            }
            print('💰 ConfirmScreen: After ApplyDiscountSuccess, totalProductGift=${_bloc.totalProductGift}');
          }
          if(state.keyLoad == 'First'){
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
                  _bloc.totalPayment = _bloc.totalPayment -  (price * sl * _bloc.listOrder[index].discountPercentByHand )/100;
                  _bloc.listOrder[index].ckntByHand = (price * sl * _bloc.listOrder[index].discountPercentByHand )/100;
                  _bloc.listOrder[index].priceAfter2 = price;//_bloc.listOrder[index].priceAfter;
                  _bloc.listOrder[index].priceAfter =
                  ((_bloc.listOrder[index].price ?? 0) - (((_bloc.listOrder[index].price ?? 0) * 1) * _bloc.listOrder[index].discountPercentByHand)/100);
                 print('1234A ${ _bloc.listOrder[index].priceAfter}');
                  if(_bloc.listOrder[index].discountPercentByHand > 0){
                    Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã áp dụng chiết khấu tự do');
                  }
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
          }
          if(state.keyLoad != 'First' && DataLocal.indexValuesTax >=0){
            _bloc.add(PickTaxAfter(DataLocal.indexValuesTax,DataLocal.taxPercent));
          }
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
            getDiscountProduct('First');
          }
        }
        else if(state is CreateOrderSuccess){
          // ✅ QUAN TRỌNG: Đánh dấu đã đặt đơn thành công (ngăn không cho save draft sau đó)
          _orderCreatedSuccessfully = true;
          
          // ✅ QUAN TRỌNG: Làm sạch toàn bộ dữ liệu đơn hàng
          _clearAllOrderData();
          
          // ✅ QUAN TRỌNG: Xóa draft ngay sau khi đặt đơn thành công
          // Vì đơn đã được tạo thành công, không cần giữ draft nữa
          CartDraftStorage.clearDraft().then((_) {
            print('💾 ✅ Draft đã được xóa sau khi đặt đơn thành công (confirm_order_screen)');
          }).catchError((e) {
            print('💾 ❌ Lỗi khi xóa draft: $e');
          });
          
          // Xóa sản phẩm từ database
          _bloc.add(DeleteAllProductFromDB());
          
          Utils.showCustomToast(context, Icons.check_circle_outline, widget.title.toString().contains('Đặt hàng') ? 'Yeah, Tạo đơn thành công' : 'Yeah, Cập nhật đơn thành công');
        }
        else if(state is CreateOrderFromCheckInSuccess){
          // ✅ QUAN TRỌNG: Đánh dấu đã đặt đơn thành công (ngăn không cho save draft sau đó)
          _orderCreatedSuccessfully = true;
          
          // ✅ QUAN TRỌNG: Làm sạch toàn bộ dữ liệu đơn hàng
          _clearAllOrderData();
          
          // ✅ QUAN TRỌNG: Xóa draft ngay sau khi đặt đơn thành công
          // Vì đơn đã được tạo thành công, không cần giữ draft nữa
          CartDraftStorage.clearDraft().then((_) {
            print('💾 ✅ Draft đã được xóa sau khi đặt đơn thành công (CheckIn - confirm_order_screen)');
          }).catchError((e) {
            print('💾 ❌ Lỗi khi xóa draft: $e');
          });
          
          Utils.showCustomToast(context, Icons.check_circle_outline, widget.title.toString().contains('Đặt hàng') ? 'Yeah, Tạo đơn thành công' : 'Yeah, Cập nhật đơn thành công');
          Navigator.of(context).pop(Const.REFRESH);
        }
        else if(state is DeleteAllProductFromDBSuccess){
          // ✅ QUAN TRỌNG: Nếu đã đặt đơn thành công, dữ liệu đã được clear trong CreateOrderSuccess
          // Chỉ clear lại nếu chưa đặt đơn thành công (trường hợp xóa sản phẩm thủ công)
          if (!_orderCreatedSuccessfully) {
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
            print('💾 ✅ Data cleared in DeleteAllProductFromDBSuccess (manual delete)');
          } else {
            print('💾 ⚠️ Skip clear in DeleteAllProductFromDBSuccess: Order already created successfully, data already cleared');
          }
          Utils.showCustomToast(context, Icons.check_circle_outline, widget.title.toString().contains('Đặt hàng') ? 'Yeah, Tạo đơn thành công' : 'Yeah, Cập nhật đơn thành công');
          Navigator.of(context).pop(Const.REFRESH);
        }
        else if(state is PickStoreNameSuccess){}
        else if(state is UpdateProductCountOrderFromCheckInSuccess){
          getDiscountProduct('Second');
        }
        else if(state is GrantCameraPermission){
          getImage();
        }
        else if(state is GetListStockEventSuccess){
          print('ADKCM');
          print(itemSelect.allowDvt );
          print(itemSelect.contentDvt?.length );
          if(gift == false){

            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return InputQuantityPopupOrder(
                    title: 'Cập nhật thông tin',
                    quantity: itemSelect.count??0,
                    quantityStock: _bloc.ton13,
                    listDvt: itemSelect.allowDvt == true ? itemSelect.contentDvt!.split(',').toList() : [],
                    inventoryStore: false,
                    findStock: true,
                    listStock: _bloc.listStockResponse,
                    allowDvt: itemSelect.allowDvt == 0 ? true : false,
                    price: Const.isWoPrice == false ? itemSelect.price??0 :itemSelect.woPrice??0,
                    nameProduction: itemSelect.name.toString(),
                    codeProduction:  itemSelect.code.toString(), listObjectJson: itemSelect.jsonOtherInfo.toString(),
                    updateValues: true, listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh,
                    nuocsx: _bloc.listOrder[indexSelect].nuocsx.toString(), quycach: _bloc.listOrder[indexSelect].quycach.toString() ,
                    idNVKD: _bloc.listOrder[indexSelect].idNVKD.toString(),
                    nameNVKD: _bloc.listOrder[indexSelect].nameNVKD.toString(),
                    tenThue:  _bloc.listOrder[indexSelect].tenThue,thueSuat:  _bloc.listOrder[indexSelect].thueSuat,
                  );
                }).then((value){
              if(value != null && double.parse(value[0].toString()) > 0){
                String codeStockOld = itemSelect.stockCode.toString().trim();
                _bloc.listOrder[indexSelect].name =  (value[7].toString().isNotEmpty && value[7].toString() != 'null') ? value[7].toString() : itemSelect.name;
                _bloc.listOrder[indexSelect].count = double.parse(value[0].toString());
                _bloc.listOrder[indexSelect].stockCode = (value[2].toString().isNotEmpty && !value[3].toString().contains('Chọn kho xuất hàng')) ? value[2].toString() : _bloc.listOrder[indexSelect].stockCode;
                _bloc.listOrder[indexSelect].stockName = (value[3].toString().isNotEmpty && !value[3].toString().contains('Chọn kho xuất hàng')) ? value[3].toString() : _bloc.listOrder[indexSelect].stockName;
                _bloc.listOrder[indexSelect].jsonOtherInfo = value[11].toString();
                _bloc.listOrder[indexSelect].heSo = value[12].toString();
                _bloc.listOrder[indexSelect].idNVKD = value[13].toString();
                _bloc.listOrder[indexSelect].nameNVKD = value[14].toString();
                _bloc.listOrder[indexSelect].nuocsx = value[15].toString();
                _bloc.listOrder[indexSelect].quycach = value[16].toString();
                _bloc.listOrder[indexSelect].dvt = value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() : _bloc.listOrder[indexSelect].dvt;
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
                    name: (value[7].toString().isNotEmpty && value[7].toString() != 'null') ? value[7].toString() : itemSelect.name,
                  name2:itemSelect.name2,
                  dvt:value[1].toString().replaceAll('null', '').isNotEmpty ? value[1].toString() :  itemSelect.dvt,
                  description:itemSelect.descript,
                  price: Const.isWoPrice == false ? itemSelect.price :itemSelect.woPrice,
                  priceAfter:  itemSelect.priceAfter ,
                  discountPercent:itemSelect.discountPercent,
                  stockAmount:itemSelect.stockAmount,
                  taxPercent:itemSelect.taxPercent,
                  imageUrl:itemSelect.imageUrl ?? '',
                  count:itemSelect.count,
                  isMark: itemSelect.isMark,
                  giaSuaDoi: double.parse(value[4].toString()),
                  giaGui: double.parse(value[6].toString()),
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
                  jsonOtherInfo: value[11].toString(),
                  heSo: value[12].toString(),
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
                print(production.price);
                _bloc.add(UpdateProductCount(
                    index: indexSelect,
                    count: double.parse(value[0].toString()),
                    addOrderFromCheckIn:  widget.orderFromCheckIn,
                    product: production,
                    stockCodeOld: codeStockOld,
                ));
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
                    listDvt: itemSelect.allowDvt == true ? itemSelect.contentDvt!.split(',').toList() : [],
                    inventoryStore: false,
                    findStock: true,
                    listStock: _bloc.listStockResponse,
                    allowDvt: DataLocal.listProductGift[indexSelectGift].allowDvt == 0 ? true : false,
                    nameProduction: DataLocal.listProductGift[indexSelectGift].name.toString(),
                    price: Const.isWoPrice == false ?  DataLocal.listProductGift[indexSelectGift].price??0 : DataLocal.listProductGift[indexSelectGift].woPrice??0,
                    codeProduction: DataLocal.listProductGift[indexSelectGift].code.toString(),
                    listObjectJson: DataLocal.listProductGift[indexSelectGift].jsonOtherInfo.toString(),
                    updateValues: true, listQuyDoiDonViTinh: _bloc.listQuyDoiDonViTinh, nuocsx: '', quycach: '',
                  );
                }).then((value){
              if(double.parse(value[0].toString()) > 0){
                setState(() {
                  _bloc.totalProductGift = _bloc.totalProductGift - DataLocal.listProductGift[indexSelectGift].count!;
                  DataLocal.listProductGift[indexSelectGift].count = double.parse(value[0].toString());
                  DataLocal.listProductGift[indexSelectGift].stockCode = (value[2].toString());
                  DataLocal.listProductGift[indexSelectGift].stockName = (value[3].toString());
                  DataLocal.listProductGift[indexSelectGift].jsonOtherInfo = (value[11].toString());
                  DataLocal.listProductGift[indexSelectGift].heSo = (value[12].toString());
                  DataLocal.listProductGift[indexSelectGift].contentDvt = (value[17].toString());
                  DataLocal.listProductGift[indexSelectGift].name = (value[7].toString().isNotEmpty && value[7].toString() != 'null') ? value[7].toString() :  DataLocal.listProductGift[indexSelectGift].name;
                  _bloc.totalProductGift = _bloc.totalProductGift + DataLocal.listProductGift[indexSelectGift].count!;
                });
              }
            });
          }
        }
        else if(state is CheckIsMarkProductSuccess){
          double totalDiscountForOder = _bloc.totalDiscountForOder ?? 0;
          _bloc.totalPayment = (_bloc.totalMoney - _bloc.totalDiscount - totalDiscountForOder) + _bloc.totalTax;
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
                }
              }
              break;
            }
          }
        }
      }
    }
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
        double x = ((element.price ?? 0) * element.count!);
        listItem = listItem == '' ? element.code.toString() : '$listItem,${element.code.toString()}';
        listQty = listQty == '' ? element.count.toString() : '$listQty,${element.count.toString()}';
        listPrice = listPrice == '' ?  (element.price ?? 0).toString() : '$listPrice,${(element.price ?? 0).toString()}';
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
      // ✅ Đảm bảo customerId không rỗng/null
      // Ưu tiên: widget.codeCustomer > DataLocal.infoCustomer.customerCode > _bloc.codeCustomer
      final finalCustomerId = ((widget.codeCustomer != null &&
                  widget.codeCustomer.toString().trim().isNotEmpty &&
                  widget.codeCustomer.toString().trim() != 'null')
              ? widget.codeCustomer.toString().trim()
              : ((DataLocal.infoCustomer.customerCode.toString().trim().isNotEmpty &&
                      DataLocal.infoCustomer.customerCode.toString().trim() != 'null')
                  ? DataLocal.infoCustomer.customerCode.toString().trim()
                  : (_bloc.codeCustomer?.toString().trim() ?? '')));

      // ✅ Đảm bảo warehouseId không rỗng
      // Ưu tiên: _bloc.storeCode > codeStore > widget.codeStore > Const.stockList[0].stockCode
      final finalWarehouseId = (!Utils.isEmpty(_bloc.storeCode.toString()) && _bloc.storeCode.toString().trim().isNotEmpty)
          ? _bloc.storeCode.toString()
          : ((!Utils.isEmpty(codeStore) && codeStore.trim().isNotEmpty)
              ? codeStore
              : ((widget.codeStore != null && !Utils.isEmpty(widget.codeStore.toString()) && widget.codeStore.toString().trim().isNotEmpty && widget.codeStore.toString().trim() != 'null')
                  ? widget.codeStore.toString()
                  : (Const.stockList.isNotEmpty ? Const.stockList[0].stockCode.toString() : '')));
      
      if (finalWarehouseId.isEmpty) {
        print('⚠️ Warning: warehouseId is empty in ConfirmScreen, API may fail!');
        print('   - _bloc.storeCode = ${_bloc.storeCode}');
        print('   - codeStore = $codeStore');
        print('   - widget.codeStore = ${widget.codeStore}');
        print('   - Const.stockList.length = ${Const.stockList.length}');
      }

      if (finalCustomerId.isEmpty) {
        print('⚠️ Warning: customerId is empty/null in ConfirmScreen, skip apply-discount-v2');
        print('   - widget.codeCustomer = ${widget.codeCustomer}');
        print('   - DataLocal.infoCustomer.customerCode = ${DataLocal.infoCustomer.customerCode}');
        print('   - _bloc.codeCustomer = ${_bloc.codeCustomer}');
        return;
      }
      
      _bloc.add(GetListItemApplyDiscountEvent(
        listCKVT: DataLocal.listCKVT,
        listPromotion: _bloc.listPromotion,
        listItem: listItem,
        listQty: listQty,
        listPrice: listPrice,
        listMoney: listMoney,
        warehouseId: finalWarehouseId,
        customerId: finalCustomerId,
        keyLoad: (key == '' && key.isEmpty) ? 'First' : key,
      ));
    }
  }

  Widget buildScreen(BuildContext context,CartState state){
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildAppBar(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              width: double.infinity,
              height: 1,
              color: Colors.blueGrey.withOpacity(0.5),
            ),
          ),
          Expanded(
              child: buildBody(height)
          ),
        ],
      ),
    );
  }

  Widget buildBody(double height){
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        buildListCart(),
        buildLine(),
        Visibility(
            visible: Const.discountSpecial == true,
            child: buildListProductGiftCart()),
        Visibility(
          visible: Const.discountSpecial == true,
          child: buildLine(),
        ),
        buildMethodReceive(),
        buildLine(),
        InkWell(
          onTap: (){
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return InputAddressPopup(note: (DataLocal.noteSell.isNotEmpty && DataLocal.noteSell != '' && DataLocal.noteSell != "null") ? DataLocal.noteSell.toString() : "",
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
            height: 45,
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
        buildLine(),

        buildPaymentDetail(),
        buildLine(),
        buildOtherRequest(),
        const SizedBox(height: 50,),
        buildPayment()
      ],
    );
  }

  buildPayment(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text('${NumberFormat(Const.amountFormat).format(_bloc.totalMNProduct??0)} đ',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.normal,decoration: TextDecoration.lineThrough),),
            // const SizedBox(width: 8,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng thanh toán',style: TextStyle(color: Colors.black,fontSize: 12),),
                Text('${Utils.formatMoneyStringToDouble(_bloc.totalPayment)} ₫',style: const TextStyle(color: subColor,fontWeight: FontWeight.bold),),
              ],
            ),
            const SizedBox(width: 18,),
            GestureDetector(
              onTap: (){
                if(Const.chooseStockBeforeOrder == true){
                  if(_bloc.listOrder.isNotEmpty) {
                    for (var element in _bloc.listOrder) {
                      if(element.isMark == 1){
                        if(element.stockCode.toString().isEmpty || element.stockCode == '' || element.stockCode == 'null'){
                          lockChooseStore = true;
                          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Vui lòng chọn kho cho SP bạn bán');
                          break;
                        }else{
                          lockChooseStore = false;
                        }
                      }
                    }
                  }
                  if(DataLocal.listProductGift.isNotEmpty) {
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
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: mainColor
                ),
                child: Center(
                  child: Text(widget.title.toString(),style: const TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void logic(){
    if (Const.chooseAgency == true){
      if(_bloc.transactionName.contains('Đại lý')){
        if(_bloc.codeAgency.toString() != '' && _bloc.codeAgency.toString() != 'null'){
          createOrder();
        }else{
          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn chưa chọn Đại lý kìa');
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
                      content: 'Chọn trạng thái đơn trước khi tạo mới',
                      ck_dac_biet: _bloc.ck_dac_biet,
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
                      storeCode:  _bloc.storeCode,
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
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: CustomOrderComponent(
                      iconData: MdiIcons.shopping,
                      title: 'Xác nhận đơn hàng',
                      content: 'Chọn trạng thái đơn trước khi tạo mới',
                      ck_dac_biet: _bloc.ck_dac_biet,
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
            ));
          }

        }
      }
      else{
        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Thông tin Khách hàng không được để trống');
      }
    }
    else{
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, '
          'Giỏ hàng của bạn đâu có gì?');
    }
  }

  buildLine(){
    return Padding(
      padding: const EdgeInsets.only(top: 10,bottom: 10),
      child: Container(
        height: 8,
        width: double.infinity,
        color: grey_200,
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
                            value: _bloc.checkAllProduct,
                            onChanged: (bool? b){
                              if(_bloc.listOrder.isNotEmpty){
                                _bloc.add(CheckAllProductEvent(b!));
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
                      const SizedBox(width: 6,),
                      Text('Sản phẩm (${_bloc.totalProductView.toInt()})',style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
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
                              DataLocal.datePayment = '';
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
            child: SizedBox(
              height: (!_bloc.expanded || _bloc.listOrder.length == 1) ? 100 : 250,
              child: buildListViewProduct(),
            ),
          ),
          Visibility(
            visible: _bloc.listOrder.isNotEmpty && _bloc.listOrder.length > 1,
            child: GestureDetector(
              onTap: (){
                _bloc.add(ChangeHeightListEvent(expanded: !_bloc.expanded));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(),
                    ),
                    Text(!_bloc.expanded ? 'Xem thêm' : 'Thu gọn',style: const TextStyle(color: Colors.blueGrey,fontSize: 12.5),),
                    Icon(!_bloc.expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,color: Colors.blueGrey,size: 16,),
                    const Expanded(
                      child: Divider(),
                    )
                  ],
                ),
              ),
            ),
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

  buildListViewProduct(){
    return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _bloc.listOrder.length,
        itemBuilder: (context,index){
          return Slidable(
              key: ValueKey('confirm-${_bloc.listOrder[index].code}-$index'),
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
              endActionPane: widget.viewDetail == true
                  ? null
                  : ActionPane(
                motion: const ScrollMotion(),
                dragDismissible: false,
                children: [
                  if (_bloc.listOrder[index].gifProduct != true)
                    SlidableAction(
                      onPressed:(_) {
                        gift = false;
                        indexSelect = index;
                        itemSelect = _bloc.listOrder[index];
                        _bloc.add(GetListStockEvent(itemCode: _bloc.listOrder[index].code.toString(),getListGroup: false,lockInputToCart: false, checkStockEmployee: Const.checkStockEmployee == true ? true : false));
                      },
                      borderRadius:const BorderRadius.all(Radius.circular(8)),
                      padding:const EdgeInsets.all(10),
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.edit_calendar_outlined,
                      label: 'Sửa',
                    ),
                  SlidableAction(
                    onPressed:(_) {
                      itemSelect = _bloc.listOrder[index];
                      if(DataLocal.listCKVT.isNotEmpty && DataLocal.listCKVT.contains('${itemSelect.sttRecCK.toString().trim()}-${itemSelect.code.toString().trim()}') == true){
                        DataLocal.listCKVT = DataLocal.listCKVT.replaceAll('${itemSelect.sctGoc.toString().trim()}-${itemSelect.code.toString().trim()}', '');
                      }
                      // ✅ FIX: Chỉ gọi DeleteProductFromDB, không cần gọi GetListProductFromDB
                      // Vì _deleteProductFromDB trong cart_bloc đã tự động gọi GetListProductFromDB rồi (dòng 1681)
                      _bloc.add(DeleteProductFromDB(false,index,_bloc.listOrder[index].code.toString(),_bloc.listOrder[index].stockCode.toString()));
                      // _bloc.add(GetListProductFromDB(addOrderFromCheckIn: false, getValuesTax: false,key: '')); // ❌ REMOVED: Bị gọi 2 lần
                    },
                    borderRadius:const BorderRadius.all(Radius.circular(8)),
                    padding:const EdgeInsets.all(10),
                    backgroundColor: const Color(0xFFC90000),
                    foregroundColor: Colors.white,
                    icon: Icons.delete_forever,
                    label: 'Xoá',
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: (){
                  // print(!Utils.isEmpty(_bloc.listOrder[index].listDiscount??[]));
                  // _bloc.listOrder[index].listDiscount!.clear();
                  // print(_bloc.listOrder[index].listDiscount!.length);

                  if(_bloc.listOrder[index].isMark == 1){
                    _bloc.listOrder[index].isMark = 0;
                  }
                  else{
                    _bloc.listOrder[index].isMark = 1;
                  }
                  itemSelect = _bloc.listOrder[index];
                  Product production = Product(
                    code: _bloc.listOrder[index].code,
                    name: _bloc.listOrder[index].name,
                    name2:_bloc.listOrder[index].name2,
                    dvt:_bloc.listOrder[index].dvt,
                    description:_bloc.listOrder[index].descript,
                    price: _bloc.listOrder[index].price ,
                    priceAfter:  _bloc.listOrder[index].priceAfter ,
                    discountPercent:_bloc.listOrder[index].discountPercent,
                    stockAmount:_bloc.listOrder[index].stockAmount,
                    taxPercent:_bloc.listOrder[index].taxPercent,
                    imageUrl:_bloc.listOrder[index].imageUrl ?? '',
                    count:_bloc.listOrder[index].count,
                    isMark: _bloc.listOrder[index].isMark,
                    discountMoney:_bloc.listOrder[index].discountMoney ?? '0',
                    discountProduct:_bloc.listOrder[index].discountProduct ?? '0',
                    budgetForItem:_bloc.listOrder[index].budgetForItem ?? '',
                    budgetForProduct:_bloc.listOrder[index].budgetForProduct ?? '',
                    residualValueProduct:_bloc.listOrder[index].residualValueProduct ?? 0,
                    residualValue:_bloc.listOrder[index].residualValue ?? 0,
                    unit:_bloc.listOrder[index].unit ?? '',
                    unitProduct:_bloc.listOrder[index].unitProduct ?? '',
                    dsCKLineItem:_bloc.listOrder[index].maCk.toString(),
                    allowDvt: _bloc.listOrder[index].allowDvt == true ? 0 : 1,
                    contentDvt: _bloc.listOrder[index].contentDvt ?? '',
                    kColorFormatAlphaB: _bloc.listOrder[index].kColorFormatAlphaB?.value,
                    codeStock: _bloc.listOrder[index].stockCode,
                    nameStock: _bloc.listOrder[index].stockName,
                  );
                  _bloc.add(CheckIsMarkProductEvent(_bloc.listOrder[index].isMark == 1 ? true : false, production,_bloc.listOrder[index]));
                },
                child: Card(
                  semanticContainer: true,
                  margin: EdgeInsets.only(
                      left: (_bloc.listOrder[index].gifProduct != true  && _bloc.listOrder[index].gifProductByHand != true)
                          ? 2 : 40,
                      right: 2,top: 5,bottom: 5),
                  child: Container(
                    padding: EdgeInsets.only(right: 6,top: 10,bottom: 10,
                    left: (_bloc.listOrder[index].gifProduct != true  && _bloc.listOrder[index].gifProductByHand != true)
                        ? 0 : 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Visibility(
                          visible: _bloc.listOrder[index].gifProduct != true  && _bloc.listOrder[index].gifProductByHand != true,
                          child: SizedBox(
                            width: 40,
                            child: Transform.scale(
                              scale: 1,
                              alignment: Alignment.topLeft,
                              child: Checkbox(
                                value: _bloc.listOrder[index].isMark == 0 ? false : true,
                                onChanged: (b){

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
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _bloc.listOrder[index].gifProduct == true  || _bloc.listOrder[index].gifProductByHand == true?
                            Container(
                                width: 30,
                                height: 30,
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
                                child: const Icon(Icons.card_giftcard_rounded ,size: 16,color: Colors.white,))
                                :
                            Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color:_bloc.listOrder[index].kColorFormatAlphaB == null ? Colors.blueGrey : Color(_bloc.listOrder[index].kColorFormatAlphaB!.value),
                                borderRadius: const BorderRadius.all(Radius.circular(6),)
                            ),
                            child: Center(child: Text('${_bloc.listOrder[index].name?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
                          ),
                          Visibility(
                            visible: !Utils.isEmpty(_bloc.listOrder[index].listDiscount??[]),
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
                            padding: EdgeInsets.only(
                                left: (_bloc.listOrder[index].gifProduct != true  && _bloc.listOrder[index].gifProductByHand != true)
                                    ? 10 : 19,right: 3,top: 0,bottom: 0),
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '[${_bloc.listOrder[index].code.toString().trim()}] ',
                                              style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                  0xff555a55)),
                                            ),
                                            TextSpan(
                                              text: _bloc.listOrder[index].name.toString().trim(),
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
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
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ),
                                    const SizedBox(width: 10,),
                                    Visibility(
                                      visible: _bloc.listOrder[index].gifProduct != true  && _bloc.listOrder[index].gifProductByHand != true,
                                      child: Column(
                                        children: [
                                          ((_bloc.listOrder[index].price ?? 0) > 0 && _bloc.listOrder[index].price == _bloc.listOrder[index].priceAfter ) ?
                                              Container()
                                              :
                                          Text(
                                           ((widget.currencyCode == "VND"
                                                ?
                                           _bloc.listOrder[index].price??0
                                                :
                                           _bloc.listOrder[index].price??0))
                                                == 0 ? 'Giá đang cập nhật' : '${widget.currencyCode == "VND"
                                                ?
                                            Utils.formatMoneyStringToDouble(_bloc.listOrder[index].price??0)
                                                :
                                            Utils.formatMoneyStringToDouble(_bloc.listOrder[index].price??0)} ₫'
                                            ,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color:
                                            ((widget.currencyCode == "VND"
                                                ?
                                            _bloc.listOrder[index].price??0
                                                :
                                            _bloc.listOrder[index].price??0)) == 0
                                                ?
                                            Colors.grey : Colors.red, fontSize: 10, decoration: ((widget.currencyCode == "VND"
                                                ?
                                            _bloc.listOrder[index].price??0
                                                :
                                            _bloc.listOrder[index].price??0)) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                          ),
                                          const SizedBox(height: 3,),
                                          Visibility(
                                            visible: _bloc.listOrder[index].priceAfter! > 0,
                                            child: Text(
                                              '${Utils.formatMoneyStringToDouble(_bloc.listOrder[index].priceAfter??0)} ₫',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(color: Color(
                                                  0xff067902), fontSize: 13,fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Const.lockStockInItem == false ? Flexible(
                                        child: Const.lockStockInItem == false && (_bloc.listOrder[index].gifProduct != true  && _bloc.listOrder[index].gifProductByHand != true)
                                            ?
                                        Padding(padding:const EdgeInsets.only(right: 20), child: Text(
                                          '${(_bloc.listOrder[index].stockName.toString().isNotEmpty && _bloc.listOrder[index].stockName.toString() != 'null') ? _bloc.listOrder[index].stockName : 'Chọn kho xuất hàng'}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:
                                          (!_bloc.listOrder[index].stockName.toString().trim().contains('Chọn kho xuất hàng') && _bloc.listOrder[index].stockName.toString().trim().isNotEmpty && _bloc.listOrder[index].stockName.toString().trim() != 'null') == true
                                              ?
                                          const Color(0xff358032)
                                              :
                                          Colors.red
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),)
                                            :
                                        Container(),
                                      ) : Container(),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _bloc.listOrder[index].gifProduct == true ? 'KL Tặng' :
                                            'KH đặt:',
                                            style: TextStyle(color: _bloc.listOrder[index].gifProduct == true ? Colors.red : Colors.black.withOpacity(0.7), fontSize: 11),
                                            textAlign: TextAlign.left,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text("${Utils.formatQuantity(_bloc.listOrder[index].count??0)} (${_bloc.listOrder[index].dvt.toString().trim()})",
                                            style: TextStyle(color: _bloc.listOrder[index].gifProduct == true ? Colors.red : blue, fontSize: 12),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ],
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
                                                      'CTBH:',
                                                      style: TextStyle(color: Colors.blueGrey, fontSize: 11),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Flexible(
                                                        child:
                                                        Text(
                                                          '${(_bloc.listOrder[index].idVv.toString() != '' && _bloc.listOrder[index].idVv.toString() != 'null') ? _bloc.listOrder[index].nameVv : 'Chọn Chương trình bán hàng'}',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:
                                                          (_bloc.listOrder[index].idVv.toString() != '' && _bloc.listOrder[index].idVv.toString() != 'null')
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
                                                          '${(_bloc.listOrder[index].idHd.toString().isNotEmpty && _bloc.listOrder[index].idHd.toString() != 'null') ? _bloc.listOrder[index].nameHd : 'Chọn hợp đồng'}',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:
                                                          (_bloc.listOrder[index].idHd.toString().isNotEmpty && _bloc.listOrder[index].idHd.toString() != 'null') == true
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
                                              _bloc.listOrder[index].gifProduct == true ? 'KL Tặng' :
                                              'KH đặt:',
                                              style: TextStyle(color: _bloc.listOrder[index].gifProduct == true ? Colors.red : Colors.black.withOpacity(0.7), fontSize: 11),
                                              textAlign: TextAlign.left,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text("${_bloc.listOrder[index].count?.toInt()??0} (${_bloc.listOrder[index].dvt.toString().trim()})",
                                              style: TextStyle(color: _bloc.listOrder[index].gifProduct == true ? Colors.red : blue, fontSize: 12),
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
                    Text('Sản phẩm tặng (${_bloc.totalProductGift.toInt()})',style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
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
            child: SizedBox(
              height: (!_bloc.expandedProductGift || DataLocal.listProductGift.length == 1) ? 100 : 250,
              child: buildListViewProductGift(),
            ),
          ),
          Visibility(
            visible: DataLocal.listProductGift.isNotEmpty && DataLocal.listProductGift.length > 1,
            child: GestureDetector(
              onTap: (){
                _bloc.add(ChangeHeightListProductGiftEvent(expandedProductGift: !_bloc.expandedProductGift));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(),
                    ),
                    Text(!_bloc.expandedProductGift ? 'Xem thêm' : 'Thu gọn',style: const TextStyle(color: Colors.blueGrey,fontSize: 12.5),),
                    Icon(!_bloc.expandedProductGift ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,color: Colors.blueGrey,size: 16,),
                    const Expanded(
                      child: Divider(),
                    )
                  ],
                ),
              ),
            ),
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

  buildListViewProductGift(){
    return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemCount: DataLocal.listProductGift.length,
        itemBuilder: (context,index){
          return Slidable(
              key: const ValueKey(1),
              startActionPane: Const.isVv == true
                  ? ActionPane(
                      motion: const ScrollMotion(),
                      // extentRatio: 0.25,
                      dragDismissible: false,
                      children: [
                        Visibility(
                          visible: false,
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
                            label: 'CTBH',
                          ),
                        ),
                      ],
                    )
                  : null,
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
                      _bloc.add(GetListStockEvent(itemCode: DataLocal.listProductGift[index].code.toString(),getListGroup: false,lockInputToCart: true, checkStockEmployee: Const.checkStockEmployee == true ? true : false));
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
                                    Visibility(
                                      visible: Const.lockStockInItem == false,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Const.lockStockInItem == false
                                                ?
                                            Text(
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
                                            )
                                                :
                                            Container(),
                                          ),
                                          const SizedBox(width: 20,),
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
                                              Text("${DataLocal.listProductGift[index].count?.toInt()??0} (${DataLocal.listProductGift[index].dvt.toString().trim()})",
                                                style: TextStyle(color: DataLocal.listProductGift[index].gifProduct == true ? Colors.red : blue, fontSize: 12),
                                                textAlign: TextAlign.left,
                                              ),
                                            ],
                                          ),
                                        ],
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
                                                Text("${DataLocal.listProductGift[index].count?.toInt()??0} (${DataLocal.listProductGift[index].dvt.toString().trim()})",
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
                  child: Const.woPrice == true ? Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text( Const.isWoPrice == false ? 'Bán lẻ' : 'Bán buôn',style: const TextStyle(fontSize: 12,color: Colors.black),),
                  )
                      :
                  transactionWidget()
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
                    PersistentNavBarNavigator.pushNewScreen(context, screen:const SearchCustomerScreen(selected: true,allowCustomerSearch: false,typeName: true, inputQuantity: false,),withNavBar: false).then((value){
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
                                    child:   SizedBox(
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
          customWidgetPayment('Tổng tiền hàng:','${Utils.formatMoneyStringToDouble(_bloc.totalMoney)} ₫',0,''),
          Visibility(
              visible: Const.enableViewPriceAndTotalPriceProductGift == true && DataLocal.listProductGift.isNotEmpty,
              child: customWidgetPayment('Tổng tiền hàng KM:','${Utils.formatMoneyStringToDouble(_bloc.totalMoneyProductGift)} ₫',0,'')),
          customWidgetPayment('Thuế:','${Utils.formatMoneyStringToDouble(_bloc.totalTax)} ₫',0,''),
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
                      // ✅ Đảm bảo warehouseId không rỗng
                      // Ưu tiên: _bloc.storeCode > codeStore > widget.codeStore > Const.stockList[0].stockCode
                      final finalWarehouseId = (!Utils.isEmpty(_bloc.storeCode.toString()) && _bloc.storeCode.toString().trim().isNotEmpty)
                          ? _bloc.storeCode.toString()
                          : ((!Utils.isEmpty(codeStore) && codeStore.trim().isNotEmpty)
                              ? codeStore
                              : ((widget.codeStore != null && !Utils.isEmpty(widget.codeStore.toString()) && widget.codeStore.toString().trim().isNotEmpty && widget.codeStore.toString().trim() != 'null')
                                  ? widget.codeStore.toString()
                                  : (Const.stockList.isNotEmpty ? Const.stockList[0].stockCode.toString() : '')));
                      
                      if (finalWarehouseId.isEmpty) {
                        print('⚠️ Warning: warehouseId is empty in ConfirmScreen (voucher), API may fail!');
                        print('   - _bloc.storeCode = ${_bloc.storeCode}');
                        print('   - codeStore = $codeStore');
                        print('   - widget.codeStore = ${widget.codeStore}');
                        print('   - Const.stockList.length = ${Const.stockList.length}');
                      }

                      // ✅ Đảm bảo customerId không rỗng/null
                      final finalCustomerId = ((widget.codeCustomer != null &&
                                  widget.codeCustomer.toString().trim().isNotEmpty &&
                                  widget.codeCustomer.toString().trim() != 'null')
                              ? widget.codeCustomer.toString().trim()
                              : ((DataLocal.infoCustomer.customerCode.toString().trim().isNotEmpty &&
                                      DataLocal.infoCustomer.customerCode.toString().trim() != 'null')
                                  ? DataLocal.infoCustomer.customerCode.toString().trim()
                                  : (_bloc.codeCustomer?.toString().trim() ?? '')));
                      if (finalCustomerId.isEmpty) {
                        print('⚠️ Warning: customerId is empty/null in ConfirmScreen (voucher), skip apply-discount-v2');
                        print('   - widget.codeCustomer = ${widget.codeCustomer}');
                        print('   - DataLocal.infoCustomer.customerCode = ${DataLocal.infoCustomer.customerCode}');
                        print('   - _bloc.codeCustomer = ${_bloc.codeCustomer}');
                        return;
                      }
                      
                      _bloc.add(GetListItemApplyDiscountEvent(
                          listCKVT: DataLocal.listCKVT,
                          listPromotion: _bloc.listPromotion,
                          listItem: listItem,
                          listQty: listQty,
                          listPrice: listPrice,
                          listMoney: listMoney,
                          warehouseId: finalWarehouseId,
                          customerId: finalCustomerId,
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
                  // Visibility(
                  //   visible: discount > 0,
                  //   child: DottedBorder(
                  //       dashPattern: const [5, 3],
                  //       color: subColor,
                  //       borderType: BorderType.RRect,
                  //       radius: const Radius.circular(2),
                  //       padding: const EdgeInsets.only(top: 2,bottom: 2,left: 16,right: 16),
                  //       child: Container(
                  //         decoration: const BoxDecoration(
                  //           borderRadius: BorderRadius.all(Radius.circular(8)),
                  //         ),
                  //         child: Text('-$discount %',style: TextStyle(fontSize: 11,color: subColor),
                  //         ),
                  //       )
                  //   ),
                  // ),
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
               if(widget.orderFromCheckIn == false && widget.addInfoCheckIn != true){
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
                     child: (widget.orderFromCheckIn == false && widget.addInfoCheckIn != true) ? const Icon(Icons.search_outlined,color: Colors.grey,size: 20,) : Container())
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

  late int indexValuesTax;

  Widget genderTaxWidget() {
    // Lấy tax hiện tại
    GetListTaxResponseData? currentTax;
    if (DataLocal.listTax.isNotEmpty && _bloc.taxIndex < DataLocal.listTax.length) {
      currentTax = DataLocal.listTax[_bloc.taxIndex];
    }

    return InkWell(
      onTap: () {
        // Show bottom sheet để chọn thuế
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => TaxSelectionSheet(
            selectedTax: currentTax,
            onTaxSelected: (tax) {
              // Xử lý khi chọn thuế
              if (tax.maThue.toString().trim() == '#000') {
                _bloc.allowTaxPercent = false;
              } else {
                _bloc.allowTaxPercent = true;
              }

              // Tìm index của tax trong DataLocal.listTax
              int indexValuesTax = 0;
              if (DataLocal.listTax.isNotEmpty) {
                int foundIndex = DataLocal.listTax.indexWhere(
                  (t) => t.maThue == tax.maThue,
                );
                if (foundIndex >= 0) {
                  indexValuesTax = foundIndex;
                }
              }

              indexValuesTax = DataLocal.listTax.indexOf(tax);
              DataLocal.indexValuesTax = indexValuesTax;
              DataLocal.taxPercent = tax.thueSuat!.toDouble();
              DataLocal.taxCode = tax.maThue.toString().trim();
              
              if (Const.afterTax == true) {
                _bloc.add(PickTaxAfter(DataLocal.indexValuesTax, DataLocal.taxPercent));
              } else {
                _bloc.add(PickTaxBefore(DataLocal.indexValuesTax, DataLocal.taxPercent));
              }
            },
            onLoadTaxList: () async {
              try {
                // Call API để lấy danh sách thuế
                final response = await _bloc.getListTaxFromAPI();
                
                // Parse response
                if (response != null && response is Map<String, dynamic>) {
                  final taxResponse = GetListTaxResponse.fromJson(response);
                  DataLocal.listTax = taxResponse.data ?? [];
                  
                  // ✅ Tự động thêm option "Không áp dụng thuế" vào đầu danh sách
                  if (DataLocal.listTax.isNotEmpty) {
                    GetListTaxResponseData element = GetListTaxResponseData(
                      maThue: '#000',
                      tenThue: 'Không áp dụng thuế cho đơn hàng này',
                      thueSuat: 0.0,
                    );
                    
                    // Chỉ thêm nếu chưa có
                    bool hasNoTaxOption = DataLocal.listTax.any((tax) => tax.maThue?.trim() == '#000');
                    if (!hasNoTaxOption) {
                      DataLocal.listTax.insert(0, element);
                    }
                  }
                  
                  return DataLocal.listTax;
                }
                
                // Fallback: return DataLocal.listTax nếu đã có
                return DataLocal.listTax;
              } catch (e) {
                print('❌ Error loading tax list: $e');
                // Fallback: return DataLocal.listTax nếu có lỗi
                return DataLocal.listTax;
              }
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                currentTax?.tenThue?.toString() ?? 'Chọn thuế',
                style: TextStyle(
                  fontSize: 12.0,
                  color: currentTax != null ? black : Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionWidget() {
    return Utils.isEmpty(Const.listTransactionsOrder)
        ? const Padding(
          padding: EdgeInsets.only(top: 6),
          child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
        )
        : DropdownButtonHideUnderline(
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
              _bloc.add(PickTransactionName(Const.listTransactionsOrder.indexOf(DataLocal.transaction),DataLocal.transaction.tenGd.toString(),DataLocal.transaction.chonDLYN??0));
          }),
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
          gradient:const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
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
                color: Colors.white,
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
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                  maxLines: 1,overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10,),
          // Nút chọn chương trình chiết khấu
          InkWell(
            onTap: () {
              if(widget.viewDetail == false && widget.orderFromCheckIn == false) {
                _showDiscountFlow();
              }
            },
            child: SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.card_giftcard,
                size: 25,
                color: widget.orderFromCheckIn == false ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 5,),
          InkWell(
            onTap: (){
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
                  // if(widget.viewUpdateOrder == false){
                  // _bloc.add(GetListProductFromDB(addOrderFromCheckIn: false, getValuesTax: false,key: ''));
                  _bloc.listOrder.clear();
                  _bloc.listItemOrder.clear();
                  _bloc.listCkMatHang.clear();
                  _bloc.listCkTongDon.clear();
                  _bloc.listPromotion = '';
                  calculationDiscount();
                  // }
                  // else {
                  //   _bloc.add(CheckDisCountWhenUpdateEvent(widget.sttRec.toString(),false,addNewItem: true,codeCustomer: widget.codeCustomer.toString(),codeStore: widget.codeStore.toString()));
                  // }
                });
              }
            },
            child: SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.search,
                size: 25,
                color: widget.orderFromCheckIn == false ? Colors.white : Colors.transparent,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget typeOrderWidget() {
    return Utils.isEmpty(Const.listTransactionsTAH)
        ? const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        : DropdownButtonHideUnderline(
      child: DropdownButton<ListTransaction>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: Const.listTransactionsTAH[_bloc.typeOrderIndex < 0 ? 0 : _bloc.typeOrderIndex],
          items: Const.listTransactionsTAH.map((value) => DropdownMenuItem<ListTransaction>(
            value: value,
            child: Text(value.tenGd.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            DataLocal.typeOrder = value!;
            _bloc.add(PickTypeOrderName(DataLocal.typeOrder.tenGd.toString(),Const.listTransactionsTAH.indexOf(DataLocal.typeOrder),DataLocal.typeOrder.maGd.toString()));
          }),
    );
  }

  // Sync listOrder to listProductOrderAndUpdate for UI update
  /// ✅ Hàm helper để làm sạch toàn bộ dữ liệu đơn hàng sau khi đặt đơn thành công
  void _clearAllOrderData() {
    print('🧹 Clearing all order data after successful order creation...');
    
    // 1. Clear danh sách sản phẩm
    _bloc.listOrder.clear();
    _bloc.listItemOrder.clear();
    _bloc.listProductOrder.clear();
    _bloc.listProductOrderAndUpdate.clear();
    
    // 2. Clear sản phẩm tặng
    DataLocal.listProductGift.clear();
    _bloc.totalProductGift = 0;
    
    // 3. Clear tổng tiền và chiết khấu
    _bloc.totalMoney = 0;
    _bloc.totalMoneyOld = 0;
    _bloc.totalDiscount = 0;
    _bloc.totalDiscountOld = 0;
    _bloc.totalDiscountOldByHand = 0;
    _bloc.totalDiscountByHand = 0;
    _bloc.totalTax = 0;
    _bloc.totalTax2 = 0;
    _bloc.valuesTax = 0;
    _bloc.totalPayment = 0;
    _bloc.totalPaymentOld = 0;
    _bloc.totalMoneyProductGift = 0;
    _bloc.manualTotalDiscountPercent = 0;
    
    // 4. Clear thông tin chiết khấu
    DataLocal.listOrderCalculatorDiscount.clear();
    DataLocal.listObjectDiscount.clear();
    DataLocal.listOrderDiscount.clear();
    DataLocal.listCKVT = '';
    _bloc.listPromotion = '';
    
    // 5. Clear discount selections
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
    
    // 6. Clear thông tin khách hàng
    _bloc.customerName = null;
    _bloc.codeCustomer = null;
    _bloc.phoneCustomer = null;
    _bloc.addressCustomer = null;
    DataLocal.infoCustomer = ManagerCustomerResponseData();
    nameCustomerController.clear();
    phoneCustomerController.clear();
    addressCustomerController.clear();
    
    // 7. Clear thông tin thanh toán và thuế
    DataLocal.transactionCode = "";
    DataLocal.transaction = ListTransaction();
    DataLocal.indexValuesTax = -1;
    DataLocal.taxPercent = 0;
    DataLocal.taxCode = '';
    DataLocal.valuesTypePayment = '';
    DataLocal.datePayment = '';
    DataLocal.noteSell = '';
    
    // 8. Clear thông tin VV/HD
    _bloc.idVv = '';
    _bloc.nameVv = 'Chọn Chương trình bán hàng';
    _bloc.idHd = '';
    _bloc.nameHd = '';
    _bloc.idHdForVv = '';
    
    // 9. Clear thông tin đại lý
    _bloc.codeAgency = '';
    _bloc.nameAgency = '';
    _bloc.typeDiscount = '';
    _bloc.discountAgency = 0;
    _bloc.chooseAgencyCode = false;
    
    // 10. Clear thông tin cửa hàng và giao hàng
    _bloc.storeCode = '';
    _bloc.storeIndex = 0;
    _bloc.typeDeliveryIndex = 0;
    _bloc.typeDeliveryName = '';
    _bloc.typeDeliveryCode = '';
    _bloc.transactionIndex = 0;
    _bloc.typeOrderIndex = 0;
    _bloc.typePaymentIndex = 0;
    _bloc.taxIndex = 0;
    
    // 11. Clear các list discount
    _bloc.listCkTongDon.clear();
    _bloc.listCkMatHang.clear();
    _bloc.listDiscount.clear();
    
    // 12. Clear các biến khác
    Const.numberProductInCart = 0;
    Const.listKeyGroupCheck = '';
    Const.listKeyGroup = '';
    DataLocal.listOrderProductIsChange = false;
    
    print('🧹 ✅ All order data cleared successfully');
  }

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

  // ========== DISCOUNT FLOW - START ==========
  
  // Main discount flow - Show voucher selection bottom sheet (E-commerce style)
  void _showDiscountFlow() async {
    // ❗️Không gọi API khi chỉ mở sheet – chỉ upload khi user nhấn "Áp dụng"

    // ✅ RESTORE selectedCkgIds, selectedHHIds, selectedCktdttIds từ ma_ck trong listOrder (khi sửa đơn từ chi tiết)
    // Chỉ restore nếu chưa có selection (tránh overwrite khi user đã chọn)
    if (widget.viewUpdateOrder == true && _bloc.listOrder.isNotEmpty) {
      bool needRestoreCkg = _bloc.selectedCkgIds.isEmpty;
      bool needRestoreHH = _bloc.selectedHHIds.isEmpty;
      bool needRestoreCktdtt = _bloc.selectedCktdttIds.isEmpty;
      
      if (needRestoreCkg || needRestoreHH || needRestoreCktdtt) {
        print('💰 Restoring discount selections from listOrder ma_ck...');
        Set<String> restoredCkgIds = <String>{};
        Set<String> restoredHHIds = <String>{};
        Set<String> restoredCktdttIds = <String>{};
        
        // Duyệt qua tất cả sản phẩm trong listOrder
        for (var product in _bloc.listOrder) {
          if (product.maCk != null && product.maCk.toString().trim().isNotEmpty) {
            String maCk = product.maCk.toString().trim();
            
            // ✅ Check CKG (chỉ restore nếu chưa có selection)
            if (needRestoreCkg && product.gifProduct != true) {
              for (var ckgItem in _bloc.listCkg) {
                String ckgMaCk = (ckgItem.maCk ?? '').trim();
                if (ckgMaCk == maCk) {
                  restoredCkgIds.add(maCk);
                  print('💰 Found CKG match: maCk=$maCk, product=${product.code}, tenCk=${ckgItem.tenCk}');
                  break;
                }
              }
            }
            
            // ✅ Check HH (gift products) - từ DataLocal.listProductGift
            // ✅ LOGIC RÕ RÀNG:
            // 1. Nếu maCk = rỗng hoặc null → KHÔNG RESTORE (gift sẽ được giữ lại bởi logic validate)
            // 2. Nếu maCk có, match được với listHH → RESTORE
            if (needRestoreHH) {
              for (var gift in DataLocal.listProductGift) {
                if (gift.typeCK == 'HH') {
                  String? giftMaCk = (gift.maCk ?? '').trim();
                  String? giftCode = (gift.code ?? '').trim();
                  
                  // ✅ CHỈ restore nếu có maCk (gift từ chọn chiết khấu)
                  if (giftMaCk.isEmpty) {
                    print('💰 Debug HH: Gift ${gift.code} has empty maCk - skipping restore (will be kept by validation logic)');
                    continue; // Không restore, nhưng gift sẽ được giữ lại bởi logic validate
                  }
                  
                  // ✅ Restore nếu match được với listHH
                  if (giftCode.isNotEmpty) {
                    for (var hhItem in _bloc.listHH) {
                      String hhSttRecCk = (hhItem.sttRecCk ?? '').trim();
                      String hhId = '${hhSttRecCk}_${hhItem.tenVt?.trim() ?? ''}';
                      String hhMaCk = (hhItem.maCk ?? '').trim();
                      String hhMaVt = (hhItem.maVt ?? '').trim();
                      
                      // ✅ Match theo maCk VÀ maVt (giống CKG)
                      if (hhMaCk.isNotEmpty && hhMaCk == giftMaCk &&
                          hhMaVt.isNotEmpty && hhMaVt == giftCode) {
                        restoredHHIds.add(hhId);
                        print('💰 Found HH match: hhId=$hhId, gift=${gift.code}, tenVt=${hhItem.tenVt} (matched by maCk="$giftMaCk" and maVt="$giftCode")');
                        break;
                      }
                    }
                  }
                }
              }
            }
          }
        }
        
        // ✅ Check CKTDTT từ totalDiscountForOder hoặc codeDiscountTD
        if (needRestoreCktdtt && _bloc.totalDiscountForOder != null && _bloc.totalDiscountForOder! > 0) {
          for (var cktdttItem in _bloc.listCktdtt) {
            String cktdttSttRecCk = (cktdttItem.sttRecCk ?? '').trim();
            String cktdttMaCk = (cktdttItem.maCk ?? '').trim();
            
            // Match bằng sttRecCk hoặc maCk
            if ((_bloc.sttRecCKOld?.trim() == cktdttSttRecCk) || 
                (_bloc.codeDiscountTD?.trim() == cktdttMaCk)) {
              restoredCktdttIds.add(cktdttSttRecCk);
              print('💰 Found CKTDTT match: sttRecCk=$cktdttSttRecCk, maCk=$cktdttMaCk');
              break;
            }
          }
        }
        
        // ✅ Update selections nếu có restore được (merge với existing nếu có)
        if (restoredCkgIds.isNotEmpty) {
          _bloc.selectedCkgIds.addAll(restoredCkgIds);
          print('💰 Restored selectedCkgIds: ${_bloc.selectedCkgIds}');
        }
        if (restoredHHIds.isNotEmpty) {
          _bloc.selectedHHIds.addAll(restoredHHIds);
          print('💰 Restored selectedHHIds: ${_bloc.selectedHHIds}');
        }
        if (restoredCktdttIds.isNotEmpty) {
          _bloc.selectedCktdttIds.addAll(restoredCktdttIds);
          print('💰 Restored selectedCktdttIds: ${_bloc.selectedCktdttIds}');
        }
        
        if (restoredCkgIds.isEmpty && restoredHHIds.isEmpty && restoredCktdttIds.isEmpty) {
          print('💰 No discounts found in listOrder to restore');
        } else {
          // ✅ Force rebuild sheet sau khi restore để checkbox được check
          print('💰 Restore completed, will rebuild sheet with restored selections');
        }
      } else {
        print('💰 Discount selections already exist, skipping restore');
      }
    }

    _discountSheetKey = GlobalKey<DiscountVoucherSelectionSheetState>();
    
    // ✅ Debug: Log selectedCkgIds trước khi mở sheet
    print('💰 Opening discount sheet with selectedCkgIds: ${_bloc.selectedCkgIds}');
    print('💰 Opening discount sheet with selectedHHIds: ${_bloc.selectedHHIds}');
    print('💰 Opening discount sheet with selectedCktdttIds: ${_bloc.selectedCktdttIds}');
    
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
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
          key: _discountSheetKey,
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
          onSelectCknGroup: (groupKey, items, totalQuantity) {
            _handleCKNSelection({'action': 'select', 'groupKey': groupKey, 'items': items, 'totalQuantity': totalQuantity});
          },
          onRemoveCknGroup: (groupKey) {
            _handleRemoveCKN({'groupKey': groupKey});
          },
          onSelectCktdthGroup: (groupKey, items, totalQuantity) {
            _handleCKTDTHSelection({'action': 'select', 'groupKey': groupKey, 'items': items, 'totalQuantity': totalQuantity});
          },
          onRemoveCktdthGroup: (groupKey) {
            _handleRemoveCKTDTH({'groupKey': groupKey});
          },
          onSelectCkg: (ckgId, ckgItem) {
            // ✅ CKG: Áp dụng ngay khi chọn (giống cart_screen)
            print('💰 🔔 CALLBACK: onSelectCkg called with ckgId=$ckgId');
            _handleCKGSelection(ckgId, ckgItem);
          },
          onRemoveCkg: (ckgId, ckgItem) {
            // ✅ CKG: Bỏ áp dụng ngay khi bỏ chọn (giống cart_screen)
            _handleRemoveCKG(ckgId, ckgItem);
          },
          onSelectCktdtt: (cktdttId, cktdttItem) {
            // ✅ CKTDTT: Áp dụng ngay khi chọn (giống cart_screen)
            print('💰 🔔 CALLBACK: onSelectCktdtt called with cktdttId=$cktdttId');
            _handleCKTDTTSSelection(cktdttId, cktdttItem);
          },
          onRemoveCktdtt: (cktdttId, cktdttItem) {
            // ✅ CKTDTT: Bỏ áp dụng ngay khi bỏ chọn (giống cart_screen)
            _handleRemoveCKTDTTS(cktdttId, cktdttItem);
          },
          onSelectHH: (hhId, hhItem) {
            // ✅ HH: Áp dụng ngay khi chọn
            print('💰 🔔 CALLBACK: onSelectHH called with hhId=$hhId');
            _handleHHSelection(hhId, hhItem);
          },
          onRemoveHH: (hhId, hhItem) {
            // ✅ HH: Bỏ áp dụng ngay khi bỏ chọn và gọi API reload
            print('💰 🔔 CALLBACK: onRemoveHH called with hhId=$hhId');
            _handleRemoveHH(hhId, hhItem);
          },
        ),
            );
          },
        ),
      ),
    );

    if (result != null) {
      _handleDiscountResult(result);
    }
  }

  // Handle discount result from bottom sheet
  void _handleDiscountResult(Map<String, dynamic> result) {
    final String action = result['action'];
    print('💰 Discount action: $action');

    switch (action) {
      case 'apply':
      case 'apply_all': // ✅ Fix: Handle 'apply_all' action from DiscountVoucherSelectionSheet
        _applyDiscounts(result);
        break;
      case 'select_ckn':
        _handleCKNSelection(result);
        break;
      case 'remove_ckn':
        _handleRemoveCKN(result);
        break;
      case 'select_cktdth':
        _handleCKTDTHSelection(result);
        break;
      case 'remove_cktdth':
        _handleRemoveCKTDTH(result);
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

      if (matchingCkn.isNotEmpty) {
        for (var ckn in matchingCkn) {
          if (item.sttRec0 == ckn.sttRecCk?.trim()) {
            _bloc.totalProductGift -= item.count ?? 0;
            removedCount++;
            return true;
          }
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

  // Handle remove CKTDTH group gifts
  void _handleRemoveCKTDTH(Map<String, dynamic> result) {
    final String groupKey = result['groupKey'];

    print('💰 CKTDTH: Removing gifts from group $groupKey');

    int removedCount = 0;
    DataLocal.listProductGift.removeWhere((item) {
      var matchingCktdth = _bloc.listCktdth.where((cktdth) =>
        cktdth.group_dk?.toString() == groupKey
      ).toList();

      if (matchingCktdth.isNotEmpty) {
        for (var cktdth in matchingCktdth) {
          if (item.sttRec0 == cktdth.sttRecCk?.trim()) {
            _bloc.totalProductGift -= item.count ?? 0;
            removedCount++;
            return true;
          }
        }
      }
      return false;
    });

    if (removedCount > 0) {
      Utils.showCustomToast(
        context,
        Icons.info,
        'Đã bỏ $removedCount quà tặng CKTDTH',
      );
      print('💰 CKTDTH: Removed $removedCount gifts - totalProductGift=${_bloc.totalProductGift}');
    }

    setState(() {});
  }

  // Apply all selected discounts
  void _applyDiscounts(Map<String, dynamic> result) {
    final Set<String> selectedCknGroups = result['selectedCknGroups'] ?? <String>{};
    final Set<String> selectedCkgIds = result['selectedCkgIds'] ?? <String>{};
    final Set<String> selectedHHIds = result['selectedHHIds'] ?? <String>{};
    final Set<String> selectedCktdttIds = result['selectedCktdttIds'] ?? <String>{};
    final Set<String> selectedCktdthGroups = result['selectedCktdthGroups'] ?? <String>{};

    print('💰 Applying discounts:');
    print('   - CKN groups: ${selectedCknGroups.length}');
    print('   - CKG: ${selectedCkgIds.length}');
    print('   - HH: ${selectedHHIds.length}');
    print('   - CKTDTT: ${selectedCktdttIds.length}');
    print('   - CKTDTH groups: ${selectedCktdthGroups.length}');

    // Save selections to bloc
    _bloc.selectedCknGroups = selectedCknGroups;
    _bloc.selectedCkgIds = selectedCkgIds;
    _bloc.selectedHHIds = selectedHHIds;
    _bloc.selectedCktdttIds = selectedCktdttIds;
    _bloc.selectedCktdthGroups = selectedCktdthGroups;

    // Apply CKG and CKTDTT (need to reload from backend)
    bool needReload = false;
    if (selectedCkgIds.isNotEmpty || selectedCktdttIds.isNotEmpty) {
      needReload = true;
      _applyAllCKG(selectedCkgIds);
      _applyAllCKTDTT(selectedCktdttIds);
    }

    // ✅ Apply HH gifts TRƯỚC KHI reload (để có trong DataLocal.listProductGift)
    // Sau đó sẽ re-apply sau API response nếu cần
    if (selectedHHIds.isNotEmpty) {
      print('💰 Applying HH gifts BEFORE reload');
      _applyAllHH(selectedHHIds);
      // ✅ Set flag để re-apply sau API reload
      if (needReload) {
        _needReapplyHHAfterReload = true;
        print('💰 Set _needReapplyHHAfterReload = true (will re-apply HH after API reload)');
      }
    }

    // Reload discounts from backend if needed
    if (needReload) {
      _reloadDiscountsFromBackend();
    } else {
      print('💰 No discount changes to sync');
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

    int totalApplied = selectedCknGroups.length + selectedCkgIds.length + selectedHHIds.length + selectedCktdttIds.length + selectedCktdthGroups.length;
    Utils.showCustomToast(
      context,
      Icons.check_circle_outline,
      'Đã áp dụng $totalApplied chương trình khuyến mại',
    );

    setState(() {});
  }

  // Apply all selected CKG discounts (add to listCKVT for backend)
  void _applyAllCKG(Set<String> selectedIds) {
    print('💰 Applying ${selectedIds.length} CKG discounts');
    print('💰 Selected IDs: $selectedIds');
    
    bool hasAdditions = false;
    bool hasRemovals = false;
    
    for (var ckgItem in _bloc.listCkg) {
      String sttRecCk = ckgItem.sttRecCk?.trim() ?? '';
      String productCode = ckgItem.maVt?.trim() ?? '';
      
      // ✅ Build ckgId với format giống DiscountVoucherSelectionSheet: "sttRecCk_productCode"
      // Hoặc có thể là maCk (nếu DiscountVoucherSelectionSheet đã convert)
      String ckgId = '${sttRecCk}_$productCode';
      String maCk = (ckgItem.maCk ?? '').trim();
      
      // ✅ Check both formats: ckgId (sttRecCk_productCode) và maCk
      bool shouldApply = selectedIds.contains(ckgId) || (maCk.isNotEmpty && selectedIds.contains(maCk));
      
      // ✅ discountKey dùng format "-" (vì DataLocal.listCKVT dùng format này)
      String discountKey = '${sttRecCk}-${productCode}';
      
      print('💰 Processing CKG: ckgId=$ckgId, maCk=$maCk, sttRecCk=$sttRecCk, productCode=$productCode, shouldApply=$shouldApply');
      
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
            final giaSauCk = (ckgItem.giaSauCk ?? 0).toDouble();
            final giaGoc = (ckgItem.giaGoc ?? originalPrice).toDouble();
            double priceAfter = originalPrice;
            double discountPercent = 0;

            if (tlCk > 0) {
              // Case 1: Trường hợp có tỉ lệ chiết khấu (%)
              discountPercent = tlCk;
              priceAfter = originalPrice - (originalPrice * discountPercent / 100);
            } else if (giaSauCk > 0 && giaSauCk != giaGoc && giaGoc > 0) {
              // Ưu tiên: Trường hợp có giá sau chiết khấu và khác giá gốc (có chiết khấu thực sự)
              priceAfter = giaSauCk;
              discountPercent = originalPrice > 0 ? ((originalPrice - priceAfter) / originalPrice) * 100 : 0;
            } else if (ckValue > 0) {
              // Case 2: Trường hợp có số tiền chiết khấu
              double ckPerItem = ckValue;
              
              // Nếu ck > giaGoc, có thể là tổng chiết khấu cho nhiều sản phẩm
              // Tìm số lượng sản phẩm trong giỏ hàng với cùng mã sản phẩm
              if (ckValue > giaGoc && giaGoc > 0) {
                double totalQuantity = 0;
                for (var item in _bloc.listOrder) {
                  if ((item.code ?? '').trim() == productCode.trim() && item.gifProduct != true) {
                    totalQuantity += (item.count ?? 0);
                  }
                }
                // Nếu tìm thấy số lượng, chia ck cho số lượng
                if (totalQuantity > 0) {
                  ckPerItem = ckValue / totalQuantity;
                  print('💰 CKG: ck=$ckValue là tổng cho $totalQuantity sản phẩm, ckPerItem=$ckPerItem');
                }
              }
              
              // Áp dụng chiết khấu nếu hợp lý (ckPerItem <= originalPrice)
              if (ckPerItem <= originalPrice && originalPrice > 0) {
                priceAfter = originalPrice - ckPerItem;
                discountPercent = (ckPerItem / originalPrice) * 100;
              } else if (ckPerItem > originalPrice && originalPrice > 0) {
                // Nếu ckPerItem vẫn > originalPrice, có thể là lỗi dữ liệu, nhưng vẫn tính để hiển thị
                priceAfter = 0;
                discountPercent = 100; // 100% discount
                print('💰 ⚠️ WARNING: ckPerItem=$ckPerItem > originalPrice=$originalPrice, set priceAfter=0');
              }
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
            print('💰 UNCHECK: Removing discount for product ${productCode}');
            
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
            
            // ✅ QUAN TRỌNG: LUÔN RESET discount cho product này khi UNCHECK (không cần check điều kiện thêm)
            // Vì đã match productCode rồi, chỉ cần reset
            print('💰 [${i}] Resetting ${productCode}: discountPercent=${_bloc.listOrder[i].discountPercent} → 0');
            
            // ✅ QUAN TRỌNG: Get original price (giá gốc) đúng cách
            // Trong edit mode, element.price là giá gốc từ lineItem
            // Trong add mode, element.giaSuaDoi là giá gốc (nếu chưa có chiết khấu)
            double originalPrice = 0;
            
            // Check nếu đang ở edit mode (có maCk hoặc giaSuaDoi != price)
            // ⚠️ CHÚ Ý: Phải check TRƯỚC KHI clear maCk, vì sau khi clear thì không còn maCk để check
            bool isEditMode = (_bloc.listOrder[i].maCk != null && _bloc.listOrder[i].maCk.toString().trim().isNotEmpty) ||
                             (_bloc.listOrder[i].giaSuaDoi != null && _bloc.listOrder[i].price != null && 
                              _bloc.listOrder[i].giaSuaDoi! > 0 && _bloc.listOrder[i].price! > 0 && 
                              _bloc.listOrder[i].giaSuaDoi != _bloc.listOrder[i].price);
            
            if (isEditMode) {
              // EDIT MODE: Dùng price (giá gốc từ lineItem)
              originalPrice = _bloc.listOrder[i].price ?? 0;
              print('💰 [EDIT MODE] Using price as originalPrice: $originalPrice (giaSuaDoi=${_bloc.listOrder[i].giaSuaDoi} was priceAfter)');
            } else {
              // ADD MODE: Dùng giaSuaDoi (giá gốc)
              originalPrice = _bloc.listOrder[i].giaSuaDoi ?? 0;
              if (originalPrice == 0) {
                originalPrice = _bloc.listOrder[i].price ?? 0;
              }
              print('💰 [ADD MODE] Using giaSuaDoi as originalPrice: $originalPrice');
            }
            
            // Reset ALL discount fields
            _bloc.listOrder[i].typeCK = '';
            _bloc.listOrder[i].maCk = '';
            _bloc.listOrder[i].sttRecCK = '';
            _bloc.listOrder[i].maVtGoc = '';
            _bloc.listOrder[i].sctGoc = '';
            _bloc.listOrder[i].discountPercent = 0; // ✅ QUAN TRỌNG: Reset discountPercent về 0
            _bloc.listOrder[i].discountPercentByHand = 0;
            _bloc.listOrder[i].ckntByHand = 0;
            _bloc.listOrder[i].ck = 0;
            _bloc.listOrder[i].cknt = 0;
            _bloc.listOrder[i].discountByHand = false;
            
            // ✅ Reset về giá gốc - ĐẢM BẢO UI HIỂN THỊ ĐÚNG
            if (isEditMode) {
              // EDIT MODE: Giữ nguyên price (giá gốc), set giaSuaDoi = price để đồng bộ
              _bloc.listOrder[i].price = originalPrice; // Giá gốc từ lineItem
              _bloc.listOrder[i].giaSuaDoi = originalPrice; // Set bằng price để đồng bộ
              _bloc.listOrder[i].priceAfter = originalPrice; // Giá sau = giá gốc
              _bloc.listOrder[i].priceAfter2 = originalPrice;
              print('💰 [EDIT MODE] Reset: price=$originalPrice, giaSuaDoi=$originalPrice, priceAfter=$originalPrice');
            } else {
              // ADD MODE: Giữ nguyên logic cũ
              _bloc.listOrder[i].giaSuaDoi = originalPrice; // Giá gốc
              _bloc.listOrder[i].price = originalPrice; // Giá gốc
              _bloc.listOrder[i].priceAfter = originalPrice; // Giá sau = giá gốc
              _bloc.listOrder[i].priceAfter2 = originalPrice;
            }
            
            DataLocal.listOrderCalculatorDiscount.removeWhere(
              (element) => element.code.toString().trim() == productCode.toString().trim()
            );
            
            hasRemovals = true; // Ensure hasRemovals is set
            print('💰 [${i}] RESET DONE: originalPrice=$originalPrice, priceAfter=$originalPrice, discountPercent=0');
          }
        }
      }
    }
    
    // ✅ FORCE UI UPDATE NGAY
    if (hasRemovals || hasAdditions) {
      print('💰 Force UI rebuild - hasRemovals=$hasRemovals, hasAdditions=$hasAdditions');
      
      // ✅ CRITICAL: Sync listOrder → listProductOrderAndUpdate và database (đặc biệt quan trọng cho edit mode)
      if (widget.viewUpdateOrder == true) {
        print('💰 [EDIT MODE] Syncing discount changes to database...');
        _syncListOrderToUI();
      }
      
      // ✅ CRITICAL: Tính lại total LOCAL (không cần gọi backend vì backend không nhận discount info)
      _recalculateTotalLocal();
      
      setState(() {});
    }
    
    print('💰 Updated listCKVT: ${DataLocal.listCKVT}');
    print('💰 Updated listPromotion: ${_bloc.listPromotion}');
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
          code: hhItem.maVt?.trim() ?? '',
          sttRec0: hhItem.sttRecCk?.trim() ?? '',
          name: hhItem.tenVt ?? 'Quà tặng',
          name2: hhItem.tenVt ?? 'Quà tặng',
          dvt: hhItem.dvt ?? '',
          count: hhItem.soLuong ?? 0,
          priceAfter: 0,
          price: 0,
          giaSuaDoi: 0,
          typeCK: 'HH',
          discountPercent: 0,
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
    // Reset totalDiscountForOder
    _bloc.totalDiscountForOder = 0;

    // Rebuild listPromotion for CKTDTT
    List<String> promoList = _bloc.listPromotion.split(',').where((s) => s.isNotEmpty).toList();

    for (var cktdttItem in _bloc.listCktdtt) {
      String cktdttId = cktdttItem.sttRecCk?.trim() ?? '';
      if (selectedIds.contains(cktdttId)) {
        // ✅ Add to List_promo nếu chưa có
        if (!promoList.contains(cktdttId)) {
          promoList.add(cktdttId);
        }
        // ✅ Cộng dồn chiết khấu (tiền hoặc %)
        // tlCkTt: tỷ lệ chiết khấu (%), tCkTt: tiền chiết khấu
        if (cktdttItem.tlCkTt != null && cktdttItem.tlCkTt! > 0) {
          // Tính % trên totalPayment
          double discountAmount = (_bloc.totalPayment * (cktdttItem.tlCkTt ?? 0)) / 100;
          _bloc.totalDiscountForOder += discountAmount;
        } else if (cktdttItem.tCkTt != null && cktdttItem.tCkTt! > 0) {
          // Tiền mặt
          _bloc.totalDiscountForOder += cktdttItem.tCkTt ?? 0;
        }
      } else {
        // ✅ Remove from List_promo nếu không được chọn
        promoList.removeWhere((item) => item.trim() == cktdttId);
      }
    }

    // ✅ Update listPromotion
    _bloc.listPromotion = promoList.join(',');

    print('💰 CKTDTT complete - totalDiscountForOder=${_bloc.totalDiscountForOder}');
    print('💰 Updated listPromotion: ${_bloc.listPromotion}');

    // Recalculate totals
    _recalculateTotalLocal();
  }

  // Recalculate total payment locally (without API call)
  void _recalculateTotalLocal() {
    print('💰 === Recalculating Total Locally ===');
    
    double totalMoney = 0;
    double totalDiscount = 0;
    double totalTax = 0;
    
    // Loop through all products
    for (var element in _bloc.listOrder) {
      if (element.isMark == 1 && element.gifProduct != true) {
        double originalPrice = element.giaSuaDoi ?? 0;
        if (originalPrice == 0) {
          originalPrice = element.price ?? 0;
        }
        double quantity = element.count ?? 0;
        
        // ✅ QUAN TRỌNG: Tính priceAfter - ưu tiên từ element.priceAfter, nếu không có thì tính từ discountPercent
        // Điều này đảm bảo tính đúng cho mọi trường hợp và đồng bộ với UI
        double priceAfter = element.priceAfter ?? 0;
        double discountPercent = (element.discountPercentByHand ?? 0) > 0 
          ? (element.discountPercentByHand ?? 0) 
          : (element.discountPercent ?? 0);
        
        // Nếu priceAfter chưa được set hoặc bằng 0, tính từ discountPercent
        if (priceAfter == 0 || priceAfter == originalPrice) {
          if (discountPercent > 0 && originalPrice > 0) {
            priceAfter = originalPrice - (originalPrice * discountPercent / 100);
            if (priceAfter < 0) priceAfter = 0;
          } else {
            priceAfter = originalPrice;
          }
        }
        
        totalMoney += originalPrice * quantity;  // Original total
        
        // ✅ Calculate discount từ sự khác biệt giữa originalPrice và priceAfter
        // Điều này đảm bảo tính đúng cho mọi trường hợp (tlCk, giaSauCk, ckValue)
        if (priceAfter < originalPrice && originalPrice > 0) {
          double lineDiscount = (originalPrice - priceAfter) * quantity;
          totalDiscount += lineDiscount;
        }
        
        // ✅ Calculate tax nếu có sử dụng thuế
        if (Const.useTax == true && priceAfter > 0) {
          double taxPercent = DataLocal.taxPercent;
          double lineTax = ((priceAfter * quantity) * taxPercent) / 100;
          totalTax += lineTax;
          
          // Update element.valuesTax để đảm bảo UI hiển thị đúng
          element.valuesTax = lineTax / quantity; // Tax per unit
        }

         discountPercent = (element.discountPercentByHand ?? 0) > 0
          ? (element.discountPercentByHand ?? 0)
          : (element.discountPercent ?? 0);

        print('💰 Product ${element.code}: qty=$quantity, originalPrice=$originalPrice, priceAfter=$priceAfter, discountPercent=$discountPercent%, lineDiscount=${priceAfter < originalPrice && originalPrice > 0 ? (originalPrice - priceAfter) * quantity : 0}, lineTax=${Const.useTax == true ? ((priceAfter * quantity) * DataLocal.taxPercent) / 100 : 0}');
      }
    }
    
    // ✅ Update BLoC state
    _bloc.totalMoney = totalMoney;
    _bloc.totalDiscount = totalDiscount;
    
    // ✅ Tính totalPayment = totalMoney - totalDiscount - totalDiscountForOder + totalTax
    // totalMoney: Tổng tiền nguyên giá
    // totalDiscount: Tổng chiết khấu sản phẩm (CKG, CKN, HH)
    // totalDiscountForOder: Tổng chiết khấu tổng đơn (CKTDTT - Chiết khấu tổng đơn tặng tiền)
    // totalTax: Tổng thuế (nếu có)
    _bloc.totalPayment = totalMoney - totalDiscount - (_bloc.totalDiscountForOder ?? 0) + totalTax;
    if (_bloc.totalPayment < 0) _bloc.totalPayment = 0;

    print('💰 Recalculated totals:');
    print('   - totalMoney: ${_bloc.totalMoney}');
    print('   - totalDiscount: ${_bloc.totalDiscount}');
    print('   - totalDiscountForOder: ${_bloc.totalDiscountForOder}');
    print('   - totalTax: $totalTax');
    print('   - totalPayment: ${_bloc.totalPayment}');

    setState(() {});
  }

  // Handle CKN selection (when user clicks checkbox and needs to select gifts)
  void _handleCKNSelection(Map<String, dynamic> result) async {
    final String groupKey = result['groupKey'];
    final List<ListCkMatHang> items = result['items'];
    final double totalQuantity = result['totalQuantity'];

    print('💰 CKN: User selected group $groupKey, need to select ${totalQuantity.toInt()} gifts from ${items.length} items');

    // Store pending state
    _pendingCknGroupKey = groupKey;
    _pendingDiscountItems = items;
    _pendingMaxQuantity = totalQuantity;
    _pendingDiscountType = 'CKN';
    _pendingDiscountName = items.isNotEmpty ? (items[0].tenVt ?? 'Chương trình CKN') : 'Chương trình CKN';

    // Close bottom sheet first
    Navigator.of(context).pop();

    // Show gift product selection dialog
    await _showGiftProductSelectionDialog();
  }

  // Handle CKTDTH selection
  void _handleCKTDTHSelection(Map<String, dynamic> result) async {
    final String groupKey = result['groupKey'];
    final List<ListCkMatHang> items = result['items'];
    final double totalQuantity = result['totalQuantity'];

    print('💰 CKTDTH: User selected group $groupKey, need to select ${totalQuantity.toInt()} gifts from ${items.length} items');

    _pendingCktdthGroupKey = groupKey;
    _pendingDiscountItems = items;
    _pendingMaxQuantity = totalQuantity;
    _pendingDiscountType = 'CKTDTH';
    _pendingDiscountName = items.isNotEmpty ? (items[0].tenVt ?? 'Chương trình CKTDTH') : 'Chương trình CKTDTH';

    Navigator.of(context).pop();
    await _showGiftProductSelectionDialog();
  }

  // Show gift product selection dialog
  Future<void> _showGiftProductSelectionDialog() async {
    if (_pendingDiscountItems == null || _pendingMaxQuantity == null) {
      print('💰 ERROR: No pending discount items or quantity');
      return;
    }

    // ✅ FIX: Use _bloc.listGiftProducts (already populated from API)
    final result = await showDialog<Map<String, double>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CknGiftProductSelectionDialog(
        giftProducts: _bloc.listGiftProducts,
        discountName: _pendingDiscountName ?? 'Chương trình khuyến mại',
        maxQuantity: _pendingMaxQuantity!,
        initialSelections: {},
      ),
    );

    if (result != null && result.isNotEmpty) {
      print('💰 User selected ${result.length} gift products');

      // Process selected products
      _processSelectedGiftProducts(result);

      // Add to selection set
      if (_pendingDiscountType == 'CKN') {
        _bloc.selectedCknGroups.add(_pendingCknGroupKey!);
      } else if (_pendingDiscountType == 'CKTDTH') {
        _bloc.selectedCktdthGroups.add(_pendingCktdthGroupKey!);
      }

      Utils.showCustomToast(
        context,
        Icons.check_circle_outline,
        'Đã thêm ${result.length} quà tặng',
      );

      setState(() {});

      // Clear pending state
      _clearPendingDiscountState();
    } else {
      print('💰 User cancelled gift selection');
      _clearPendingDiscountState();
    }
  }

  // Process selected gift products (after user confirms selection)
  void _processSelectedGiftProducts(Map<String, double> selectedQuantities) {
    if (_pendingDiscountItems == null || _pendingDiscountItems!.isEmpty) {
      print('💰 ERROR: No pending discount items');
      return;
    }

    final discountItem = _pendingDiscountItems!.first;
    
    // Add all newly selected products
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

      print('💰 Adding gift: $productName x$quantity');

      // Create gift product object
      SearchItemResponseData gift = SearchItemResponseData(
        code: productCode,
        sttRec0: discountItem.sttRecCk?.trim() ?? '',
        sttRecCK: discountItem.sttRecCk?.trim() ?? '',
        maCk: discountItem.sttRecCk?.trim() ?? '',
        name: productName,
        name2: productName,
        dvt: discountItem.dvt ?? '',
        count: quantity,
        priceAfter: 0,
        price: 0,
        giaSuaDoi: 0,
        typeCK: _pendingDiscountType ?? 'CKN',
        discountPercent: 0,
        gifProduct: true,
        stockAmount: 0,
        isMark: 1,
      );

      DataLocal.listProductGift.add(gift);
      _bloc.totalProductGift += quantity.toInt();
    }

    print('💰 Total gifts after adding: ${_bloc.totalProductGift}');
  }

  // Clear pending discount state
  void _clearPendingDiscountState() {
    _pendingDiscountName = null;
    _pendingMaxQuantity = null;
    _pendingDiscountItems = null;
    _pendingDiscountType = null;
    _pendingCknGroupKey = null;
    _pendingCktdthGroupKey = null;
  }

  // Reload discounts from backend after applying CKG/CKTDTT
  void _reloadDiscountsFromBackend() {
    print('💰 Reloading discounts from backend...');
    print('💰   - listCKVT: ${DataLocal.listCKVT}');
    print('💰   - listPromotion: ${_bloc.listPromotion}');

    // Call API to reload discounts
    getDiscountProduct('Second');
  }

  // ========== DISCOUNT FLOW - END ==========

  // ========== HANDLE IMMEDIATE SELECTION/REMOVAL (giống cart_screen) ==========

  // Handle CKG selection (when user clicks checkbox - apply immediately)
  void _handleCKGSelection(String ckgId, ListCk ckgItem) {
    print('💰 ========== CKG SELECTION START ==========');
    print('💰 CKG: User selecting discount for ckgId=$ckgId');
    print('💰 CKG Item: sttRecCk=${ckgItem.sttRecCk}, maVt=${ckgItem.maVt}, maCk=${ckgItem.maCk}');
    
    // ✅ Parse ckgId: có thể là maCk hoặc format "sttRecCk_productCode"
    String maCk = (ckgItem.maCk ?? '').trim();
    String sttRecCk = ckgItem.sttRecCk?.trim() ?? '';
    String productCode = ckgItem.maVt?.trim() ?? '';
    
    // Nếu ckgId là maCk, tìm tất cả CKG items cùng ma_ck
    if (ckgId == maCk || (!ckgId.contains('_') && ckgId == sttRecCk)) {
      // Apply cho tất cả items cùng ma_ck
      _applyCKGByMaCk(maCk, shouldApply: true);
    } else {
      // Nếu ckgId là format "sttRecCk_productCode", apply cho item cụ thể
      _applySingleCKG(ckgId, ckgItem, shouldApply: true);
    }
    
    // Update BLoC state
    _bloc.selectedCkgIds.add(ckgId);
    print('💰 Updated selectedCkgIds: ${_bloc.selectedCkgIds}');
    print('💰 ========== CKG SELECTION END ==========');
  }

  // Handle CKG removal (when user unchecks checkbox - remove immediately)
  void _handleRemoveCKG(String ckgId, ListCk ckgItem) {
    print('💰 CKG: User removing discount for ckgId=$ckgId');
    
    // ✅ Parse ckgId tương tự
    String maCk = (ckgItem.maCk ?? '').trim();
    String sttRecCk = ckgItem.sttRecCk?.trim() ?? '';
    
    // Nếu ckgId là maCk, remove cho tất cả items cùng ma_ck
    if (ckgId == maCk || (!ckgId.contains('_') && ckgId == sttRecCk)) {
      _applyCKGByMaCk(maCk, shouldApply: false);
    } else {
      _applySingleCKG(ckgId, ckgItem, shouldApply: false);
    }
    
    // Update BLoC state
    _bloc.selectedCkgIds.remove(ckgId);
  }

  // Handle CKTDTT selection (when user clicks checkbox - apply immediately)
  void _handleCKTDTTSSelection(String cktdttId, ListCkTongDon cktdttItem) {
    print('💰 ========== CKTDTT SELECTION START ==========');
    print('💰 CKTDTT: User selecting discount for cktdttId=$cktdttId');
    print('💰 CKTDTT Item: sttRecCk=${cktdttItem.sttRecCk}, maCk=${cktdttItem.maCk}');
    
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

  // Apply CKG discount cho tất cả items cùng ma_ck
  void _applyCKGByMaCk(String maCk, {required bool shouldApply}) {
    print('💰 ========== _applyCKGByMaCk START ==========');
    print('💰 maCk=$maCk, shouldApply=$shouldApply');
    
    // Tìm tất cả CKG items có cùng ma_ck
    List<ListCk> ckgItemsWithSameMaCk = _bloc.listCkg.where((ckg) => 
      (ckg.maCk ?? '').trim() == maCk.trim()
    ).toList();
    
    print('💰 Found ${ckgItemsWithSameMaCk.length} CKG items with maCk=$maCk');
    
    // Apply cho từng item
    for (var ckgItem in ckgItemsWithSameMaCk) {
      String sttRecCk = ckgItem.sttRecCk?.trim() ?? '';
      String productCode = ckgItem.maVt?.trim() ?? '';
      String ckgId = '${sttRecCk}_$productCode';
      
      print('💰 Applying CKG for product: $productCode (sttRecCk=$sttRecCk)');
      _applySingleCKG(ckgId, ckgItem, shouldApply: shouldApply);
    }
    
    print('💰 ========== _applyCKGByMaCk END ==========');
  }

  // Apply or remove a single CKG discount
  void _applySingleCKG(String ckgId, ListCk ckgItem, {required bool shouldApply}) {
    String sttRecCk = ckgItem.sttRecCk?.trim() ?? '';
    String productCode = ckgItem.maVt?.trim() ?? '';
    
    // Parse ckgId nếu cần
    if (ckgId.contains('_')) {
      List<String> parts = ckgId.split('_');
      if (parts.length >= 2) {
        sttRecCk = parts[0].trim();
        productCode = parts[1].trim();
      }
    }
    
    String discountKey = '${sttRecCk}-${productCode}';
    
    print('💰 _applySingleCKG: ckgId=$ckgId, sttRecCk=$sttRecCk, productCode=$productCode, shouldApply=$shouldApply');
    
    List<String> ckvtList = DataLocal.listCKVT.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    bool ckvtExists = ckvtList.contains(discountKey);
    
    List<String> promoList = _bloc.listPromotion.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    bool promoExists = promoList.contains(sttRecCk);
    
    bool hasChanges = false;
    
    for (int i = 0; i < _bloc.listOrder.length; i++) {
      String cartProductCode = (_bloc.listOrder[i].code ?? '').trim();
      
      if (cartProductCode == productCode.trim() && _bloc.listOrder[i].gifProduct != true) {
        if (shouldApply) {
          // ADD discount
          if (!ckvtExists) {
            DataLocal.listCKVT = DataLocal.listCKVT.isEmpty ? discountKey : '${DataLocal.listCKVT},$discountKey';
            ckvtExists = true;
          }
          if (!promoExists) {
            _bloc.listPromotion = _bloc.listPromotion.isEmpty ? sttRecCk : '${_bloc.listPromotion},$sttRecCk';
            promoExists = true;
          }
          
          final product = _bloc.listOrder[i];
          double originalPrice = product.giaSuaDoi ?? 0;
          if (originalPrice == 0) originalPrice = product.price ?? 0;
          if (originalPrice == 0 && ckgItem.giaGoc != null && ckgItem.giaGoc! > 0) {
            originalPrice = ckgItem.giaGoc!.toDouble();
          }
          
          if (originalPrice == 0) continue;
          
          // Calculate discount
          final tlCk = (ckgItem.tlCk ?? 0).toDouble();
          final ckValue = (ckgItem.ck ?? 0).toDouble();
          final ckNtValue = (ckgItem.ckNt ?? 0).toDouble();
          final giaSauCk = (ckgItem.giaSauCk ?? 0).toDouble();
          final giaGoc = (ckgItem.giaGoc ?? originalPrice).toDouble();
          double priceAfter = originalPrice;
          double discountPercent = 0;

          if (tlCk > 0) {
            discountPercent = tlCk;
            priceAfter = originalPrice - (originalPrice * discountPercent / 100);
          } else if (giaSauCk > 0 && giaSauCk != giaGoc && giaGoc > 0) {
            priceAfter = giaSauCk;
            discountPercent = originalPrice > 0 ? ((originalPrice - priceAfter) / originalPrice) * 100 : 0;
          } else if (ckValue > 0) {
            double ckPerItem = ckValue;
            if (ckValue > giaGoc && giaGoc > 0) {
              double totalQuantity = 0;
              for (var item in _bloc.listOrder) {
                if ((item.code ?? '').trim() == productCode.trim() && item.gifProduct != true) {
                  totalQuantity += (item.count ?? 0);
                }
              }
              if (totalQuantity > 0) {
                ckPerItem = ckValue / totalQuantity;
              }
            }
            if (ckPerItem <= originalPrice && originalPrice > 0) {
              priceAfter = originalPrice - ckPerItem;
              discountPercent = (ckPerItem / originalPrice) * 100;
            } else if (ckPerItem > originalPrice && originalPrice > 0) {
              priceAfter = 0;
              discountPercent = 100;
            }
          }
          
          if (priceAfter < 0) priceAfter = 0;

          product.giaSuaDoi = originalPrice;
          product.price = originalPrice;
          product.priceAfter = priceAfter;
          product.priceAfter2 = priceAfter;
          product.discountPercent = discountPercent;
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
          
          hasChanges = true;
        } else {
          // REMOVE discount
          if (ckvtExists) {
            ckvtList.removeWhere((item) => item.trim() == discountKey);
            DataLocal.listCKVT = ckvtList.join(',');
            ckvtExists = false;
            
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
          }
          
          if ((_bloc.listOrder[i].sttRecCK == sttRecCk || 
              (_bloc.listOrder[i].typeCK == 'CKG' && _bloc.listOrder[i].code == productCode))) {
            double originalPrice = _bloc.listOrder[i].giaSuaDoi ?? 0;
            if (originalPrice == 0) originalPrice = _bloc.listOrder[i].price ?? 0;
            
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
            _bloc.listOrder[i].giaSuaDoi = originalPrice;
            _bloc.listOrder[i].price = originalPrice;
            _bloc.listOrder[i].priceAfter = originalPrice;
            _bloc.listOrder[i].priceAfter2 = originalPrice;
            
            hasChanges = true;
          }
        }
      }
    }
    
    if (hasChanges) {
      _recalculateTotalLocal();
      setState(() {});
    }
  }

  // Apply or remove a single CKTDTT discount
  void _applySingleCKTDTT(String cktdttId, ListCkTongDon cktdttItem, {required bool shouldApply}) {
    String sttRecCk = (cktdttItem.sttRecCk ?? '').trim();
    
    List<String> promoList = _bloc.listPromotion.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    bool promoExists = promoList.contains(sttRecCk);
    
    List<String> ckvtList = DataLocal.listCKVT.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    bool ckvtExists = ckvtList.contains(sttRecCk);
    
    if (shouldApply) {
      if (!promoExists) {
        double currentDiscount = _bloc.totalDiscountForOder ?? 0;
        double newDiscount = cktdttItem.tCkTtNt ?? 0;
        _bloc.totalDiscountForOder = (currentDiscount + newDiscount);
      }
      
      if (!promoExists) {
        _bloc.listPromotion = _bloc.listPromotion.isEmpty ? sttRecCk : '${_bloc.listPromotion},$sttRecCk';
      }
      if (!ckvtExists) {
        DataLocal.listCKVT = DataLocal.listCKVT.isEmpty ? sttRecCk : '${DataLocal.listCKVT},$sttRecCk';
      }
      
      if (_bloc.codeDiscountTD.isEmpty) {
        _bloc.codeDiscountTD = cktdttItem.maCk?.toString().trim() ?? '';
      }
      if (_bloc.sttRecCKOld.isEmpty) {
        _bloc.sttRecCKOld = sttRecCk;
      }
    } else {
      if (promoExists) {
        promoList.removeWhere((item) => item.trim() == sttRecCk);
        _bloc.listPromotion = promoList.join(',');
      }
      if (ckvtExists) {
        ckvtList.removeWhere((item) => item.trim() == sttRecCk);
        DataLocal.listCKVT = ckvtList.join(',');
      }
      
      // Recalculate totalDiscountForOder
      double totalDiscount = 0;
      for (var item in _bloc.listCktdtt) {
        String itemSttRecCk = (item.sttRecCk ?? '').trim();
        if (itemSttRecCk.isNotEmpty && _bloc.selectedCktdttIds.contains(itemSttRecCk)) {
          totalDiscount += (item.tCkTtNt ?? 0);
        }
      }
      _bloc.totalDiscountForOder = totalDiscount;
      
      if (_bloc.selectedCktdttIds.isEmpty) {
        _bloc.codeDiscountTD = '';
        _bloc.sttRecCKOld = '';
        _bloc.totalDiscountForOder = 0;
      }
    }
    
    _recalculateTotalLocal();
    setState(() {});
  }

  // Handle HH selection (when user clicks checkbox - apply immediately)
  void _handleHHSelection(String hhId, ListCk hhItem) {
    print('💰 ========== HH SELECTION START ==========');
    print('💰 HH: User selecting gift for hhId=$hhId');
    print('💰 HH Item: sttRecCk=${hhItem.sttRecCk}, maVt=${hhItem.maVt}, tenVt=${hhItem.tenVt}');
    
    // Update BLoC state
    _bloc.selectedHHIds.add(hhId);
    print('💰 Updated selectedHHIds: ${_bloc.selectedHHIds}');
    
    // Apply HH gift immediately
    Set<String> selectedIds = {hhId};
    _applyAllHH(selectedIds);
    
    print('💰 ========== HH SELECTION END ==========');
  }

  // Handle HH removal (when user unchecks checkbox - remove immediately and reload API)
  void _handleRemoveHH(String hhId, ListCk hhItem) {
    print('💰 ========== HH REMOVAL START ==========');
    print('💰 HH: User removing gift for hhId=$hhId');
    
    // Update BLoC state
    _bloc.selectedHHIds.remove(hhId);
    print('💰 Updated selectedHHIds: ${_bloc.selectedHHIds}');
    
    // Remove HH gift immediately
    int removedCount = 0;
    DataLocal.listProductGift.removeWhere((item) {
      if (item.typeCK == 'HH') {
        // ✅ Match bằng sttRec0 (sttRecCk) và code (maVt)
        String itemSttRecCk = (item.sttRec0 ?? '').trim();
        String itemCode = (item.code ?? '').trim();
        String hhSttRecCk = (hhItem.sttRecCk ?? '').trim();
        String hhMaVt = (hhItem.maVt ?? '').trim();
        
        if (itemSttRecCk == hhSttRecCk && itemCode == hhMaVt) {
          _bloc.totalProductGift -= item.count ?? 0;
          removedCount++;
          print('💰 Removed HH gift: ${item.code} x${item.count}');
          return true;
        }
      }
      return false;
    });
    
    // ✅ Remove from listPromotion
    String sttRecCk = (hhItem.sttRecCk ?? '').trim();
    if (sttRecCk.isNotEmpty) {
      List<String> promoList = _bloc.listPromotion.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      promoList.removeWhere((item) => item.trim() == sttRecCk);
      _bloc.listPromotion = promoList.join(',');
    }
    
    print('💰 Removed $removedCount HH gifts');
    print('💰 Updated listPromotion: ${_bloc.listPromotion}');
    
    // ✅ CRITICAL: Gọi API reload để sync với backend khi bỏ chọn HH
    // Vì HH có thể ảnh hưởng đến chiết khấu khác
    if (removedCount > 0) {
      print('💰 Calling API reload after removing HH gifts');
      _reloadDiscountsFromBackend();
    }
    
    setState(() {});
    print('💰 ========== HH REMOVAL END ==========');
  }
}
