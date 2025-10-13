# 🔢 Quantity Format - Dấu ngăn cách nghìn

## 📋 Yêu cầu

Số lượng cần có dấu ngăn cách nghìn để dễ đọc với số lớn:
```
1000 → 1.000 Cái
10500 → 10.500 Cái
1234.5 → 1.234.5 Cái
```

---

## 🎯 Giải pháp

### **Updated `_formatDecimal()` với parameter `withSeparator`**

```dart
String _formatDecimal(dynamic value, {bool withSeparator = false}) {
  if (value == null) return '0';
  try {
    double amount = double.parse(value.toString());
    
    // Nếu cần separator (cho số lượng)
    if (withSeparator) {
      // Nếu là số nguyên
      if (amount == amount.roundToDouble()) {
        final formatter = NumberFormat('#,##0', 'vi_VN');
        return formatter.format(amount).replaceAll(',', '.');
      }
      // Nếu có phần thập phân
      final formatter = NumberFormat('#,##0.##', 'vi_VN');
      return formatter.format(amount).replaceAll(',', '.');
    }
    
    // Không cần separator (cho phần trăm)
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    String result = amount.toStringAsFixed(2);
    result = result.replaceAll(RegExp(r'0*$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');
    return result;
  } catch (e) {
    return '0';
  }
}
```

---

## 📊 Usage

### **1. Số lượng (with separator):**
```dart
_formatDecimal(1000, withSeparator: true)    // → "1.000"
_formatDecimal(10500, withSeparator: true)   // → "10.500"
_formatDecimal(1234.5, withSeparator: true)  // → "1.234.5"
```

### **2. Phần trăm (without separator):**
```dart
_formatDecimal(10)     // → "10"
_formatDecimal(10.5)   // → "10.5"
```

---

## 🎨 Examples

### **Số lượng lớn:**

| Input | Output | Description |
|-------|--------|-------------|
| 1000 | `1.000 Cái` | 1 nghìn |
| 10000 | `10.000 Cái` | 10 nghìn |
| 100000 | `100.000 Cái` | 100 nghìn |
| 1000000 | `1.000.000 Cái` | 1 triệu |
| 1234567 | `1.234.567 Cái` | 1 triệu 234 nghìn |

### **Số lượng có thập phân:**

| Input | Output | Description |
|-------|--------|-------------|
| 1000.5 | `1.000.5 Cái` | 1 nghìn lẻ |
| 10500.25 | `10.500.25 Cái` | 10 nghìn 500 lẻ |
| 1234.56 | `1.234.56 Cái` | 1 nghìn 234 lẻ |

---

## 📊 So sánh Before → After

### **Before (no separator):**
```
┌─────────────────────────────────┐
│ Số lượng:   1000/10000 Cái      │ ← Khó đọc
└─────────────────────────────────┘
```

### **After (with separator):**
```
┌─────────────────────────────────┐
│ Số lượng:   1.000/10.000 Cái    │ ← Dễ đọc
└─────────────────────────────────┘
```

---

## 🎯 Visual Examples

### **Material Card - Normal View:**

**Before:**
```
┌─────────────────────────────────┐
│ Số lượng:   100/10000 Cái       │
│ Đơn giá:    1.234.567 đ         │
│ Thuế:       10%                  │
│ Tổng:       123.456.789 đ       │
└─────────────────────────────────┘
```

**After:**
```
┌─────────────────────────────────┐
│ Số lượng:   100/10.000 Cái      │ ← Separator added
│ Đơn giá:    1.234.567 đ         │
│ Thuế:       10%                  │
│ Tổng:       123.456.789 đ       │
└─────────────────────────────────┘
```

### **Material Card - Search Item View:**

**Before:**
```
┌─────────────────────────────────┐
│ Số lượng:   500/5000 Cái        │
│ [✓] Selected                     │
└─────────────────────────────────┘
```

**After:**
```
┌─────────────────────────────────┐
│ Số lượng:   500/5.000 Cái       │ ← Separator added
│ [✓] Selected                     │
└─────────────────────────────────┘
```

---

## 🔧 Implementation Details

### **Locations Updated:**

1. ✅ **Line ~430-461:** `_formatDecimal()` method - added `withSeparator` parameter
2. ✅ **Line ~740:** Số lượng display (normal view) - `withSeparator: true`
3. ✅ **Line ~1401:** Quantity display (search item view) - `withSeparator: true`

### **Method Signature:**
```dart
String _formatDecimal(dynamic value, {bool withSeparator = false})
```

### **Parameter:**
- `withSeparator: true` → Add thousand separator (for quantity)
- `withSeparator: false` (default) → No separator (for percentage)

---

## 📏 Format Rules by Type

### **1. Số lượng (Quantity) - WITH separator:**
```
Pattern:  #,##0.##
Examples:
  1000      → 1.000
  10000     → 10.000
  100000    → 100.000
  1234.5    → 1.234.5
  10500.25  → 10.500.25
```

### **2. Phần trăm (Percentage) - WITHOUT separator:**
```
Pattern:  0.##
Examples:
  10     → 10
  10.5   → 10.5
  5      → 5
```

