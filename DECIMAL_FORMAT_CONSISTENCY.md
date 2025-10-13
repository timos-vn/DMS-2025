# 🔢 Decimal Format Consistency

## 📋 Vấn đề trước đây

### **Inconsistent Formats:**
```
Đơn giá:     1.234.567 đ      (có dấu chấm ngăn cách)
Số lượng:    10               (không thập phân)
Số lượng:    10.5             (có thập phân tùy ý)
Tỷ lệ CK:    5                (không thập phân)
Thuế suất:   10               (không thập phân)
Tổng tiền:   1.234.567,5 đ   (1 chữ số thập phân)
```

❌ **Problems:**
- Không đồng bộ
- Đôi khi có .0, đôi khi không
- Khó so sánh số liệu
- Không chuyên nghiệp

---

## ✅ Giải pháp mới

### **1. Hai Helper Methods:**

#### **A. `_formatMoney()` - Cho tiền tệ**
```dart
String _formatMoney(dynamic value) {
  if (value == null) return '0.00';
  try {
    double amount = double.parse(value.toString());
    // Format với 2 chữ số thập phân và dấu ngăn cách
    final formatter = NumberFormat('#,##0.00', 'vi_VN');
    return formatter.format(amount).replaceAll(',', '.');
  } catch (e) {
    return '0.00';
  }
}
```

**Features:**
- **2 chữ số thập phân** cố định (.00)
- **Dấu chấm ngăn cách** hàng nghìn (1.000)
- **Null safety** → '0.00'
- **Format:** `1.234.567.89`

#### **B. `_formatDecimal()` - Cho số lượng, phần trăm**
```dart
String _formatDecimal(dynamic value, {int decimals = 2}) {
  if (value == null) return '0.00';
  try {
    double amount = double.parse(value.toString());
    return amount.toStringAsFixed(decimals);
  } catch (e) {
    return '0.00';
  }
}
```

**Features:**
- **2 chữ số thập phân** cố định (.00)
- **Không có dấu ngăn cách** (10.50)
- **Null safety** → '0.00'
- **Flexible decimals** (default = 2)
- **Format:** `10.50`

---

## 🎯 Áp dụng

### **1. Material Cards - Vật tư**

| Field | Old Format | New Format | Method |
|-------|-----------|-----------|---------|
| Đơn giá | `Utils.formatMoneyStringToDouble()` | `_formatMoney()` | 1.000.000.00 đ |
| Số lượng | `Utils.formatDecimalNumber()` | `_formatDecimal()` | 10.00 Cái |
| Tỷ lệ CK | `Utils.formatDecimalNumber()` | `_formatDecimal()` | 5.00% |
| Thuế suất | `Utils.formatDecimalNumber()` | `_formatDecimal()` | 10.00% |
| Tổng | `Utils.formatMoneyStringToDouble()` | `_formatMoney()` | 1.100.000.00 đ |

### **2. Bottom Total - Tổng thanh toán**

| Field | Old Format | New Format |
|-------|-----------|-----------|
| Tổng tiền | Inconsistent | 10.000.000.00 đ |
| Tổng thuế | Inconsistent | 1.000.000.00 đ |
| Tổng thanh toán | Inconsistent | 11.000.000.00 đ |

---

## 📊 So sánh Before → After

### **Material Card Example:**

**BEFORE:**
```
┌─────────────────────────────────┐
│ Đơn giá:    1.234.567 đ         │
│ Số lượng:   10 Cái              │
│ CK:         5%                   │
│ Thuế:       10%                  │
│ Tổng:       1.234.567 đ         │
└─────────────────────────────────┘
```

**AFTER:**
```
┌─────────────────────────────────┐
│ Đơn giá:    1.234.567.00 đ      │
│ Số lượng:   10.00 Cái           │
│ CK:         5.00%                │
│ Thuế:       10.00%               │
│ Tổng:       1.234.567.00 đ      │
└─────────────────────────────────┘
```

### **Bottom Total Example:**

**BEFORE:**
```
Tổng tiền:        10.000.000 đ
Tổng thuế:        1.000.000 đ
─────────────────────────────
Tổng thanh toán:  11.000.000 đ
```

**AFTER:**
```
Tổng tiền:        10.000.000.00 đ
Tổng thuế:        1.000.000.00 đ
──────────────────────────────────
Tổng thanh toán:  11.000.000.00 đ
```

---

## 🎨 Format Rules

### **Rule 1: Tiền tệ (Money)**
```
Format:  #,##0.00
Example: 1.234.567.89 đ
         10.50 đ
         0.00 đ
```
- Dấu chấm (.) ngăn cách hàng nghìn
- Luôn có 2 chữ số thập phân

