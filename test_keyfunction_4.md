# Test Case: KeyFunction #4 (Cập nhật pallet)

## **Mục tiêu:**
So sánh logic và UI của keyFunction #4 giữa DMS và SSE-Scanner để đảm bảo đồng nhất.

## **Test Steps:**

### **1. UI Test - Tab Structure**
- [ ] **DMS Expected:** 3 tabs: ['Sản phẩm', 'Lịch sử', 'Thông tin']
- [ ] **SSE-Scanner Expected:** 3 tabs: ['Sản phẩm', 'Lịch sử', 'Thông tin']
- [ ] **Status:** ✅ PASS - Đã đồng nhất

### **2. UI Test - TabBarView Logic**
- [ ] **DMS Expected:** 
  - Tab 0: buildListItem() (Sản phẩm)
  - Tab 1: buildListItemHistory() (Lịch sử)
  - Tab 2: buildInfo() (Thông tin)
- [ ] **SSE-Scanner Expected:** Tương tự
- [ ] **Status:** ✅ PASS - Đã đồng nhất

### **3. Logic Test - Barcode Processing (Đặc biệt)**
- [ ] **DMS Expected:**
  ```dart
  if (widget.keyFunction == '#4') {
    if (indexSelected >= 0 && indexSelected < listItemCard.length) {
      // Parse weight từ format provider
      if (widget.formatProvider.canYn == 1) {
        final canStart = widget.formatProvider.canTu?.toInt() ?? 0;
        final canEnd = widget.formatProvider.canDen?.toInt() ?? code.length;
        final weightStr = code.substring(canStart, canEnd);
        final weight = double.parse(weightStr);
        kg = NumberFormat(widget.formatProvider.soThapPhan.toString()).format(weight);
      }
      
      // Parse expiration date từ format provider
      if (widget.formatProvider.hsdYn == 1) {
        final hsdStart = widget.formatProvider.hsdTu?.toInt() ?? 0;
        final hsdEnd = widget.formatProvider.hsdDen?.toInt() ?? code.length;
        expirationDate = code.substring(hsdStart, hsdEnd);
      }
      
      // Gọi addListHistory trực tiếp
      addListHistory(code, double.parse(kg), double.parse(kg), 
                    expirationDate, '', false, '', '');
    }
  }
  ```
- [ ] **SSE-Scanner Expected:** Tương tự logic với format provider
- [ ] **Status:** ✅ PASS - Đã đồng nhất

### **4. Logic Test - History Loading**
- [ ] **DMS Expected:** Load history data khi initState
- [ ] **SSE-Scanner Expected:** Tương tự
- [ ] **Status:** ✅ PASS - Đã đồng nhất

### **5. Logic Test - Action Values**
- [ ] **DMS Expected:** 
  - Cập nhật pallet: action = 1
  - Xác nhận: action = 2
- [ ] **SSE-Scanner Expected:** Tương tự
- [ ] **Status:** ✅ PASS - Đã đồng nhất

### **6. UI Test - Button Actions**
- [ ] **DMS Expected:**
  - Button 1: "Cập nhật pallet" → action = 1
  - Button 2: "Xác nhận" → action = 2
- [ ] **SSE-Scanner Expected:** Tương tự
- [ ] **Status:** ✅ PASS - Đã đồng nhất

### **7. Logic Test - Data Sources**
- [ ] **DMS Expected:**
  - _listItem: từ _bloc.listItemHistory
  - _listConfirm: từ _bloc.listItemCard
- [ ] **SSE-Scanner Expected:** Tương tự
- [ ] **Status:** ✅ PASS - Đã đồng nhất

### **8. Logic Test - Format Provider Integration**
- [ ] **DMS Expected:** 
  - Sử dụng formatProvider.canYn để parse weight
  - Sử dụng formatProvider.hsdYn để parse expiration date
  - Gọi addListHistory trực tiếp thay vì API
- [ ] **SSE-Scanner Expected:** Tương tự
- [ ] **Status:** ✅ PASS - Đã đồng nhất

### **9. Logic Test - Product Selection Requirement**
- [ ] **DMS Expected:** Yêu cầu chọn sản phẩm trước khi quét barcode
- [ ] **SSE-Scanner Expected:** Tương tự
- [ ] **Status:** ✅ PASS - Đã đồng nhất

## **Kết quả tổng thể:**
- **UI Consistency:** ✅ PASS
- **Logic Consistency:** ✅ PASS
- **Action Values:** ✅ PASS
- **Tab Structure:** ✅ PASS
- **Button Actions:** ✅ PASS
- **Data Sources:** ✅ PASS
- **Format Provider:** ✅ PASS
- **Product Selection:** ✅ PASS

## **Kết luận:**
KeyFunction #4 đã hoàn toàn đồng nhất giữa DMS và SSE-Scanner.

## **Các điểm cần lưu ý:**
1. ✅ Tab structure: 3 tabs với đúng thứ tự
2. ✅ Barcode processing: Logic đặc biệt với format provider
3. ✅ Action values: 1 cho cập nhật, 2 cho xác nhận
4. ✅ Data sources: Đúng nguồn dữ liệu theo SSE-Scanner
5. ✅ History loading: Load khi initState
6. ✅ Button text: "Cập nhật pallet" cho keyFunction #4
7. ✅ Format provider: Parse weight và expiration date
8. ✅ Product selection: Yêu cầu chọn sản phẩm trước
9. ✅ Direct history: Gọi addListHistory trực tiếp

## **Khuyến nghị:**
KeyFunction #4 đã sẵn sàng cho production, không cần thay đổi thêm.
