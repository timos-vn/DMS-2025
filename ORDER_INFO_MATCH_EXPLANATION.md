# Giải thích cách Match Thông tin Khách hàng và Thông tin Bổ trợ Đơn hàng

## Tổng quan

Khi sửa đơn hàng, hệ thống cần restore tất cả thông tin từ đơn hàng cũ, bao gồm:
1. **Thông tin khách hàng** (Customer Info)
2. **Thông tin bổ trợ đơn hàng** (Order Metadata)

## 1. Thông tin Khách hàng

### Cách Match:
- **Truyền trực tiếp qua Widget parameters** từ `history_order_detail_screen` → `CartScreen`

### Các trường được truyền:
```dart
CartScreen(
  nameCustomer: widget.nameCustomer,      // ✅ Tên khách hàng
  codeCustomer: widget.codeCustomer,      // ✅ Mã khách hàng
  phoneCustomer: widget.phoneCustomer,    // ✅ Số điện thoại
  addressCustomer: widget.addressCustomer, // ✅ Địa chỉ
  ...
)
```

### Nguồn dữ liệu:
- Từ `HistoryOrderDetailScreen` widget parameters:
  - `widget.nameCustomer`
  - `widget.codeCustomer`
  - `widget.phoneCustomer`
  - `widget.addressCustomer`

### Cách restore trong CartScreen:
```dart
// Trong initState()
if(widget.codeCustomer != null && widget.codeCustomer.toString().trim().isNotEmpty){
  nameCustomerController.text = widget.nameCustomer?.toString() ?? '';
  phoneCustomerController.text = widget.phoneCustomer?.toString() ?? '';
  addressCustomerController.text = widget.addressCustomer?.toString() ?? '';
  _bloc.customerName = widget.nameCustomer;
  _bloc.codeCustomer = widget.codeCustomer;
  _bloc.addressCustomer = widget.addressCustomer;
  _bloc.phoneCustomer = widget.phoneCustomer;
}
```

### Match qua:
- **Trực tiếp từ widget parameters** → Không cần match, chỉ cần set vào bloc và controllers

---

## 2. Thông tin Bổ trợ Đơn hàng

### Cách Match:
- **Restore từ DataLocal** sau khi gọi `GetListItemUpdateOrderEvent`
- DataLocal được set trong `_handleGetDetailOrder()` từ API response

### Flow restore:

```
1. history_order_detail_screen gọi AddProductToCartEvent()
   ↓
2. AddProductToCartEvent() trigger GetListItemUpdateOrderEvent
   ↓
3. _handleGetDetailOrder() parse API response và set vào DataLocal
   ↓
4. Navigate đến CartScreen với viewUpdateOrder: true
   ↓
5. CartScreen.calculationDiscount() restore từ DataLocal
```

### Các thông tin được restore:

#### A. **Transaction (Giao dịch)**
- **Nguồn**: `masterDetailOrder.maGD`, `masterDetailOrder.tenGD` từ API
- **Set vào DataLocal**: 
  - `DataLocal.transactionCode = masterDetailOrder.maGD`
  - `DataLocal.nameTransition = masterDetailOrder.tenGD`
- **Restore trong CartScreen**:
```dart
if(Const.listTransactionsOrder.isNotEmpty && DataLocal.nameTransition.isNotEmpty){
  int indexTransaction = Const.listTransactionsOrder.indexWhere(
    (element) => element.tenGd.toString().contains(DataLocal.nameTransition)
  );
  _bloc.add(PickTransactionName(indexTransaction, DataLocal.nameTransition, DataLocal.transactionYN));
}
```
- **Match qua**: `DataLocal.nameTransition` == `transaction.tenGd` trong `Const.listTransactionsOrder`

#### B. **Store (Kho hàng)**
- **Nguồn**: `masterDetailOrder.maDL`, `masterDetailOrder.tenDL` từ API
- **Set vào DataLocal**: 
  - `DataLocal.maDL = masterDetailOrder.maDL`
  - `DataLocal.tenDL = masterDetailOrder.tenDL`
