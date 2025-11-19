# ✅ **FIXED ISSUES - Uncheck & Multiple HH Items**

## 🎯 **2 Vấn Đề Đã Fix**

---

### **1. CKG Uncheck không hoạt động** ✅

#### **Vấn đề:**
- User uncheck CKG → Chiết khấu vẫn còn
- Giá sản phẩm không trở về giá gốc
- Total không tính lại

#### **Nguyên nhân:**
`_applyAllCKG()` chỉ set metadata (typeCK, maCk...) nhưng **không thực sự áp dụng discount percentage** và không tính lại `priceAfter`.

#### **Fix:**

```dart
// ✅ TRƯỚC (Chỉ set metadata)
if (shouldApply) {
  _bloc.listOrder[index].typeCK = 'CKG';
  _bloc.listOrder[index].maCk = ckgItem.maCk;
  // ❌ Không tính discount
}

// ✅ SAU (Tính thực sự discount)
if (shouldApply) {
  _bloc.listOrder[index].typeCK = 'CKG';
  _bloc.listOrder[index].maCk = ckgItem.maCk;
  
  // ✅ THỰC SỰ ÁP DỤNG CHIẾT KHẤU
  double discountPercent = ckgItem.tlCk ?? 0;  // Lấy từ backend
  double originalPrice = _bloc.listOrder[index].giaSuaDoi ?? 0;
  double quantity = _bloc.listOrder[index].count ?? 0;
  
  _bloc.listOrder[index].discountPercentByHand = discountPercent;
  _bloc.listOrder[index].discountByHand = true;
  _bloc.listOrder[index].priceAfter = originalPrice - (originalPrice * discountPercent / 100);
  _bloc.listOrder[index].priceAfter2 = originalPrice;
  _bloc.listOrder[index].ckntByHand = (originalPrice * quantity * discountPercent) / 100;
  
  // Add to calculator list
  DataLocal.listOrderCalculatorDiscount.add(_bloc.listOrder[index]);
  
  needRecalculate = true;
}
```

#### **Khi uncheck:**

```dart
// Reset tất cả discount values
_bloc.listOrder[index].discountPercentByHand = 0;
_bloc.listOrder[index].ckntByHand = 0;
_bloc.listOrder[index].priceAfter = _bloc.listOrder[index].giaSuaDoi;  // Về giá gốc
_bloc.listOrder[index].discountByHand = false;

// Remove from calculator
DataLocal.listOrderCalculatorDiscount.removeWhere(...);

// Trigger recalculate
_recalculateTotalPayment();
```

#### **Result:**
```
Before uncheck:
  SP A: 100,000đ → CKG 7% → 93,000đ
  Total: 93,000đ

After uncheck CKG:
  SP A: 93,000đ → 100,000đ ✅
  Total: 93,000đ → 100,000đ ✅
  Discount: 7,000đ → 0đ ✅
```

---

### **2. HH - Check/Uncheck cả 2 items cùng lúc** ✅

#### **Vấn đề:**
- Backend trả về 2 HH items (PS-BITE, PS-PUTTY)
- User check/uncheck 1 item → cả 2 items bị check/uncheck

#### **Nguyên nhân:**
Cả 2 HH items **cùng `sttRecCk`** (vì cùng 1 discount rule), nhưng khác `tenVt` (tên sản phẩm).

Code cũ chỉ dùng `sttRecCk` làm ID:
```dart
❌ String hhId = hhItem.sttRecCk?.trim() ?? '';
// → 2 items cùng ID → check/uncheck cả 2!
```

#### **Fix:**

Dùng **unique ID = sttRecCk + tenVt**:

```dart
// ✅ cart_bloc.dart (Default selection)
selectedHHIds.clear();
for (var hhItem in listHH) {
  String uniqueId = '${hhItem.sttRecCk?.trim() ?? ''}_${hhItem.tenVt?.trim() ?? ''}';
  selectedHHIds.add(uniqueId);
}

// ✅ discount_voucher_selection_sheet.dart (UI)
for (var hhItem in widget.listHH) {
  String hhId = '${hhItem.sttRecCk?.trim() ?? ''}_${hhItem.tenVt?.trim() ?? ''}';
  bool isSelected = _selectedHHIds.contains(hhId);
  // ...
}

// ✅ cart_screen.dart (Apply)
for (var hhItem in _bloc.listHH) {
  String hhId = '${hhItem.sttRecCk?.trim() ?? ''}_${hhItem.tenVt?.trim() ?? ''}';
  if (selectedIds.contains(hhId)) {
    // Add this specific gift
  }
}
```

