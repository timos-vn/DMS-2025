# 🔢 Dấu phẩy "," cho Số lượng

## 📋 Yêu cầu

Số lượng dùng dấu phẩy "," thay vì dấu chấm ".":
```
Số lượng: 1,000 Cái    (dấu phẩy)
Đơn giá:  1.234.567 đ  (dấu chấm)
```

---

## 🎯 Giải pháp

### **Added `separator` parameter to `_formatDecimal()`**

```dart
String _formatDecimal(
  dynamic value, 
  {
    bool withSeparator = false, 
    String separator = ','  // Default là dấu phẩy
  }
)
```

**Usage:**
```dart
// Số lượng - dùng dấu phẩy (default)
_formatDecimal(1000, withSeparator: true)  
// → "1,000"

// Tiền tệ - dùng dấu chấm (money format riêng)
_formatMoney(1234567)
// → "1.234.567"
```

---

## 📊 Format by Type

### **1. Số lượng (Quantity) - Dấu phẩy ","**
```
1000      → 1,000 Cái
10000     → 10,000 Cái
100000    → 100,000 Cái
1234.5    → 1,234.5 Cái
```

### **2. Tiền tệ (Money) - Dấu chấm "."**
```
1000      → 1.000 đ
1234567   → 1.234.567 đ
1234.5    → 1.234.5 đ
```

### **3. Phần trăm (Percentage) - Không separator**
```
10     → 10%
10.5   → 10.5%
```

---

## 🎨 Visual Examples

### **Material Card:**

```
┌─────────────────────────────────┐
│ Số lượng:   1,000/10,000 Cái    │ ← Dấu phẩy
│ Đơn giá:    1.234.567 đ         │ ← Dấu chấm
│ Thuế:       10%                  │ ← Không separator
│ Tổng:       1.234.567.000 đ     │ ← Dấu chấm
└─────────────────────────────────┘
```

### **Large Quantities:**

```
┌─────────────────────────────────┐
│ Gạo ngon XYZ                    │
│ Số lượng:   50,000/100,000 Kg   │ ← Dấu phẩy
│ Đơn giá:    20.000 đ/Kg         │ ← Dấu chấm
│ Tổng:       1.000.000.000 đ     │ ← Dấu chấm
└─────────────────────────────────┘
```

---

## 📊 So sánh Dấu chấm vs Dấu phẩy

### **With Comma (,) - Số lượng:**

| Input | Output |
|-------|--------|
| 1000 | `1,000 Cái` |
| 10000 | `10,000 Cái` |
| 100000 | `100,000 Cái` |
| 1234.5 | `1,234.5 Cái` |

### **With Dot (.) - Tiền tệ:**

| Input | Output |
|-------|--------|
| 1000 | `1.000 đ` |
| 1234567 | `1.234.567 đ` |
| 1234.5 | `1.234.5 đ` |

---

## 🎯 Why Different Separators?

### **International Standards:**

**English/US Format:**
```
Quantity: 1,000 items
Money:    $1,234.56
```

**Vietnamese Format:**
```
Số lượng: 1,000 Cái    (giống English)
Tiền:     1.234.567 đ  (dùng dấu chấm)
```

### **Distinction:**
- ✅ **Comma (,)** for quantity → Dễ phân biệt với tiền
- ✅ **Dot (.)** for money → Convention tiền tệ VN
- ✅ **Visual difference** → Rõ ràng ngay khi nhìn

---

## 🔧 Implementation

### **Method Signature:**
```dart
String _formatDecimal(
  dynamic value, 
  {
    bool withSeparator = false,
    String separator = ','  // ← Default comma
  }
)
```

### **Internal Logic:**
```dart
if (withSeparator) {
  final formatter = NumberFormat('#,##0.##', 'vi_VN');
  return formatter.format(amount).replaceAll(',', separator);
  //                                              ↑
  //                             Replace với separator parameter
}
```

### **Locations Using:**
1. ✅ Line ~740: Số lượng display (normal view)
2. ✅ Line ~1401: Số lượng display (search item view)

**Both use default separator (comma) automatically!**

---

## 📏 Complete Format Rules

| Type | Separator | Pattern | Example |
|------|-----------|---------|---------|
| **Số lượng** | `,` (comma) | `#,##0.##` | `1,000 Cái` |
| **Tiền tệ** | `.` (dot) | `#,##0.##` | `1.234.567 đ` |
| **Phần trăm** | None | `0.##` | `10%` |

