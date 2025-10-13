# Test Cases - Popup Update Quantity Contract

## 📋 Thông tin Test
- **File**: `lib/screen/sell/contract/component/popup_update_quantity_contract.dart`
- **Feature**: Dialog cập nhật số lượng sản phẩm trong hợp đồng
- **Tester**: [Tên người test]
- **Date**: [Ngày test]

---

## 🎯 Test Setup
### Điều kiện ban đầu (Precondition)
- Có sản phẩm với:
  - `maVt2`: "SP001"
  - `productName`: "Sản phẩm Test"
  - `currentQuantity`: 100
  - `availableQuantity`: 1000

---

## 📝 Test Cases

### **TC01: Nhập số lượng hợp lệ (Valid Input)**
| ID | Test Case | Input | Expected Result | Status | Note |
|----|-----------|-------|-----------------|--------|------|
| TC01-01 | Nhập số dương nhỏ hơn availableQuantity | 500 | ✅ Hiển thị "500", errorText = null, isValid = true, nút Xác nhận enabled | ⬜ |  |
| TC01-02 | Nhập số = availableQuantity | 1000 | ✅ Hiển thị "1,000", errorText = null, isValid = true, nút Xác nhận enabled | ⬜ |  |
| TC01-03 | Nhập số = 1 (minimum valid) | 1 | ✅ Hiển thị "1", errorText = null, isValid = true, nút Xác nhận enabled | ⬜ |  |
| TC01-04 | Nhập số lớn với format | 12345 | ✅ Tự động format thành "12,345", isValid = true | ⬜ |  |
| TC01-05 | Nhập số rất lớn nhưng <= availableQuantity | 999 | ✅ Hiển thị "999", isValid = true | ⬜ |  |

---

### **TC02: Nhập số không hợp lệ (Invalid Input)**
| ID | Test Case | Input | Expected Result | Status | Note |
|----|-----------|-------|-----------------|--------|------|
| TC02-01 | Nhập số = 0 | 0 | ❌ errorText = "Số lượng phải lớn hơn 0", isValid = false, nút Xác nhận disabled | ⬜ |  |
| TC02-02 | Nhập số âm | -5 | ❌ Không cho phép nhập (FilteringTextInputFormatter.digitsOnly) | ⬜ | Chỉ accept số dương |
| TC02-03 | Nhập số > availableQuantity | 1500 | ❌ errorText = "Vượt quá số lượng khả dụng (1,000)", isValid = false | ⬜ |  |
| TC02-04 | Nhập số lớn hơn availableQuantity rất nhiều | 999999 | ❌ errorText = "Vượt quá số lượng khả dụng (1,000)", isValid = false | ⬜ |  |

---

### **TC03: Nhập ký tự đặc biệt và chữ**
| ID | Test Case | Input | Expected Result | Status | Note |
|----|-----------|-------|-----------------|--------|------|
| TC03-01 | Nhập chữ cái | abc | ❌ Không cho phép nhập, TextField trống | ⬜ | digitsOnly filter |
| TC03-02 | Nhập ký tự đặc biệt | !@#$% | ❌ Không cho phép nhập, TextField trống | ⬜ | digitsOnly filter |
| TC03-03 | Nhập dấu phẩy thủ công | 1,2,3 | ✅ Auto remove commas, chỉ giữ "123" và format lại thành "123" | ⬜ | Formatter xử lý |
| TC03-04 | Nhập dấu chấm | 123.45 | ❌ Không cho phép nhập dấu chấm | ⬜ | digitsOnly filter |
| TC03-05 | Nhập khoảng trắng | "1 2 3" | ❌ Không cho phép, chỉ hiển thị "123" | ⬜ | digitsOnly filter |
| TC03-06 | Copy-paste text có chữ | "abc123def" | ✅ Chỉ giữ lại số "123" | ⬜ | Formatter xử lý |

---

### **TC04: Xóa và để trống (Empty Input)**
| ID | Test Case | Input | Expected Result | Status | Note |
|----|-----------|-------|-----------------|--------|------|
| TC04-01 | Xóa hết text để trống | "" (empty) | ❌ errorText = "Vui lòng nhập số lượng", isValid = false | ⬜ |  |
| TC04-02 | Nhập số rồi xóa từng ký tự | "123" → "" | ❌ Khi còn "", errorText hiện, nút disabled | ⬜ |  |

---

### **TC05: Auto-format với ThousandsSeparatorInputFormatter**
| ID | Test Case | Input | Display | Expected Format | Status | Note |
|----|-----------|-------|---------|-----------------|--------|------|
| TC05-01 | Nhập 4 chữ số | 1234 | 1,234 | ✅ Format đúng với dấu phẩy | ⬜ |  |
| TC05-02 | Nhập 5 chữ số | 12345 | 12,345 | ✅ Format đúng | ⬜ |  |
| TC05-03 | Nhập 6 chữ số | 123456 | 123,456 | ✅ Format đúng | ⬜ |  |
| TC05-04 | Nhập 7 chữ số | 1234567 | 1,234,567 | ✅ Format đúng | ⬜ |  |
| TC05-05 | Nhập 1-3 chữ số | 123 | 123 | ✅ Không có dấu phẩy (< 1000) | ⬜ |  |
| TC05-06 | Nhập từng ký tự 1→12→123→1234 | 1,2,3,4 | 1,234 | ✅ Format realtime khi gõ | ⬜ |  |

