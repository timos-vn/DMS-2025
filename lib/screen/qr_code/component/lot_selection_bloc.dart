import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/model/network/request/dynamic_api_request.dart';
import 'package:dms/model/network/response/dynamic_api_response.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';

// Events
abstract class LotSelectionEvent {}

class LoadLotListEvent extends LotSelectionEvent {
  final String maVt;
  final String searchValue;
  final int pageIndex;
  final int pageSize;

  LoadLotListEvent({
    required this.maVt,
    this.searchValue = '',
    this.pageIndex = 1,
    this.pageSize = 10,
  });
}

class SelectLotEvent extends LotSelectionEvent {
  final LotData selectedLot;

  SelectLotEvent(this.selectedLot);
}

class ClearLotSelectionEvent extends LotSelectionEvent {}

// States
abstract class LotSelectionState {}

class LotSelectionInitial extends LotSelectionState {}

class LotSelectionLoading extends LotSelectionState {}

class LotSelectionLoaded extends LotSelectionState {
  final List<LotData> listLot;
  final int totalPage;
  final int currentPage;

  LotSelectionLoaded({
    required this.listLot,
    required this.totalPage,
    required this.currentPage,
  });
}

class LotSelectionError extends LotSelectionState {
  final String message;

  LotSelectionError(this.message);
}

class LotSelected extends LotSelectionState {
  final LotData selectedLot;

  LotSelected(this.selectedLot);
}

// Bloc
class LotSelectionBloc extends Bloc<LotSelectionEvent, LotSelectionState> {
  final NetWorkFactory _networkFactory;

  LotSelectionBloc({required NetWorkFactory networkFactory})
      : _networkFactory = networkFactory,
        super(LotSelectionInitial()) {
    on<LoadLotListEvent>(_onLoadLotList);
    on<SelectLotEvent>(_onSelectLot);
    on<ClearLotSelectionEvent>(_onClearLotSelection);
  }

