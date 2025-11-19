# 🎁 Hệ Thống Chiết Khấu Đa Loại - Hướng Dẫn

## 📋 Tổng Quan

Hệ thống hỗ trợ **3 loại chiết khấu** có thể áp dụng đồng thời cho một đơn hàng:

| Loại | Mã | Mô tả | Cách hoạt động | User Action |
|------|-----|-------|----------------|-------------|
| **Chiết khấu nhóm** | `CKN` | Cho phép chọn sản phẩm tặng từ nhóm | User chọn sản phẩm tặng từ danh sách | ✅ **Chọn thủ công** |
| **Chiết khấu giá** | `CKG` | Giảm giá trực tiếp cho **sản phẩm gốc** | Backend tự động áp dụng khi tính toán | 🤖 **Tự động** (Info only) |
| **Hàng hóa tặng** | `HH` | Tặng hàng cố định kèm **sản phẩm gốc** | Backend tự động thêm vào `listDiscountProduct` | 🤖 **Tự động** (Info only) |

### ⚠️ **LƯU Ý QUAN TRỌNG:**

- **CKN**: User CẦN chọn thủ công sản phẩm tặng → UI cho phép tương tác
- **CKG & HH**: Backend ĐÃ tự động xử lý trong `_handleCalculator()` → UI CHỈ hiển thị thông tin

---

## 🎯 Tính Năng

### ✅ **Đã Triển Khai**

1. **UI Mới - Tabbed Dialog**
   - Hiển thị tất cả loại chiết khấu trong 1 dialog
   - Tab riêng cho mỗi loại (CKN, CKG, HH)
   - Hiển thị số lượng chiết khấu khả dụng
   - Icon và màu sắc riêng cho mỗi loại

2. **Logic Xử Lý Riêng Biệt**
   - **CKN**: Flow 2 bước (chọn nhóm → chọn sản phẩm)
   - **CKG**: Tự động áp dụng (backend đã tính)
   - **HH**: Tự động thêm sản phẩm tặng cố định

3. **Không Duplicate**
   - Mỗi loại chiết khấu tách biệt bằng `typeCK`
   - Xóa sạch sản phẩm cũ trước khi thêm mới
   - Hỗ trợ chọn lại và cập nhật

4. **State Management**
   - Track từng loại chiết khấu đã chọn
   - Clear tất cả khi tạo đơn mới
   - Persistent selections khi edit order

---

## 📂 Cấu Trúc Code

### **Files Mới Tạo**

```
lib/screen/sell/cart/widgets/
└── discount_type_selection_dialog.dart  # Main discount selection UI
```

### **Files Đã Cập Nhật**

```
lib/screen/sell/cart/
├── cart_bloc.dart          # Thêm listCkg, listHH, state management
├── cart_screen.dart        # Thêm handlers cho CKG và HH
└── cart_event.dart         # (không thay đổi)

lib/model/network/response/
└── apply_discount_response.dart  # ListCkMatHang structure
```

---

## 🔧 Cách Sử Dụng

### **1. User Flow**

```
1. User thêm sản phẩm vào giỏ
   ↓
2. Backend tính toán chiết khấu và tự động áp dụng:
   • CKG → Giảm giá cho sản phẩm gốc (itemOrder.typeCK = 'CKG')
   • HH → Thêm hàng tặng vào listDiscountProduct
   • CKN → Trả về danh sách nhóm để user chọn
   ↓
3. Nếu có chiết khấu → Hiển thị icon 🎁
   ↓
4. User click icon:
   • Nếu CÓ CKN → Mở dialog chọn sản phẩm tặng
   • Nếu KHÔNG CÓ CKN → Hiển thị info về CKG/HH đã áp dụng
   ↓
5. CKN: User chọn nhóm → Chọn sản phẩm tặng
   ↓
6. Hoàn tất!
   
✅ CKG và HH: Đã được backend tự động xử lý, không cần user làm gì!
```

### **2. Code Flow**

#### **Khi Backend Trả Về Response:**

```dart
// cart_bloc.dart - _handleCalculator()
if(keyLoad == 'First' && response.listCkMatHang != null){
  // Filter by type
  listCkn = response.listCkMatHang!.where((item) => item.kieuCK == 'CKN').toList();
  listCkg = response.listCkMatHang!.where((item) => item.kieuCK == 'CKG').toList();
  listHH = response.listCkMatHang!.where((item) => item.kieuCK == 'HH').toList();
  
  // Set flags
  hasCknDiscount = listCkn.isNotEmpty;
  hasCkgDiscount = listCkg.isNotEmpty;
  hasHHDiscount = listHH.isNotEmpty;
}
```

#### **Khi Backend Xử Lý CKG và HH (Trong `_handleCalculator`):**

