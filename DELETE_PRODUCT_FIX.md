# ✅ **DELETE PRODUCT FIX - Clear Discount Memory**

## 🎯 **Vấn Đề**

```
User flow:
1. Add sản phẩm A → Apply CKG 10%
2. Delete sản phẩm A
3. Add lại sản phẩm A
  
Expected:
  - Sản phẩm A không có discount (fresh start)
  
Actual:
  - Sản phẩm A TỰ ĐỘNG có CKG 10% ❌
  
→ Discount được "ghi nhớ" từ lần trước!
```

---

## 🔍 **Root Cause**

### **Code cũ (Line 3300-3301):**

```dart
// ❌ VẤNĐỀ
if(DataLocal.listCKVT.contains('${itemSelect.sttRecCK}-${itemSelect.code}')) {
  DataLocal.listCKVT.replaceAll('${itemSelect.sctGoc}-${itemSelect.code}', '');
}
```

### **Issues:**

1. **Dùng `sctGoc` thay vì `sttRecCK`:**
   ```
   Check: sttRecCK = "A000000018"
   Remove: sctGoc = "" (empty!) → Không xóa được!
   ```

2. **`replaceAll('')` để lại comma thừa:**
   ```
   listCKVT = "A000000018-MANIT10,A000000019-PS-BITE"
   replaceAll("A000000018-MANIT10", "")
   → ",A000000019-PS-BITE"  ← Comma đầu thừa!
   ```

3. **Không clear `_bloc.selectedCkgIds`:**
   ```
   selectedCkgIds vẫn chứa discount ID
   → Khi add lại → auto-check CKG
   ```

---

## ✅ **Fix**

### **New Logic:**

```dart
// ✅ ĐÚNG
if(DataLocal.listCKVT.isNotEmpty) {
  String productCode = itemSelect.code.toString().trim();
  
  // Split by comma, filter empty
  List<String> ckList = DataLocal.listCKVT
    .split(',')
    .where((s) => s.isNotEmpty)
    .toList();
  
  // Remove ALL discounts for this product (endsWith check)
  ckList.removeWhere((item) => item.endsWith('-$productCode'));
  
  // Rejoin with comma (no trailing commas)
  DataLocal.listCKVT = ckList.join(',');
  
  // Also clear from selectedCkgIds
  _bloc.selectedCkgIds.removeWhere((id) => 
    _bloc.listCkg.any((ckg) => 
      ckg.sttRecCk == id && ckg.maVt?.trim() == productCode
    )
  );
}
```

---

## 📊 **Test Scenarios**

### **Test 1: Delete product có CKG**

```
Step 1: Add product
  - SP A: 3.040.000đ x1
  - listCKVT: ""
  - selectedCkgIds: {}

Step 2: Apply CKG 10%
  - listCKVT: "A000000018-MANIT10"
  - selectedCkgIds: {"A000000018"}

Step 3: Delete SP A
  Expected:
    ✅ listCKVT: ""  (removed)
    ✅ selectedCkgIds: {}  (cleared)

Step 4: Add lại SP A
  Expected:
    ✅ Không có discount tự động
    ✅ listCKVT: ""
    ✅ Click 🎁 → CKG unchecked
```

### **Test 2: Delete 1 trong nhiều products**

```
Given:
  - SP A: CKG 10%
  - SP B: CKG 7%
  - listCKVT: "A000000018-MANIT10,A000000020-PS-BC31"

Action: Delete SP A

Expected:
  ✅ listCKVT: "A000000020-PS-BC31"  (SP A removed, SP B kept)
  ✅ selectedCkgIds: {"A000000020"}  (SP A discount removed)
```

### **Test 3: Delete sản phẩm không có discount**

```
Given:
  - SP A: No discount
  - SP B: CKG 10%
  - listCKVT: "A000000020-PS-BC31"

Action: Delete SP A

Expected:
  ✅ listCKVT: "A000000020-PS-BC31"  (unchanged)
  ✅ selectedCkgIds: {"A000000020"}  (unchanged)
```

---

## 🔧 **Benefits**

### **Before Fix:**
```
Delete product → listCKVT không clean
  ↓
Add lại → API nhận listCKVT cũ
  ↓
Backend tự động apply discount ❌
```

### **After Fix:**
```
Delete product → listCKVT clean hoàn toàn
  ↓
selectedCkgIds also cleared
  ↓
Add lại → Fresh start, no discount ✅
```

---

## 🎯 **Implementation Details**

### **Why `endsWith()` check?**

```dart
// Format: "sttRecCk-productCode"
"A000000018-MANIT10"
"A000000019-PS-BITE"

// When delete "MANIT10"
ckList.removeWhere((item) => item.endsWith('-MANIT10'))
  → Removes "A000000018-MANIT10" ✅
  → Keeps "A000000019-PS-BITE" ✅
```

### **Why filter `isNotEmpty`?**

```dart
// Prevent empty strings in list
"A000000018-MANIT10,,A000000019-PS-BITE"
  .split(',')  // ["A000000018-MANIT10", "", "A000000019-PS-BITE"]
  .where((s) => s.isNotEmpty)  // ["A000000018-MANIT10", "A000000019-PS-BITE"]
  .toList()
```

### **Why clear `selectedCkgIds`?**

```dart
// Prevent auto-check when add lại
selectedCkgIds = {"A000000018"}  // SP A discount
→ Delete SP A
→ Clear this ID from set
→ Add lại SP A
→ Voucher sheet: CKG unchecked ✅
```

---

## 🚀 **TEST STEPS**

```bash
flutter run
```

1. **Add sản phẩm:** 3.040.000đ x1
2. **Apply CKG 10%**
   - Giá: 2.736.000đ ✅
3. **Delete sản phẩm** (swipe left → Xóa)
   - Check logs: "Removed product ... from listCKVT"
4. **Add lại sản phẩm** (cùng code)
5. **Verify:**
   - ✅ Giá: 3.040.000đ (NO discount)
   - ✅ Click 🎁 → CKG unchecked
6. **Apply lại CKG**
   - ✅ Giá: 2.736.000đ

---

## 🎉 **COMPLETE FIX!**

**All discount memory issues resolved:**
- ✅ Delete product → Clear discount
- ✅ Clean comma handling
- ✅ Clear selectedCkgIds
- ✅ Fresh start when re-add

**→ Perfect behavior! 🚀**

