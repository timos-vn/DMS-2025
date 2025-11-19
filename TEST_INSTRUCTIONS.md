# 🧪 **TEST INSTRUCTIONS - Debug Giá Tăng & Gifts Duplicate**

## 🎯 **Mục Tiêu**

Tìm nguyên nhân:
1. Giá TĂNG khi apply CKG (3.04M → 10.94M)
2. Gifts tự động tăng

---

## 📋 **Test Steps**

### **Chuẩn Bị:**
```bash
flutter run
```

### **Test 1: Check CKG - Debug Giá Tăng**

**Steps:**
1. **Xóa hết** sản phẩm trong giỏ (nếu có)
2. **Thêm 1 sản phẩm:**
   - Tên: (tên sản phẩm của bạn)
   - Giá: 3.040.000đ
   - Số lượng: 1
3. **Click 🎁** (mở voucher sheet)
4. **Check CKG** (chiết khấu 10%)
5. **XEM CONSOLE** và copy TẤT CẢ logs

**Expected Logs:**
```
💰 Added CKG to listCKVT: A000000018-MANIT10
💰 Force UI rebuild
💰 Calling API to apply new discounts
💰 === Calling API with parameters ===
💰 listCKVT: A000000018-MANIT10
💰 listItem: MANIT10  ← 1 item
💰 listQty: 1  ← Số lượng 1
💰 listPrice: 3040000  ← Giá gốc
💰 listMoney: 3040000  ← Tiền = giá * số lượng
💰 Called GetListItemApplyDiscountEvent
--- (wait for API) ---
💰 === API Response Received (keyLoad=Second) ===
💰 Product: MANIT10, giaSuaDoi=?, priceAfter=?, discountPercent=?
```

**GỬI CHO TÔI:**
- ✅ giaSuaDoi = ? (nên là 3.040.000)
- ✅ priceAfter = ? (nên là 2.736.000)
- ✅ discountPercent = ? (nên là 10.0)
- ✅ listItem = ? (nên là "MANIT10")
- ✅ listPrice = ? (nên là "3040000")

---

### **Test 2: HH Gifts Duplicate**

**Steps:**
1. Sau khi check CKG (từ test 1)
2. **XEM CONSOLE** tìm logs HH:

```
💰 Applying 2 HH gifts - START totalProductGift=?
💰 Removed ? old HH gifts
💰 Added HH gift: PS-BITE x1
💰 Added HH gift: PS-PUTTY x1
💰 HH gifts complete - Added 2 items, END totalProductGift=?
```

**Expected:**
- START totalProductGift = 0 (hoặc số cũ)
- Removed = số cũ (0 nếu lần đầu)
- Added = 2
- END totalProductGift = 2

**If WRONG:**
- START = 2, END = 4 → Duplicate! ❌
- START = 4, END = 6 → Gọi nhiều lần! ❌

**GỬI CHO TÔI:**
- ✅ START totalProductGift = ?
- ✅ END totalProductGift = ?
- ✅ _applyAllHH được gọi mấy lần?

---

## 🔍 **Additional Debug - Backend Response**

### **Kiểm tra raw response từ backend:**

Tìm trong logs file `network_factory.dart`:
```
📤 Request URL: /api/apply-discount
📤 Request Data: {...}
📥 Response Data: {
  "list_ck": [
    {
      "kieu_ck": "CKG",
      "ma_vt": "MANIT10",
      "tl_ck": 10.0,
      "gia_goc": ?,  ← CHECK
      "gia_sau_ck": ?,  ← CHECK
      "ck": ?,
      "ck_nt": ?
    }
  ]
}
```

**GỬI CHO TÔI backend response JSON nếu thấy!**

---

## 🎯 **What I Need**

### **Minimum info:**
```
1. Console logs khi check CKG
2. Giá trị: giaSuaDoi, priceAfter, discountPercent
3. HH gifts: START/END totalProductGift
```

### **Bonus (if possible):**
```
4. Request parameters (listItem, listPrice, ...)
5. Backend response JSON
6. listOrder.length before/after API
```

---

## 🚀 **Sau Khi Có Logs**

Tôi sẽ:
1. Phân tích logs
2. Tìm root cause
3. Fix chính xác vấn đề
4. Test lại

---

**📝 RUN TEST VÀ GỬI LOGS CHO TÔI NGAY! 🔥**

