# Hướng dẫn sử dụng các Component đã tạo

## Tổng quan

Đã tách thành công file `cart_screen.dart` (5901 dòng) thành các component nhỏ hơn, dễ maintain:

### ✅ Các Component đã tạo:

1. **CartAppBar** - AppBar với navigation
2. **CartBottomTotal** - Bottom bar với tổng tiền và nút action
3. **CartProductList** - Danh sách sản phẩm và quà tặng
4. **CartCustomerInfo** - Form thông tin khách hàng
5. **CartBillInfo** - Thông tin thanh toán và hóa đơn
6. **CartOrderHandler** - Logic tạo/cập nhật đơn hàng

## Cách sử dụng trong cart_screen.dart

### 1. Import các component

```dart
import 'widgets/cart_app_bar.dart';
import 'widgets/cart_bottom_total.dart';
import 'widgets/cart_product_list.dart';
import 'widgets/cart_customer_info.dart';
import 'widgets/cart_bill_info.dart';
import 'widgets/cart_order_handler.dart';
```

### 2. Sử dụng CartAppBar

Thay thế `buildAppBar()`:

```dart
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

### 3. Sử dụng CartBottomTotal

Thay thế bottom bar trong `buildScreen()`:

```dart
CartBottomTotal(
  bloc: _bloc,
  tabController: tabController,
  onNextPressed: () {
    // Logic chuyển tab
    if (tabController.index == 0 || tabController.index == 1) {
      tabController.animateTo((tabController.index + 1) % 10);
    }
  },
  onCreateOrderPressed: () {
    // Logic tạo đơn
    final handler = CartOrderHandler(
      context: context,
      bloc: _bloc,
      viewUpdateOrder: widget.viewUpdateOrder,
      sttRec: widget.sttRec,
      currencyCode: widget.currencyCode,
      dateOrder: widget.dateOrder,
      isContractCreateOrder: widget.isContractCreateOrder,
      sttRectHD: widget.sttRectHD,
      nameCompanyController: nameCompanyController,
      mstController: mstController,
      addressCompanyController: addressCompanyController,
      noteCompanyController: noteCompanyController,
      noteController: noteController,
    );
    handler.createOrder();
  },
  isProcessing: _isProcessing,
)
```

### 4. Sử dụng CartProductList

Thay thế `buildListProduction()`:

```dart
CartProductList(
  bloc: _bloc,
  onShowDiscountFlow: () => _showDiscountFlow(),
  onAddAllHDVV: () {
    // Logic thêm VV/HD cho tất cả
  },
  onAddDiscountForAll: () {
    // Logic thêm discount cho tất cả
  },
  onDeleteAll: () {
    // Logic xóa tất cả
  },
  onEditProduct: (index) {
    // Logic sửa sản phẩm
  },
  onDeleteProduct: (index) {
    // Logic xóa sản phẩm
  },
  onApplyVVHD: (index) {
    // Logic áp dụng VV/HD
  },
  onApplyManualDiscount: (index, value) {
    // Logic áp dụng discount thủ công
  },
  buildProductItem: (context, index) {
    // Build product item widget
    return buildProductItemWidget(index);
  },
  buildGiftItem: (context, index) {
    // Build gift item widget
    return buildGiftItemWidget(index);
  },
)
```

### 5. Sử dụng CartCustomerInfo

Thay thế `buildInfo()`:

```dart
CartCustomerInfo(
  bloc: _bloc,
  buildInfoCallOtherPeople: () => buildInfoCallOtherPeople(),
  transactionWidget: () => transactionWidget(),
  typeOrderWidget: () => typeOrderWidget(),
  genderWidget: () => genderWidget(),
  genderTaxWidget: () => genderTaxWidget(),
  typePaymentWidget: () => typePaymentWidget(),
  typeDeliveryWidget: () => typeDeliveryWidget(),
  buildPopupVvHd: () => buildPopupVvHd(),
  maGD: maGD,
  onStateChanged: () => setState(() {}),
)
```

### 6. Sử dụng CartBillInfo

Thay thế `buildBill()`:

```dart
CartBillInfo(
  bloc: _bloc,
  listItem: listItem,
  listQty: listQty,
  listPrice: listPrice,
  listMoney: listMoney,
  codeStore: codeStore,
  onVoucherTap: () {
    // Logic xử lý voucher (đã được xử lý trong component)
  },
  buildOtherRequest: () => buildOtherRequest(),
  customWidgetPayment: (title, subtitle, discount, codeDiscount) {
    return customWidgetPayment(title, subtitle, discount, codeDiscount);
  },
)
```

### 7. Sử dụng CartOrderHandler

Thay thế `createOrder()`:

```dart
final handler = CartOrderHandler(
  context: context,
  bloc: _bloc,
  viewUpdateOrder: widget.viewUpdateOrder,
  sttRec: widget.sttRec,
  currencyCode: widget.currencyCode,
  dateOrder: widget.dateOrder,
  isContractCreateOrder: widget.isContractCreateOrder,
  sttRectHD: widget.sttRectHD,
  nameCompanyController: nameCompanyController,
  mstController: mstController,
  addressCompanyController: addressCompanyController,
  noteCompanyController: noteCompanyController,
  noteController: noteController,
);

handler.createOrder();
```

## Lợi ích

1. **Code ngắn gọn hơn**: File `cart_screen.dart` sẽ giảm từ 5901 dòng xuống còn khoảng 2000-3000 dòng
2. **Dễ maintain**: Mỗi component có trách nhiệm rõ ràng
3. **Dễ test**: Có thể test từng component độc lập
4. **Tái sử dụng**: Có thể dùng lại ở màn hình khác
5. **Dễ đọc**: Code logic rõ ràng hơn

## Lưu ý

- Các component sử dụng **callbacks** để xử lý logic phức tạp
- Một số widget builder functions vẫn cần được truyền từ parent
- Đảm bảo truyền đúng tất cả các dependencies cần thiết
- Test kỹ từng component sau khi refactor

## Next Steps

1. Refactor `cart_screen.dart` để sử dụng các component mới
2. Test toàn bộ flow
3. Clean up code cũ
4. Tạo CartDiscountHandler nếu cần (optional)

