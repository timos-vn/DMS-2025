# 📸 Camera Permission Handler - Hướng Dẫn Sử Dụng

## 🎯 Tổng Quan

`CameraPermissionHandler` là một utility class hoàn chỉnh để xử lý camera permission với UX/UI tốt nhất, giúp người dùng hiểu rõ TẠI SAO cần quyền và CÁCH CẤP quyền một cách dễ dàng.

### ✨ Các Tính Năng

- ✅ **Educational Rationale** - Giải thích rõ ràng tại sao cần quyền camera
- ✅ **Progressive Flow** - Hướng dẫn từng bước một cách logic
- ✅ **Non-blocking** - Không ép buộc, cho phép người dùng từ chối
- ✅ **Helpful Guide** - Hướng dẫn chi tiết cách mở Settings nếu bị permanently denied
- ✅ **Beautiful UI** - Dialog, Bottom Sheet, Snackbar thiết kế đẹp mắt
- ✅ **Consistent** - Tuân theo design pattern của các app lớn (Instagram, WhatsApp...)

---

## 🚀 Cách Sử Dụng

### 1️⃣ **Basic Usage - Xử lý toàn bộ flow tự động**

```dart
import 'package:dms/utils/camera_permission_handler.dart';

// Trong StatefulWidget hoặc method cần camera
final bool hasPermission = await CameraPermissionHandler.handleCameraPermission(context);

if (hasPermission) {
  // ✅ Có quyền camera - tiếp tục logic
  _openCamera();
} else {
  // ❌ Không có quyền - CameraPermissionHandler đã hiển thị UI phù hợp
  print('Camera permission denied');
}
```

**Flow tự động:**
1. Nếu đã có quyền → Return `true` ngay
2. Nếu chưa hỏi → Hiển thị **Educational Dialog** giải thích
3. Nếu người dùng đồng ý → Request permission
4. Nếu bị permanently denied → Hiển thị **Bottom Sheet** hướng dẫn mở Settings
5. Nếu từ chối → Hiển thị **Snackbar** nhẹ nhàng

---

### 2️⃣ **Sử dụng trong BLoC (QRCodeBloc)**

```dart
// lib/screen/qr_code/qr_code_bloc.dart

void _getCameraEvent(GetCameraEvent event, Emitter<QRCodeState> emitter) async {
  emitter(InitialQRCodeState());
  
  // ✅ Sử dụng CameraPermissionHandler
  final bool granted = await CameraPermissionHandler.handleCameraPermission(context);
  
  if (granted) {
    isGrantCamera = true;
    emitter(GrantCameraPermission());
  } else {
    isGrantCamera = false;
    emitter(InitialQRCodeState());
  }
}
```

---

### 3️⃣ **Empty State trong Camera Screen**

Khi camera không có quyền, hiển thị empty state với hướng dẫn:

```dart
// lib/widget/custom_camera.dart

@override
Widget build(BuildContext context) {
  if (!isCameraReady) {
    return FutureBuilder<PermissionStatus>(
      future: Permission.camera.status,
      builder: (context, snapshot) {
        if (snapshot.hasData && 
            (snapshot.data!.isDenied || snapshot.data!.isPermanentlyDenied)) {
          
          // ✅ Hiển thị Empty State với hướng dẫn
          return Scaffold(
            body: CameraPermissionHandler.buildCameraPermissionEmptyState(
              context,
              onRetry: () {
                // Callback khi người dùng cấp quyền và muốn thử lại
                _setupCamera();
              },
            ),
          );
        }
        
        // Loading
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
  
  // Camera preview...
}
```

**Empty State bao gồm:**
- 🎨 Icon lớn animated
- 📝 Tiêu đề và mô tả rõ ràng
- 🔘 Nút "Cấp quyền Camera" lớn, nổi bật
- 🔙 Nút "Quay lại" để thoát

---

### 4️⃣ **Permission Banner cho Main Screen**

