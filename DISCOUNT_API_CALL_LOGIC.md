# Logic Gọi API Khi Nhấn "Áp dụng" Chiết khấu

## 📍 Vị trí: Bottom Sheet "Voucher & Ưu đãi" → Nút "Áp dụng"

## 🔍 Hàm xử lý: `_handleApplyAllDiscounts()`

### ✅ Các trường hợp KHÔNG gọi API:

#### 1. **Mode Edit (`viewUpdateOrder == true`)**
```dart
if (widget.viewUpdateOrder == true) {
  // ❌ KHÔNG gọi API
  // Chỉ update local state
}
```
**Lý do**: Khi sửa đơn, chỉ cần update local state, không cần backend tính lại chiết khấu.

#### 2. **Không có thay đổi (CKG, CKTDTT, HH đều rỗng)**
```dart
bool hasChanges = selectedCkgIds.isNotEmpty || 
                  selectedCktdttIds.isNotEmpty || 
                  selectedHHIds.isNotEmpty;

if (!hasChanges) {
  // ❌ KHÔNG gọi API
  // Không có chiết khấu nào được chọn
}
```
**Lý do**: Không có chiết khấu nào cần sync với backend.

#### 3. **Chỉ chọn CKN hoặc CKTDTH (không có CKG, CKTDTT, HH)**
```dart
// ⚠️ LƯU Ý: CKN và CKTDTH KHÔNG được tính vào hasChanges
// Nếu chỉ chọn CKN hoặc CKTDTH → hasChanges = false → KHÔNG gọi API
```
**Lý do**: CKN và CKTDTH là gift products, không cần backend tính lại chiết khấu.

---

### ✅ Các trường hợp GỌI API:

#### 1. **Mode Create + Có CKG được chọn**
```dart
if (hasChanges && (widget.viewUpdateOrder != true)) {
  // ✅ GỌI API
  _reloadDiscountsFromBackend();
}
```
**Lý do**: Cần backend tính lại giá sau chiết khấu cho CKG.

#### 2. **Mode Create + Có CKTDTT được chọn**
```dart
if (hasChanges && (widget.viewUpdateOrder != true)) {
  // ✅ GỌI API
  _reloadDiscountsFromBackend();
}
```
**Lý do**: Cần backend tính lại `totalDiscountForOder`.

#### 3. **Mode Create + Có HH được chọn**
```dart
if (hasChanges && (widget.viewUpdateOrder != true)) {
  // ✅ GỌI API
  _reloadDiscountsFromBackend();
}
```
**Lý do**: HH có thể ảnh hưởng đến chiết khấu khác, cần backend sync.

---

## 📊 Bảng Tóm Tắt

| Trường hợp | CKG | CKTDTT | HH | CKN | CKTDTH | Mode | Gọi API? |
|------------|-----|--------|----|----|--------|------|----------|
| 1 | ✅ | ❌ | ❌ | ❌ | ❌ | Create | ✅ YES |
| 2 | ❌ | ✅ | ❌ | ❌ | ❌ | Create | ✅ YES |
| 3 | ❌ | ❌ | ✅ | ❌ | ❌ | Create | ✅ YES |
| 4 | ✅ | ✅ | ✅ | ❌ | ❌ | Create | ✅ YES |
| 5 | ✅ | ❌ | ❌ | ❌ | ❌ | **Edit** | ❌ **NO** |
| 6 | ❌ | ✅ | ❌ | ❌ | ❌ | **Edit** | ❌ **NO** |
| 7 | ❌ | ❌ | ✅ | ❌ | ❌ | **Edit** | ❌ **NO** |
| 8 | ❌ | ❌ | ❌ | ✅ | ❌ | Create | ❌ NO |
| 9 | ❌ | ❌ | ❌ | ❌ | ✅ | Create | ❌ NO |
| 10 | ❌ | ❌ | ❌ | ❌ | ❌ | Create | ❌ NO |

---

## 🔑 Điều Kiện Gọi API

```dart
bool hasChanges = selectedCkgIds.isNotEmpty || 
                  selectedCktdttIds.isNotEmpty || 
                  selectedHHIds.isNotEmpty;

if (hasChanges && (widget.viewUpdateOrder != true)) {
  // ✅ GỌI API
  _reloadDiscountsFromBackend();
} else if (widget.viewUpdateOrder == true) {
  // ❌ KHÔNG GỌI API - Edit mode
} else {
  // ❌ KHÔNG GỌI API - No changes
}
```

---

## ⚠️ Lưu Ý

1. **CKN và CKTDTH không được tính vào `hasChanges`**:
   - Nếu chỉ chọn CKN hoặc CKTDTH → `hasChanges = false` → Không gọi API
   - Điều này là **ĐÚNG** vì CKN/CKTDTH chỉ thêm gift products, không cần backend tính lại

2. **Edit Mode luôn skip API**:
   - Dù có chọn CKG, CKTDTT, HH → Vẫn không gọi API
   - Chỉ update local state

3. **Double check trong `_reloadDiscountsFromBackend()`**:
   - Hàm này cũng có check `if (widget.viewUpdateOrder == true) return;`
   - Đảm bảo không gọi API dù có gọi nhầm từ nơi khác
