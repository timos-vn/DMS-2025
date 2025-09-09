import 'package:dms/model/entity/search_feature.dart';
import 'package:get_storage/get_storage.dart';

class SearchHistoryService {
  static final SearchHistoryService _instance = SearchHistoryService._internal();
  factory SearchHistoryService() => _instance;
  SearchHistoryService._internal();

  final GetStorage _storage = GetStorage();
  static const String _storageKey = 'search_history';
  static const int _maxHistoryItems = 10;

  // Lưu feature vào lịch sử tìm kiếm
  void saveToHistory(SearchFeature feature) {
    try {
      final List<dynamic> savedData = _storage.read(_storageKey) ?? [];
      List<Map<String, dynamic>> history = savedData.cast<Map<String, dynamic>>();
      
      // Kiểm tra xem feature đã tồn tại chưa
      final existingIndex = history.indexWhere((item) => item['id'] == feature.id);
      
      if (existingIndex != -1) {
        // Nếu đã tồn tại, xóa item cũ
        history.removeAt(existingIndex);
      }
      
      // Thêm feature mới vào đầu danh sách
      history.insert(0, feature.toJson());
      
      // Giới hạn số lượng item trong lịch sử
      if (history.length > _maxHistoryItems) {
        history = history.take(_maxHistoryItems).toList();
      }
      
      _storage.write(_storageKey, history);
    } catch (e) {
      // Handle error silently
    }
  }

  // Lấy lịch sử tìm kiếm
  List<SearchFeature> getSearchHistory() {
    try {
      final List<dynamic> savedData = _storage.read(_storageKey) ?? [];
      return savedData
          .map((data) => SearchFeature.fromJson(data))
          .where((feature) => feature.isEnabled)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Xóa một item khỏi lịch sử
  void removeFromHistory(String featureId) {
    try {
      final List<dynamic> savedData = _storage.read(_storageKey) ?? [];
      List<Map<String, dynamic>> history = savedData.cast<Map<String, dynamic>>();
      
      history.removeWhere((item) => item['id'] == featureId);
      _storage.write(_storageKey, history);
    } catch (e) {
      // Handle error silently
    }
  }

  // Xóa toàn bộ lịch sử
  void clearHistory() {
    try {
      _storage.remove(_storageKey);
    } catch (e) {
      // Handle error silently
    }
  }

  // Kiểm tra xem có lịch sử tìm kiếm không
  bool hasSearchHistory() {
    try {
      final List<dynamic> savedData = _storage.read(_storageKey) ?? [];
      return savedData.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Lấy số lượng item trong lịch sử
  int getHistoryCount() {
    try {
      final List<dynamic> savedData = _storage.read(_storageKey) ?? [];
      return savedData.length;
    } catch (e) {
      return 0;
    }
  }
}

