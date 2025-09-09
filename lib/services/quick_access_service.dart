import 'package:dms/model/entity/quick_access_feature.dart';
import 'package:dms/services/search_service.dart';
import 'package:get_storage/get_storage.dart';

class QuickAccessService {
  static final QuickAccessService _instance = QuickAccessService._internal();
  factory QuickAccessService() => _instance;
  QuickAccessService._internal();

  final GetStorage _storage = GetStorage();
  final SearchService _searchService = SearchService();
  static const String _storageKey = 'quick_access_features';

  // Lấy danh sách quick access features đã lưu
  List<QuickAccessFeature> getQuickAccessFeatures() {
    try {
      final List<dynamic> savedData = _storage.read(_storageKey) ?? [];
      final savedFeatures = savedData
          .map((data) => QuickAccessFeature.fromJson(data))
          .where((feature) => feature.isEnabled)
          .toList();

      // Nếu chưa có dữ liệu hoặc dữ liệu không hợp lệ, trả về default
      if (savedFeatures.isEmpty) {
        return _getDefaultQuickAccessFeatures();
      }

      return savedFeatures;
    } catch (e) {
      return _getDefaultQuickAccessFeatures();
    }
  }

  // Lấy danh sách default quick access features
  List<QuickAccessFeature> _getDefaultQuickAccessFeatures() {
    final availableFeatures = _searchService.getAvailableQuickAccessFeatures();
    return availableFeatures
        .where((feature) => feature.isEnabled)
        .take(4)
        .toList();
  }

  // Lưu danh sách quick access features
  void saveQuickAccessFeatures(List<QuickAccessFeature> features) {
    final dataToSave = features.map((feature) => feature.toJson()).toList();
    _storage.write(_storageKey, dataToSave);
  }

  // Thêm feature vào quick access
  bool addQuickAccessFeature(QuickAccessFeature feature) {
    final currentFeatures = getQuickAccessFeatures();
    if (currentFeatures.length >= 4) {
      return false; // Đã đủ 4 features
    }

    if (currentFeatures.any((f) => f.id == feature.id)) {
      return false; // Feature đã tồn tại
    }

    final newFeature = feature.copyWith(order: currentFeatures.length + 1);
    currentFeatures.add(newFeature);
    saveQuickAccessFeatures(currentFeatures);
    return true;
  }

  // Xóa feature khỏi quick access
  bool removeQuickAccessFeature(String featureId) {
    final currentFeatures = getQuickAccessFeatures();
    final updatedFeatures = currentFeatures.where((f) => f.id != featureId).toList();
    
    // Reorder remaining features
    for (int i = 0; i < updatedFeatures.length; i++) {
      updatedFeatures[i] = updatedFeatures[i].copyWith(order: i + 1);
    }
    
    saveQuickAccessFeatures(updatedFeatures);
    return true;
  }

  // Sắp xếp lại thứ tự features
  void reorderQuickAccessFeatures(int oldIndex, int newIndex) {
    final currentFeatures = getQuickAccessFeatures();
    if (oldIndex < 0 || oldIndex >= currentFeatures.length ||
        newIndex < 0 || newIndex >= currentFeatures.length) {
      return;
    }

    final item = currentFeatures.removeAt(oldIndex);
    currentFeatures.insert(newIndex, item);
    
    // Update order
    for (int i = 0; i < currentFeatures.length; i++) {
      currentFeatures[i] = currentFeatures[i].copyWith(order: i + 1);
    }
    
    saveQuickAccessFeatures(currentFeatures);
  }

  // Reset về default
  void resetToDefault() {
    _storage.remove(_storageKey);
  }

  // Kiểm tra xem feature có trong quick access không
  bool isFeatureInQuickAccess(String featureId) {
    final currentFeatures = getQuickAccessFeatures();
    return currentFeatures.any((f) => f.id == featureId);
  }

  // Lấy số lượng features hiện tại
  int getQuickAccessFeaturesCount() {
    return getQuickAccessFeatures().length;
  }

  // Kiểm tra có thể thêm feature không
  bool canAddFeature() {
    return getQuickAccessFeaturesCount() < 4;
  }
}

