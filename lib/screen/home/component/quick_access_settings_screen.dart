import 'package:dms/model/entity/quick_access_feature.dart';
import 'package:dms/services/search_service.dart';
import 'package:dms/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class QuickAccessSettingsScreen extends StatefulWidget {
  const QuickAccessSettingsScreen({super.key});

  @override
  State<QuickAccessSettingsScreen> createState() => _QuickAccessSettingsScreenState();
}

class _QuickAccessSettingsScreenState extends State<QuickAccessSettingsScreen> {
  final SearchService _searchService = SearchService();
  final GetStorage _storage = GetStorage();
  static const String _storageKey = 'quick_access_features';
  
  List<QuickAccessFeature> _availableFeatures = [];
  List<QuickAccessFeature> _selectedFeatures = [];
  List<QuickAccessFeature> _unselectedFeatures = [];

  @override
  void initState() {
    super.initState();
    _loadFeatures();
  }

  void _loadFeatures() {
    _availableFeatures = _searchService.getAvailableQuickAccessFeatures();
    if (_availableFeatures.isEmpty) {
      // If no features available, show error message
      return;
    }
    _loadSelectedFeatures();
    _updateLists();
  }

  void _loadSelectedFeatures() {
    try {
      final List<dynamic> savedData = _storage.read(_storageKey) ?? [];
      _selectedFeatures = savedData
          .map((data) => QuickAccessFeature.fromJson(data))
          .where((feature) => feature.isEnabled)
          .take(4)
          .toList();
      
      // Ensure order is correct
      for (int i = 0; i < _selectedFeatures.length; i++) {
        _selectedFeatures[i] = _selectedFeatures[i].copyWith(order: i);
      }
    } catch (e) {
      // Load default features if no saved data
      _selectedFeatures = _availableFeatures
          .where((feature) => feature.isEnabled)
          .take(4)
          .toList();
      
      // Ensure order is correct
      for (int i = 0; i < _selectedFeatures.length; i++) {
        _selectedFeatures[i] = _selectedFeatures[i].copyWith(order: i);
      }
    }
  }

  void _updateLists() {
    final selectedIds = _selectedFeatures.map((f) => f.id).toSet();
    _unselectedFeatures = _availableFeatures
        .where((feature) => !selectedIds.contains(feature.id) && feature.isEnabled)
        .toList();
    
    // Sort unselected features by title for better UX
    _unselectedFeatures.sort((a, b) => a.title.compareTo(b.title));
  }

  void _saveSelectedFeatures() {
    final dataToSave = _selectedFeatures.map((feature) => feature.toJson()).toList();
    _storage.write(_storageKey, dataToSave);
  }

  void _addFeature(QuickAccessFeature feature) {
    if (_selectedFeatures.length < 4) {
      setState(() {
        final newFeature = feature.copyWith(order: _selectedFeatures.length);
        _selectedFeatures.add(newFeature);
        _updateLists();
      });
      _saveSelectedFeatures();
    }
  }

  void _removeFeature(QuickAccessFeature feature) {
    setState(() {
      _selectedFeatures.removeWhere((f) => f.id == feature.id);
      // Reorder remaining features
      for (int i = 0; i < _selectedFeatures.length; i++) {
        _selectedFeatures[i] = _selectedFeatures[i].copyWith(order: i);
      }
      _updateLists();
    });
    _saveSelectedFeatures();
  }

  void _reorderFeatures(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _selectedFeatures.removeAt(oldIndex);
      _selectedFeatures.insert(newIndex, item);
      
      // Update order for all features
      for (int i = 0; i < _selectedFeatures.length; i++) {
        _selectedFeatures[i] = _selectedFeatures[i].copyWith(order: i);
      }
      
      _saveSelectedFeatures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: subColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt tiện ích',
          style: TextStyle(color: subColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFeatures.clear();
                _updateLists();
              });
              _saveSelectedFeatures();
            },
            child: const Text(
              'Đặt lại',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kéo thả để sắp xếp thứ tự. Tối đa 4 chức năng.',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selected features
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Chức năng đã chọn (${_selectedFeatures.length}/4)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: subColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _availableFeatures.isEmpty
                      ? const Center(
                          child: Text(
                            'Không có chức năng nào khả dụng',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : _selectedFeatures.isEmpty
                          ? const Center(
                              child: Text(
                                'Chưa có chức năng nào được chọn',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ReorderableListView.builder(
                              itemCount: _selectedFeatures.length,
                              onReorder: _reorderFeatures,
                              itemBuilder: (context, index) {
                                final feature = _selectedFeatures[index];
                                return _buildSelectedFeatureTile(feature, index);
                              },
                            ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1),

          // Available features
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Chức năng có sẵn',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: subColor,
                    ),
                  ),
                ),
                Expanded(
                  child: _availableFeatures.isEmpty
                      ? const Center(
                          child: Text(
                            'Không có chức năng nào khả dụng',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : _unselectedFeatures.isEmpty
                          ? const Center(
                              child: Text(
                                'Tất cả chức năng đã được chọn',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _unselectedFeatures.length,
                              itemBuilder: (context, index) {
                                final feature = _unselectedFeatures[index];
                                return _buildAvailableFeatureTile(feature);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFeatureTile(QuickAccessFeature feature, int index) {
    return Card(
      key: ValueKey(feature.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            feature.icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          feature.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: subColor,
          ),
        ),
        subtitle: Text(
          'Thứ tự: ${index + 1}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: Colors.grey[400]),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => _removeFeature(feature),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableFeatureTile(QuickAccessFeature feature) {
    return Card(
      key: ValueKey(feature.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            feature.icon,
            color: Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          feature.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: subColor,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
          onPressed: _selectedFeatures.length < 4
              ? () => _addFeature(feature)
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chỉ có thể chọn tối đa 4 chức năng'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
        ),
      ),
    );
  }
}
