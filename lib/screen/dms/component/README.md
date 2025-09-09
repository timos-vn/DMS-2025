# Customer Care Screen Optimization

## Overview
Đã tối ưu hóa màn hình `AddNewCustomerCareScreen` để cải thiện khả năng maintain, reusability và performance.

## Các thay đổi chính

### 1. **Tách thành các Widget con**
- `CustomerInfoSection`: Quản lý thông tin khách hàng
- `CareTypeSection`: Quản lý loại chăm sóc khách hàng
- `ImageAttachmentSection`: Quản lý đính kèm hình ảnh
- `CustomInputField`: Widget input tùy chỉnh
- `CustomSubmitButton`: Button submit thân thiện với người dùng

### 2. **Tạo Constants**
- `CustomerCareStrings`: Tập trung tất cả strings
- Dễ dàng thay đổi và internationalization

### 3. **Tạo Model**
- `CustomerCareFormData`: Quản lý state form
- Validation logic tập trung
- Type safety

### 4. **Tạo Services**
- `ImageService`: Xử lý hình ảnh tối ưu với percentQuantityImage
- `CustomerCareValidator`: Validation logic

### 5. **Cải thiện Code Structure**
- Giảm từ 832 dòng xuống ~400 dòng
- Tách logic business ra khỏi UI
- Sử dụng BLoC pattern hiệu quả hơn

## Cấu trúc thư mục

```
lib/screen/dms/component/
├── constants/
│   └── customer_care_strings.dart
├── models/
│   └── customer_care_form_data.dart
├── services/
│   └── image_service.dart
├── utils/
│   └── customer_care_validator.dart
├── widgets/
│   ├── care_type_section.dart
│   ├── custom_input_field.dart
│   ├── custom_submit_button.dart
│   ├── customer_info_section.dart
│   ├── image_attachment_section.dart
│   └── optimized_image_widget.dart
├── add_new_customer_care_screen.dart
└── README.md
```

## Lợi ích đạt được

### ✅ **Maintainability**
- Code dễ đọc và hiểu hơn
- Tách biệt rõ ràng các chức năng
- Dễ dàng thay đổi và debug

### ✅ **Reusability**
- Các component có thể tái sử dụng
- Widget con có thể dùng ở màn hình khác
- Services có thể dùng chung

### ✅ **Performance**
- Tối ưu image handling với percentQuantityImage
- Loại bỏ timer loading, sử dụng OptimizedImageWidget
- Giảm rebuild không cần thiết
- Lazy loading cho images

### ✅ **Type Safety**
- Sử dụng model classes
- Validation tập trung
- Error handling tốt hơn

### ✅ **Scalability**
- Dễ dàng thêm tính năng mới
- Cấu trúc modular
- Testing friendly

### ✅ **User Experience**
- Button submit thân thiện với người dùng
- Loading state rõ ràng
- Bottom button dễ tiếp cận

## Cách sử dụng

### Import components
```dart
import 'constants/customer_care_strings.dart';
import 'models/customer_care_form_data.dart';
import 'services/image_service.dart';
import 'utils/customer_care_validator.dart';
import 'widgets/care_type_section.dart';
import 'widgets/custom_input_field.dart';
import 'widgets/custom_submit_button.dart';
import 'widgets/customer_info_section.dart';
import 'widgets/image_attachment_section.dart';
```

### Sử dụng form data
```dart
late CustomerCareFormData _formData;

@override
void initState() {
  super.initState();
  _formData = CustomerCareFormData();
}

void _updateFormData() {
  _formData = _formData.copyWith(
    customerName: nameController.text,
    content: contentController.text,
    // ... other fields
  );
}
```

### Validation
```dart
if (_formData.isValid) {
  // Submit form
} else {
  final errors = _formData.validationErrors;
  // Show error message
}
```

## Image Optimization

### ✅ **Đã tối ưu:**
- **Loại bỏ Timer**: Không còn sử dụng timer để load UI
- **percentQuantityImage**: Sử dụng để set chất lượng ảnh (mặc định 65%)
- **OptimizedImageWidget**: Widget tối ưu để hiển thị ảnh với loading state
- **Error Handling**: Xử lý lỗi khi load ảnh
- **Performance**: Giảm memory usage và tăng tốc độ load

### 🔧 **Cách sử dụng:**
```dart
// Set chất lượng ảnh
_formData = _formData.copyWith(percentQuantityImage: 0.8); // 80% quality

// Chụp ảnh với chất lượng tùy chỉnh
final File? image = await ImageService.pickImage(
  isCamera: true,
  percentQuantityImage: _formData.percentQuantityImage,
);
```

## Button Optimization

### ✅ **Đã tối ưu:**
- **Thay thế FloatingActionButton**: Sử dụng BottomSubmitButton thân thiện hơn
- **Loading State**: Hiển thị loading indicator khi đang xử lý
- **User-Friendly**: Button ở bottom dễ tiếp cận và sử dụng
- **Visual Feedback**: Shadow và elevation tạo hiệu ứng đẹp mắt
- **Responsive**: Button tự động điều chỉnh theo kích thước màn hình
- **Compact Design**: Padding và chiều cao tối ưu, không chiếm quá nhiều không gian
- **Flexible Padding**: Thay SafeArea bằng padding tùy chỉnh để kiểm soát tốt hơn

### 🔧 **Cách sử dụng:**
```dart
// Sử dụng BottomSubmitButton với padding tùy chỉnh
BottomSubmitButton(
  onPressed: () => submitForm(),
  isLoading: false,
  isEnabled: true,
  text: 'Tạo phiếu CSKH',
  icon: MdiIcons.plusBoxOutline,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  buttonHeight: 50,
  bottomPadding: 8, // Padding bottom tùy chỉnh
)

// Hoặc sử dụng CustomSubmitButton
CustomSubmitButton(
  onPressed: () => submitForm(),
  isLoading: false,
  isEnabled: true,
  text: 'Tạo phiếu CSKH',
  icon: MdiIcons.plusBoxOutline,
)
```

## Next Steps

1. **Testing**: Thêm unit tests và widget tests
2. **Error Handling**: Cải thiện error handling
3. **Performance**: Thêm debounce cho input fields
4. **Accessibility**: Thêm accessibility features
5. **Internationalization**: Hỗ trợ đa ngôn ngữ

## Notes

- Các component đã được tối ưu để tái sử dụng
- Validation logic tập trung và dễ maintain
- Image handling được tối ưu cho performance
- Code structure modular và scalable