```dart
// cart_bloc.dart - Line 2165-2248
for (var element in listProductOrderAndUpdate) {
  if(itemOrder.listDiscount![0].kieuCk == 'HH'){
    // ✅ Backend tự động thêm hàng tặng
    SearchItemResponseData itemHH = SearchItemResponseData(
      code: itemOrder.listDiscountProduct[0].maHangTang,
      typeCK: 'HH',
      gifProduct: true,
      ...
    );
    listOrder.add(itemHH); // Đã trong giỏ!
  }
  else if(itemOrder.listDiscount![0].kieuCk == 'CKG'){
    // ✅ Backend tự động áp dụng giảm giá
    itemOrder.typeCK = 'CKG';
    itemOrder.priceAfter = itemOrder.listDiscount![0].giaSauCk;
    itemOrder.discountPercent = itemOrder.listDiscount![0].tlCk;
    // Sản phẩm đã có giá mới!
  }
}
```

#### **Khi User Click Icon:**

```dart
// cart_screen.dart
void _showDiscountFlow() async {
  if (_bloc.hasCknDiscount) {
    // ✅ CÓ CKN: Cho phép user chọn
    _showCknDiscountFlow();
  } else {
    // ℹ️ CHỈ CÓ CKG/HH: Hiển thị thông tin
    _showAutoAppliedDiscountInfo();
  }
}
```

---

## 📊 Data Structure

### **Backend Response (`ListCkMatHang`)**

```dart
class ListCkMatHang {
  String? sttRecCk;      // Mã chiết khấu record
  String? maCk;          // Mã chiết khấu
  String? maVt;          // Mã vật tư
  String? tenVt;         // Tên vật tư
  String? dvt;           // Đơn vị tính
  double? soLuong;       // Số lượng (hoặc % giảm giá)
  String? kieuCK;        // Loại: 'CKN', 'CKG', 'HH'
  dynamic group_dk;      // Mã nhóm chiết khấu
  dynamic ten_ck;        // Tên chiết khấu
}
```

### **Gift Product in Cart (`SearchItemResponseData`)**

```dart
SearchItemResponseData {
  String code;           // Mã sản phẩm
  String typeCK;         // 'CKN', 'CKG', 'HH'
  String sttRecCK;       // Mã CK (để phân biệt)
  String maCk;           // Mã chiết khấu
  double count;          // Số lượng
  bool gifProduct;       // = true
  ...
}
```

---

## 🎨 UI/UX Design

### **Main Discount Button**

```dart
// Hiển thị khi có ít nhất 1 loại chiết khấu
Visibility(
  visible: (_bloc.hasCknDiscount || _bloc.hasCkgDiscount || _bloc.hasHHDiscount) 
           && _bloc.listOrder.isNotEmpty,
  child: IconButton(
    icon: Icon(Icons.card_giftcard_rounded, color: Colors.green),
    onTap: () => _showDiscountFlow(),
  ),
)
```

### **Discount Type Dialog**

```
┌──────────────────────────────────────┐
│  🎁 Chiết khấu đơn hàng        ✕    │
│  Chọn loại chiết khấu muốn áp dụng   │
├──────────────────────────────────────┤
│  [Chiết khấu nhóm] [Chiết khấu giá] [Hàng tặng] │ ← Tabs
├──────────────────────────────────────┤
│                                      │
│  ℹ️ Chọn sản phẩm tặng từ nhóm      │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ ✓ Chiết khấu Tết 2024     →   │ │ ← Selected
│  │ • Số lượng tối đa: 10 SP       │ │
│  │ • Số nhóm sản phẩm: 3          │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │   Chiết khấu Mua 10 Tặng 1 →  │ │
│  │ • Số lượng tối đa: 5 SP        │ │
│  │ • Số nhóm sản phẩm: 2          │ │
│  └────────────────────────────────┘ │
│                                      │
└──────────────────────────────────────┘
```

---

## 🧪 Test Cases

### **Test 1: Chọn CKN**

```
✅ Hiển thị danh sách nhóm CKN
✅ Click vào nhóm → Hiển thị dialog chọn sản phẩm
✅ Chọn sản phẩm → Thêm vào "Sản phẩm tặng"
✅ Chọn lại → Cập nhật, không duplicate
```

### **Test 2: Chọn CKG**

```
✅ Hiển thị danh sách CKG
✅ Click vào CKG → Hiển thị toast xác nhận
✅ Giá sản phẩm trong đơn được giảm (backend đã tính)
```

### **Test 3: Chọn HH**

```
✅ Hiển thị danh sách HH
✅ Click vào HH → Tự động thêm hàng tặng
✅ Sản phẩm tặng xuất hiện trong "Sản phẩm tặng"
✅ Chọn lại → Cập nhật danh sách HH, không duplicate
```

