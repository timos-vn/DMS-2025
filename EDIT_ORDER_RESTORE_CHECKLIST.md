# Checklist: Kiểm tra các thông tin được restore khi sửa đơn (viewUpdateOrder = true)

## ✅ Đã được restore

### 1. Thông tin Khách hàng
- ✅ `nameCustomer` - Từ widget parameter
- ✅ `codeCustomer` - Từ widget parameter  
- ✅ `phoneCustomer` - Từ widget parameter
- ✅ `addressCustomer` - Từ widget parameter

### 2. Thông tin Bổ trợ Đơn hàng
- ✅ `Transaction` (maGD, tenGD) - Từ DataLocal.nameTransition, DataLocal.transactionCode
- ✅ `Store` (maDL, tenDL) - Từ DataLocal.maDL, DataLocal.tenDL
- ✅ `Tax` (maThue, taxPercent) - Từ DataLocal.codeTax
- ✅ `VV/HD` (maVV, tenVV, maHD, tenHD) - Từ DataLocal.maVV, DataLocal.tenVV, DataLocal.maHD, DataLocal.tenHD
- ✅ `Payment Type` (hTTT) - Từ DataLocal.typePayment
- ✅ `Due Date Payment` (hanTT) - Từ DataLocal.dueDatePayment
- ✅ `Description/Note` - Từ widget.description
- ✅ `Date Order` - Từ widget.dateOrder
- ✅ `Currency Code` - Từ widget.currencyCode
- ✅ `Date Est Delivery` - Từ widget.dateEstDelivery → DataLocal.dateEstDelivery

### 3. Danh sách Sản phẩm
- ✅ `listOrder` - Từ widget.listOrder (được load từ database qua AddProductToCartEvent)

### 4. Danh sách Hàng tặng
- ✅ `DataLocal.listProductGift` - Được preserve và restore từ lineItem và CheckDisCountWhenUpdateEvent

### 5. Chiết khấu (Discount Selections)
- ✅ `CKG` - Restore từ maCk trong listOrder
- ✅ `HH` - Restore từ DataLocal.listProductGift với typeCK == 'HH'
- ✅ `CKTDTT` - Restore từ sttRecCKOld/codeDiscountTD
- ✅ `CKN` - Restore từ DataLocal.listProductGift với typeCK == 'CKN'
- ✅ `CKTDTH` - Restore từ DataLocal.listProductGift với typeCK == 'CKTDTH'

---

## ❓ Cần kiểm tra/Thiếu

### 1. Company Information (Thông tin Công ty)
- ❓ `nameCompany` - **KHÔNG THẤY** được restore trong CartScreen
- ❓ `mstCompany` - **KHÔNG THẤY** được restore trong CartScreen
- ❓ `addressCompany` - **KHÔNG THẤY** được restore trong CartScreen
- ❓ `noteCompany` - **KHÔNG THẤY** được restore trong CartScreen

**Vấn đề**: 
- API response `HistoryOrderDetailResponse` **KHÔNG CÓ** các trường này trong `Master` hoặc `LineItems`
- Các trường này có trong `UpdateOrderRequest` và `CreateOrderRequest` nhưng không có trong response
- Cần kiểm tra xem API có trả về không, hoặc có được lưu ở đâu khác không

### 2. Delivery Method (Phương thức giao hàng)
- ❓ `typeDelivery` - **KHÔNG THẤY** được restore trong CartScreen
- ❓ `typeDeliveryIndex` - **KHÔNG THẤY** được restore
- ❓ `typeDeliveryName` - **KHÔNG THẤY** được restore
- ❓ `typeDeliveryCode` - **KHÔNG THẤY** được restore

**Vấn đề**:
- API response **KHÔNG CÓ** trường `typeDelivery` trong `Master`
- Có trong `UpdateOrderRequest` nhưng không có trong response
- Cần kiểm tra xem có cần restore không

### 3. Agency Information (Thông tin Đại lý)
- ⚠️ `codeAgency` - **ĐANG RESET** về rỗng khi sửa đơn
- ⚠️ `nameAgency` - **ĐANG RESET** về rỗng khi sửa đơn
- ⚠️ `discountPercentAgency` - **KHÔNG THẤY** được restore

**Vấn đề**:
- Hiện tại code reset về rỗng: `_bloc.nameAgency = ''; _bloc.codeAgency = '';`
- Cần kiểm tra xem API có trả về không, hoặc có cần restore không

### 4. Other Metadata
- ❓ `idTypeOrder` - **KHÔNG THẤY** được restore
- ❓ `orderStatus` - **KHÔNG THẤY** được restore (có trong Master.status nhưng không restore)
- ❓ `saleCode` - **KHÔNG THẤY** được restore

---

## 📋 Tóm tắt

### Đã restore đầy đủ:
1. ✅ Customer Info (name, code, phone, address)
2. ✅ Transaction, Store, Tax, VV/HD, Payment Type
3. ✅ Description, Date Order, Currency Code, Date Est Delivery
4. ✅ Products và Gifts
5. ✅ Discount Selections (CKG, HH, CKTDTT, CKN, CKTDTH)

### Cần kiểm tra/Bổ sung:
1. ❓ Company Info (nameCompany, mstCompany, addressCompany, noteCompany)
2. ❓ Delivery Method (typeDelivery)
3. ⚠️ Agency Info (codeAgency, nameAgency, discountPercentAgency)
4. ❓ Other Metadata (idTypeOrder, orderStatus, saleCode)

---

## 🔍 Cần làm

1. **Kiểm tra API response**: Xem API `getItemDetailOrder` có trả về company info, typeDelivery, agency info không
2. **Nếu có**: Cần thêm logic restore trong `_handleGetDetailOrder` và `CartScreen.calculationDiscount()`
3. **Nếu không có**: Cần xác nhận với backend hoặc lưu ý rằng các thông tin này không được restore
