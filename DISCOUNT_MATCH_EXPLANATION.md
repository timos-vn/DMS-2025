# Giải thích cách Match Chiết khấu từ Đơn hàng Cũ

## Tổng quan

Khi sửa đơn hàng có chiết khấu, hệ thống cần restore các chiết khấu đã chọn để match với danh sách chiết khấu khi mở icon hộp quà.

## Các trường dùng để Match

### 1. **CKG (Chiết khấu hàng)**
- **Nguồn dữ liệu từ đơn cũ**: `product.maCk` trong `_bloc.listOrder`
  - Được set từ `lineItem` → `listDiscount[0].maCk` khi `kieuCk == 'CKG'`
- **Match với**: `ckgItem.maCk` trong `_bloc.listCkg`
- **Trường match**: `maCk` (mã chiết khấu)

### 2. **HH (Hàng hóa tặng)**
- **Nguồn dữ liệu từ đơn cũ**: `DataLocal.listProductGift` với `typeCK == 'HH'`
  - Được thêm từ `listDiscountProduct` khi gọi `CheckDisCountWhenUpdateEvent`
- **Match với**: `hhItem.sttRecCk` hoặc `hhItem.maVt` trong `_bloc.listHH`
- **Trường match**: 
  - `gift.sttRec0` (sttRecCk của chiết khấu) == `hhItem.sttRecCk`
  - HOẶC `gift.code` (mã sản phẩm tặng) == `hhItem.maVt`
- **ID format**: `'${hhItem.sttRecCk}_${hhItem.tenVt}'`

### 3. **CKTDTT (Chiết khấu tổng đơn tặng tiền)**
- **Nguồn dữ liệu từ đơn cũ**: 
  - `_bloc.sttRecCKOld` (từ `listDiscount[0].sttRecCk` khi `kieuCk == 'CKTDTT'`)
  - `_bloc.codeDiscountTD` (từ `listDiscount[0].maCk` khi `kieuCk == 'CKTDTT'`)
- **Match với**: `cktdttItem.sttRecCk` hoặc `cktdttItem.maCk` trong `_bloc.listCktdtt`
- **Trường match**: 
  - `sttRecCKOld` == `cktdttItem.sttRecCk`
  - HOẶC `codeDiscountTD` == `cktdttItem.maCk`

### 4. **CKN (Chiết khấu nhóm)**
- **Nguồn dữ liệu từ đơn cũ**: `DataLocal.listProductGift` với `typeCK == 'CKN'`
  - Được thêm từ `listDiscountProduct` khi `kieuCk == 'CKN'`
- **Match với**: `cknItem.group_dk` hoặc `cknItem.sttRecCk` trong `_bloc.listCkn`
- **Trường match**: 
  - `gift.sttRecCK` (sttRecCk của chiết khấu) == `cknItem.sttRecCk` hoặc `cknItem.group_dk`
  - HOẶC `gift.code` (mã sản phẩm tặng) == `cknItem.maHangTang` → lấy `group_dk` hoặc `sttRecCk`
- **GroupKey format**: `group_dk` hoặc `sttRecCk`

### 5. **CKTDTH (Chiết khấu tổng đơn tặng hàng)**
- **Nguồn dữ liệu từ đơn cũ**: `DataLocal.listProductGift` với `typeCK == 'CKTDTH'`
  - Được thêm từ `listDiscountProduct` khi `kieuCk == 'CKTDTH'`
- **Match với**: `cktdthItem.group_dk` hoặc `cktdthItem.sttRecCk` trong `_bloc.listCktdth`
- **Trường match**: Tương tự CKN

## Flow dữ liệu

```
1. Load đơn hàng cũ (GetListItemUpdateOrderEvent)
   ↓
2. Parse lineItem từ API response
   ↓
3. Gọi CheckDisCountWhenUpdateEvent
   ↓
4. API trả về listDiscount và listDiscountProduct
   ↓
5. Set maCk vào listOrder products (CKG)
   ↓
6. Set sttRecCKOld, codeDiscountTD (CKTDTT)
   ↓
7. Thêm gifts vào DataLocal.listProductGift (HH, CKN, CKTDTH)
   ↓
8. Khi mở discount sheet (_showDiscountFlow)
   ↓
9. Restore selections bằng cách match các trường trên
```

## Lưu ý

- **CKG**: Match trực tiếp qua `maCk` trong sản phẩm
- **HH**: Match qua `sttRec0` hoặc `code` trong gifts
- **CKTDTT**: Match qua `sttRecCKOld` hoặc `codeDiscountTD` trong CartBloc
- **CKN/CKTDTH**: Match qua `sttRecCK` trong gifts, hoặc tìm trong list bằng `code` == `maHangTang`