### **3. Tiền tệ (Money) - WITH separator:**
```
Pattern:  #,##0.##
Examples:
  1000      → 1.000
  1234567   → 1.234.567
  1234.56   → 1.234.56
```

---

## ✅ Benefits

### **1. Readability - Dễ đọc**
```
Before: 1000000/10000000 Cái  ❌ Khó đọc
After:  1.000.000/10.000.000 Cái  ✅ Rõ ràng
```

### **2. Quick Recognition - Nhận biết nhanh**
```
1.000      → 1 nghìn
10.000     → 10 nghìn
100.000    → 100 nghìn
1.000.000  → 1 triệu
```

### **3. Professional Look**
- ✅ Chuẩn hiển thị số lớn
- ✅ Dễ so sánh giữa các số
- ✅ Giống format tiền tệ (consistency)

### **4. Flexible**
- ✅ Với separator cho số lượng
- ✅ Không separator cho phần trăm
- ✅ Đúng context từng trường hợp

---

## 🎯 Use Cases

### **Case 1: Warehouse Inventory - Kho hàng**
```
Tồn kho: 1.000.000 Cái
Đã bán:    500.000 Cái
Còn lại:   500.000 Cái
```
→ Rõ ràng là triệu đơn vị

### **Case 2: Large Orders - Đơn hàng lớn**
```
Đặt hàng: 10.000/50.000 Cái
```
→ Dễ thấy là 10 nghìn / 50 nghìn

### **Case 3: Small Quantities - Số lượng nhỏ**
```
Đặt hàng: 100/200 Cái
```
→ Không separator vẫn rõ

### **Case 4: Decimal Quantities - Có thập phân**
```
Đặt hàng: 1.234.5 Kg
```
→ 1 nghìn 234 kg rưỡi

---

## 📊 Comparison Table

| Type | Format | Example | Use For |
|------|--------|---------|---------|
| **Quantity** | `#,##0.##` | 1.000 Cái | Số lượng vật tư |
| **Percentage** | `0.##` | 10% | Thuế, CK |
| **Money** | `#,##0.##` | 1.234.567 đ | Tiền tệ |

---

## 🎨 Visual Impact

### **Small Numbers (< 1000):**
```
Before: 100 Cái
After:  100 Cái
```
→ Không ảnh hưởng (không cần separator)

### **Medium Numbers (1000-9999):**
```
Before: 5000 Cái
After:  5.000 Cái
```
→ Dễ đọc hơn một chút

### **Large Numbers (≥ 10000):**
```
Before: 100000 Cái
After:  100.000 Cái
```
→ **CỰC KỲ DỄ ĐỌC** (100 nghìn vs 100000)

### **Very Large Numbers (≥ 1000000):**
```
Before: 1234567 Cái
After:  1.234.567 Cái
```
→ **CRITICAL** (1 triệu 234 nghìn vs 1234567)

---

## 📝 Real World Examples

### **Example 1: Electronics Store**
```
┌─────────────────────────────────┐
│ Điện thoại ABC                  │
│ Số lượng:   1.500/10.000 Cái    │
│ Đơn giá:    15.000.000 đ        │
│ Tổng:       22.500.000.000 đ    │
└─────────────────────────────────┘
```

### **Example 2: Wholesale**
```
┌─────────────────────────────────┐
│ Gạo ngon XYZ                    │
│ Số lượng:   50.000/100.000 Kg   │
│ Đơn giá:    20.000 đ/Kg         │
│ Tổng:       1.000.000.000 đ     │
└─────────────────────────────────┘
```

### **Example 3: Small Business**
```
┌─────────────────────────────────┐
│ Bút bi                          │
│ Số lượng:   200/500 Cái         │
│ Đơn giá:    5.000 đ             │
│ Tổng:       1.000.000 đ         │
└─────────────────────────────────┘
```

---

## ✅ Code Quality

- ✅ **Backward compatible** - Default `withSeparator: false`
- ✅ **Flexible** - Can enable separator per use case
- ✅ **Consistent** - Uses same logic as money format
- ✅ **Smart** - Auto-detects integer vs decimal
- ✅ **Null safe** - Returns '0' on null
- ✅ **Error handling** - Try-catch for parsing

---

## 🎯 Summary

**What changed:**
- Added `withSeparator` parameter to `_formatDecimal()`
- Applied separator to quantity displays
- Kept percentage without separator

**Format Rules:**
- **Quantity:** `1.000 Cái` (with separator)
- **Percentage:** `10%` (without separator)
- **Money:** `1.234.567 đ` (with separator)

**Benefits:**
- ✅ Dễ đọc số lớn (1.000.000 vs 1000000)
- ✅ Quick recognition (1.000 = 1 nghìn)
- ✅ Professional appearance
- ✅ Consistent với money format

**Result:**
```
Số lượng: 1.000/10.000 Cái
          ↑     ↑
     Dễ đọc  Clear
```

---

**Updated:** 2025-10-09  
**Status:** ✅ Completed - No linter errors  
**File:** `/lib/screen/sell/contract/component/detail_contract.dart`

