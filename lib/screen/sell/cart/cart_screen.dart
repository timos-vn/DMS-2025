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

  const CartScreen({Key? key,this.sttRec,this.addInfoCheckIn,this.viewUpdateOrder,this.listOrder,this.currencyCode,this.viewDetail,this.nameCustomer,this.idCustomer,
    this.phoneCustomer,this.addressCustomer,this.nameStore,this.codeStore,this.codeCustomer,this.itemGroupCode,this.listIdGroupProduct, this.dateOrder,
    required this.orderFromCheckIn, required this.title, this.description, required this.loadDataLocal, this.sttRectHD, this.isContractCreateOrder = false,this.contractMaster}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin{
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
      
      _bloc.add(GetListItemApplyDiscountEvent(
        listCKVT: DataLocal.listCKVT,
        listPromotion: _bloc.listPromotion,
        listItem: listItem,
        listQty: listQty,
        listPrice: listPrice,
        listMoney: listMoney,
        warehouseId: finalWarehouseId,
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
      print('💾 Loading existing order: widget.listOrder.length=${widget.listOrder?.length ?? 0}');
      print('💾   - _bloc.listProductOrder.length=${_bloc.listProductOrder.length}');
      print('💾   - _bloc.listOrder.length=${_bloc.listOrder.length} (before GetListProductFromDB)');
      
      if(Const.stockList.isNotEmpty){
        _bloc.storeCode = Const.stockList[_bloc.storeIndex].stockCode;
      }
      _bloc.add(GetListProductFromDB(addOrderFromCheckIn: widget.orderFromCheckIn, getValuesTax: false,key: ''));
    }
    if(widget.viewUpdateOrder == true){
      print('💾 Setting up edit order mode...');
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
        final restored = await CartDraftStorage.restoreDraft(_bloc);
        if (restored) {
          print('💾 ✅ Draft restored successfully!');
          print('💾 After restore:');
          print('💾   - bloc.listOrder.length = ${_bloc.listOrder.length}');
          print('💾   - DataLocal.listProductGift.length = ${DataLocal.listProductGift.length}');
          print('💾   - bloc.totalMoney = ${_bloc.totalMoney}');
          print('💾   - bloc.totalPayment = ${_bloc.totalPayment}');
          print('💾   - bloc.customerName = ${_bloc.customerName}');
          print('💾   - bloc.codeCustomer = ${_bloc.codeCustomer}');
          
          // Print chi tiết từng sản phẩm
          for (int i = 0; i < _bloc.listOrder.length; i++) {
            final item = _bloc.listOrder[i];
            print('💾   Product[$i]: code=${item.code}, name=${item.name}, count=${item.count}, price=${item.price}');
          }
          
          // Print chi tiết từng sản phẩm tặng
          for (int i = 0; i < DataLocal.listProductGift.length; i++) {
            final gift = DataLocal.listProductGift[i];
            print('💾   Gift[$i]: code=${gift.code}, name=${gift.name}, count=${gift.count}');
          }
          
          // Refresh UI sau khi restore
          if (mounted) {
            setState(() {});
          }
        } else {
          print('💾 ❌ No draft to restore or restore failed');
        }
      } else {
        print('💾 Skip restore: isNewOrder=$isNewOrder, listOrder.isEmpty=${_bloc.listOrder.isEmpty}, listProductGift.isEmpty=${DataLocal.listProductGift.isEmpty}');
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
    if(widget.codeCustomer != null && 
       widget.codeCustomer.toString().trim().replaceAll('null', '').isNotEmpty){
      print('💾 initState: Setting customer info from widget');
      print('💾   - widget.codeCustomer = ${widget.codeCustomer}');
      print('💾   - widget.nameCustomer = ${widget.nameCustomer}');
      nameCustomerController.text = widget.nameCustomer?.toString() ?? '';
      phoneCustomerController.text = widget.phoneCustomer?.toString() ?? '';
      addressCustomerController.text = widget.addressCustomer?.toString() ?? '';
      _bloc.customerName = widget.nameCustomer;
      _bloc.codeCustomer = widget.codeCustomer;
      _bloc.addressCustomer = widget.addressCustomer;
      _bloc.phoneCustomer = widget.phoneCustomer;
      print('💾   - _bloc.codeCustomer set to = ${_bloc.codeCustomer}');
    } else {
      print('💾 initState: widget.codeCustomer is null or empty');
      print('💾   - widget.codeCustomer = ${widget.codeCustomer}');
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
      if (isNewOrder && (_bloc.listOrder.isNotEmpty || DataLocal.listProductGift.isNotEmpty)) {
        // Lưu draft bất đồng bộ (không await để không block dispose)
        CartDraftStorage.saveDraft(_bloc).then((_) {
          print('💾 Draft auto-saved on dispose (user back from new order)');
        }).catchError((e) {
          print('💾 Error auto-saving draft on dispose: $e');
        });
      }
    }
    
    _timer.cancel();
    tabController.dispose();
    super.dispose();
  }

  /// Lưu draft tự động (không show dialog) - gọi khi có thay đổi
  Future<void> _autoSaveDraft() async {
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

  /// Lưu draft với dialog loading và thông báo thành công
  Future<void> _saveDraftWithDialog() async {
    print('💾 _saveDraftWithDialog called: viewUpdateOrder=${widget.viewUpdateOrder}, listOrder.length=${_bloc.listOrder.length}, listProductGift.length=${DataLocal.listProductGift.length}');
    
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
      print('💾 Không có dữ liệu để lưu, cho phép pop ngay');
      // Không có gì để lưu, cho phép pop ngay
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
          final finalCodeCustomer = (widget.codeCustomer != null && 
                                      widget.codeCustomer.toString().trim().isNotEmpty && 
                                      widget.codeCustomer.toString().trim() != 'null')
              ? widget.codeCustomer
              : ((DataLocal.infoCustomer.customerCode.toString().isNotEmpty && 
                  DataLocal.infoCustomer.customerCode.toString() != 'null')
                  ? DataLocal.infoCustomer.customerCode
                  : _bloc.codeCustomer);
          
          final finalCustomerName = (widget.nameCustomer != null && 
                                      widget.nameCustomer.toString().trim().isNotEmpty && 
                                      widget.nameCustomer.toString().trim() != 'null')
              ? widget.nameCustomer
              : ((DataLocal.infoCustomer.customerName.toString().isNotEmpty && 
                  DataLocal.infoCustomer.customerName.toString() != 'null')
                  ? DataLocal.infoCustomer.customerName
                  : _bloc.customerName);
          
          final finalPhone = (widget.phoneCustomer != null && 
                              widget.phoneCustomer.toString().trim().isNotEmpty && 
                              widget.phoneCustomer.toString().trim() != 'null')
              ? widget.phoneCustomer
              : ((DataLocal.infoCustomer.phone.toString().isNotEmpty && 
                  DataLocal.infoCustomer.phone.toString() != 'null')
                  ? DataLocal.infoCustomer.phone
                  : _bloc.phoneCustomer);
          
          final finalAddress = (widget.addressCustomer != null && 
                                widget.addressCustomer.toString().trim().isNotEmpty && 
                                widget.addressCustomer.toString().trim() != 'null')
              ? widget.addressCustomer
              : ((DataLocal.infoCustomer.address.toString().isNotEmpty && 
                  DataLocal.infoCustomer.address.toString() != "null")
                  ? DataLocal.infoCustomer.address
                  : _bloc.addressCustomer);
          
          print('💾 PickInfoCustomer - Final values:');
          print('💾   - finalCodeCustomer = $finalCodeCustomer');
          print('💾   - finalCustomerName = $finalCustomerName');
          print('💾   - widget.codeCustomer = ${widget.codeCustomer}');
          print('💾   - DataLocal.infoCustomer.customerCode = ${DataLocal.infoCustomer.customerCode}');
          print('💾   - _bloc.codeCustomer = ${_bloc.codeCustomer}');
          
          _bloc.add(PickInfoCustomer(
            customerName: finalCustomerName,
            phone: finalPhone,
            address: finalAddress,
            codeCustomer: finalCodeCustomer,
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
          print('💾 GetListProductFromDBSuccess triggered');
          print('💾 Current state: listOrder.length=${_bloc.listOrder.length}, listProductOrderAndUpdate.length=${_bloc.listProductOrderAndUpdate.length}');
          
          // ✅ Tự động lưu draft sau khi có thay đổi sản phẩm (xóa, cập nhật số lượng, v.v.)
          // Chỉ lưu khi key != 'First' (không phải lần load đầu tiên)
          if (state.key != 'First') {
            _autoSaveDraft();
          }
          
          // ✅ Restore listOrder từ draft nếu GetListProductFromDB làm mất listOrder (khi tạo đơn mới)
          final isNewOrder = widget.sttRec == null || widget.sttRec!.trim().isEmpty;
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
              CartDraftStorage.restoreDraft(_bloc).then((restored) {
                if (restored && mounted) {
                  print('💾 ✅ Restored listOrder from draft in GetListProductFromDBSuccess - listOrder.length=${_bloc.listOrder.length}');
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
          
          if(_bloc.listProductOrderAndUpdate.isNotEmpty){
            print('💾 listProductOrderAndUpdate is not empty, calling getDiscountProduct');
            print('💾   - listProductOrderAndUpdate.length = ${_bloc.listProductOrderAndUpdate.length}');
            getDiscountProduct(state.key);
          }
          else {
            print('💾 ⚠️ listProductOrderAndUpdate is empty');
            print('💾   - listOrder.length = ${_bloc.listOrder.length}');
            print('💾   - state.key = ${state.key}');
            
            // ✅ CHỈ clear listOrder nếu key == 'First' (lần load đầu tiên)
            // Nếu key != 'First' và listOrder không rỗng, có thể đang có sản phẩm từ draft hoặc vừa thêm
            // Không clear để tránh mất sản phẩm vừa thêm
            if (state.key == 'First' || state.key == '') {
              print('💾 Clearing listOrder (key is First or empty)');
              print('💾   Before clear: listOrder.length=${_bloc.listOrder.length}');
              _bloc.listItemOrder.clear();
              _bloc.listOrder.clear();
              _bloc.listCkTongDon.clear();
              _bloc.listCkMatHang.clear();
              _bloc.totalMoney = 0;
              _bloc.totalDiscount = 0;
              _bloc.totalPayment = 0;
              Const.listKeyGroupCheck = '';
              Const.listKeyGroup = '';
              print('💾   After clear: listOrder.length=${_bloc.listOrder.length}');
              
              // ✅ Nếu đang tạo đơn mới và listOrder bị clear, restore từ draft
              final isNewOrder = widget.sttRec == null || widget.sttRec!.trim().isEmpty;
              if (isNewOrder && (widget.listOrder == null || widget.listOrder!.isEmpty)) {
                print('💾 Attempting to restore draft after listOrder was cleared...');
                CartDraftStorage.restoreDraft(_bloc).then((restored) {
                  if (restored && mounted) {
                    print('💾 ✅ Restored draft after listOrder was cleared - listOrder.length=${_bloc.listOrder.length}');
                    setState(() {});
                  } else {
                    print('💾 ❌ Failed to restore draft after listOrder was cleared');
                  }
                });
              }
            } else {
              print('💾 Skip clear listOrder - key is not First (key=${state.key}), may have products from draft or just added');
              print('💾   - Keeping listOrder.length = ${_bloc.listOrder.length}');
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
            print('💾 GetListProductFromDBSuccess in edit mode:');
            print('💾   - _bloc.listOrder.length=${_bloc.listOrder.length}');
            print('💾   - _bloc.listProductOrderAndUpdate.length=${_bloc.listProductOrderAndUpdate.length}');
            print('💾   - DataLocal.listProductGift.length=${DataLocal.listProductGift.length}');
            print('💾   - Draft should NOT be affected (still in database)');
            
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
          // ✅ Tự động lưu draft sau khi thay đổi thông tin khách hàng
          _autoSaveDraft();
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
          DataLocal.listProductGift.clear();
          _persistGiftProducts();
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
          _persistGiftProducts();
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
          _persistGiftProducts();
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
            print('💾 AddOrDeleteProductGiftSuccess: Auto-saving draft');
            print('💾   - DataLocal.listProductGift.length = ${DataLocal.listProductGift.length}');
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
              print('🔙 PopScope onPopInvoked: didPop=$didPop, viewUpdateOrder=${widget.viewUpdateOrder}');
              if (!didPop) {
                // ✅ Lưu draft khi user back ra khỏi màn hình tạo đơn mới (nếu có dữ liệu)
                // Sử dụng WidgetsBinding để đảm bảo context còn available
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  print('🔙 addPostFrameCallback called, mounted=$mounted');
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
    final handler = CartOrderHandler(
      context: context,
      bloc: _bloc,
      viewUpdateOrder: widget.viewUpdateOrder,
      sttRec: widget.sttRec,
      currencyCode: widget.currencyCode,
      dateOrder: widget.dateOrder,
      isContractCreateOrder: widget.isContractCreateOrder,
      sttRectHD: widget.sttRectHD,
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

  // Old createOrder method - kept for reference, can be removed later
  void _createOrderOld(){
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
    
    _discountSheetKey = GlobalKey<DiscountVoucherSelectionSheetState>();
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
      
      // Call API to recalculate discounts
      _bloc.add(GetListItemApplyDiscountEvent(
        listCKVT: DataLocal.listCKVT,
        listPromotion: _bloc.listPromotion,
        listItem: listItem,
        listQty: listQty,
        listPrice: listPrice,
        listMoney: listMoney,
        warehouseId: finalWarehouseId,
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
    double totalTax = 0;
    
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
        
        // ✅ Calculate tax nếu có sử dụng thuế
        if (Const.useTax == true && priceAfter > 0) {
          double taxPercent = DataLocal.taxPercent;
          double lineTax = ((priceAfter * quantity) * taxPercent) / 100;
          totalTax += lineTax;
          
          // Update element.valuesTax để đảm bảo UI hiển thị đúng
          element.valuesTax = lineTax / quantity; // Tax per unit
        }
        
        double discountPercent = (element.discountPercentByHand ?? 0) > 0 
          ? (element.discountPercentByHand ?? 0) 
          : (element.discountPercent ?? 0);
        
        print('💰 Product ${element.code}: qty=$quantity, originalPrice=$originalPrice, priceAfter=$priceAfter, discountPercent=$discountPercent%, lineDiscount=${(originalPrice - priceAfter) * quantity}, lineTax=${Const.useTax == true ? ((priceAfter * quantity) * DataLocal.taxPercent) / 100 : 0}');
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
    
    // Check CKTDTT đã chọn (chỉ nếu chưa tìm thấy từ CKG)
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
