
import 'package:flutter/services.dart';
import 'package:gs1_barcode_parser/gs1_barcode_parser.dart';
import 'package:dms/model/network/response/get_list_history_dnnk_response.dart';
import 'package:dms/model/network/request/item_location_modify_requset.dart';
import 'package:dms/screen/qr_code/qr_code_bloc.dart';
import 'package:dms/screen/qr_code/qr_code_sate.dart';
import 'package:dms/widget/barcode_scanner_widget.dart';
import 'package:dms/widget/custom_confirm_2.dart';
import 'package:dms/screen/qr_code/component/custom_update_barcode.dart';
import 'package:dms/widget/input_quantity_shipping_popup.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';

import '../../../model/network/request/update_item_barcode_request.dart';
import '../../../model/network/request/update_quantity_warehouse_delivery_card_request.dart';
import '../../../model/network/response/get_info_card_response.dart';
import '../../../model/network/response/qr_code_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/images.dart';
import '../../../utils/utils.dart';
import '../../filter/filter_page.dart';
import '../qr_code_event.dart';

class ViewInformationCardScreen extends StatefulWidget {
  final String nameCard;
  final FormatProvider formatProvider;
  final List<ListItem> listItemCard;
  final RuleActionInfoCard ruleActionInformationCard;
  final MasterInfoCard masterInformationCard;
  final String keyFunction;
  final QRCodeBloc? bloc; // Thêm bloc parameter

  const ViewInformationCardScreen({super.key, required this.formatProvider,required this.nameCard, required this.masterInformationCard, required this.ruleActionInformationCard,
    required this.listItemCard,
    required this.keyFunction, this.bloc});

  @override
  State<ViewInformationCardScreen> createState() => _ViewInformationCardScreenState();

  /// Static method để xử lý barcode từ custom_qr_code.dart - Sử dụng BarcodeHelper
  static Future<void> handleBarcodeScanStatic(String barcode, QRCodeBloc bloc, String keyFunction, BuildContext context) async {
    // Validate barcode
    if (barcode.isEmpty || barcode.trim().isEmpty || barcode.length < 3 || barcode.length > 100) {
      Utils.showCustomToast(context, Icons.warning_amber, 'Mã barcode không hợp lệ - Vui lòng quét lại');
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final valueScan = barcode.trim();

    // ✅ Bỏ kiểm tra status của dữ liệu cũ - cho phép quét dữ liệu mới
    // Status sẽ được kiểm tra sau khi có response từ server

    // Xử lý barcode trực tiếp
    if (valueScan.contains('key')) {
      // Xử lý QR code đặc biệt
      debugPrint('Processing special QR code: $valueScan');
    } else {
      // Xử lý barcode thông thường
      bloc.add(GetInformationItemFromBarCodeEvent(barcode: valueScan, pallet: ''));
    }
  }


  /// Action 1: Cập nhật số liệu (không back)
  /// Action 2: Xác nhận phiếu (back về màn hình trước)




}

class _ViewInformationCardScreenState extends State<ViewInformationCardScreen> with TickerProviderStateMixin{

  late TabController tabController;
  late QRCodeBloc _bloc;

  String codeTransfer = '';
  String nameTransfer = '';
  String valuesBarcode = '';
  bool isProcessing = false;
  bool checkItemExits = false;
  bool viewQRCode = true;
  int indexSelected = -1;
  int tabIndex = 0;
  
  // ✅ API loading state để block quét khi đang call API
  bool isApiLoading = false;
  
  // ✅ Additional variables from SSE-Scanner
  List<ItemLocationModifyRequestDetail> listItem = [];
  QrcodeResponse qrcodePallet = QrcodeResponse();
  
  
  // GetStorage instance
  GetStorage box = GetStorage();
  // ✅ Tab definitions theo keyFunction - Logic từ SSE-Scanner
  List<String> get listTabs {
    switch (widget.keyFunction) {
      case '#1': // Cập nhật số lượng
        return ['Sản phẩm', 'Lịch sử', 'Thông tin'];
      case '#3': // Cập nhật vị trí  
        return ['Sản phẩm', 'Lịch sử', 'Thông tin'];
      case '#4': // Cập nhật pallet
        return ['Sản phẩm', 'Lịch sử', 'Thông tin'];
      case '#5': // Cập nhật lô hàng
        return ['Sản phẩm', 'Thông tin'];
      case '#6': // Lên phiếu giao hàng
        return ['Sản phẩm', 'Thông tin'];
      case '#7': // Cập nhật ngày sản xuất
        return ['Sản phẩm', 'Lịch sử', 'Thông tin'];
      case '#8': // Cập nhật số lượng
        return ['Sản phẩm', 'Lịch sử', 'Thông tin'];
      default:
        return ['Sản phẩm', 'Thông tin'];
    }
  }
  String licensePlates = '';
  
  // ✅ Camera instance riêng cho màn hình này
  final GlobalKey _cameraKey = GlobalKey();
  List<ListItem> listItemCard = [];

  // Enhanced features from ScannerOtherFunction
  String valueScan = '';
  bool showPopUp = false;
  late final GS1BarcodeParser _gs1Parser;
  
  // Additional fields from SSE-Scanner
  String typeBarcode = '';
  bool getInformationBarcodeWithBarcode = true;
  List<String> listPhieu = ['Pallet'];
  bool isLoad = false;
  bool isNextScreen = false;
  double totalQtyForFilter = 0;
  double totalKgForFilter = 0;
  
  // ✅ Flag để track việc xóa và cần reload
  bool _hasDeletedItems = false;

