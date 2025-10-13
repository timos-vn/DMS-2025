# 🔢 Smart Decimal Format - Chỉ hiển thị khi cần

## 📋 Yêu cầu mới

1. ✅ **Chỉ hiển thị thập phân khi có giá trị** (không phải .00)
2. ✅ **Bỏ trường Chiết khấu** trong danh sách vật tư

---

## 🎯 Logic mới - Smart Format

### **Rule: Hiển thị thập phân chỉ khi cần thiết**

```
10.00    → 10       (bỏ .00)
10.50    → 10.5     (giữ .5)
10.123   → 10.12    (làm tròn 2 chữ số)
1000.00  → 1.000    (ngăn cách nghìn, không .00)
1234.56  → 1.234.56 (ngăn cách nghìn + thập phân)
```

---

## 🔧 Implementation

### **1. `_formatMoney()` - Smart Money Format**

```dart
String _formatMoney(dynamic value) {
  if (value == null) return '0';
  try {
    double amount = double.parse(value.toString());
    
    // Nếu là số nguyên → không hiển thị .0
    if (amount == amount.roundToDouble()) {
      final formatter = NumberFormat('#,##0', 'vi_VN');
      return formatter.format(amount).replaceAll(',', '.');
    }
    
    // Nếu có thập phân → hiển thị (tối đa 2 chữ số)
    final formatter = NumberFormat('#,##0.##', 'vi_VN');
    return formatter.format(amount).replaceAll(',', '.');
  } catch (e) {
    return '0';
  }
}
```

**Features:**
- ✅ Số nguyên: `1.000` (không .0)
- ✅ Có thập phân: `1.000.5` hoặc `1.000.50`
- ✅ Dấu chấm ngăn cách nghìn
- ✅ Tối đa 2 chữ số thập phân

### **2. `_formatDecimal()` - Smart Decimal Format**

```dart
String _formatDecimal(dynamic value) {
  if (value == null) return '0';
  try {
    double amount = double.parse(value.toString());
    
    // Nếu là số nguyên → trả về int
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    
    // Nếu có thập phân → format và loại bỏ số 0 thừa
    String result = amount.toStringAsFixed(2);
    result = result.replaceAll(RegExp(r'0*$'), '');  // Xóa 0 cuối
    result = result.replaceAll(RegExp(r'\.$'), '');  // Xóa dấu . nếu là số nguyên
    return result;
  } catch (e) {
    return '0';
  }
}
```

**Features:**
- ✅ Số nguyên: `10` (không .0)
- ✅ Có thập phân: `10.5` (không padding 0)
- ✅ Không có dấu ngăn cách
- ✅ Tối đa 2 chữ số thập phân

---

## 📊 Examples

### **Money Format:**

| Input | Output | Reason |
|-------|--------|--------|
| 1000 | `1.000 đ` | Số nguyên, có separator |
| 1000.00 | `1.000 đ` | Bỏ .00 |
| 1000.5 | `1.000.5 đ` | Giữ .5 |
| 1234.56 | `1.234.56 đ` | Giữ .56 |
| 10.123 | `10.12 đ` | Làm tròn 2 chữ số |

### **Decimal Format:**

| Input | Output | Reason |
|-------|--------|--------|
| 10 | `10` | Số nguyên |
| 10.00 | `10` | Bỏ .00 |
| 10.5 | `10.5` | Giữ .5 |
| 10.50 | `10.5` | Bỏ 0 cuối |
| 10.123 | `10.12` | Làm tròn 2 chữ số |

---

## 🎨 So sánh Before → After

### **Material Card Example:**

**OLD (Fixed .00):**
```
┌─────────────────────────────────┐
│ Đơn giá:    1.234.567.00 đ      │
│ Số lượng:   10.00 Cái           │
│ Chiết khấu: 5.00%                │
│ Thuế:       10.00%               │
│ Tổng:       1.234.567.00 đ      │
└─────────────────────────────────┘
```

**NEW (Smart):**
```
┌─────────────────────────────────┐
│ Đơn giá:    1.234.567 đ         │
│ Số lượng:   10 Cái              │
│ Thuế:       10%                  │
│ Tổng:       1.234.567 đ         │
└─────────────────────────────────┘
```

**Changes:**
1. ✅ `1.234.567.00` → `1.234.567` (bỏ .00)
2. ✅ `10.00` → `10` (bỏ .00)
3. ❌ Chiết khấu - **Đã bỏ**
4. ✅ `10.00%` → `10%` (bỏ .00)

### **With Decimals Example:**

**Input có thập phân:**
```
┌─────────────────────────────────┐
│ Đơn giá:    1.234.567.5 đ       │
│ Số lượng:   10.5 Cái            │
│ Thuế:       10.5%                │
│ Tổng:       1.358.024.13 đ      │
└─────────────────────────────────┘
```

**Features:**
- ✅ Giữ `.5` vì có giá trị
- ✅ Không padding thành `.50`
- ✅ Clean và gọn

---

## 🎯 Đã bỏ: Chiết khấu

### **Before:**
```dart
// Chiết khấu (nếu có)
if (_safeText(item.tlCk) != '---' && item.tlCk.toString().isNotEmpty) ...[
  const SizedBox(height: 8),
  _buildCompactDetailRow(
    icon: Icons.local_offer_outlined,
    label: 'Chiết khấu',
    value: '${_formatDecimal(item.tlCk)}%',
    iconColor: Colors.pink,
  ),
],
```

