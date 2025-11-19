# 🚨 **CRITICAL BUGS - Giá Tăng & Gifts Duplicate**

## 🎯 **2 Vấn Đề Nghiêm Trọng**

### **Bug 1: Giá TĂNG khi apply chiết khấu** 🚨
```
Given:
  - SP A: Giá gốc 3.040.000đ
  - CKG: 10%
  
Expected:
  - Giá sau CK: 3.040.000 - 10% = 2.736.000đ
  
Actual:
  - Giá sau CK: 10.944.000đ ❌❌❌
  
→ GIÁ TĂNG thay vì GIẢM!
```

### **Bug 2: Số lượng gifts tự động tăng** 🚨
```
Given:
  - HH: 2 items (PS-BITE x1, PS-PUTTY x1)
  - totalProductGift = 2
  
Action: Check CKG (trigger API reload)

Actual:
  - totalProductGift: 2 → 4 → 6 → 8... ❌
  
→ Gifts bị ADD NHIỀU LẦN!
```

---

## ✅ **Fixes Applied**

### **Fix 1: Prevent HH Duplicate**

**Root cause:**
```dart
// OLD flow
_handleApplyAllDiscounts() {
  _applyAllCKG();  // Call API if check
  _applyAllHH();   // Add HH gifts (1st time)
}

// After API response
ApplyDiscountSuccess (keyLoad='Second') {
  _applyAllHH();   // Add HH gifts (2nd time) ❌ DUPLICATE!
}
```

**Solution:**
```dart
_handleApplyAllDiscounts() {
  _applyAllCKG();
  
  // ✅ CHỈ apply HH nếu KHÔNG có API reload
  if (!_needReapplyHHAfterReload) {
    _applyAllHH();  // Only if no API pending
  }
}

ApplyDiscountSuccess {
  if (_needReapplyHHAfterReload) {
    _applyAllHH();  // Re-apply after API
  }
}
```

**Kết quả:**
- ✅ HH chỉ được add 1 lần
- ✅ totalProductGift không tăng

---

## 🔍 **Debug Bug 1: Giá Tăng**

### **Added Debug Logs:**

```dart
else if(state is ApplyDiscountSuccess){
  if(state.keyLoad == 'Second') {
    print('💰 === API Response Received ===');
    for (var item in _bloc.listOrder) {
      print('💰 Product: ${item.code}');
      print('    giaSuaDoi=${item.giaSuaDoi}');
      print('    priceAfter=${item.priceAfter}');
      print('    discountPercent=${item.discountPercent}');
    }
  }
}
```

### **Expected Logs (Khi check CKG):**
```
💰 Calling API to apply new discounts
--- API call ---
💰 === API Response Received ===
💰 Product: MANIT10
    giaSuaDoi=3040000  ← Giá gốc
    priceAfter=2736000  ← Giá sau CK (3.04M - 10%)
    discountPercent=10.0
```

### **If Logs Show:**
```
💰 Product: MANIT10
    giaSuaDoi=3040000
    priceAfter=10944000  ← SAI!
    discountPercent=10.0
```

**→ Backend response SAI! Backend trả về giá tăng thay vì giảm.**

**Possible reasons:**
1. Backend tính sai công thức
2. Backend nhận sai parameters (listPrice, listMoney)
3. Backend logic có bug

---

## 🎯 **Debug Steps**

### **Test và kiểm tra logs:**

```bash
flutter run
```

**Steps:**
1. Xóa hết sản phẩm trong giỏ
2. Thêm 1 sản phẩm (giá 3.040.000đ)
3. Click 🎁
4. **Check CKG 10%**
5. **XEM CONSOLE LOGS:**

```
💰 Added CKG to listCKVT: ...
💰 Calling API to apply new discounts
💰 Called GetListItemApplyDiscountEvent with:
  listItem: MANIT10
  listQty: 1
  listPrice: 3040000
  listMoney: 3040000
  listCKVT: A000000018-MANIT10
💰 === API Response Received ===
💰 Product: MANIT10
    giaSuaDoi=?     ← CHECK VALUE
    priceAfter=?    ← CHECK VALUE  
    discountPercent=?
```

### **Kiểm tra:**

| Field | Expected | If Wrong → Problem |
|-------|----------|-------------------|
| giaSuaDoi | 3.040.000 | Backend changed giá gốc ❌ |
| priceAfter | 2.736.000 | Backend tính sai ❌ |
| discountPercent | 10.0 | Discount % sai ❌ |

---

## 🧪 **Possible Issues**

### **Issue A: Backend nhận sai request**
```
Request sent:
  listPrice: "3040000,3040000,3040000"  ← Nhiều giá trị?
  listQty: "1,1,1"  ← Nhiều items?
  
→ Backend tính: 3.040.000 * 3 = 9.120.000
→ Sau CK 10%: 9.120.000 + ??? = 10.944.000
```

**Fix:** Check request có duplicate items không

### **Issue B: Backend tính CK NGƯỢC**
```
Backend logic (SAI):
  giaSauCk = giaGoc * (1 + tlCk/100)  ← CỘNG discount!
  = 3.040.000 * 1.1
  = 3.344.000
```

**Fix:** Báo backend sửa công thức

### **Issue C: Có items khác được add vào**
```
listOrder before API: 1 item (3.04M)
listOrder after API: 3 items (3.04M + ??? + ???)
→ Total: 10.944.000
```

**Fix:** Check `_bloc.listOrder.length` before/after

---

## 📋 **Action Items**

**GỬI CHO TÔI:**

1. **Console logs** khi check CKG (TẤT CẢ logs)
2. **Giá trị của:**
   - `giaSuaDoi` after API
   - `priceAfter` after API
   - `discountPercent` after API
   - `_bloc.listOrder.length` before/after
3. **Request parameters:**
   - `listItem` value
   - `listQty` value
   - `listPrice` value
   - `listMoney` value
   - `listCKVT` value

---

## 🔧 **Temporary Workaround**

### **Nếu backend response sai, có thể skip backend và tính local:**

```dart
if (shouldApply) {
  // DON'T call API, calculate locally
  double discountPercent = ckgItem.tlCk ?? 0;
  double originalPrice = _bloc.listOrder[i].giaSuaDoi ?? 0;
  double priceAfter = originalPrice * (1 - discountPercent / 100);
  
  _bloc.listOrder[i].discountPercent = discountPercent;
  _bloc.listOrder[i].priceAfter = priceAfter;
  
  setState();
  // No API call
}
```

---

## 🚨 **Priority Actions**

1. **Test với logs** → Report kết quả
2. **Nếu backend SAI** → Tính local hoặc báo backend fix
3. **Nếu request SAI** → Fix request parameters

---

**📝 CHẠY TEST VÀ GỬI LOGS CHO TÔI ĐỂ DEBUG TIẾP!**