  Future<void> _onLoadLotList(
    LoadLotListEvent event,
    Emitter<LotSelectionState> emit,
  ) async {
    print('=== LOT SELECTION BLOC: Loading lot list ===');
    print('maVt: ${event.maVt}');
    print('searchValue: ${event.searchValue}');
    print('pageIndex: ${event.pageIndex}');
    print('pageSize: ${event.pageSize}');
    
    emit(LotSelectionLoading());

    try {
      final request = DynamicApiRequest(
        store: "api_get_list_lot_by_item",
        param: {
          "ma_vt": event.maVt,
          "searchValue": event.searchValue,
          "PageIndex": event.pageIndex,
          "PageSize": event.pageSize,
        },
        data: {},
        resultSetNames: ["data", "pagination"],
      );

      print('=== LOT SELECTION BLOC: Calling API ===');
      print('Request: ${request.toJson()}');
      print('Token: ${Const.token}');
      print('Token length: ${Const.token.length}');
      print('Token isEmpty: ${Const.token.isEmpty}');

      // Kiểm tra token trước khi gọi API
      if (Const.token.isEmpty) {
        print('=== LOT SELECTION BLOC: Token is empty ===');
        emit(LotSelectionError('Token không hợp lệ. Vui lòng đăng nhập lại.'));
        return;
      }

      // Kiểm tra token có hợp lệ không (ít nhất phải có ký tự)
      if (Const.token.trim().isEmpty) {
        print('=== LOT SELECTION BLOC: Token is invalid (empty or whitespace) ===');
        emit(LotSelectionError('Token không hợp lệ. Vui lòng đăng nhập lại.'));
        return;
      }

      final result = await _networkFactory.callDynamicApi(
        token: Const.token,
        request: request,
      );

      print('=== LOT SELECTION BLOC: API Response ===');
      print('Result type: ${result.runtimeType}');
      print('Result: $result');

      // Debug response structure
      if (result is Map<String, dynamic>) {
        print('=== LOT SELECTION BLOC: Response structure ===');
        print('responseModel: ${result['responseModel']}');
        print('listObject: ${result['listObject']}');
        if (result['listObject'] != null && result['listObject'] is Map<String, dynamic>) {
          final listObject = result['listObject'] as Map<String, dynamic>;
          print('dataLists: ${listObject['dataLists']}');
          if (listObject['dataLists'] != null && listObject['dataLists'] is Map<String, dynamic>) {
            final dataLists = listObject['dataLists'] as Map<String, dynamic>;
            print('data: ${dataLists['data']}');
            print('pagination: ${dataLists['pagination']}');

            // Debug data array chi tiết
            if (dataLists['data'] != null && dataLists['data'] is List) {
              final dataArray = dataLists['data'] as List;
              print('Data array length: ${dataArray.length}');
              for (int i = 0; i < dataArray.length; i++) {
                print('Data[$i]: ${dataArray[i]}');
              }
            }

            // Debug pagination array chi tiết
            if (dataLists['pagination'] != null && dataLists['pagination'] is List) {
              final paginationArray = dataLists['pagination'] as List;
              print('Pagination array length: ${paginationArray.length}');
              for (int i = 0; i < paginationArray.length; i++) {
                print('Pagination[$i]: ${paginationArray[i]}');
              }
            }
          }
        }
      }

      if (result is Map<String, dynamic>) {
        try {
          print('=== LOT SELECTION BLOC: Parsing response ===');
          final response = DynamicApiResponse.fromJson(result);
          print('=== LOT SELECTION BLOC: Response parsed successfully ===');
          print('responseModel: ${response.responseModel != null ? response.responseModel!.isSucceded : null}');
          print('message: ${response.responseModel != null ? response.responseModel!.message : null}');
          print('listObject: ${response.listObject != null}');
          print('dataLists: ${response.listObject != null && response.listObject!.dataLists != null}');

          if (response.responseModel != null &&
              response.responseModel!.isSucceded == true &&
              response.listObject != null &&
              response.listObject!.dataLists != null) {
            print('=== LOT SELECTION BLOC: Emitting loaded state ===');
            print('Data count: ${response.listObject!.dataLists!.data != null ? response.listObject!.dataLists!.data!.length : 0}');
            print('Total page: ${response.listObject!.dataLists!.pagination != null && response.listObject!.dataLists!.pagination!.isNotEmpty
                ? response.listObject!.dataLists!.pagination!.first.totalPage ?? 1
                : 1}');

            emit(LotSelectionLoaded(
              listLot: response.listObject!.dataLists!.data != null ? response.listObject!.dataLists!.data! : [],
              totalPage: response.listObject!.dataLists!.pagination != null && response.listObject!.dataLists!.pagination!.isNotEmpty
                  ? response.listObject!.dataLists!.pagination!.first.totalPage ?? 1
                  : 1,
              currentPage: event.pageIndex,
            ));
          } else {
            print('=== LOT SELECTION BLOC: Emitting error state ===');
            print('isSucceded: ${response.responseModel != null ? response.responseModel!.isSucceded : null}');
            print('dataLists null: ${response.listObject == null || response.listObject!.dataLists == null}');
            emit(LotSelectionError(
                response.responseModel != null && response.responseModel!.message != null
                    ? response.responseModel!.message!
                    : 'Không thể tải danh sách lô'
            ));
          }
        } catch (e) {
          print('=== LOT SELECTION BLOC: Error parsing response ===');
          print('Error: $e');
          print('Stack trace: ${StackTrace.current}');
          emit(LotSelectionError('Lỗi khi parse dữ liệu: ${e.toString()}'));
        }
      }
      else {
        print('=== LOT SELECTION BLOC: Result is not Map<String, dynamic> ===');
        print('Result type: ${result.runtimeType}');
        print('Result: $result');
        emit(LotSelectionError('Dữ liệu trả về không đúng định dạng'));
      }
    } catch (e) {
      emit(LotSelectionError('Lỗi khi tải danh sách lô: ${e.toString()}'));
    }
  }

  void _onSelectLot(
    SelectLotEvent event,
    Emitter<LotSelectionState> emit,
  ) {
    emit(LotSelected(event.selectedLot));
  }

  void _onClearLotSelection(
    ClearLotSelectionEvent event,
    Emitter<LotSelectionState> emit,
  ) {
    emit(LotSelectionInitial());
  }
}