### **After:**
```dart
// Đã bỏ - không dùng
```

**Reason:** Hiện tại không dùng tới chiết khấu

---

## 📏 Format Rules (Updated)

### **Rule 1: Money (Tiền tệ)**
```
Pattern:  #,##0.##  (không force .00)
Examples:
  10       → 10 đ
  10.5     → 10.5 đ
  10.50    → 10.5 đ
  1000     → 1.000 đ
  1234.56  → 1.234.56 đ
```

### **Rule 2: Decimal (Số lượng, %)** 
```
Pattern:  0.##  (không force .00)
Examples:
  10       → 10
  10.5     → 10.5
  10.50    → 10.5
  5        → 5%
  5.5      → 5.5%
```

---

## ✅ Benefits (Updated)

### **1. Cleaner Display**
- ✅ Không hiển thị `.00` thừa
- ✅ Chỉ hiển thị thập phân khi cần
- ✅ Gọn gàng hơn

### **2. Natural Reading**
- ✅ `10 Cái` thay vì `10.00 Cái`
- ✅ `5%` thay vì `5.00%`
- ✅ Dễ đọc hơn

### **3. Smart Logic**
- ✅ Tự động detect số nguyên vs thập phân
- ✅ Loại bỏ số 0 thừa
- ✅ Professional

### **4. Less Clutter**
- ✅ Bỏ trường Chiết khấu không dùng
- ✅ Ít thông tin thừa
- ✅ Focus vào thông tin quan trọng

---

## 📊 Comparison Table

| Type | Old Format | New Format | Better? |
|------|-----------|-----------|---------|
| Integer money | 1.000.00 đ | 1.000 đ | ✅ Cleaner |
| Decimal money | 1.000.50 đ | 1.000.5 đ | ✅ Natural |
| Integer qty | 10.00 Cái | 10 Cái | ✅ Cleaner |
| Decimal qty | 10.50 Cái | 10.5 Cái | ✅ Natural |
| Integer % | 5.00% | 5% | ✅ Cleaner |
| Decimal % | 5.50% | 5.5% | ✅ Natural |

---

## 🔧 Technical Details

### **RegEx Used:**
```dart
RegExp(r'0*$')   // Xóa số 0 ở cuối: "10.50" → "10.5"
RegExp(r'\.$')   // Xóa dấu . thừa: "10." → "10"
```

### **NumberFormat Patterns:**
```dart
'#,##0'      // Integer với separator: 1,000
'#,##0.##'   // Decimal với separator: 1,000.5
```

### **Replacements:**
```dart
.replaceAll(',', '.')  // VN style: 1.000 thay vì 1,000
```

---

## 📍 Locations Updated

### **File:** `detail_contract.dart`

**Updated:**
1. ✅ Line ~411-447: `_formatMoney()` và `_formatDecimal()` methods
2. ✅ Line ~738: Đơn giá
3. ✅ Line ~747: Thuế suất
4. ✅ Line ~726: Số lượng
5. ✅ Line ~769: Tổng card
6. ✅ Line ~903: Tổng thanh toán
7. ✅ Line ~947: Total items
8. ✅ Line ~1378: Quantity display

**Removed:**
1. ❌ Chiết khấu section (lines ~728-736)

---

## 🎯 Key Changes Summary

### **1. Format Logic:**
```
Before: Always show .00
After:  Only show decimals when needed
```

### **2. Display Fields:**
```
Before: Kho, Số lượng, Đơn giá, CK, Thuế, Tổng
After:  Kho, Số lượng, Đơn giá, Thuế, Tổng (no CK)
```

### **3. Examples:**
```
10.00 → 10     (cleaner)
10.50 → 10.5   (natural, không padding)
5.00% → 5%     (cleaner)
```

---

## 📝 Visual Examples

### **Scenario 1: All Integers**
```
┌─────────────────────────────┐
│ Số lượng:   10 Cái          │
│ Đơn giá:    1.000 đ         │
│ Thuế:       10%              │
│ Tổng:       11.000 đ        │
└─────────────────────────────┘
```

### **Scenario 2: Mixed Decimals**
```
┌─────────────────────────────┐
│ Số lượng:   10.5 Cái        │
│ Đơn giá:    1.234.5 đ       │
│ Thuế:       10.5%            │
│ Tổng:       14.300.81 đ     │
└─────────────────────────────┘
```

### **Scenario 3: Complex Decimals**
```
┌─────────────────────────────┐
│ Số lượng:   100.25 Cái      │
│ Đơn giá:    999.99 đ        │
│ Thuế:       8.5%             │
│ Tổng:       108.674.11 đ    │
└─────────────────────────────┘
```

---

## ✅ Result

**Smart Format:**
- ✅ Natural reading
- ✅ Clean display
- ✅ No unnecessary .00
- ✅ Shows decimals only when needed
- ✅ Less clutter (no CK field)
- ✅ Professional appearance

**Perfect Balance:**
- 📌 Precision when needed
- 🎯 Simplicity when possible
- ✨ Clean & professional

---

**Updated:** 2025-10-09  
**Status:** ✅ Completed - No linter errors  
**File:** `/lib/screen/sell/contract/component/detail_contract.dart`

