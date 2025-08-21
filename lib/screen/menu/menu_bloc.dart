import 'package:dms/model/database/data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../model/database/dbhelper.dart';
import '../../model/network/response/get_dynamic_list_voucher_response.dart';
import '../../model/network/response/get_info_card_response.dart';
import '../../model/network/response/get_information_item_from_barcode_response.dart';
import '../../model/network/response/list_history_action_employee_response.dart';
import '../../model/network/services/network_factory.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';
import 'menu_event.dart';
import 'menu_state.dart';


class MenuBloc extends Bloc<MenuEvent,MenuState>{
  BuildContext context;
  NetWorkFactory? _networkFactory;
  
  String? userName;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;
  DateTime dateFrom  =  DateTime.now().add(const Duration(days: -7));
  DateTime dateTo = DateTime.now();

  DatabaseHelper db = DatabaseHelper();

  int get currentPage => _currentPage;
  int _currentPage = 1;
  int _maxPage = 20;
  bool isScroll = true;
  int get maxPage => _maxPage;
  final box = GetStorage();

  InformationProduction informationProduction = InformationProduction();
  List<MasterInfoCard> listInformationCardMaster = [];
  List<ListItem> listItemCard = [];
  RuleActionInfoCard ruleActionInformationCard = RuleActionInfoCard();
  FormatProvider formatProvider = FormatProvider();
  MasterInfoCard masterInformationCard = MasterInfoCard();

  List<GetListHistoryActionEmployeeResponseData> _list = <GetListHistoryActionEmployeeResponseData>[];
  List<GetListHistoryActionEmployeeResponseData> get list => _list;

  List<ListVoucher> listVoucher = <ListVoucher>[];
  List<ListStatus> listStatus = <ListStatus>[];
  int totalUnreadNotification = 0;

