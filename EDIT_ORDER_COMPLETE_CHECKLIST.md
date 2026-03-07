# ✅ Checklist Đầy Đủ: Các thông tin được restore khi sửa đơn (viewUpdateOrder = true)

## 📊 Tổng quan

API Response `HistoryOrderDetailResponse` có cấu trúc:
- `Master`: Thông tin chính đơn hàng
- `LineItems`: Danh sách sản phẩm
- `InfoPayment`: Thông tin thanh toán (tTien, tCkTtNt, tTtNt, tThueNt)

---

## ✅ ĐÃ ĐƯỢC RESTORE ĐẦY ĐỦ

### 1. ✅ Thông tin Khách hàng
| Trường | Nguồn | Cách restore | Status |
|--------|-------|--------------|--------|
| `nameCustomer` | Widget parameter | Trực tiếp từ `widget.nameCustomer` | ✅ |
| `codeCustomer` | Widget parameter | Trực tiếp từ `widget.codeCustomer` | ✅ |
| `phoneCustomer` | Widget parameter | Trực tiếp từ `widget.phoneCustomer` | ✅ |
| `addressCustomer` | Widget parameter | Trực tiếp từ `widget.addressCustomer` | ✅ |

### 2. ✅ Thông tin Bổ trợ Đơn hàng
| Trường | Nguồn API | Set vào DataLocal | Restore trong CartScreen | Status |
|--------|-----------|-------------------|-------------------------|--------|
| **Transaction** | `master.maGD`, `master.tenGD` | `DataLocal.transactionCode`, `DataLocal.nameTransition` | Match index trong `Const.listTransactionsOrder` | ✅ |
| **Store** | `master.maDL`, `master.tenDL` | `DataLocal.maDL`, `DataLocal.tenDL` | Match index trong `Const.stockList` | ✅ |
| **Tax** | `lineItem[].maThue` | `DataLocal.codeTax` | Match index trong `DataLocal.listTax` | ✅ |
| **VV/HD** | `lineItem[].maVV`, `lineItem[].tenVV`, `lineItem[].maHD`, `lineItem[].tenHD` | `DataLocal.maVV`, `DataLocal.tenVV`, `DataLocal.maHD`, `DataLocal.tenHD` | Set trực tiếp vào `_bloc.idVv`, `_bloc.nameVv`, `_bloc.idHd`, `_bloc.nameHd` | ✅ |
| **Payment Type** | `master.hTTT` | `DataLocal.typePayment` (convert: 'N'→'Thanh toán ngay', 'S'→'Công nợ') | Match index trong `DataLocal.typePaymentList` | ✅ |
| **Due Date Payment** | `master.hanTT` | `DataLocal.dueDatePayment` | Set vào `DataLocal.datePayment` khi Payment = 'Công nợ' | ✅ |
| **Description** | `master.description` | `_bloc.description` | Truyền qua `widget.description` → `noteController.text` | ✅ |
| **Date Order** | - | - | Truyền qua `widget.dateOrder` | ✅ |
| **Currency Code** | - | - | Truyền qua `widget.currencyCode` | ✅ |
| **Date Est Delivery** | - | - | Truyền qua `widget.dateEstDelivery` → `DataLocal.dateEstDelivery` | ✅ |

### 3. ✅ Danh sách Sản phẩm
| Trường | Nguồn | Cách restore | Status |
|--------|-------|--------------|--------|
| `listOrder` | `lineItem` → `AddProductToCartEvent` → Database | Load từ database qua `GetListProductFromDB` | ✅ |
| `maCk` trong products | `lineItem[].maCk` | Set vào `product.maCk` trong `listOrder` | ✅ |

### 4. ✅ Danh sách Hàng tặng
| Trường | Nguồn | Cách restore | Status |
|--------|-------|--------------|--------|
| `DataLocal.listProductGift` | `lineItem[]` với `kmYn = 1` | Preserve và restore từ `_handleGetDetailOrder` và `CheckDisCountWhenUpdateEvent` | ✅ |

### 5. ✅ Chiết khấu (Discount Selections)
| Loại | Trường match | Nguồn | Restore trong `_showDiscountFlow()` | Status |
|------|--------------|-------|-------------------------------------|--------|
| **CKG** | `maCk` | `product.maCk` trong `listOrder` | Match với `ckgItem.maCk` trong `listCkg` | ✅ |
| **HH** | `sttRec0` hoặc `code` | `DataLocal.listProductGift` với `typeCK == 'HH'` | Match với `hhItem.sttRecCk` hoặc `hhItem.maVt` | ✅ |
| **CKTDTT** | `sttRecCKOld` hoặc `codeDiscountTD` | `_bloc.sttRecCKOld`, `_bloc.codeDiscountTD` | Match với `cktdttItem.sttRecCk` hoặc `cktdttItem.maCk` | ✅ |
| **CKN** | `sttRecCK` hoặc `code` → `group_dk` | `DataLocal.listProductGift` với `typeCK == 'CKN'` | Extract `groupKey` từ `gift.sttRecCK` hoặc tìm trong `listCkn` | ✅ |
| **CKTDTH** | `sttRecCK` hoặc `code` → `group_dk` | `DataLocal.listProductGift` với `typeCK == 'CKTDTH'` | Extract `groupKey` từ `gift.sttRecCK` hoặc tìm trong `listCktdth` | ✅ |

