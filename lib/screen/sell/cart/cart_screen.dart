import 'dart:async';
import 'dart:convert';
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
import 'package:get_storage/get_storage.dart';
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
import 'widgets/cart_app_bar.dart';
import 'widgets/cart_bottom_total.dart';
import 'widgets/cart_product_list.dart';
import 'widgets/cart_customer_info.dart';
import 'widgets/cart_bill_info.dart';
import 'widgets/cart_gift_item.dart';
import 'widgets/cart_product_item.dart';
import 'widgets/cart_order_handler.dart';
import 'widgets/cart_popup_vvhd.dart';
import 'widgets/cart_helper_widgets.dart';
import 'widgets/cart_method_receive.dart';
import 'widgets/cart_invoice_widgets.dart';
import 'widgets/tabs/cart_product_tab.dart';
import 'widgets/tabs/cart_customer_tab.dart';
import 'widgets/tabs/cart_bill_tab.dart';
import 'helpers/cart_discount_helper.dart';
import 'helpers/cart_draft_storage.dart';

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
  final bool? isCopyOrder; // ✅ Flag để biết đang copy đơn hàng (cần clear discount)

  const CartScreen({Key? key,this.sttRec,this.addInfoCheckIn,this.viewUpdateOrder,this.listOrder,this.currencyCode,this.viewDetail,this.nameCustomer,this.idCustomer,
    this.phoneCustomer,this.addressCustomer,this.nameStore,this.codeStore,this.codeCustomer,this.itemGroupCode,this.listIdGroupProduct, this.dateOrder,
    required this.orderFromCheckIn, required this.title, this.description, required this.loadDataLocal, this.sttRectHD, this.isContractCreateOrder = false,this.contractMaster, this.isCopyOrder}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin{
  // ✅ Flag để đánh dấu đã restore CK tổng đơn (chỉ restore một lần khi vào sửa đơn)
  bool _hasRestoredManualTotalDiscount = false;
  late CartBloc _bloc;
  late TabController tabController;
  final _giftStorage = GetStorage();
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
  
  // ✅ Lưu state ban đầu của discount khi mở bottom sheet (để detect thay đổi khi nhấn "Áp dụng")
  Set<String>? _initialSelectedCkgIds;
  Set<String>? _initialSelectedCktdttIds;
  Set<String>? _initialSelectedHHIds;
  String? _initialListCKVT;
  String? _initialListPromotion;
  double? _pendingMaxQuantity;
  List<ListCkMatHang>? _pendingDiscountItems;
  String? _pendingDiscountType; // 'CKN' or 'CKTDTH'
  String? _pendingCknGroupKey;
  String? _pendingCktdthGroupKey;
  GlobalKey<DiscountVoucherSelectionSheetState>? _discountSheetKey;
  
  // Flag to re-apply HH after API reload (từ CKG check/uncheck)
  bool _needReapplyHHAfterReload = false;
  
  // Loading dialog state
  bool _isLoadingGiftProducts = false;
  
  // ✅ Lưu discount từ lineItem để validate sau khi API trả về (EDIT MODE)
  List<String> _lineItemDiscounts = [];
  List<String> _lineItemPromotions = [];

  void _persistGiftProducts() {
    try{
      final manualGifts = DataLocal.listProductGift.where((e)=> e.gifProductByHand == true).toList();
      _giftStorage.write('listProductGift', jsonEncode(manualGifts.map((e)=>e.toJson()).toList()));
    }catch(_){
      // ignore write error
    }
  }
  
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
      // ❗️KHÔNG được clear listOrder ở đây
      // Trước đây, dòng này khiến luồng 1 (tạo đơn mới từ OrderScreen) bị mất toàn bộ sản phẩm
      // ngay sau khi GetListProductFromDBSuccess sync dữ liệu DB → listOrder:
      //   - DB fetch ra 2 sản phẩm
      //   - GetListProductFromDBSuccess sync 2 sản phẩm vào _bloc.listOrder
      //   - getDiscountProduct('') được gọi và _bloc.listOrder.clear() → UI thấy listOrder rỗng
      //
      // Hiện tại logic chỉ cần clear listPromotion + DataLocal.listCKVT (thông tin chiết khấu),
      // không cần – và không nên – xóa danh sách sản phẩm.
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
      // ✅ Đảm bảo customerId không rỗng/null
      // Ưu tiên: widget.codeCustomer > DataLocal.infoCustomer.customerCode > _bloc.codeCustomer
      final finalCustomerId = (widget.codeCustomer != null &&
              widget.codeCustomer.toString().trim().isNotEmpty &&
              widget.codeCustomer.toString().trim() != 'null')
          ? widget.codeCustomer.toString().trim()
          : ((DataLocal.infoCustomer.customerCode.toString().trim().isNotEmpty &&
                  DataLocal.infoCustomer.customerCode.toString().trim() != 'null')
              ? DataLocal.infoCustomer.customerCode.toString().trim()
              : (_bloc.codeCustomer?.toString().trim() ?? ''));

      // ✅ Đảm bảo warehouseId không rỗng
      // Ưu tiên: _bloc.storeCode > codeStore > Const.stockList[0].stockCode
      final finalWarehouseId = (!Utils.isEmpty(_bloc.storeCode.toString()) && _bloc.storeCode.toString().trim().isNotEmpty)
          ? _bloc.storeCode.toString()
          : ((!Utils.isEmpty(codeStore) && codeStore.trim().isNotEmpty)
              ? codeStore
              : (Const.stockList.isNotEmpty ? Const.stockList[0].stockCode.toString() : ''));
      
      if (finalWarehouseId.isEmpty) {
        print('⚠️ Warning: warehouseId is empty, API may fail!');
        print('   - _bloc.storeCode = ${_bloc.storeCode}');
        print('   - codeStore = $codeStore');
        print('   - Const.stockList.length = ${Const.stockList.length}');
      }
      
      print('💰 getDiscountProduct: warehouseId = $finalWarehouseId');

      if (finalCustomerId.isEmpty) {
        print('⚠️ Warning: customerId is empty/null, skip apply-discount-v2 to avoid wrong promotions!');
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
      // ✅ Xử lý khi tạo đơn mới hoặc sửa đơn (không phải từ check-in)
      // Khi sửa đơn (viewUpdateOrder: true):
      // - widget.listOrder chứa List<Product> từ AddProductToCartEvent (đã load vào database)
      // - Set listProductOrder từ widget.listOrder để có dữ liệu ban đầu
      // - Sau đó GetListProductFromDB sẽ load từ database (dữ liệu chính xác hơn)
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
      print('💾 Loading existing order: widget.listOrder.length=${widget.listOrder?.length ?? 0}');
      print('💾   - _bloc.listProductOrder.length=${_bloc.listProductOrder.length}');
      print('💾   - _bloc.listOrder.length=${_bloc.listOrder.length} (before GetListProductFromDB)');
      
      if(Const.stockList.isNotEmpty){
        _bloc.storeCode = Const.stockList[_bloc.storeIndex].stockCode;
      }
      _bloc.add(GetListProductFromDB(addOrderFromCheckIn: widget.orderFromCheckIn, getValuesTax: false,key: ''));
    }
    if(widget.viewUpdateOrder == true){
      // ✅ Setup mode sửa đơn: Khôi phục các thông tin từ DataLocal
      // (đã được set trong GetListItemUpdateOrderEvent từ history_order_detail_screen)
      print('💾 Setting up edit order mode...');
      print('💾   - sttRec = ${widget.sttRec}');
      print('💾   - listOrder.length = ${widget.listOrder?.length ?? 0}');
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

  /// Khởi tạo draft storage: restore draft khi quay lại tạo mới
  /// Khi vào sửa đơn, KHÔNG làm gì với draft (draft đã được lưu khi back ra)
  Future<void> _initDraftStorage() async {
    print('💾 _initDraftStorage called: viewUpdateOrder=${widget.viewUpdateOrder}, sttRec=${widget.sttRec}');
    print('💾 Current state: listOrder.length=${_bloc.listOrder.length}, listProductGift.length=${DataLocal.listProductGift.length}');
    
    // ✅ Chỉ restore draft khi quay lại tạo mới (KHÔNG vào sửa đơn)
    if (widget.viewUpdateOrder != true) {
      final isNewOrder = widget.sttRec == null || widget.sttRec!.trim().isEmpty;
      print('💾 isNewOrder=$isNewOrder, listOrder.isEmpty=${_bloc.listOrder.isEmpty}, listProductGift.isEmpty=${DataLocal.listProductGift.isEmpty}');
      
      if (isNewOrder && _bloc.listOrder.isEmpty && DataLocal.listProductGift.isEmpty) {
        print('💾 Attempting to restore draft...');
        // ✅ QUAN TRỌNG: Trong mode add, clear discounts khi restore draft
        final restored = await CartDraftStorage.restoreDraft(_bloc, clearDiscounts: true);
        if (restored) {
          print('💾 ✅ Draft restored successfully! (with discounts cleared)');
          print('💾 After restore:');
          print('💾   - bloc.listOrder.length = ${_bloc.listOrder.length}');
          print('💾   - DataLocal.listProductGift.length = ${DataLocal.listProductGift.length}');
          print('💾   - bloc.totalMoney = ${_bloc.totalMoney}');
          print('💾   - bloc.totalPayment = ${_bloc.totalPayment}');
          print('💾   - bloc.totalDiscount = ${_bloc.totalDiscount}');
          print('💾   - bloc.manualTotalDiscountPercent = ${_bloc.manualTotalDiscountPercent}%');
          print('💾   - bloc.customerName = ${_bloc.customerName}');
          print('💾   - bloc.codeCustomer = ${_bloc.codeCustomer}');
          print('💾   - DataLocal.listCKVT = ${DataLocal.listCKVT}');
          print('💾   - bloc.listPromotion = ${_bloc.listPromotion}');
          
          // Print chi tiết từng sản phẩm
          for (int i = 0; i < _bloc.listOrder.length; i++) {
            final item = _bloc.listOrder[i];
            print('💾   Product[$i]: code=${item.code}, name=${item.name}, count=${item.count}, price=${item.price}, priceAfter=${item.priceAfter}, discountPercent=${item.discountPercent}, maCk=${item.maCk}');
          }
          
          // Print chi tiết từng sản phẩm tặng
          for (int i = 0; i < DataLocal.listProductGift.length; i++) {
            final gift = DataLocal.listProductGift[i];
            print('💾   Gift[$i]: code=${gift.code}, name=${gift.name}, count=${gift.count}');
          }
          
          // ✅ QUAN TRỌNG: Nếu không có sản phẩm chính, clear hết sản phẩm tặng
          // Sản phẩm tặng chỉ nên hiển thị khi có sản phẩm chính trong giỏ hàng
          if (_bloc.listOrder.isEmpty) {
            print('💰 [ADD MODE] Clearing all gift products because listOrder is empty');
            DataLocal.listProductGift.clear();
            _bloc.totalProductGift = 0;
            print('💰   - After clear: listProductGift.length = ${DataLocal.listProductGift.length}');
          } else {
            // ✅ QUAN TRỌNG: Clear hết sản phẩm tặng từ chương trình chiết khấu (không clear hàng tặng thủ công)
            print('💰 [ADD MODE] Clearing gift products from discount programs...');
            DataLocal.listProductGift.removeWhere((gift) => 
              gift.gifProduct == true && 
              gift.gifProductByHand != true
            );
            print('💰   - After clear: listProductGift.length = ${DataLocal.listProductGift.length}');
          }
          
          // ✅ QUAN TRỌNG: Trigger tính toán lại chiết khấu và tổng tiền sau khi restore
          // Đảm bảo chiết khấu tổng đơn bằng tay (manualTotalDiscountPercent) được tính lại đúng
          if (_bloc.listOrder.isNotEmpty) {
            print('💰 Triggering recalculation after restore draft...');
            print('💰 manualTotalDiscountPercent before calculation: ${_bloc.manualTotalDiscountPercent}%');
            _bloc.add(CalculatorDiscountEvent(
              addOnProduct: false,
              reLoad: true,
              addTax: false,
            ));
          } else {
            // ✅ Nếu không có sản phẩm, vẫn refresh UI để hiển thị manualTotalDiscountPercent = 0
            if (mounted) {
              setState(() {});
            }
          }
        } else {
          print('💾 ❌ No draft to restore or restore failed');
          // ✅ QUAN TRỌNG: Chỉ clear thông tin khách hàng nếu KHÔNG có widget.codeCustomer
          // Nếu có widget.codeCustomer (đi từ DetailCustomerScreen), giữ lại thông tin đó
          if (widget.codeCustomer == null || 
              widget.codeCustomer.toString().trim().replaceAll('null', '').isEmpty) {
            print('💾 🧹 Clearing all customer info because no draft exists and no widget.codeCustomer');
            _bloc.customerName = null;
            _bloc.codeCustomer = null;
            _bloc.phoneCustomer = null;
            _bloc.addressCustomer = null;
            DataLocal.infoCustomer = ManagerCustomerResponseData();
            nameCustomerController.clear();
            phoneCustomerController.clear();
            addressCustomerController.clear();
            print('💾 ✅ Customer info cleared');
          } else {
            print('💾 ✅ Keeping customer info from widget (codeCustomer=${widget.codeCustomer})');
            // Đảm bảo DataLocal.infoCustomer cũng được set để widget có thể đọc
            if (DataLocal.infoCustomer.customerCode.toString().isEmpty || 
                DataLocal.infoCustomer.customerCode.toString() == 'null') {
              DataLocal.infoCustomer.customerCode = widget.codeCustomer;
              DataLocal.infoCustomer.customerName = widget.nameCustomer ?? '';
              DataLocal.infoCustomer.phone = widget.phoneCustomer ?? '';
              DataLocal.infoCustomer.address = widget.addressCustomer ?? '';
              print('💾 ✅ DataLocal.infoCustomer updated from widget');
            }
          }
        }
      } else {
        print('💾 Skip restore: isNewOrder=$isNewOrder, listOrder.isEmpty=${_bloc.listOrder.isEmpty}, listProductGift.isEmpty=${DataLocal.listProductGift.isEmpty}');
        // ✅ QUAN TRỌNG: Chỉ clear thông tin khách hàng nếu KHÔNG có widget.codeCustomer
        // Nếu có widget.codeCustomer (đi từ DetailCustomerScreen), giữ lại thông tin đó
        if (isNewOrder && _bloc.listOrder.isEmpty && DataLocal.listProductGift.isEmpty) {
          if (widget.codeCustomer == null || 
              widget.codeCustomer.toString().trim().replaceAll('null', '').isEmpty) {
            print('💾 🧹 Clearing all customer info because creating new order with no products and no widget.codeCustomer');
            _bloc.customerName = null;
            _bloc.codeCustomer = null;
            _bloc.phoneCustomer = null;
            _bloc.addressCustomer = null;
            DataLocal.infoCustomer = ManagerCustomerResponseData();
            nameCustomerController.clear();
            phoneCustomerController.clear();
            addressCustomerController.clear();
            print('💾 ✅ Customer info cleared');
          } else {
            print('💾 ✅ Keeping customer info from widget (codeCustomer=${widget.codeCustomer})');
            // Đảm bảo DataLocal.infoCustomer cũng được set để widget có thể đọc
            if (DataLocal.infoCustomer.customerCode.toString().isEmpty || 
                DataLocal.infoCustomer.customerCode.toString() == 'null') {
              DataLocal.infoCustomer.customerCode = widget.codeCustomer;
              DataLocal.infoCustomer.customerName = widget.nameCustomer ?? '';
              DataLocal.infoCustomer.phone = widget.phoneCustomer ?? '';
              DataLocal.infoCustomer.address = widget.addressCustomer ?? '';
              print('💾 ✅ DataLocal.infoCustomer updated from widget');
            }
          }
        }
      }
    } else {
      print('💾 Skip restore: viewUpdateOrder=true (editing order)');
    }
    // ✅ Khi vào sửa đơn, KHÔNG làm gì - draft đã được lưu khi back ra, không cần save lại
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
      print('💾 ========== ENTERING EDIT ORDER MODE ==========');
      print('💾 viewUpdateOrder=true, sttRec=${widget.sttRec}');
      print('💾 widget.listOrder.length=${widget.listOrder?.length ?? 0}');
      print('💾 Current draft state BEFORE loading order:');
      print('💾   - _bloc.listOrder.length=${_bloc.listOrder.length}');
      print('💾   - DataLocal.listProductGift.length=${DataLocal.listProductGift.length}');
      print('💾   - DataLocal.editOrderTotalMoney=${DataLocal.editOrderTotalMoney}');
      print('💾   - DataLocal.editOrderTotalDiscount=${DataLocal.editOrderTotalDiscount}');
      print('💾   - DataLocal.editOrderTotalPayment=${DataLocal.editOrderTotalPayment}');
      print('💾   - DataLocal.editOrderTotalTax=${DataLocal.editOrderTotalTax}');

      // ✅ Khởi tạo lại manualTotalDiscountPercent từ DataLocal (nếu có) khi SỬA ĐƠN
      if (Const.freeDiscount == true && DataLocal.editOrderManualTotalDiscountPercent > 0) {
        _bloc.manualTotalDiscountPercent = DataLocal.editOrderManualTotalDiscountPercent;
        print('💰 [EDIT MODE - FreeDiscount] Init manualTotalDiscountPercent from DataLocal: ${_bloc.manualTotalDiscountPercent}%');
      } else {
        _bloc.manualTotalDiscountPercent = 0;
      }
      
      // ✅ Flag để đánh dấu đã restore CK tổng đơn (chỉ restore một lần khi vào sửa đơn)
      _hasRestoredManualTotalDiscount = false;
      
      // ✅ Kiểm tra draft hiện tại trong database
      CartDraftStorage.checkDraftExists().then((exists) {
        if (exists) {
          print('💾 ⚠️ Draft exists in database (will NOT be affected by edit order)');
          CartDraftStorage.getDraftInfo().then((info) {
            print('💾 Draft info: $info');
          });
        } else {
          print('💾 No draft in database');
        }
      });
      
      _bloc.showWarning = false;
    }
    _bloc.allowed = true;
    
    // ✅ Restore draft TRƯỚC KHI gọi GetPrefs() (chỉ khi tạo đơn mới)
    // Khi vào sửa đơn, KHÔNG làm gì với draft (draft đã được lưu khi back ra)
    _initDraftStorage().then((_) {
      // Sau khi restore draft xong, mới gọi GetPrefs()
      _bloc.add(GetPrefs());
    });
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
    if(widget.codeCustomer != null && widget.codeCustomer.toString().trim().replaceAll('null', '').isNotEmpty){
      nameCustomerController.text = widget.nameCustomer.toString();
      phoneCustomerController.text = widget.phoneCustomer?.toString() ?? '';
      addressCustomerController.text = widget.addressCustomer?.toString() ?? '';
      // QUAN TRỌNG: Notify listeners để ValueListenableBuilder rebuild ngay
      nameCustomerController.notifyListeners();
      phoneCustomerController.notifyListeners();
      addressCustomerController.notifyListeners();
      _bloc.customerName = widget.nameCustomer;
      _bloc.codeCustomer = widget.codeCustomer;
      _bloc.addressCustomer = widget.addressCustomer;
      _bloc.phoneCustomer = widget.phoneCustomer;
      // QUAN TRỌNG: Cũng set vào DataLocal.infoCustomer để widget có thể đọc được
      DataLocal.infoCustomer.customerCode = widget.codeCustomer;
      DataLocal.infoCustomer.customerName = widget.nameCustomer ?? '';
      DataLocal.infoCustomer.phone = widget.phoneCustomer ?? '';
      DataLocal.infoCustomer.address = widget.addressCustomer ?? '';
    } else {
    }
    if(Const.isDefaultCongNo && Const.chooseTypePayment){
      _bloc.showDatePayment = true;
      DataLocal.valuesTypePayment = "Công nợ";
      _bloc.add(PickTypePayment(DataLocal.typePaymentList.indexOf("Công nợ"),  DataLocal.valuesTypePayment));
    }
  }

  @override
  @override
  void dispose() {
    // ✅ Lưu draft khi user back ra khỏi màn hình tạo đơn mới (nếu có dữ liệu)
    // Lưu ý: Không show dialog trong dispose vì context đã không còn available
    if (widget.viewUpdateOrder != true) {
      final isNewOrder = widget.sttRec == null || widget.sttRec!.trim().isEmpty;
      if (isNewOrder) {
        if (_bloc.listOrder.isNotEmpty || DataLocal.listProductGift.isNotEmpty) {
          // Lưu draft bất đồng bộ (không await để không block dispose)
          CartDraftStorage.saveDraft(_bloc).then((_) {
            print('💾 Draft auto-saved on dispose (user back from new order)');
          }).catchError((e) {
            print('💾 Error auto-saving draft on dispose: $e');
          });
        } else {
          // ✅ QUAN TRỌNG: Nếu không có sản phẩm, xóa draft
          CartDraftStorage.clearDraft().then((_) {
            print('💾 Draft cleared on dispose (no products)');
          }).catchError((e) {
            print('💾 Error clearing draft on dispose: $e');
          });
        }
      }
    }
    
    _timer.cancel();
    tabController.dispose();
    super.dispose();
  }

  // ✅ Flag để đánh dấu đã đặt đơn thành công (ngăn không cho save draft sau đó)
  bool _orderCreatedSuccessfully = false;
  
  /// Lưu draft tự động (không show dialog) - gọi khi có thay đổi
  Future<void> _autoSaveDraft() async {
    // ✅ QUAN TRỌNG: Không lưu draft nếu đã đặt đơn thành công
    if (_orderCreatedSuccessfully) {
      print('💾 ⚠️ Skip auto-save draft: Order already created successfully');
      return;
    }
    
    // Chỉ lưu khi đang tạo đơn mới
    if (widget.viewUpdateOrder == true) {
      return; // Không lưu khi sửa đơn
    }
    
    final isNewOrder = widget.sttRec == null || widget.sttRec!.trim().isEmpty;
    if (!isNewOrder) {
      return; // Không lưu khi không phải đơn mới
    }
    
    // Chỉ lưu nếu có dữ liệu
    if (_bloc.listOrder.isEmpty && DataLocal.listProductGift.isEmpty) {
      return;
    }
    
    try {
      await CartDraftStorage.saveDraft(_bloc);
      print('💾 Draft auto-saved after change');
    } catch (e) {
      print('💾 Error auto-saving draft: $e');
    }
  }

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
    _persistGiftProducts();
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

  /// Lưu draft với dialog loading và thông báo thành công
  Future<void> _saveDraftWithDialog() async {
    print('💾 _saveDraftWithDialog called: viewUpdateOrder=${widget.viewUpdateOrder}, listOrder.length=${_bloc.listOrder.length}, listProductGift.length=${DataLocal.listProductGift.length}');
    
    // ✅ QUAN TRỌNG: Không lưu draft nếu đã đặt đơn thành công
    if (_orderCreatedSuccessfully) {
      print('💾 ⚠️ Skip save draft: Order already created successfully');
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    
    // Kiểm tra điều kiện
    if (widget.viewUpdateOrder == true) {
      print('💾 ✅ Đang sửa đơn, KHÔNG save draft (draft không bị ảnh hưởng)');
      print('💾   - Draft vẫn còn trong database');
      print('💾   - Cho phép pop ngay');
      // Nếu đang sửa đơn, cho phép pop ngay (KHÔNG save draft)
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    
    final isNewOrder = widget.sttRec == null || widget.sttRec!.trim().isEmpty;
    if (!isNewOrder) {
      print('💾 Không phải đơn mới, cho phép pop ngay');
      // Nếu không phải đơn mới, cho phép pop ngay
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    
    if (_bloc.listOrder.isEmpty && DataLocal.listProductGift.isEmpty) {
      print('💾 Không có dữ liệu để lưu, xóa draft và cho phép pop ngay');
      // ✅ QUAN TRỌNG: Nếu không có sản phẩm, xóa draft thay vì lưu
      CartDraftStorage.clearDraft();
      print('💾 ✅ Draft đã được xóa vì không có sản phẩm');
      // Cho phép pop ngay
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    
    print('💾 Có dữ liệu để lưu, sẽ show dialog');
    
    // Kiểm tra mounted trước khi show dialog
    if (!mounted) {
      // Nếu không mounted, vẫn lưu draft nhưng không show dialog
      try {
        await CartDraftStorage.saveDraft(_bloc);
        print('💾 Draft saved silently (context not available)');
      } catch (e) {
        print('💾 Error saving draft: $e');
      }
      return;
    }
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Đang lưu đơn hàng tạm...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    try {
      // Lưu draft
      await CartDraftStorage.saveDraft(_bloc);
      
      // Đóng loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();
      
      // ✅ Bỏ dialog thông báo thành công, pop màn hình luôn
      if (mounted) {
        Navigator.of(context).pop(widget.currencyCode);
      }
      
      print('💾 Draft saved successfully (no success dialog)');
    } catch (e) {
      // Đóng loading dialog nếu có lỗi và vẫn cho phép pop
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Đóng loading dialog
        }
        // Vẫn cho phép pop màn hình dù có lỗi (với giá trị trả về)
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(widget.currencyCode);
        }
      }
      print('💾 Error saving draft: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc,CartState>(
      listener: (context,state){
        if(state is GetPrefsSuccess){
          print('💾 GetPrefsSuccess triggered');
          print('💾 Current state: listOrder.length=${_bloc.listOrder.length}, listProductGift.length=${DataLocal.listProductGift.length}');
          
          // ✅ Ưu tiên restore từ preservedListOrderFromDraft (từ AddProductToCartEvent) TRƯỚC KHI preserve
          final isNewOrder = widget.sttRec == null || widget.sttRec!.trim().isEmpty;
          if (isNewOrder && (widget.listOrder == null || widget.listOrder!.isEmpty)) {
            if (_bloc.preservedListOrderFromDraft != null && _bloc.preservedListOrderFromDraft!.isNotEmpty) {
              print('💾 Found preservedListOrderFromDraft in GetPrefsSuccess (from AddProductToCartEvent):');
              print('💾   - preservedListOrderFromDraft.length = ${_bloc.preservedListOrderFromDraft!.length}');
              
              if (_bloc.listOrder.isEmpty) {
                _bloc.listOrder.clear();
                _bloc.listOrder.addAll(_bloc.preservedListOrderFromDraft!);
                print('💾 ✅ Restored listOrder from preservedListOrderFromDraft in GetPrefsSuccess - listOrder.length=${_bloc.listOrder.length}');
                // Clear biến tạm sau khi restore
                _bloc.preservedListOrderFromDraft = null;
                if (mounted) {
                  setState(() {});
                }
              } else {
                print('💾 listOrder not empty, skip restore from preservedListOrderFromDraft');
                _bloc.preservedListOrderFromDraft = null; // Clear biến tạm
              }
            }
          }
          
          // ✅ Preserve listOrder đã restore từ draft trước khi gọi calculationDiscount
          // Vì calculationDiscount có thể gọi GetListProductFromDB với widget.listOrder (có thể null/empty)
          final preservedListOrder = isNewOrder ? List<SearchItemResponseData>.from(_bloc.listOrder) : null;
          
          print('💾 isNewOrder=$isNewOrder, preservedListOrder.length=${preservedListOrder?.length ?? 0}');
          
          if((Const.isVvHd == true || Const.isVv == true || Const.isHd == true)){ // && (DataLocal.listVv.isEmpty || DataLocal.listHd.isEmpty)
            print('💾 Calling GetListVVHD()');
            _bloc.add(GetListVVHD());
          }
          else{
            print('💾 Calling calculationDiscount()');
            calculationDiscount();
          }
          
          // ✅ Restore lại listOrder từ draft nếu bị mất (sau calculationDiscount)
          if (isNewOrder && preservedListOrder != null && preservedListOrder.isNotEmpty) {
            // Delay một chút để đảm bảo calculationDiscount đã chạy xong
            Future.microtask(() {
              print('💾 Checking if listOrder was lost after calculationDiscount...');
              print('💾   - _bloc.listOrder.length = ${_bloc.listOrder.length}');
              print('💾   - widget.listOrder = ${widget.listOrder?.length ?? 0}');
              if (mounted && _bloc.listOrder.isEmpty && (widget.listOrder == null || widget.listOrder!.isEmpty)) {
                _bloc.listOrder.clear();
                _bloc.listOrder.addAll(preservedListOrder);
                print('💾 ✅ Restored listOrder from draft after calculationDiscount - listOrder.length=${_bloc.listOrder.length}');
                setState(() {});
              } else {
                print('💾 No need to restore: listOrder not empty or widget.listOrder exists');
              }
            });
          }
          
          // ✅ Ưu tiên sử dụng widget.codeCustomer (từ DetailCustomerScreen) nếu có
          // Nếu không có, mới dùng DataLocal.infoCustomer hoặc _bloc.codeCustomer
          // ✅ QUAN TRỌNG: Nếu đang tạo đơn mới và không có đơn hàng và không có sản phẩm trong giỏ,
          // thì KHÔNG lấy thông tin khách hàng từ DataLocal.infoCustomer (thông tin cũ)
          final shouldUseOldCustomerInfo = !(isNewOrder && 
                                              widget.viewUpdateOrder != true && 
                                              _bloc.listOrder.isEmpty && 
                                              DataLocal.listProductGift.isEmpty);
          
          final finalCodeCustomer = (widget.codeCustomer != null &&
                                      widget.codeCustomer.toString().trim().isNotEmpty &&
                                      widget.codeCustomer.toString().trim() != 'null')
              ? widget.codeCustomer
              : (shouldUseOldCustomerInfo &&
                  DataLocal.infoCustomer.customerCode.toString().isNotEmpty &&
                  DataLocal.infoCustomer.customerCode.toString() != 'null')
                  ? DataLocal.infoCustomer.customerCode
                  : _bloc.codeCustomer;
          
          final finalCustomerName = (widget.nameCustomer != null &&
                                      widget.nameCustomer.toString().trim().isNotEmpty &&
                                      widget.nameCustomer.toString().trim() != 'null')
              ? widget.nameCustomer
              : (shouldUseOldCustomerInfo &&
                  DataLocal.infoCustomer.customerName.toString().isNotEmpty &&
                  DataLocal.infoCustomer.customerName.toString() != 'null')
                  ? DataLocal.infoCustomer.customerName
                  : _bloc.customerName;
          
          final finalPhone = (widget.phoneCustomer != null &&
                              widget.phoneCustomer.toString().trim().isNotEmpty &&
                              widget.phoneCustomer.toString().trim() != 'null')
              ? widget.phoneCustomer
              : (shouldUseOldCustomerInfo &&
                  DataLocal.infoCustomer.phone.toString().isNotEmpty &&
                  DataLocal.infoCustomer.phone.toString() != 'null')
                  ? DataLocal.infoCustomer.phone
                  : _bloc.phoneCustomer;
          
          final finalAddress = (widget.addressCustomer != null &&
                                widget.addressCustomer.toString().trim().isNotEmpty &&
                                widget.addressCustomer.toString().trim() != 'null')
              ? widget.addressCustomer
              : (shouldUseOldCustomerInfo &&
                  DataLocal.infoCustomer.address.toString().isNotEmpty &&
                  DataLocal.infoCustomer.address.toString() != "null")
                  ? DataLocal.infoCustomer.address
                  : _bloc.addressCustomer;
          
          // ✅ Đồng bộ lại UI input (TextEditingController) với thông tin khách hàng cuối cùng
          // Tránh trường hợp Bloc đã có dữ liệu nhưng các ô nhập vẫn trống
          bool hasUpdatedController = false;
          if (finalCustomerName != null &&
              finalCustomerName.toString().trim().isNotEmpty &&
              finalCustomerName.toString().trim() != 'null') {
            final newName = finalCustomerName.toString().trim();
            if (nameCustomerController.text != newName) {
              nameCustomerController.text = newName;
              // ✅ Force notify listeners để ValueListenableBuilder rebuild ngay
              nameCustomerController.notifyListeners();
              hasUpdatedController = true;
            }
          }
          
          if (finalPhone != null &&
              finalPhone.toString().trim().isNotEmpty &&
              finalPhone.toString().trim() != 'null') {
            final newPhone = finalPhone.toString().trim();
            if (phoneCustomerController.text != newPhone) {
              phoneCustomerController.text = newPhone;
              // ✅ Force notify listeners để ValueListenableBuilder rebuild ngay
              phoneCustomerController.notifyListeners();
              hasUpdatedController = true;
            }
          }
          
          if (finalAddress != null &&
              finalAddress.toString().trim().isNotEmpty &&
              finalAddress.toString().trim() != 'null') {
            final newAddress = finalAddress.toString().trim();
            if (addressCustomerController.text != newAddress) {
              addressCustomerController.text = newAddress;
              // ✅ Force notify listeners để ValueListenableBuilder rebuild ngay
              addressCustomerController.notifyListeners();
              hasUpdatedController = true;
            }
          }
          
          // ✅ Đảm bảo DataLocal.infoCustomer cũng được cập nhật
          if (finalCodeCustomer != null && finalCodeCustomer.toString().trim().isNotEmpty) {
            DataLocal.infoCustomer.customerCode = finalCodeCustomer;
            DataLocal.infoCustomer.customerName = finalCustomerName ?? '';
            DataLocal.infoCustomer.phone = finalPhone ?? '';
            DataLocal.infoCustomer.address = finalAddress ?? '';
          }
          
          _bloc.add(PickInfoCustomer(
            customerName: finalCustomerName,
            phone: finalPhone,
            address: finalAddress,
            codeCustomer: finalCodeCustomer,
          ));
          
          // ✅ Rebuild UI nếu đã cập nhật controller
          if (hasUpdatedController && mounted) {
            setState(() {});
          }
        }
        else if(state is GetListVvHdSuccess){
          calculationDiscount();
        }
        else if(state is DeleteAllProductEventSuccess){
          _bloc.add(GetListProductFromDB(addOrderFromCheckIn: widget.orderFromCheckIn, getValuesTax: false,key: ''));
          // ✅ QUAN TRỌNG: Nếu xóa tất cả sản phẩm, xóa draft
          if (_bloc.listOrder.isEmpty && DataLocal.listProductGift.isEmpty) {
            print('💾 🧹 Xóa tất cả sản phẩm, xóa draft');
            CartDraftStorage.clearDraft();
            // Clear thông tin khách hàng
            _bloc.customerName = null;
            _bloc.codeCustomer = null;
            _bloc.phoneCustomer = null;
            _bloc.addressCustomer = null;
            DataLocal.infoCustomer = ManagerCustomerResponseData();
            nameCustomerController.clear();
            phoneCustomerController.clear();
            addressCustomerController.clear();
            print('💾 ✅ Draft và thông tin khách hàng đã được xóa');
          }
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
          print('💾 GetListProductFromDBSuccess triggered');
          print('💾 Current state: listOrder.length=${_bloc.listOrder.length}, listProductOrderAndUpdate.length=${_bloc.listProductOrderAndUpdate.length}');
          print('💾 DEBUG: viewUpdateOrder=${widget.viewUpdateOrder}, freeDiscount=${Const.freeDiscount}, lineItem.length=${_bloc.lineItem.length}');
          print('💾 DEBUG: infoPayment=${_bloc.infoPayment != null ? "exists" : "null"}, totalDiscountForOder=${_bloc.totalDiscountForOder}, totalMoney=${_bloc.totalMoney}');

          // ✅ FIX: Sync listProductOrderAndUpdate → listOrder để đảm bảo UI luôn khớp với DB
          // - Khi listOrder rỗng (lần đầu vào CartScreen từ Luồng 1)
          // - Khi key == 'Second' (sau khi xóa/thêm/sửa sản phẩm)
          // - Khi số lượng khác nhau (có thể bị lệch do thao tác khác)
          bool shouldSync = false;
          if (_bloc.listProductOrderAndUpdate.isNotEmpty && _bloc.listOrder.isEmpty) {
            // Case 1: listOrder rỗng → cần sync
            shouldSync = true;
            print('💾 ⚠️ listOrder is empty but listProductOrderAndUpdate has ${_bloc.listProductOrderAndUpdate.length} items');
          } else if (state.key == 'Second' && _bloc.listProductOrderAndUpdate.isNotEmpty) {
            // Case 2: Sau khi xóa/thêm/sửa (key='Second') → luôn sync để đảm bảo khớp với DB
            shouldSync = true;
            print('💾 🔄 key=Second: Syncing listProductOrderAndUpdate → listOrder after delete/add/update...');
          } else if (_bloc.listProductOrderAndUpdate.length != _bloc.listOrder.length && _bloc.listProductOrderAndUpdate.isNotEmpty) {
            // Case 3: Số lượng khác nhau → sync để đồng bộ
            shouldSync = true;
            print('💾 ⚠️ listOrder.length=${_bloc.listOrder.length} != listProductOrderAndUpdate.length=${_bloc.listProductOrderAndUpdate.length}, syncing...');
          }
          
          if (shouldSync) {
            print('💾 🔧 Syncing listProductOrderAndUpdate → listOrder...');
            
            // Clear listOrder cũ và rebuild từ listProductOrderAndUpdate
            _bloc.listOrder.clear();
            
            // Convert Product → SearchItemResponseData
            for (var product in _bloc.listProductOrderAndUpdate) {
              if (product.isMark == 1) {
                SearchItemResponseData item = SearchItemResponseData(
                  code: product.code,
                  sttRec0: product.sttRec0,
                  name: product.name,
                  name2: product.name2,
                  dvt: product.dvt,
                  descript: product.description,
                  price: product.price ?? 0,
                  priceAfterTax: product.priceAfterTax,
                  valuesTax: product.valuesTax,
                  applyPriceAfterTax: product.applyPriceAfterTax == 1,
                  woPrice: product.woPrice,
                  woPriceAfter: product.woPriceAfter,
                  priceOk: product.priceOk,
                  discountPercent: product.discountPercent ?? 0,
                  priceAfter: product.priceAfter ?? product.price ?? 0,
                  priceAfter2: product.priceAfter ?? product.price ?? 0,
                  stockAmount: product.stockAmount,
                  taxPercent: product.taxPercent,
                  imageUrl: product.imageUrl,
                  count: product.count ?? 0,
                  countMax: product.countMax ?? 0,
                  isMark: product.isMark ?? 1,
                  discountMoney: product.discountMoney,
                  discountProduct: product.discountProduct,
                  budgetForItem: product.budgetForItem,
                  budgetForProduct: product.budgetForProduct,
                  residualValueProduct: product.residualValueProduct ?? 0,
                  residualValue: product.residualValue ?? 0,
                  unit: product.unit,
                  unitProduct: product.unitProduct,
                  dsCKLineItem: product.dsCKLineItem,
                  maCk: product.dsCKLineItem?.isNotEmpty == true ? product.dsCKLineItem : null,
                  allowDvt: product.allowDvt == 0,
                  contentDvt: product.contentDvt,
                  stockCode: product.codeStock,
                  stockName: product.nameStock,
                  idVv: product.idVv,
                  idHd: product.idHd,
                  nameVv: product.nameVv,
                  nameHd: product.nameHd,
                  isCheBien: product.isCheBien == 1,
                  isSanXuat: product.isSanXuat == 1,
                  giaSuaDoi: product.giaSuaDoi ?? product.price ?? 0,
                  giaGui: product.giaGui ?? 0,
                  priceMin: product.priceMin ?? 0,
                  heSo: product.heSo,
                  idNVKD: product.idNVKD,
                  nameNVKD: product.nameNVKD,
                  nuocsx: product.nuocsx,
                  quycach: product.quycach,
                  maThue: product.maThue,
                  tenThue: product.tenThue,
                  thueSuat: product.thueSuat,
                  maVt2: product.maVt2,
                  so_luong_kd: product.so_luong_kd,
                  discountByHand: product.discountByHand == 1,
                  discountPercentByHand: product.discountPercentByHand ?? 0,
                  ckntByHand: product.ckntByHand ?? 0,
                  gifProduct: false, // Sản phẩm từ DB không phải quà tặng
                  gifProductByHand: false,
                );
                _bloc.listOrder.add(item);
              }
            }
            print('💾 ✅ Synced ${_bloc.listOrder.length} items from listProductOrderAndUpdate to listOrder');

            // ✅ Sau khi đồng bộ lại sản phẩm, cần tính lại tiền và chiết khấu LOCALLY
            // Sử dụng CalculatorDiscountEvent (reLoad=true) để:
            //  - Recalculate: totalMoney, totalDiscount, totalPayment, totalTax
            //  - Sau đó CartBloc sẽ phát CalculatorDiscountSuccess → UpdateListOrder → UI + bottom total được cập nhật
            if (_bloc.listOrder.isNotEmpty) {
              print('💰 Recalculating totals after cart changed (sync from DB)...');
              _bloc.add(CalculatorDiscountEvent(
                addOnProduct: false,
                reLoad: true,
                addTax: false,
              ));
            }
            
            // Force UI rebuild sau khi sync
            if (mounted) {
              setState(() {});
            }
          }

          // ✅ QUAN TRỌNG: Áp dụng chiết khấu tự do khi sửa đơn (chạy ngay sau khi load từ database)
          // Logic này cần chạy cho CẢ keyLoad == 'First' và keyLoad != 'First' để đảm bảo chiết khấu được áp dụng đúng
          if(widget.viewUpdateOrder == true && Const.freeDiscount == true && _bloc.listOrder.isNotEmpty){
            print('💰 [EDIT ORDER] Applying freeDiscount logic after loading from database...');
            bool hasAppliedDiscount = false;
            for (int index = 0; index < _bloc.listOrder.length ; index++) {
              // ✅ QUAN TRỌNG: Kiểm tra xem sản phẩm đã có chiết khấu từ chi tiết đơn hàng chưa
              // Tìm sản phẩm tương ứng trong listProductOrderAndUpdate (từ database)
              Product? productFromDB = _bloc.listProductOrderAndUpdate.firstWhere(
                (product) => product.code.toString().trim() == _bloc.listOrder[index].code.toString().trim(),
                orElse: () => Product(),
              );
              
              // ✅ Kiểm tra xem sản phẩm đã có chiết khấu từ chi tiết đơn hàng chưa
              // Có chiết khấu nếu:
              // 1. discountByHand = 1 và discountPercentByHand > 0 (từ database)
              // 2. HOẶC discountPercentByHand > 0 trong listOrder (đã được load từ database)
              // 3. HOẶC discountPercent > 0 và priceAfter != price (có chiết khấu thực sự)
              bool hasDiscountFromOrderDetail = false;
              double existingDiscountPercent = 0;
              
              if (productFromDB.code != null && productFromDB.code.toString().trim().isNotEmpty) {
                // Có sản phẩm trong database
                if (productFromDB.discountByHand == 1 && (productFromDB.discountPercentByHand ?? 0) > 0) {
                  // Đã có chiết khấu nhập tay từ chi tiết đơn hàng
                  hasDiscountFromOrderDetail = true;
                  existingDiscountPercent = productFromDB.discountPercentByHand ?? 0;
                  print('💰 [EDIT ORDER] Product ${_bloc.listOrder[index].code} has discount from order detail: ${existingDiscountPercent}% (from database)');
                }
              }
              
              // Kiểm tra trong listOrder (có thể đã được load từ database)
              if (!hasDiscountFromOrderDetail && 
                  (_bloc.listOrder[index].discountPercentByHand ?? 0) > 0) {
                hasDiscountFromOrderDetail = true;
                existingDiscountPercent = _bloc.listOrder[index].discountPercentByHand ?? 0;
                print('💰 [EDIT ORDER] Product ${_bloc.listOrder[index].code} has discount from order detail: ${existingDiscountPercent}% (from listOrder)');
              }
              
              // Kiểm tra discountPercent và priceAfter (có chiết khấu thực sự)
              if (!hasDiscountFromOrderDetail && 
                  (_bloc.listOrder[index].discountPercent ?? 0) > 0 &&
                  _bloc.listOrder[index].priceAfter != null &&
                  _bloc.listOrder[index].priceAfter! > 0 &&
                  _bloc.listOrder[index].price != null &&
                  _bloc.listOrder[index].price! > 0 &&
                  _bloc.listOrder[index].priceAfter != _bloc.listOrder[index].price) {
                hasDiscountFromOrderDetail = true;
                existingDiscountPercent = _bloc.listOrder[index].discountPercent ?? 0;
                print('💰 [EDIT ORDER] Product ${_bloc.listOrder[index].code} has discount from order detail: ${existingDiscountPercent}% (from discountPercent)');
              }
              
              if (hasDiscountFromOrderDetail) {
                // ✅ Đã có chiết khấu từ chi tiết đơn hàng, giữ nguyên và chỉ set discountByHand = true
                _bloc.listOrder[index].discountByHand = true;
                
                // Đảm bảo discountPercentByHand và ckntByHand được set đúng
                if ((_bloc.listOrder[index].discountPercentByHand ?? 0) == 0) {
                  _bloc.listOrder[index].discountPercentByHand = existingDiscountPercent;
                }
                
                // Tính lại ckntByHand nếu chưa có
                if ((_bloc.listOrder[index].ckntByHand ?? 0) == 0) {
                  double sl = _bloc.listOrder[index].count ?? 0;
                  double price = _bloc.listOrder[index].price ?? _bloc.listOrder[index].giaSuaDoi ?? 0;
                  _bloc.listOrder[index].ckntByHand = (price * sl * (_bloc.listOrder[index].discountPercentByHand ?? 0)) / 100;
                }
                
                // Đảm bảo priceAfter đúng
                if (_bloc.listOrder[index].priceAfter == null || 
                    _bloc.listOrder[index].priceAfter == 0 ||
                    _bloc.listOrder[index].priceAfter == _bloc.listOrder[index].price) {
                  double originalPrice = _bloc.listOrder[index].giaSuaDoi ?? _bloc.listOrder[index].price ?? 0;
                  _bloc.listOrder[index].priceAfter = originalPrice - (originalPrice * (_bloc.listOrder[index].discountPercentByHand ?? 0) / 100);
                }
                
                print('💰 [EDIT ORDER] ✅ Preserved discount for ${_bloc.listOrder[index].code}: ${_bloc.listOrder[index].discountPercentByHand}%');
              } else {
                // ✅ Chưa có chiết khấu từ chi tiết đơn hàng, áp dụng chiết khấu tự do
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
                hasAppliedDiscount = true;
                print('💰 [EDIT ORDER] Applied free discount for ${_bloc.listOrder[index].code}: ${_bloc.listOrder[index].discountPercentByHand}%');
              }
            }
            if(hasAppliedDiscount){
              Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã áp dụng chiết khấu tự do');
            }
            setState(() {});
          }
          
          // ✅ QUAN TRỌNG: Clear chiết khấu từ database trong mode add
          // Database chứa sản phẩm với chiết khấu đã lưu từ lần trước
          final isNewOrder = widget.sttRec == null || widget.sttRec!.trim().isEmpty;
          if (isNewOrder && widget.viewUpdateOrder != true && state.key == '') {
            print('💰 [ADD MODE] Clearing discounts from database products...');
            for (var product in _bloc.listProductOrderAndUpdate) {
              if (product.isMark == 1 && product.discountByHand != 1) {
                double originalPrice = product.price ?? product.giaSuaDoi ?? 0;
                if (originalPrice > 0) {
                  print('💰   Clearing discount for ${product.code}: discountPercent=${product.discountPercent}, dsCKLineItem=${product.dsCKLineItem}');
                  product.discountPercent = 0;
                  product.discountPercentByHand = 0;
                  product.ckntByHand = 0;
                  product.discountByHand = 0;
                  product.discountMoney = '0';
                  product.dsCKLineItem = ''; // ✅ Set thành string rỗng thay vì null để tránh lỗi database
                  product.priceAfter = originalPrice;
                  product.giaSuaDoi = originalPrice;
                  
                  // ✅ Update trong database để clear discount
                  _bloc.db.updateProduct(product, product.codeStock.toString(), false);
                }
              }
            }
            
            // ✅ Clear chiết khấu từ listOrder (SearchItemResponseData)
            for (var item in _bloc.listOrder) {
              if (item.gifProduct != true && item.discountByHand != true) {
                double originalPrice = item.giaSuaDoi ?? item.price ?? 0;
                if (originalPrice > 0) {
                  print('💰   Clearing discount for listOrder item ${item.code}: discountPercent=${item.discountPercent}');
                  item.discountPercent = 0;
                  item.discountPercentByHand = 0;
                  item.discountByHand = false;
                  item.ckntByHand = 0;
                  item.maCk = null;
                  item.sttRecCK = null;
                  item.typeCK = null;
                  item.discountMoney = null;
                  item.priceAfter = originalPrice;
                }
              }
            }
            print('💰 [ADD MODE] ✅ All discounts cleared from database products');
          }
          
          // ✅ QUAN TRỌNG: Sync chiết khấu byhand từ listOrder vào listProductOrderAndUpdate
          // Đảm bảo chiết khấu byhand có trong listProductOrderAndUpdate để preserve khi call API tính chiết khấu
          if (_bloc.listOrder.isNotEmpty && _bloc.listProductOrderAndUpdate.isNotEmpty) {
            print('💾 Syncing manual discount from listOrder to listProductOrderAndUpdate...');
            int syncedCount = 0;
            for (var item in _bloc.listOrder) {
              if (item.discountByHand == true && (item.discountPercentByHand ?? 0) > 0 && item.code != null) {
                // Tìm sản phẩm tương ứng trong listProductOrderAndUpdate
                for (var element in _bloc.listProductOrderAndUpdate) {
                  if (element.code != null && element.code.toString().trim() == item.code!.trim()) {
                    // Sync chiết khấu byhand vào listProductOrderAndUpdate
                    element.discountByHand = 1;
                    element.discountPercentByHand = item.discountPercentByHand;
                    element.ckntByHand = item.ckntByHand ?? 0;
                    element.priceAfter = item.priceAfter;
                    syncedCount++;
                    print('💾 ✅ Synced manual discount for ${element.code}: discountPercentByHand=${element.discountPercentByHand}, ckntByHand=${element.ckntByHand}');
                    break;
                  }
                }
              }
            }
            print('💾 Synced $syncedCount manual discounts from listOrder to listProductOrderAndUpdate');
          }
          
          // ✅ QUAN TRỌNG: Trong EDIT MODE, set chiết khấu byhand từ lineItem (ck_nt) vào listProductOrderAndUpdate
          // Tính toán trực tiếp từ order detail (lineItem) khi có ck_nt và tl_ck = 0 (chiết khấu nhập tay)
          // Ưu tiên: lineItem > widget.listOrder
          if (widget.viewUpdateOrder == true && _bloc.listProductOrderAndUpdate.isNotEmpty) {
            int syncedCount = 0;
            
            // ✅ CÁCH 1: Set từ lineItem (nếu có)
            if (_bloc.lineItem.isNotEmpty) {
              print('💾 [EDIT MODE] Setting manual discount from lineItem (ck_nt) to listProductOrderAndUpdate...');
              print('💾   - lineItem.length = ${_bloc.lineItem.length}');
              print('💾   - listProductOrderAndUpdate.length = ${_bloc.listProductOrderAndUpdate.length}');
              
              for (var lineItemElement in _bloc.lineItem) {
                print('💾   - Checking lineItem: maVt=${lineItemElement.maVt}, ckNt=${lineItemElement.ckNt}, discountPercent=${lineItemElement.discountPercent}, price=${lineItemElement.price}');
                // ✅ Kiểm tra: có ck_nt và tl_ck = 0 (chiết khấu nhập tay)
                if (lineItemElement.maVt != null && 
                    lineItemElement.ckNt != null && lineItemElement.ckNt! > 0 &&
                    (lineItemElement.discountPercent == null || lineItemElement.discountPercent == 0) &&
                    lineItemElement.price != null && lineItemElement.price! > 0) {
                  // Tính tỷ lệ phần trăm từ tiền chiết khấu
                  double originalPrice = lineItemElement.price!;
                  double quantity = lineItemElement.soLuong ?? 1;
                  double totalOriginalPrice = originalPrice * quantity;
                  
                  if (totalOriginalPrice > 0) {
                    double discountPercent = (lineItemElement.ckNt! / totalOriginalPrice) * 100;
                    String productCode = lineItemElement.maVt.toString().trim();
                    
                    // Tìm sản phẩm tương ứng trong listProductOrderAndUpdate
                    for (var element in _bloc.listProductOrderAndUpdate) {
                      if (element.code != null && element.code.toString().trim() == productCode) {
                        // Set chiết khấu byhand vào listProductOrderAndUpdate
                        element.discountByHand = 1;
                        element.discountPercentByHand = discountPercent;
                        element.ckntByHand = lineItemElement.ckNt!;
                        // Tính lại priceAfter từ chiết khấu
                        double priceAfter = originalPrice * (1 - discountPercent / 100);
                        element.priceAfter = priceAfter;
                        element.discountPercent = discountPercent;
                        syncedCount++;
                        print('💾 ✅ [EDIT MODE] Set manual discount from lineItem for ${element.code}: discountByHand=1, discountPercentByHand=$discountPercent, ckntByHand=${lineItemElement.ckNt}, priceAfter=$priceAfter');
                        // ✅ Update vào database để lưu chiết khấu byhand
                        _bloc.db.updateProduct(element, element.codeStock.toString(), false);
                        break;
                      }
                    }
                  }
                }
              }
            } else {
              print('💾 [EDIT MODE] ⚠️ lineItem is empty, cannot set manual discount from lineItem');
            }
            
            print('💾 [EDIT MODE] Set $syncedCount manual discounts from lineItem to listProductOrderAndUpdate');
            
            // ✅ CÁCH 2: Nếu lineItem rỗng và widget.listOrder không có chiết khấu byhand, 
            // tính toán lại từ infoPayment hoặc totalDiscountForOder
            // Áp dụng khi:
            // 1. Có codeDiscountTD hoặc listCkTongDon có CKTDTT (CK từ chương trình)
            // 2. HOẶC có infoPayment.tCkTtNt >= threshold (CK tổng đơn nhập tay freeDiscount)
            if (syncedCount == 0 && _bloc.listProductOrderAndUpdate.isNotEmpty) {
              // ✅ CHECK 1: Đơn có CK tổng đơn từ chương trình không? (CKTDTT)
              bool hasProgramTotalDiscount = false;
              
              // Check codeDiscountTD (mã CK tổng đơn từ chương trình)
              if (_bloc.codeDiscountTD != null && _bloc.codeDiscountTD!.trim().isNotEmpty) {
                hasProgramTotalDiscount = true;
                print('💰 [EDIT MODE - FreeDiscount] ✅ Found codeDiscountTD (program discount): ${_bloc.codeDiscountTD}');
              }
              
              // Check listCkTongDon có CKTDTT không
              if (!hasProgramTotalDiscount && _bloc.listCkTongDon.isNotEmpty) {
                for (var cktd in _bloc.listCkTongDon) {
                  if (cktd.kieuCK == 'CKTDTT' || (cktd.kieuCK != null && cktd.kieuCK.toString().trim().isNotEmpty)) {
                    hasProgramTotalDiscount = true;
                    print('💰 [EDIT MODE - FreeDiscount] ✅ Found CKTDTT in listCkTongDon: maCk=${cktd.maCk}, kieuCK=${cktd.kieuCK}');
                    break;
                  }
                }
              }
              
              // ✅ CHECK 2: Có infoPayment với tCkTtNt >= threshold không? (CK tổng đơn nhập tay)
              bool hasManualTotalDiscount = false;
              const double threshold = 1000.0; // 1000 VND
              
              if (_bloc.infoPayment != null) {
                final double totalDiscountOrder = _bloc.infoPayment!.tCkTtNt ?? 0;
                if (totalDiscountOrder >= threshold) {
                  hasManualTotalDiscount = true;
                  print('💰 [EDIT MODE - FreeDiscount] ✅ Found manual total discount: tCkTtNt=$totalDiscountOrder >= threshold=$threshold');
                }
              }
              
              // ✅ Áp dụng CK tổng đơn nếu có flag từ chương trình HOẶC có CK nhập tay >= threshold
              if (!hasProgramTotalDiscount && !hasManualTotalDiscount) {
                print('💰 [EDIT MODE - FreeDiscount] ⚠️ SKIP: No program total discount flag and no manual total discount >= threshold');
              } else {
                // Kiểm tra xem có infoPayment không
                if (_bloc.infoPayment != null) {
                  // NOTE: infoPayment lấy từ master khi vào sửa đơn
                  final double totalMoney = _bloc.infoPayment!.tTien ?? 0;
                  final double totalTax = _bloc.infoPayment!.tThueNt ?? 0;
                  final double totalDiscountOrder = _bloc.infoPayment!.tCkTtNt ?? 0; // t_ck_tt_nt
                  final double totalPayment = _bloc.infoPayment!.tTtNt ?? 0; // t_tt_nt
                  
                  // ✅ Áp dụng nếu có CK từ chương trình HOẶC có CK nhập tay >= threshold
                  if (totalMoney > 0 && (hasProgramTotalDiscount || totalDiscountOrder >= threshold) && Const.freeDiscount == true) {
                    // ✅ FreeDiscount (EDIT MODE): tính % CK tổng đơn theo đúng base mà CartBloc dùng khi tính lại
                    // base = totalMoney + totalTax - totalDiscountDong
                    // từ master: base = t_ck_tt_nt + t_tt_nt
                    final double base = totalDiscountOrder + totalPayment;
                    if (base > 0) {
                      final double discountPercent = (totalDiscountOrder / base) * 100;
                      _bloc.manualTotalDiscountPercent = discountPercent;
                      print('💰 [EDIT MODE - FreeDiscount] ✅ Set manualTotalDiscountPercent from infoPayment: $discountPercent% (t_ck_tt_nt=$totalDiscountOrder >= threshold=$threshold, t_tt_nt=$totalPayment, base=$base, t_tien=$totalMoney, t_thue_nt=$totalTax)');
                    
                      // Set chiết khấu byhand cho tất cả sản phẩm trong listProductOrderAndUpdate
                      for (var product in _bloc.listProductOrderAndUpdate) {
                        if (product.price != null && product.count != null && product.count! > 0) {
                          double productTotalPrice = (product.price! * product.count!);
                          double productDiscount = (productTotalPrice * discountPercent) / 100;
                          
                          product.discountByHand = 1;
                          product.discountPercentByHand = discountPercent;
                          product.ckntByHand = productDiscount;
                          double priceAfter = product.price! * (1 - discountPercent / 100);
                          product.priceAfter = priceAfter;
                          product.discountPercent = discountPercent;
                          
                          print('💾 ✅ [EDIT MODE - FreeDiscount] Applied manual total discount as byhand for ${product.code}: discountPercent=$discountPercent, ckntByHand=$productDiscount, priceAfter=$priceAfter');
                          // ✅ Update vào database để lưu chiết khấu byhand
                          _bloc.db.updateProduct(product, product.codeStock.toString(), false);
                          syncedCount++;
                        }
                      }
                      
                      // ✅ QUAN TRỌNG: Sau khi set xong, bắt buộc tính lại tổng để UI/bottom total match
                      if (mounted && _bloc.listOrder.isNotEmpty) {
                        print('💰 [EDIT MODE - FreeDiscount] Recalculating totals after applying manualTotalDiscountPercent...');
                        _bloc.add(CalculatorDiscountEvent(addOnProduct: false, reLoad: true, addTax: false));
                      }
                    }
                  } else if (totalDiscountOrder > 0 && totalDiscountOrder < threshold) {
                    print('💰 [EDIT MODE - FreeDiscount] ⚠️ SKIP: totalDiscountOrder=$totalDiscountOrder < threshold=$threshold (likely rounding error)');
                  }
                } else if (_bloc.totalDiscountForOder != null && _bloc.totalDiscountForOder! >= 1000.0 && _bloc.totalMoney > 0) {
                  // Fallback: Tính từ totalDiscountForOder nếu infoPayment không có (chỉ khi >= threshold)
                  double discountPercent = (_bloc.totalDiscountForOder! / _bloc.totalMoney) * 100;
                  
                  print('💰 [EDIT MODE - FreeDiscount] ✅ Set manualTotalDiscountPercent from totalDiscountForOder: $discountPercent% (totalDiscountForOder=${_bloc.totalDiscountForOder} >= 1000, totalMoney=${_bloc.totalMoney})');
                  
                  for (var product in _bloc.listProductOrderAndUpdate) {
                    if (product.price != null && product.count != null && product.count! > 0) {
                      double productTotalPrice = (product.price! * product.count!);
                      double productDiscount = (productTotalPrice * discountPercent) / 100;
                      
                      product.discountByHand = 1;
                      product.discountPercentByHand = discountPercent;
                      product.ckntByHand = productDiscount;
                      double priceAfter = product.price! * (1 - discountPercent / 100);
                      product.priceAfter = priceAfter;
                      product.discountPercent = discountPercent;
                      
                      print('💾 ✅ [EDIT MODE] Calculated manual discount from totalDiscountForOder for ${product.code}: discountPercent=$discountPercent, ckntByHand=$productDiscount');
                      _bloc.db.updateProduct(product, product.codeStock.toString(), false);
                      syncedCount++;
                    }
                  }
                }
              }
              
              if (syncedCount > 0) {
                print('💾 [EDIT MODE] Set $syncedCount manual discounts from infoPayment/totalDiscountForOder to listProductOrderAndUpdate');
              }
            }
          }
          
          // ✅ QUAN TRỌNG: Trong EDIT MODE, sync chiết khấu byhand từ widget.listOrder vào listProductOrderAndUpdate
          // widget.listOrder có chiết khấu byhand từ order detail (đã được set khi xử lý order detail)
          if (widget.viewUpdateOrder == true && widget.listOrder != null && widget.listOrder!.isNotEmpty && _bloc.listProductOrderAndUpdate.isNotEmpty) {
            print('💾 [EDIT MODE] Syncing manual discount from widget.listOrder to listProductOrderAndUpdate...');
            print('💾   - widget.listOrder.length = ${widget.listOrder!.length}');
            int syncedCount = 0;
            for (var product in widget.listOrder!) {
              print('💾   - Checking product: code=${product.code}, discountByHand=${product.discountByHand}, discountPercentByHand=${product.discountPercentByHand}, ckntByHand=${product.ckntByHand}');
              // ✅ Product class ĐÃ CÓ discountByHand, discountPercentByHand, ckntByHand (từ order detail)
              // Kiểm tra trực tiếp từ product (Product) thay vì tìm trong _bloc.listOrder
              if (product.code != null && product.code.toString().trim().isNotEmpty &&
                  product.discountByHand == 1 && 
                  (product.discountPercentByHand ?? 0) > 0) {
                // Tìm sản phẩm tương ứng trong listProductOrderAndUpdate
                for (var element in _bloc.listProductOrderAndUpdate) {
                  if (element.code != null && element.code.toString().trim() == product.code?.toString().trim()) {
                    // Sync chiết khấu byhand vào listProductOrderAndUpdate (chỉ nếu chưa có)
                    if (element.discountByHand != 1 || (element.discountPercentByHand ?? 0) == 0) {
                      element.discountByHand = 1;
                      element.discountPercentByHand = product.discountPercentByHand;
                      element.ckntByHand = product.ckntByHand ?? 0;
                      element.priceAfter = product.priceAfter;
                      syncedCount++;
                      print('💾 ✅ [EDIT MODE] Synced manual discount for ${element.code}: discountByHand=${element.discountByHand}, discountPercentByHand=${element.discountPercentByHand}, ckntByHand=${element.ckntByHand}, priceAfter=${element.priceAfter}');
                    } else {
                      print('💾 ⚠️ [EDIT MODE] Skipped ${element.code}: already has manual discount');
                    }
                    break;
                  }
                }
              }
            }
            print('💾 [EDIT MODE] Synced $syncedCount manual discounts from widget.listOrder to listProductOrderAndUpdate');
          }
          
          // ✅ QUAN TRỌNG: Nếu danh sách sản phẩm = 0 và đang tạo đơn mới, xóa draft
          if (isNewOrder && widget.viewUpdateOrder != true && 
              _bloc.listOrder.isEmpty && DataLocal.listProductGift.isEmpty) {
            print('💾 🧹 Danh sách sản phẩm = 0, xóa draft');
            CartDraftStorage.clearDraft();
            // Clear thông tin khách hàng
            _bloc.customerName = null;
            _bloc.codeCustomer = null;
            _bloc.phoneCustomer = null;
            _bloc.addressCustomer = null;
            DataLocal.infoCustomer = ManagerCustomerResponseData();
            nameCustomerController.clear();
            phoneCustomerController.clear();
            addressCustomerController.clear();
            print('💾 ✅ Draft và thông tin khách hàng đã được xóa');
          }
          // ✅ Tự động lưu draft sau khi có thay đổi sản phẩm (xóa, cập nhật số lượng, v.v.)
          // Chỉ lưu khi key != 'First' (không phải lần load đầu tiên)
          else if (state.key != 'First') {
            _autoSaveDraft();
          }
          
          // ✅ Restore listOrder từ draft nếu GetListProductFromDB làm mất listOrder (khi tạo đơn mới)
          // Dùng lại biến isNewOrder đã khai báo ở trên (dòng 820)
          print('💾 isNewOrder=$isNewOrder, widget.listOrder=${widget.listOrder?.length ?? 0}');
          
          // ✅ Ưu tiên restore từ preservedListOrderFromDraft (từ AddProductToCartEvent)
          // Nếu không có, mới restore từ database
          if (isNewOrder && (widget.listOrder == null || widget.listOrder!.isEmpty)) {
            // Kiểm tra preservedListOrderFromDraft trước
            if (_bloc.preservedListOrderFromDraft != null && _bloc.preservedListOrderFromDraft!.isNotEmpty) {
              print('💾 Found preservedListOrderFromDraft (from AddProductToCartEvent):');
              print('💾   - preservedListOrderFromDraft.length = ${_bloc.preservedListOrderFromDraft!.length}');
              
              // Nếu listOrder bị empty sau khi load đơn cũ, restore từ draft
              if (_bloc.listOrder.isEmpty) {
                _bloc.listOrder.clear();
                _bloc.listOrder.addAll(_bloc.preservedListOrderFromDraft!);
                print('💾 ✅ Restored listOrder from preservedListOrderFromDraft - listOrder.length=${_bloc.listOrder.length}');
                // Clear biến tạm sau khi restore
                _bloc.preservedListOrderFromDraft = null;
                if (mounted) {
                  setState(() {});
                }
              } else {
                print('💾 listOrder not empty, skip restore from preservedListOrderFromDraft');
                _bloc.preservedListOrderFromDraft = null; // Clear biến tạm
              }
            }
            // Nếu không có preservedListOrderFromDraft, thử restore từ database
            // ✅ CHỈ restore nếu listProductOrderAndUpdate rỗng (chưa có sản phẩm từ database)
            // Nếu đã có sản phẩm từ database, không restore draft để tránh mất sản phẩm vừa thêm
            else if (_bloc.listOrder.isEmpty && _bloc.listProductOrderAndUpdate.isEmpty) {
              print('💾 No preservedListOrderFromDraft, attempting to restore draft from database...');
              print('💾   - listOrder.isEmpty = ${_bloc.listOrder.isEmpty}');
              print('💾   - listProductOrderAndUpdate.isEmpty = ${_bloc.listProductOrderAndUpdate.isEmpty}');
              // ✅ QUAN TRỌNG: Trong mode add, clear discounts khi restore draft
              CartDraftStorage.restoreDraft(_bloc, clearDiscounts: true).then((restored) {
                if (restored && mounted) {
                  print('💾 ✅ Restored listOrder from draft in GetListProductFromDBSuccess (with discounts cleared) - listOrder.length=${_bloc.listOrder.length}');
                  print('💾 manualTotalDiscountPercent after restore: ${_bloc.manualTotalDiscountPercent}%');
                  // ✅ QUAN TRỌNG: Trigger tính toán lại chiết khấu và tổng tiền sau khi restore
                  if (_bloc.listOrder.isNotEmpty) {
                    print('💰 Triggering recalculation after restore draft...');
                    _bloc.add(CalculatorDiscountEvent(
                      addOnProduct: false,
                      reLoad: true,
                      addTax: false,
                    ));
                  }
                  // ✅ QUAN TRỌNG: Refresh UI để hiển thị manualTotalDiscountPercent đã được restore
                  setState(() {});
                } else {
                  print('💾 ❌ Failed to restore draft in GetListProductFromDBSuccess');
                }
              });
            } else {
              print('💾 Skip restore: listOrder or listProductOrderAndUpdate not empty');
              print('💾   - listOrder.length = ${_bloc.listOrder.length}');
              print('💾   - listProductOrderAndUpdate.length = ${_bloc.listProductOrderAndUpdate.length}');
            }
          } else {
            print('💾 Skip restore: not new order or widget.listOrder exists');
            // Clear biến tạm nếu không phải đơn mới
            _bloc.preservedListOrderFromDraft = null;
          }
          
          // ✅ COPY ORDER MODE: Clear tất cả discount info nếu đang copy đơn hàng
          // Chỉ clear khi load data lần đầu (key == 'First' hoặc '')
          if (widget.isCopyOrder == true && _bloc.listProductOrderAndUpdate.isNotEmpty && (state.key == 'First' || state.key == '')) {
            print('💰 [COPY MODE] Clearing all discount information from products...');
            print('💰 [COPY MODE] state.key = ${state.key}, listProductOrderAndUpdate.length = ${_bloc.listProductOrderAndUpdate.length}');
            bool hasChanges = false;
            
            // ✅ Clear discount từ listProductOrderAndUpdate (dữ liệu từ DB)
            for (var product in _bloc.listProductOrderAndUpdate) {
              if (product.isMark == 1) {
                // ✅ Get original price (giá gốc) - ưu tiên price, sau đó giaSuaDoi
                double originalPrice = product.price ?? 0;
                if (originalPrice == 0) {
                  originalPrice = product.giaSuaDoi ?? 0;
                }
                
                if (originalPrice > 0) {
                  // Clear ALL discount fields (chỉ các field có trong Product model)
                  product.maVtGoc = null;
                  product.sctGoc = null;
                  product.discountPercent = 0;
                  product.discountPercentByHand = 0;
                  product.ckntByHand = 0;
                  product.discountByHand = 0; // int, not bool
                  product.discountMoney = '0';
                  product.dsCKLineItem = null; // ✅ Clear discount code from line item
                  
                  // ✅ Reset về giá gốc (không còn chiết khấu)
                  product.price = originalPrice;
                  product.giaSuaDoi = originalPrice;
                  product.priceAfter = originalPrice;
                  
                  // ✅ Update in database
                  _bloc.db.updateProduct(product, product.codeStock.toString(), false);
                  
                  hasChanges = true;
                  print('💰 [COPY MODE] Cleared discount for ${product.code}: price=$originalPrice, priceAfter=$originalPrice');
                }
              }
            }
            
            // ✅ Clear discount từ listOrder (SearchItemResponseData) - dữ liệu hiển thị trên UI
            for (var item in _bloc.listOrder) {
              if (item.gifProduct != true) {
                double originalPrice = item.price ?? item.giaSuaDoi ?? 0;
                if (originalPrice > 0) {
                  // Clear discount fields trong SearchItemResponseData
                  item.typeCK = '';
                  item.maCk = '';
                  item.sttRecCK = '';
                  item.maVtGoc = '';
                  item.sctGoc = '';
                  item.discountPercent = 0;
                  item.ck = 0;
                  item.cknt = 0;
                  
                  // Reset về giá gốc
                  item.price = originalPrice;
                  item.giaSuaDoi = originalPrice;
                  item.priceAfter = originalPrice;
                  item.priceAfter2 = originalPrice;
                  
                  hasChanges = true;
                  print('💰 [COPY MODE] Cleared discount for listOrder item ${item.code}: price=$originalPrice');
                }
              }
            }
            
            // ✅ Clear discount selections
            _bloc.selectedCkgIds.clear();
            _bloc.selectedHHIds.clear();
            _bloc.selectedCktdttIds.clear();
            _bloc.selectedCknProductCode = null;
            _bloc.selectedCknSttRecCk = null;
            _bloc.selectedDiscountGroup = null;
            _bloc.selectedCknGroups.clear();
            _bloc.listPromotion = '';
            DataLocal.listCKVT = '';
            
            // ✅ Recalculate totals after clearing discount
            if (hasChanges) {
              print('💰 [COPY MODE] Recalculating totals after clearing discount...');
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _bloc.add(CalculatorDiscountEvent(addOnProduct: false, reLoad: true, addTax: false));
                }
              });
            }
          }
          
          if(_bloc.listProductOrderAndUpdate.isNotEmpty){
            getDiscountProduct(state.key);
          }
          else {
            // ✅ FIX: Clear listOrder khi listProductOrderAndUpdate rỗng (đã xóa hết sản phẩm)
            // Bất kể key là gì, nếu không còn sản phẩm trong DB thì phải clear listOrder
            _bloc.listItemOrder.clear();
            _bloc.listOrder.clear();
            _bloc.listCkTongDon.clear();
            _bloc.listCkMatHang.clear();
            _bloc.totalMoney = 0;
            _bloc.totalDiscount = 0; 
            _bloc.totalPayment = 0;
            Const.listKeyGroupCheck = '';
            Const.listKeyGroup = '';
            print('💾   After clear (empty cart): listOrder.length=${_bloc.listOrder.length}');
            
            // ✅ Force rebuild UI
            setState(() {});
            
            // ✅ Nếu đang tạo đơn mới và listOrder bị clear, restore từ draft
            final isNewOrder = widget.sttRec == null || widget.sttRec!.trim().isEmpty;
            if (isNewOrder && (widget.listOrder == null || widget.listOrder!.isEmpty)) {
              CartDraftStorage.restoreDraft(_bloc).then((restored) {
                if (restored && mounted) {
                  print('💾 ✅ Restored draft in DeleteAllProductFromDBSuccess - listOrder.length=${_bloc.listOrder.length}');
                  print('💾 manualTotalDiscountPercent after restore: ${_bloc.manualTotalDiscountPercent}%');
                  // ✅ QUAN TRỌNG: Trigger tính toán lại chiết khấu và tổng tiền sau khi restore
                  if (_bloc.listOrder.isNotEmpty) {
                    print('💰 Triggering recalculation after restore draft...');
                    _bloc.add(CalculatorDiscountEvent(
                      addOnProduct: false,
                      reLoad: true,
                      addTax: false,
                    ));
                  }
                  // ✅ QUAN TRỌNG: Refresh UI để hiển thị manualTotalDiscountPercent đã được restore
                  setState(() {});
                }
              });
            }
          }

        }
        else if(state is PickTaxAfterSuccess  || state is PickTaxBeforeSuccess){
          _bloc.chooseTax = true;
          _bloc.add(UpdateListOrder());
          // ✅ Tự động lưu draft sau khi thay đổi thuế (delay để UpdateListOrder hoàn thành)
          Future.delayed(const Duration(milliseconds: 100), () {
            _autoSaveDraft();
          });
        }
        else if(state is CalculatorDiscountSuccess){
          // ✅ EDIT MODE + FreeDiscount: Tự động khôi phục TLCK tổng đơn nhập tay từ InfoPayment (DataLocal)
          // CHỈ restore MỘT LẦN DUY NHẤT khi vào sửa đơn lần đầu, không restore lại khi xóa/cập nhật sản phẩm
          // Restore khi:
          // 1. Có codeDiscountTD hoặc listCkTongDon với CKTDTT (CK tổng đơn từ chương trình)
          // 2. HOẶC có infoPayment.tCkTtNt > 0 và chênh lệch >= threshold (CK tổng đơn nhập tay freeDiscount)
          // 3. HOẶC đã được lưu từ draft (DataLocal.editOrderManualTotalDiscountPercent > 0)
          if (widget.viewUpdateOrder == true &&
              Const.freeDiscount == true &&
              !_hasRestoredManualTotalDiscount && // ✅ CHỈ restore một lần
              _bloc.manualTotalDiscountPercent == 0 &&
              DataLocal.editOrderTotalDiscount > 0 &&
              (DataLocal.editOrderTotalMoney > 0 || DataLocal.editOrderTotalPayment > 0)) {
            try {
              // ✅ CHECK 1: Đơn có CK tổng đơn từ chương trình không? (CKTDTT)
              bool hasProgramTotalDiscount = false;
              
              // Check codeDiscountTD (mã CK tổng đơn từ chương trình)
              if (_bloc.codeDiscountTD != null && _bloc.codeDiscountTD!.trim().isNotEmpty) {
                hasProgramTotalDiscount = true;
                print('💰 [EDIT MODE - FreeDiscount] ✅ Found codeDiscountTD (program discount): ${_bloc.codeDiscountTD}');
              }
              
              // Check listCkTongDon có CKTDTT không
              if (!hasProgramTotalDiscount && _bloc.listCkTongDon.isNotEmpty) {
                for (var cktd in _bloc.listCkTongDon) {
                  if (cktd.kieuCK == 'CKTDTT' || (cktd.kieuCK != null && cktd.kieuCK.toString().trim().isNotEmpty)) {
                    hasProgramTotalDiscount = true;
                    print('💰 [EDIT MODE - FreeDiscount] ✅ Found CKTDTT in listCkTongDon: maCk=${cktd.maCk}, kieuCK=${cktd.kieuCK}');
                    break;
                  }
                }
              }
              
              // ✅ CHECK 2: Đã được lưu từ draft không?
              bool hasDraftManualDiscount = DataLocal.editOrderManualTotalDiscountPercent > 0;
              
              final double totalMoneyHistory = DataLocal.editOrderTotalMoney;
              final double totalDiscountHistory = DataLocal.editOrderTotalDiscount;
              final double totalTaxHistory = DataLocal.editOrderTotalTax;

              // Chiết khấu dòng hiện tại trong giỏ (CKG/CKN/HH, FreeDiscount theo dòng, v.v.)
              final double itemDiscountCurrent = _bloc.totalDiscount;

              // Phần chiết khấu tổng đơn nhập tay = chiết khấu lịch sử - chiết khấu dòng hiện tại
              double manualValue = totalDiscountHistory - itemDiscountCurrent;
              if (manualValue < 0) manualValue = 0;

              // ✅ CHECK 3: Threshold để tránh nhận nhầm do làm tròn
              // Tăng threshold lên 5000 VND để tránh nhận nhầm các chênh lệch nhỏ do làm tròn
              const double threshold = 5000.0; // 5000 VND
              
              // ✅ CHECK 4: Kiểm tra tỷ lệ chênh lệch so với tổng tiền (phải >= 0.5% để coi là CK tổng đơn thực sự)
              double discountRatio = 0;
              if (totalMoneyHistory > 0) {
                discountRatio = (manualValue / totalMoneyHistory) * 100;
              }
              const double minDiscountRatio = 0.5; // Tối thiểu 0.5% của tổng tiền
              
              // ✅ QUYẾT ĐỊNH: Restore nếu:
              // - Có CK tổng đơn từ chương trình (CKTDTT) → luôn restore
              // - HOẶC có draft manual discount → luôn restore
              // - HOẶC có chênh lệch >= threshold VÀ >= minDiscountRatio% (CK tổng đơn nhập tay freeDiscount) → restore
              bool shouldRestore = false;
              
              if (hasProgramTotalDiscount) {
                // Có CK từ chương trình → luôn restore
                shouldRestore = true;
                print('💰 [EDIT MODE - FreeDiscount] ✅ Will restore: Has program total discount (CKTDTT)');
              } else if (hasDraftManualDiscount) {
                // Có draft → luôn restore
                shouldRestore = true;
                print('💰 [EDIT MODE - FreeDiscount] ✅ Will restore: Has draft manual discount');
              } else if (manualValue >= threshold && discountRatio >= minDiscountRatio) {
                // Có chênh lệch đủ lớn VÀ đủ tỷ lệ → restore (CK tổng đơn nhập tay freeDiscount)
                shouldRestore = true;
                print('💰 [EDIT MODE - FreeDiscount] ✅ Will restore: manualValue=$manualValue >= threshold=$threshold AND discountRatio=$discountRatio% >= minDiscountRatio=$minDiscountRatio% (manual total discount)');
              } else {
                // Không đủ điều kiện → skip và đánh dấu đã check rồi để không check lại
                _hasRestoredManualTotalDiscount = true; // ✅ Đánh dấu đã check rồi, không restore
                print('💰 [EDIT MODE - FreeDiscount] ⚠️ SKIP auto-restore: manualValue=$manualValue < threshold=$threshold OR discountRatio=$discountRatio% < minDiscountRatio=$minDiscountRatio%, no program discount, no draft');
                DataLocal.editOrderManualTotalDiscountPercent = 0;
                _bloc.add(UpdateListOrder());
                Future.delayed(const Duration(milliseconds: 100), () {
                  _autoSaveDraft();
                });
                return;
              }

              // Base cho TLCK tổng đơn: tổng sau chiết khấu dòng nhưng trước CK tổng đơn
              final double base = totalMoneyHistory + totalTaxHistory - itemDiscountCurrent;

              if (shouldRestore && base > 0) {
                double percent;
                if (hasDraftManualDiscount) {
                  // Ưu tiên dùng giá trị từ draft
                  percent = DataLocal.editOrderManualTotalDiscountPercent;
                  print('💰 [EDIT MODE - FreeDiscount] ✅ Using draft manualTotalDiscountPercent: $percent%');
                } else {
                  // Tính từ chênh lệch
                  percent = (manualValue / base) * 100;
                }
                
                DataLocal.editOrderManualTotalDiscountPercent = percent;
                _hasRestoredManualTotalDiscount = true; // ✅ Đánh dấu đã restore rồi
                print('💰 [EDIT MODE - FreeDiscount] ✅ Restored manualTotalDiscountPercent from history: '
                    '$percent% (manualValue=$manualValue, base=$base, '
                    'totalDiscountHistory=$totalDiscountHistory, itemDiscountCurrent=$itemDiscountCurrent, '
                    'hasProgramTotalDiscount=$hasProgramTotalDiscount, hasDraftManualDiscount=$hasDraftManualDiscount)');

                // Gọi event áp dụng TLCK tổng đơn → CartBloc sẽ tự tính lại và bắn CalculatorDiscountSuccess lần nữa
                _bloc.add(ApplyManualTotalDiscountPercentEvent(percent));
                // ❗ Quan trọng: return để tránh chạy UpdateListOrder/_autoSaveDraft trên state trung gian
                return;
              } else {
                DataLocal.editOrderManualTotalDiscountPercent = 0;
                print('💰 [EDIT MODE - FreeDiscount] No manual total discount to restore (base=$base <= 0)');
              }
            } catch (e) {
              print('❌ [EDIT MODE - FreeDiscount] Error while restoring manualTotalDiscountPercent: $e');
            }
          }

          _bloc.add(UpdateListOrder());
          // ✅ Tự động lưu draft sau khi tính toán lại chiết khấu (delay để UpdateListOrder hoàn thành)
          Future.delayed(const Duration(milliseconds: 100), () {
            _autoSaveDraft();
          });
        }
        else if(state is PickTaxBeforeSuccess){
          _bloc.chooseTax = true;
        }
        else if(state is ApplyDiscountSuccess){
          // ✅ QUAN TRỌNG: Validate và xóa các chiết khấu không còn match với chương trình chiết khấu hiện tại
          // Validate khi keyLoad == 'First' (lần đầu load) hoặc 'Second' (sau khi restore từ draft hoặc edit mode)
          if(state.keyLoad == 'First' || state.keyLoad == 'Second') {
            // ✅ Delay để đảm bảo listCkg, listHH, etc. đã được cập nhật từ API response
            // Đặc biệt quan trọng cho edit mode khi cần validate với listHH
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                print('💰 Validation: listHH.length=${_bloc.listHH.length}, listCkg.length=${_bloc.listCkg.length}');
                
                // ✅ EDIT MODE: Validate chiết khấu từ lineItem với API response
                if (widget.viewUpdateOrder == true && state.keyLoad == 'Second' && _lineItemDiscounts.isNotEmpty) {
                  _validateLineItemDiscounts();
                } else {
                  // ADD MODE hoặc First load
                  _validateAndRemoveInvalidDiscounts();
                }
              }
            });
          }
          
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
            
            // ✅ QUAN TRỌNG: Update discountPercent trực tiếp vào listOrder sau API response
            // Đặc biệt quan trọng trong edit mode khi discountPercent được tính từ ckNt
            if (widget.viewUpdateOrder == true) {
              print('💰 [EDIT MODE] Updating discountPercent in listOrder after API response...');
              
              // ✅ Update discountPercent và priceAfter từ listItemOrder (đã có từ API response) vào listOrder
              // listItemOrder chứa itemOrder đã được xử lý với discountPercent và priceAfter từ API
              bool hasUpdates = false;
              for (var itemOrderFromAPI in _bloc.listItemOrder) {
                if (itemOrderFromAPI.gifProduct != true && itemOrderFromAPI.typeCK == 'CKG') {
                  // Tìm item tương ứng trong listOrder
                  int index = _bloc.listOrder.indexWhere((item) => 
                    item.code?.trim() == itemOrderFromAPI.code?.trim() && 
                    item.gifProduct != true
                  );
                  
                  if (index >= 0) {
                    // ✅ QUAN TRỌNG: Update cả priceAfter và discountPercent từ API response
                    // Đảm bảo priceAfter được tính đúng từ discountPercent nếu API trả về sai
                    double? finalPriceAfter = itemOrderFromAPI.priceAfter;
                    double? finalDiscountPercent = itemOrderFromAPI.discountPercent;
                    
                    // ✅ FIX: Nếu có discountPercent nhưng priceAfter = price (không có chiết khấu), tính lại priceAfter
                    if (finalDiscountPercent != null && finalDiscountPercent > 0 && 
                        _bloc.listOrder[index].price != null && _bloc.listOrder[index].price! > 0) {
                      double originalPrice = _bloc.listOrder[index].price!;
                      
                      // Nếu priceAfter từ API = price (không có chiết khấu), tính lại từ discountPercent
                      if (finalPriceAfter == null || finalPriceAfter <= 0 || finalPriceAfter >= originalPrice) {
                        finalPriceAfter = originalPrice - (originalPrice * finalDiscountPercent / 100);
                      } else {
                        // Verify: Nếu priceAfter từ API khác với tính toán từ discountPercent, ưu tiên tính toán
                        double calculatedPriceAfter = originalPrice - (originalPrice * finalDiscountPercent / 100);
                        double difference = (finalPriceAfter - calculatedPriceAfter).abs();
                        if (difference > 1.0) { // Nếu sai lệch > 1 VND, dùng giá trị tính toán
                          finalPriceAfter = calculatedPriceAfter;
                        }
                      }
                    }
                    
                    // Update priceAfter
                    if (finalPriceAfter != null && finalPriceAfter > 0) {
                      _bloc.listOrder[index].priceAfter = finalPriceAfter;
                    }
                    
                    // Update discountPercent
                    if (finalDiscountPercent != null && finalDiscountPercent > 0) {
                      _bloc.listOrder[index].discountPercent = finalDiscountPercent;
                      hasUpdates = true;
                    }
                  }
                }
              }
              
              // QUAN TRỌNG: Luôn sync data trước khi tính lại tổng tiền
              _syncListOrderToUI();
              
              // ✅ QUAN TRỌNG: Delay nhỏ để đảm bảo data đã được sync xong trước khi tính lại tổng tiền
              // Đặc biệt quan trọng: listProductOrderAndUpdate phải có priceAfter mới nhất từ listOrder
              Future.delayed(Duration(milliseconds: 400), () {
                if (mounted) {
                  for (var product in _bloc.listProductOrderAndUpdate) {
                    if (product.isMark == 1) {
                      bool isEditMode = (product.dsCKLineItem != null && product.dsCKLineItem.toString().trim().isNotEmpty) ||
                                       (product.giaSuaDoi != null && product.price != null && 
                                        product.giaSuaDoi! > 0 && product.price! > 0 && 
                                        product.giaSuaDoi != product.price);
                      if (isEditMode) {
                        //  DEBUG: Kiểm tra xem priceAfter có đúng không
                        if (product.priceAfter != null && product.price != null && product.price! > 0) {
                          double expectedDiscount = (product.price! - product.priceAfter!) * (product.count ?? 0);
                        }
                      }  
                    }
                  }
                  _bloc.add(CalculatorDiscountEvent(addOnProduct: false, reLoad: true, addTax: false));
                }
              });
            }
            
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
            
            // QUAN TRỌNG: Auto-restore và auto-apply discount trong edit mode
            // Chạy NGAY trong GetListProductFromDBSuccess thay vì đợi user click icon gift
            //  QUAN TRỌNG: Kiểm tra cả widget.listOrder (original order) và _bloc.listOrder (from DB)
            List<Product>? originalOrderList = widget.listOrder;
            bool hasOriginalOrder = originalOrderList != null && originalOrderList.isNotEmpty;
            bool hasBlocOrder = _bloc.listOrder.isNotEmpty;
            
            if(widget.viewUpdateOrder == true && (hasOriginalOrder || hasBlocOrder)){
              
              //  Restore CKG từ maCk trong listOrder
              //  QUAN TRỌNG: Dùng _bloc.listOrder (SearchItemResponseData) để có maCk và gifProduct
              // widget.listOrder là List<Product> không có maCk/gifProduct, chỉ có dsCKLineItem
              Set<String> restoredCkgIds = <String>{};
              
              // ✅ Use _bloc.listOrder (SearchItemResponseData) which has maCk and gifProduct fields
              // This is populated from API response and contains the original discount codes
              List<SearchItemResponseData> sourceList = _bloc.listOrder;
              
              // ✅ QUAN TRỌNG: Lưu TẤT CẢ discount từ lineItem TRƯỚC khi match (kể cả không hợp lệ)
              // Để validation có thể phát hiện discount không hợp lệ và hiển thị dialog
              List<String> allLineItemDiscounts = [];
              List<String> allLineItemPromotions = [];
              
              for (var product in sourceList) {
                String? productMaCk = product.maCk?.toString().trim();
                String? productSttRecCK = product.sttRecCK?.toString().trim();
                bool? isGiftProduct = product.gifProduct ?? false;
                
                // ✅ Lưu TẤT CẢ discount từ lineItem (kể cả không hợp lệ) để validation
                if (productMaCk != null && productMaCk.isNotEmpty && isGiftProduct != true) {
                  // Tạo discountKey từ sttRecCK hoặc maCk (nếu không có sttRecCK)
                  String discountKey = '';
                  if (productSttRecCK != null && productSttRecCK.isNotEmpty) {
                    discountKey = '$productSttRecCK-${product.code}';
                  } else if (productMaCk.isNotEmpty) {
                    // Nếu không có sttRecCK, dùng maCk để tạo key tạm (sẽ được validate sau)
                    discountKey = '$productMaCk-${product.code}';
                  }
                  
                  if (discountKey.isNotEmpty && !allLineItemDiscounts.contains(discountKey)) {
                    allLineItemDiscounts.add(discountKey);
                  }
                  
                  if (productMaCk.isNotEmpty && !allLineItemPromotions.contains(productMaCk)) {
                    allLineItemPromotions.add(productMaCk);
                  }
                }
              }
              
              // ✅ Lưu TẤT CẢ discount từ lineItem (kể cả không hợp lệ)
              _lineItemDiscounts = allLineItemDiscounts;
              _lineItemPromotions = allLineItemPromotions;
              
              // ✅ Bây giờ mới match và apply chỉ những discount hợp lệ
              for (var product in sourceList) {
                String? productMaCk = product.maCk?.toString().trim();
                bool? isGiftProduct = product.gifProduct ?? false; 
                
                if (productMaCk != null && productMaCk.isNotEmpty && isGiftProduct != true) {
                  // Parse multiple codes if comma-separated
                  List<String> productMaCkList = productMaCk.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  
                  for (var productMaCkItem in productMaCkList) {
                    bool found = false;
                    for (var ckgItem in _bloc.listCkg) {
                      String ckgMaCk = (ckgItem.maCk ?? '').trim();
                      
                      if (ckgMaCk == productMaCkItem && !restoredCkgIds.contains(ckgMaCk)) {
                        restoredCkgIds.add(ckgMaCk);
                        found = true;
                        break;
                      }
                    }
                    if (!found) {
                      print(' NO MATCH for maCk="$productMaCkItem" in listCkg (will be shown in dialog)');
                    }
                  }
                }
              }
              
              // Update selectedCkgIds
              
              if (restoredCkgIds.isNotEmpty) {
                _bloc.selectedCkgIds.addAll(restoredCkgIds);
                
                // Rebuild DataLocal.listCKVT và listPromotion (chỉ discount hợp lệ)
                List<String> ckvtList = [];
                List<String> promoList = [];
                
                for (var maCk in restoredCkgIds) {
                  // Tìm TẤT CẢ CKG items có cùng maCk (có thể áp dụng cho nhiều sản phẩm)
                  List<ListCk> ckgItems = _bloc.listCkg.where((ckg) =>
                    (ckg.maCk ?? '').trim() == maCk.trim()
                  ).toList();
                  
                  for (var ckgItem in ckgItems) {
                    String sttRecCk = (ckgItem.sttRecCk ?? '').trim();
                    String maVt = (ckgItem.maVt ?? '').trim();
                    String maCkValue = (ckgItem.maCk ?? '').trim();
                    
                    if (sttRecCk.isNotEmpty && maVt.isNotEmpty) {
                      // Add to listCKVT: format "sttRecCk-maVt"
                      String discountKey = '$sttRecCk-$maVt';
                      if (!ckvtList.contains(discountKey)) {
                        ckvtList.add(discountKey);
                      }

                      // QUAN TRỌNG: Add to listPromotion: maCk (mã chiết khấu), không phải sttRecCk
                      if (maCkValue.isNotEmpty && !promoList.contains(maCkValue)) {
                        promoList.add(maCkValue);
                      }
                    }
                  }
                }
                
                DataLocal.listCKVT = ckvtList.join(',');
                _bloc.listPromotion = promoList.join(',');

                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted && DataLocal.listCKVT.isNotEmpty) {
                    getDiscountProduct('Second');
                  } else {
                    // (trường hợp đã match discount nhưng không cần gọi API)
                    if (mounted && widget.viewUpdateOrder == true) {
                      print('💰 [EDIT MODE] No discount to apply, but recalculating totalPayment after match...');
                      _syncListOrderToUI();
                      _bloc.add(CalculatorDiscountEvent(addOnProduct: false, reLoad: true, addTax: false));
                    }
                  }
                });
              } else {
                print('No CKG discounts found in listOrder (all maCk are empty or null)');
              }
            } else {
              print(' Auto-restore skipped: viewUpdateOrder=${widget.viewUpdateOrder}, listOrder.isEmpty=${_bloc.listOrder.isEmpty}');
            }
            
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
            // ✅ Logic áp dụng chiết khấu tự do đã được di chuyển vào GetListProductFromDBSuccess handler
            // để đảm bảo chạy ngay sau khi load từ database, không phụ thuộc vào keyLoad
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
          _autoSaveDraft();
          if(_bloc.customerName.toString().trim() != 'null' && _bloc.customerName.toString().trim().isNotEmpty){
            nameCustomerController.text = _bloc.customerName.toString();
            phoneCustomerController.text = _bloc.phoneCustomer.toString();
            addressCustomerController.text = _bloc.addressCustomer.toString();
            _bloc.listDiscount.clear();
            
            int manualDiscountCount = 0;
            for (var item in _bloc.listOrder) {
              if (item.discountByHand == true && (item.discountPercentByHand ?? 0) > 0) {
                manualDiscountCount++;
              }
            }
            
            int manualDiscountCountDB = 0;
            for (var element in _bloc.listProductOrderAndUpdate) {
              if (element.discountByHand == 1 && (element.discountPercentByHand ?? 0) > 0) {
                manualDiscountCountDB++;
              }
            }
            
            // ✅ QUAN TRỌNG: Update listProductOrderAndUpdate với chiết khấu nhập tay từ listOrder
            // Tương tự như khi restore draft, đảm bảo chiết khấu nhập tay được preserve
            // khi gọi getDiscountProduct('First')
            for (var item in _bloc.listOrder) {
              if (item.discountByHand == true && (item.discountPercentByHand ?? 0) > 0 && item.code != null) {
                // Tìm sản phẩm tương ứng trong listProductOrderAndUpdate
                for (var element in _bloc.listProductOrderAndUpdate) {
                  if (element.code != null && element.code.toString().trim() == item.code!.trim()) {
                    // Update chiết khấu nhập tay vào database
                    element.discountByHand = 1;
                    element.discountPercentByHand = item.discountPercentByHand;
                    element.ckntByHand = item.ckntByHand ?? 0;
                    element.priceAfter = item.priceAfter;
                    break;
                  }
                }
              }
            }
            
            getDiscountProduct('First');
          }
        }
        else if(state is CreateOrderSuccess){
          _isProcessing = false; // Reset flag khi thành công
          
          // ✅ QUAN TRỌNG: Đánh dấu đã đặt đơn thành công (ngăn không cho save draft sau đó)
          _orderCreatedSuccessfully = true;
          
          // ✅ QUAN TRỌNG: Làm sạch toàn bộ dữ liệu đơn hàng
          _clearAllOrderData();
          
          // ✅ QUAN TRỌNG: Xóa draft ngay sau khi đặt đơn thành công
          // Vì đơn đã được tạo thành công, không cần giữ draft nữa
          CartDraftStorage.clearDraft().then((_) {
            print('💾 ✅ Draft đã được xóa sau khi đặt đơn thành công');
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
            print('💾 ✅ Draft đã được xóa sau khi đặt đơn thành công (CheckIn)');
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
            _persistGiftProducts();
            Const.listKeyGroupCheck = '';
            Const.listKeyGroup = '';
            if (_bloc.listOrder.isEmpty && DataLocal.listProductGift.isEmpty) {
              CartDraftStorage.clearDraft();
              // Clear thông tin khách hàng
              _bloc.customerName = null;
              _bloc.codeCustomer = null;
              _bloc.phoneCustomer = null;
              _bloc.addressCustomer = null;
              DataLocal.infoCustomer = ManagerCustomerResponseData();
              nameCustomerController.clear();
              phoneCustomerController.clear();
              addressCustomerController.clear();
              print('💾 ✅ Draft và thông tin khách hàng đã được xóa (manual delete)');
            }
          } else {
            print('💾 ⚠️ Skip clear in DeleteAllProductFromDBSuccess: Order already created successfully, data already cleared');
          }
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
              if(value != null && value.isNotEmpty && double.parse(value[0].toString()) > 0){
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
        else if(state is AddOrDeleteProductGiftSuccess){
          // Refresh UI when gift products are added/removed
          setState(() {});
          // ✅ Tự động lưu draft sau khi thêm/xóa sản phẩm tặng
          // Delay một chút để đảm bảo DataLocal.listProductGift đã được cập nhật
          Future.microtask(() {
            _autoSaveDraft();
          });
        }
        else if(state is GetGiftProductListSuccess){
          // ✅ Ẩn loading dialog
          _hideLoadingDialog();
          
          // API đã trả về danh sách hàng tặng, show popup step 2
          if(_pendingDiscountName != null && _pendingMaxQuantity != null && _pendingDiscountItems != null){
            final pendingType = _pendingDiscountType ?? 'CKN';
            final String? pendingGroupKey = pendingType == 'CKN'
                ? _pendingCknGroupKey
                : _pendingCktdthGroupKey;
            _showGiftProductSelectionPopup(
              discountName: _pendingDiscountName!,
              maxQuantity: _pendingMaxQuantity!,
              discountItems: _pendingDiscountItems!,
              discountType: pendingType, // Default to CKN for backward compatibility
              groupKey: pendingGroupKey,
            );
            // Clear pending state
            _pendingDiscountName = null;
            _pendingMaxQuantity = null;
            _pendingDiscountItems = null;
            _pendingDiscountType = null;
            if (pendingType == 'CKN') {
              _pendingCknGroupKey = null;
            } else if (pendingType == 'CKTDTH') {
              _pendingCktdthGroupKey = null;
            }
          }
        }
        else if(state is CartFailure){
          // ✅ Ẩn loading dialog khi có lỗi (nếu đang loading)
          _hideLoadingDialog();
          if (_pendingDiscountType != null) {
            final pendingType = _pendingDiscountType!;
            final String? pendingGroupKey = pendingType == 'CKN'
                ? _pendingCknGroupKey
                : _pendingCktdthGroupKey;
            if (pendingGroupKey != null) {
              _handleGiftSelectionCancelled(pendingType, pendingGroupKey, showToast: false);
            }
            _pendingDiscountType = null;
            if (pendingType == 'CKN') {
              _pendingCknGroupKey = null;
            } else if (pendingType == 'CKTDTH') {
              _pendingCktdthGroupKey = null;
            }
            _pendingDiscountName = null;
            _pendingMaxQuantity = null;
            _pendingDiscountItems = null;
          }
        }
      },
      bloc: _bloc,
      child: BlocBuilder<CartBloc,CartState>(
        bloc: _bloc,
        builder: (BuildContext context,CartState state){
          return PopScope(
            canPop: false, // Ngăn pop tự động, sẽ pop thủ công sau khi lưu xong
            onPopInvoked: (didPop) {
              if (!didPop) {
                // ✅ Lưu draft khi user back ra khỏi màn hình tạo đơn mới (nếu có dữ liệu)
                // Sử dụng WidgetsBinding để đảm bảo context còn available
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _saveDraftWithDialog();
                  } else {
                    print('🔙 Context not mounted, cannot show dialog');
                  }
                });
              }
            },
            child: Stack(
              children: [
                buildScreen(context, state),
              Visibility(
                visible: state is CartLoading,
                child: const PendingAction(),
              ),
            ],
          ),
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
          CartAppBar(
            bloc: _bloc,
            viewUpdateOrder: widget.viewUpdateOrder,
            nameCustomer: widget.nameCustomer,
            isContractCreateOrder: widget.isContractCreateOrder,
            contractMaster: widget.contractMaster,
            viewDetail: widget.viewDetail,
            orderFromCheckIn: widget.orderFromCheckIn,
            codeCustomer: widget.codeCustomer,
            currencyCode: widget.currencyCode,
            listIdGroupProduct: widget.listIdGroupProduct,
            itemGroupCode: widget.itemGroupCode,
            onBackPressed: () {
              // ✅ Gọi _saveDraftWithDialog() khi user nhấn nút back
              _saveDraftWithDialog();
            },
          ),
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
                            children: [
                              CartProductTab(
                                bloc: _bloc,
                                onShowDiscountFlow: () => _showDiscountFlow(),
                                onAddAllHDVV: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isDismissible: true,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25.0),
                                        topRight: Radius.circular(25.0),
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    builder: (builder) => buildPopupVvHd(),
                                  ).then((value) {
                                    if (value != null) {
                                      if (value[0] == 'ReLoad' &&
                                          value[1] != '' &&
                                          value[1] != 'null') {
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
                                },
                                onAddDiscountForAll: () {
                                  _bloc.add(AddDiscountForProductEvent(discountValues: 0));
                                },
                                onDeleteAll: () {
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
                                  DataLocal.noteSell = '';
                                  DataLocal.listCKVT = '';
                                  _bloc.selectedCknProductCode = null;
                                  _bloc.selectedCknSttRecCk = null;
                                  _bloc.listCkn.clear();
                                  _bloc.hasCknDiscount = false;
                                  _bloc.add(DeleteAllProductEvent());
                                },
                                onEditProduct: (index) {
                                  if (widget.isContractCreateOrder == true) {
                                    // Contract logic placeholder
                                  } else {
                                    gift = false;
                                    indexSelect = index;
                                    itemSelect = _bloc.listOrder[index];
                                    _bloc.add(GetListStockEvent(
                                      itemCode: _bloc.listOrder[index].code.toString(),
                                      getListGroup: false,
                                      lockInputToCart: false,
                                      checkStockEmployee: Const.checkStockEmployee == true ? true : false,
                                    ));
                                  }
                                },
                                onDeleteProduct: (index) {
                                  itemSelect = _bloc.listOrder[index];
                                  if (DataLocal.listCKVT.isNotEmpty) {
                                    String productCode = itemSelect.code.toString().trim();
                                    List<String> ckList = DataLocal.listCKVT
                                        .split(',')
                                        .where((s) => s.isNotEmpty)
                                        .toList();
                                    ckList.removeWhere((item) => item.endsWith('-$productCode'));
                                    DataLocal.listCKVT = ckList.join(',');
                                    // ✅ CHANGED: Remove maCk nếu không còn product nào trong cart có CKG với maCk đó
                                    // Tìm maCk của CKG items có productCode bị xóa
                                    Set<String> maCksToRemove = {};
                                    for (var ckg in _bloc.listCkg) {
                                      if ((ckg.maVt ?? '').trim() == productCode) {
                                        String maCk = (ckg.maCk ?? '').trim();
                                        if (maCk.isNotEmpty) {
                                          // Check xem còn product nào khác trong cart có CKG với maCk này không
                                          // (không tính product đang bị xóa)
                                          bool hasOtherProduct = false;
                                          for (var cartItem in _bloc.listOrder) {
                                            // Skip product đang bị xóa (itemSelect)
                                            if (cartItem.sttRec0 == itemSelect.sttRec0) continue;
                                            if (cartItem.gifProduct == true) continue;
                                            
                                            String cartItemCode = (cartItem.code ?? '').trim();
                                            // Check xem có CKG item nào với maCk này và product này không
                                            for (var otherCkg in _bloc.listCkg) {
                                              if ((otherCkg.maCk ?? '').trim() == maCk && 
                                                  (otherCkg.maVt ?? '').trim() == cartItemCode) {
                                                hasOtherProduct = true;
                                                break;
                                              }
                                            }
                                            if (hasOtherProduct) break;
                                          }
                                          if (!hasOtherProduct) {
                                            maCksToRemove.add(maCk);
                                          }
                                        }
                                      }
                                    }
                                    _bloc.selectedCkgIds.removeAll(maCksToRemove);
                                  }
                                  // ✅ FIX: Chỉ gọi DeleteProductFromDB, không cần gọi GetListProductFromDB
                                  // Vì _deleteProductFromDB trong cart_bloc đã tự động gọi GetListProductFromDB rồi (dòng 1681)
                                  _bloc.add(DeleteProductFromDB(
                                    false,
                                    index,
                                    _bloc.listOrder[index].code.toString(),
                                    _bloc.listOrder[index].stockCode.toString(),
                                  ));
                                  // _bloc.add(GetListProductFromDB(addOrderFromCheckIn: false, getValuesTax: false, key: '')); // ❌ REMOVED: Bị gọi 2 lần
                                },
                                onApplyVVHD: (index) {
                                  showModalBottomSheet(
                                    context: context,
                                    isDismissible: true,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25.0),
                                        topRight: Radius.circular(25.0),
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    builder: (builder) => buildPopupVvHd(),
                                  ).then((value) {
                                    if (value != null) {
                                      if (value[0] == 'ReLoad' &&
                                          value[1] != '' &&
                                          value[1] != 'null') {
                                        _bloc.listOrder[index].chooseVuViec = true;
                                        _bloc.listOrder[index].idVv = _bloc.idVv;
                                        _bloc.listOrder[index].nameVv = _bloc.nameVv;
                                        _bloc.listOrder[index].idHd = _bloc.idHd;
                                        _bloc.listOrder[index].nameHd = _bloc.nameHd;
                                        _bloc.listOrder[index].idHdForVv = _bloc.idHdForVv;
                                        _bloc.add(CalculatorDiscountEvent(
                                            addOnProduct: true,
                                            product: _bloc.listOrder[index],
                                            reLoad: false,
                                            addTax: false));
                                      } else {
                                        _bloc.listOrder[index].chooseVuViec = false;
                                      }
                                    } else {
                                      _bloc.listOrder[index].chooseVuViec = false;
                                    }
                                  });
                                },
                                onApplyManualDiscount: (index, value) {
                                  CartDiscountHelper.applyManualDiscountForItem(
                                    bloc: _bloc,
                                    index: index,
                                    percent: value,
                                    context: context,
                                    setState: (fn) => setState(fn),
                                  );
                                },
                                buildProductItem: (context, index) => _buildSingleProductItem(index),
                                buildGiftItem: (context, index) => _buildSingleGiftItem(index),
                                onAddGiftProduct: () {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: SearchProductScreen(
                                      idCustomer: widget.codeCustomer.toString(),
                                      currency: widget.currencyCode,
                                      viewUpdateOrder: false,
                                      listIdGroupProduct: widget.listIdGroupProduct,
                                      itemGroupCode: '', // Salonzo bỏ tìm theo nhóm mặt hàng khi thêm hàng tặng, cho phép tìm được tất cả sản phẩm
                                      inventoryControl: false,
                                      addProductFromCheckIn: false,
                                      addProductFromSaleOut: false,
                                      giftProductRe: true,
                                      lockInputToCart: true,
                                      checkStockEmployee: Const.checkStockEmployee,
                                      listOrder: _bloc.listProductOrderAndUpdate,
                                      backValues: false,
                                      isCheckStock: false,
                                    ),
                                    withNavBar: false,
                                  ).then((value) {
                                    if (value != null && value.isNotEmpty && value[0] == 'Yeah') {
                                      SearchItemResponseData item = value[1] as SearchItemResponseData;
                                      item.gifProductByHand = true;
                                      if (Const.enableViewPriceAndTotalPriceProductGift != true) {
                                        item.price = 0;
                                        item.priceAfter = 0;
                                      }
                                      _bloc.totalProductGift += item.count!;
                                      _bloc.add(AddOrDeleteProductGiftEvent(true, item));
                                    }
                                  });
                                },
                              ),
                              CartCustomerTab(
                                bloc: _bloc,
                                buildInfoCallOtherPeople: () => buildInfoCallOtherPeople(),
                                transactionWidget: () => transactionWidget(),
                                typeOrderWidget: () => typeOrderWidget(),
                                genderWidget: () => genderWidget(),
                                genderTaxWidget: () => genderTaxWidget(),
                                typePaymentWidget: () => typePaymentWidget(),
                                typeDeliveryWidget: () => typeDeliveryWidget(),
                                buildPopupVvHd: () => buildPopupVvHd(),
                                maGD: maGD,
                                onStateChanged: () => setState(() {}),
                              ),
                              CartBillTab(
                                bloc: _bloc,
                                listItem: listItem,
                                listQty: listQty,
                                listPrice: listPrice,
                                listMoney: listMoney,
                                codeStore: codeStore,
                                onVoucherTap: () {},
                                buildOtherRequest: () => buildOtherRequest(),
                                customWidgetPayment: (title, subtitle, discount, codeDiscount) =>
                                    customWidgetPayment(title, subtitle, discount, codeDiscount),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  CartBottomTotal(
                    bloc: _bloc,
                    tabController: tabController,
                    viewUpdateOrder: widget.viewUpdateOrder,
                    onNextPressed: () {
                              if(tabController.index == 0 || tabController.index == 1){
                                Future.delayed(const Duration(milliseconds: 200)).then((value)=>tabController.animateTo((tabController.index + 1) % 10));
                                tabIndex = tabController.index + 1;
                      }
                    },
                    onCreateOrderPressed: () {
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
                    },
                    isProcessing: _isProcessing,
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
      return;
    }
    
    _isProcessing = true;
    
    // Tự động reset flag sau 1 giây để tránh trường hợp bị kẹt
    Timer(const Duration(seconds: 1), () {
      if (_isProcessing) {
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
    final handler = CartOrderHandler(
      context: context,
      bloc: _bloc,
      viewUpdateOrder: widget.viewUpdateOrder,
      sttRec: widget.sttRec,
      currencyCode: widget.currencyCode,
      dateOrder: widget.dateOrder,
      isContractCreateOrder: widget.isContractCreateOrder,
      sttRectHD: widget.sttRectHD,
      // Fallback info nếu bloc mất khách hàng trước khi đặt đơn
      fallbackCodeCustomer: widget.codeCustomer ?? DataLocal.infoCustomer.customerCode,
      fallbackNameCustomer: widget.nameCustomer ?? DataLocal.infoCustomer.customerName,
      fallbackPhoneCustomer: widget.phoneCustomer ?? DataLocal.infoCustomer.phone,
      fallbackAddressCustomer: widget.addressCustomer ?? DataLocal.infoCustomer.address,
      nameCompanyController: nameCompanyController,
      mstController: mstController,
      addressCompanyController: addressCompanyController,
      noteCompanyController: noteCompanyController,
      noteController: noteController,
    );
    handler.createOrder();
    // Sau khi tạo đơn mới thành công, nên clear draft để tránh restore nhầm
    CartDraftStorage.clearDraft();
    _isProcessing = false; // Reset flag after order creation
  }

  int tabIndex = 0;

  // Helper methods to build single items for CartProductList
  Widget _buildSingleProductItem(int index) {
    return CartProductItemWidget(
      index: index,
      bloc: _bloc,
      isContractCreateOrder: widget.isContractCreateOrder ?? false,
      orderFromCheckIn: widget.orderFromCheckIn,
      buildPopupVvHd: () => buildPopupVvHd(),
      onApplyManualDiscount: (index, percent) => CartDiscountHelper.applyManualDiscountForItem(
        bloc: _bloc,
        index: index,
        percent: percent,
        context: context,
        setState: (fn) => setState(fn),
      ),
      formatTaxRate: (taxRate) => CartHelperWidgets.formatTaxRate(taxRate),
      onProductStateChanged: (isGift, indexSelected, itemSelected) {
        gift = isGift;
        indexSelect = indexSelected;
        itemSelect = itemSelected;
      },
    );
  }

  Widget _buildSingleGiftItem(int index) {
    return CartGiftItemWidget(
      index: index,
      bloc: _bloc,
      currencyCode: widget.currencyCode,
      buildPopupVvHd: () => buildPopupVvHd(),
      onGiftStateChanged: (isGift, indexSelected) {
        gift = isGift;
        indexSelectGift = indexSelected;
      },
    );
  }


  buildPopupVvHd(){
    return CartPopupVvHd(
      bloc: _bloc,
      onApply: (idVv, nameVv, idHd, nameHd, idHdForVv) {
        // Callback được xử lý trong widget
      },
    );
  }

  // Main discount flow - Show voucher selection bottom sheet (E-commerce style)
  void _showDiscountFlow() async {
    // ❗️Không gọi API khi chỉ mở sheet – chỉ upload khi user nhấn "Áp dụng"
    
    // ✅ RESTORE selectedCkgIds, selectedHHIds, selectedCktdttIds, selectedCknGroups, selectedCktdthGroups từ ma_ck trong listOrder (khi sửa đơn từ chi tiết)
    // Chỉ restore nếu chưa có selection (tránh overwrite khi user đã chọn)
    // ✅ QUAN TRỌNG: Chỉ restore SAU KHI API đã trả về danh sách chiết khấu (listCkg, listHH, listCktdtt, listCkn, listCktdth không rỗng)
    if (widget.viewUpdateOrder == true && _bloc.listOrder.isNotEmpty) {
      bool needRestoreCkg = _bloc.selectedCkgIds.isEmpty;
      bool needRestoreHH = _bloc.selectedHHIds.isEmpty;
      bool needRestoreCktdtt = _bloc.selectedCktdttIds.isEmpty;
      bool needRestoreCkn = _bloc.selectedCknGroups.isEmpty;
      bool needRestoreCktdth = _bloc.selectedCktdthGroups.isEmpty;
      
      // ✅ Kiểm tra API đã trả về danh sách chiết khấu chưa
      bool hasDiscountData = _bloc.listCkg.isNotEmpty || _bloc.listHH.isNotEmpty || 
                             _bloc.listCktdtt.isNotEmpty || _bloc.listCkn.isNotEmpty || 
                             _bloc.listCktdth.isNotEmpty;
      
      if ((needRestoreCkg || needRestoreHH || needRestoreCktdtt || needRestoreCkn || needRestoreCktdth) && hasDiscountData) {
        print('💰 Restoring discount selections from listOrder ma_ck and DataLocal.listProductGift...');
        print('💰   - listCkg.length: ${_bloc.listCkg.length}');
        print('💰   - listHH.length: ${_bloc.listHH.length}');
        print('💰   - listCktdtt.length: ${_bloc.listCktdtt.length}');
        print('💰   - listCkn.length: ${_bloc.listCkn.length}');
        print('💰   - listCktdth.length: ${_bloc.listCktdth.length}');
        
        Set<String> restoredCkgIds = <String>{};
        Set<String> restoredHHIds = <String>{};
        Set<String> restoredCktdttIds = <String>{};
        Set<String> restoredCknGroups = <String>{};
        Set<String> restoredCktdthGroups = <String>{};
        
        // ✅ Debug: Log thông tin để kiểm tra
        print('💰 Debug restore - listOrder.length: ${_bloc.listOrder.length}');
        print('💰 Debug restore - DataLocal.listProductGift.length: ${DataLocal.listProductGift.length}');
        
        // ✅ Debug: Log thông tin listOrder và listCkg để kiểm tra
        print('💰 Debug: Checking ${_bloc.listOrder.length} products in listOrder for CKG restore...');
        for (var product in _bloc.listOrder) {
          // ✅ maCk có thể là chuỗi đơn hoặc dsCKLineItem (nhiều mã cách nhau dấu phẩy)
          String? productMaCk = product.maCk?.toString().trim();
          bool hasMaCk = productMaCk != null && productMaCk.isNotEmpty;
          
          print('💰 Debug: Product ${product.code} - maCk=$productMaCk, gifProduct=${product.gifProduct}, hasMaCk=$hasMaCk');
          
          if (hasMaCk && product.gifProduct != true) {
            // ✅ Check CKG (chỉ restore nếu chưa có selection và listCkg đã có dữ liệu)
            if (needRestoreCkg && _bloc.listCkg.isNotEmpty) {
              // ✅ Parse dsCKLineItem nếu có nhiều mã (cách nhau dấu phẩy)
              List<String> productMaCkList = productMaCk!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              
              print('💰 Debug CKG: Checking ${_bloc.listCkg.length} CKG items for maCk(s)=$productMaCkList...');
              
              for (var productMaCkItem in productMaCkList) {
                for (var ckgItem in _bloc.listCkg) {
                  String ckgMaCk = (ckgItem.maCk ?? '').trim();
                  print('💰 Debug CKG: Comparing product.maCk="$productMaCkItem" with ckgItem.maCk="$ckgMaCk" (equal: ${ckgMaCk == productMaCkItem})');
                  
                  if (ckgMaCk == productMaCkItem) {
                    // ✅ Chỉ add nếu chưa có (tránh duplicate)
                    if (!restoredCkgIds.contains(ckgMaCk)) {
                      restoredCkgIds.add(ckgMaCk);
                      print('💰 ✅ Found CKG match: maCk=$ckgMaCk, product=${product.code}, tenCk=${ckgItem.tenCk}');
                    }
                    break; // Đã match, không cần check tiếp
                  }
                }
              }
            }
          }
        }
        
        // ✅ Check HH (gift products) - từ DataLocal.listProductGift (chỉ restore nếu listHH đã có dữ liệu)
        // HH là gift products, có thể có typeCK == 'HH' hoặc typeCK == '' (gifts từ lineItem với km_yn = 1)
        // Match theo maCk VÀ maVt (giống CKG)
        if (needRestoreHH && _bloc.listHH.isNotEmpty) {
          print('💰 Debug HH: Checking ${DataLocal.listProductGift.length} gifts, ${_bloc.listHH.length} HH items...');
          
          // ✅ Duyệt qua TẤT CẢ gifts (không chỉ typeCK == 'HH')
          // Vì gifts từ lineItem có typeCK == '' nhưng vẫn có thể là HH gifts
          for (var gift in DataLocal.listProductGift) {
            print('💰 Debug HH: Gift ${gift.code} - typeCK=${gift.typeCK}, sttRec0=${gift.sttRec0}, name=${gift.name}');
            
            // ✅ LOGIC RÕ RÀNG:
            // 1. Nếu maCk = rỗng hoặc null → KHÔNG RESTORE (gift sẽ được giữ lại bởi logic validate)
            // 2. Nếu maCk có, match được với listHH → RESTORE
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
                bool matchByMaCkAndMaVt = hhMaCk.isNotEmpty && hhMaCk == giftMaCk &&
                                         hhMaVt.isNotEmpty && hhMaVt == giftCode;
                
                print('💰 Debug HH: Comparing gift.maCk="$giftMaCk", gift.code="$giftCode" with hhItem.maCk="$hhMaCk", hhItem.maVt="$hhMaVt" (match: $matchByMaCkAndMaVt)');
                
                if (matchByMaCkAndMaVt) {
                  restoredHHIds.add(hhId);
                  print('💰 ✅ Found HH match: hhId=$hhId, gift=${gift.code}, tenVt=${hhItem.tenVt} (matched by maCk="$giftMaCk" and maVt="$giftCode")');
                  break; // Chỉ match 1 HH item cho mỗi gift
                }
              }
            }
          }
        }
        
        // ✅ Check CKTDTT từ totalDiscountForOder hoặc codeDiscountTD/sttRecCKOld (chỉ restore nếu listCktdtt đã có dữ liệu)
        // ✅ QUAN TRỌNG: Restore CKTDTT nếu có totalDiscountForOder > 0 HOẶC có codeDiscountTD
        if (needRestoreCktdtt && _bloc.listCktdtt.isNotEmpty) {
          bool hasCktdttDiscount = (_bloc.totalDiscountForOder != null && _bloc.totalDiscountForOder! > 0) ||
                                   (_bloc.codeDiscountTD != null && _bloc.codeDiscountTD!.isNotEmpty);
          
          if (hasCktdttDiscount) {
            print('💰 Restoring CKTDTT: totalDiscountForOder=${_bloc.totalDiscountForOder}, codeDiscountTD=${_bloc.codeDiscountTD}, sttRecCKOld=${_bloc.sttRecCKOld}');
            
            for (var cktdttItem in _bloc.listCktdtt) {
              String cktdttSttRecCk = (cktdttItem.sttRecCk ?? '').trim();
              String cktdttMaCk = (cktdttItem.maCk ?? '').trim();
              
              // ✅ Match bằng sttRecCk hoặc maCk (codeDiscountTD)
              bool matchBySttRecCk = _bloc.sttRecCKOld != null && 
                                      _bloc.sttRecCKOld!.trim().isNotEmpty &&
                                      _bloc.sttRecCKOld!.trim() == cktdttSttRecCk;
              bool matchByMaCk = _bloc.codeDiscountTD != null && 
                                 _bloc.codeDiscountTD!.trim().isNotEmpty &&
                                 _bloc.codeDiscountTD!.trim() == cktdttMaCk;
              
              if (matchBySttRecCk || matchByMaCk) {
                restoredCktdttIds.add(cktdttSttRecCk);
                print('💰 ✅ Found CKTDTT match: sttRecCk=$cktdttSttRecCk, maCk=$cktdttMaCk (matched by ${matchBySttRecCk ? "sttRecCk" : "maCk"})');
                break;
              }
            }
            
            // ✅ Nếu không match được nhưng có totalDiscountForOder > 0, vẫn restore CKTDTT đầu tiên (fallback)
            if (restoredCktdttIds.isEmpty && _bloc.totalDiscountForOder != null && _bloc.totalDiscountForOder! > 0 && _bloc.listCktdtt.isNotEmpty) {
              String firstCktdttSttRecCk = (_bloc.listCktdtt.first.sttRecCk ?? '').trim();
              if (firstCktdttSttRecCk.isNotEmpty) {
                restoredCktdttIds.add(firstCktdttSttRecCk);
                print('💰 ⚠️ CKTDTT: No exact match found, restoring first CKTDTT as fallback: sttRecCk=$firstCktdttSttRecCk');
              }
            }
          }
        }
        
        // ✅ Check CKN và CKTDTH từ DataLocal.listProductGift (chỉ restore nếu list đã có dữ liệu)
        if (needRestoreCkn && _bloc.listCkn.isNotEmpty) {
          for (var gift in DataLocal.listProductGift) {
            if (gift.typeCK == 'CKN') {
              // ✅ FIX: Luôn dùng group_dk làm groupKey (giống sheet), fallback về sttRecCk
              String? groupKey;
              
              // Tìm trong listCkn bằng code (maHangTang) để lấy group_dk
              for (var cknItem in _bloc.listCkn) {
                if (cknItem.maHangTang?.trim() == gift.code?.trim()) {
                  // Ưu tiên group_dk, fallback về sttRecCk
                  groupKey = (cknItem.group_dk?.toString().trim() ?? cknItem.sttRecCk?.toString().trim());
                  break;
                }
              }
              
              // Nếu không tìm thấy bằng code, thử match bằng sttRecCK
              if (groupKey == null || groupKey.isEmpty) {
                String? giftSttRecCK = gift.sttRecCK?.trim();
                if (giftSttRecCK != null && giftSttRecCK.isNotEmpty) {
                  for (var cknItem in _bloc.listCkn) {
                    String cknSttRecCk = (cknItem.sttRecCk ?? '').trim();
                    if (cknSttRecCk == giftSttRecCK) {
                      // Ưu tiên group_dk, fallback về sttRecCk
                      groupKey = (cknItem.group_dk?.toString().trim() ?? cknSttRecCk);
                      break;
                    }
                  }
                }
              }
              
              if (groupKey != null && groupKey.isNotEmpty) {
                restoredCknGroups.add(groupKey);
                print('💰 Found CKN match: groupKey=$groupKey, gift=${gift.code}');
              }
            }
          }
        }
        
        if (needRestoreCktdth && _bloc.listCktdth.isNotEmpty) {
          for (var gift in DataLocal.listProductGift) {
            if (gift.typeCK == 'CKTDTH') {
              // ✅ FIX: Luôn dùng group_dk làm groupKey (giống sheet), fallback về sttRecCk
              String? groupKey;
              
              // Tìm trong listCktdth bằng code (maHangTang) để lấy group_dk
              for (var cktdthItem in _bloc.listCktdth) {
                if (cktdthItem.maHangTang?.trim() == gift.code?.trim()) {
                  // Ưu tiên group_dk, fallback về sttRecCk
                  groupKey = (cktdthItem.group_dk?.toString().trim() ?? cktdthItem.sttRecCk?.toString().trim());
                  break;
                }
              }
              
              // Nếu không tìm thấy bằng code, thử match bằng sttRecCK
              if (groupKey == null || groupKey.isEmpty) {
                String? giftSttRecCK = gift.sttRecCK?.trim();
                if (giftSttRecCK != null && giftSttRecCK.isNotEmpty) {
                  for (var cktdthItem in _bloc.listCktdth) {
                    String cktdthSttRecCk = (cktdthItem.sttRecCk ?? '').trim();
                    if (cktdthSttRecCk == giftSttRecCK) {
                      // Ưu tiên group_dk, fallback về sttRecCk
                      groupKey = (cktdthItem.group_dk?.toString().trim() ?? cktdthSttRecCk);
                      break;
                    }
                  }
                }
              }
              
              if (groupKey != null && groupKey.isNotEmpty) {
                restoredCktdthGroups.add(groupKey);
                print('💰 Found CKTDTH match: groupKey=$groupKey, gift=${gift.code}');
              }
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
        if (restoredCknGroups.isNotEmpty) {
          _bloc.selectedCknGroups.addAll(restoredCknGroups);
          print('💰 Restored selectedCknGroups: ${_bloc.selectedCknGroups}');
        }
        if (restoredCktdthGroups.isNotEmpty) {
          _bloc.selectedCktdthGroups.addAll(restoredCktdthGroups);
          print('💰 Restored selectedCktdthGroups: ${_bloc.selectedCktdthGroups}');
        }
        
        if (restoredCkgIds.isEmpty && restoredHHIds.isEmpty && restoredCktdttIds.isEmpty && 
            restoredCknGroups.isEmpty && restoredCktdthGroups.isEmpty) {
          print('💰 No discounts found in listOrder to restore');
        } else {
          // ✅ Force rebuild sheet sau khi restore để checkbox được check
          print('💰 Restore completed, will rebuild sheet with restored selections');
          print('💰   - Restored CKG: ${restoredCkgIds.length}');
          print('💰   - Restored HH: ${restoredHHIds.length}');
          print('💰   - Restored CKTDTT: ${restoredCktdttIds.length}');
          print('💰   - Restored CKN: ${restoredCknGroups.length}');
          print('💰   - Restored CKTDTH: ${restoredCktdthGroups.length}');
          
          // ✅ QUAN TRỌNG: Rebuild DataLocal.listCKVT từ selectedCkgIds để API có dữ liệu
          if (restoredCkgIds.isNotEmpty) {
            List<String> ckvtList = [];
            for (var maCk in restoredCkgIds) {
              var ckgItem = _bloc.listCkg.firstWhere((item) => (item.maCk ?? '').trim() == maCk);
              String sttRecCk = (ckgItem.sttRecCk ?? '').trim();
              String maVt = (ckgItem.maVt ?? '').trim();
              if (sttRecCk.isNotEmpty && maVt.isNotEmpty) {
                ckvtList.add('$sttRecCk-$maVt');
              }
            }
            DataLocal.listCKVT = ckvtList.join(',');
            print('💰 Rebuilt DataLocal.listCKVT: ${DataLocal.listCKVT}');
          }
          
          // ✅ Rebuild listPromotion từ selectedCktdttIds
          if (restoredCktdttIds.isNotEmpty) {
            List<String> promoList = [];
            for (var maCk in restoredCktdttIds) {
              var cktdttItem = _bloc.listCktdtt.firstWhere((item) => (item.maCk ?? '').trim() == maCk);
              String sttRecCk = (cktdttItem.sttRecCk ?? '').trim();
              if (sttRecCk.isNotEmpty) {
                promoList.add(sttRecCk);
              }
            }
            _bloc.listPromotion = promoList.join(',');
            print('💰 Rebuilt listPromotion: ${_bloc.listPromotion}');
          }
          
          // ✅ KHÔNG set flag ở đây nữa
          // Logic auto-apply đã được di chuyển vào GetListProductFromDBSuccess
        }
      } else if (!hasDiscountData) {
        print('💰 Discount API data not ready yet, skipping restore (will retry when sheet opens again)');
      } else {
        print('💰 Discount selections already exist, skipping restore');
      }
    }
    
    // ✅ QUAN TRỌNG: Lưu state ban đầu SAU KHI restore (để detect thay đổi chính xác)
    // Nếu lưu trước khi restore, khi restore xong rồi bỏ tích, cả 2 đều rỗng → không detect được thay đổi
    _initialSelectedCkgIds = Set.from(_bloc.selectedCkgIds);
    _initialSelectedCktdttIds = Set.from(_bloc.selectedCktdttIds);
    _initialSelectedHHIds = Set.from(_bloc.selectedHHIds);
    _initialListCKVT = DataLocal.listCKVT;
    _initialListPromotion = _bloc.listPromotion;
    print('💰 Saving initial discount state (AFTER restore):');
    print('💰   - initialSelectedCkgIds: $_initialSelectedCkgIds');
    print('💰   - initialSelectedCktdttIds: $_initialSelectedCktdttIds');
    print('💰   - initialSelectedHHIds: $_initialSelectedHHIds');
    print('💰   - initialListCKVT: $_initialListCKVT');
    print('💰   - initialListPromotion: $_initialListPromotion');
    
    _discountSheetKey = GlobalKey<DiscountVoucherSelectionSheetState>();
    
    // ✅ Debug: Log selected discount IDs trước khi mở sheet
    print('💰 Opening discount sheet with:');
    print('💰   - selectedCkgIds: ${_bloc.selectedCkgIds}');
    print('💰   - selectedHHIds: ${_bloc.selectedHHIds}');
    print('💰   - selectedCktdttIds: ${_bloc.selectedCktdttIds}');
    print('💰   - selectedCknGroups: ${_bloc.selectedCknGroups}');
    print('💰   - selectedCktdthGroups: ${_bloc.selectedCktdthGroups}');
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

    _discountSheetKey = null;

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

    // ✅ QUAN TRỌNG: Rebuild listCKVT và listPromotion từ selectedCkgIds và selectedCktdttIds
    // Đảm bảo API nhận được đúng state hiện tại (không phải state cũ)
    // Clear trước
    DataLocal.listCKVT = '';
    _bloc.listPromotion = '';
    
    // ✅ Rebuild listCKVT từ selectedCkgIds
    List<String> ckvtList = [];
    List<String> promoList = [];
    
    for (String maCk in selectedCkgIds) {
      // Tìm CKG items có cùng maCk
      List<ListCk> ckgItems = _bloc.listCkg.where((ckg) => 
        (ckg.maCk ?? '').trim() == maCk.trim()
      ).toList();
      
      for (var ckgItem in ckgItems) {
        String sttRecCk = (ckgItem.sttRecCk ?? '').trim();
        String productCode = (ckgItem.maVt ?? '').trim();
        String maCkValue = (ckgItem.maCk ?? '').trim();
        
        if (sttRecCk.isNotEmpty && productCode.isNotEmpty) {
          String discountKey = '$sttRecCk-$productCode';
          if (!ckvtList.contains(discountKey)) {
            ckvtList.add(discountKey);
          }
          
          // ✅ QUAN TRỌNG: Add to listPromotion: maCk (mã chiết khấu), không phải sttRecCk
          if (maCkValue.isNotEmpty && !promoList.contains(maCkValue)) {
            promoList.add(maCkValue);
          }
        }
      }
    }
    
    // ✅ Rebuild listPromotion từ selectedCktdttIds
    for (String cktdttId in selectedCktdttIds) {
      // cktdttId là sttRecCk
      if (!promoList.contains(cktdttId)) {
        promoList.add(cktdttId);
      }
    }
    
    // Update DataLocal và BLoC
    DataLocal.listCKVT = ckvtList.join(',');
    _bloc.listPromotion = promoList.join(',');
    
    print('💰 Rebuilt discount lists from selections:');
    print('💰   - listCKVT: ${DataLocal.listCKVT}');
    print('💰   - listPromotion: ${_bloc.listPromotion}');
    print('💰   - selectedCkgIds: $selectedCkgIds');
    print('💰   - selectedCktdttIds: $selectedCktdttIds');
    
    // ✅ QUAN TRỌNG: Xóa maCk khỏi products khi CKG bị bỏ tích
    Set<String> removedCkgIds = (_initialSelectedCkgIds ?? {}).difference(selectedCkgIds);
    if (removedCkgIds.isNotEmpty) {
      print('💰 Removing maCk from products for unchecked CKG: $removedCkgIds');

      for (var product in _bloc.listOrder) {
        if (product.maCk != null && product.maCk.toString().trim().isNotEmpty) {
          List<String> productMaCkList = product.maCk.toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          List<String> updatedMaCkList = productMaCkList.where((maCk) => !removedCkgIds.contains(maCk)).toList();
          
          if (productMaCkList.length != updatedMaCkList.length) {
            // Có CKG bị xóa
            String newMaCk = updatedMaCkList.join(',');
            product.maCk = newMaCk;
            print('💰   - Product ${product.code}: Updated maCk from "${productMaCkList.join(',')}" to "$newMaCk"');
            
            // ✅ Update lại vào DB (tìm trong listProductOrderAndUpdate)
            int dbIndex = _bloc.listProductOrderAndUpdate.indexWhere((p) => p.code == product.code);
            if (dbIndex >= 0) {
              _bloc.listProductOrderAndUpdate[dbIndex].dsCKLineItem = newMaCk;
              _bloc.db.updateProduct(_bloc.listProductOrderAndUpdate[dbIndex], _bloc.listProductOrderAndUpdate[dbIndex].codeStock.toString(), false);
              print('💰   - Updated dsCKLineItem in DB for ${product.code}');
            }
          }
        }
      }
    }
    
    // ✅ QUAN TRỌNG: Xóa hàng tặng không còn được chọn
    // 1. Xóa HH gifts không còn trong selectedHHIds
    // Bao gồm cả gifts từ chi tiết đơn hàng (typeCK == '' hoặc null, không phải manual gift)
    print('💰 Checking HH gifts for removal:');
    print('💰   - Total gifts: ${DataLocal.listProductGift.length}');
    print('💰   - selectedHHIds: $selectedHHIds');
    print('💰   - listHH.length: ${_bloc.listHH.length}');
    
    int removedHHCount = 0;
    DataLocal.listProductGift.removeWhere((gift) {
      // ✅ Chỉ xóa gifts không phải manual (gifProductByHand != true)
      // Và có typeCK == 'HH' hoặc typeCK == ''/null (gifts từ chi tiết đơn hàng)
      if (gift.gifProductByHand != true && 
          (gift.typeCK == 'HH' || gift.typeCK == '' || gift.typeCK == null)) {
        
        print('💰 Checking gift: ${gift.code} (typeCK=${gift.typeCK}, sttRec0=${gift.sttRec0}, name=${gift.name})');
        
        // ✅ LOGIC RÕ RÀNG:
        // 1. Nếu maCk = rỗng hoặc null → GIỮ LẠI (không validate)
        // 2. Nếu maCk có, nhưng không match được với listHH → MỚI XÓA
        String? giftMaCk = (gift.maCk ?? '').trim();
        String? giftCode = (gift.code ?? '').trim();
        
        // ✅ Nếu maCk rỗng/null → GIỮ LẠI
        if (giftMaCk.isEmpty) {
          print('💰   ✅ KEEP gift: maCk is empty/null - keeping gift (no validation needed)');
          return false; // Giữ nguyên - không xóa
        }
        
        // ✅ CHỈ validate nếu maCk không rỗng
        bool isSelected = false;
        
        if (giftCode.isNotEmpty) {
          for (var hhItem in _bloc.listHH) {
            String hhSttRecCk = (hhItem.sttRecCk ?? '').trim();
            String hhId = '${hhSttRecCk}_${hhItem.tenVt?.trim() ?? ''}';
            String hhMaCk = (hhItem.maCk ?? '').trim();
            String hhMaVt = (hhItem.maVt ?? '').trim();
            
            // ✅ Match theo maCk VÀ maVt (giống CKG)
            bool matchByMaCkAndMaVt = hhMaCk.isNotEmpty && hhMaCk == giftMaCk &&
                                     hhMaVt.isNotEmpty && hhMaVt == giftCode;
            
            print('💰   - Comparing gift.maCk="$giftMaCk", gift.code="$giftCode" with HH.maCk="$hhMaCk", HH.maVt="$hhMaVt" (match: $matchByMaCkAndMaVt)');
            print('💰   - hhId in selectedHHIds: ${selectedHHIds.contains(hhId)}');
            
            // ✅ Nếu match theo maCk và maVt, và còn trong selectedHHIds → giữ lại
            if (matchByMaCkAndMaVt && selectedHHIds.contains(hhId)) {
              isSelected = true;
              print('💰 ✅ Keeping HH gift: ${gift.code} (matched by maCk="$giftMaCk" and maVt="$giftCode", hhId=$hhId, in selectedHHIds)');
              break;
            }
          }
        }
        
        // ✅ CHỈ xóa nếu có maCk nhưng không match được
        if (!isSelected) {
          _bloc.totalProductGift -= gift.count ?? 0;
          removedHHCount++;
          print('💰 ❌ Removing HH gift: ${gift.code} x${gift.count} (maCk="$giftMaCk" exists but not matched)');
          return true;
        }
      }
      return false;
    });
    
    // 2. Xóa CKN gifts không còn trong selectedCknGroups
    int removedCKNCount = 0;
    DataLocal.listProductGift.removeWhere((gift) {
      if (gift.typeCK == 'CKN') {
        // Tìm CKN item trong listCkn để lấy groupKey
        String? groupKey;
        for (var cknItem in _bloc.listCkn) {
          if ((cknItem.maHangTang?.trim() == gift.code?.trim()) ||
              (cknItem.sttRecCk?.trim() == gift.sttRecCK?.trim())) {
            groupKey = (cknItem.group_dk?.toString().trim() ?? cknItem.sttRecCk?.toString().trim());
            break;
          }
        }
        
        if (groupKey != null && !selectedCknGroups.contains(groupKey)) {
          _bloc.totalProductGift -= gift.count ?? 0;
          removedCKNCount++;
          print('💰 Removing CKN gift: ${gift.code} x${gift.count} (group $groupKey not in selectedCknGroups)');
          return true;
        }
      }
      return false;
    });
    
    // 3. Xóa CKTDTH gifts không còn trong selectedCktdthGroups
    int removedCKTDTHCount = 0;
    DataLocal.listProductGift.removeWhere((gift) {
      if (gift.typeCK == 'CKTDTH') {
        // Tìm CKTDTH item trong listCktdth để lấy groupKey
        String? groupKey;
        for (var cktdthItem in _bloc.listCktdth) {
          if ((cktdthItem.maHangTang?.trim() == gift.code?.trim()) ||
              (cktdthItem.sttRecCk?.trim() == gift.sttRecCK?.trim())) {
            groupKey = (cktdthItem.group_dk?.toString().trim() ?? cktdthItem.sttRecCk?.toString().trim());
            break;
          }
        }
        
        if (groupKey != null && !selectedCktdthGroups.contains(groupKey)) {
          _bloc.totalProductGift -= gift.count ?? 0;
          removedCKTDTHCount++;
          print('💰 Removing CKTDTH gift: ${gift.code} x${gift.count} (group $groupKey not in selectedCktdthGroups)');
          return true;
        }
      }
      return false;
    });
    
    print('💰 Removed gifts: HH=$removedHHCount, CKN=$removedCKNCount, CKTDTH=$removedCKTDTHCount');
    print('💰 Remaining gifts: ${DataLocal.listProductGift.length}');
    
    // ✅ Xóa hàng tặng khỏi listOrder nếu có (gifProduct = true)
    int removedFromOrderCount = 0;
    List<String> removedGiftCodes = [];
    _bloc.listOrder.removeWhere((product) {
      if (product.gifProduct == true) {
        // Kiểm tra xem gift này còn trong listProductGift không
        bool stillExists = DataLocal.listProductGift.any((gift) => 
          (gift.code?.trim() == product.code?.trim()) &&
          (gift.typeCK == product.typeCK || (gift.typeCK == '' && product.typeCK == null))
        );
        
        if (!stillExists) {
          removedFromOrderCount++;
          removedGiftCodes.add(product.code ?? '');
          print('💰 Removing gift product from listOrder: ${product.code}');
          return true;
        }
      }
      return false;
    });
    
    if (removedFromOrderCount > 0) {
      print('💰 Removed $removedFromOrderCount gift products from listOrder: $removedGiftCodes');
      // Recalculate totals after removing gifts
      _recalculateTotalLocal();
    }
    
    // ✅ Apply all CKTDTT discounts (cộng dồn totalDiscountForOder)
    if (selectedCktdttIds.isNotEmpty) {
      print('💰 Applying ${selectedCktdttIds.length} CKTDTT discounts');
      _applyAllCKTDTT(selectedCktdttIds);
    }

    // ✅ Gọi API để sync tất cả thay đổi (CKG, CKTDTT, HH) với backend
    // ✅ Cả mode add và edit đều cần gọi API khi có thay đổi
    // So sánh state hiện tại với state ban đầu (khi mở bottom sheet) để detect thay đổi
    
    // ✅ Kiểm tra có thay đổi so với state ban đầu không
    bool hasCkgChanged = !_setsEqual(selectedCkgIds, _initialSelectedCkgIds ?? {});
    bool hasCktdttChanged = !_setsEqual(selectedCktdttIds, _initialSelectedCktdttIds ?? {});
    bool hasHHChanged = !_setsEqual(selectedHHIds, _initialSelectedHHIds ?? {});
    bool hasListCKVTChanged = (DataLocal.listCKVT != (_initialListCKVT ?? ''));
    bool hasListPromotionChanged = (_bloc.listPromotion != (_initialListPromotion ?? ''));
    
    bool hasChanges = hasCkgChanged || hasCktdttChanged || hasHHChanged || hasListCKVTChanged || hasListPromotionChanged;
    
    // ✅ Nếu có chiết khấu được chọn (add) → cần gọi API
    bool hasSelectedDiscounts = selectedCkgIds.isNotEmpty || selectedCktdttIds.isNotEmpty || selectedHHIds.isNotEmpty;
    
    // ✅ Nếu có thay đổi (add hoặc remove) → gọi API
    if (hasChanges || hasSelectedDiscounts) {
      print('💰 Calling API to sync discount changes to backend');
      print('💰   - Mode: ${widget.viewUpdateOrder == true ? "EDIT" : "ADD"}');
      print('💰   - hasChanges: $hasChanges (CKG: $hasCkgChanged, CKTDTT: $hasCktdttChanged, HH: $hasHHChanged, listCKVT: $hasListCKVTChanged, listPromotion: $hasListPromotionChanged)');
      print('💰   - hasSelectedDiscounts: $hasSelectedDiscounts (CKG: ${selectedCkgIds.length}, CKTDTT: ${selectedCktdttIds.length}, HH: ${selectedHHIds.length})');
      print('💰   - Current: listCKVT=${DataLocal.listCKVT}, listPromotion=${_bloc.listPromotion}');
      print('💰   - Initial: listCKVT=$_initialListCKVT, listPromotion=$_initialListPromotion');
      _needReapplyHHAfterReload = true;
      _reloadDiscountsFromBackend();
    } else {
      print('💰 No discount changes to sync (no changes detected compared to initial state)');
    }     
  
    // Apply HH gifts (sẽ được re-apply sau  API response nếu cần)
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
        
        print('💰 Checking product[${i}]: cartCode=${cartProductCode}, searchCode=${searchProductCode}, match=${cartProductCode == searchProductCode}, gifProduct=${_bloc.listOrder[i].gifProduct}, sttRecCK=${_bloc.listOrder[i].sttRecCK}, maCk=${_bloc.listOrder[i].maCk}');
        
        if (cartProductCode == searchProductCode && _bloc.listOrder[i].gifProduct != true) {
          print('💰 ✅ Product MATCH at index ${i}: shouldApply=$shouldApply');
          
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
            
            // ✅ Get original price (giá gốc)
            // QUAN TRỌNG: Trong edit mode, giaSuaDoi = priceAfter (giá sau chiết khấu) từ lineItem
            // Nên phải dùng product.price (giá gốc) làm originalPrice, không dùng giaSuaDoi
            // Check edit mode: có maCk hoặc giaSuaDoi != price (đã được set = priceAfter)
            bool isEditMode = (product.maCk != null && product.maCk.toString().trim().isNotEmpty) ||
                             (product.giaSuaDoi != null && product.price != null && 
                              product.giaSuaDoi! > 0 && product.price! > 0 && 
                              product.giaSuaDoi != product.price);
            
            double originalPrice = 0;
            if (isEditMode) {
              // ✅ EDIT MODE: Dùng price (giá gốc) làm originalPrice
              originalPrice = product.price ?? 0;
              if (originalPrice == 0 && ckgItem.giaGoc != null && ckgItem.giaGoc! > 0) {
                originalPrice = ckgItem.giaGoc!.toDouble();
              }
              print('💰 [EDIT MODE] originalPrice from product.price: $originalPrice (giaSuaDoi=${product.giaSuaDoi} is priceAfter)');
            } else {
              // ✅ CREATE MODE: Ưu tiên giaSuaDoi, sau đó price, cuối cùng giaGoc từ CKG
              originalPrice = product.giaSuaDoi ?? 0;
              if (originalPrice == 0) {
                originalPrice = product.price ?? 0;
              }
              if (originalPrice == 0 && ckgItem.giaGoc != null && ckgItem.giaGoc! > 0) {
                originalPrice = ckgItem.giaGoc!.toDouble();
              }
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
            // ✅ QUAN TRỌNG: Reset NGAY không cần check thêm điều kiện
            // Vì đã match productCode ở vòng loop rồi
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
              print('💰 [EDIT MODE] Using price as originalPrice: $originalPrice (giaSuaDoi=${_bloc.listOrder[i].giaSuaDoi} is priceAfter)');
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
    
    // ✅ CHỈ GỌI API KHI CÓ ADDITIONS (không gọi khi chỉ remove)
    if (hasAdditions) {
      print('💰 Calling API to apply new discounts');
      _needReapplyHHAfterReload = true;
      _reloadDiscountsFromBackend();
    }
  }
  
  
  // Reload discounts from backend after changing selection
  void _reloadDiscountsFromBackend() {
    // ✅ Gọi API cho cả mode add và edit khi có thay đổi chiết khấu
    // Edit mode cũng cần gọi API để backend tính lại giá sau khi bỏ tích hoặc thêm chiết khấu
    
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
      // ✅ Đảm bảo customerId không rỗng/null
      final finalCustomerId = (widget.codeCustomer != null &&
              widget.codeCustomer.toString().trim().isNotEmpty &&
              widget.codeCustomer.toString().trim() != 'null')
          ? widget.codeCustomer.toString().trim()
          : ((DataLocal.infoCustomer.customerCode.toString().trim().isNotEmpty &&
                  DataLocal.infoCustomer.customerCode.toString().trim() != 'null')
              ? DataLocal.infoCustomer.customerCode.toString().trim()
              : (_bloc.codeCustomer?.toString().trim() ?? ''));

      // ✅ DEBUG: Log request parameters
      print('💰 === Calling API with parameters ===');
      print('💰 listCKVT: ${DataLocal.listCKVT}');
      print('💰 listItem: $listItem');
      print('💰 listQty: $listQty');
      print('💰 listPrice: $listPrice');
      print('💰 listMoney: $listMoney');
      
      // ✅ Đảm bảo warehouseId không rỗng
      // Ưu tiên: _bloc.storeCode > codeStore > Const.stockList[0].stockCode
      final finalWarehouseId = (!Utils.isEmpty(_bloc.storeCode.toString()) && _bloc.storeCode.toString().trim().isNotEmpty)
          ? _bloc.storeCode.toString()
          : ((!Utils.isEmpty(codeStore) && codeStore.trim().isNotEmpty)
              ? codeStore
              : (Const.stockList.isNotEmpty ? Const.stockList[0].stockCode.toString() : ''));
      
      if (finalWarehouseId.isEmpty) {
        print('⚠️ Warning: warehouseId is empty in _syncListOrderToUI, API may fail!');
        print('   - _bloc.storeCode = ${_bloc.storeCode}');
        print('   - codeStore = $codeStore');
        print('   - Const.stockList.length = ${Const.stockList.length}');
      }
      
      print('💰 warehouseId: $finalWarehouseId');

      if (finalCustomerId.isEmpty) {
        print('⚠️ Warning: customerId is empty/null in _reloadDiscountsFromBackend, skip apply-discount-v2');
        print('   - widget.codeCustomer = ${widget.codeCustomer}');
        print('   - DataLocal.infoCustomer.customerCode = ${DataLocal.infoCustomer.customerCode}');
        print('   - _bloc.codeCustomer = ${_bloc.codeCustomer}');
        return;
      }
      
      // Call API to recalculate discounts
      _bloc.add(GetListItemApplyDiscountEvent(
        listCKVT: DataLocal.listCKVT,
        listPromotion: _bloc.listPromotion,
        listItem: listItem,
        listQty: listQty,
        listPrice: listPrice,
        listMoney: listMoney,
        warehouseId: finalWarehouseId,
        customerId: finalCustomerId,
        keyLoad: 'Second',  // Not first load
      ));
      
      print('💰 Called GetListItemApplyDiscountEvent');
    }
  }
  
  // Recalculate total payment locally (sau khi check/uncheck discount)
  // ✅ Helper function để so sánh 2 Set có bằng nhau không
  bool _setsEqual<T>(Set<T> set1, Set<T> set2) {
    if (set1.length != set2.length) return false;
    return set1.every((item) => set2.contains(item));
  }
  
  /// ✅ Clear TẤT CẢ chiết khấu sau khi restore draft trong mode add
  /// Bao gồm cả chiết khấu từ chương trình và chiết khấu thủ công
  /// Để user có thể chọn lại chiết khấu từ đầu
  void _clearAllDiscountsAfterRestore() {
    print('💰 === Clearing ALL discounts after restore draft ===');
    
    // 1. Clear TẤT CẢ chiết khấu trên từng sản phẩm (bao gồm cả chiết khấu thủ công)
    for (int i = 0; i < _bloc.listOrder.length; i++) {
      var product = _bloc.listOrder[i];
      if (product.gifProduct == true) continue;
      
      print('💰 Clearing ALL discounts from product ${product.code}:');
      print('💰   - discountPercent=${product.discountPercent}');
      print('💰   - discountPercentByHand=${product.discountPercentByHand}');
      print('💰   - maCk=${product.maCk}');
      print('💰   - priceAfter=${product.priceAfter}');
      
      // Reset về giá gốc
      double originalPrice = product.giaSuaDoi ?? product.price ?? 0;
      product.priceAfter = originalPrice;
      
      // Clear TẤT CẢ chiết khấu
      product.discountPercent = 0;
      product.discountPercentByHand = 0;
      product.discountByHand = false;
      product.ckntByHand = 0;
      product.maCk = null;
      product.sttRecCK = null;
      product.typeCK = null;
      product.discountMoney = null;
      product.discountProduct = null;
      
      print('💰   - After: priceAfter=$originalPrice, discountPercent=0');
    }
    
    // 2. Clear listCKVT và listPromotion
    print('💰 Clearing listCKVT and listPromotion');
    print('💰   - Before: listCKVT=${DataLocal.listCKVT}');
    print('💰   - Before: listPromotion=${_bloc.listPromotion}');
    
    DataLocal.listCKVT = '';
    _bloc.listPromotion = '';
    
    // Clear selected discount IDs
    _bloc.selectedCkgIds.clear();
    _bloc.selectedHHIds.clear();
    _bloc.selectedCktdttIds.clear();
    _bloc.selectedCknGroups.clear();
    _bloc.selectedCktdthGroups.clear();
    
    // 3. Clear HOÀN TOÀN listOrderCalculatorDiscount (bao gồm cả chiết khấu thủ công)
    print('💰 Clearing ALL listOrderCalculatorDiscount');
    print('💰   - Before: listOrderCalculatorDiscount.length=${DataLocal.listOrderCalculatorDiscount.length}');
    
    DataLocal.listOrderCalculatorDiscount.clear();
    
    print('💰   - After: listCKVT=${DataLocal.listCKVT}');
    print('💰   - After: listPromotion=${_bloc.listPromotion}');
    print('💰   - After: listOrderCalculatorDiscount.length=${DataLocal.listOrderCalculatorDiscount.length}');
    
    // 4. Reset tổng tiền về tổng tiền nguyên giá (không có chiết khấu)
    _bloc.totalDiscount = 0;
    _bloc.totalDiscountForOder = 0;
    
    // 5. Tính lại tổng tiền
    _recalculateTotalLocal();
    
    print('💰 ✅ ALL discounts cleared (including manual discounts)');
    print('💰   - totalMoney=${_bloc.totalMoney}');
    print('💰   - totalDiscount=${_bloc.totalDiscount}');
    print('💰   - totalPayment=${_bloc.totalPayment}');
  }
  
  /// ✅ Validate chiết khấu từ lineItem (EDIT MODE) với chương trình chiết khấu hiện tại
  void _validateLineItemDiscounts() {
    print('💰 === Validating lineItem discounts (EDIT MODE) ===');
    print('💰 _lineItemDiscounts: $_lineItemDiscounts (${_lineItemDiscounts.length} items)');
    print('💰 _lineItemPromotions: $_lineItemPromotions (${_lineItemPromotions.length} items)');
    print('💰 _bloc.listCkg.length: ${_bloc.listCkg.length}');
    
    List<String> invalidDiscounts = [];
    List<String> invalidGifts = [];
    bool hasInvalidDiscounts = false;
    
    // 1. Validate chiết khấu từ lineItem với API response
    if (_lineItemDiscounts.isEmpty) {
      print('💰 ⚠️ _lineItemDiscounts is empty - nothing to validate');
    }
    
    for (String discountKey in _lineItemDiscounts) {
      // Parse format "sttRecCk-maVt" hoặc "maCk-maVt"
      List<String> parts = discountKey.split('-');
      if (parts.length >= 2) {
        String identifier = parts[0].trim(); // Có thể là sttRecCk hoặc maCk
        String maVt = parts.sublist(1).join('-').trim();
        
        print('💰 Validating discount: $discountKey (identifier=$identifier, maVt=$maVt)');
        
        // Kiểm tra xem CKG này còn tồn tại trong API response không
        // So sánh theo cả sttRecCk và maCk, và phải khớp với maVt
        bool isValid = _bloc.listCkg.any((ckg) => 
          (ckg.sttRecCk?.trim() == identifier || ckg.maCk?.trim() == identifier) &&
          ckg.maVt?.trim() == maVt
        );
        
        print('💰   - isValid: $isValid');
        if (!isValid) {
          print('💰   - ❌ Invalid discount: $discountKey - Not found in current discount programs');
          print('💰   - Checking listCkg items:');
          for (var ckg in _bloc.listCkg) {
            print('💰     - CKG: sttRecCk="${ckg.sttRecCk}", maCk="${ckg.maCk}", maVt="${ckg.maVt}"');
          }
        } else {
          print('💰   - ✅ Valid discount: $discountKey');
        }
        
        if (!isValid) {
          hasInvalidDiscounts = true;
          
          // Tìm tên sản phẩm và mã chiết khấu
          String productName = maVt;
          String? maCkValue;
          
          // Tìm mã chiết khấu từ _lineItemPromotions hoặc từ product
          // identifier có thể là sttRecCk hoặc maCk
          bool identifierIsMaCk = _lineItemPromotions.any((promo) => promo.trim() == identifier);
          
          if (identifierIsMaCk) {
            // Nếu identifier là maCk, dùng trực tiếp
            maCkValue = identifier;
          } else {
            // Nếu identifier là sttRecCk, tìm maCk từ product hoặc từ lineItem
            for (var product in _bloc.listOrder) {
              if (product.code?.trim() == maVt) {
                productName = product.name ?? maVt;
                
                // Tìm maCk từ product nếu có
                if (product.sttRecCK?.trim() == identifier || product.maCk?.trim() == identifier) {
                  if (product.maCk != null && product.maCk!.isNotEmpty) {
                    maCkValue = product.maCk!.trim();
                  }
                }
                break;
              }
            }
            
            // Nếu vẫn chưa tìm thấy maCk, tìm trong _lineItemPromotions
            // bằng cách match với sttRecCk trong listCkg (tìm trong listCkg trước khi nó bị xóa)
            if (maCkValue == null || maCkValue.isEmpty) {
              // Tìm maCk từ product trước khi xóa
              for (var product in _bloc.listOrder) {
                if (product.code?.trim() == maVt && product.sttRecCK?.trim() == identifier) {
                  if (product.maCk != null && product.maCk!.isNotEmpty) {
                    maCkValue = product.maCk!.trim();
                    break;
                  }
                }
              }
            }
          }
          
          // Tìm tên sản phẩm
          for (var product in _bloc.listOrder) {
            if (product.code?.trim() == maVt) {
              productName = product.name ?? maVt;
              
              // Xóa chiết khấu khỏi sản phẩm
              product.discountPercent = 0;
              product.priceAfter = product.price ?? product.giaSuaDoi ?? 0;
              product.maCk = null;
              product.sttRecCK = null;
              product.typeCK = null;
              
              print('💰 ❌ Invalid discount for product: $maVt, maCk: $maCkValue');
              break;
            }
          }
          
          // Hiển thị cả mã chiết khấu và tên sản phẩm
          String discountInfo = 'Chiết khấu cho: $productName';
          if (maCkValue != null && maCkValue.isNotEmpty) {
            discountInfo += ' (Mã CK: $maCkValue)';
          } else if (identifierIsMaCk && identifier.isNotEmpty) {
            // Nếu identifier là maCk, hiển thị luôn
            discountInfo += ' (Mã CK: $identifier)';
          }
          
          invalidDiscounts.add(discountInfo);
        }
      }
    }
    
    // 2. Validate hàng tặng từ lineItem
    List<SearchItemResponseData> giftsFromLineItem = DataLocal.listProductGift.where((gift) => 
      gift.gifProduct == true && 
      gift.gifProductByHand != true && 
      (gift.typeCK == null || gift.typeCK == '' || gift.typeCK == 'HH')
    ).toList();
    
    print('💰 Validating ${giftsFromLineItem.length} gifts from lineItem');
    print('💰 _bloc.listHH.length: ${_bloc.listHH.length}');
    
    // ✅ Debug: In ra tất cả items trong listHH
    if (_bloc.listHH.isNotEmpty) {
      print('💰 Available HH items in listHH:');
      for (var hh in _bloc.listHH) {
        print('💰   - maVt="${hh.maVt}", sttRecCk="${hh.sttRecCk}", maCk="${hh.maCk}", tenVt="${hh.tenVt}"');
      }
    } else {
      print('💰 ⚠️ listHH is EMPTY - cannot validate gifts!');
    }
    
    for (var gift in giftsFromLineItem) {
      String? giftMaCk = (gift.maCk ?? '').trim();
      String giftCode = (gift.code ?? '').trim();
      
      print('💰 Checking gift: code="$giftCode", name="${gift.name}", maCk="$giftMaCk", sttRec0="${gift.sttRec0}", sttRecCK="${gift.sttRecCK}", typeCK="${gift.typeCK}"');
      
      // ✅ LOGIC RÕ RÀNG:
      // 1. Nếu maCk = rỗng hoặc null → GIỮ LẠI (không validate)
      // 2. Nếu maCk có, nhưng không match được với listHH → MỚI XÓA
      if (giftMaCk.isEmpty) {
        print('💰   ✅ KEEP gift: maCk is empty/null - keeping gift (no validation needed)');
        continue; // Giữ nguyên hàng tặng này - không cần validate
      }
      
      // ✅ CHỈ validate nếu maCk không rỗng (là gift từ chọn chiết khấu)
      // ✅ QUAN TRỌNG: Nếu listHH rỗng, không thể validate → GIỮ NGUYÊN gift
      if (_bloc.listHH.isEmpty) {
        print('💰   ✅ KEEP gift: listHH is empty - cannot validate, keeping gift to be safe');
        continue; // Giữ nguyên hàng tặng này nếu listHH rỗng
      }
      
      bool isValid = false;
      
      // ✅ Check trong listHH - match theo maCk VÀ maVt (giống CKG)
      for (var hh in _bloc.listHH) {
        String hhMaCk = (hh.maCk ?? '').trim();
        String hhMaVt = (hh.maVt ?? '').trim();
        
        print('💰   Comparing gift "$giftCode" (maCk="$giftMaCk") with HH: maCk="$hhMaCk", maVt="$hhMaVt"');
        
        // ✅ Match theo maCk VÀ maVt (giống CKG)
        if (hhMaCk.isNotEmpty && hhMaCk == giftMaCk && 
            hhMaVt.isNotEmpty && hhMaVt == giftCode) {
          isValid = true;
          print('💰   ✅ MATCH by maCk and maVt! Gift is valid (giftMaCk="$giftMaCk" == hhMaCk="$hhMaCk" && giftCode="$giftCode" == hhMaVt="$hhMaVt")');
          break;
        }
      }
      
      // ✅ CHỈ xóa nếu có maCk nhưng không match được
      if (!isValid) {
        hasInvalidDiscounts = true;
        String giftName = gift.name ?? gift.code ?? 'Unknown';
        String maCkDisplay = giftMaCk.isNotEmpty ? ' (Mã CK: $giftMaCk)' : '';
        invalidGifts.add('Hàng tặng: $giftName$maCkDisplay');
        
        print('💰 ❌ Invalid gift: code="$giftCode", maCk="$giftMaCk" - Not found in listHH (will be removed)');
        print('💰   Searched for: maVt="$giftCode", maCk="$giftMaCk", sttRec0="${gift.sttRec0}", sttRecCK="${gift.sttRecCK}"');
        
        // Xóa hàng tặng (có maCk nhưng không match)
        DataLocal.listProductGift.removeWhere((g) => 
          g.code == gift.code && g.gifProductByHand != true
        );
        _bloc.totalProductGift -= gift.count ?? 0;
      }
    }
    
    // 3. Hiển thị dialog nếu có chiết khấu/hàng tặng không hợp lệ
    if (hasInvalidDiscounts) {
      print('💰 Found ${invalidDiscounts.length} invalid discounts and ${invalidGifts.length} invalid gifts');
      
      // Xóa khỏi listCKVT và listPromotion
      if (invalidDiscounts.isNotEmpty) {
        List<String> currentCkvt = DataLocal.listCKVT.split(',').where((s) => s.isNotEmpty).toList();
        List<String> currentPromo = _bloc.listPromotion.split(',').where((s) => s.isNotEmpty).toList();
        
        for (String discountKey in _lineItemDiscounts) {
          if (!_bloc.listCkg.any((ckg) => discountKey.startsWith('${ckg.sttRecCk}-') || discountKey.startsWith('${ckg.maCk}-'))) {
            currentCkvt.removeWhere((key) => key == discountKey);
          }
        }
        
        DataLocal.listCKVT = currentCkvt.join(',');
        _bloc.listPromotion = currentPromo.join(',');
      }
      
      // Tính lại tổng tiền
      _recalculateTotalLocal();
      
      // Sync vào database
      if (widget.viewUpdateOrder == true) {
        _syncListOrderToUI();
      }
      
      // Hiển thị dialog
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _showInvalidDiscountsDialog(invalidDiscounts, invalidGifts);
        }
      });
      
      setState(() {});
    } else {
      print('💰 All lineItem discounts are valid');
    }
    
    // Clear biến tạm
    _lineItemDiscounts.clear();
    _lineItemPromotions.clear();
  } 
  
  /// ✅ Validate và xóa các chiết khấu đã restore từ draft nhưng không còn match với chương trình chiết khấu hiện tại
  void _validateAndRemoveInvalidDiscounts() {
    print('💰 === Validating restored discounts ===');
    
    bool hasChanges = false;
    List<String> invalidDiscounts = []; // Danh sách chiết khấu không hợp lệ
    List<String> invalidGifts = []; // Danh sách hàng tặng không hợp lệ
    
    // 1. Validate DataLocal.listCKVT (format: "sttRecCk-maVt")
    if (DataLocal.listCKVT.isNotEmpty) {
      List<String> ckvtList = DataLocal.listCKVT.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      List<String> validCkvtList = [];
      
      for (String ckvtItem in ckvtList) {
        // Parse format "sttRecCk-maVt"
        List<String> parts = ckvtItem.split('-');
        if (parts.length >= 2) {
          String sttRecCk = parts[0].trim();
          String maVt = parts.sublist(1).join('-').trim(); // Join lại phần còn lại (có thể có nhiều dấu -)
          
          // Kiểm tra xem CKG này còn tồn tại trong listCkg không
          bool isValid = _bloc.listCkg.any((ckg) => 
            (ckg.sttRecCk?.trim() == sttRecCk || ckg.maCk?.trim() == sttRecCk) &&
            ckg.maVt?.trim() == maVt
          );
          
          if (isValid) {
            validCkvtList.add(ckvtItem);
            print('💰 ✅ Valid CKG: $ckvtItem');
          } else {
            hasChanges = true;
            print('💰 ❌ Invalid CKG (removed): $ckvtItem - Not found in current discount programs');
            
            // Tìm tên chiết khấu để hiển thị trong dialog
            String productName = '';
            for (var product in _bloc.listOrder) {
              if (product.code?.trim() == maVt) {
                productName = product.name ?? maVt;
                break;
              }
            }
            invalidDiscounts.add('Chiết khấu cho sản phẩm: $productName');
            
            // Xóa chiết khấu khỏi sản phẩm (chỉ nếu không phải chiết khấu thủ công)
            for (int i = 0; i < _bloc.listOrder.length; i++) {
              var product = _bloc.listOrder[i];
              if (product.code?.trim() == maVt && 
                  (product.sttRecCK?.trim() == sttRecCk || product.maCk?.trim() == sttRecCk) &&
                  product.discountByHand != true) {
                print('💰   Removing discount from product: ${product.code}');
                product.maCk = null;
                product.sttRecCK = null;
                product.typeCK = null;
                // ✅ CHỈ xóa discountPercent nếu không phải chiết khấu thủ công
                if (product.discountPercentByHand == null || product.discountPercentByHand == 0) {
                  product.discountPercent = 0;
                  product.priceAfter = product.giaSuaDoi ?? product.price ?? 0;
                }
                
                // Xóa khỏi listOrderCalculatorDiscount nếu có (chỉ nếu không phải chiết khấu thủ công)
                DataLocal.listOrderCalculatorDiscount.removeWhere((item) => 
                  item.code?.trim() == product.code?.trim() && item.discountByHand != true
                );
              }
            }
          }
        }
      }
      
      if (hasChanges) {
        DataLocal.listCKVT = validCkvtList.join(',');
        print('💰 Updated listCKVT: ${DataLocal.listCKVT}');
      }
    }
    
    // 2. Validate _bloc.listPromotion (format: "sttRecCk1,sttRecCk2,...")
    if (_bloc.listPromotion.isNotEmpty) {
      List<String> promoList = _bloc.listPromotion.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      List<String> validPromoList = [];
      
      for (String sttRecCk in promoList) {
        bool isValid = false;
        
        // Kiểm tra trong listCkg
        if (_bloc.listCkg.any((ckg) => ckg.sttRecCk?.trim() == sttRecCk || ckg.maCk?.trim() == sttRecCk)) {
          isValid = true;
        }
        // Kiểm tra trong listHH
        else if (_bloc.listHH.any((hh) => hh.sttRecCk?.trim() == sttRecCk)) {
          isValid = true;
        }
        // Kiểm tra trong listCktdtt
        else if (_bloc.listCktdtt.any((cktdtt) => cktdtt.sttRecCk?.trim() == sttRecCk)) {
          isValid = true;
        }
        // Kiểm tra trong listCkn
        else if (_bloc.listCkn.any((ckn) => ckn.sttRecCk?.trim() == sttRecCk)) {
          isValid = true;
        }
        // Kiểm tra trong listCktdth
        else if (_bloc.listCktdth.any((cktdth) => cktdth.sttRecCk?.trim() == sttRecCk)) {
          isValid = true;
        }
        
        if (isValid) {
          validPromoList.add(sttRecCk);
          print('💰 ✅ Valid promotion: $sttRecCk');
        } else {
          hasChanges = true;
          print('💰 ❌ Invalid promotion (removed): $sttRecCk - Not found in current discount programs');
          
          // Tìm tên chiết khấu (nếu có)
          // invalidDiscounts đã được add ở phần validate listCKVT
        }
      }
      
      if (hasChanges) {
        _bloc.listPromotion = validPromoList.join(',');
        print('💰 Updated listPromotion: ${_bloc.listPromotion}');
      }
    }
    
    // 3. Validate và xóa chiết khấu khỏi sản phẩm nếu không còn match
    for (int i = 0; i < _bloc.listOrder.length; i++) {
      var product = _bloc.listOrder[i];
      if (product.gifProduct == true) continue;
      
      // ✅ QUAN TRỌNG: Không xóa chiết khấu thủ công (discountByHand == true)
      if (product.discountByHand == true) {
        continue; // Skip chiết khấu thủ công
      }
      
      bool needRemove = false;
      String? reason = '';
      
      // Kiểm tra 1: Nếu sản phẩm có maCk nhưng không còn trong listCkg
      if (product.maCk != null && product.maCk.toString().trim().isNotEmpty) {
        String maCk = product.maCk.toString().trim();
        bool isValid = _bloc.listCkg.any((ckg) => 
          ckg.maCk?.trim() == maCk || ckg.sttRecCk?.trim() == maCk
        );
        
        if (!isValid) {
          needRemove = true;
          reason = 'maCk=$maCk not found in listCkg';
        }
      }
      
      // Kiểm tra 2: Nếu sản phẩm có discountPercent nhưng không có maCk hoặc maCk không match
      // Đây là trường hợp chiết khấu được restore từ listOrderCalculatorDiscount nhưng không match với chương trình hiện tại
      if (!needRemove && product.discountPercent != null && product.discountPercent! > 0) {
        String productCode = product.code?.trim() ?? '';
        
        // Kiểm tra xem có CKG nào trong listCkg match với sản phẩm này không
        bool hasMatchingCkg = _bloc.listCkg.any((ckg) => 
          ckg.maVt?.trim() == productCode
        );
        
        // Nếu không có CKG match và không có maCk, thì chiết khấu này không hợp lệ
        if (!hasMatchingCkg && (product.maCk == null || product.maCk.toString().trim().isEmpty)) {
          needRemove = true;
          reason = 'discountPercent=${product.discountPercent}% but no matching CKG program found';
        }
        // Nếu có maCk nhưng không match với listCkg
        else if (product.maCk != null && product.maCk.toString().trim().isNotEmpty) {
          String maCk = product.maCk.toString().trim();
          bool isValid = _bloc.listCkg.any((ckg) => 
            (ckg.maCk?.trim() == maCk || ckg.sttRecCk?.trim() == maCk) &&
            ckg.maVt?.trim() == productCode
          );
          
          if (!isValid) {
            needRemove = true;
            reason = 'maCk=$maCk exists but discountPercent=${product.discountPercent}% does not match any CKG program';
          }
        }
      }
      
      if (needRemove) {
        hasChanges = true;
        print('💰 ❌ Removing invalid discount from product ${product.code}: $reason');
        product.maCk = null;
        product.sttRecCK = null;
        product.typeCK = null;
        product.discountPercent = 0;
        product.priceAfter = product.giaSuaDoi ?? product.price ?? 0;
        
        // Xóa khỏi listOrderCalculatorDiscount nếu có
        DataLocal.listOrderCalculatorDiscount.removeWhere((item) => 
          item.code?.trim() == product.code?.trim() && item.discountByHand != true
        );
      }
    }
    
    // 4. Validate hàng tặng
    List<SearchItemResponseData> invalidGiftsList = [];
    for (var gift in DataLocal.listProductGift) {
      if (gift.gifProduct == true && gift.gifProductByHand != true) {
        // Kiểm tra xem gift này còn trong chương trình chiết khấu không
        bool isValidGift = false;
        
        // ✅ HH là gift products, có thể có typeCK == 'HH' hoặc typeCK == ''/null (gifts từ lineItem với km_yn = 1)
        if (gift.typeCK == 'HH' || gift.typeCK == '' || gift.typeCK == null) {
          // ✅ LOGIC RÕ RÀNG:
          // 1. Nếu maCk = rỗng hoặc null → GIỮ LẠI (không validate)
          // 2. Nếu maCk có, nhưng không match được với listHH → MỚI XÓA
          String? giftMaCk = (gift.maCk ?? '').trim();
          String? giftCode = (gift.code ?? '').trim();
          
          // ✅ Nếu maCk rỗng/null → GIỮ LẠI (không validate)
          if (giftMaCk.isEmpty) {
            isValidGift = true; // Giữ lại
            print('💰   ✅ KEEP gift: maCk is empty/null - keeping gift (no validation needed)');
          } else {
            // ✅ CHỈ validate nếu maCk không rỗng
            isValidGift = giftCode.isNotEmpty && _bloc.listHH.any((hh) => 
              (hh.maCk ?? '').trim() == giftMaCk &&
              (hh.maVt ?? '').trim() == giftCode
            );
            if (!isValidGift) {
              print('💰   ❌ Invalid gift: maCk="$giftMaCk" exists but not matched with listHH');
            }
          }
        } else if (gift.typeCK == 'CKN') {
          isValidGift = _bloc.listCkn.any((ckn) => 
            ckn.sttRecCk?.trim() == gift.sttRecCK?.trim()
          );
        } else if (gift.typeCK == 'CKTDTH') {
          isValidGift = _bloc.listCktdth.any((cktdth) => 
            cktdth.sttRecCk?.trim() == gift.sttRecCK?.trim()
          );
        }
        
        if (!isValidGift) {
          hasChanges = true;
          invalidGiftsList.add(gift);
          invalidGifts.add('Hàng tặng: ${gift.name ?? gift.code}');
          print('💰 ❌ Invalid gift (will be removed): ${gift.code} - ${gift.name}');
        }
      }
    }
    
    // Xóa hàng tặng không hợp lệ
    for (var gift in invalidGiftsList) {
      DataLocal.listProductGift.removeWhere((g) => 
        g.code == gift.code && g.sttRecCK == gift.sttRecCK && g.typeCK == gift.typeCK
      );
      _bloc.totalProductGift -= gift.count ?? 0;
    }
    
    // 5. Hiển thị dialog báo nếu có chiết khấu/hàng tặng không hợp lệ (chỉ trong EDIT mode)
    if (hasChanges && widget.viewUpdateOrder == true && (invalidDiscounts.isNotEmpty || invalidGifts.isNotEmpty)) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _showInvalidDiscountsDialog(invalidDiscounts, invalidGifts);
        }
      });
    }
    
    // 6. Nếu có thay đổi, tính lại tổng tiền
    if (hasChanges) {
      print('💰 Recalculating total after removing invalid discounts...');
      _recalculateTotalLocal();
      if (mounted) {
        setState(() {});
      }
    } else {
      print('💰 All restored discounts are valid');
    }
  }
  
  /// Hiển thị dialog báo chiết khấu/hàng tặng không còn hợp lệ
  void _showInvalidDiscountsDialog(List<String> invalidDiscounts, List<String> invalidGifts) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Cập nhật chiết khấu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Một số chiết khấu/hàng tặng không còn áp dụng cho đơn hàng hiện tại:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                if (invalidDiscounts.isNotEmpty) ...[
                  Text('• Chiết khấu đã bỏ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(height: 8),
                  ...invalidDiscounts.map((discount) => Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('- $discount', style: TextStyle(fontSize: 14)),
                  )),
                ],
                if (invalidGifts.isNotEmpty) ...[
                  if (invalidDiscounts.isNotEmpty) SizedBox(height: 12),
                  Text('• Hàng tặng đã bỏ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(height: 8),
                  ...invalidGifts.map((gift) => Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('- $gift', style: TextStyle(fontSize: 14)),
                  )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Đã hiểu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  
  void _recalculateTotalLocal() {
    print('💰 === Recalculating Total Locally ===');
    
    double totalMoney = 0;
    double totalDiscount = 0;
    double totalTax = 0;
    
    // Loop through all products
    for (var element in _bloc.listOrder) {
      if (element.isMark == 1 && element.gifProduct != true) {
        // ✅ QUAN TRỌNG: Trong edit mode, giaSuaDoi = priceAfter (giá sau chiết khấu) từ lineItem
        // Nên phải dùng element.price (giá gốc) làm originalPrice, không dùng giaSuaDoi
        // Check edit mode: có maCk hoặc giaSuaDoi != price (đã được set = priceAfter)
        bool isEditMode = (element.maCk != null && element.maCk.toString().trim().isNotEmpty) ||
                         (element.giaSuaDoi != null && element.price != null && 
                          element.giaSuaDoi! > 0 && element.price! > 0 && 
                          element.giaSuaDoi != element.price);
        
        double originalPrice = 0;
        if (isEditMode) {
          // ✅ EDIT MODE: Dùng price (giá gốc) làm originalPrice
          originalPrice = element.price ?? 0;
        } else {
          // ✅ CREATE MODE: Ưu tiên giaSuaDoi, sau đó price
          originalPrice = element.giaSuaDoi ?? 0;
          if (originalPrice == 0) {
            originalPrice = element.price ?? 0;
          }
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
        
        print('💰 Product ${element.code}: qty=$quantity, originalPrice=$originalPrice, priceAfter=$priceAfter, discountPercent=$discountPercent%, lineDiscount=${priceAfter < originalPrice && originalPrice > 0 ? (originalPrice - priceAfter) * quantity : 0}, lineTax=${Const.useTax == true ? ((priceAfter * quantity) * DataLocal.taxPercent) / 100 : 0}');
      }
    }
    
    // ✅ Tính totalPayment = totalMoney - totalDiscount - totalDiscountForOder + totalTax
    // totalMoney: Tổng tiền nguyên giá
    // totalDiscount: Tổng chiết khấu sản phẩm (CKG, CKN, HH)
    // totalDiscountForOder: Tổng chiết khấu tổng đơn (CKTDTT - Chiết khấu tổng đơn tặng tiền)
    // totalTax: Tổng thuế (nếu có)
    double totalDiscountForOder = _bloc.totalDiscountForOder ?? 0;
    double totalPayment = totalMoney - totalDiscount - totalDiscountForOder;
    if (Const.useTax == true) {
      totalPayment = totalPayment + totalTax;
    }
    
    // Update BLoC
    _bloc.totalMoney = totalMoney;
    _bloc.totalDiscount = totalDiscount;
    _bloc.totalTax = totalTax;
    _bloc.totalPayment = totalPayment;
    
    print('💰 Total Calculated:');
    print('    totalMoney = $totalMoney (tổng tiền nguyên giá)');
    print('    totalDiscount = $totalDiscount (tổng chiết khấu sản phẩm)');
    print('    totalDiscountForOder (CKTDTT) = $totalDiscountForOder (chiết khấu tổng đơn)');
    print('    totalTax = $totalTax (tổng thuế)');
    print('    totalPayment = $totalPayment (totalMoney - totalDiscount - totalDiscountForOder + totalTax)');
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
          code: hhItem.maVt?.trim() ?? '',
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
    _pendingCknGroupKey = groupKey;
    
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
    _pendingCktdthGroupKey = groupKey;

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

  // ✅ Helper function để tính và set ck_dac_biet từ các chiết khấu đã chọn
  void _updateCkDacBiet() {
    int? calculatedCkDacBiet = 0;
    
    // Check CKG đã chọn
    for (var ckgItem in _bloc.listCkg) {
      String maCk = (ckgItem.maCk ?? '').trim();
      if (maCk.isNotEmpty && _bloc.selectedCkgIds.contains(maCk)) {
        final ckDacBietValue = ckgItem.ck_dac_biet;
        if (ckDacBietValue != null) {
          int? ckDacBietInt;
          if (ckDacBietValue is int) {
            ckDacBietInt = ckDacBietValue;
          } else if (ckDacBietValue is String && ckDacBietValue.trim().isNotEmpty) {
            ckDacBietInt = int.tryParse(ckDacBietValue);
          } else if (ckDacBietValue is num) {
            ckDacBietInt = ckDacBietValue.toInt();
          }
          
          if (ckDacBietInt == 1) {
            calculatedCkDacBiet = 1;
            print('💰 ✅ Found CKG with ck_dac_biet = 1: maCk=$maCk');
            break;
          }
        }
      }
    }
    
    // ✅ Check HH đã chọn hoặc tự động áp dụng (chỉ nếu chưa tìm thấy từ CKG)
    if (calculatedCkDacBiet != 1) {
      for (var hhItem in _bloc.listHH) {
        String sttRecCk = (hhItem.sttRecCk ?? '').trim();
        
        // HH được tự động áp dụng hoặc user đã chọn
        // Check nếu HH có trong selectedHHIds hoặc được tự động áp dụng (có trong listPromotion string)
        bool isHHSelected = _bloc.selectedHHIds.contains(sttRecCk);
        bool isHHAutoApplied = _bloc.listPromotion.isNotEmpty && 
                               (_bloc.listPromotion == sttRecCk || 
                                _bloc.listPromotion.startsWith('$sttRecCk,') || 
                                _bloc.listPromotion.contains(',$sttRecCk,') || 
                                _bloc.listPromotion.endsWith(',$sttRecCk'));
        
        if (isHHSelected || isHHAutoApplied) {
          final ckDacBietValue = hhItem.ck_dac_biet;
          if (ckDacBietValue != null) {
            int? ckDacBietInt;
            if (ckDacBietValue is int) {
              ckDacBietInt = ckDacBietValue;
            } else if (ckDacBietValue is String && ckDacBietValue.trim().isNotEmpty) {
              ckDacBietInt = int.tryParse(ckDacBietValue);
            } else if (ckDacBietValue is num) {
              ckDacBietInt = ckDacBietValue.toInt();
            }
            
            if (ckDacBietInt == 1) {
              calculatedCkDacBiet = 1;
              print('💰 ✅ Found HH with ck_dac_biet = 1: sttRecCk=$sttRecCk, maCk=${hhItem.maCk}');
              break;
            }
          }
        }
      }
    }
    
    // Check CKTDTT đã chọn (chỉ nếu chưa tìm thấy từ CKG hoặc HH)
    if (calculatedCkDacBiet != 1) {
      for (var cktdttItem in _bloc.listCktdtt) {
        String sttRecCk = (cktdttItem.sttRecCk ?? '').trim();
        String cktdttId = sttRecCk;
        
        if (_bloc.selectedCktdttIds.contains(cktdttId)) {
          final ckDacBietValue = cktdttItem.ck_dac_biet;
          if (ckDacBietValue != null) {
            int? ckDacBietInt;
            if (ckDacBietValue is int) {
              ckDacBietInt = ckDacBietValue;
            } else if (ckDacBietValue is String && ckDacBietValue.trim().isNotEmpty) {
              ckDacBietInt = int.tryParse(ckDacBietValue);
            } else if (ckDacBietValue is num) {
              ckDacBietInt = ckDacBietValue.toInt();
            }
            
            if (ckDacBietInt == 1) {
              calculatedCkDacBiet = 1;
              print('💰 ✅ Found CKTDTT with ck_dac_biet = 1: cktdttId=$cktdttId');
              break;
            }
          }
        }
      }
    }
    
    // Set vào bloc
    _bloc.ck_dac_biet = calculatedCkDacBiet;
    if (calculatedCkDacBiet == 1) {
      print('💰 ✅ Updated bloc.ck_dac_biet = 1');
    } else {
      print('💰 ℹ️ Updated bloc.ck_dac_biet = 0');
    }
  }

  // Handle CKG selection (when user clicks checkbox - apply immediately)
  // ✅ CHANGED: ckgId giờ là maCk, apply cho tất cả CKG items cùng ma_ck
  void _handleCKGSelection(String maCk, ListCk ckgItem) {
    print('💰 ========== CKG SELECTION START ==========');
    print('💰 CKG: User selecting discount for maCk=$maCk');
    print('💰 CKG Item: sttRecCk=${ckgItem.sttRecCk}, maVt=${ckgItem.maVt}, maCk=${ckgItem.maCk}, tenCk=${ckgItem.tenCk}');
    print('💰 CKG Item: tlCk=${ckgItem.tlCk}, ck=${ckgItem.ck}, giaSauCk=${ckgItem.giaSauCk}');
    
    // Update BLoC state - dùng maCk làm key
    _bloc.selectedCkgIds.add(maCk);
    print('💰 Updated selectedCkgIds: ${_bloc.selectedCkgIds}');
    
    // Apply CKG discount cho tất cả items cùng ma_ck
    _applyCKGByMaCk(maCk, shouldApply: true);
    
    // ✅ Tính lại ck_dac_biet sau khi chọn CKG
    _updateCkDacBiet();
    
    print('💰 ========== CKG SELECTION END ==========');
  }

  // Handle CKG removal (when user unchecks checkbox - remove immediately)
  // ✅ CHANGED: ckgId giờ là maCk, remove cho tất cả CKG items cùng ma_ck
  void _handleRemoveCKG(String maCk, ListCk ckgItem) {
    print('💰 CKG: User removing discount for maCk=$maCk');
    
    // Update BLoC state
    _bloc.selectedCkgIds.remove(maCk);
    
    // Remove CKG discount cho tất cả items cùng ma_ck
    _applyCKGByMaCk(maCk, shouldApply: false);
    
    // ✅ Tính lại ck_dac_biet sau khi bỏ chọn CKG
    _updateCkDacBiet();
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
    
    // ✅ Tính lại ck_dac_biet sau khi chọn CKTDTT
    _updateCkDacBiet();
    
    print('💰 ========== CKTDTT SELECTION END ==========');
  }

  // Handle CKTDTT removal (when user unchecks checkbox - remove immediately)
  void _handleRemoveCKTDTTS(String cktdttId, ListCkTongDon cktdttItem) {
    print('💰 CKTDTT: User removing discount for $cktdttId');
    
    // Update BLoC state
    _bloc.selectedCktdttIds.remove(cktdttId);
    
    // Remove CKTDTT discount immediately
    _applySingleCKTDTT(cktdttId, cktdttItem, shouldApply: false);
    
    // ✅ Tính lại ck_dac_biet sau khi bỏ chọn CKTDTT
    _updateCkDacBiet();
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

  // ✅ NEW: Apply CKG discount cho tất cả items cùng ma_ck
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
      // Tạo ckgId từ sttRecCk và productCode để dùng với _applySingleCKG
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
            
            // ✅ Get original price (giá gốc)
            // QUAN TRỌNG: Trong edit mode, giaSuaDoi = priceAfter (giá sau chiết khấu) từ lineItem
            // Nên phải dùng product.price (giá gốc) làm originalPrice, không dùng giaSuaDoi
            // Check edit mode: có maCk hoặc giaSuaDoi != price (đã được set = priceAfter)
            bool isEditMode = (product.maCk != null && product.maCk.toString().trim().isNotEmpty) ||
                             (product.giaSuaDoi != null && product.price != null && 
                              product.giaSuaDoi! > 0 && product.price! > 0 && 
                              product.giaSuaDoi != product.price);
            
            double originalPrice = 0;
            if (isEditMode) {
              // ✅ EDIT MODE: Dùng price (giá gốc) làm originalPrice
              originalPrice = product.price ?? 0;
              if (originalPrice == 0 && ckgItem.giaGoc != null && ckgItem.giaGoc! > 0) {
                originalPrice = ckgItem.giaGoc!.toDouble();
              }
              print('💰 [EDIT MODE] originalPrice from product.price: $originalPrice (giaSuaDoi=${product.giaSuaDoi} is priceAfter)');
            } else {
              // ✅ CREATE MODE: Ưu tiên giaSuaDoi, sau đó price, cuối cùng giaGoc từ CKG
              originalPrice = product.giaSuaDoi ?? 0;
              if (originalPrice == 0) {
                originalPrice = product.price ?? 0;
              }
              if (originalPrice == 0 && ckgItem.giaGoc != null && ckgItem.giaGoc! > 0) {
                originalPrice = ckgItem.giaGoc!.toDouble();
              }
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
    String? groupKey,
  }) async {
    final String effectiveGroupKey = (groupKey ??
            discountItems.first.group_dk?.toString() ??
            discountItems.first.sttRecCk?.toString() ??
            '')
        .trim();
    
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

    if (result == null || result.isEmpty) {
      _handleGiftSelectionCancelled(discountType, effectiveGroupKey);
      return;
    }

    // Process selected products
    _processSelectedGiftProducts(result, discountItems.first, discountType, effectiveGroupKey);
  }

  void _handleGiftSelectionCancelled(String discountType, String groupKey, {bool showToast = true}) {
    if (groupKey.isEmpty) return;
    if (discountType == 'CKN') {
      _bloc.selectedCknGroups.remove(groupKey);
      _discountSheetKey?.currentState?.unselectCknGroup(groupKey);
    } else if (discountType == 'CKTDTH') {
      _bloc.selectedCktdthGroups.remove(groupKey);
      _discountSheetKey?.currentState?.unselectCktdthGroup(groupKey);
    }
    
    if (showToast) {
      Utils.showCustomToast(
        context,
        Icons.info_outline,
        'Chưa chọn sản phẩm tặng',
      );
    }
    setState(() {});
  }

  void _processSelectedGiftProducts(
    Map<String, double> selectedQuantities,
    ListCkMatHang discountItem,
    String discountType, // 'CKN' or 'CKTDTH'
    String groupKey,
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
      
      if (groupKey.isNotEmpty) {
        if (discountType == 'CKN') {
          if (!_bloc.selectedCknGroups.contains(groupKey)) {
            _bloc.selectedCknGroups.add(groupKey);
          }
        } else if (discountType == 'CKTDTH') {
          if (!_bloc.selectedCktdthGroups.contains(groupKey)) {
            _bloc.selectedCktdthGroups.add(groupKey);
          }
        }
      }

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



  Widget buildMethodReceive() {
    return CartMethodReceive(
      bloc: _bloc,
      maGD: maGD,
      buildInfoCallOtherPeople: () => buildInfoCallOtherPeople(),
      transactionWidget: () => transactionWidget(),
      typeOrderWidget: () => typeOrderWidget(),
      genderWidget: () => genderWidget(),
      genderTaxWidget: () => genderTaxWidget(),
      typePaymentWidget: () => typePaymentWidget(),
      typeDeliveryWidget: () => typeDeliveryWidget(),
      buildPopupVvHd: () => buildPopupVvHd(),
      onStateChanged: () => setState(() {}),
    );
  }

  Widget buildInfoCallOtherPeople() {
    
    // QUAN TRỌNG: Đảm bảo controller được set từ widget.codeCustomer TRƯỚC KHI build widget
    // Vì widget có thể được build trước khi GetPrefsSuccess chạy
    if (widget.codeCustomer != null && 
        widget.codeCustomer.toString().trim().isNotEmpty &&
        widget.codeCustomer.toString().trim() != 'null') {
      // Nếu controller đang trống nhưng widget có data, set lại ngay
      if (nameCustomerController.text.trim().isEmpty && widget.nameCustomer != null) {
        nameCustomerController.text = widget.nameCustomer.toString();
        nameCustomerController.notifyListeners();
      }
      if (phoneCustomerController.text.trim().isEmpty && widget.phoneCustomer != null) {
        print('💾   - Setting controller from widget.phoneCustomer: ${widget.phoneCustomer}');
        phoneCustomerController.text = widget.phoneCustomer.toString();
        phoneCustomerController.notifyListeners();
      }
      if (addressCustomerController.text.trim().isEmpty && widget.addressCustomer != null) {
        print('💾   - Setting controller from widget.addressCustomer: ${widget.addressCustomer}');
        addressCustomerController.text = widget.addressCustomer.toString();
        addressCustomerController.notifyListeners();
      }
      
      // Cũng set vào DataLocal để widget có thể đọc được
      if (DataLocal.infoCustomer.customerCode.toString().isEmpty || 
          DataLocal.infoCustomer.customerCode.toString() == 'null') {
        DataLocal.infoCustomer.customerCode = widget.codeCustomer;
        DataLocal.infoCustomer.customerName = widget.nameCustomer ?? '';
        DataLocal.infoCustomer.phone = widget.phoneCustomer ?? '';
        DataLocal.infoCustomer.address = widget.addressCustomer ?? '';
      }
    }
    
    return CartCustomerInfoWidget(
      bloc: _bloc,
      nameCustomerController: nameCustomerController,
      phoneCustomerController: phoneCustomerController,
      addressCustomerController: addressCustomerController,
      nameCustomerFocus: nameCustomerFocus,
      phoneCustomerFocus: phoneCustomerFocus,
      addressCustomerFocus: addressCustomerFocus,
      isContractCreateOrder: widget.isContractCreateOrder ?? false,
      orderFromCheckIn: widget.orderFromCheckIn,
      addInfoCheckIn: widget.addInfoCheckIn ?? false,
      inputWidget: ({
        String? title,
        String? hideText,
        IconData? iconPrefix,
        IconData? iconSuffix,
        bool? isEnable,
        TextEditingController? controller,
        Function? onTapSuffix,
        Function? onSubmitted,
        FocusNode? focusNode,
        TextInputAction? textInputAction,
        bool inputNumber = false,
        bool note = false,
        bool isPassWord = false,
      }) {
        return inputWidget(
          title: title,
          hideText: hideText,
          iconPrefix: iconPrefix,
          iconSuffix: iconSuffix,
          isEnable: isEnable,
          controller: controller,
          onTapSuffix: onTapSuffix,
          onSubmitted: onSubmitted,
          focusNode: focusNode,
          textInputAction: textInputAction,
          inputNumber: inputNumber,
                        note: note,
          isPassWord: isPassWord,
        );
      },
      onStateChanged: () => setState(() {}),
    );
  }

  // Helper widgets moved to CartHelperWidgets class
  String maGD = '';
  
  Widget typePaymentWidget() => CartHelperWidgets.typePaymentWidget(_bloc);
  Widget typeChooseTypeDelivery() => CartHelperWidgets.typeChooseTypeDelivery(_bloc);
  Widget typeDeliveryWidget() => CartHelperWidgets.typeChooseTypeDelivery(_bloc); // Alias for typeChooseTypeDelivery
  Widget transactionWidget() => CartHelperWidgets.transactionWidget(_bloc, (maGDValue) {
    maGD = maGDValue;
  });
  Widget typeOrderWidget() => CartHelperWidgets.typeOrderWidget();
  Widget genderTaxWidget() => CartHelperWidgets.genderTaxWidget(
    context,
    _bloc,
    (index) {
      indexValuesTax = index;
    },
    // ✅ Callback để load tax list từ API khi mở bottom sheet
    () async {
      try {
        // Call API để lấy danh sách thuế thông qua CartBloc
        // Sử dụng SellBloc nếu có, hoặc call trực tiếp qua NetworkFactory
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
  );
  Widget genderWidget() => CartHelperWidgets.genderWidget(_bloc);
  Widget inputWidget({String? title,String? hideText,IconData? iconPrefix,IconData? iconSuffix, bool? isEnable,
    TextEditingController? controller,Function? onTapSuffix, Function? onSubmitted,FocusNode? focusNode,
    TextInputAction? textInputAction,bool inputNumber = false,bool note = false,bool isPassWord = false}) {
    return CartHelperWidgets.inputWidget(
      title: title,
      hideText: hideText,
      iconPrefix: iconPrefix,
      iconSuffix: iconSuffix,
      isEnable: isEnable,
      controller: controller,
      onTapSuffix: onTapSuffix,
      onSubmitted: onSubmitted,
              focusNode: focusNode,
      textInputAction: textInputAction,
      inputNumber: inputNumber,
      note: note,
      isPassWord: isPassWord,
    );
  }

  Widget buildOtherRequest() {
    return CartOtherRequestWidget(
      bloc: _bloc,
      buildAttachFileInvoice: () => buildAttachFileInvoice(),
      buildInfoInvoice: () => buildInfoInvoice(),
      buildCheckboxList: (title, value, index) =>
          CartHelperWidgets.buildCheckboxList(title, value, index, _bloc),
    );
  }

  Widget buildAttachFileInvoice() {
    return CartAttachFileInvoiceWidget(
      bloc: _bloc,
      start: start,
      waitingLoad: waitingLoad,
      getImage: getImage,
      openImageFullScreen: openImageFullScreen,
      onStateChanged: () => setState(() {}),
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

  Widget buildInfoInvoice() {
    return CartInfoInvoiceWidget(
      nameCompanyController: nameCompanyController,
      mstController: mstController,
      addressCompanyController: addressCompanyController,
      noteController: noteController,
      nameCompanyFocus: nameCompanyFocus,
      mstFocus: mstFocus,
      addressFocus: addressFocus,
      noteFocus: noteFocus,
      inputWidget: ({
        String? title,
        String? hideText,
        IconData? iconPrefix,
        IconData? iconSuffix,
        bool? isEnable,
        TextEditingController? controller,
        Function? onTapSuffix,
        Function? onSubmitted,
        FocusNode? focusNode,
        TextInputAction? textInputAction,
        bool inputNumber = false,
        bool note = false,
        bool isPassWord = false,
      }) {
        return inputWidget(
          title: title,
          hideText: hideText,
          iconPrefix: iconPrefix,
          iconSuffix: iconSuffix,
          isEnable: isEnable,
          controller: controller,
          onTapSuffix: onTapSuffix,
          onSubmitted: onSubmitted,
          focusNode: focusNode,
          textInputAction: textInputAction,
          inputNumber: inputNumber,
          note: note,
          isPassWord: isPassWord,
        );
      },
    );
  }

  Widget customWidgetPayment(String title, String subtitle, int discount, String codeDiscount) {
    return CartHelperWidgets.customWidgetPayment(title, subtitle, discount, codeDiscount);
  }
}