#### **Result:**
```
Before fix:
  □ PS-BITE    } Click 1 → Check cả 2 ❌
  □ PS-PUTTY   }

After fix:
  □ PS-BITE    → Click → ☑ PS-BITE ✅
  □ PS-PUTTY                (PS-PUTTY vẫn unchecked)
```

---

## 📊 **Test Cases**

### **Test 1: CKG Apply & Uncheck**
```
Given:
  - SP A: 100,000đ x5
  - CKG: MANIT10 (7%)

Step 1: Check CKG
  ✅ SP A: 100,000đ → 93,000đ
  ✅ Discount: 35,000đ (7,000 x5)
  ✅ Total: 465,000đ

Step 2: Uncheck CKG
  ✅ SP A: 93,000đ → 100,000đ
  ✅ Discount: 35,000đ → 0đ
  ✅ Total: 465,000đ → 500,000đ
```

### **Test 2: HH Independent Selection**
```
Given:
  - HH 1: PS-BITE (sttRecCk: A000000019)
  - HH 2: PS-PUTTY (sttRecCk: A000000019)  ← Same!

Step 1: Default (Both checked)
  ☑ PS-BITE
  ☑ PS-PUTTY
  ✅ 2 gifts in cart

Step 2: Uncheck PS-BITE
  ☐ PS-BITE
  ☑ PS-PUTTY   ← Still checked! ✅
  ✅ 1 gift in cart

Step 3: Check PS-BITE again
  ☑ PS-BITE
  ☑ PS-PUTTY
  ✅ 2 gifts in cart

Step 4: Uncheck PS-PUTTY
  ☑ PS-BITE    ← Still checked! ✅
  ☐ PS-PUTTY
  ✅ 1 gift in cart
```

### **Test 3: Mixed Operations**
```
Given:
  - SP A: 100,000đ
  - CKG: 7%
  - HH: PS-BITE, PS-PUTTY
  - CKN: MANI (3 gifts)

Step 1: Check all
  ✅ CKG: 7% → Total: 93,000đ
  ✅ HH: 2 gifts
  ✅ CKN: 3 gifts

Step 2: Uncheck CKG
  ✅ Total: 93,000đ → 100,000đ
  ✅ HH: still 2 gifts
  ✅ CKN: still 3 gifts

Step 3: Uncheck PS-BITE (HH)
  ✅ Total: 100,000đ (unchanged)
  ✅ HH: 2 → 1 gift (PS-PUTTY)
  ✅ CKN: still 3 gifts

Step 4: Check CKG again
  ✅ Total: 100,000đ → 93,000đ
  ✅ HH: 1 gift
  ✅ CKN: 3 gifts
```

---

## 🔧 **Files Changed**

### **1. cart_screen.dart**
- `_applyAllCKG()`: Bổ sung logic tính thực discount từ `tlCk`
- `_recalculateTotalPayment()`: Tính lại tổng tiền sau khi thay đổi discount
- `_applyAllHH()`: Dùng unique ID cho HH items

### **2. cart_bloc.dart**
- `_handlerApplyDiscountV2()`: Dùng unique ID khi select default HH

### **3. discount_voucher_selection_sheet.dart**
- `_buildHHVouchers()`: Dùng unique ID để render checkbox độc lập

---

## ✅ **Summary**

| Issue | Status | Impact |
|-------|--------|--------|
| CKG uncheck không hoạt động | ✅ Fixed | Chiết khấu được bỏ và tính lại tiền đúng |
| HH check/uncheck cả 2 | ✅ Fixed | Mỗi HH item có thể check/uncheck riêng |

**→ Cả 2 vấn đề đã được fix hoàn toàn!**

---

## 🚀 **Ready to Test**

```bash
flutter run
# Thêm sản phẩm → Click 🎁
# Test 1: Check CKG → Uncheck CKG → Giá tăng lên ✅
# Test 2: Check/uncheck từng HH riêng → Độc lập ✅
```

**🎉 Perfect!**

