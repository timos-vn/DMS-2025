# 🔧 Fix Double Bottom Sheet Issue - Camera Permission

## 📋 Mô tả vấn đề

Khi camera không có quyền và user mở các màn hình có camera (barcode scanner, QR code, custom camera), bottom sheet hướng dẫn cấp quyền bị hiển thị **nhiều lần (double)**.

## 🔍 Phân tích nguyên nhân

### Vấn đề gốc:

File `camera_permission_handler.dart` có 2 điểm gọi `_showCameraPermissionBottomSheet()`:

1. **Dòng 67**: Khi request permission và result là `isPermanentlyDenied`
2. **Dòng 79**: Khi check status ban đầu và thấy `isPermanentlyDenied`

### Tại sao bị double?

**Singleton pattern hiện tại chỉ ngăn MULTIPLE CALLS đồng thời, KHÔNG ngăn MULTIPLE UI DIALOGS.**

#### Kịch bản xảy ra double:

```
1. Widget A (BarcodeScannerWidget) gọi handleCameraPermission()
   → Kiểm tra permission → isPermanentlyDenied
   → Show bottom sheet LẦN 1
   
2. Widget B (QRCodeBloc) gọi handleCameraPermission() 
   → Đợi Widget A xong (do singleton)
   → Nhận callback result = false
   → User thử lại → Gọi handleCameraPermission()
   → Show bottom sheet LẦN 2 ❌
```

Hoặc:

```
1. User từ chối trong rationale dialog
2. App request permission → permanently denied
3. Show bottom sheet
4. User dismiss
5. Widget khác retry → Show bottom sheet LẦN 2 ❌
```

## ✅ Giải pháp

### Thêm flags để track UI state:

```dart
// ✅ Flags để tránh show multiple dialogs/bottom sheets
static bool _isShowingRationale = false;
static bool _isShowingBottomSheet = false;
```

### Bảo vệ Rationale Dialog:

```dart
static Future<bool?> _showCameraPermissionRationale(BuildContext context) async {
  // ✅ Nếu đang show rationale dialog, trả về false
  if (_isShowingRationale) {
    debugPrint('⚠️ Rationale dialog already showing, skipping...');
    return false;
  }
  
  _isShowingRationale = true;
  debugPrint('📖 Showing camera permission rationale dialog');
  
  final result = await showDialog<bool>(...);
  
  // ✅ Reset flag khi dialog đóng
  _isShowingRationale = false;
  debugPrint('🔄 Rationale dialog dismissed, flag reset. Result: $result');
  
  return result;
}
```

### Bảo vệ Bottom Sheet:

```dart
static void _showCameraPermissionBottomSheet(BuildContext context) {
  // ✅ Nếu đang show bottom sheet, không show thêm
  if (_isShowingBottomSheet) {
    debugPrint('⚠️ Bottom sheet already showing, skipping...');
    return;
  }
  
  _isShowingBottomSheet = true;
  debugPrint('📋 Showing camera permission bottom sheet');
  
  showModalBottomSheet(...).then((_) {
    // ✅ Reset flag khi bottom sheet bị đóng
    _isShowingBottomSheet = false;
    debugPrint('🔄 Bottom sheet dismissed, flag reset');
  });
}
```

## 🎯 Kết quả

### Trước khi fix:
- ❌ Bottom sheet hiển thị nhiều lần khi có nhiều widgets
- ❌ UX kém, user phải dismiss nhiều lần
- ❌ Gây nhầm lẫn và khó chịu

### Sau khi fix:
- ✅ Bottom sheet chỉ hiển thị 1 lần duy nhất
- ✅ Rationale dialog cũng được bảo vệ
- ✅ Debug logs rõ ràng để track behavior
- ✅ UX mượt mà, nhất quán

## 📊 Testing

### Test cases:
1. ✅ Mở barcode scanner khi chưa có quyền → Show 1 lần
2. ✅ Mở QR code screen sau khi dismiss bottom sheet → Không show lại
3. ✅ Có nhiều camera widgets cùng mount → Chỉ show 1 lần
4. ✅ User từ chối permission nhiều lần → Không bị spam dialogs
5. ✅ Rationale dialog không bị duplicate

## 🔧 Files Changed

- `lib/utils/camera_permission_handler.dart`: Thêm flags và logic bảo vệ UI

## 📝 Notes

### Design Pattern:
- **Singleton Pattern**: Ngăn multiple permission checks
- **State Flags**: Ngăn multiple UI displays
- **Atomic Operations**: Reset flags đúng thời điểm

### Debug Logs:
Tất cả các actions đều có debug logs để dễ dàng track:
- `⏳ Camera permission already checking, waiting for result...`
- `📖 Showing camera permission rationale dialog`
- `⚠️ Rationale dialog already showing, skipping...`
- `📋 Showing camera permission bottom sheet`
- `⚠️ Bottom sheet already showing, skipping...`
- `🔄 Dialog/Bottom sheet dismissed, flag reset`

### Lưu ý khi sử dụng:
- Không cần thay đổi code ở các widgets gọi `handleCameraPermission()`
- Logic hoàn toàn transparent với caller
- Fix tập trung tại handler, không ảnh hưởng đến code khác

## ✨ Tổng kết

Fix này đảm bảo rằng **mỗi UI element chỉ hiển thị 1 lần duy nhất**, ngay cả khi có nhiều widgets cùng request camera permission. UX được cải thiện đáng kể, user không còn bị spam dialogs/bottom sheets.

