import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dms/screen/dms/shipping/shipping_event.dart';
import 'package:dms/screen/dms/shipping/shipping_state.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:get_storage/get_storage.dart';

import '../../../model/network/request/list_shipping_request.dart';
import '../../../model/network/response/list_shipping_reponse.dart';
import '../../../model/network/services/network_factory.dart';

class ShippingBloc extends Bloc<ShippingEvent,ShippingState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  List<ListShippingResponseData> listShipping = <ListShippingResponseData>[];

  ShippingBloc(this.context) : super(ShippingInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsShippingEvent>(_getPrefs);
    on<GetListShippingEvent>(_getListShippingEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsShippingEvent event, Emitter<ShippingState> emitter)async{
    emitter(ShippingInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getListShippingEvent(GetListShippingEvent event, Emitter<ShippingState> emitter)async{
    emitter(ShippingLoading());
    ListShippingRequest request = ListShippingRequest(
      dateTimeFrom: Utils.parseDateToString(event.dateFrom, Const.DATE_SV_FORMAT),
      dateTimeTo: Utils.parseDateToString(event.dateTo, Const.DATE_SV_FORMAT),
    );
    ShippingState state = _handleGetListShipping(await _networkFactory!.getListShipping(request,_accessToken!));
    emitter(state);
  }

  ShippingState _handleGetListShipping(Object data){
    if(data is String) return GetListShippingFailure('Có lỗi xảy ra'+ ": ${data.toString()}");
    try{
     ListShippingResponse response = ListShippingResponse.fromJson(data as Map<String,dynamic>);
      listShipping = response.data!;
      if(listShipping.isEmpty){
        return GetListShippingEmpty();
      }else{
        return GetListShippingSuccess();
      }
    }catch(e){
      print(e.toString());
      return GetListShippingFailure('Có lỗi xảy ra'+ ": ${e.toString()}");
    }
  }
}