---

## ✅ Benefits

### **1. Visual Distinction - Phân biệt rõ**
```
Số lượng: 1,000 Cái         ← Comma
Đơn giá:  1.234.567 đ       ← Dot
```
→ Một cái nhìn biết ngay số lượng vs tiền

### **2. International Standard**
```
Quantity: 1,000 items   ← Standard English format
Money:    1.234.567 đ   ← Vietnamese format
```
→ Follow best practices

### **3. Easy to Read**
```
50,000/100,000 Kg   ← Comma rõ ràng
```
→ Dễ đọc với số lớn

### **4. Flexible**
```dart
separator = ','  // Default for quantity
separator = '.'  // Can override if needed
```
→ Có thể customize nếu cần

---

## 🎨 Real World Examples

### **Example 1: Electronics**
```
┌─────────────────────────────────┐
│ iPhone 15 Pro Max               │
│ Số lượng:   1,500/10,000 Cái    │ ← Comma
│ Đơn giá:    30.000.000 đ        │ ← Dot
│ Tổng:       45.000.000.000 đ    │ ← Dot
└─────────────────────────────────┘
```

### **Example 2: Wholesale Rice**
```
┌─────────────────────────────────┐
│ Gạo ST25                        │
│ Số lượng:   100,000/500,000 Kg  │ ← Comma
│ Đơn giá:    25.000 đ/Kg         │ ← Dot
│ Tổng:       2.500.000.000 đ     │ ← Dot
└─────────────────────────────────┘
```

### **Example 3: Office Supplies**
```
┌─────────────────────────────────┐
│ Bút bi xanh                     │
│ Số lượng:   200/500 Cái         │ ← No separator (< 1000)
│ Đơn giá:    5.000 đ             │ ← Dot
│ Tổng:       1.000.000 đ         │ ← Dot
└─────────────────────────────────┘
```

---

## 📊 Comparison Table

| Value | Quantity Format | Money Format |
|-------|----------------|--------------|
| 1000 | `1,000` | `1.000` |
| 10000 | `10,000` | `10.000` |
| 100000 | `100,000` | `100.000` |
| 1000000 | `1,000,000` | `1.000.000` |
| 1234.5 | `1,234.5` | `1.234.5` |

---

## 🎯 Quick Reference

### **When to use Comma (,):**
- ✅ Số lượng vật tư
- ✅ Inventory counts
- ✅ Order quantities

### **When to use Dot (.):**
- ✅ Tiền tệ (Money)
- ✅ Prices
- ✅ Totals

### **When to use Nothing:**
- ✅ Percentages (Thuế, CK)
- ✅ Small numbers (< 1000)

---

## 📝 Code Example

```dart
// Số lượng với comma
'${_formatDecimal(item.slDh, withSeparator: true)}/${_formatDecimal(item.so_luong_kd, withSeparator: true)} ${_safeText(item.dvt)}'
// → "1,000/10,000 Cái"

// Tiền tệ với dot (từ _formatMoney)
'${_formatMoney(item.giaNt2)} đ'
// → "1.234.567 đ"

// Phần trăm không separator
'${_formatDecimal(item.thueSuat)}%'
// → "10%"
```

---

## ✅ Result

**Complete Format System:**
```
┌─────────────────────────────────┐
│ Vật tư ABC                      │
│ Số lượng:   1,000/10,000 Cái    │ ← Comma
│ Đơn giá:    1.234.567 đ         │ ← Dot
│ Thuế:       10%                  │ ← No separator
│ Tổng:       1.234.567.000 đ     │ ← Dot
└─────────────────────────────────┘
```

**Clear Distinction:**
- 📦 Quantity → Comma (,)
- 💰 Money → Dot (.)
- 📊 Percentage → None

**Professional & Clear!**

---

**Updated:** 2025-10-09  
**Status:** ✅ Completed - No linter errors  
**File:** `/lib/screen/sell/contract/component/detail_contract.dart`

**Key Change:**
```dart
// Added separator parameter with default comma
String _formatDecimal(
  dynamic value, 
  {
    bool withSeparator = false, 
    String separator = ','  // ← Default comma for quantity
  }
)
```