  @override
  void initState() {
    super.initState();
    isProcessing = false;
    isApiLoading = false;
    
    // Sử dụng bloc được truyền từ parent hoặc tạo mới nếu không có
    _bloc = widget.bloc ?? QRCodeBloc(context);
    listItemCard.addAll(widget.listItemCard);
    
    // Initialize variables from SSE-Scanner

    licensePlates = widget.masterInformationCard.licensePlates ?? '';
    
    // Đồng bộ actualQuantity với dữ liệu từ lịch sử quét
    _syncActualQuantityFromHistory();
    codeTransfer = widget.masterInformationCard.tenHtvc ?? '';
    nameTransfer = widget.masterInformationCard.tenHtvc ?? '';
    
    tabController = TabController(vsync: this, length: listTabs.length);
    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
      });
    });
    
    
    if(widget.keyFunction == '#1' || widget.keyFunction == '#3' || widget.keyFunction == '#4' || widget.keyFunction == '#7' || widget.keyFunction == '#8'){
      // ✅ Kiểm tra cache trước, nếu có thì dùng cache, nếu không thì gọi API
      _loadHistoryData();
    }
    
    // Initialize GS1 parser
    _gs1Parser = GS1BarcodeParser.defaultParser();
    
    // Initialize enhanced features
    // TTS disabled
    
    // Auto select first product if listItemCard is not empty
    if (listItemCard.isNotEmpty && indexSelected == -1) {
      setState(() {
        indexSelected = 0;
        listItemCard[0].isMark = 1; // Mark first item as selected
      });
      debugPrint('Auto selected first product with index: 0');
    }
    _initializeEnhancedFeatures();
  }



  void _initializeEnhancedFeatures() async {
    // TTS disabled
  }

  void _updateItemBarCodeWithActionInstance(int action, String successMessage, QRCodeBloc bloc, String sttRec) {
    // ✅ Validation sttRec trước khi xử lý
    if (sttRec.isEmpty || sttRec == 'null' || sttRec == '') {
      _showWarningMessage('Lỗi: Không tìm thấy mã phiếu (sttRec). Vui lòng thử lại.');
      return;
    }
    
    // Tạo listItem từ listItemCard
    final List<UpdateItemBarCodeRequestDetail> _listItem = [];
    for (var element in bloc.listItemCard) {
      _listItem.add(UpdateItemBarCodeRequestDetail(
        indexItem: _listItem.length + 1,
        maVt: element.maVt,
        soCan: _getQuantityForAPI(element).toString(),
        barcode: element.qrCode,
        hsd: element.expirationDate,
        maKho: element.maKho ?? '',
        maLo: element.maLo ?? '',
        sttRec0: element.sttRec0,
        sttRec: element.sttRec,
        tenVt: element.tenVt,
        dvt: element.dvt,
        pallet: element.pallet,
        maViTri: element.maViTri,
        nsx: element.productionDate,
        timeScan: DateTime.now().toIso8601String(),
        soLuong: _getQuantityForAPI(element),
        isCallAPI: false,
      ));
    }
    
    // Tạo listConfirm từ listHistoryDNNK
    final List<UpdateItemBarCodeRequestDetail> _listConfirm = [];
    for (var element in bloc.listHistoryDNNK) {
      // Tìm item tương ứng trong listItemCard để lấy actualQuantity
      final correspondingItem = bloc.listItemCard.firstWhere(
        (item) => item.maVt.toString().trim() == element.maVt.toString().trim(),
        orElse: () => ListItem(),
      );
      
      // ✅ Logic tổng hợp: Tìm kiếm các mã vật tư có cùng mã vật tư trong tab lịch sử và cộng tổng
      double totalQuantity = 0.0;
      double totalSoCan = 0.0;
      
      // Tìm tất cả các item trong lịch sử có cùng mã vật tư
      final historyItems = bloc.listHistoryDNNK.where(
        (historyItem) => historyItem.maVt.toString().trim() == element.maVt.toString().trim()
      ).toList();
      
      if (historyItems.isNotEmpty) {
        // Tính tổng soLuong và soCan từ lịch sử
        totalQuantity = historyItems.fold(0.0, (sum, item) => sum + (item.soLuong ?? 0.0));
        totalSoCan = historyItems.fold(0.0, (sum, item) => sum + (item.soCan ?? 0.0));
      }
      
      // ✅ Ưu tiên dữ liệu nhập tay (actualQuantity) trước
      final double actualQuantity = correspondingItem.actualQuantity ?? 0.0;
      
      // Logic ưu tiên: actualQuantity (nhập tay) > tổng từ lịch sử > soCan gốc
      final double quantityToUse = (actualQuantity > 0) 
          ? actualQuantity 
          : ((totalQuantity > 0) ? totalQuantity : (element.soCan ?? 0));
      
      final double soCanToUse = (actualQuantity > 0) 
          ? actualQuantity 
          : ((totalSoCan > 0) ? totalSoCan : (element.soCan ?? 0));
      
      _listConfirm.add(UpdateItemBarCodeRequestDetail(
        indexItem: _listConfirm.length + 1,
        maVt: element.maVt,
        soCan: soCanToUse.toString(),
        barcode: element.barcode,
        hsd: element.hsd,
        maKho: element.maKho ?? '',
        maLo: element.maLo ?? '',
        sttRec0: element.sttRec0,
        sttRec: element.sttRec,
        tenVt: element.tenVt,
        dvt: element.dvt,
        pallet: element.pallet,
        maViTri: element.maViTri,
        nsx: element.nsx,
        timeScan: element.timeScan,
        soLuong: quantityToUse,
        isCallAPI: element.isCallAPI ?? false,
      ));
    }

    bloc.add(UpdateItemBarCodeEvent(
      listItem: _listItem,
      sttRec: sttRec,
      action: action,
      listConfirm: _listConfirm,
    ));
    
    // Focus is handled by camera scanner
  }

  @override
  void dispose() {
    // ✅ Stop camera safely when leaving the screen
    try {
      (_cameraKey.currentState as dynamic)?.stopCamera();
    } catch (e) {
      debugPrint('Error stopping camera in dispose: $e');
    }
    
    // Clean up enhanced features
    // TTS disabled
    
    // ✅ Reset processing state when leaving screen
    isProcessing = false;
    isApiLoading = false;
    debugPrint('=== ViewInformationCardScreen disposed - reset processing states ===');
    
    // Chỉ dispose bloc nếu chúng ta tạo mới (không phải từ parent)
    if (widget.bloc == null) {
      _bloc.close();
      debugPrint('=== QRCodeBloc disposed (was created locally) ===');
    } else {
      debugPrint('=== QRCodeBloc not disposed (was passed from parent) ===');
    }
    
    tabController.dispose();
    super.dispose();
  }



  void warningAlert(String valuesMaLo) {
    // Implementation for warning alert
    _showWarningMessage('Cảnh báo: $valuesMaLo');
  }

  // Enhanced barcode handling with GS1 parsing
  void handleEnhancedBarcodeScan(String code) async {
    // Validate input - but allow scanning to continue
    if (!_isValidBarcode(code)) {
      _showBarcodeError('Mã barcode không hợp lệ - Vui lòng quét lại');
      // Add small delay to allow camera to continue scanning
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    if (isProcessing) {
      print('Already processing barcode, skipping...');
      debugPrint('=== handleEnhancedBarcodeScan - isProcessing: $isProcessing ===');
      return;
    }

    isProcessing = true;
    debugPrint('=== handleEnhancedBarcodeScan START - isProcessing: $isProcessing ===');

    try {
      // Try GS1 parsing first
      final gs1Result = _gs1Parser.parse(code);
      if (gs1Result.elements.isNotEmpty) {
        _processGS1Barcode(gs1Result, code);
        return;
      }
    } catch (e) {
      debugPrint('GS1 parsing failed: $e');
    } finally {
      debugPrint('=== handleEnhancedBarcodeScan END - isProcessing set to false ===');
      await Future.delayed(const Duration(milliseconds: 1000));
      isProcessing = false;
    }

    // Fallback to original logic
    handleBarcodeScan(code);
  }

  // Validator for barcode input
  bool _isValidBarcode(String code) {
    if (code.isEmpty || code.trim().isEmpty) return false;
    if (code.length < 3) return false; // Minimum barcode length
    if (code.length > 100) return false; // Maximum barcode length
    return true;
  }

  // Centralized notification system
  void _showBarcodeError(String message) {
    _showNotification(message, Icons.warning_amber, NotificationType.error);
  }

  void _showSuccessMessage(String message) {
    _showNotification(message, Icons.check_circle_outline, NotificationType.success);
  }

  void _showWarningMessage(String message) {
    _showNotification(message, Icons.warning_amber, NotificationType.warning);
  }

  // Centralized notification method
  void _showNotification(String message, IconData icon, NotificationType type) {
    Utils.showCustomToast(context, icon, message);
  }


  void _processGS1Barcode(GS1Barcode gs1Result, String originalCode) {
    final gs1Data = _extractGS1Data(gs1Result);
    
    if (gs1Data['kilogram'] > 0 && _isValidIndexSelected()) {
      _updateItemWithGS1Data(
        originalCode, 
        gs1Data['kilogram'], 
        gs1Data['expirationDate'], 
        gs1Data['productionDate'], 
        gs1Data['maLo']
      );
    } else {
      // Fallback to original barcode handling
      handleBarcodeScan(originalCode);
    }
  }

  // Extract GS1 data with optimized logic
  Map<String, dynamic> _extractGS1Data(GS1Barcode gs1Result) {
    double kilogram = 0;
        String expirationDate = '';
    String productionDate = '';
    String maLo = '';

    // Process GS1 data with priority handling
    gs1Result.elements.forEach((aiCode, element) {
      final data = element.data.toString();
      
      switch (aiCode) {
        case '17': // Expiration Date (highest priority)
          expirationDate = data;
          break;
        case '12': // Due Date (only if no expiration date)
          if (expirationDate.isEmpty) expirationDate = data;
          break;
        case '15': // Best Before Date (only if no expiration date)
          if (expirationDate.isEmpty) expirationDate = data;
          break;
        case '11': // Production Date (highest priority)
          productionDate = data;
          break;
        case '13': // Packing Date (only if no production date)
          if (productionDate.isEmpty) productionDate = data;
          break;
        case '310': // kilogram
          kilogram = _parseKilogram(data);
          break;
        case '320': // Pound to kilogram conversion
          kilogram = _convertPoundToKilogram(data);
          break;
        case '10': // Batch/Lot number
          maLo = data;
          break;
      }
    });

    return {
      'kilogram': kilogram,
      'expirationDate': expirationDate,
      'productionDate': productionDate,
      'maLo': maLo,
    };
  }

  // Parse kilogram with validation
  double _parseKilogram(String data) {
    final parsed = double.tryParse(data);
    return (parsed != null && parsed > 0) ? parsed : 0;
  }

  // Convert pound to kilogram with validation
  double _convertPoundToKilogram(String data) {
    final pound = double.tryParse(data);
    if (pound == null || pound <= 0) return 0;
    
    const double poundToKg = 0.45359237;
    final kilogram = pound * poundToKg;
    return double.parse(kilogram.toStringAsFixed(3));
  }

  // Validate index selected
  bool _isValidIndexSelected() {
    return indexSelected >= 0 && indexSelected < listItemCard.length;
  }

  void _updateItemWithGS1Data(String barcode, double kilogram, String expirationDate, String productionDate, String maLo) {
    if (indexSelected >= 0 && indexSelected < listItemCard.length) {
      // Cập nhật dữ liệu vào listItemCard
      listItemCard[indexSelected].expirationDate = expirationDate;
      listItemCard[indexSelected].productionDate = productionDate;
      listItemCard[indexSelected].maLo = maLo;
      listItemCard[indexSelected].soLuong = (listItemCard[indexSelected].soLuong ?? 0) + kilogram;
      
      // Sử dụng hàm addListHistory từ SSE-Scanner
      addListHistory(
        barcode, 
        kilogram, 
        (listItemCard[indexSelected].soLuong ?? 0) + kilogram, 
        expirationDate, 
        productionDate, 
        false, // isAdd = false cho GS1 parsing
        '', // maViTri
        maLo
      );
      
      // ✅ Validation sttRec trước khi gọi API
      final sttRec = _bloc.masterInformationCard.sttRec?.toString() ?? '';
      if (sttRec.isEmpty) {
        _showWarningMessage('Lỗi: Không tìm thấy mã phiếu. Vui lòng thử lại.');
        return;
      }
      
      // ✅ Action 1: Cập nhật lô hàng (maLo)
      if (maLo.isNotEmpty) {
        _updateItemBarCodeWithActionInstance(1, 'Cập nhật lô hàng thành công', _bloc, sttRec);
      }
      
      // ✅ Action 1: Cập nhật hạn sử dụng (hsd)
      if (expirationDate.isNotEmpty) {
        _updateItemBarCodeWithActionInstance(1, 'Cập nhật hạn sử dụng thành công', _bloc, sttRec);
      }
      
      // ✅ Action 1: Cập nhật ngày sản xuất (nsx)
      if (productionDate.isNotEmpty) {
        _updateItemBarCodeWithActionInstance(1, 'Cập nhật ngày sản xuất thành công', _bloc, sttRec);
      }
      
      // ✅ Action 1: Cập nhật số lượng (soLuong)
      if (kilogram > 0) {
        _updateItemBarCodeWithActionInstance(1, 'Cập nhật số lượng thành công', _bloc, sttRec);
      }
    }
  }

  /// Hàm addListHistory tích hợp từ SSE-Scanner
  void addListHistory(String text, double kilogram, double kilogramNew, String? expirationDateProduction,
      String? productionDate, bool isAdd, String maViTri, String valuesMaLo) {
    
    // Validate input parameters
    if (!_validateAddListHistoryParams(text, kilogram, kilogramNew)) {
      return;
    }

    // ✅ Check for duplicate barcode - block nếu duplicate
    if (_isDuplicateBarcode(text)) {
      _handleDuplicateBarcode();
      return;
    }

    // Insert history if not duplicate
    insertHistory(text, kilogram, kilogramNew, expirationDateProduction, productionDate, isAdd, maViTri, valuesMaLo);
  }

  /// Xử lý dữ liệu từ API response GetInformationItemFromBarCodeSuccess
  void _handleGetInformationItemFromBarCodeSuccess(GetInformationItemFromBarCodeSuccess state) {
    try {
      debugPrint('=== _handleGetInformationItemFromBarCodeSuccess START ===');
      
      // Lấy dữ liệu từ API response
      final informationProduction = state.informationProduction;
      debugPrint('API response - maVt: ${informationProduction.maVt}, maIn: ${informationProduction.maIn}, soLuong: ${informationProduction.soLuong}');
      
      // Kiểm tra xem có dữ liệu hợp lệ không
      if (informationProduction.maVt == null || informationProduction.maVt!.isEmpty) {
        debugPrint('API response không có maVt hợp lệ');
        _showWarningMessage('Không tìm thấy thông tin sản phẩm');
        return;
      }

      // Sử dụng sản phẩm đã chọn (indexSelected) - đã được auto select trong initState
      if (indexSelected < 0 || indexSelected >= listItemCard.length) {
        debugPrint('indexSelected không hợp lệ: $indexSelected, listItemCard.length: ${listItemCard.length}');
        _showWarningMessage('Vui lòng chọn sản phẩm trước khi quét barcode');
        return;
      }

      // Lấy thông tin từ sản phẩm đã chọn
      final selectedItem = listItemCard[indexSelected];
      debugPrint('Sử dụng sản phẩm đã chọn tại index: $indexSelected, maVt: ${selectedItem.maVt}');
      
      // Kiểm tra duplicate barcode trước khi tạo history item
      final barcode = informationProduction.maIn ?? '';
      bool isDuplicate = _bloc.listHistoryDNNK.any((element) => 
        element.barcode.toString().trim() == barcode.trim()
      );

      if (isDuplicate) {
        _showWarningMessage('Barcode này đã được quét trước đó');
        return;
      }
      
      // Tạo history item từ dữ liệu API và listItemCard
      final historyItem = GetListHistoryDNNKResponseData(
        maVt: informationProduction.maVt,
        tenVt: informationProduction.tenVt,
        sttRec: selectedItem.sttRec,
        index: _bloc.listHistoryDNNK.length, // Sử dụng length hiện tại làm index
        barcode: barcode,
        soLuong: informationProduction.soLuong ?? 0,
        soCan: informationProduction.soLuong ?? 0,
        soCanView: informationProduction.soLuong ?? 0,
        maLo: selectedItem.maLo ?? '',
        maKho: selectedItem.maKho ?? '',
        hsd: informationProduction.hsd ?? '',
        nsx: selectedItem.productionDate ?? '',
        sttRec0: selectedItem.sttRec0 ?? '',
        pallet: selectedItem.pallet ?? '',
        maViTri: '',
        timeScan: DateTime.now().toString().replaceAll('T', ' '),
        dvt: selectedItem.tenDvt ?? '',
        isCallAPI: true,
      );

      // Thêm vào lịch sử
      debugPrint('Thêm item vào lịch sử: ${historyItem.maVt} - ${historyItem.barcode}');
      debugPrint('Số lượng items trong lịch sử trước khi thêm: ${_bloc.listHistoryDNNK.length}');
      
      // Thêm vào đầu danh sách
      _bloc.listHistoryDNNK.insert(0, historyItem);
      
      // Cập nhật index cho tất cả items
      for (int i = 0; i < _bloc.listHistoryDNNK.length; i++) {
        _bloc.listHistoryDNNK[i].index = i;
      }
      
      // Cập nhật actualQuantity cho item tương ứng
      _updateActualQuantityForItem(selectedItem.maVt.toString());
      
      // Trigger state update
      _bloc.add(RefreshUpdateItemBarCodeEvent());
      
      debugPrint('Số lượng items trong lịch sử sau khi thêm: ${_bloc.listHistoryDNNK.length}');

      // Cache barcode history
      _cacheBarcodeHistory(
        historyItem.barcode.toString(),
        historyItem.soCan ?? 0,
        historyItem.soCanView ?? 0,
        historyItem.hsd ?? '',
        historyItem.nsx ?? '',
        true, // isAdd
        historyItem.maViTri ?? '',
        historyItem.maLo ?? ''
      );

      _showSuccessMessage('Thêm vào lịch sử thành công');
      debugPrint('=== _handleGetInformationItemFromBarCodeSuccess END ===');

    } catch (e) {
      debugPrint('Error in _handleGetInformationItemFromBarCodeSuccess: $e');
      _showBarcodeError('Lỗi khi xử lý dữ liệu API: ${e.toString()}');
    }
  }

  // Validate parameters for addListHistory
  bool _validateAddListHistoryParams(String text, double kilogram, double kilogramNew) {
    if (text.trim().isEmpty) {
      _showBarcodeError('Mã barcode không được để trống');
      return false;
    }
    
    if (kilogram < 0) {
      _showBarcodeError('Số kilogram không được âm');
      return false;
    }
    
    if (kilogramNew < 0) {
      _showBarcodeError('Số kilogram mới không được âm');
      return false;
    }
    
    if (!_isValidIndexSelected()) {
      _showBarcodeError('Vui lòng chọn sản phẩm trước khi quét barcode');
      return false;
    }
    
    return true;
  }

  // Check for duplicate barcode
  bool _isDuplicateBarcode(String text) {
    return _bloc.listHistoryDNNK.any((element) => 
      element.barcode.toString().trim() == text.trim()
    );
  }

  // Handle duplicate barcode with appropriate message
  void _handleDuplicateBarcode() {
    final isSerialItem = _isValidIndexSelected() && 
                        listItemCard[indexSelected].serialYn == true;
    
    final message = isSerialItem 
        ? 'Barcode này đã được khai báo cho vật tư trước đó'
        : 'Barcode này đã được quét trước đó';
    
    _showBarcodeError(message);
  }


  /// Hàm insertHistory tích hợp từ SSE-Scanner - Tối ưu hóa
  void insertHistory(String text, double kilogram, double kilogramNew, String? expirationDateProduction,
      String? productionDate, bool isAdd, String maViTri, String valuesMaLo) {
    
    try {
      // Prepare data
      final expirationDate = _sanitizeDate(expirationDateProduction);
      final currentTime = DateTime.now();
      
      // Update item card
      _updateItemCard(text, expirationDate, valuesMaLo);
      
      // Create history item
      final item = _createHistoryItem(
        text, kilogram, maViTri, expirationDate, 
        productionDate, currentTime
      );
      
      // Add to history
      _bloc.listHistoryDNNK.add(item);
      
      // Cập nhật actualQuantity cho item tương ứng
      if (indexSelected >= 0 && indexSelected < listItemCard.length) {
        final selectedItem = listItemCard[indexSelected];
        _updateActualQuantityForItem(selectedItem.maVt.toString());
      }
      
      _bloc.add(RefreshUpdateItemBarCodeEvent());
      
      // Cache barcode history
      _cacheBarcodeHistory(text, kilogram, kilogramNew, expirationDateProduction, 
          productionDate, isAdd, maViTri, valuesMaLo);
      
      // Update values barcode
      _updateValuesBarcode(text);
      
      // Show success message for add operations
      if (isAdd) {
        _showSuccessMessage('Cập nhật thông tin thành công');
      }
      
    } catch (e) {
      debugPrint('Error in insertHistory: $e');
      _showBarcodeError('Lỗi khi thêm lịch sử: ${e.toString()}');
    }
  }

  // Sanitize date input
  String? _sanitizeDate(String? date) {
    if (date == null || date.trim().isEmpty) return null;
    return date.trim();
  }

  // Update item card with new data
  void _updateItemCard(String text, String? expirationDate, String valuesMaLo) {
    if (!_isValidIndexSelected()) return;
    
    setState(() {
      listItemCard[indexSelected].qrCode = text;
        listItemCard[indexSelected].expirationDate = expirationDate;
      listItemCard[indexSelected].maLo = valuesMaLo;
    });
  }

  // Create history item with optimized data
  GetListHistoryDNNKResponseData _createHistoryItem(
    String text, double kilogram, String maViTri, 
    String? expirationDate, String? productionDate, DateTime currentTime
  ) {
    final selectedItem = listItemCard[indexSelected];
    
    return GetListHistoryDNNKResponseData(
      maVt: selectedItem.maVt,
      tenVt: selectedItem.tenVt,
      sttRec: selectedItem.sttRec,
      index: _bloc.listHistoryDNNK.length, // Use current length as index
      barcode: text,
      soLuong: 1,
      soCan: kilogram,
      soCanView: kilogram,
      maLo: maViTri, // Use maViTri as maLo for now
      maKho: selectedItem.maKho,
      hsd: expirationDate ?? '',
      nsx: productionDate ?? selectedItem.productionDate ?? '',
      sttRec0: selectedItem.sttRec0,
      pallet: '', // TODO: Add pallet logic if needed
      maViTri: maViTri,
      timeScan: currentTime.toString().replaceAll('T', ' '),
      dvt: selectedItem.tenDvt,
      isCallAPI: false,
    );
  }

  // Cache barcode history with validation
  void _cacheBarcodeHistory(String text, double kilogram, double kilogramNew, 
      String? expirationDate, String? productionDate, bool isAdd, 
      String maViTri, String valuesMaLo) {
    try {
      _bloc.cacheBarcodeHistory(text, {
        'barcode': text,
        'kilogram': kilogram,
        'kilogramNew': kilogramNew,
        'expirationDate': expirationDate,
        'productionDate': productionDate,
        'isAdd': isAdd,
        'maViTri': maViTri,
        'valuesMaLo': valuesMaLo,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error caching barcode history: $e');
    }
  }

  // Update values barcode
  void _updateValuesBarcode(String text) {
    if (!valuesBarcode.contains(text)) {
      valuesBarcode = text;
        _bloc.add(RefreshUpdateItemBarCodeEvent());
    }
  }


  /// Hàm tính toán sản xuất trong tab lịch sử - Tối ưu hóa
  void calculatorProductionInTabHistory() {
    if (!_isValidIndexSelected()) {
      debugPrint('Invalid index selected for calculation');
      return;
    }

    try {
      final selectedItem = listItemCard[indexSelected];
      final maVt = selectedItem.maVt.toString().trim();
      
      // Calculate total kilogram for selected item from history
      final totalKilogram = _bloc.listHistoryDNNK
          .where((element) => element.maVt.toString().trim() == maVt)
          .fold<double>(0.0, (sum, element) => sum + (element.soCan ?? 0));

      // KHÔNG ghi đè soLuong từ API - chỉ tính toán để hiển thị
      // soLuong từ API phải được giữ nguyên
      debugPrint('Calculated total kilogram for $maVt: $totalKilogram');
      debugPrint('Original soLuong from API: ${selectedItem.soLuong}');
      
    } catch (e) {
      debugPrint('Error in calculatorProductionInTabHistory: $e');
      _showBarcodeError('Lỗi khi tính toán sản xuất: ${e.toString()}');
    }
  }

  /// Hàm làm tròn đến 3 chữ số thập phân - tích hợp từ SSE-Scanner
  double roundToThreeDecimals(double value) {
    return double.parse((value).toStringAsFixed(3));
  }

  /// ✅ Cập nhật lại soLuong cho listItemCard sau khi xóa - Logic từ SSE-Scanner
  void _updateItemQuantityAfterDelete(String maVt, double soCanToDelete) {
    try {
      // Tìm item trong listItemCard có cùng maVt
      final itemIndex = listItemCard.indexWhere(
        (item) => item.maVt.toString().trim().toUpperCase() == maVt.trim().toUpperCase()
      );
      
      if (itemIndex != -1) {
        // Tính tổng soCan còn lại từ history cho item này
        final remainingSoCan = _bloc.listHistoryDNNK
            .where((element) => element.maVt.toString().trim().toUpperCase() == maVt.trim().toUpperCase())
            .fold<double>(0.0, (sum, element) => sum + (element.soCan ?? 0));
        
        // Cập nhật soLuong = soCan còn lại
        listItemCard[itemIndex].soLuong = remainingSoCan;
        
        debugPrint('Updated soLuong for $maVt: $remainingSoCan (deleted: $soCanToDelete)');
      }
    } catch (e) {
      debugPrint('Error updating quantity after delete: $e');
    }
  }

  /// ✅ Format thời gian quét để hiển thị với giờ-phút-giây cụ thể
  String _formatTimeScan(String? timeScan) {
    if (timeScan == null || timeScan.isEmpty) {
      return 'Chưa có thời gian';
    }
    
    try {
      final dateTime = DateTime.parse(timeScan);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      // Format thời gian cụ thể: HH:mm:ss
      final timeString = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
      
      if (difference.inSeconds < 60) {
        return 'Vừa xong ($timeString)';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước ($timeString)';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước ($timeString)';
      } else {
        // Format ngày tháng năm với thời gian cụ thể
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} $timeString';
      }
    } catch (e) {
      debugPrint('Error formatting timeScan: $e');
      return 'Thời gian không hợp lệ';
    }
  }

  /// ✅ Cập nhật cache sau khi xóa - Logic từ SSE-Scanner
  void _updateCacheAfterDelete() {
    try {
      // Cập nhật cache QRCode data
      _bloc.cacheQRCodeData(_bloc.masterInformationCard.sttRec.toString(), _bloc.listHistoryDNNK);
      
      // Cập nhật cache listItemHistory
      _bloc.listItemHistory = List<GetListHistoryDNNKResponseData>.from(_bloc.listHistoryDNNK);
      
      debugPrint('Cache updated after delete');
    } catch (e) {
      debugPrint('Error updating cache after delete: $e');
    }
  }

  /// ✅ Sync listItemHistory với listHistoryDNNK - Đảm bảo đồng bộ
  void _syncListItemHistory() {
    try {
      _bloc.listItemHistory = List<GetListHistoryDNNKResponseData>.from(_bloc.listHistoryDNNK);
      debugPrint('Synced listItemHistory with listHistoryDNNK: ${_bloc.listItemHistory.length} items');
    } catch (e) {
      debugPrint('Error syncing listItemHistory: $e');
    }
  }

  /// ✅ Load history data với logic merge cache và API - Logic từ SSE-Scanner
  Future<void> _loadHistoryData({bool forceReload = false}) async {
    try {
      if (forceReload || _hasDeletedItems) {
        // Force reload từ server và clear cache
        await _bloc.clearQRCodeCache(_bloc.masterInformationCard.sttRec.toString());
        _bloc.add(GetListHistoryDNNKEvent(sttRec: _bloc.masterInformationCard.sttRec.toString(), keyFunc: widget.keyFunction));
        _hasDeletedItems = false; // Reset flag
        debugPrint('🔄 Force reloading history from server (deleted items: $_hasDeletedItems)');
        return;
      }
      
      // ✅ Luôn call API để lấy dữ liệu mới nhất - Logic từ SSE-Scanner
      // Bloc sẽ tự động merge với cache data
      _bloc.add(GetListHistoryDNNKEvent(sttRec: _bloc.masterInformationCard.sttRec.toString(), keyFunc: widget.keyFunction));
      debugPrint('🔄 Calling API to load history (will merge with cache)');
    } catch (e) {
      debugPrint('❌ Error loading history data: $e');
      // Fallback: gọi API nếu có lỗi
      _bloc.add(GetListHistoryDNNKEvent(sttRec: _bloc.masterInformationCard.sttRec.toString(), keyFunc: widget.keyFunction));
    }
  }


  /// ✅ Xóa item với error handling - Logic từ SSE-Scanner
  void _deleteItemWithErrorHandling({
    required String pallet,
    required String barcode,
    required String sttRec,
    required String sttRec0,
  }) {
    try {
      if (
          barcode.isEmpty || barcode == 'null' ||
          sttRec.isEmpty || sttRec == 'null' ||
          sttRec0.isEmpty || sttRec0 == 'null') {
        _showWarningMessage('Thông tin xóa không hợp lệ');
        return;
      }
      _bloc.add(DeleteItemEvent(
        pallet: pallet,
        barcode: barcode,
        sttRec: sttRec,
        sttRec0: sttRec0,
      ));
      debugPrint('DeleteItemEvent dispatched successfully');
      _showSuccessMessage('Đã gửi yêu cầu xóa barcode');
      
    } catch (e) {
      debugPrint('Error deleting item: $e');
      _showWarningMessage('Lỗi khi xóa barcode: ${e.toString()}');
    }
  }

  /// Hàm xử lý quy tắc barcode - tích hợp từ SSE-Scanner
  void getRuleBarcode(String valueScanBarcode, String? expirationDateProduction, String? productionDate, dynamic lenghtBarcode, String maNcc) {
    setState(() {
      valueScan = valueScanBarcode;
    });

    double kilogramNew = 0;
    double kilogram = 0;
    String valuesMaLo = '';
    bool isExits = false;

    // Logic xử lý quy tắc barcode từ SSE-Scanner
    // Có thể cần thêm Const.listRuleBarcode nếu cần thiết

    if(isExits == true) {
      isExits = false;
      addListHistory(valueScan, kilogram, kilogramNew, expirationDateProduction, productionDate, false, '', valuesMaLo);
      _bloc.add(RefreshUpdateItemBarCodeEvent());
      if(!valuesBarcode.contains(valueScan.toString())){
        valuesBarcode = valueScan.toString();
          _bloc.add(RefreshUpdateItemBarCodeEvent());
      }
    } else {
      // Fallback to original barcode handling
      handleBarcodeScan(valueScanBarcode);
    }

    valueScan = '';
  }



  /// Hàm xử lý barcode với GS1 parser khi API không tìm thấy - Logic từ SSE-Scanner
  /// Thử parse barcode bằng GS1 parser và trả về kết quả thành công/thất bại
  Future<bool> _handleBarcodeWithGS1Parser(String barcode) async {
    try {
      if (indexSelected >= 0 && indexSelected < listItemCard.length) {
        // Thử parse barcode bằng GS1 parser
        final parser = GS1BarcodeParser.defaultParser();
        var result = parser.parse(barcode);
        
        if (result.getAIsData.isNotEmpty) {
          double kilogram = 0;
          String maLo = '';
          String expirationDate = '';
          
          result.getAIsData.forEach((key, value) {
            if (key.toString().trim() == '10') { // LOT
              maLo = value.toString().trim();
            } else if (key.toString().trim() == '11') { // Production date
              expirationDate = value.toString().trim();
            } else if (key.toString().trim() == '310') { // Weight
              kilogram = double.tryParse(value.toString()) ?? 0;
            }
          });
          
          if (kilogram > 0 || maLo.isNotEmpty || expirationDate.isNotEmpty) {
            _updateItemWithGS1Data(barcode, kilogram, expirationDate, '', maLo);
            return true; // ✅ GS1 parser thành công
          } else {
            return false; // ❌ Không thể parse thông tin
          }
        } else {
          return false; // ❌ Barcode không hợp lệ
        }
      } else {
        _showBarcodeError('Vui lòng chọn sản phẩm trước khi quét barcode');
        return false; // ❌ Chưa chọn sản phẩm
      }
    } catch (e) {
      return false; // ❌ Lỗi parse
    }
  }

  /// Convert GetListHistoryDNNKResponseData to ItemLocationModifyRequestDetail
  List<ItemLocationModifyRequestDetail> _convertToItemLocationModifyRequestDetail(List<GetListHistoryDNNKResponseData> listItemHistory) {
    return listItemHistory.map((item) => ItemLocationModifyRequestDetail(
      maVt: item.maVt,
      maViTri: item.maViTri,
      soLuong: item.soLuong,
      teVt: item.tenVt,
      nxt: item.index,
      qrCode: item.barcode,
    )).toList();
  }

  // TODO: Implement methods from SSE-Scanner when required classes are available
  // /// Method insertDB từ SSE-Scanner - Đồng nhất hoàn toàn
  // void insertDB(ItemInvoices itemInvoices, bool isDelete)async{
  //   _bloc.db.addItemInvoices2(itemInvoices,isDelete);
  // }

  // /// Method deleteData từ SSE-Scanner - Đồng nhất hoàn toàn
  // void deleteData({String? sttRec})async{
  //   // _bloc.db.removeInvoices(sttRec);
  //   _bloc.db.deleteAllDBInvoices();
  // }

  // /// Method getListTicket từ SSE-Scanner - Đồng nhất hoàn toàn
  // void getListTicket(){
  //   if(qrcodeResponse.sttRec.toString().replaceAll('null', '').isNotEmpty){
  //     _bloc.add(GetInformationCardEvent(idCard: qrcodeResponse.sttRec.toString(), key: qrcodeResponse.key.toString()));
  //   }
  //   else{
  //     if(Const.sttRec.toString().replaceAll('null', '').isNotEmpty){
  //       _bloc.add(GetInformationCardEvent(idCard: Const.sttRec.toString(), key: Const.keyFunc.toString()));
  //     }else{
  //       if( widget.masterInformationCard?.sttRec.toString() != null){
  //         _bloc.add(GetInformationCardEvent(idCard: widget.masterInformationCard!.sttRec.toString(), key: widget.key.toString()));
  //       }else {
  //         _showWarningMessage('Liên hệ Tuấn Anh SSE để hỗ trợ');
  //       }
  //     }
  //   }
  // }

  /// Hàm xử lý barcode với quy tắc từ SSE-Scanner - Tối ưu hóa
  void handleBarcodeWithRules(String barcode) async {
    if (!_isValidBarcode(barcode)) {
      _showBarcodeError('Mã barcode không hợp lệ - Vui lòng quét lại');
      // Add small delay to allow camera to continue scanning
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    // Xử lý theo quy tắc barcode
    getRuleBarcode(barcode, null, null, barcode.length, '');
  }

  /// Hàm xử lý barcode từ camera - Tối ưu hóa
  void handleCameraBarcode(String barcode) async {
    print(barcode);
    if (!_isValidBarcode(barcode)) {
      _showBarcodeError('Mã barcode không hợp lệ - Vui lòng quét lại');
      // Add small delay to allow camera to continue scanning
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    // Xử lý barcode từ camera
    handleEnhancedBarcodeScan(barcode);
  }



  void handleBarcodeScan(String code) async {
    // ✅ Block quét khi đang xử lý hoặc đang call API
    if (isProcessing || isApiLoading) {
      debugPrint('Already processing or API loading, skipping...');
      debugPrint('=== isProcessing: $isProcessing, isApiLoading: $isApiLoading ===');
      return;
    }
    
    // Validate barcode
    if (!_isValidBarcode(code)) {
      debugPrint('Invalid barcode: $code');
      _showBarcodeError('Mã barcode không hợp lệ - Vui lòng quét lại');
      // Add small delay to allow camera to continue scanning
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    
    isProcessing = true;
    debugPrint('Starting barcode processing...');

    try {
      if (widget.keyFunction == '#4') {
        if (indexSelected >= 0 && indexSelected < listItemCard.length) {
          String kg = "0";
          String expirationDate = '';

          // Parse barcode using format provider
          if (widget.formatProvider.canYn == 1) {
            try {
              final canStart = widget.formatProvider.canTu?.toInt() ?? 0;
              final canEnd = widget.formatProvider.canDen?.toInt() ?? code.length;
              if (canStart < code.length && canEnd <= code.length && canStart < canEnd) {
                final weightStr = code.substring(canStart, canEnd);
                final weight = double.parse(weightStr);
                kg = NumberFormat(widget.formatProvider.soThapPhan.toString()).format(weight);
              }
            } catch (e) {
              debugPrint('Error parsing weight: $e');
              kg = "0";
            }
          }
          
          if (widget.formatProvider.hsdYn == 1) {
            try {
              final hsdStart = widget.formatProvider.hsdTu?.toInt() ?? 0;
              final hsdEnd = widget.formatProvider.hsdDen?.toInt() ?? code.length;
              if (hsdStart < code.length && hsdEnd <= code.length && hsdStart < hsdEnd) {
                expirationDate = code.substring(hsdStart, hsdEnd);
              }
            } catch (e) {
              debugPrint('Error parsing expiration date: $e');
              expirationDate = '';
            }
          }

          // Sử dụng hàm addListHistory từ SSE-Scanner
          addListHistory(
            code, 
            double.parse(kg), 
            double.parse(kg), // kilogramNew = kilogram cho format provider
            expirationDate, 
            '', // productionDate
            false, // isAdd = false cho format provider
            '', // maViTri
            '' // valuesMaLo
          );
          
          // Cập nhật UI và thông báo
          _showSuccessMessage('Cập nhật thông tin thành công');
      } else {
        _showWarningMessage('Vui lòng chọn 1 sản phẩm để cập nhật');
      }
    }
      else if (widget.keyFunction == '#3') {
      // Kiểm tra xem có sản phẩm nào trong danh sách không
      if (listItemCard.isEmpty) {
        _showWarningMessage('Danh sách sản phẩm trống');
        return;
      }
      
      // ✅ Check duplicate barcode trước khi gọi API
      if (!valuesBarcode.contains(code)) {
        valuesBarcode = code;
        debugPrint('=== Calling GetInformationItemFromBarCodeEvent for keyFunction #3 with barcode: $valuesBarcode ===');
        
        // ✅ Set API loading state
        setState(() {
          isApiLoading = true;
        });
        
        _bloc.add(GetInformationItemFromBarCodeEvent(barcode: valuesBarcode, pallet: ''));
      } else {
        debugPrint('Barcode already processed: $code');
        _showBarcodeError('Barcode này đã được quét trước đó');
      }
    } else if (widget.keyFunction == '#1') {
      // Kiểm tra xem có sản phẩm nào trong danh sách không
      if (listItemCard.isEmpty) {
        _showWarningMessage('Danh sách sản phẩm trống');
        return;
      }
      setState(() {
        isApiLoading = true;
      });
      
      _bloc.add(GetInformationItemFromBarCodeEvent(barcode: code, pallet: ''));
    } else if (widget.keyFunction == '#5') {
      // Cập nhật lô hàng - Logic giống #1
      if (listItemCard.isEmpty) {
        _showWarningMessage('Danh sách sản phẩm trống');
        return;
      }
      setState(() {
        isApiLoading = true;
      });
      
      _bloc.add(GetInformationItemFromBarCodeEvent(barcode: code, pallet: ''));
    } else if (widget.keyFunction == '#6') {
      // Lên phiếu giao hàng - Logic giống #1
      if (listItemCard.isEmpty) {
        _showWarningMessage('Danh sách sản phẩm trống');
        return;
      }
      setState(() {
        isApiLoading = true;
      });
      
      _bloc.add(GetInformationItemFromBarCodeEvent(barcode: code, pallet: ''));
    } else if (widget.keyFunction == '#7') {
      // Cập nhật ngày sản xuất - Logic giống #1
      if (listItemCard.isEmpty) {
        _showWarningMessage('Danh sách sản phẩm trống');
        return;
      }
      setState(() {
        isApiLoading = true;
      });
      
      _bloc.add(GetInformationItemFromBarCodeEvent(barcode: code, pallet: ''));
    } else if (widget.keyFunction == '#8') {
      // Cập nhật số lượng - Logic giống #1
      if (listItemCard.isEmpty) {
        _showWarningMessage('Danh sách sản phẩm trống');
        return;
      }
      setState(() {
        isApiLoading = true;
      });
      
      _bloc.add(GetInformationItemFromBarCodeEvent(barcode: code, pallet: ''));
    } else {
      // Default case - Logic chung cho các keyFunction khác
      if (listItemCard.isEmpty) {
        _showWarningMessage('Danh sách sản phẩm trống');
        return;
      }
      setState(() {
        isApiLoading = true;
      });
      
      _bloc.add(GetInformationItemFromBarCodeEvent(barcode: code, pallet: ''));
    }
    } catch (e) {
      debugPrint('Error in handleBarcodeScan: $e');
      _showBarcodeError('Lỗi xử lý barcode: ${e.toString()}');
    } finally {
      debugPrint('=== handleBarcodeScan END - isProcessing set to false ===');
    await Future.delayed(const Duration(milliseconds: 1000));
    isProcessing = false;
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey_100,
      body: BlocListener<QRCodeBloc,QRCodeState>(
        bloc: _bloc,
        listener: (context,state){
          // Debug logging để kiểm tra tất cả states
          debugPrint('=== BlocListener State: ${state.runtimeType} ===');
          debugPrint('=== State details: $state ===');
          debugPrint('=== Context mounted: ${context.mounted} ===');
          
          if(state is UpdateQuantityInWarehouseDeliveryCardSuccess){
            // ✅ Xử lý khi cập nhật số lượng thành công - Logic từ SSE-Scanner
            debugPrint('✅ UpdateQuantityInWarehouseDeliveryCardSuccess received - Action: ${state.action}');
            
            // Hiển thị thông báo trực tiếp với delay để đảm bảo context sẵn sàng
            Future.delayed(const Duration(milliseconds: 100), () {
              try {
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật số lượng thành công');
                debugPrint('✅ Success toast displayed');
              } catch (e) {
                debugPrint('❌ Error showing toast: $e');
                // Fallback: Sử dụng ScaffoldMessenger
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cập nhật số lượng thành công'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                debugPrint('✅ Fallback SnackBar displayed');
              }
            });
            
            // ✅ Xử lý action theo mapping từ SSE-Scanner
            if(state.action == 2){
              // Action 2: Xác nhận phiếu (back về màn hình trước)
              _clearCacheBeforeBack();
              Future.delayed(const Duration(milliseconds: 200), () {
                Navigator.pop(context);
                _restartCameraAfterBack();
              });
            } else {
              // Action 1: Cập nhật số liệu (không back)
              // Refresh danh sách ticket như SSE-Scanner
              _bloc.add(GetInformationCardEvent(idCard: widget.masterInformationCard.sttRec.toString(), key: ''));
            }
          }
          else if(state is UpdateItemBarCodeSuccess){
            // ✅ Xử lý khi cập nhật item barcode thành công - Logic từ SSE-Scanner
            debugPrint('✅ UpdateItemBarCodeSuccess received - Action: ${state.action}');
            
            // TODO: Implement itemInvoices and deleteData
            // _bloc.itemInvoices.clear();
            // deleteData();
            
            if(widget.keyFunction == '#1'){
              // Tạo listItem từ listItemCard cho ItemLocationModifyEvent
              final List<ItemLocationModifyRequestDetail> listItem = [];
              for (var element in _bloc.listItemCard) {
                listItem.add(ItemLocationModifyRequestDetail(
                  maVt: element.maVt,
                  maViTri: element.maViTri,
                  soLuong: element.soLuong?.toDouble() ?? 0.0,
                  teVt: element.tenVt,
                  nxt: 0,
                  qrCode: element.qrCode,
                ));
              }
              
              _bloc.add(ItemLocationModifyEvent(listItem: listItem, typeFunction: '2'));
            }

            // Tính toán lại sản xuất trong tab lịch sử
            calculatorProductionInTabHistory();

            // ✅ Xử lý action theo mapping từ SSE-Scanner (chỉ có action 1 và 2)
            if(state.action == 2){
              // Action 2: Xác nhận phiếu (back về màn hình trước)
              _clearCacheBeforeBack();
              _showSuccessMessage('Xác nhận phiếu thành công');
              Future.delayed(const Duration(milliseconds: 200), () {
              Navigator.pop(context);
                _restartCameraAfterBack();
              });
            }
            else{
              // Action 1: Cập nhật số liệu (không back)
              _showSuccessMessage('Cập nhật số liệu thành công');
            }
          }
          else if(state is GetListHistoryDNNKSuccess){
            // ✅ Sync listItemHistory sau khi load thành công
            _syncListItemHistory();
            // Tính toán lại sản xuất trong tab lịch sử
            calculatorProductionInTabHistory();
            _showSuccessMessage('Tải dữ liệu lịch sử thành công');
          }
          else if(state is DeleteItemSuccess){
            // ✅ Xử lý khi xóa thành công
            _showSuccessMessage('Xóa barcode thành công');
            // Tính toán lại sản xuất trong tab lịch sử
            calculatorProductionInTabHistory();
            // ✅ Không cần force reload ngay vì đã có flag _hasDeletedItems
            // Sẽ reload khi vào lại màn hình
          }
          else if(state is DeleteItemFailure){
            // ✅ Xử lý khi xóa thất bại
            _showWarningMessage(state.error);
            // Có thể rollback UI nếu cần
          }
          else if(state is StockTransferConfirmSuccess){
            // ✅ Xử lý khi xác nhận chuyển kho thành công - Logic từ SSE-Scanner

            _clearCacheBeforeBack();
            // Gọi ItemLocationModifyEvent với typeFunction = '2'
            _bloc.add(ItemLocationModifyEvent(
              listItem: _convertToItemLocationModifyRequestDetail(_bloc.listItemHistory), 
              typeFunction: '2'
            ));
            _showSuccessMessage('Xác nhận phiếu thành công');
            Navigator.pop(context);
          }
          else if(state is ConfirmPostPNFSuccess || state is CreateRefundBarcodeHistorySuccess){
            // ✅ Xử lý khi xác nhận hoặc tạo hoàn trả barcode thành công - Logic từ SSE-Scanner

            _showSuccessMessage('Cập nhật phiếu thành công');
            _clearCacheBeforeBack();
            if(tabIndex == 1){
            Navigator.pop(context);
            }else{
              // Refresh danh sách ticket
              _bloc.add(GetInformationCardEvent(idCard: widget.masterInformationCard.sttRec.toString(), key: ''));
            }
          }
          else if(state is CreateDeliverySuccess){
            // ✅ Xử lý khi tạo phiếu giao hàng thành công - Logic từ SSE-Scanner
            _showSuccessMessage('Tạo phiếu giao hàng thành công');
            _clearCacheBeforeBack();
            Navigator.pop(context);
          }
          else if(state is ItemLocationModifySuccess){
            // ✅ Xử lý khi cập nhật vị trí thành công - Logic từ SSE-Scanner
            _showSuccessMessage('Cập nhật vị trí thành công');
            // Không cần back vì đây là action phụ
          }
          else if(state is GetValueFromBarCodeSuccess){
            // ✅ Xử lý khi lấy giá trị từ barcode thành công - Logic từ SSE-Scanner
            setState(() {
              isApiLoading = false;
            });
            
            if(state.kilogram > 0){
              // ✅ Lấy dữ liệu từ dm_in
              double kilogramNew = 0;
              double kilogramOld = listItemCard[indexSelected].soLuong ?? 0;
              double valuesKilogram = kilogramOld + state.kilogram;
              kilogramNew = valuesKilogram;
              
              String valueScan = state.valueScanBarcode;
              _showSuccessMessage('Cập nhật thông tin thành công');
              
              addListHistory(
                valueScan,
                state.kilogram,
                kilogramNew,
                null,
                null,
                false,
                '',
                '' // TODO: Add maLo if needed
              );
              
              _bloc.add(RefreshUpdateItemBarCodeEvent());
              if(!valuesBarcode.contains(valueScan.toString())){
                valuesBarcode = valueScan.toString();
                _bloc.add(RefreshUpdateItemBarCodeEvent());
              }
            } else {
              // ✅ Lấy dữ liệu từ quy ước
              getRuleBarcode(
                state.valueScanBarcode,
                null,
                null,
                state.valueScanBarcode.toString().trim().length,
                listItemCard[indexSelected].maVt.toString().trim()
              );
            }
          }
          else if(state is GetInformationItemFromBarCodeNotSuccess){
            // ✅ Xử lý khi không tìm thấy thông tin sản phẩm từ barcode - Logic từ SSE-Scanner
            setState(() {
              isApiLoading = false;
            });

            // ✅ Logic hợp lý: Kiểm tra URL trước, sau đó mới hiển thị popup
            // Kiểm tra URL để hiển thị message phù hợp - Logic từ SSE-Scanner
            if(Const.NAME_URL.toString().contains('dungtrang')){
              _showBarcodeError('Sản phẩm này của bạn không có trong danh sách phiếu, vui lòng kiểm tra lại');
            } else {
              // Fallback: Thử parse barcode bằng GS1 parser
              _handleBarcodeWithGS1Parser(state.barcode).then((gs1Success) {
                // ✅ Chỉ hiển thị popup "Phiếu không xác định" khi GS1 parser cũng thất bại
                if (!gs1Success) {
                  ///todo something
                }
              });
            }
          }
          else if(state is GetInformationItemFromBarCodeSuccess){
            valuesBarcode = '';
            
            // ✅ Reset API loading state khi API hoàn thành
            setState(() {
              isApiLoading = false;
            });
            
            // Tính toán lại sản xuất trong tab lịch sử
            calculatorProductionInTabHistory();
            
            // Xử lý dữ liệu từ API response để thêm vào lịch sử cho các key function cần thiết
            if (widget.keyFunction == '#3' || widget.keyFunction == '#4' || widget.keyFunction == '#7' || widget.keyFunction == '#8') {
              debugPrint('Calling _handleGetInformationItemFromBarCodeSuccess for keyFunction: ${widget.keyFunction}');
              _handleGetInformationItemFromBarCodeSuccess(state);
            } else {
              debugPrint('Skipping _handleGetInformationItemFromBarCodeSuccess for keyFunction: ${widget.keyFunction}');
            }
            
            if (widget.keyFunction == '#1') {
              if (indexSelected >= 0) {
                listItemCard[indexSelected].qrCode = valuesBarcode;
                listItemCard[indexSelected].soLuong = state.informationProduction.soLuong ?? 0;
                listItemCard[indexSelected].expirationDate = state.informationProduction.hsd;
                _showSuccessMessage('Cập nhật thông tin thành công');
              }
            }

            else{
              // Chỉ hiển thị thông báo kiểm tra cho các keyFunction không phải #3, #4, #7, #8
              // Vì các keyFunction này đã được xử lý trong _handleGetInformationItemFromBarCodeSuccess
              if (widget.keyFunction != '#3' && widget.keyFunction != '#4' && widget.keyFunction != '#7' && widget.keyFunction != '#8') {
              if(listItemCard.isNotEmpty){
                  print('check mv 1');
                for (var element in listItemCard) {

                    print(element.maVt);
                    print(_bloc.informationProduction.maVt.toString());
                  if(element.maVt.toString().trim() == _bloc.informationProduction.maVt.toString().trim()){
                    checkItemExits = true;
                    break;
                  }
                }
                if(checkItemExits == false){
                    print('check mv');
                    print('check mv');
                  _showWarningMessage('Sản phẩm này của bạn không tồn tại');
                }else{
                  _showSuccessMessage('Kiểm tra thành công');
                }
              }else{
                _showWarningMessage('Phiếu của bạn đang trống');
                }
              }
            }
          }
        },
        child: BlocBuilder<QRCodeBloc,QRCodeState>(
            bloc: _bloc,
            builder: (BuildContext context,QRCodeState state){
              return  Stack(
                children: [
                  buildScreen(context, state),
                  Visibility(
                    visible: state is QRCodeLoading,
                    child: const PendingAction(),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }

  buildScreen(context,QRCodeState state){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildAppBar(),
        Visibility(
          visible: viewQRCode == true,
          child: SizedBox(
            height: 200, width: double.infinity,
            child: buildCamera(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10,right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  const Text(
                    'Danh sách sản phẩm ',
                    style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5,),
                  Text(
                    widget.keyFunction.toString().trim().replaceAll('null', ''),
                    style: const TextStyle(fontSize: 12.0,color: subColor),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: IconButton(
                  icon: Icon(
                    EneftyIcons.scan_outline,
                    color: viewQRCode ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      viewQRCode = !viewQRCode;
                      if (viewQRCode) {
                        // ✅ Khởi động camera an toàn
                        try {
                          (_cameraKey.currentState as dynamic)?.startCamera();
                        } catch (e) {
                          debugPrint('Error starting camera: $e');
                          _showCameraErrorDialog(e);
                        }
                      } else {
                        // ✅ Dừng camera an toàn
                        try {
                          (_cameraKey.currentState as dynamic)?.stopCamera();
                        } catch (e) {
                          debugPrint('Error stopping camera: $e');
                        }
                      }
                    });
                  },
                ),
              )
            ],
          ),
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
                      tabs: List<Widget>.generate(listTabs.length, (int index) {
                        return Tab(
                          text: listTabs[index],
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
                            children: List<Widget>.generate(listTabs.length, (int index) {
                                // ✅ Logic TabBarView theo keyFunction - Logic từ SSE-Scanner
                                switch (widget.keyFunction) {
                                  case '#1': // Cập nhật số lượng
                                  case '#3': // Cập nhật vị trí
                                  case '#4': // Cập nhật pallet
                                  case '#7': // Cập nhật ngày sản xuất
                                  case '#8': // Cập nhật số lượng
                                    if (index == 0) return buildListItem();
                                    if (index == 1) return buildListItemHistory();
                                    if (index == 2) return buildInfo();
                                    break;
                                  case '#5': // Cập nhật lô hàng
                                  case '#6': // Lên phiếu giao hàng
                                    if (index == 0) return buildListItem();
                                    if (index == 1) return buildInfo();
                                    break;
                                   default:
                                    if (index == 0) return buildListItem();
                                    if (index == 1) return buildInfo();
                                    break;
                                }
                                return buildInfo(); // Fallback
                            })),
                      ),
                    ),
                  ),
                ),
                // ✅ Logic 2 nút
                Visibility(
                  visible: (widget.keyFunction == '#4' || widget.keyFunction == '#7') && _bloc.ruleActionInformationCard.status != 1,
                  child: Container(
                    height: 70, width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (tabIndex == 0) {
                                if (_bloc.masterInformationCard.sttRec.toString().replaceAll('null', '').isNotEmpty) {
                                  List<UpdateItemBarCodeRequestDetail> _listItem = [];
                                  List<UpdateItemBarCodeRequestDetail> _listConfirm = [];
                                  int indexItem = 0;
                                  int indexItem2 = 0;
                                  for (var element in _bloc.listItemHistory) {
                                    indexItem = indexItem + 1;
                                    _listItem.add(UpdateItemBarCodeRequestDetail(
                                      maVt: element.maVt,
                                      indexItem: indexItem,
                                      barcode: element.barcode,
                                      maKho: element.maKho.toString(),
                                      maLo: element.maLo.toString(),
                                      soLuong: double.tryParse(element.soLuong.toString().replaceAll('null', '0')) ?? 0.0,
                                      soCan: element.soCan.toString().replaceAll('null', '0'),
                                      hsd: element.hsd.toString().replaceAll('null', '').isEmpty ? null : element.hsd.toString().replaceAll('null', ''),
                                      nsx: element.nsx.toString().replaceAll('null', '').isEmpty ? null : element.nsx.toString().replaceAll('null', ''),
                                      sttRec: _bloc.masterInformationCard.sttRec.toString(),
                                      sttRec0: element.sttRec0.toString(),
                                      pallet: element.pallet,
                                      timeScan: element.timeScan.toString().replaceAll('T', ' ')
                                    ));
                                  }
                                  for (var element in _bloc.listItemCard) {
                                    indexItem2 = indexItem2 + 1;

                                    // ✅ Logic tổng hợp: Tìm kiếm các mã vật tư có cùng mã vật tư trong tab lịch sử và cộng tổng
                                    double totalQuantity = 0.0;
                                    double totalSoCan = 0.0;
                                    
                                    // Tìm tất cả các item trong lịch sử có cùng mã vật tư
                                    final historyItems = _bloc.listItemHistory.where(
                                      (historyItem) => historyItem.maVt.toString().trim() == element.maVt.toString().trim()
                                    ).toList();
                                    
                                    if (historyItems.isNotEmpty) {
                                      // Tính tổng soLuong và soCan từ lịch sử
                                      totalQuantity = historyItems.fold(0.0, (sum, item) => sum + (item.soLuong ?? 0.0));
                                      totalSoCan = historyItems.fold(0.0, (sum, item) => sum + (item.soCan ?? 0.0));
                                    }
                                    
                                    // ✅ Ưu tiên dữ liệu nhập tay (actualQuantity) trước
                                    final double actualQuantity = element.actualQuantity ?? 0.0;
                                    final double soCanFromItem = element.actualQuantity ?? 0.0;
                                    
                                    // Logic ưu tiên: actualQuantity (nhập tay) > tổng từ lịch sử > soCan gốc
                                    final double finalQuantity = (actualQuantity > 0) 
                                        ? actualQuantity 
                                        : ((totalQuantity > 0) ? totalQuantity : soCanFromItem);
                                    
                                    final double finalSoCan = (actualQuantity > 0) 
                                        ? actualQuantity 
                                        : ((totalSoCan > 0) ? totalSoCan : soCanFromItem);

                                    _listConfirm.add(UpdateItemBarCodeRequestDetail(
                                      maVt: element.maVt,
                                      indexItem: indexItem2,
                                      barcode: element.qrCode,
                                      maKho: element.maKho,
                                      maLo: element.maLo,
                                      soLuong: finalQuantity,
                                      soCan: finalSoCan.toString(),
                                      hsd: element.expirationDate.toString().replaceAll('null', '').isEmpty ? null : element.expirationDate.toString().replaceAll('null', ''),
                                      nsx: element.productionDate.toString().replaceAll('null', '').isEmpty ? null : element.productionDate.toString().replaceAll('null', ''),
                                      sttRec: _bloc.masterInformationCard.sttRec.toString(),
                                      sttRec0: element.sttRec0,
                                      pallet: element.pallet
                                    ));
                                  }
                                  _bloc.add(UpdateItemBarCodeEvent(
                                    listItem: _listItem,
                                    sttRec: _bloc.masterInformationCard.sttRec.toString(),
                                    action: 1,
                                    listConfirm: _listConfirm
                                  ));
                                } else {
                                  Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng quét mã Phiếu trước khi thao tác bạn êi');
                                }
                              }
                            },
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: tabIndex == 0 ? Colors.black : Colors.grey,
                                borderRadius: BorderRadius.circular(24)
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Cập nhật số lượng',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          )
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (tabIndex != 0) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return WillPopScope(
                                      onWillPop: () async => false,
                                      child: const CustomConfirm2(
                                        title: 'Xác nhận',
                                        content: 'Hãy chắc chắn là bạn muốn điều này!',
                                      ),
                                    );
                                  }).then((value) {
                                  if (!Utils.isEmpty(value) && value[0] == 'confirm') {
                                    List<UpdateItemBarCodeRequestDetail> _listItem = [];
                                    List<UpdateItemBarCodeRequestDetail> _listConfirm = [];
                                    int indexItem = 0;
                                    int indexItem2 = 0;
                                    listItem.clear();
                                    for (var element in _bloc.listItemHistory) {
                                      indexItem = indexItem + 1;
                                      _listItem.add(UpdateItemBarCodeRequestDetail(
                                        maVt: element.maVt,
                                        indexItem: indexItem,
                                        barcode: element.barcode,
                                        maKho: element.maKho.toString(),
                                        maLo: element.maLo.toString(),
                                      soLuong: double.tryParse(element.soLuong.toString().replaceAll('null', '0')) ?? 0.0,
                                      soCan: element.soCan.toString().replaceAll('null', '0'),
                                        hsd: element.hsd.toString().replaceAll('null', '').isEmpty ? null : element.hsd.toString().replaceAll('null', ''),
                                        nsx: element.nsx.toString().replaceAll('null', '').isEmpty ? null : element.nsx.toString().replaceAll('null', ''),
                                        sttRec: _bloc.masterInformationCard.sttRec.toString(),
                                        sttRec0: element.sttRec0.toString(),
                                        pallet: element.pallet,
                                        timeScan: element.timeScan.toString().replaceAll('T', ' ')
                                      ));
                                      ItemLocationModifyRequestDetail item = ItemLocationModifyRequestDetail(
                                        maVt: element.maVt.toString().trim(),
                                        maViTri: element.maViTri.toString().trim(),
                                        soLuong: double.tryParse(element.soLuong.toString().replaceAll('null', '0')) ?? 0.0,
                                        nxt: 2,
                                        teVt: element.tenVt.toString().trim(),
                                        qrCode: element.barcode.toString().trim()
                                      );
                                      listItem.add(item);
                                    }
                                    for (var element in _bloc.listItemCard) {
                                      indexItem2 = indexItem2 + 1;

                                      // ✅ Logic tổng hợp: Tìm kiếm các mã vật tư có cùng mã vật tư trong tab lịch sử và cộng tổng
                                      double totalQuantity = 0.0;
                                      double totalSoCan = 0.0;
                                      
                                      // Tìm tất cả các item trong lịch sử có cùng mã vật tư
                                      final historyItems = _bloc.listItemHistory.where(
                                        (historyItem) => historyItem.maVt.toString().trim() == element.maVt.toString().trim()
                                      ).toList();
                                      
                                      if (historyItems.isNotEmpty) {
                                        // Tính tổng soLuong và soCan từ lịch sử
                                        totalQuantity = historyItems.fold(0.0, (sum, item) => sum + (item.soLuong ?? 0.0));
                                        totalSoCan = historyItems.fold(0.0, (sum, item) => sum + (item.soCan ?? 0.0));
                                      }
                                      
                                      // ✅ Ưu tiên dữ liệu nhập tay (actualQuantity) trước
                                      final double actualQuantity = element.actualQuantity ?? 0.0;
                                      final double soCanFromItem = element.actualQuantity ?? 0.0;
                                      
                                      // Logic ưu tiên: actualQuantity (nhập tay) > tổng từ lịch sử > soCan gốc
                                      final double finalQuantity = (actualQuantity > 0) 
                                          ? actualQuantity 
                                          : ((totalQuantity > 0) ? totalQuantity : soCanFromItem);
                                      
                                      final double finalSoCan = (actualQuantity > 0) 
                                          ? actualQuantity 
                                          : ((totalSoCan > 0) ? totalSoCan : soCanFromItem);

                                      _listConfirm.add(UpdateItemBarCodeRequestDetail(
                                        maVt: element.maVt,
                                        indexItem: indexItem2,
                                        barcode: element.qrCode,
                                        maKho: element.maKho,
                                        maLo: element.maLo,
                                        soLuong: finalQuantity,
                                        soCan: finalSoCan.toString(),
                                        hsd: element.expirationDate.toString().replaceAll('null', '').isEmpty ? null : element.expirationDate.toString().replaceAll('null', ''),
                                        nsx: element.productionDate.toString().replaceAll('null', '').isEmpty ? null : element.productionDate.toString().replaceAll('null', ''),
                                        sttRec: _bloc.masterInformationCard.sttRec.toString(),
                                        sttRec0: element.sttRec0.toString(),
                                        pallet: element.pallet
                                      ));
                                    }
                                    // String sizeQuantityToString = json.encode(_listItem);
                                    if (widget.keyFunction == '#7') {
                                      _bloc.add(StockTransferConfirmEvent(
                                        listItem: _listItem,
                                        sttRec: _bloc.masterInformationCard.sttRec.toString(),
                                        listConfirm: _listConfirm
                                      ));
                                    } else {
                                      _bloc.add(UpdateItemBarCodeEvent(
                                        listItem: _listItem,
                                        sttRec: _bloc.masterInformationCard.sttRec.toString(),
                                        action: 2,
                                        listConfirm: _listConfirm
                                      ));
                                    }
                                    deleteData();
                                  }
                                });
                              }
                            },
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: tabIndex != 0 ? Colors.black : Colors.grey,
                                borderRadius: BorderRadius.circular(24)
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Xác nhận',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          )
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: (widget.keyFunction != '#4' && widget.keyFunction != '#7') && _bloc.ruleActionInformationCard.status != 1,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return WillPopScope(
                            onWillPop: () async => false,
                            child: const CustomConfirm2(
                              title: 'Xác nhận cập nhật',
                              content: 'Hãy chắc chắn là bạn muốn điều này!',
                            ),
                          );
                        }).then((value) {
                        if (!Utils.isEmpty(value) && value[0] == 'confirm') {
                          if (widget.keyFunction.toString().trim() == '#1') {
                            if (_bloc.listItemCard.isNotEmpty) {
                              List<UpdateQuantityInWarehouseDeliveryCardDetail> listItemUpdate = [];
                              List<UpdateQuantityInWarehouseDeliveryCardDetail> listBarcode = [];
                              for (var element in _bloc.listItemHistory) {
                                UpdateQuantityInWarehouseDeliveryCardDetail item = UpdateQuantityInWarehouseDeliveryCardDetail(
                                  sttRec: element.sttRec,
                                  sttRec0: element.sttRec0,
                                  soCan: double.tryParse(element.soCan.toString().replaceAll('null', '0')) ?? 0.0,
                                  soLuong: double.tryParse(element.soLuong.toString().replaceAll('null', '0')) ?? 0.0,
                                  codeProduction: element.maVt,
                                  barcode: element.barcode,
                                  index: element.index,
                                  maLo: element.maLo,
                                  maKho: element.maKho,
                                  timeScan: element.timeScan.toString().replaceAll('T', ' ')
                                );
                                listBarcode.add(item);
                              }
                              int idx = 0;
                              for (var element in _bloc.listItemCard) {
                                idx = idx + 1;
                                UpdateQuantityInWarehouseDeliveryCardDetail item = UpdateQuantityInWarehouseDeliveryCardDetail(
                                  sttRec: element.sttRec,
                                  sttRec0: element.sttRec0,
                                  soCan: double.tryParse(element.soCan.toString().replaceAll('null', '0')) ?? 0.0,
                                  soLuong: double.tryParse(element.soLuong.toString().replaceAll('null', '0')) ?? 0.0,
                                  codeProduction: element.maVt,
                                  barcode: element.qrCode,
                                  index: idx,
                                  maLo: element.maLo,
                                  maKho: element.maKho,
                                );
                                listItemUpdate.add(item);
                              }
                              _bloc.add(UpdateQuantityInWarehouseDeliveryCardEvent(
                                licensePlates: licensePlates,
                                listItem: listItemUpdate,
                                listBarcode: listBarcode,
                                action: tabIndex == 0 ? 1 : 2
                              ));
                            } else {
                              Utils.showCustomToast(context, Icons.warning_amber, 'Úi, Phiếu của bạn không có gì để cập nhật cả');
                            }
                          } else if (widget.keyFunction.toString().trim() == '#3') {
                            if (_bloc.masterInformationCard.sttRec.toString().replaceAll('null', '').isNotEmpty) {
                              List<UpdateQuantityInWarehouseDeliveryCardDetail> listItemUpdate = [];
                              List<UpdateQuantityInWarehouseDeliveryCardDetail> listBarcode = [];
                              for (var element in _bloc.listItemHistory) {
                                UpdateQuantityInWarehouseDeliveryCardDetail item = UpdateQuantityInWarehouseDeliveryCardDetail(
                                  sttRec: element.sttRec,
                                  sttRec0: element.sttRec0,
                                  soCan: double.tryParse(element.soCan.toString().replaceAll('null', '0')) ?? 0.0,
                                  soLuong: double.tryParse(element.soLuong.toString().replaceAll('null', '0')) ?? 0.0,
                                  codeProduction: element.maVt,
                                  barcode: element.barcode,
                                  index: element.index,
                                  pallet: element.pallet,
                                  timeScan: element.timeScan.toString().replaceAll('T', ' ')
                                );
                                listBarcode.add(item);
                              }
                              int index2 = 0;
                              for (var element in _bloc.listItemCard) {
                                index2 += 1;
                                UpdateQuantityInWarehouseDeliveryCardDetail item = UpdateQuantityInWarehouseDeliveryCardDetail(
                                  sttRec: element.sttRec,
                                  sttRec0: element.sttRec0,
                                  soCan: double.tryParse(element.soCan.toString().replaceAll('null', '0')) ?? 0.0,
                                  soLuong: double.tryParse(element.soLuong.toString().replaceAll('null', '0')) ?? 0.0,
                                  codeProduction: element.maVt,
                                  barcode: element.qrCode,
                                  index: index2,
                                  pallet: element.pallet
                                );
                                listItemUpdate.add(item);
                              }
                              _bloc.add(ConfirmPostPNFEvent(
                                sttRec: _bloc.masterInformationCard.sttRec.toString(),
                                listDetail: listItemUpdate,
                                listBarcode: listBarcode,
                                action: tabIndex == 0 ? 1 : 2
                              ));
                            } else {
                              Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng quét mã Phiếu trước khi thao tác bạn êi');
                            }
                          } else if (widget.keyFunction.toString().trim() == '#6') {
                            _bloc.add(CreateDeliveryEvent(
                              sttRec: _bloc.masterInformationCard.sttRec.toString(),
                              licensePlates: licensePlates,
                              codeTransfer: codeTransfer
                            ));
                          } else if (widget.keyFunction.toString().trim() == '#8') {
                            if (_bloc.masterInformationCard.sttRec.toString().replaceAll('null', '').isNotEmpty) {
                              List<UpdateQuantityInWarehouseDeliveryCardDetail> listBarcode = [];
                              for (var element in _bloc.listItemHistory) {
                                UpdateQuantityInWarehouseDeliveryCardDetail item = UpdateQuantityInWarehouseDeliveryCardDetail(
                                  sttRec: element.sttRec,
                                  sttRec0: element.sttRec0,
                                  soCan: double.tryParse(element.soCan.toString().replaceAll('null', '0')) ?? 0.0,
                                  soLuong: double.tryParse(element.soLuong.toString().replaceAll('null', '0')) ?? 0.0,
                                  codeProduction: element.maVt,
                                  barcode: element.barcode,
                                  index: element.index,
                                  timeScan: element.timeScan.toString().replaceAll('T', ' ')
                                );
                                listBarcode.add(item);
                              }
                              _bloc.add(CreateRefundBarcodeHistoryEvent(
                                sttRec: _bloc.masterInformationCard.sttRec.toString(),
                                listBarcode: listBarcode
                              ));
                            } else {
                              Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng quét mã Phiếu trước khi thao tác bạn êi');
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      height: 70, width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
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
                                  Text(
                                    widget.keyFunction == '#1' ?
                                      (tabIndex == 0 ? 'Cập nhật số lượng' : 'Xác nhận')
                                      :
                                    widget.keyFunction == '#3' ? (tabIndex == 0 ? 'Cập nhật số lượng' : 'Xác nhận')
                                      :
                                    widget.keyFunction == '#6' ? 'Lên phiếu giao hàng'
                                      :
                                    'Cập nhật thông tin phiếu',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
        ),
      ],
    );
  }

  buildListItem(){
    return ListView.separated(
        key: const Key('KeyListItems'),
        shrinkWrap: true,
        physics: listItemCard.length > 1 ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (_, index) {
          if(index != indexSelected){
            listItemCard[index].isMark = 0;
          }
          return Slidable(
            key: const ValueKey(1),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              dragDismissible: false,
              children: [
                SlidableAction(
                  onPressed:(_) {
                    showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) {
                          return UpdateBarCode(
                            barcode: listItemCard[index].qrCode.toString(),
                            hsd: listItemCard[index].expirationDate.toString(),
                            maVt: listItemCard[index].maVt,
                            selectedLotCode: listItemCard[index].maLo,
                            selectedLotName: listItemCard[index].tenLo,
                          );
                        }).then((value){
                      
                      if(value != null){
                        setState(() {
                          listItemCard[index].qrCode = value[0].toString();
                          listItemCard[index].expirationDate = value[1].toString();
                          // Cập nhật mã lô và tên lô nếu có
                          if (value.length > 2 && value[2].toString().isNotEmpty) {
                            listItemCard[index].maLo = value[2].toString();
                          }
                          if (value.length > 3 && value[3].toString().isNotEmpty) {
                            listItemCard[index].tenLo = value[3].toString();
                          }
                          // Chỉ cập nhật thông tin sản phẩm, KHÔNG thêm vào danh sách lịch sử
                          // Vì đây chỉ là chỉnh sửa thông tin, không phải quét barcode mới
                        });
                      } else {
                        print('=== VIEW INFO CARD: Dialog result is null ===');
                      }
                    });
                  },
                  borderRadius:const BorderRadius.all(Radius.circular(8)),
                  padding:const EdgeInsets.all(10),
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  icon: EneftyIcons.card_edit_outline,
                  label: 'Sửa',
                ),
              ],
            ),
            child: GestureDetector(
              onTap: (){
                if(widget.keyFunction == '#4' || widget.keyFunction == '#1'){
                  setState(() {
                    if(listItemCard[index].isMark == 1){
                      listItemCard[index].isMark = 0;
                      indexSelected = -1;
                    }
                    else{
                      listItemCard[index].isMark = 1;
                      indexSelected = index;
                    }
                  });
                }
              },
              child: Card(
                semanticContainer: true,
                margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                child: Row(
                  children: [
                    Visibility(
                      visible: widget.keyFunction == '#4' || widget.keyFunction == '#1',
                      child: SizedBox(
                        width: 50,
                        child: Transform.scale(
                          scale: 1,
                          alignment: Alignment.topLeft,
                          child: Checkbox(
                            value: listItemCard[index].isMark == 0 ? false : true,
                            onChanged: (b){
                              setState(() {
                                if(listItemCard[index].isMark == 1){
                                  listItemCard[index].isMark = 0;
                                  indexSelected = -1;
                                }
                                else{
                                  listItemCard[index].isMark = 1;
                                  indexSelected = index;
                                }
                              });
                            },
                            activeColor: mainColor,
                            hoverColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)
                            ),
                            side: WidgetStateBorderSide.resolveWith((states){
                              if(states.contains(WidgetState.pressed)){
                                return BorderSide(color: mainColor);
                              }else{
                                return BorderSide(color: mainColor);
                              }
                            }),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10,right: 6,bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '[${listItemCard[index].maVt.toString().trim()}] ${listItemCard[index].tenVt.toString().toUpperCase()}',
                              style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                              maxLines: 2,overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5,),
                            Padding(
                              padding: const EdgeInsets.only(right: 6,bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(EneftyIcons.scan_outline,color: Colors.grey,size: 15,),
                                  const SizedBox(width: 5,),
                                  Expanded(
                                    child: Text(listItemCard[index].qrCode??'Chưa cập nhật QRCode',
                                      textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 6,bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(EneftyIcons.calendar_remove_outline,color: Colors.grey,size: 15,),
                                  const SizedBox(width: 5,),
                                  Text(listItemCard[index].expirationDate??'Chưa cập nhật hạn sử dụng',
                                    textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Hiển thị mã lô nếu có
                            if (listItemCard[index].maLo != null && listItemCard[index].maLo!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 6,bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(EneftyIcons.box_outline,color: Colors.grey,size: 15,),
                                    const SizedBox(width: 5,),
                                    Expanded(
                                      child: Text('Mã lô: ${listItemCard[index].maLo}',
                                        textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(EneftyIcons.shopping_cart_outline,size: 15,color: Colors.grey),
                                const SizedBox(width: 7,),
                                Expanded(
                                  child: Text(listItemCard[index].tenKho??'Kho đang cập nhật',
                                    textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  height: 13,
                                  width: 1.5,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Loại: ${listItemCard[index].cheBien == 1 ? 'Chế biến' : listItemCard[index].sanXuat == 1 ? 'Sản xuất' :'Thường'}',
                                        style:const TextStyle(color: Colors.blueGrey,fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 13,
                                  width: 1.5,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Đơn vị: ${listItemCard[index].tenDvt}',
                                        style:const TextStyle(color: Colors.blueGrey,fontSize: 12,),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5,right: 0),
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
                                          Row(
                                            children: [
                                              Text(
                                                '\$ ${Utils.formatMoneyStringToDouble(listItemCard[index].tien??0)}',
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Container(
                                              color: Colors.transparent,
                                              width: 40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 35,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: grey_100
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        // InkWell(
                                        //     onTap: (){
                                        //       double qty = listItemCard[index].soLuong ?? 0;
                                        //       if(qty > 0){
                                        //         setState(() {
                                        //           qty = qty - 1;
                                        //           listItemCard[index].soLuong = qty;
                                        //         });
                                        //         _showInfoMessage('Số lượng: ${qty.toInt()}');
                                        //       } else {
                                        //         _showWarningMessage('Số lượng không thể nhỏ hơn 0');
                                        //       }
                                        //     },
                                        //     child: const SizedBox(width:25,child: Icon(FluentIcons.subtract_12_filled,size: 15,))),
                                        InkWell(
                                          onTap: (){
                                            showDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (context) {
                                                  return const InputQuantityShipping(title: 'Vui lòng nhập số lượng thay đổi',desc: 'Nếu số lượng không thay đổi thì bạn không cần sửa.',);
                                                }).then((values){
                                              if(values != null && values[0] != null){
                                                try {
                                                  final newQuantity = double.parse(values[0]);
                                                  if (newQuantity >= 0) {
                                                setState(() {
                                                      listItemCard[index].actualQuantity = newQuantity;
                                                    });
                                                _showWarningMessage('Số lượng thực tế: ${newQuantity.toInt()}');
                                                  } else {
                                                    _showWarningMessage('Số lượng không thể âm');
                                                  }
                                                } catch (e) {
                                                  _showWarningMessage('Số lượng không hợp lệ');
                                                }
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text("${listItemCard[index].actualQuantity ?? _getTotalQuantityForMaVt(listItemCard[index].maVt.toString())}/${listItemCard[index].soLuong ?? 0} ",
                                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // InkWell(
                                        //     onTap: (){
                                        //       double qty = listItemCard[index].soLuong ?? 0;
                                        //       setState(() {
                                        //         qty = qty + 1;
                                        //         listItemCard[index].soLuong = qty;
                                        //       });
                                        //       _showInfoMessage('Số lượng: ${qty.toInt()}');
                                        //     },
                                        //     child: const SizedBox(width:25,child: Icon(FluentIcons.add_12_filled,size: 15))),
                                      ],
                                    ),
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
              ),
            ),
          );
        },
        separatorBuilder: (_, __) {
          return const SizedBox(height: 8);
        },
        itemCount: listItemCard.length);
  }

  buildListItemHistory(){
    // ✅ Sắp xếp lịch sử theo thời gian quét mới nhất lên đầu
    final sortedHistory = List<GetListHistoryDNNKResponseData>.from(_bloc.listHistoryDNNK);
    sortedHistory.sort((a, b) {
      // Parse thời gian quét để so sánh
      try {
        final timeA = a.timeScan != null ? DateTime.parse(a.timeScan!) : DateTime(1970);
        final timeB = b.timeScan != null ? DateTime.parse(b.timeScan!) : DateTime(1970);
        return timeB.compareTo(timeA); // Sắp xếp giảm dần (mới nhất lên đầu)
      } catch (e) {
        debugPrint('Error parsing timeScan: $e');
        return 0;
      }
    });

    return sortedHistory.isNotEmpty ? ListView.separated(
        key: const Key('KeyListHistoryItem'),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (_, index) {
          final item = sortedHistory[index];
          return Slidable(
            key: const ValueKey(2),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              dragDismissible: false,
              children: [
                SlidableAction(
                  onPressed:(_) {
                    showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) {
                          return const CustomConfirm2(
                            title: 'Bạn sẽ xoá Barcode này',
                            content: 'Hãy chắc chắn là bạn muốn điều này!',
                          );
                        }).then((value){
                      if(value != null && value[0] == 'confirm'){
                        // Tìm index thực tế trong list gốc
                        final originalIndex = _bloc.listHistoryDNNK.indexWhere((element) => element == item);
                        if(originalIndex >= 0 && originalIndex < _bloc.listHistoryDNNK.length) {
                          final itemToDelete = _bloc.listHistoryDNNK[originalIndex];
                          
                          // ✅ Lấy dữ liệu an toàn, tránh "null" string
                          String palletDelete = itemToDelete.pallet?.toString() ?? '';
                          String barcodeDelete = itemToDelete.barcode?.toString() ?? '';
                          // ✅ Lấy sttRec từ masterInformationCard thay vì itemToDelete
                          String sttRec = widget.masterInformationCard.sttRec?.toString() ?? '';
                          String sttRec0 = itemToDelete.sttRec0?.toString() ?? '';
                          String maVt = itemToDelete.maVt?.toString() ?? '';
                          double soCanToDelete = itemToDelete.soCan ?? 0;
                          
                          // ✅ Debug log để kiểm tra dữ liệu
                          debugPrint('Delete item data:');
                          debugPrint('  pallet: "$palletDelete"');
                          debugPrint('  barcode: "$barcodeDelete"');
                          debugPrint('  sttRec: "$sttRec"');
                          debugPrint('  sttRec0: "$sttRec0"');
                          debugPrint('  maVt: "$maVt"');
                          
                          // ✅ Validation sttRec và sttRec0 trước khi xóa
                          if (sttRec.isEmpty || sttRec == 'null') {
                            _showWarningMessage('Lỗi: Không tìm thấy mã phiếu (sttRec). Vui lòng thử lại.');
                            return;
                          }
                          if (sttRec0.isEmpty || sttRec0 == 'null') {
                            _showWarningMessage('Lỗi: Không tìm thấy mã phiếu con (sttRec0). Vui lòng thử lại.');
                            return;
                          }
                          
                        setState(() {
                            // ✅ Xóa an toàn - chỉ xóa từ listHistoryDNNK
                            if (originalIndex < _bloc.listHistoryDNNK.length) {
                              final deletedItem = _bloc.listHistoryDNNK[originalIndex];
                              _bloc.listHistoryDNNK.removeAt(originalIndex);
                              
                              // Cập nhật actualQuantity cho item tương ứng
                              _updateActualQuantityForItem(deletedItem.maVt.toString());
                            }
                            
                            // ✅ Sync lại listItemHistory sau khi xóa
                            _syncListItemHistory();
                          });
                          
                          // ✅ Đánh dấu rằng đã có item bị xóa
                          _hasDeletedItems = true;
                          
                          // ✅ Cập nhật lại soLuong cho listItemCard như SSE-Scanner
                          _updateItemQuantityAfterDelete(maVt, soCanToDelete);
                          
                          // Cập nhật cache sau khi xóa
                          _updateCacheAfterDelete();
                          
                          // Gọi API xóa item với error handling
                          _deleteItemWithErrorHandling(
                            pallet: palletDelete,
                            barcode: barcodeDelete,
                            sttRec: sttRec,
                            sttRec0: sttRec0,
                          );
                        } else {
                          _showWarningMessage('Không thể xóa item này');
                        }
                      }
                    });
                  },
                  borderRadius:const BorderRadius.all(Radius.circular(8)),
                  padding:const EdgeInsets.all(10),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: EneftyIcons.trash_outline,
                  label: 'Xoá',
                ),
              ],
            ),
            child: Card(
              semanticContainer: true,
              margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
              child: Row(
                children: [
                  // ✅ Thêm số thứ tự - UI cải thiện với bo góc full viền
                  Container(
                    width: 50,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          subColor.withOpacity(0.15),
                          subColor.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                        color: subColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'STT',
                          style: TextStyle(
                            color: subColor.withOpacity(0.7),
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: subColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, right: 6, bottom: 5, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '[${item.maVt.toString().trim()}] ${item.tenVt.toString().toUpperCase()}',
                            style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                            maxLines: 2,overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5,),
                          // ✅ Thêm thời gian quét
                          Padding(
                            padding: const EdgeInsets.only(right: 6,bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(EneftyIcons.clock_outline,color: Colors.grey,size: 15,),
                                const SizedBox(width: 5,),
                                Expanded(
                                  child: Text(
                                    _formatTimeScan(item.timeScan),
                                    textAlign: TextAlign.left, 
                                    style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 6,bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(EneftyIcons.scan_outline,color: Colors.grey,size: 15,),
                                const SizedBox(width: 5,),
                                Expanded(
                                  child: Text(item.barcode??'Chưa cập nhật QRCode',
                                    textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5,),
                          Padding(
                            padding: const EdgeInsets.only(right: 6,bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(EneftyIcons.activity_outline,color: Colors.grey,size: 15,),
                                const SizedBox(width: 5,),
                                Expanded(
                                  child: Text('SL: ${item.soCan.toString()}',
                                    textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
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
            ),
          );
        },
        separatorBuilder: (_, __) {
          return const SizedBox(height: 8);
        },
        itemCount: sortedHistory.length) : const Center(
      child: Text('Úi, hãy cập nhật thông tin sản phẩm đã nhé',style: TextStyle(color: grey,fontSize: 12),),
    );
  }

  buildInfo(){
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5,bottom: 15),
            child: Container(
              color: grey_100,
              child: Column(
                children: [
                  const SizedBox(height: 5,),
                  Container(
                    height: 100,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(8, 0, 8,0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          backgroundImage: AssetImage(avatarStore),
                          backgroundColor: Colors.transparent,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(child: Text(
                                  '[${!Utils.isEmpty(widget.masterInformationCard.maKh.toString()) && widget.masterInformationCard.maKh.toString().trim() != 'null' ? widget.masterInformationCard.maKh.toString().trim() :widget.masterInformationCard.maNcc.toString().trim()}]  '
                                      '${(!Utils.isEmpty(widget.masterInformationCard.tenKh.toString()) && widget.masterInformationCard.tenKh.toString().trim() != 'null') ? widget.masterInformationCard.tenKh.toString().trim() : widget.masterInformationCard.tenNcc.toString().trim()}',
                                  style: const TextStyle(color: subColor,fontWeight: FontWeight.bold,fontSize: 13),maxLines: 2,overflow: TextOverflow.ellipsis,),),
                                const SizedBox(height: 5,),
                                Row(
                                  children: [
                                    const Icon(EneftyIcons.card_pos_outline,color: Colors.blueGrey,size: 18,),
                                    const SizedBox(width: 8,),
                                    Text(
                                      '${widget.masterInformationCard.sttRec}'
                                      ,style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(EneftyIcons.calendar_3_outline,color: Colors.blueGrey,size: 18,),
                                        const SizedBox(width: 8,),
                                        Text(
                                          '${widget.masterInformationCard.ngayCt}'
                                          ,style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text('${widget.masterInformationCard.statusname}',
                                          style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11)),
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
                  const SizedBox(height: 5,),
                  InkWell(
                    onTap: (){
                      if(Const.allowChangeTransfer == true){
                        showDialog(
                            context: context,
                            builder: (context) => const FilterScreen(controller: 'dmnvbh_lookup',
                              listItem: null,show: false,)).then((value){
                          if(value != null){
                            setState(() {
                              codeTransfer = value[0];
                              nameTransfer = value[1];
                            });
                          }
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12,right: 0,bottom: 5 ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(EneftyIcons.truck_fast_outline),
                                    const SizedBox(width: 18,),
                                    Text('Vận chuyển: ${widget.masterInformationCard.tenHtvc.toString().trim()}',
                                      style: const TextStyle(fontWeight: FontWeight.normal,color: subColor),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: Const.allowChangeTransfer == true,
                                child: InkWell(
                                  child: Row(
                                    children: [
                                      Text(
                                        nameTransfer.isNotEmpty ? nameTransfer : 'Tài xế của bạn',
                                        style: const TextStyle(color: subColor),
                                      ),
                                      const SizedBox(width: 5,),
                                      const Icon(EneftyIcons.search_normal_outline,size: 15,color: accent,),
                                      const SizedBox(width: 5,),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5 ),
                          const Divider(color: Colors.grey)
                        ],
                      ),
                    ),
                  ),
                  customView(EneftyIcons.note_2_outline, 'Ghi chú: ${widget.masterInformationCard.dienGiai.toString().trim()}', false, FontWeight.normal),
                ],
              ),
            ),
          ),
        customPayment(title: 'Code', value: '${widget.masterInformationCard.soCt}'),
          Visibility(
            visible: widget.keyFunction.toString().trim() != '#6' && widget.keyFunction.toString().trim() != '#1',
          child: customPayment(title: 'Tổng số lượng', value: '${widget.masterInformationCard.tSoLuong}'),
        ),
          Visibility(
            visible: widget.keyFunction.toString().trim() != '#6' && widget.keyFunction.toString().trim() != '#1',
          child: customPayment(title: 'Tổng thanh toán', value: '\$${Utils.formatMoneyStringToDouble(widget.masterInformationCard.tTT??0)}'.toString().trim()),
        ),
          const SizedBox(
            height: 5.0,
          )
        ],
      ),
    );

  }

  customPayment({required String title,required String value}){
    return Padding(
      padding: const EdgeInsets.only(left: 12,right: 12,bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,style: const TextStyle(color: subColor,fontWeight: FontWeight.bold),),
          Text(value,style: const TextStyle(color: subColor,fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }

  customView(IconData icon, String title, bool showDivider, FontWeight fontWeight){
    return Padding(
      padding: EdgeInsets.only(left: 12,right: 0,bottom: showDivider == true ? 5 : 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: 18,),
              Text(title,
                style: TextStyle(fontWeight: fontWeight,color: subColor),
              ),
            ],
          ),
          SizedBox(height: showDivider == true ? 5 : 10,),
          Visibility(
              visible: showDivider == true,
              child: const Divider(color: Colors.grey))
        ],
      ),
    );
  }


  buildCamera(){
    return BarcodeScannerWidget(
      key: _cameraKey,
      onBarcodeDetected: handleCameraBarcode,
      framePadding: const EdgeInsets.symmetric(vertical: 16),
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
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){

              Navigator.pop(context);
            },
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
            child: Center(
              child: Text(
               widget.nameCard.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.event,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  /// Build barcode widget từ SSE-Scanner (tạm thời bỏ qua vì không cần thiết)
  // void buildBarcode(
  //     Barcode bc,
  //     String data, {
  //       String? filename,
  //       double? width,
  //       double? height,
  //       double? fontHeight,
  //     }) {
  //   /// Create the Barcode
  //   final svg = bc.toSvg(
  //     data,
  //     width: width ?? 200,
  //     height: height ?? 80,
  //     fontHeight: fontHeight,
  //   );

  //   // Save the image
  //   filename ??= bc.name.replaceAll(RegExp(r'\s'), '-').toLowerCase();
  //   // File('$filename.svg').writeAsStringSync(svg); // Tạm thời bỏ qua vì không cần thiết
  // }

  /// Show choose type print dialog từ SSE-Scanner
  void showChooseTypePrint(BuildContext context, ListItem listItemCard) {
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: const CustomConfirm2(
              title: 'Chọn phương pháp in',
              content: 'Vui lòng chọn phương pháp in của bạn',
            ),
          );
        }).then((value) async {
      if (value == 'Bluetooth') {
        // pushNewScreen(context, screen: PrintingScreen(
        //   key: widget.reLoadState,
        //   codeProduction: listItemCard.maVt.toString().trim(),
        //   nameProduction: listItemCard.tenVt.toString().trim(),
        //   sttRec: listItemCard.sttRec.toString(),
        //   sttRec0: listItemCard.sttRec0.toString(),)
        //     , withNavBar: false);
        _showWarningMessage('Chức năng in Bluetooth chưa được tích hợp');
        Utils.showCustomToast(context, Icons.info, 'Chức năng in Bluetooth chưa được tích hợp');
      } else if (value == 'WiFi') {
        // pushNewScreen(context, screen: PrintWFNative(
        //   key: widget.reLoadState,
        //   codeProduction: listItemCard.maVt.toString().trim(),
        //   nameProduction: listItemCard.tenVt.toString().trim(),
        //   sttRec: listItemCard.sttRec.toString(),
        //   sttRec0: listItemCard.sttRec0.toString(),)
        //     , withNavBar: false);
        _showWarningMessage('Chức năng in WiFi chưa được tích hợp');
        Utils.showCustomToast(context, Icons.info, 'Chức năng in WiFi chưa được tích hợp');
      }
    });
  }

  /// Get list items from cache - tích hợp từ SSE-Scanner
  void getListItem() async {
    try {
      _bloc.getListItem();
      _showSuccessMessage('Đã tải danh sách từ cache');
    } catch (e) {
      _showBarcodeError('Lỗi tải danh sách từ cache');
    }
  }

  /// Cache current QRCode data - tích hợp từ SSE-Scanner
  Future<void> cacheCurrentData() async {
    try {
      await _bloc.cacheQRCodeData(
        widget.masterInformationCard.sttRec ?? '',
        _bloc.listHistoryDNNK,
      );
      _showWarningMessage('Đã lưu dữ liệu vào cache');
      Utils.showCustomToast(context, Icons.save, 'Đã lưu dữ liệu vào cache');
    } catch (e) {
      _showWarningMessage('Lỗi lưu dữ liệu vào cache');
      Utils.showCustomToast(context, Icons.error, 'Lỗi lưu dữ liệu vào cache');
    }
  }

  /// Load cached QRCode data - tích hợp từ SSE-Scanner
  Future<void> loadCachedData() async {
    try {
      final cachedData = await _bloc.getCachedQRCodeData(
        widget.masterInformationCard.sttRec ?? '',
      );
      if (cachedData.isNotEmpty) {
        setState(() {
          _bloc.listHistoryDNNK = cachedData;
        });
        _showSuccessMessage('Đã tải dữ liệu từ cache');
      } else {
        _showWarningMessage('Không có dữ liệu trong cache');
      }
    } catch (e) {
      _showBarcodeError('Lỗi tải dữ liệu từ cache');
    }
  }

  /// Clear QRCode cache - tích hợp từ SSE-Scanner
  Future<void> clearCache() async {
    try {
      await _bloc.clearQRCodeCache(
        widget.masterInformationCard.sttRec ?? '',
      );
      _showSuccessMessage('Đã xóa dữ liệu cache');
    } catch (e) {
      _showBarcodeError('Lỗi xóa dữ liệu cache');
    }
  }

  /// ✅ Xóa cache phiếu trước khi back - Logic từ SSE-Scanner
  Future<void> _clearCacheBeforeBack() async {
    try {
      final sttRec = widget.masterInformationCard.sttRec?.toString() ?? '';
      if (sttRec.isNotEmpty) {
        // Xóa cache QRCode data
        await _bloc.clearQRCodeCache(sttRec);
        
        // Xóa cache listItemHistory
        _bloc.listItemHistory.clear();
        
        // Clear các list liên quan
        _bloc.listHistoryDNNK.clear();
        
        debugPrint('✅ Cache cleared before back for sttRec: $sttRec');
      }
    } catch (e) {
      debugPrint('❌ Error clearing cache before back: $e');
    }
  }

  /// ✅ Restart camera sau khi back - Logic từ SSE-Scanner
  void _restartCameraAfterBack() {
    try {
      // Delay để đảm bảo màn hình trước đã load xong
      Future.delayed(const Duration(milliseconds: 1000), () {
        debugPrint('✅ Camera restart requested after back - màn hình trước sẽ tự xử lý');
        
        // Màn hình trước (custom_qr_code.dart) sẽ tự động restart camera
        // khi nhận được callback từ Navigator.pop()
      });
    } catch (e) {
      debugPrint('❌ Error requesting camera restart after back: $e');
    }
  }

  /// ✅ Hiển thị popup xác nhận refresh camera khi gặp lỗi
  void _showCameraErrorDialog(dynamic error) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng bằng cách tap bên ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Lỗi Camera'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Camera gặp sự cố và cần được khởi động lại.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chi tiết lỗi:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bạn có muốn thử khởi động lại camera không?',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Tắt camera view nếu user không muốn thử lại
                setState(() {
                  viewQRCode = false;
                });
              },
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _refreshCamera();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        );
      },
    );
  }

  /// ✅ Refresh camera với logic cải tiến
  void _refreshCamera() {
    try {
      debugPrint('ViewInformationCardScreen: Refreshing camera...');
      
      // Dừng camera hiện tại
      try {
        (_cameraKey.currentState as dynamic)?.stopCamera();
      } catch (e) {
        debugPrint('Error stopping camera before refresh: $e');
      }
      
      // Đợi một chút rồi khởi động lại
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          try {
            (_cameraKey.currentState as dynamic)?.startCamera();
            debugPrint('ViewInformationCardScreen: Camera refreshed successfully');
            _showSuccessMessage('Camera đã được khởi động lại thành công');
          } catch (e) {
            debugPrint('Error starting camera after refresh: $e');
            _showCameraErrorDialog(e);
          }
        }
      });
    } catch (e) {
      debugPrint('ViewInformationCardScreen: Error refreshing camera: $e');
      _showWarningMessage('Không thể khởi động lại camera: ${e.toString()}');
    }
  }

  /// Xóa item từ danh sách - tích hợp từ SSE-Scanner
  void deleteItem(int index) {
    // Validate index
    if (!_isValidDeleteIndex(index)) {
      _showBarcodeError('Không thể xóa item - chỉ mục không hợp lệ');
      return;
    }

    // Show confirmation dialog
    _showDeleteConfirmation(index);
  }

  // Validate delete index
  bool _isValidDeleteIndex(int index) {
    return index >= 0 && index < _bloc.listHistoryDNNK.length;
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => const CustomConfirm2(
        title: 'Bạn sẽ xoá Barcode này',
        content: 'Hãy chắc chắn là bạn muốn điều này!',
      ),
    ).then((value) {
      if (value != null && value[0] == 'confirm') {
        _performDelete(index);
      }
    });
  }

  // Perform the actual delete operation
  void _performDelete(int index) {
    try {
      final itemToDelete = _bloc.listHistoryDNNK[index];
      
      // Update item quantities
      _updateItemQuantities(itemToDelete);
      
      // Remove from lists
      _removeFromLists(index);
      
      // Update cache
      _updateCacheAfterDelete();
      
      // Call API to delete
      _callDeleteAPI(itemToDelete);
      
      // Show success message
      _showSuccessMessage('Đã xóa item thành công');
      
    } catch (e) {
      debugPrint('Error deleting item: $e');
      _showBarcodeError('Lỗi khi xóa item: ${e.toString()}');
    }
  }

  // Update item quantities after deletion
  void _updateItemQuantities(GetListHistoryDNNKResponseData itemToDelete) {
    if (_bloc.listItemCard.isEmpty) return;
    
    final kilogram = itemToDelete.soCan ?? 0;
    final maVt = itemToDelete.maVt.toString().trim();
    
    for (var element in _bloc.listItemCard) {
      if (element.maVt.toString().trim() == maVt) {
        final newQuantity = (element.soLuong! - kilogram).clamp(0.0, double.infinity);
        element.soLuong = roundToThreeDecimals(newQuantity);
      }
    }
  }

  // Remove item from lists
  void _removeFromLists(int index) {
    setState(() {
      final deletedItem = _bloc.listHistoryDNNK[index];
      _bloc.listHistoryDNNK.removeAt(index);
      if (index < _bloc.listItemHistory.length) {
        _bloc.listItemHistory.removeAt(index);
      }
      
      // Cập nhật actualQuantity cho item tương ứng
      _updateActualQuantityForItem(deletedItem.maVt.toString());
      
      // Cập nhật lại index cho tất cả items (đánh số từ dưới lên)
      for (int i = 0; i < _bloc.listHistoryDNNK.length; i++) {
        _bloc.listHistoryDNNK[i].index = i;
      }
    });
  }

  // Call delete API
  void _callDeleteAPI(GetListHistoryDNNKResponseData item) {
    _bloc.add(DeleteItemEvent(
      pallet: item.pallet.toString(),
      barcode: item.barcode.toString(),
      sttRec: item.sttRec.toString(),
      sttRec0: item.sttRec0.toString(),
    ));
  }


  /// Tính tổng số lượng cùng ma_vt từ danh sách lịch sử
  double _getTotalQuantityForMaVt(String maVt) {
    if (maVt.isEmpty) return 0.0;
    
    double total = 0.0;
    for (var item in _bloc.listHistoryDNNK) {
      if (item.maVt.toString().trim() == maVt.trim()) {
        // Sử dụng soLuong thay vì soCan để tính tổng số lượng
        total += item.soCan ?? 0.0;
      }
    }
    return roundToThreeDecimals(total);
  }

  /// Đồng bộ actualQuantity với dữ liệu từ lịch sử quét
  void _syncActualQuantityFromHistory() {
    for (var item in listItemCard) {
      if (item.actualQuantity == null) {
        // Nếu actualQuantity chưa được set, đồng bộ từ lịch sử quét
        item.actualQuantity = _getTotalQuantityForMaVt(item.maVt.toString());
      }
    }
  }

  /// Cập nhật actualQuantity cho một item cụ thể
  void _updateActualQuantityForItem(String maVt) {
    for (var item in listItemCard) {
      if (item.maVt.toString().trim() == maVt.trim()) {
        // Cập nhật actualQuantity từ lịch sử quét
        item.actualQuantity = _getTotalQuantityForMaVt(maVt);
        break;
      }
    }
  }

  /// Lấy số lượng để truyền vào API: actualQuantity nếu > 0, nếu = 0 thì dùng soLuong
  double _getQuantityForAPI(ListItem element) {
    return (element.actualQuantity != null && element.actualQuantity! > 0) 
        ? element.actualQuantity! 
        : (element.soLuong ?? 0);
  }

  /// ✅ Method deleteData từ SSE-Scanner
  void deleteData() {
    try {
      // Clear các list và cache
      _bloc.listItemHistory.clear();
      _bloc.listItemCard.clear();
      _bloc.listHistoryDNNK.clear();
      listItem.clear();
      
      // Clear cache QRCode nếu có sttRec
      final sttRec = _bloc.masterInformationCard.sttRec?.toString() ?? '';
      if (sttRec.isNotEmpty) {
        _bloc.clearQRCodeCache(sttRec);
      }
      
      debugPrint('✅ Data cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }
}

/// Extension for DateTime formatting từ SSE-Scanner
extension ShowDataInOwnFormat on DateTime {
  String showDateInOwnFormat() {
    return '$year-$month-$day';
  }
}

// Notification types enum
enum NotificationType { success, error, warning, info }
