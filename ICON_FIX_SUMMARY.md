# Sửa lỗi Icon không khớp giữa Home Screen và Settings Screen

## Vấn đề
Icon hiển thị trong màn hình home và cài đặt tiện ích không khớp với icon trong danh sách chức năng có sẵn.

## Nguyên nhân
1. **SearchFeature** sử dụng các icon từ nhiều nguồn khác nhau:
   - Material Icons (`Icons`)
   - Enefty Icons (`EneftyIcons`) 
   - Material Design Icons (`MdiIcons`)

2. **QuickAccessFeature** chỉ có một bản đồ icon hạn chế (`_iconMap`) với các Material Icons cơ bản

3. Khi chuyển đổi từ `SearchFeature` sang `QuickAccessFeature`, các icon từ `EneftyIcons` và `MdiIcons` không có trong bản đồ `_iconMap`, nên chúng bị thay thế bằng `Icons.help_outline`

## Giải pháp

### 1. Cập nhật QuickAccessFeature
- **File**: `lib/model/entity/quick_access_feature.dart`
- **Thay đổi**:
  - Cập nhật method `_getIconDataFromJson()` để lưu và khôi phục đầy đủ thông tin `fontFamily` và `fontPackage`
  - Cập nhật method `toJson()` để lưu đầy đủ thông tin font family với fallback mặc định
  - Xóa method `_getIconData()` không sử dụng

### 2. Cập nhật SearchFeature
- **File**: `lib/model/entity/search_feature.dart`
- **Thay đổi**:
  - Cập nhật method `fromJson()` để sử dụng `_getIconDataFromJson()` thay vì `_getIconData()`
  - Thêm method `_getIconDataFromJson()` tương tự như QuickAccessFeature

### 3. Logic mới
```dart
static IconData _getIconDataFromJson(Map<String, dynamic> json) {
  final codePoint = json['iconCode'] as int?;
  final fontFamily = json['fontFamily'] as String?;
  final fontPackage = json['fontPackage'] as String?;
  
  if (codePoint == null) {
    return Icons.help_outline;
  }
  
  // Try to get from predefined map first (all icons in map are const)
  if (_iconMap.containsKey(codePoint)) {
    return _iconMap[codePoint]!;
  }
  
  // For icons not in predefined map, create IconData with font family info
  // This preserves the original icon even if not in our predefined map
  return IconData(
    codePoint,
    fontFamily: fontFamily,
    fontPackage: fontPackage,
  );
}
```

## Kết quả
- ✅ Icon từ `EneftyIcons` và `MdiIcons` được lưu và khôi phục đúng cách với đầy đủ thông tin font family
- ✅ Icon hiển thị nhất quán giữa màn hình home và cài đặt tiện ích
- ✅ Sử dụng đúng icon gốc từ danh sách chức năng thay vì fallback icon
- ✅ APK build thành công với kích thước 57.7MB
- ⚠️ Sử dụng `--no-tree-shake-icons` để đảm bảo tất cả icon được include (tăng kích thước APK nhưng đảm bảo icon hiển thị đúng)

## Files đã thay đổi
1. `lib/model/entity/quick_access_feature.dart`
2. `lib/model/entity/search_feature.dart`
3. `test_icon_serialization.dart` (test file)

## Test
- ✅ APK build thành công với `flutter build apk --release --no-tree-shake-icons`
- ✅ Icon serialization/deserialization hoạt động đúng với đầy đủ thông tin font family
- ✅ Icon hiển thị đúng trong cả màn hình home và cài đặt tiện ích

## Lưu ý quan trọng
- Phải sử dụng flag `--no-tree-shake-icons` khi build để đảm bảo tất cả icon fonts được include
- Điều này sẽ tăng kích thước APK nhưng đảm bảo icon hiển thị đúng
- Có thể tối ưu hóa sau bằng cách tạo bản đồ icon đầy đủ hơn để tránh cần `--no-tree-shake-icons`
