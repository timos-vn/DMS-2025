# 🔍 **DEBUG - CKG Uncheck Still Shows Discount**

## 🎯 **Issue**

```
User uncheck CKG:
  ❌ UI vẫn hiển thị: "Giá bán: $760000 (-10.0%)"
  ❌ Discount không bị bỏ
```

---

## 🔧 **Latest Fix - Immediate Reset**

### **What we did:**

1. **Reset TẤT CẢ discount fields ngay khi uncheck:**
```dart
_bloc.listOrder[index].discountPercent = 0;
_bloc.listOrder[index].discountPercentByHand = 0;
_bloc.listOrder[index].ckntByHand = 0;
_bloc.listOrder[index].ck = 0;
_bloc.listOrder[index].cknt = 0;
_bloc.listOrder[index].priceAfter = originalPrice;
```

2. **Sync NGAY ra UI (không đợi API):**
```dart
_syncSingleProductToUI(index, productCode);
  → Update listProductOrderAndUpdate[uiIndex]
  → setState()
```

3. **Added debug logs:**
```dart
print('💰 BEFORE reset: discountPercent=..., discountPercentByHand=...');
print('💰 AFTER reset: discountPercent=0, priceAfter=...');
```

---

## 🧪 **Debug Steps**

### **Test và check logs:**

```bash
flutter run
```

**Steps:**
1. Thêm sản phẩm vào giỏ
2. Click 🎁 → Default CKG checked
3. **Uncheck CKG** 
4. **XEM CONSOLE LOGS:**

```
💰 Applying 0 CKG discounts
💰 Removed CKG from listCKVT: A000000018-MANIT10
💰 Force reset ALL discount fields for MANIT10
💰 BEFORE reset: discountPercent=10.0, discountPercentByHand=0
💰 AFTER reset: discountPercent=0, discountPercentByHand=0, priceAfter=100000
💰 Syncing product MANIT10 to UI immediately
💰 UI data updated for MANIT10: discount=0, price=100000
💰 Reloading discounts from backend with listCKVT: 
```

**Kiểm tra output:**
- ✅ discountPercent = 0?
- ✅ discountPercentByHand = 0?
- ✅ priceAfter = 100000?

---

## 🎯 **UI Rendering Check**

### **UI reads from:**

```dart
// Line 3449-3456 in cart_screen.dart
Text.rich(
  TextSpan(
    children: [
      TextSpan(text: 'Giá bán: \$${_bloc.listOrder[index].giaSuaDoi}'),
      TextSpan(
        // ← THIS SHOWS "(-10.0%)"
        text: _bloc.listOrder[index].discountPercentByHand > 0 
          ? '  (-${_bloc.listOrder[index].discountPercentByHand} %)'
          : _bloc.listOrder[index].discountPercent! > 0 
            ? '  (-${_bloc.listOrder[index].discountPercent} %)'  ← CHECK THIS!
            : '',
        style: TextStyle(color: Colors.red),
      ),
    ],
  ),
)
```

**Check:**
- Nếu `discountPercentByHand = 0` ✅
- Và `discountPercent = 0` ✅
- Thì UI KHÔNG hiển thị "(-10.0%)" ✅

---

## 🔍 **Possible Issues**

### **Issue 1: Multiple products cùng code?**
```dart
// Check xem có nhiều products cùng code không
_bloc.listOrder.where((item) => item.code == 'MANIT10').length
// Nếu > 1 → Chỉ reset 1 item, còn item khác vẫn có discount
```

**Fix nếu đúng:**
```dart
// Reset ALL products cùng code
for (int i = 0; i < _bloc.listOrder.length; i++) {
  if (_bloc.listOrder[i].code == productCode && 
      _bloc.listOrder[i].sttRecCK == ckgItem.sttRecCk) {
    // Reset this item
  }
}
```

### **Issue 2: API response overwrite reset values?**
```
Reset local → setState() → UI update ✅
     ↓
API response arrives LATER
     ↓
Backend response có discount (vì timing)
     ↓
Overwrite reset values ❌
     ↓
UI hiển thị lại discount
```

**Fix nếu đúng:**
- Đợi API response xong RỒI MỚI reset
- HOẶC: Ignore API response nếu product không có trong listCKVT

---

## 🎯 **Debug Checklist**

Khi test, kiểm tra console logs:

### **1. Check discount values AFTER reset:**
```
💰 AFTER reset: discountPercent=?, discountPercentByHand=?
```
- Nếu = 0 → Reset thành công ✅
- Nếu ≠ 0 → Reset thất bại, cần check logic ❌

### **2. Check listCKVT value:**
```
💰 Removed CKG from listCKVT: ...
💰 Reloading discounts from backend with listCKVT: ?
```
- Nếu empty ("") → Đúng ✅
- Nếu vẫn có CKG → Sai ❌

### **3. Check API response:**
```
// Trong console, tìm response log
Response: {
  list_ck: [
    {kieu_ck: "CKG", tl_ck: 10.0, ...}  ← Nếu vẫn có → SAI!
  ]
}
```

### **4. Check UI index:**
```
💰 Syncing product MANIT10 to UI immediately
💰 UI data updated for MANIT10: discount=0, price=?
```
- Found và updated → Đúng ✅
- Not found → Index sai ❌

---

## 📋 **Action Items**

**Run và report logs:**

1. Mở app → Thêm sản phẩm
2. Click 🎁
3. **Uncheck CKG**
4. **COPY TẤT CẢ CONSOLE LOGS** và gửi cho tôi
5. Kiểm tra:
   - Value của `discountPercent` sau reset
   - Value của `listCKVT` sau remove
   - API response có CKG không?
   - UI index có tìm thấy product không?

---

## 🚨 **Quick Fix If Needed**

### **Nếu vấn đề là API response overwrite:**

```dart
// Option: Skip API reload, just reset local
void _applyAllCKG(Set<String> selectedIds) {
  for (var ckgItem in _bloc.listCkg) {
    if (!shouldApply) {
      // Reset fields
      _bloc.listOrder[index].discountPercent = 0;
      _bloc.listOrder[index].discountPercentByHand = 0;
      // ...
      
      // Sync to UI IMMEDIATELY
      _syncSingleProductToUI(index, productCode);
      
      // DON'T call API if only removing
      // (Only call API if adding discount)
    }
  }
}
```

---

**📝 GỬI LOGS CHO TÔI ĐỂ DEBUG TIẾP!**