Hiển thị banner cố định khi chưa có quyền camera:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Trang chủ')),
    body: FutureBuilder<PermissionStatus>(
      future: Permission.camera.status,
      builder: (context, snapshot) {
        return Column(
          children: [
            // ✅ Hiển thị banner nếu chưa có quyền
            if (snapshot.hasData && 
                (snapshot.data!.isDenied || snapshot.data!.isPermanentlyDenied))
              CameraPermissionHandler.buildPermissionBanner(context),
            
            // Nội dung chính
            Expanded(
              child: YourMainContent(),
            ),
          ],
        );
      },
    ),
  );
}
```

**Banner bao gồm:**
- ⚠️ Icon warning
- 📝 Thông báo ngắn gọn
- 🔘 Nút "Cài đặt" để mở Settings
- ❌ Nút "Đóng" để ẩn banner

---

### 5️⃣ **Check Permission Status (Utility)**

Kiểm tra trạng thái permission mà không hiển thị UI:

```dart
// Kiểm tra status hiện tại
PermissionStatus status = await CameraPermissionHandler.checkCameraPermissionStatus();

if (status.isGranted) {
  print('✅ Đã có quyền');
} else if (status.isDenied) {
  print('❌ Chưa cấp quyền hoặc vừa từ chối');
} else if (status.isPermanentlyDenied) {
  print('⛔ Bị từ chối vĩnh viễn');
}

// Kiểm tra có nên hiển thị rationale không
bool shouldShow = await CameraPermissionHandler.shouldShowRationale();
if (shouldShow) {
  // Có thể request lại
}
```

---

## 🎨 UI Components

### 1. Educational Rationale Dialog

<img src="https://via.placeholder.com/300x500?text=Rationale+Dialog" width="200"/>

**Khi nào xuất hiện:**
- Lần đầu tiên request permission
- Người dùng vừa từ chối (chưa permanently)

**Nội dung:**
- 🎯 Tiêu đề với icon camera
- 📋 Danh sách lý do cần quyền
- 🔒 Thông tin bảo mật
- ✅ Nút "Cho phép" (primary)
- ❌ Nút "Từ chối" (secondary)

---

### 2. Settings Guide Bottom Sheet

<img src="https://via.placeholder.com/300x500?text=Settings+Guide" width="200"/>

**Khi nào xuất hiện:**
- Permission bị permanently denied
- Người dùng bấm "Cấp quyền" trong Empty State

**Nội dung:**
- 🎨 Icon camera lớn với nền màu
- 📝 Mô tả ngắn gọn
- 1️⃣2️⃣3️⃣4️⃣ Hướng dẫn 4 bước
- 🔘 Nút "Mở Cài đặt" (primary, to)
- 🔘 Nút "Để sau" (secondary, nhỏ)

---

### 3. Permission Snackbar

<img src="https://via.placeholder.com/300x100?text=Snackbar" width="250"/>

**Khi nào xuất hiện:**
- Người dùng từ chối trong dialog
- Reminder nhẹ nhàng

**Nội dung:**
- 📸 Icon camera
- 📝 Text ngắn gọn
- 🔘 Action "Cấp quyền"

---

### 4. Success Snackbar

<img src="https://via.placeholder.com/300x100?text=Success" width="250"/>

**Khi nào xuất hiện:**
- Sau khi cấp quyền thành công

**Nội dung:**
- ✅ Icon check
- 📝 "Đã cấp quyền Camera thành công!"
- 🎨 Màu xanh lá

---

### 5. Empty State

<img src="https://via.placeholder.com/300x500?text=Empty+State" width="200"/>

**Khi nào xuất hiện:**
- Trong camera screen khi chưa có quyền

**Nội dung:**
- 🎨 Icon lớn animated (no photography)
- 📝 Tiêu đề to, rõ ràng
- 📝 Mô tả chi tiết
- 🔘 Nút "Cấp quyền Camera" (full width, primary)
- 🔘 Nút "Quay lại" (text button)

---

### 6. Permission Banner

<img src="https://via.placeholder.com/300x100?text=Banner" width="250"/>

**Khi nào xuất hiện:**
- Trong main screen khi chưa có quyền

**Nội dung:**
- ⚠️ Icon warning màu cam
- 📝 Text ngắn gọn
- 🔘 Action "Cài đặt"
- ❌ Action "Đóng"

---

## 🔄 Permission Flow Diagram

```
┌─────────────────────────────────────────┐
│  handleCameraPermission()               │
└─────────────────┬───────────────────────┘
                  │
                  ▼
         ┌────────────────┐
         │ Check Status   │
         └────────┬───────┘
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
  ┌──────────┐      ┌──────────────┐
  │ Granted  │      │ Denied/      │
  │          │      │ Permanently  │
  └────┬─────┘      └──────┬───────┘
       │                   │
       │                   ▼
       │          ┌─────────────────┐
       │          │ Show Rationale  │
       │          │    Dialog       │
       │          └────────┬────────┘
       │                   │
       │          ┌────────┴────────┐
       │          │                 │
       │          ▼                 ▼
       │    ┌──────────┐     ┌──────────┐
       │    │ Allow    │     │ Deny     │
       │    └────┬─────┘     └────┬─────┘
       │         │                │
       │         ▼                ▼
       │  ┌─────────────┐  ┌─────────────┐
       │  │  Request    │  │   Show      │
       │  │ Permission  │  │  Snackbar   │
       │  └──────┬──────┘  └─────────────┘
       │         │
       │  ┌──────┴──────┐
       │  │             │
       │  ▼             ▼
       │ ┌──────┐  ┌──────────────┐
       │ │Grant │  │ Permanently  │
       │ │      │  │   Denied     │
       │ └──┬───┘  └──────┬───────┘
       │    │             │
       ▼    ▼             ▼
  ┌─────────────┐  ┌─────────────────┐
  │   Return    │  │  Show Bottom    │
  │    true     │  │     Sheet       │
  └─────────────┘  │ (Guide to       │
                   │  Settings)      │
                   └────────┬────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │ User opens      │
                   │   Settings      │
                   └─────────────────┘