---

### **TC06: Nút Plus/Minus (+/-)**
| ID | Test Case | Action | Initial Value | Expected Result | Status | Note |
|----|-----------|--------|---------------|-----------------|--------|------|
| TC06-01 | Click nút "+" khi value = 100 | Click + | 100 | ✅ Tăng lên 101 | ⬜ |  |
| TC06-02 | Click nút "+" nhiều lần | Click + x5 | 100 | ✅ Tăng lên 105 | ⬜ |  |
| TC06-03 | Click nút "+" khi = availableQuantity-1 | Click + | 999 | ✅ Tăng lên 1000, không tăng thêm nữa | ⬜ | Max limit |
| TC06-04 | Click nút "+" khi = availableQuantity | Click + | 1000 | ❌ Không tăng thêm | ⬜ | Max limit |
| TC06-05 | Click nút "-" khi value = 100 | Click - | 100 | ✅ Giảm xuống 99 | ⬜ |  |
| TC06-06 | Click nút "-" nhiều lần | Click - x5 | 100 | ✅ Giảm xuống 95 | ⬜ |  |
| TC06-07 | Click nút "-" khi = 2 | Click - | 2 | ✅ Giảm xuống 1, không giảm thêm nữa | ⬜ | Min limit |
| TC06-08 | Click nút "-" khi = 1 | Click - | 1 | ❌ Không giảm thêm (min = 1) | ⬜ | Min limit |
| TC06-09 | Click +/- khi có text format | Click +/- | "1,234" | ✅ Parse đúng, tăng/giảm, format lại | ⬜ | Remove commas |

---

### **TC07: Cursor Position sau khi format**
| ID | Test Case | Input | Expected Cursor Position | Status | Note |
|----|-----------|-------|--------------------------|--------|------|
| TC07-01 | Nhập "1234" | 1234 | Cursor ở cuối "1,234│" | ⬜ | Cursor tự động nhảy về cuối |
| TC07-02 | Nhập từng ký tự | 1→2→3→4 | Cursor luôn ở cuối sau mỗi lần format | ⬜ |  |

---

### **TC08: Validation Realtime**
| ID | Test Case | Sequence | Expected Behavior | Status | Note |
|----|-----------|----------|-------------------|--------|------|
| TC08-01 | Nhập từ valid → invalid | "100" → "2000" | ✅→❌ isValid thay đổi realtime, nút disabled ngay | ⬜ |  |
| TC08-02 | Nhập từ invalid → valid | "2000" → "500" | ❌→✅ Error text biến mất, nút enabled ngay | ⬜ |  |
| TC08-03 | Xóa từ valid → empty | "100" → "" | ✅→❌ Error "Vui lòng nhập số lượng" | ⬜ |  |

---

### **TC09: Progress Bar (khi không có keyboard)**
| ID | Test Case | Input | Expected Progress Bar | Status | Note |
|----|-----------|-------|----------------------|--------|------|
| TC09-01 | Nhập 500 (50% của 1000) | 500 | ✅ Progress = 50%, hiển thị "500 / 1,000" | ⬜ |  |
| TC09-02 | Nhập 1000 (100%) | 1000 | ✅ Progress = 100%, hiển thị "1,000 / 1,000" | ⬜ |  |
| TC09-03 | Nhập 250 (25%) | 250 | ✅ Progress = 25%, hiển thị "250 / 1,000" | ⬜ |  |
| TC09-04 | Progress bar khi keyboard hiện | Focus TextField | ❌ Progress bar ẩn đi (isKeyboardVisible = true) | ⬜ | Responsive |

---

### **TC10: Nút Xác nhận (Confirm Button)**
| ID | Test Case | Condition | Expected Behavior | Status | Note |
|----|-----------|-----------|-------------------|--------|------|
| TC10-01 | Click Xác nhận khi valid | value = 500, valid | ✅ Dialog đóng, callback onConfirmed(500) được gọi | ⬜ |  |
| TC10-02 | Click Xác nhận khi invalid | value = 2000, invalid | ❌ Nút disabled, không thể click | ⬜ |  |
| TC10-03 | Click Xác nhận khi empty | value = "", invalid | ❌ Nút disabled, không thể click | ⬜ |  |
| TC10-04 | Click Xác nhận với text có comma | value = "1,234" | ✅ Parse thành 1234, callback onConfirmed(1234) | ⬜ | Remove commas |

---

### **TC11: Nút Hủy (Cancel Button)**
| ID | Test Case | Action | Expected Behavior | Status | Note |
|----|-----------|--------|-------------------|--------|------|
| TC11-01 | Click nút Hủy | Click Cancel | ✅ Dialog đóng, không gọi callback | ⬜ |  |
| TC11-02 | Click outside dialog | Click backdrop | ✅ Dialog đóng (barrierDismissible = true) | ⬜ |  |

