import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import '../../../model/database/data_local.dart';
import '../../../model/network/response/create_task_from_customer_response.dart';
import '../../../model/network/response/detail_checkin_response.dart';
import '../../../model/network/response/detail_customer_response.dart';
import '../../../model/network/response/list_checkin_response.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import 'detail_customer_event.dart';
import 'detail_customer_state.dart';

class DetailCustomerBloc extends Bloc<DetailCustomerEvent,DetailCustomerState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;


  DetailCustomerResponseData detailCustomer =  DetailCustomerResponseData();
  List<OtherData>? listOtherData = <OtherData>[];


  DetailCustomerBloc(this.context) : super(DetailCustomerInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    on<GetDetailCustomerEvent>(_getDetailCustomerEvent);
    on<GetDetailCheckInOnlineEvent>(_getDetailCheckInOnlineEvent);
    on<CreateTaskFromCustomerEvent>(_createTaskFromCustomerEvent);
  }

  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<DetailCustomerState> emitter)async{
    emitter(DetailCustomerInitial());
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getDetailCustomerEvent(GetDetailCustomerEvent event, Emitter<DetailCustomerState> emitter)async{
    emitter(DetailCustomerLoading());
    DetailCustomerState state = _handlerGetDetailCustomer(await _networkFactory!.getDetailCustomer(_accessToken!, event.idCustomer));
    emitter(state);
  }

  void _createTaskFromCustomerEvent(CreateTaskFromCustomerEvent event, Emitter<DetailCustomerState> emitter)async{
    emitter(DetailCustomerLoading());
    DetailCustomerState state = _handlerCreateTaskFromCustomerEvent(await _networkFactory!.createTaskFromCustomer(_accessToken!, event.idCustomer));
    emitter(state);
  }

  void _getDetailCheckInOnlineEvent(GetDetailCheckInOnlineEvent event, Emitter<DetailCustomerState> emitter)async{
    emitter(DetailCustomerLoading());
    DetailCustomerState state = _handleGetDetailCheckInOnline(await _networkFactory!.getDetailCheckIn(_accessToken!,event.idCheckIn,event.idCustomer), event.idCheckIn.toString(), event.idCustomer);
    emitter(state);
  }

  DetailCustomerState _handlerGetDetailCustomer(Object data){
    if(data is String) return DetailCustomerFailure('Có lỗi xảy ra: ${data.toString()}');
    try{
      DetailCustomerResponse response = DetailCustomerResponse.fromJson(data as Map<String,dynamic>);
      detailCustomer = response.data??DetailCustomerResponseData();
      listOtherData = response.data?.otherData??[];
      return GetDetailCustomerSuccess();
    }catch(e){
      print(e);
      return DetailCustomerFailure('Có lỗi xảy ra: ${e.toString()}');
    }
  }

  int idCheckIn = 0;
  String customerId = '';

  DetailCustomerState _handlerCreateTaskFromCustomerEvent(Object data){
    if(data is String) return DetailCustomerFailure('Có lỗi xảy ra: ${data.toString()}');
    try{
      CreateTaskFromCustomerResponse response = CreateTaskFromCustomerResponse.fromJson(data as Map<String,dynamic>);
      List<CreateTaskFromCustomerResponseData> listData = response.data!;

      if(listData.isNotEmpty){
        idCheckIn = listData[0].id??0;
        customerId = listData[0].customerId.toString();
        return GetInfoTaskCustomerSuccess(idCustomer: customerId.toString(), idTask: idCheckIn);
      }
      else{
        return DetailCustomerFailure('Không lấy được dữ liệu');
      }
    }catch(e){
      return DetailCustomerFailure('Có lỗi xảy ra: ${e.toString()}');
    }
  }
  List<ListAlbum> listAlbum = [];
  List<ListAlbumTicketOffLine> listTicket = [];
  ListCheckIn detailCheckInMaster = ListCheckIn();
  DetailCustomerState _handleGetDetailCheckInOnline(Object data,String idCheckIn, String idCustomer){
    if(data is String) return DetailCustomerFailure('Úi, ${data.toString()}');
    try{
      DataLocal.listItemAlbum.clear();
      DetailCheckInResponse response = DetailCheckInResponse.fromJson(data as Map<String,dynamic>);
      listAlbum = response.listAlbum??[];
      DataLocal.listItemAlbum.addAll(response.listAlbum??[]);
      listTicket = response.listTicket??[];

      if(response.master == null){
        return GetDetailCheckInEmpty();
      }
      else{
        detailCheckInMaster = ListCheckIn(
            id: response.master?[0].id,
            tieuDe: response.master?[0].tieuDe.toString(),
            ngayCheckin: DateTime.now().toString(),
            maKh: response.master?[0].maKh.toString(),
            tenCh: response.master?[0].tenCh.toString(),
            diaChi: response.master?[0].diaChi.toString(),
            dienThoai: response.master![0].dienThoai.toString(),
            gps: response.master?[0].gps.toString(),
            trangThai: response.master?[0].trangThai.toString(),
            tgHoanThanh: response.master?[0].tgHoanThanh.toString(),
            timeCheckOut: response.master?[0].timeCheckOut.toString()
        );
        return GetDetailCheckInOnlineSuccess(itemSelect: detailCheckInMaster);
      }
    }catch(e){
      return DetailCustomerFailure('Úi, ${e.toString()}');
    }
  }
}