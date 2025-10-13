# 🧪 Test Separator Format

## Code hiện tại

### Method Definition (Line 430):
```dart
String _formatDecimal(dynamic value, {bool withSeparator = false, String separator = ','})
```
✅ Default separator = `','` (COMMA)

### Logic (Line 440, 444):
```dart
return formatter.format(amount).replaceAll(',', separator);
```
✅ Replace với separator parameter

### Usage (Line 740):
```dart
'${_formatDecimal(item.slDh, withSeparator: true)}/${_formatDecimal(item.so_luong_kd, withSeparator: true)} ${_safeText(item.dvt)}'
```
✅ Dùng `withSeparator: true` (sẽ dùng default separator = comma)

---

## Expected Output

### Test Case 1:
**Input:** `slDh = 1000`, `so_luong_kd = 10000`

**Code:**
```dart
_formatDecimal(1000, withSeparator: true)   // → "1,000"
_formatDecimal(10000, withSeparator: true)  // → "10,000"
```

**Expected Display:**
```
Số lượng: 1,000/10,000 Cái
```

### Test Case 2:
**Input:** `slDh = 100`, `so_luong_kd = 500`

**Code:**
```dart
_formatDecimal(100, withSeparator: true)   // → "100" (no separator needed)
_formatDecimal(500, withSeparator: true)   // → "500" (no separator needed)
```

**Expected Display:**
```
Số lượng: 100/500 Cái
```

### Test Case 3:
**Input:** `slDh = 1234.5`, `so_luong_kd = 10000`

**Code:**
```dart
_formatDecimal(1234.5, withSeparator: true)  // → "1,234.5"
_formatDecimal(10000, withSeparator: true)   // → "10,000"
```

**Expected Display:**
```
Số lượng: 1,234.5/10,000 Cái
```

---

## Comparison with Money

### Money Format (Line 411-427):
```dart
String _formatMoney(dynamic value) {
  ...
  return formatter.format(amount).replaceAll(',', '.');
  //                                              ↑
  //                                          HARDCODED DOT
}
```

**Expected:**
```
Đơn giá: 1.234.567 đ   (dấu chấm)
Tổng:    1.234.567 đ   (dấu chấm)
```

---

## Full Display Example

```
┌─────────────────────────────────┐
│ Vật tư ABC                      │
│ Số lượng:   1,000/10,000 Cái    │ ← COMMA
│ Đơn giá:    1.234.567 đ         │ ← DOT
│ Thuế:       10%                  │
│ Tổng:       1.234.567.000 đ     │ ← DOT
└─────────────────────────────────┘
```

---

## Troubleshooting

### Nếu vẫn thấy dấu chấm:

1. ✅ **HOT RESTART** app (không phải Hot Reload)
   - Press `Shift + R` hoặc restart app hoàn toàn

2. ✅ **Clear cache** nếu cần:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. ✅ **Kiểm tra đúng trường:**
   - Số lượng → Comma (,)
   - Tiền tệ → Dot (.)

4. ✅ **Check console logs:**
   - Xem có báo lỗi parse không

---

## Code is Correct ✅

**Confirmation:**
- ✅ Line 430: `separator = ','` (default comma)
- ✅ Line 440, 444: `.replaceAll(',', separator)`
- ✅ Line 740: `withSeparator: true` (uses default)
- ✅ Line 1401: `withSeparator: true` (uses default)

**Logic flow:**
```
_formatDecimal(1000, withSeparator: true)
  ↓
withSeparator = true
  ↓
separator = ',' (default)
  ↓
formatter.format(1000) = "1,000"
  ↓
replaceAll(',', ',') = "1,000"
  ↓
Return: "1,000" ✅
```

---

## Action Required

**PLEASE DO:**
1. **Hot Restart** app (Shift + R)
2. Check "Số lượng" field (not "Đơn giá")
3. Look for comma: `1,000 Cái`

**Expected Result:**
```
Số lượng:   1,000/10,000 Cái    ← COMMA
Đơn giá:    1.234.567 đ         ← DOT
```