---

## ❌ KHÔNG CÓ TRONG API RESPONSE (Không thể restore)

### 1. ❌ Company Information
| Trường | Có trong Request? | Có trong Response? | Status |
|--------|-------------------|---------------------|--------|
| `nameCompany` | ✅ (UpdateOrderRequest, CreateOrderRequest) | ❌ **KHÔNG CÓ** trong `HistoryOrderDetailResponse` | ❌ |
| `mstCompany` | ✅ (UpdateOrderRequest, CreateOrderRequest) | ❌ **KHÔNG CÓ** trong `HistoryOrderDetailResponse` | ❌ |
| `addressCompany` | ✅ (UpdateOrderRequest, CreateOrderRequest) | ❌ **KHÔNG CÓ** trong `HistoryOrderDetailResponse` | ❌ |
| `noteCompany` | ✅ (UpdateOrderRequest, CreateOrderRequest) | ❌ **KHÔNG CÓ** trong `HistoryOrderDetailResponse` | ❌ |

**Kết luận**: API **KHÔNG TRẢ VỀ** company info, nên **KHÔNG THỂ restore** từ đơn hàng cũ. Các trường này sẽ để trống khi sửa đơn.

### 2. ❌ Delivery Method
| Trường | Có trong Request? | Có trong Response? | Status |
|--------|-------------------|---------------------|--------|
| `typeDelivery` | ✅ (UpdateOrderRequest, CreateOrderRequest) | ❌ **KHÔNG CÓ** trong `HistoryOrderDetailResponse` | ❌ |
| `typeDeliveryIndex` | - | ❌ **KHÔNG CÓ** | ❌ |
| `typeDeliveryName` | - | ❌ **KHÔNG CÓ** | ❌ |
| `typeDeliveryCode` | - | ❌ **KHÔNG CÓ** | ❌ |

**Kết luận**: API **KHÔNG TRẢ VỀ** typeDelivery, nên **KHÔNG THỂ restore** từ đơn hàng cũ.

### 3. ❌ Agency Information
| Trường | Có trong Request? | Có trong Response? | Status |
|--------|-------------------|---------------------|--------|
| `codeAgency` | ✅ (UpdateOrderRequest, CreateOrderRequest) | ❌ **KHÔNG CÓ** trong `HistoryOrderDetailResponse` | ❌ |
| `nameAgency` | - | ❌ **KHÔNG CÓ** | ❌ |
| `discountPercentAgency` | ✅ (UpdateOrderRequest, CreateOrderRequest) | ❌ **KHÔNG CÓ** | ❌ |

**Kết luận**: API **KHÔNG TRẢ VỀ** agency info. Code hiện tại **RESET về rỗng** khi sửa đơn (đúng vì không có dữ liệu để restore).

### 4. ❌ Other Metadata
| Trường | Có trong Request? | Có trong Response? | Status |
|--------|-------------------|---------------------|--------|
| `idTypeOrder` | ✅ (UpdateOrderRequest, CreateOrderRequest) | ❌ **KHÔNG CÓ** trong `HistoryOrderDetailResponse` | ❌ |
| `orderStatus` | ✅ (UpdateOrderRequest) | ⚠️ Có `master.status` nhưng **KHÔNG restore** | ⚠️ |
| `saleCode` | ✅ (UpdateOrderRequest, CreateOrderRequest) | ❌ **KHÔNG CÓ** | ❌ |

**Kết luận**: 
- `idTypeOrder`, `saleCode`: **KHÔNG CÓ** trong response
- `orderStatus`: Có trong `master.status` nhưng **KHÔNG được restore** (có thể không cần vì là status hiện tại)

---

## 📋 TÓM TẮT

### ✅ Đã restore đầy đủ (100%):
1. ✅ **Customer Info** (name, code, phone, address)
2. ✅ **Transaction, Store, Tax, VV/HD, Payment Type**
3. ✅ **Description, Date Order, Currency Code, Date Est Delivery**
4. ✅ **Products và Gifts**
5. ✅ **Discount Selections** (CKG, HH, CKTDTT, CKN, CKTDTH)

### ❌ Không thể restore (API không trả về):
1. ❌ **Company Info** (nameCompany, mstCompany, addressCompany, noteCompany)
2. ❌ **Delivery Method** (typeDelivery)
3. ❌ **Agency Info** (codeAgency, nameAgency, discountPercentAgency)
4. ❌ **Other Metadata** (idTypeOrder, saleCode)

### ⚠️ Có trong API nhưng không restore:
1. ⚠️ **orderStatus** (`master.status`) - Có thể không cần vì là status hiện tại

---

## 🎯 KẾT LUẬN

**Tất cả thông tin có trong API response đã được restore đầy đủ.**

Các thông tin **KHÔNG CÓ** trong API response (company info, typeDelivery, agency info) sẽ:
- **Company Info**: Để trống, user cần nhập lại nếu cần
- **Delivery Method**: Để mặc định hoặc user chọn lại
- **Agency Info**: Reset về rỗng (đúng với code hiện tại)

**Không có vấn đề gì cần fix** - code đã xử lý đúng với dữ liệu có sẵn từ API.