### **Rule 2: Số lượng (Quantity)**
```
Format:  0.00
Example: 10.00 Cái
         5.50 Kg
         100.00 Hộp
```
- Không có dấu ngăn cách
- Luôn có 2 chữ số thập phân

### **Rule 3: Phần trăm (Percentage)**
```
Format:  0.00%
Example: 5.00%
         10.50%
         0.00%
```
- Không có dấu ngăn cách
- Luôn có 2 chữ số thập phân

---

## ✅ Benefits

### **1. Consistency** 
- ✅ Tất cả số đều có .00
- ✅ Dễ đọc và so sánh
- ✅ Professional look

### **2. Clarity**
- ✅ Rõ ràng là decimal
- ✅ Không nhầm lẫn giữa 10 và 10.0
- ✅ Dễ dàng phân biệt số nguyên vs thập phân

### **3. Professional**
- ✅ Chuẩn kế toán
- ✅ Nhất quán toàn bộ app
- ✅ Dễ audit số liệu

### **4. Null Safety**
- ✅ Không bao giờ crash
- ✅ Default: '0.00'
- ✅ Try-catch handling

---

## 🔧 Technical Details

### **Method Signatures:**
```dart
String _formatMoney(dynamic value)
String _formatDecimal(dynamic value, {int decimals = 2})
```

### **Import Required:**
```dart
import 'package:intl/intl.dart';
```

### **Usage Examples:**
```dart
// Tiền tệ
_formatMoney(1234567.89)  // → "1.234.567.89"
_formatMoney(10.5)        // → "10.50"
_formatMoney(null)        // → "0.00"

// Số lượng
_formatDecimal(10)        // → "10.00"
_formatDecimal(10.5)      // → "10.50"
_formatDecimal(null)      // → "0.00"

// Phần trăm
_formatDecimal(5.5)       // → "5.50"
_formatDecimal(10)        // → "10.00"
```

---

## 📍 Locations Updated

### **File:** `detail_contract.dart`

**Lines updated:**
1. ✅ Line ~411-432: Helper methods
2. ✅ Line ~724: Đơn giá (giaNt2)
3. ✅ Line ~734: Tỷ lệ CK (tlCk)
4. ✅ Line ~745: Thuế suất (thueSuat)
5. ✅ Line ~712: Số lượng display
6. ✅ Line ~769: Tổng card
7. ✅ Line ~903: Tổng thanh toán (bottom)
8. ✅ Line ~947: Compact total items
9. ✅ Line ~1384: Quantity display search item

**Total:** 9 locations

---

## 🎯 Decimal Places by Type

| Data Type | Decimals | Example |
|-----------|----------|---------|
| Money (đ) | 2 | 1.234.567.89 đ |
| Quantity | 2 | 10.50 Cái |
| Percentage | 2 | 5.50% |
| Price | 2 | 100.00 đ |
| Tax | 2 | 10.00% |
| Discount | 2 | 5.00% |

**Standard:** ALL numbers display with **2 decimal places**

---

## 📊 Impact

### **Before:**
```
Inconsistent decimals:
- 10
- 10.5
- 10.0
- 1.234.567
- 1.234.567,5
```

### **After:**
```
Consistent decimals:
- 10.00
- 10.50
- 10.00
- 1.234.567.00
- 1.234.567.50
```

### **Result:**
- ✅ 100% consistency
- ✅ Professional appearance
- ✅ Easy to read
- ✅ No confusion
- ✅ Audit-ready

---

## 🚀 Future Considerations

### **Optional Enhancements:**
1. **Locale-aware** formatting (VN vs EN)
2. **Currency symbol** position (đ vs VND)
3. **Configurable decimals** (2 vs 3 vs 4)
4. **Round vs Truncate** options
5. **Negative number** formatting

---

## ✅ Code Quality

- ✅ Type-safe with dynamic input
- ✅ Null safety with defaults
- ✅ Try-catch error handling
- ✅ Reusable helper methods
- ✅ Clear naming conventions
- ✅ No linter errors
- ✅ Consistent throughout

---

## 📝 Summary

**What changed:**
- All money values: **2 decimal places** with separator
- All quantities: **2 decimal places** no separator
- All percentages: **2 decimal places** no separator

**Why it matters:**
- Consistency across entire screen
- Professional appearance
- Easy to read and compare
- Audit-friendly
- No confusion about decimal values

**Result:**
- ✅ 100% decimal format consistency
- ✅ Professional financial display
- ✅ Easy maintenance
- ✅ User-friendly

---

**Updated:** 2025-10-09  
**Status:** ✅ Completed - No linter errors  
**File:** `/lib/screen/sell/contract/component/detail_contract.dart`

