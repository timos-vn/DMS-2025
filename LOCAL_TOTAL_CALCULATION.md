# ✅ **LOCAL TOTAL CALCULATION - Final Solution**

## 🎯 **Root Cause**

### **Vấn đề với Backend API:**

```dart
// TotalDiscountAndMoneyForAppEvent calls calculatorPayment API
// DiscountRequest model:
{
  maKh: "KH001",
  maKho: "KHO001",
  lineItem: [...]
}

// ❌ KHÔNG CÓ listPromotion!
// ❌ KHÔNG CÓ listCKVT!

→ Backend KHÔNG biết discounts nào đã chọn
→ Không tính discount được
→ Total SAI!
```

---

## ✅ **Solution: Local Calculation**

### **Thay vì gọi backend, tính LOCAL:**

```dart
void _recalculateTotalLocal() {
  double totalMoney = 0;
  double totalDiscount = 0;
  
  // Loop all products
  for (var element in _bloc.listOrder) {
    if (element.isMark == 1 && element.gifProduct != true) {
      double originalPrice = element.giaSuaDoi ?? 0;
      double quantity = element.count ?? 0;
      
      // Original total
      totalMoney += originalPrice * quantity;
      
      // Discount
      double discountPercent = element.discountPercentByHand ?? element.discountPercent ?? 0;
      if (discountPercent > 0) {
        double lineDiscount = (originalPrice * quantity * discountPercent) / 100;
        totalDiscount += lineDiscount;
      }
    }
  }
  
  // Calculate payment
  double totalPayment = totalMoney - totalDiscount;
  
  // Update BLoC
  _bloc.totalMoney = totalMoney;
  _bloc.totalDiscount = totalDiscount;
  _bloc.totalPayment = totalPayment;
}
```

---

## 📊 **Calculation Logic**

### **Example:**

```
Products in cart:
  SP A: 3.040.000đ x4, CKG 10%
    → priceAfter = 2.736.000đ
  SP B: 5.000.000đ x2, no discount
    → priceAfter = 5.000.000đ

Calculation:
  totalMoney = (3.040.000 * 4) + (5.000.000 * 2)
             = 12.160.000 + 10.000.000
             = 22.160.000đ
  
  totalDiscount = (3.040.000 * 4 * 10%)
                = 1.216.000đ
  
  totalPayment = 22.160.000 - 1.216.000
               = 20.944.000đ
```

---

## 🎯 **When Called**

### **Triggered by:**

1. **Check CKG/HH:**
   ```
   _applyAllCKG(selectedIds) {
     if (hasRemovals || hasAdditions) {
       _recalculateTotalLocal();  ← HERE
       setState();
     }
   }
   ```

2. **Uncheck CKG/HH:**
   ```
   Same flow - recalculates when discount removed
   ```

---

## 🔍 **Debug Logs**

### **Expected Output:**

```
💰 Force UI rebuild - hasRemovals=true
💰 === Recalculating Total Locally ===
💰 Product MANIT10: qty=4, originalPrice=3040000, priceAfter=3040000, discount=0%
💰 Product PS-PUTTY: qty=2, originalPrice=5000000, priceAfter=5000000, discount=0%
💰 Total Calculated:
    totalMoney = 22160000
    totalDiscount = 0
    totalPayment = 22160000
```

**With CKG:**
```
💰 Product MANIT10: qty=4, originalPrice=3040000, priceAfter=2736000, discount=10%
💰 Total Calculated:
    totalMoney = 22160000
    totalDiscount = 1216000
    totalPayment = 20944000
```

---

## ✅ **Complete Fix Flow**

### **Uncheck CKG:**

```
User uncheck ☑ → ☐
  ↓
Remove from listCKVT + listPromotion ✅
  ↓
Reset discount fields = 0 ✅
  ↓
_recalculateTotalLocal() ✅
  → totalMoney = Σ(giaSuaDoi * count)
  → totalDiscount = 0 (no discounts)
  → totalPayment = totalMoney
  ↓
setState() → UI rebuild ✅
  ↓
✅ DONE:
  Unit price: correct
  Total price: correct  ← FIXED!
```

---

## 🎊 **Benefits**

### **Local Calculation:**
- ✅ **Instant** (no API wait)
- ✅ **Accurate** (uses current data)
- ✅ **Simple** (clear logic)
- ✅ **No dependencies** (không cần DiscountRequest model changes)

### **Still Use Backend For:**
- ✅ Initial discount load (GetListItemApplyDiscountEvent)
- ✅ CKG check (reload with listCKVT + listPromotion)
- ✅ Final order calculation (when submit)

---

## 🚀 **TEST NOW!**

```bash
flutter run
```

**Critical Test:**
1. Add SP: 3.040.000đ x4
2. **Check CKG 10%:**
   - Logs: "totalPayment = 10944000"
   - UI: Total = 10.944.000đ ✅
3. **Uncheck CKG:**
   - Logs: "totalPayment = 12160000"
   - UI: Total = 12.160.000đ ✅
4. **Verify calculation:**
   - totalMoney = 12.160.000
   - totalDiscount = 0
   - totalPayment = 12.160.000 ✅

---

## 📂 **Files Changed**

### **cart_screen.dart:**
- `_applyAllCKG()`: Call `_recalculateTotalLocal()`
- `_recalculateTotalLocal()`: NEW - Calculate total locally

---

## 🎉 **SHOULD WORK NOW!**

**Test và report:**
- ✅ Total có update không?
- ✅ Console logs có đúng không?
- ✅ Số tiền có match với calculation không?

**→ Test ngay! 🚀**