### **Test 4: Chọn Đa Loại**

```
✅ Chọn CKN → Thêm SP tặng từ CKN
✅ Chọn CKG → Áp dụng giảm giá
✅ Chọn HH → Thêm hàng tặng HH
✅ Tất cả 3 loại cùng tồn tại trong đơn
✅ Không conflict với nhau
```

### **Test 5: Clear và Reset**

```
✅ Tạo đơn mới → Clear all discount selections
✅ Xóa tất cả sản phẩm → Clear discount
✅ Cập nhật đơn → Giữ lại discount đã chọn
```

---

## 🔍 Debug

### **Enable Debug Logging**

```dart
// Trong cart_bloc.dart
print('💰 Discount Debug: CKN: ${listCkn.length}, CKG: ${listCkg.length}, HH: ${listHH.length}');

// Trong cart_screen.dart
print('💰 Discount Flow: Selected type=$type, groupKey=$groupKey');
print('💰 CKN Debug: Loading initial selections...');
print('💰 CKG Discount: Applying price discount...');
print('💰 HH Discount: Adding fixed gift products...');
```

### **Common Issues**

| Issue | Cause | Solution |
|-------|-------|----------|
| Duplicate sản phẩm tặng | Không xóa item cũ | Check `removeWhere` với `typeCK` + `sttRecCK` |
| Không hiển thị discount | Backend không trả về | Check `listCkMatHang` trong response |
| Conflict giữa các loại | Logic xử lý chung | Tách riêng handler cho mỗi loại |
| UI không update | Thiếu setState | Add `setState()` sau khi modify list |

---

## 📝 Notes

### **Backend Requirements**

#### **1. Response Structure**

```json
{
  "listItemOrder": [
    {
      "code": "SP001",
      "name": "Sản phẩm gốc",
      "count": 5,
      "price": 100000,
      
      // ✅ CKG: Chiết khấu giá cho sản phẩm này
      "listDiscount": [
        {
          "kieu_ck": "CKG",
          "stt_rec_ck": "CK001",
          "ma_ck": "GIAMGIA20",
          "ma_vt": "SP001",  // ← Link với sản phẩm gốc
          "tl_ck": 20,
          "gia_goc": 100000,
          "gia_sau_ck": 80000
        }
      ],
      
      // ✅ HH: Hàng tặng kèm sản phẩm này
      "listDiscountProduct": [
        {
          "ma_hang_tang": "GIFT01",
          "ten_hang_tang": "Quà tặng",
          "so_luong": 1,
          "stt_rec_ck": "CK002",
          "ma_ck": "TANGKEM",
          "ma_vt": "SP001"  // ← Link với sản phẩm gốc
        }
      ]
    }
  ],
  
  // ℹ️ CKN: Danh sách để user chọn
  "listCkMatHang": [
    {
      "kieu_ck": "CKN",
      "group_dk": "GROUP1",
      "ten_ck": "Chọn quà Tết",
      "ma_vt": "SP002",
      "ten_vt": "Bánh kẹo",
      "so_luong": 10
    }
  ]
}
```

#### **2. Key Points**

- **CKG**: Link với `ma_vt` trong `listDiscount` của sản phẩm gốc
- **HH**: Link với `ma_vt` trong `listDiscountProduct` của sản phẩm gốc
- **CKN**: Không link với sản phẩm cụ thể, user tự chọn từ `group_dk`

### **Future Enhancements**

- [ ] Hiển thị badge số lượng chiết khấu đã chọn
- [ ] Cho phép xóa từng loại chiết khấu đã chọn
- [ ] Thêm animation khi chọn discount
- [ ] Export discount info khi tạo đơn
- [ ] Lịch sử discount đã áp dụng

---

## 🚀 Deployment Checklist

```
□ Test tất cả 3 loại chiết khấu
□ Test chọn đa loại chiết khấu
□ Test clear và reset
□ Test với đơn hàng có nhiều sản phẩm
□ Test edit order với discount
□ Verify không có duplicate
□ Check performance với list lớn
□ Test trên cả Android và iOS
□ Update documentation
□ Train user về tính năng mới
```

---

## 📞 Support

Nếu có vấn đề, check theo thứ tự:

1. **Console log** - Xem debug messages
2. **Backend response** - Verify `listCkMatHang` structure
3. **State** - Check `hasCknDiscount`, `hasCkgDiscount`, `hasHHDiscount`
4. **UI** - Verify button visibility conditions
5. **Logic** - Review handler methods

---

**Version:** 1.0.0  
**Last Updated:** 2025-11-05  
**Author:** AI Assistant + Dev Team