---

### **TC12: Auto-focus và Select Text**
| ID | Test Case | Action | Expected Behavior | Status | Note |
|----|-----------|--------|-------------------|--------|------|
| TC12-01 | Mở dialog với currentQuantity > 0 | Open dialog | ✅ TextField auto-focus, text được select all | ⬜ |  |
| TC12-02 | Mở dialog với currentQuantity = 0 | Open dialog | ✅ TextField auto-focus, trống | ⬜ |  |
| TC12-03 | Gõ phím ngay sau khi mở | Type "123" | ✅ Replace text cũ, hiển thị "123" | ⬜ |  |

---

### **TC13: Responsive với Keyboard**
| ID | Test Case | Action | Expected Behavior | Status | Note |
|----|-----------|--------|-------------------|--------|------|
| TC13-01 | Focus vào TextField (keyboard hiện) | Focus | ✅ Dialog thu gọn: padding giảm, icon nhỏ hơn, progress bar ẩn | ⬜ |  |
| TC13-02 | Unfocus (keyboard ẩn) | Unfocus | ✅ Dialog expand: padding tăng, icon lớn hơn, progress bar hiện | ⬜ |  |

---

### **TC14: UI Display**
| ID | Test Case | Expected Display | Status | Note |
|----|-----------|------------------|--------|------|
| TC14-01 | Hiển thị thông tin sản phẩm | ✅ Mã vật tư "SP001" và tên "Sản phẩm Test" hiển thị đúng | ⬜ |  |
| TC14-02 | Hiển thị số lượng khả dụng | ✅ "Tối đa có thể đặt: 1,000" với format dấu phẩy | ⬜ |  |
| TC14-03 | Gradient colors | ✅ mainColor và subColor hiển thị đúng | ⬜ |  |
| TC14-04 | Icons | ✅ Tất cả icons hiển thị đúng (edit_note, inventory, check_circle, +/-) | ⬜ |  |

---

### **TC15: Edge Cases**
| ID | Test Case | Input/Action | Expected Result | Status | Note |
|----|-----------|--------------|-----------------|--------|------|
| TC15-01 | availableQuantity = 0 | Open dialog | ⚠️ Không thể nhập gì, mọi input đều invalid | ⬜ | Edge case |
| TC15-02 | availableQuantity = 1 | Open dialog | ✅ Chỉ có thể nhập "1", nút - disabled | ⬜ | Min = Max |
| TC15-03 | currentQuantity > availableQuantity | current=1500, available=1000 | ⚠️ Initial invalid, errorText hiện ngay | ⬜ | Data inconsistency |
| TC15-04 | Nhập số rất lớn (>999,999,999) | 9999999999 | ❌ Invalid nếu > availableQuantity | ⬜ |  |
| TC15-05 | Rotate device (responsive) | Rotate | ✅ Dialog vẫn hiển thị đúng, responsive | ⬜ |  |
| TC15-06 | productName = null | Open dialog | ✅ Chỉ hiển thị mã vật tư, không crash | ⬜ |  |
| TC15-07 | productName rất dài | "Sản phẩm có tên dài hơn 100 ký tự..." | ✅ Text ellipsis sau 2 dòng | ⬜ | maxLines: 2 |

---

## 📊 Test Summary

| Category | Total | Passed | Failed | Pending |
|----------|-------|--------|--------|---------|
| TC01: Valid Input | 5 | - | - | 5 |
| TC02: Invalid Input | 4 | - | - | 4 |
| TC03: Special Chars | 6 | - | - | 6 |
| TC04: Empty Input | 2 | - | - | 2 |
| TC05: Auto Format | 6 | - | - | 6 |
| TC06: Plus/Minus | 9 | - | - | 9 |
| TC07: Cursor Position | 2 | - | - | 2 |
| TC08: Validation | 3 | - | - | 3 |
| TC09: Progress Bar | 4 | - | - | 4 |
| TC10: Confirm Button | 4 | - | - | 4 |
| TC11: Cancel Button | 2 | - | - | 2 |
| TC12: Auto Focus | 3 | - | - | 3 |
| TC13: Responsive | 2 | - | - | 2 |
| TC14: UI Display | 4 | - | - | 4 |
| TC15: Edge Cases | 7 | - | - | 7 |
| **TOTAL** | **63** | **0** | **0** | **63** |

---

## 🐛 Bugs Found
| Bug ID | Test Case | Description | Severity | Status |
|--------|-----------|-------------|----------|--------|
| - | - | - | - | - |

---

## 📝 Notes
- Test trên cả iOS và Android
- Test với nhiều kích thước màn hình khác nhau
- Test với nhiều availableQuantity khác nhau (nhỏ, vừa, lớn)
- Kiểm tra memory leak khi mở/đóng dialog nhiều lần

---

## ✅ Sign-off
- [ ] All test cases executed
- [ ] All critical bugs fixed
- [ ] Performance acceptable
- [ ] Ready for production

**Tester**: ________________  
**Date**: ________________  
**Signature**: ________________