- **Restore trong CartScreen**:
```dart
_bloc.storeCode = DataLocal.maDL;
if(Const.stockList.isNotEmpty){
  for (var element in Const.stockList) {
    if(element.stockCode.toString().trim() == DataLocal.maDL.toString().trim()){
      _bloc.add(PickStoreName(Const.stockList.indexOf(element)));
      break;
    }
  }
}
```
- **Match qua**: `DataLocal.maDL` == `stock.stockCode` trong `Const.stockList`

#### C. **Tax (Thuế)**
- **Nguồn**: `lineItem[].maThue` từ API (lấy từ item đầu tiên có maThue)
- **Set vào DataLocal**: 
  - `DataLocal.codeTax = element.maThue`
- **Restore trong CartScreen**:
```dart
if(Const.useTax == true){
  if(DataLocal.listTax.isNotEmpty){
    for (var element in DataLocal.listTax) {
      if(element.maThue.toString().trim() == DataLocal.codeTax.toString().trim()){
        indexValuesTax = DataLocal.listTax.indexOf(element);
        DataLocal.indexValuesTax = indexValuesTax;
        DataLocal.taxPercent = element.thueSuat!.toDouble();
        DataLocal.taxCode = element.maThue.toString().trim();
        _bloc.add(PickTaxAfter(DataLocal.indexValuesTax, DataLocal.taxPercent));
        break;
      }
    }
  }
}
```
- **Match qua**: `DataLocal.codeTax` == `tax.maThue` trong `DataLocal.listTax`

#### D. **VV/HD (Vụ việc/Hợp đồng)**
- **Nguồn**: `lineItem[].maVV`, `lineItem[].tenVV`, `lineItem[].maHD`, `lineItem[].tenHD` từ API
- **Set vào DataLocal**: 
  - `DataLocal.maVV = element.maVV`
  - `DataLocal.tenVV = element.tenVV`
  - `DataLocal.maHD = element.maHD`
  - `DataLocal.tenHD = element.tenHD`
- **Restore trong CartScreen**:
```dart
_bloc.idVv = DataLocal.maVV;
_bloc.nameVv = (DataLocal.tenVV.isNotEmpty && DataLocal.tenVV != 'null') 
    ? DataLocal.tenVV : '';
_bloc.idHd = (DataLocal.maHD.isNotEmpty && DataLocal.maHD != 'null') 
    ? DataLocal.maHD : '';
_bloc.nameHd = DataLocal.tenHD;
```
- **Match qua**: **Trực tiếp set từ DataLocal** (không cần match với list)

#### E. **Payment Type (Loại thanh toán)**
- **Nguồn**: `masterDetailOrder.hTTT` từ API
- **Set vào DataLocal**: 
  - `DataLocal.typePayment = masterDetailOrder.hTTT` (convert: 'N' → 'Thanh toán ngay', 'S' → 'Công nợ')
  - `DataLocal.dueDatePayment = masterDetailOrder.hanTT`
- **Restore trong CartScreen**:
```dart
if(Const.chooseTypePayment == true){
  if(DataLocal.typePaymentList.isNotEmpty){
    for (var element in DataLocal.typePaymentList) {
      if(element.toString().trim() == DataLocal.typePayment.toString().trim()){
        _bloc.add(PickTypePayment(DataLocal.typePaymentList.indexOf(element), element));
        if(element.toString().contains('Công nợ')){
          _bloc.showDatePayment = true;
          if(DataLocal.dueDatePayment.toString().replaceAll('null', '').isNotEmpty){
            DataLocal.datePayment = Utils.safeFormatDate(DataLocal.dueDatePayment);
          }
        }
        break;
      }
    }
  }
}
```
- **Match qua**: `DataLocal.typePayment` == `paymentType` trong `DataLocal.typePaymentList`

