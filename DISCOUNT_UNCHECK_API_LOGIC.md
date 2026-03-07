# Logic Gọi API Khi Bỏ Tích Chiết Khấu

## 📍 Vị trí: Bottom Sheet "Voucher & Ưu đãi" → User bỏ tích checkbox

## 🔍 Flow Khi Bỏ Tích

### 1. **CKG (Chiết khấu giá)**
```
User bỏ tích CKG checkbox
  ↓
onRemoveCkg callback
  ↓
_handleRemoveCKG(maCk, ckgItem)
  ↓
_applyCKGByMaCk(maCk, shouldApply: false)
  ↓
_applySingleCKG(ckgId, ckgItem, shouldApply: false)
  ↓
Update local state (remove from listCKVT, reset discount fields)
  ↓
setState() → UI update
  ↓
❌ KHÔNG GỌI API
```

### 2. **CKTDTT (Chiết khấu tổng đơn tặng tiền)**
```
User bỏ tích CKTDTT checkbox
  ↓
onRemoveCktdtt callback
  ↓
_handleRemoveCKTDTTS(cktdttId, cktdttItem)
  ↓
_applySingleCKTDTT(cktdttId, cktdttItem, shouldApply: false)
  ↓
Update local state (remove from listPromotion, recalculate totalDiscountForOder)
  ↓
setState() → UI update
  ↓
❌ KHÔNG GỌI API
```

### 3. **HH (Hàng tặng)**
```
User bỏ tích HH checkbox
  ↓
onRemoveHH callback (nếu có)
  ↓
Update local state (remove from DataLocal.listProductGift)
  ↓
setState() → UI update
  ↓
❌ KHÔNG GỌI API (trong cart_screen)
```

### 4. **CKN (Chiết khấu nhóm)**
```
User bỏ tích CKN checkbox
  ↓
onRemoveCknGroup callback
  ↓
_handleRemoveCKN(groupKey)
  ↓
Remove gifts from DataLocal.listProductGift
  ↓
setState() → UI update
  ↓
❌ KHÔNG GỌI API
```

### 5. **CKTDTH (Chiết khấu tổng đơn tặng hàng)**
```
User bỏ tích CKTDTH checkbox
  ↓
onRemoveCktdthGroup callback
  ↓
_handleRemoveCKTDTTH(groupKey)
  ↓
Remove gifts from DataLocal.listProductGift
  ↓
setState() → UI update
  ↓
❌ KHÔNG GỌI API
```

---

## ✅ Kết Luận

### **Khi bỏ tích checkbox trong bottom sheet:**
- ❌ **KHÔNG gọi API ngay**
- ✅ Chỉ update local state
- ✅ UI được update ngay (setState)

### **API chỉ được gọi khi:**
1. User nhấn nút **"Áp dụng"** ở bottom sheet
2. VÀ có changes (CKG, CKTDTT, HH được chọn)
3. VÀ không phải edit mode (`viewUpdateOrder != true`)

---

## 📊 Bảng Tóm Tắt

| Hành động | Gọi API? | Khi nào gọi API? |
|-----------|----------|------------------|
| **Bỏ tích CKG** | ❌ NO | Chỉ khi nhấn "Áp dụng" + có changes + create mode |
| **Bỏ tích CKTDTT** | ❌ NO | Chỉ khi nhấn "Áp dụng" + có changes + create mode |
| **Bỏ tích HH** | ❌ NO | Chỉ khi nhấn "Áp dụng" + có changes + create mode |
| **Bỏ tích CKN** | ❌ NO | Không bao giờ (CKN không cần API) |
| **Bỏ tích CKTDTH** | ❌ NO | Không bao giờ (CKTDTH không cần API) |
| **Nhấn "Áp dụng"** | ✅ YES* | *Chỉ khi có changes + create mode |

---

## 🔑 Logic Code

### Khi bỏ tích (trong bottom sheet):
```dart
// CKG
onRemoveCkg: (ckgId, ckgItem) {
  _handleRemoveCKG(ckgId, ckgItem);  // ❌ Không gọi API
}

void _handleRemoveCKG(String maCk, ListCk ckgItem) {
  _bloc.selectedCkgIds.remove(maCk);
  _applyCKGByMaCk(maCk, shouldApply: false);  // ❌ Không gọi API
  _updateCkDacBiet();
}
```

### Khi nhấn "Áp dụng":
```dart
void _handleApplyAllDiscounts(Map<String, dynamic> result) {
  bool hasChanges = selectedCkgIds.isNotEmpty || 
                    selectedCktdttIds.isNotEmpty || 
                    selectedHHIds.isNotEmpty;
  
  if (hasChanges && (widget.viewUpdateOrder != true)) {
    // ✅ GỌI API
    _reloadDiscountsFromBackend();
  }
}
```

---

## ⚠️ Lưu Ý

1. **Bỏ tích checkbox**: Chỉ update local, không gọi API
2. **Nhấn "Áp dụng"**: Mới gọi API (nếu có changes + create mode)
3. **Edit mode**: Dù nhấn "Áp dụng" cũng không gọi API
