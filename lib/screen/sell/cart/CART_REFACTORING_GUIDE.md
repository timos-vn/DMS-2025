# Hướng dẫn Refactoring CartScreen

## Tổng quan
File `cart_screen.dart` hiện tại có **5901 dòng code**, quá dài và khó maintain. Tài liệu này hướng dẫn cách tách thành các component nhỏ hơn.

## Cấu trúc Component đã tạo

### 1. ✅ CartAppBar (`widgets/cart_app_bar.dart`)
- **Chức năng**: AppBar với nút back, title, và search
- **Dependencies**: CartBloc, các screen navigation
- **Status**: ✅ Hoàn thành

### 2. ✅ CartBottomTotal (`widgets/cart_bottom_total.dart`)
- **Chức năng**: Bottom bar hiển thị tổng tiền và nút tiếp tục/đặt hàng
- **Dependencies**: CartBloc, TabController
- **Status**: ✅ Hoàn thành

## Các Component cần tạo tiếp

### 3. CartProductList (`widgets/cart_product_list.dart`)
**Chức năng**: 
- Hiển thị danh sách sản phẩm trong giỏ hàng
- Xử lý swipe actions (xóa, chỉnh sửa)
- Hiển thị quà tặng

**Methods cần tách**:
- `buildListProduction()` - Line 1332
- `buildListCart()` - Line 1352
- `buildListProductGiftCart()` - Cần tìm

**Dependencies**:
- CartBloc
- Slidable widget
- Product model

### 4. CartCustomerInfo (`widgets/cart_customer_info.dart`)
**Chức năng**:
- Form thông tin khách hàng
- Địa chỉ giao hàng
- Ghi chú đơn hàng

**Methods cần tách**:
- `buildInfo()` - Line 4756
- `buildMethodReceive()` - Line 4790

**Dependencies**:
- CartBloc
- TextEditingController
- Form validation

### 5. CartBillInfo (`widgets/cart_bill_info.dart`)
**Chức năng**:
- Thông tin thanh toán
- Chi tiết hóa đơn
- Các checkbox (xuất hóa đơn, đính kèm hóa đơn)

**Methods cần tách**:
- `buildBill()` - Line 4772
- `buildPaymentDetail()` - Line 5474
- `buildInfoInvoice()` - Line 5732
- `buildOtherRequest()` - Cần tìm

**Dependencies**:
- CartBloc
- Payment models

### 6. CartOrderHandler (`widgets/cart_order_handler.dart`)
**Chức năng**:
- Logic tạo đơn hàng
- Logic cập nhật đơn hàng
- Validation trước khi tạo đơn

**Methods cần tách**:
- `createOrder()` - Line 1174
- `logic()` - Line 1127
- Validation logic

**Dependencies**:
- CartBloc
- CreateOrderRequest
- UpdateOrderRequest

### 7. CartDiscountHandler (`widgets/cart_discount_handler.dart`)
**Chức năng**:
- Xử lý các loại chiết khấu (CKG, CKN, HH, CKTDTT, CKTDTH)
- Apply/Remove discounts
- Recalculate totals

**Methods cần tách**:
- `_showDiscountFlow()` - Line ~1950
- `_handleCKGSelection()` - Cần tìm
- `_handleCKNSelection()` - Cần tìm
- `_applyAllHH()` - Cần tìm
- `_reloadDiscountsFromBackend()` - Cần tìm

**Dependencies**:
- CartBloc
- Discount models
- API calls

## Cách sử dụng Component mới

### Ví dụ: Sử dụng CartAppBar

```dart
// Trong cart_screen.dart
import 'widgets/cart_app_bar.dart';

// Thay thế buildAppBar() bằng:
CartAppBar(
  bloc: _bloc,
  viewUpdateOrder: widget.viewUpdateOrder,
  nameCustomer: widget.nameCustomer,
  isContractCreateOrder: widget.isContractCreateOrder,
  contractMaster: widget.contractMaster,
  viewDetail: widget.viewDetail,
  orderFromCheckIn: widget.orderFromCheckIn,
  codeCustomer: widget.codeCustomer,
  currencyCode: widget.currencyCode,
  listIdGroupProduct: widget.listIdGroupProduct,
  itemGroupCode: widget.itemGroupCode,
  onBackPressed: () => Navigator.of(context).pop(widget.currencyCode),
)
```

### Ví dụ: Sử dụng CartBottomTotal

```dart
// Trong buildScreen()
CartBottomTotal(
  bloc: _bloc,
  tabController: tabController,
  onNextPressed: () {
    // Logic chuyển tab
  },
  onCreateOrderPressed: () {
    logic();
  },
  isProcessing: _isProcessing,
)
```

## Lợi ích của Refactoring

1. **Dễ maintain**: Mỗi component có trách nhiệm rõ ràng
2. **Dễ test**: Có thể test từng component độc lập
3. **Tái sử dụng**: Có thể dùng lại component ở màn hình khác
4. **Dễ đọc**: Code ngắn gọn, dễ hiểu hơn
5. **Performance**: Có thể optimize từng component riêng

## Lưu ý khi Refactoring

1. **Giữ nguyên logic**: Không thay đổi business logic
2. **Test kỹ**: Test từng component sau khi tách
3. **Dependencies**: Đảm bảo import đúng các dependencies
4. **State management**: Truyền đúng CartBloc và callbacks
5. **Backward compatibility**: Đảm bảo không break existing code

## Next Steps

1. ✅ Tạo CartAppBar
2. ✅ Tạo CartBottomTotal
3. ⏳ Tạo CartProductList
4. ⏳ Tạo CartCustomerInfo
5. ⏳ Tạo CartBillInfo
6. ⏳ Tạo CartOrderHandler
7. ⏳ Tạo CartDiscountHandler
8. ⏳ Refactor cart_screen.dart để sử dụng các component mới
9. ⏳ Test toàn bộ flow
10. ⏳ Clean up code cũ

## Tips

- Tách từng component một, test kỹ trước khi tiếp tục
- Sử dụng `callback` functions để truyền logic từ parent
- Giữ nguyên các biến state trong CartScreen, chỉ tách UI
- Document rõ ràng các props và callbacks của mỗi component