```

---

## 📝 Best Practices

### ✅ DO:

1. **Luôn giải thích TẠI SAO cần quyền TRƯỚC KHI request**
   ```dart
   // ✅ Tốt
   await CameraPermissionHandler.handleCameraPermission(context);
   
   // ❌ Tệ
   await Permission.camera.request();
   ```

2. **Cho phép người dùng từ chối và vẫn dùng các tính năng khác**
   ```dart
   if (!hasPermission) {
     // Vẫn cho phép dùng app, chỉ ẩn features cần camera
     return HomeScreenWithoutCamera();
   }
   ```

3. **Hiển thị hướng dẫn chi tiết khi permanently denied**
   ```dart
   // ✅ CameraPermissionHandler tự động làm điều này
   ```

4. **Sử dụng Empty State thay vì error message**
   ```dart
   // ✅ Tốt
   return CameraPermissionHandler.buildCameraPermissionEmptyState(context);
   
   // ❌ Tệ
   return Text('Error: No camera permission');
   ```

### ❌ DON'T:

1. **Không request permission ngay khi mở app**
   ```dart
   // ❌ Tệ
   @override
   void initState() {
     Permission.camera.request(); // Người dùng chưa hiểu tại sao
   }
   ```

2. **Không ép buộc người dùng cấp quyền**
   ```dart
   // ❌ Tệ
   if (!hasPermission) {
     showDialog(
       barrierDismissible: false, // Không cho đóng
       builder: (c) => AlertDialog(
         content: Text('Bạn PHẢI cấp quyền!'),
       ),
     );
   }
   ```

3. **Không bỏ qua permanently denied case**
   ```dart
   // ❌ Tệ - Người dùng không biết phải làm gì
   if (status.isPermanentlyDenied) {
     print('Permission denied');
     return;
   }
   ```

---

## 🎯 Example Scenarios

### Scenario 1: QR Scanner Screen

```dart
class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await CameraPermissionHandler.handleCameraPermission(context);
    setState(() {
      _hasPermission = granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return CameraPermissionHandler.buildCameraPermissionEmptyState(
        context,
        onRetry: _checkPermission,
      );
    }

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }
}
```

---

### Scenario 2: Photo Picker with Camera

```dart
Future<void> _pickImage() async {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.camera_alt),
          title: Text('Chụp ảnh'),
          onTap: () async {
            Navigator.pop(context);
            
            // ✅ Check permission trước
            final hasPermission = await CameraPermissionHandler.handleCameraPermission(context);
            
            if (hasPermission) {
              final image = await ImagePicker().pickImage(source: ImageSource.camera);
              // Handle image...
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.photo_library),
          title: Text('Chọn từ thư viện'),
          onTap: () async {
            Navigator.pop(context);
            final image = await ImagePicker().pickImage(source: ImageSource.gallery);
            // Handle image...
          },
        ),
      ],
    ),
  );
}
```

---

### Scenario 3: Settings Screen

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cài đặt')),
      body: ListView(
        children: [
          FutureBuilder<PermissionStatus>(
            future: Permission.camera.status,
            builder: (context, snapshot) {
              final status = snapshot.data;
              
              return SwitchListTile(
                title: Text('Quyền Camera'),
                subtitle: Text(
                  status?.isGranted == true 
                    ? 'Đã cấp quyền' 
                    : 'Chưa cấp quyền',
                ),
                value: status?.isGranted ?? false,
                onChanged: (value) async {
                  if (value) {
                    // Request permission
                    await CameraPermissionHandler.handleCameraPermission(context);
                  } else {
                    // Mở Settings để revoke
                    openAppSettings();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 🔧 Customization

Nếu muốn customize UI, bạn có thể copy các method `_build...` trong `CameraPermissionHandler` và chỉnh sửa theo design của bạn.

### Ví dụ: Custom Colors

```dart
// Trong camera_permission_handler.dart