  MenuBloc(this.context) : super(InitialMenuState()){
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME);
    totalUnreadNotification = box.read(Const.TOTAL_UNREAD_NOTIFICATION) ?? 0;
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsMenuEvent>(_getPrefs);
    on<DeleteAccount>(_deleteAccount);
    on<GetListHistoryActionEmployeeEvent>(_getListHistoryActionEmployeeEvent);
    on<LogOutAppEvent>(_logOutAppEvent);
    on<GetDynamicListVoucherEvent>(_getDynamicListVoucherEvent);
    on<GetInformationCardEvent>(_getInformationCardEvent);
    on<GetTotalUnreadNotificationEvent>(_getTotalUnreadNotification);
    on<ChangePassWord>(_changePassword);

  }

  void _getInformationCardEvent(GetInformationCardEvent event, Emitter<MenuState> emitter)async{
    emitter(MenuLoading());
    MenuState state = _handleGetInformationCard(await _networkFactory!.getInformationCard(
      token: _accessToken.toString(),
      idCard: event.idCard.toString(),
      key: event.key.toString(),
    ),event.updateLocation??false);
    emitter(state);
  }

  void _getPrefs(GetPrefsMenuEvent event, Emitter<MenuState> emitter)async{
    emitter(InitialMenuState());
    emitter(GetPrefsSuccess());
  }
  void _getDynamicListVoucherEvent(GetDynamicListVoucherEvent event, Emitter<MenuState> emitter)async{
    emitter(MenuLoading());
    MenuState state = _handleListDynamicListVoucher(await _networkFactory!.getListTypeVoucher(
        _accessToken!,
        Utils.parseDateToString(dateFrom, Const.DATE_SV_FORMAT_2),
        Utils.parseDateToString(dateTo, Const.DATE_SV_FORMAT_2),
        event.voucherCode,
        event.status,
    ));
    emitter(state);
  }

  void _logOutAppEvent(LogOutAppEvent event, Emitter<MenuState> emitter)async{
    emitter(InitialMenuState());
    box.remove(Const.ACCESS_TOKEN);
    box.remove(Const.REFRESH_TOKEN);
    box.remove(Const.USER_NAME);
    box.remove(Const.USER_ID);
    box.remove(Const.CODE);
    box.remove(Const.CODE_NAME);
    box.remove(Const.EMAIL);
    box.remove(Const.PHONE_NUMBER);
    box.remove(Const.TOTAL_UNREAD_NOTIFICATION);
    await db.deleteAllDBLogin();
    emitter(LogOutAppSuccess());
  }

  void _getListHistoryActionEmployeeEvent(GetListHistoryActionEmployeeEvent event, Emitter<MenuState> emitter)async{
    emitter(InitialMenuState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? MenuLoading()
        : InitialMenuState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        MenuState state = await handleCallApiListRefundOrder(i,event.dateFrom.toString(),event.dateTo.toString(),event.idCustomer.toString());
        if (state is! GetListHistoryEmployeeSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    MenuState state = await handleCallApiListRefundOrder(_currentPage,event.dateFrom.toString(),event.dateTo.toString(),event.idCustomer.toString());
    emitter(state);
  }

  Future<MenuState> handleCallApiListRefundOrder(int pageIndex,String dateForm, String dateTo, String idCustomer) async {

    MenuState state = _handleLoadList(await _networkFactory!.getListHistoryActionEmployee(
        _accessToken!,
        dateForm,
        dateTo,
        idCustomer == 'null' ? '' : idCustomer,
        pageIndex,
        _maxPage),
        pageIndex);
    return state;
  }

  void _deleteAccount(DeleteAccount event, Emitter<MenuState> emitter)async{
    emitter(InitialMenuState());
    MenuState state = _handleDeleteAccount(await _networkFactory!.deleteAccount(_accessToken!));
    emitter(state);
  }

  MenuState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return MenuFailure('Úi, $data');
    try {
      GetListHistoryActionEmployeeResponse response = GetListHistoryActionEmployeeResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<GetListHistoryActionEmployeeResponseData> list = response.data!;
      if (!Utils.isEmpty(list) && _list.length >= (pageIndex - 1) * _maxPage + list.length) {
        _list.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _list = list;
        } else {
          _list.addAll(list);
        }
      }
      if (Utils.isEmpty(_list)) {
        return GetListHistoryEmployeeEmpty();
      } else {
        isScroll = true;
      }
      return GetListHistoryEmployeeSuccess();
    } catch (e) {
      return MenuFailure('Úi, ${e.toString()}');
    }
  }

  MenuState _handleListDynamicListVoucher(Object data) {
    if (data is String) return MenuFailure('Úi, $data');
    try {
      GetDynamicListVoucherResponse response = GetDynamicListVoucherResponse.fromJson(data as Map<String,dynamic>);
      listVoucher = response.listVoucher??[];
      listStatus = response.listStatus??[];
      if (Utils.isEmpty(listVoucher)) {
        return GetListTypeVoucherEmpty();
      } else {
        return GetListTypeVoucherSuccess();
      }
    } catch (e) {
      return MenuFailure('Úi, ${e.toString()}');
    }
  }

  MenuState _handleDeleteAccount(Object data){
    if(data is String) return MenuFailure('Úi, ${data.toString()}');
    try{
      return DeleteAccountSuccess();
    }catch(e){
      return MenuFailure('Úi, ${e.toString()}');
    }
  }

  MenuState _handleGetInformationCard(Object data, bool updateLocation){
    if(data is String) return MenuFailure(data.toString());
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
      return MenuFailure('Úi, ${e.toString()}');
    }
  }


  void _getTotalUnreadNotification(GetTotalUnreadNotificationEvent event,
      Emitter<MenuState> emitter) async {
    emitter(MenuLoading());

    try {
      Object data = await _networkFactory!.getTotalUnreadNotification(
        _accessToken!,
      );

      if (data is Map<String, dynamic>) {
        if (data['recordUnRead'] != null && data['recordUnRead'] is int) {
          int recordUnRead = data['recordUnRead'];
          totalUnreadNotification = recordUnRead;
          box.write(Const.TOTAL_UNREAD_NOTIFICATION, recordUnRead);
          emitter(GetTotalUnreadNotificationSuccess());
        } else {
          emitter(MenuFailure(''));
        }
      }
    } catch (e) {
      emitter(MenuFailure('Úi: ${e.toString()}'));
    }
  }

  void _changePassword(ChangePassWord event, Emitter<MenuState> emitter) async {
    emitter(MenuLoading());
    try {
      if (DataLocal.passwordAccount != event.oldPass) {
        emitter(MenuFailure('Mật khẩu cũ không đúng'));
      } else {
        Object data = await _networkFactory!.changePassword(
          _accessToken!,
          event.newPass,
        );
        if (data is String) emitter(MenuFailure('Úi, ${data.toString()}'));
        if (data is Map<String, dynamic>) {
          if (data['message'] != null) {
            String message = data['message'];
            DataLocal.passwordAccount = event.newPass;
            emitter(ChangePassWordSuccess(message: message));
          } else {
            emitter(MenuFailure(''));
          }
        }
      }
    } catch (e) {
      emitter(MenuFailure('Úi: ${e.toString()}'));
    }
  }
}