#### F. **Description/Note (Ghi chú)**
- **Nguồn**: `masterDetailOrder.description` từ API
- **Set vào CartBloc**: 
  - `description = masterDetailOrder.description`
- **Truyền qua Widget**: 
  - `description: _bloc.description` trong `history_order_detail_screen`
- **Restore trong CartScreen**:
```dart
noteController.text = (widget.description.toString().isNotEmpty && 
                       widget.description.toString() != '' && 
                       widget.description.toString() != 'null') 
    ? widget.description.toString() : '';
DataLocal.noteSell = noteController.text;
```
- **Match qua**: **Trực tiếp từ widget.description** (không cần match)

#### G. **Date Order (Ngày đơn hàng)**
- **Nguồn**: `widget.dateOrder` từ `history_order_detail_screen`
- **Truyền qua Widget**: 
  - `dateOrder: widget.dateOrder` trong `history_order_detail_screen`
- **Sử dụng**: Truyền vào `CartOrderHandler` khi tạo/cập nhật đơn
- **Match qua**: **Trực tiếp từ widget.dateOrder** (không cần match)

#### H. **Currency Code (Mã tiền tệ)**
- **Nguồn**: `widget.currencyCode` từ `history_order_detail_screen`
- **Truyền qua Widget**: 
  - `currencyCode: widget.currencyCode` trong `history_order_detail_screen`
- **Sử dụng**: Truyền vào `CartOrderHandler` khi tạo/cập nhật đơn
- **Match qua**: **Trực tiếp từ widget.currencyCode** (không cần match)

#### I. **Agency (Đại lý)** - Nếu có
- **Restore trong CartScreen**:
```dart
if(Const.chooseAgency == true && _bloc.showSelectAgency == true){
  _bloc.nameAgency = '';
  _bloc.codeAgency = '';
}
```
- **Lưu ý**: Hiện tại reset về rỗng khi sửa đơn (có thể cần điều chỉnh nếu cần restore)

---

## Tóm tắt cách Match

| Thông tin | Nguồn | Cách Match | Trường Match |
|-----------|-------|------------|--------------|
| **Customer Name** | Widget parameter | Trực tiếp | `widget.nameCustomer` |
| **Customer Code** | Widget parameter | Trực tiếp | `widget.codeCustomer` |
| **Phone** | Widget parameter | Trực tiếp | `widget.phoneCustomer` |
| **Address** | Widget parameter | Trực tiếp | `widget.addressCustomer` |
| **Transaction** | DataLocal | Match index | `DataLocal.nameTransition` == `transaction.tenGd` |
| **Store** | DataLocal | Match index | `DataLocal.maDL` == `stock.stockCode` |
| **Tax** | DataLocal | Match index | `DataLocal.codeTax` == `tax.maThue` |
| **VV/HD** | DataLocal | Trực tiếp | `DataLocal.maVV`, `DataLocal.tenVV`, `DataLocal.maHD`, `DataLocal.tenHD` |
| **Payment Type** | DataLocal | Match index | `DataLocal.typePayment` == `paymentType` |
| **Due Date Payment** | DataLocal | Trực tiếp | `DataLocal.dueDatePayment` |
| **Description** | Widget parameter | Trực tiếp | `widget.description` |
| **Date Order** | Widget parameter | Trực tiếp | `widget.dateOrder` |
| **Currency Code** | Widget parameter | Trực tiếp | `widget.currencyCode` |

## Lưu ý

1. **Thông tin khách hàng**: Được truyền trực tiếp qua widget, không cần match
2. **Thông tin bổ trợ**: Được restore từ DataLocal (đã set trong `_handleGetDetailOrder`)
3. **Match bằng index**: Transaction, Store, Tax, Payment Type cần tìm index trong list tương ứng
4. **Match trực tiếp**: VV/HD, Description, Date Order, Currency Code được set trực tiếp
