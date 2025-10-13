import 'package:dms/model/network/response/qr_code_response.dart';
import 'package:dms/screen/qr_code/qr_code_event.dart';
import 'package:dms/screen/qr_code/qr_code_sate.dart';
import 'package:dms/utils/camera_permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../model/network/request/create_delivery_request.dart';
import '../../model/network/request/item_location_modify_requset.dart';
import '../../model/network/request/update_item_barcode_request.dart';
import '../../model/network/request/update_quantity_warehouse_delivery_card_request.dart';
import '../../model/network/response/get_info_card_response.dart';
import '../../model/network/response/get_information_item_from_barcode_response.dart';
import '../../model/network/response/get_list_history_dnnk_response.dart';
import '../../model/network/services/network_factory.dart';
import '../../model/database/dbhelper.dart';
import '../../utils/const.dart';

class QRCodeBloc extends Bloc<QRCodeEvent,QRCodeState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  InformationProduction informationProduction = InformationProduction();
  List<GetListHistoryDNNKResponseData> listHistoryDNNK = [];
  List<GetListHistoryDNNKResponseData> listItemHistory = [];
  List<MasterInfoCard> listInformationCardMaster = [];
  List<ListItem> listItemCard = [];
  RuleActionInfoCard ruleActionInformationCard = RuleActionInfoCard();
  FormatProvider formatProvider = FormatProvider();
  MasterInfoCard masterInformationCard = MasterInfoCard();
  bool isGrantCamera = false;
  final box = GetStorage();
  
  // Database helper for caching
  DatabaseHelper db = DatabaseHelper();

  QRCodeBloc(this.context) : super(InitialQRCodeState()){
    _networkFactory = NetWorkFactory(context);
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);

    on<GetInformationCardEvent>(_getInformationCardEvent);
    on<GetKeyBySttRecEvent>(_getKeyBySttRecEvent);
    on<UpdateQuantityInWarehouseDeliveryCardEvent>(_updateQuantityInWarehouseDeliveryCardEvent);
    on<CreateDeliveryEvent>(_createDeliveryEvent);
    on<UpdateItemBarCodeEvent>(_updateItemBarCodeEvent);
    on<RefreshUpdateItemBarCodeEvent>(_refreshUpdateItemBarCodeEvent);
    on<GetInformationItemFromBarCodeEvent>(_getInformationItemFromBarCodeEvent);
    on<ConfirmPostPNFEvent>(_confirmPostPNFEvent);
    on<StockTransferConfirmEvent>(_stockTransferConfirmEvent);
    on<ItemLocationModifyEvent>(_itemLocationModifyEvent);
    on<GetListHistoryDNNKEvent>(_getListHistoryDNNKEvent);
    on<GetCameraEvent>(_getCameraEvent);
    on<GetQuantityForTicketEvent>(_getQuantityForTicketEvent);
    on<GetRuleBarCodeEvent>(_getRuleBarCodeEvent);
    on<CreateRefundBarcodeHistoryEvent>(_createRefundBarcodeHistoryEvent);
    on<GetValueBarcodeEvent>(_getValueBarcodeEvent);
    on<DeleteItemEvent>(_deleteItemEvent);
    on<SearchSuggestEvent>(_searchSuggestEvent);
    on<CheckShowCloseEvent>(_checkShowCloseEvent);
    on<GetItemBarcodeFromDMINEvent>(_getItemBarcodeFromDMINEvent);
    on<ResetDataEvent>(_resetDataEvent);
  }

  void _getCameraEvent(GetCameraEvent event, Emitter<QRCodeState> emitter)async{
    emitter(InitialQRCodeState());
    
    // ✅ Sử dụng CameraPermissionHandler với UX tốt hơn
    final bool granted = await CameraPermissionHandler.handleCameraPermission(context);
    
    if (granted) {
      isGrantCamera = true;
      emitter(GrantCameraPermission());
    } else {
      isGrantCamera = false;
      // Không cần emit failure nữa vì CameraPermissionHandler đã hiển thị UI phù hợp
      emitter(InitialQRCodeState());
    }
  }

  void _getListHistoryDNNKEvent(GetListHistoryDNNKEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());
    
    // ✅ Luôn call API để lấy dữ liệu mới nhất - Logic từ SSE-Scanner
    debugPrint('🔄 Fetching history from API for sttRec: ${event.sttRec}, keyFunc: ${event.keyFunc}');
    QRCodeState state = _handleGetListHistoryDNNK(await _networkFactory!.getListHistoryDNNK(
        token: _accessToken.toString(),
        sttRec: event.sttRec.toString(),
    ), event.sttRec.toString(), event.keyFunc);
    
    emitter(state);
  }

  void _getQuantityForTicketEvent(GetQuantityForTicketEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());
    QRCodeState state = _handleGetQuantityForTicket(await _networkFactory!.getQuantityForTicket(
        token: _accessToken.toString(),
        sttRec: event.sttRec.toString(),
        key: event.key.toString()
    ));
    emitter(state);
  }
  void _getInformationItemFromBarCodeEvent(GetInformationItemFromBarCodeEvent event, Emitter<QRCodeState> emitter)async{
    debugPrint('=== _getInformationItemFromBarCodeEvent START ===');
    debugPrint('Barcode: ${event.barcode}');
    debugPrint('Pallet: ${event.pallet}');
    debugPrint('Check: ${event.check}');
    debugPrint('IsPallet: ${event.isPallet}');
    debugPrint('Access Token: $_accessToken');
    
    emitter(QRCodeLoading());
    
    try {
      final response = await _networkFactory!.getInformationItemFromBarCode(
          token: _accessToken.toString(),
          barcode: event.barcode.toString(),
          pallet: event.pallet.toString(),
      );
      
      debugPrint('=== Raw API Response ===');
      debugPrint('Response type: ${response.runtimeType}');
      debugPrint('Response: $response');
      
      // Kiểm tra nếu response là String (error message)
      if (response is String) {
        debugPrint('=== API returned error message: $response ===');
        emitter(QRCodeFailure('API Error: $response'));
        return;
      }
      
      // Kiểm tra nếu response là Map
      if (response is Map<String, dynamic>) {
        debugPrint('=== Response is Map ===');
        debugPrint('Response keys: ${response.keys.toList()}');
        debugPrint('Response statusCode: ${response['statusCode']}');
        debugPrint('Response message: ${response['message']}');
        debugPrint('Response informationProduction: ${response['informationProduction']}');
      }
      
      QRCodeState state = _handleGetInformationItemFromBarCode(response, event.check??false, event.isPallet, event.barcode);
      debugPrint('=== Final State: ${state.runtimeType} ===');
      emitter(state);
    } catch (e) {
      debugPrint('=== Error in _getInformationItemFromBarCodeEvent: $e ===');
      emitter(QRCodeFailure('Lỗi API: ${e.toString()}'));
    }
  }
  void _getInformationCardEvent(GetInformationCardEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());
    QRCodeState state = _handleGetInformationCard(await _networkFactory!.getInformationCard(
        token: _accessToken.toString(),
        idCard: event.idCard.toString(),
        key: event.key.toString(),
    ),event.updateLocation??false);
    emitter(state);
  }
  void _getKeyBySttRecEvent(GetKeyBySttRecEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());
    QRCodeState state = _handleGetKeyBySttRec(await _networkFactory!.getKeyBySttRec(
        token: _accessToken.toString(),
        sttRec: event.sttRec.toString(),
    ));
    emitter(state);
  }
  void _refreshUpdateItemBarCodeEvent(RefreshUpdateItemBarCodeEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());
    emitter(InitialQRCodeState());
  }

  void _updateQuantityInWarehouseDeliveryCardEvent(UpdateQuantityInWarehouseDeliveryCardEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());

    UpdateQuantityInWarehouseDeliveryCardRequest request = UpdateQuantityInWarehouseDeliveryCardRequest(
        data: UpdateQuantityInWarehouseDeliveryCardRequestData(
            licensePlates: event.licensePlates,
            detail: event.listItem,
            listBarcode: event.listBarcode,
            action: event.action
        )
    );

    QRCodeState state = _handleUpdateQuantityInWarehouseDeliveryCard(
        await _networkFactory!.updateQuantityInWarehouseDeliveryCard(request,_accessToken.toString()),
        event.action
    );
    emitter(state);
  }

  void _updateItemBarCodeEvent(UpdateItemBarCodeEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());

    UpdateItemBarCodeRequest request = UpdateItemBarCodeRequest(
      data: UpdateItemBarCodeRequestData(
        sttRec: event.sttRec.toString(),
        detail: event.listItem,
        action: event.action,
        listConfirm: event.listConfirm, // ✅ Thêm listConfirm từ event
      )
    );

    QRCodeState state = _handleUpdateItemBarCode(
        await _networkFactory!.updateItemBarCode(request,_accessToken.toString()),
        event.action
    );
    emitter(state);
  }

  void _createDeliveryEvent(CreateDeliveryEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());

    CreateDeliveryRequest request = CreateDeliveryRequest(
      data: CreateDeliveryRequestData(
        licensePlates: event.licensePlates,
        sttRec: event.sttRec,
          codeTransfer: event.codeTransfer
      )
    );

    QRCodeState state = _handleCreateDelivery(
        await _networkFactory!.createDelivery(request,_accessToken.toString())
    );
    emitter(state);
  }
  void _itemLocationModifyEvent(ItemLocationModifyEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());

    ItemLocationModifyRequest request = ItemLocationModifyRequest(
      data: ItemLocationModifyRequestData(
        detail: event.listItem,
        typeFunction: event.typeFunction
      )
    );

    QRCodeState state = _handleItemLocationModify(
        await _networkFactory!.itemLocationModify(request,_accessToken.toString())
    );
    emitter(state);
  }

  void _confirmPostPNFEvent(ConfirmPostPNFEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());
    
    // ✅ Sử dụng listBarcode nếu có, nếu không thì dùng listDetail
    List<UpdateQuantityInWarehouseDeliveryCardDetail> detailList = event.listBarcode.isNotEmpty 
        ? event.listBarcode 
        : event.listDetail;
        
    UpdateQuantityInWarehouseDeliveryCardRequest request = UpdateQuantityInWarehouseDeliveryCardRequest(
      data: UpdateQuantityInWarehouseDeliveryCardRequestData(
        licensePlates: '', // Có thể cần licensePlates từ event
        detail: detailList
      )
    );
    
    QRCodeState state = _handleUpdateQuantityInWarehouseDeliveryCard(
        await _networkFactory!.updateQuantityInWarehouseDeliveryCard(request, _accessToken.toString()),
        event.action
    );
    emitter(state);
  }

  void _stockTransferConfirmEvent(StockTransferConfirmEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());
    
    UpdateItemBarCodeRequest request = UpdateItemBarCodeRequest(
      data: UpdateItemBarCodeRequestData(
        sttRec: event.sttRec.toString(),
        detail: event.listItem,
        action: 2, // Stock transfer confirm action
        listConfirm: event.listConfirm,
      )
    );
    
    QRCodeState state = _handleStockTransferConfirm(
        await _networkFactory!.updateItemBarCode(request, _accessToken.toString()),
        2 // Stock transfer confirm action
    );
    emitter(state);
  }

  QRCodeState _handleConfirmPostPNF(Object data){
    if (data is String) return QRCodeFailure('Úi, ${data.toString()}');
    try{
      return ConfirmPostPNFSuccess();
    }catch(e){
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }

  QRCodeState _handleStockTransferConfirm(Object data, int action){
    if (data is String) return QRCodeFailure('Úi, ${data.toString()}');
    try{
      return StockTransferConfirmSuccess(action: action);
    }catch(e){
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }

  QRCodeState _handleCreateDelivery(Object data){
    if (data is String) return QRCodeFailure('Úi, ${data.toString()}');
    try{
      return CreateDeliverySuccess();
    }catch(e){
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }
  QRCodeState _handleItemLocationModify(Object data){
    if (data is String) return QRCodeFailure('Úi, ${data.toString()}');
    try{
      return ItemLocationModifySuccess();
    }catch(e){
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }

  QRCodeState _handleUpdateQuantityInWarehouseDeliveryCard(Object data, int action){
    if (data is String) return QRCodeFailure('Úi, ${data.toString()}');
    try{
      return UpdateQuantityInWarehouseDeliveryCardSuccess(action: action);
    }catch(e){
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }

  QRCodeState _handleUpdateItemBarCode(Object data,int action){
    if (data is String) return QRCodeFailure('Úi, ${data.toString()}');
    try{
      return UpdateItemBarCodeSuccess(action:action);
    }catch(e){
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }

  QRCodeState _handleGetInformationCard(Object data, bool updateLocation){
    if(data is String) return QRCodeFailure(data.toString());
    try{
      if(listInformationCardMaster.isNotEmpty) {
        listInformationCardMaster.clear();
      }
      if(listItemCard.isNotEmpty) {
        listItemCard.clear();
      }
      GetInfoCardResponse response = GetInfoCardResponse.fromJson(data as Map<String,dynamic>);
      listInformationCardMaster = response.masterInfoCard!;
      listItemCard = response.listItem!;
      ruleActionInformationCard = response.ruleActionInfoCard!;
      formatProvider = response.formatProvider??FormatProvider();

      if(listInformationCardMaster.isNotEmpty){
        for (var element in listInformationCardMaster) {
          masterInformationCard = element;
        }
      }
      return GetInformationCardSuccess(updateLocation: updateLocation);
    }
    catch(e){
      print(e.toString());
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }

  QRCodeState _handleGetKeyBySttRec(Object data){
    if(data is String) return QRCodeFailure(data.toString());
    try{
      GetKeyBySttRecResponse response = GetKeyBySttRecResponse.fromJson(data as Map<String,dynamic>);
      return GetKeyBySttRecSuccess(valuesKey: response.valueKey.toString(), sttRec: response.sttRec.toString(), title: response.title.toString());
    }
    catch(e){
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }

  QRCodeState _handleGetInformationItemFromBarCode(Object data, bool check, bool isPallet, String barcode){
    debugPrint('=== _handleGetInformationItemFromBarCode START ===');
    debugPrint('Data type: ${data.runtimeType}');
    debugPrint('Data: $data');
    
    if(data is String) {
      print('=== Data is String, returning QRCodeFailure ===');
      return QRCodeFailure(data.toString());
    }
    
    try{
      print('=== Parsing response ===');
      GetInformationItemFromBarResponse response = GetInformationItemFromBarResponse.fromJson(data as Map<String,dynamic>);
      
      // Debug response structure
      print('=== Response structure ===');
      print('Response statusCode: ${response.statusCode}');
      print('Response message: ${response.message}');
      print('Response informationProduction: ${response.informationProduction}');
      
      // ✅ Logic từ SSE-Scanner: Kiểm tra nếu có thông tin sản phẩm
      if (response.informationProduction != null && 
          response.informationProduction!.maVt != null && 
          response.informationProduction!.maVt.toString().replaceAll('null', '').isNotEmpty) {
        
        // Debug informationProduction details
        print('=== InformationProduction details ===');
        print('maVt: ${response.informationProduction!.maVt}');
        print('maIn: ${response.informationProduction!.maIn}');
        print('tenVt: ${response.informationProduction!.tenVt}');
        print('soLuong: ${response.informationProduction!.soLuong}');
        print('hsd: ${response.informationProduction!.hsd}');
        print('nsx: ${response.informationProduction!.nsx}');
        print('maLo: ${response.informationProduction!.maLo}');
        print('maViTri: ${response.informationProduction!.maViTri}');
        print('maPallet: ${response.informationProduction!.maPallet}');
        
        informationProduction = response.informationProduction!;
        
        print('=== After assignment ===');
        print('informationProduction.maVt: ${informationProduction.maVt}');
        print('informationProduction.maIn: ${informationProduction.maIn}');
        print('informationProduction.soLuong: ${informationProduction.soLuong}');
        
        return GetInformationItemFromBarCodeSuccess(informationProduction: informationProduction);
      } else {
        // ✅ Logic từ SSE-Scanner: Trả về GetInformationItemFromBarCodeNotSuccess khi không tìm thấy
        print('=== WARNING: informationProduction is NULL or empty ===');
        print('=== Checking listItem ===');
        if (response.listItem != null && response.listItem!.isNotEmpty) {
          print('listItem length: ${response.listItem!.length}');
          print('First item: ${response.listItem![0].toJson()}');
        } else {
          print('listItem is also null or empty');
        }
        
        // ✅ Trả về GetInformationItemFromBarCodeNotSuccess với barcode từ event
        return GetInformationItemFromBarCodeNotSuccess(barcode: barcode);
      }
    }
    catch(e){
      print('=== Error parsing response: $e ===');
      print(e.toString());
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }

  QRCodeState _handleGetListHistoryDNNK(Object data, String sttRec, String keyFunc){
    if(data is String) return QRCodeFailure(data.toString());
    try{
      listHistoryDNNK.clear();
      listItemHistory.clear();
      // List<GetListHistoryDNNKResponseData> listHistory = []; // TODO: Uncomment when implementing database cache
      GetListHistoryDNNKResponse response = GetListHistoryDNNKResponse.fromJson(data as Map<String,dynamic>);
      listHistoryDNNK = response.data??[];
      if(listHistoryDNNK.isNotEmpty){
        for (var item in listHistoryDNNK) {
          item.isCallAPI = true;
        }
      }
      listItemHistory.addAll(response.data??[]);
      listHistoryDNNK.sort((a,b) => b.index!.compareTo(a.index!));
      listItemHistory.sort((a,b) => b.index!.compareTo(a.index!));

      // ✅ Logic từ SSE-Scanner: Merge với database cache nếu có
      // if(itemInvoices.isNotEmpty){
      //   for (var element in itemInvoices) {
      //     if(element.sttRec.toString().trim() == sttRec.toString().trim()){
      //       listHistory.addAll((json.decode(element.listHistory) as List).map((e) => GetListHistoryDNNKResponseData.fromJson(e)).toList());
      //     }
      //   }
      // }

      // if(listHistoryDNNK.isNotEmpty && listHistory.isNotEmpty){
      //   for (var element in listHistory) {
      //     bool isTrue = false;
      //     for (var elementDNNK in listHistoryDNNK) {
      //       if(elementDNNK.barcode.toString().trim().contains(element.barcode.toString().trim())
      //           && elementDNNK.timeScan.toString().replaceAll('T', ' ') == (element.timeScan.toString().replaceAll('T', ' ').trim())){
      //         isTrue = true;
      //       }
      //     }
      //     if(isTrue == false){
      //       element.timeScan.toString().replaceAll('T', ' ');
      //       listHistoryDNNK.add(element);
      //       listItemHistory.add(element);
      //     }
      //   }
      // }

      // if(listHistoryDNNK.isEmpty && listHistory.isNotEmpty){
      //   for (var element in listHistory) {
      //     if(element.sttRec.toString().trim().contains(sttRec.toString().trim())){
      //       element.timeScan.toString().replaceAll('T', ' ');
      //       listHistoryDNNK.add(element);
      //       listItemHistory.add(element);
      //     }
      //   }
      // }

      // ✅ Logic từ SSE-Scanner: Cập nhật soLuong cho listItemCard
      if(listItemCard.isNotEmpty && listHistoryDNNK.isNotEmpty){
        for (var elementCard in listItemCard) {
          double totalKg = 0;
          // double totalKgCard = elementCard.soLuong??0; // TODO: Use when implementing complex logic
          for (var element in listHistoryDNNK) {
            if(keyFunc == '#1'){
              if(elementCard.maVt.toString().trim() == element.maVt.toString().trim()
                  && elementCard.sttRec0.toString().trim() == element.sttRec0.toString().trim()){
                double kg = 0;
                kg = element.soCan??0;
                totalKg = totalKg + kg;
              }
            }else{
              if(elementCard.maVt.toString().trim() == element.maVt.toString().trim()){
                double kg = 0;
                kg = element.soCan??0;
                totalKg = totalKg + kg;
              }
            }
          }
          if(totalKg != 0){
            elementCard.soLuong = totalKg;
          }
        }
      }

      return GetListHistoryDNNKSuccess();
    }
    catch(e){
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }
  QRCodeState _handleGetQuantityForTicket(Object data){
    if(data is String) return QRCodeFailure(data.toString());
    try{
      GetQuantityForTicketResponse response = GetQuantityForTicketResponse.fromJson(data as Map<String,dynamic>);
      double sl = 0;
      double slGiao = 0;
      bool allowCreateTicket = false;
      sl = response.data?.soLuong??0;
      slGiao = response.data?.slGiao??0;

      if(slGiao < sl){
        allowCreateTicket = true;
      }else{
        allowCreateTicket = false;
      }

      return GetQuantityForTicketSuccess(allowCreate: allowCreateTicket);
    }
    catch(e){
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }

  // Các method xử lý event mới từ SSE-Scanner
  void _getRuleBarCodeEvent(GetRuleBarCodeEvent event, Emitter<QRCodeState> emitter) async {
    emitter(QRCodeLoading());
    try {
      QRCodeState state = _handleGetRuleBarCode(await _networkFactory!.getRuleBarCode(
        token: _accessToken.toString(),
      ));
      emitter(state);
    } catch (e) {
      emitter(QRCodeFailure('Lỗi xử lý quy tắc barcode: ${e.toString()}'));
    }
  }

  void _createRefundBarcodeHistoryEvent(CreateRefundBarcodeHistoryEvent event, Emitter<QRCodeState> emitter) async {
    emitter(QRCodeLoading());
    try {
      // ✅ Sử dụng listBarcode thay vì data
      UpdateQuantityInWarehouseDeliveryCardRequest request = UpdateQuantityInWarehouseDeliveryCardRequest(
        data: UpdateQuantityInWarehouseDeliveryCardRequestData(
          licensePlates: '', // Có thể cần licensePlates từ event
          detail: event.listBarcode
        )
      );
      
      QRCodeState state = _handleCreateRefundBarcodeHistory(await _networkFactory!.updateQuantityInWarehouseDeliveryCard(
        request,
        _accessToken.toString()
      ));
      emitter(state);
    } catch (e) {
      emitter(QRCodeFailure('Lỗi tạo lịch sử hoàn trả: ${e.toString()}'));
    }
  }

  void _getValueBarcodeEvent(GetValueBarcodeEvent event, Emitter<QRCodeState> emitter) async {
    emitter(QRCodeLoading());
    try {
      QRCodeState state = _handleGetValueBarcode(await _networkFactory!.getValueBarcode(
        token: _accessToken.toString(),
        barcode: event.barcode,
      ));
      emitter(state);
    } catch (e) {
      emitter(QRCodeFailure('Lỗi lấy giá trị barcode: ${e.toString()}'));
    }
  }

  void _deleteItemEvent(DeleteItemEvent event, Emitter<QRCodeState> emitter) async {
    emitter(QRCodeLoading());
    try {
      QRCodeState state = _handleDeleteItem(await _networkFactory!.deleteItem(
        token: _accessToken.toString(),
        pallet: event.pallet,
        barcode: event.barcode,
        sttRec: event.sttRec,
        sttRec0: event.sttRec0,
      ));
      emitter(state);
    } catch (e) {
      emitter(QRCodeFailure('Lỗi xóa item: ${e.toString()}'));
    }
  }

  void _searchSuggestEvent(SearchSuggestEvent event, Emitter<QRCodeState> emitter) async {
    emitter(QRCodeLoading());
    try {
      QRCodeState state = _handleSearchSuggest(await _networkFactory!.searchSuggest(
        token: _accessToken.toString(),
        query: event.query,
      ));
      emitter(state);
    } catch (e) {
      emitter(QRCodeFailure('Lỗi tìm kiếm gợi ý: ${e.toString()}'));
    }
  }

  void _checkShowCloseEvent(CheckShowCloseEvent event, Emitter<QRCodeState> emitter) async {
    emitter(QRCodeLoading());
    try {
      QRCodeState state = _handleCheckShowClose(await _networkFactory!.checkShowClose(
        token: _accessToken.toString(),
        text: event.text,
      ));
      emitter(state);
    } catch (e) {
      emitter(QRCodeFailure('Lỗi kiểm tra hiển thị đóng: ${e.toString()}'));
    }
  }

  void _getItemBarcodeFromDMINEvent(GetItemBarcodeFromDMINEvent event, Emitter<QRCodeState> emitter) async {
    emitter(QRCodeLoading());
    try {
      QRCodeState state = _handleGetItemBarcodeFromDMIN(await _networkFactory!.getItemBarcodeFromDMIN(
        token: _accessToken.toString(),
        itemCode: event.itemCode,
      ));
      emitter(state);
    } catch (e) {
      emitter(QRCodeFailure('Lỗi lấy item barcode từ DMIN: ${e.toString()}'));
    }
  }

  // Các method cache từ SSE-Scanner
  void getListItem() async {
    try {
      // Lấy dữ liệu từ database local
      // Có thể cần tạo bảng mới cho QRCode data
      debugPrint('Getting list items from cache...');
    } catch (e) {
      debugPrint('Error getting list items from cache: $e');
    }
  }

  // Cache QRCode data
  Future<void> cacheQRCodeData(String sttRec, List<GetListHistoryDNNKResponseData> data) async {
    try {
      // Lưu dữ liệu QRCode vào cache
      // Có thể sử dụng SharedPreferences hoặc SQLite
      await box.write('qr_code_data_$sttRec', data.map((e) => e.toJson()).toList());
      debugPrint('QRCode data cached for sttRec: $sttRec');
    } catch (e) {
      debugPrint('Error caching QRCode data: $e');
    }
  }

  // Get cached QRCode data
  Future<List<GetListHistoryDNNKResponseData>> getCachedQRCodeData(String sttRec) async {
    try {
      final cachedData = box.read('qr_code_data_$sttRec');
      if (cachedData != null) {
        return (cachedData as List)
            .map((e) => GetListHistoryDNNKResponseData.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting cached QRCode data: $e');
      return [];
    }
  }

  // Clear QRCode cache
  Future<void> clearQRCodeCache(String sttRec) async {
    try {
      await box.remove('qr_code_data_$sttRec');
      debugPrint('QRCode cache cleared for sttRec: $sttRec');
    } catch (e) {
      debugPrint('Error clearing QRCode cache: $e');
    }
  }

  // TODO: Uncomment when implementing database cache
  // /// ✅ Merge dữ liệu từ cache và API - Logic từ SSE-Scanner
  // List<GetListHistoryDNNKResponseData> _mergeHistoryData(
  //   List<GetListHistoryDNNKResponseData> cachedData,
  //   List<GetListHistoryDNNKResponseData> apiData,
  // ) {
  //   final Map<String, GetListHistoryDNNKResponseData> mergedMap = {};
  //   
  //   // Thêm dữ liệu từ cache trước
  //   for (var item in cachedData) {
  //     final key = '${item.sttRec0}_${item.timeScan}';
  //     mergedMap[key] = item;
  //   }
  //   
  //   // Thêm/update dữ liệu từ API (ưu tiên API)
  //   for (var item in apiData) {
  //     final key = '${item.sttRec0}_${item.timeScan}';
  //     mergedMap[key] = item; // API data sẽ override cache data
  //   }
  //   
  //   // Chuyển về list và sort theo thời gian
  //   final mergedList = mergedMap.values.toList();
  //   mergedList.sort((a, b) {
  //     try {
  //       final timeA = a.timeScan != null ? DateTime.parse(a.timeScan!) : DateTime(1970);
  //       final timeB = b.timeScan != null ? DateTime.parse(b.timeScan!) : DateTime(1970);
  //       return timeB.compareTo(timeA); // Sắp xếp giảm dần (mới nhất lên đầu)
  //     } catch (e) {
  //       return 0;
  //     }
  //   });
  //   
  //   debugPrint('✅ Merged data: ${cachedData.length} cached + ${apiData.length} API = ${mergedList.length} total');
  //   return mergedList;
  // }

  // Cache barcode scan history
  Future<void> cacheBarcodeHistory(String barcode, Map<String, dynamic> data) async {
    try {
      final historyKey = 'barcode_history_$barcode';
      await box.write(historyKey, data);
      debugPrint('Barcode history cached for: $barcode');
    } catch (e) {
      debugPrint('Error caching barcode history: $e');
    }
  }

  // Get cached barcode history
  Future<Map<String, dynamic>?> getCachedBarcodeHistory(String barcode) async {
    try {
      final historyKey = 'barcode_history_$barcode';
      return box.read(historyKey);
    } catch (e) {
      debugPrint('Error getting cached barcode history: $e');
      return null;
    }
  }

  // Các method handlers còn thiếu
  QRCodeState _handleGetRuleBarCode(Object data) {
    if (data is String) return QRCodeFailure(data.toString());
    try {
      // Xử lý response từ API getRuleBarCode
      return GetRuleBarCodeSuccess();
    } catch (e) {
      return QRCodeFailure('Lỗi xử lý rule barcode: ${e.toString()}');
    }
  }

  QRCodeState _handleCreateRefundBarcodeHistory(Object data) {
    if (data is String) return QRCodeFailure(data.toString());
    try {
      // Xử lý response từ API createRefundBarcodeHistory
      return CreateRefundBarcodeHistorySuccess();
    } catch (e) {
      return QRCodeFailure('Lỗi tạo lịch sử hoàn trả barcode: ${e.toString()}');
    }
  }

  QRCodeState _handleGetValueBarcode(Object data) {
    if (data is String) return QRCodeFailure(data.toString());
    try {
      // Xử lý response từ API getValueBarcode
      return GetValueBarcodeSuccess();
    } catch (e) {
      return QRCodeFailure('Lỗi lấy giá trị barcode: ${e.toString()}');
    }
  }

  QRCodeState _handleSearchSuggest(Object data) {
    if (data is String) return QRCodeFailure(data.toString());
    try {
      // Xử lý response từ API searchSuggest
      return SearchSuggestSuccess();
    } catch (e) {
      return QRCodeFailure('Lỗi tìm kiếm gợi ý: ${e.toString()}');
    }
  }

  QRCodeState _handleCheckShowClose(Object data) {
    if (data is String) return QRCodeFailure(data.toString());
    try {
      // Xử lý response từ API checkShowClose
      return CheckShowCloseSuccess();
    } catch (e) {
      return QRCodeFailure('Lỗi kiểm tra hiển thị đóng: ${e.toString()}');
    }
  }

  QRCodeState _handleGetItemBarcodeFromDMIN(Object data) {
    if (data is String) return QRCodeFailure(data.toString());
    try {
      // Xử lý response từ API getItemBarcodeFromDMIN
      return GetItemBarcodeFromDMINSuccess();
    } catch (e) {
      return QRCodeFailure('Lỗi lấy item barcode từ DMIN: ${e.toString()}');
    }
  }

  QRCodeState _handleDeleteItem(Object data) {
    debugPrint('QRCodeBloc: _handleDeleteItem called with data type: ${data.runtimeType}');
    debugPrint('QRCodeBloc: _handleDeleteItem data: $data');
    
    if (data is String) {
      debugPrint('QRCodeBloc: API returned error string: $data');
      return DeleteItemFailure(data.toString());
    }
    try {
      // Xử lý response từ API deleteItem
      debugPrint('QRCodeBloc: API call successful, returning DeleteItemSuccess');
      return DeleteItemSuccess();
    } catch (e) {
      debugPrint('QRCodeBloc: Error in _handleDeleteItem: $e');
      return QRCodeFailure('Lỗi xóa item: ${e.toString()}');
    }
  }

  /// Reset dữ liệu cũ để cho phép quét dữ liệu mới
  void _resetDataEvent(ResetDataEvent event, Emitter<QRCodeState> emitter) async {
    debugPrint('QRCodeBloc: Resetting old data to allow new scan');
    
    // Reset các dữ liệu cũ
    ruleActionInformationCard = RuleActionInfoCard();
    masterInformationCard = MasterInfoCard();
    listItemCard.clear();
    listInformationCardMaster.clear();
    informationProduction = InformationProduction();
    
    // Emit state để UI biết đã reset
    emitter(InitialQRCodeState());
    
    debugPrint('QRCodeBloc: Data reset completed - ready for new scan');
  }
}