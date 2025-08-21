import 'package:dms/model/network/response/qr_code_response.dart';
import 'package:dms/screen/qr_code/qr_code_event.dart';
import 'package:dms/screen/qr_code/qr_code_sate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../model/network/request/create_delivery_request.dart';
import '../../model/network/request/item_location_modify_requset.dart';
import '../../model/network/request/update_item_barcode_request.dart';
import '../../model/network/request/update_quantity_warehouse_delivery_card_request.dart';
import '../../model/network/response/get_info_card_response.dart';
import '../../model/network/response/get_information_item_from_barcode_response.dart';
import '../../model/network/response/get_list_history_dnnk_response.dart';
import '../../model/network/services/network_factory.dart';
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
  List<MasterInfoCard> listInformationCardMaster = [];
  List<ListItem> listItemCard = [];
  RuleActionInfoCard ruleActionInformationCard = RuleActionInfoCard();
  FormatProvider formatProvider = FormatProvider();
  MasterInfoCard masterInformationCard = MasterInfoCard();
  bool isGrantCamera = false;
  final box = GetStorage();

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
    on<ItemLocationModifyEvent>(_itemLocationModifyEvent);
    on<GetListHistoryDNNKEvent>(_getListHistoryDNNKEvent);
    on<GetCameraEvent>(_getCameraEvent);
    on<GetQuantityForTicketEvent>(_getQuantityForTicketEvent);
  }

  void _getCameraEvent(GetCameraEvent event, Emitter<QRCodeState> emitter)async{
    emitter(InitialQRCodeState());
    Map<Permission, PermissionStatus> permissionRequestResult = await [Permission.location,Permission.camera].request();
    if (permissionRequestResult[Permission.camera] == PermissionStatus.granted) {
      isGrantCamera = true;
      emitter(GrantCameraPermission());
    }
    else {
      if (await Permission.camera.isPermanentlyDenied) {
        emitter(InitialQRCodeState());
      } else {
        isGrantCamera = false;
        emitter(QRCodeFailure('Vui lòng cấp quyền truy cập Camera.'));
      }
    }
  }

  void _getListHistoryDNNKEvent(GetListHistoryDNNKEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());
    QRCodeState state = _handleGetListHistoryDNNK(await _networkFactory!.getListHistoryDNNK(
        token: _accessToken.toString(),
        sttRec: event.sttRec.toString(),
    ));
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
    emitter(QRCodeLoading());
    QRCodeState state = _handleGetInformationItemFromBarCode(await _networkFactory!.getInformationItemFromBarCode(
        token: _accessToken.toString(),
        barcode: event.barcode.toString(),
    ));
    emitter(state);
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
        detail: event.listItem
      )
    );

    QRCodeState state = _handleUpdateQuantityInWarehouseDeliveryCard(
        await _networkFactory!.updateQuantityInWarehouseDeliveryCard(request,_accessToken.toString())
    );
    emitter(state);
  }

  void _updateItemBarCodeEvent(UpdateItemBarCodeEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());

    UpdateItemBarCodeRequest request = UpdateItemBarCodeRequest(
      data: UpdateItemBarCodeRequestData(
        sttRec: event.sttRec.toString(),
        detail: event.listItem,
        action: event.action
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
        detail: event.listItem
      )
    );

    QRCodeState state = _handleItemLocationModify(
        await _networkFactory!.itemLocationModify(request,_accessToken.toString())
    );
    emitter(state);
  }

  void _confirmPostPNFEvent(ConfirmPostPNFEvent event, Emitter<QRCodeState> emitter)async{
    emitter(QRCodeLoading());
    QRCodeState state = _handleConfirmPostPNF(
        await _networkFactory!.updatePostPNF(_accessToken.toString(),event.sttRec)
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

  QRCodeState _handleUpdateQuantityInWarehouseDeliveryCard(Object data){
    if (data is String) return QRCodeFailure('Úi, ${data.toString()}');
    try{
      return UpdateQuantityInWarehouseDeliveryCardSuccess();
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

  QRCodeState _handleGetInformationItemFromBarCode(Object data){
    if(data is String) return QRCodeFailure(data.toString());
    try{
      GetInformationItemFromBarResponse response = GetInformationItemFromBarResponse.fromJson(data as Map<String,dynamic>);
      informationProduction = response.informationProduction!;
      return GetInformationItemFromBarCodeSuccess(informationProduction: informationProduction);
    }
    catch(e){
      return QRCodeFailure('Úi, ${e.toString()}');
    }
  }

  QRCodeState _handleGetListHistoryDNNK(Object data){
    if(data is String) return QRCodeFailure(data.toString());
    try{
      GetListHistoryDNNKResponse response = GetListHistoryDNNKResponse.fromJson(data as Map<String,dynamic>);
      listHistoryDNNK = response.data??[];
      return GetInformationItemFromBarCodeSuccess(informationProduction: informationProduction);
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
}