// Đổi màu primary
backgroundColor: yourCustomOrangeColor,
foregroundColor: yourCustomWhiteColor,

// Đổi màu icon
Icon(Icons.camera_alt, color: yourCustomColor),
```

### Ví dụ: Custom Text

```dart
// Đổi text trong rationale dialog
Text('Your custom reason text'),

// Đổi số bước trong bottom sheet
_buildStepItem(1, 'Your custom step 1'),
```

---

## 📊 Analytics (Optional)

Bạn có thể thêm analytics để track permission events:

```dart
void _getCameraEvent(GetCameraEvent event, Emitter<QRCodeState> emitter) async {
  final granted = await CameraPermissionHandler.handleCameraPermission(context);
  
  // Track event
  analytics.logEvent(
    name: 'camera_permission_result',
    parameters: {
      'granted': granted,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
  
  if (granted) {
    emitter(GrantCameraPermission());
  }
}
```

---

## 🐛 Troubleshooting

### Issue 1: Dialog không hiển thị

**Nguyên nhân:** Context không hợp lệ

**Giải pháp:**
```dart
// Đảm bảo context có Scaffold
await Future.delayed(Duration(milliseconds: 100));
await CameraPermissionHandler.handleCameraPermission(context);
```

---

### Issue 2: Bottom Sheet bị che bởi keyboard

**Nguyên nhân:** Không xử lý viewInsets

**Giải pháp:** Đã được xử lý trong code:
```dart
padding: EdgeInsets.only(
  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
),
```

---

### Issue 3: Permission status không update real-time

**Nguyên nhân:** Cần rebuild widget sau khi grant permission

**Giải pháp:**
```dart
onRetry: () {
  setState(() {}); // Trigger rebuild
  _setupCamera();
},
```

---

## 📚 References

- [permission_handler package](https://pub.dev/packages/permission_handler)
- [Material Design - Permissions](https://material.io/design/platform-guidance/android-permissions.html)
- [iOS Human Interface Guidelines - Requesting Permission](https://developer.apple.com/design/human-interface-guidelines/patterns/accessing-private-data/)

---

## 🎉 Summary

`CameraPermissionHandler` cung cấp một giải pháp hoàn chỉnh cho việc xử lý camera permission với:

✅ UX tốt nhất - Người dùng hiểu rõ và dễ dàng cấp quyền  
✅ UI đẹp - Consistent với design system  
✅ Non-invasive - Không ép buộc người dùng  
✅ Helpful - Hướng dẫn chi tiết khi cần  
✅ Easy to use - Chỉ 1 dòng code để handle toàn bộ flow  

**Happy coding! 🚀**

