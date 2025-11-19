# 🛍️ E-Commerce Style Discount UI - Like Shopee, Lazada, Tiki

## 🎨 **UI Design Overview**

### **Inspiration:**
Thiết kế dựa trên UX của các app thương mại điện tử hàng đầu:
- ✅ **Shopee**: Bottom sheet vouchers
- ✅ **Lazada**: Discount selection UI
- ✅ **Tiki**: Promo code selection

### **Key Features:**
1. **All-in-One View**: Hiển thị TẤT CẢ chiết khấu trong 1 màn hình
2. **Visual Hierarchy**: Icon màu sắc riêng cho từng loại
3. **Clear Status**: "Đã áp dụng" vs "Chọn ngay"
4. **Interactive**: Cho phép toggle on/off từng voucher
5. **Draggable**: Bottom sheet có thể kéo lên/xuống

---

## 📱 **UI Components**

### **1. Main Entry Point - Icon Button**
```dart
Icon 🎁 ở giỏ hàng
→ Click → Show DiscountVoucherSelectionSheet
```

### **2. Bottom Sheet Structure**

```
┌──────────────────────────────────────────┐
│  🏷️  Voucher & Ưu đãi            ✕      │ ← Header
│  12 ưu đãi khả dụng                      │
├──────────────────────────────────────────┤
│                                           │
│  💰 Chiết khấu giá (3)                   │ ← Section Title
│                                           │
│  ┌────────────────────────────────────┐  │
│  │ 💚 Giảm 20%              ✓ Đã áp  │  │ ← CKG Voucher
│  │ Cho: Sản phẩm A            dụng   │  │   (Auto-applied)
│  │ Giảm 20% giá sản phẩm              │  │
│  └────────────────────────────────────┘  │
│                                           │
│  ┌────────────────────────────────────┐  │
│  │ 💚 Giảm 15%                        │  │ ← CKG Voucher
│  │ Cho: Sản phẩm B         [Chọn ngay] │  │   (Not applied)
│  │ Giảm 15% giá sản phẩm              │  │
│  └────────────────────────────────────┘  │
│                                           │
│  🎁 Quà tặng kèm (2)                      │
│                                           │
│  ┌────────────────────────────────────┐  │
│  │ 💜 Mua 5 tặng 1          ✓ Đã áp  │  │ ← HH Voucher
│  │ Cho: Sản phẩm A            dụng   │  │   (Auto-applied)
│  │ Tặng Quà tặng x1                   │  │
│  └────────────────────────────────────┘  │
│                                           │
│  🎊 Chọn quà tặng (1)                     │
│                                           │
│  ┌────────────────────────────────────┐  │
│  │ 💙 Tết 2024              ✓ Đổi quà │  │ ← CKN Voucher
│  │ Chọn tối đa 10 SP          khác   │  │   (Selected)
│  │ 3 nhóm sản phẩm khả dụng           │  │
│  └────────────────────────────────────┘  │
│                                           │
└──────────────────────────────────────────┘
```

---

## 🎯 **User Interactions**

### **CKG - Chiết khấu giá** 💚

#### **Status: Đã áp dụng (Default)**
```
┌────────────────────────────────────┐
│ 💚 Giảm 20%              ✓ Đã áp  │
│ Cho: Sản phẩm A            dụng   │
│ Giảm 20% giá sản phẩm              │
└────────────────────────────────────┘
```

**User Actions:**
- ✅ **Tap**: Bỏ áp dụng chiết khấu này
- ✅ **Effect**: Voucher card đổi màu xám, giá sản phẩm về giá gốc

#### **Status: Chưa áp dụng**
```
┌────────────────────────────────────┐
│ 💚 Giảm 20%                        │
│ Cho: Sản phẩm A         [Chọn ngay] │
│ Giảm 20% giá sản phẩm              │
└────────────────────────────────────┘
```

**User Actions:**
- ✅ **Tap "Chọn ngay"**: Áp dụng lại chiết khấu
- ✅ **Effect**: Voucher card đổi màu xanh, giá giảm

---

### **HH - Hàng hóa tặng** 💜

#### **Status: Đã áp dụng (Default)**
```
┌────────────────────────────────────┐
│ 💜 Mua 5 tặng 1          ✓ Đã áp  │
│ Cho: Sản phẩm A            dụng   │
│ Tặng Quà tặng x1                   │
└────────────────────────────────────┘
```

**User Actions:**
- ✅ **Tap**: Bỏ quà tặng này
- ✅ **Effect**: Quà tặng biến mất khỏi "Sản phẩm tặng"

#### **Status: Chưa áp dụng**
```
┌────────────────────────────────────┐
│ 💜 Mua 5 tặng 1                    │
│ Cho: Sản phẩm A         [Chọn ngay] │
│ Tặng Quà tặng x1                   │
└────────────────────────────────────┘
```

**User Actions:**
- ✅ **Tap "Chọn ngay"**: Thêm lại quà tặng
- ✅ **Effect**: Quà tặng xuất hiện trong giỏ

---

### **CKN - Chọn quà tặng** 💙

#### **Status: Đã chọn**
```
┌────────────────────────────────────┐
│ 💙 Tết 2024              ✓ Đổi quà │
│ Chọn tối đa 10 SP          khác   │
│ 3 nhóm sản phẩm khả dụng           │
└────────────────────────────────────┘
```

**User Actions:**
- ✅ **Tap "Đổi quà khác"**: Mở dialog chọn sản phẩm tặng mới
- ✅ **Effect**: Replace sản phẩm tặng cũ

#### **Status: Chưa chọn**
```
┌────────────────────────────────────┐
│ 💙 Tết 2024                        │
│ Chọn tối đa 10 SP       [Chọn ngay] │
│ 3 nhóm sản phẩm khả dụng           │
└────────────────────────────────────┘
```

**User Actions:**
- ✅ **Tap "Chọn ngay"**: Mở dialog chọn sản phẩm tặng
- ✅ **Effect**: Show gift selection popup

---

## 🔄 **Flow Diagrams**

### **Flow 1: CKG Toggle**
```
User click CKG voucher (đã áp dụng)
  ↓
Confirm: "Bỏ chiết khấu giá?"
  ↓
Yes → Remove CKG
  ↓
Product.typeCK = ''
Product.price = original_price
  ↓
UI update: Voucher đổi màu xám
Toast: "Đã bỏ chiết khấu giá"
```

### **Flow 2: HH Toggle**
```
User click HH voucher (đã áp dụng)
  ↓
Confirm: "Bỏ quà tặng?"
  ↓
Yes → Remove HH gift
  ↓
DataLocal.listProductGift.remove(gift)
  ↓
UI update: Voucher đổi màu xám
Toast: "Đã bỏ quà tặng"
```

### **Flow 3: CKN Selection**
```
User click CKN voucher
  ↓
Close bottom sheet
  ↓
Open gift selection dialog
  ↓
User chọn sản phẩm tặng
  ↓
Add to DataLocal.listProductGift
  ↓
UI update: Voucher show "✓ Đổi quà khác"
Toast: "Đã thêm N sản phẩm tặng"
```

---

## 💻 **Implementation Details**

### **1. Bottom Sheet Component**

**File:** `lib/screen/sell/cart/widgets/discount_voucher_selection_sheet.dart`

**Key Features:**
- DraggableScrollableSheet (có thể kéo)
- Sections cho từng loại voucher
- Visual indicators (icons, colors)
- Status badges ("Đã áp dụng", "Chọn ngay")

### **2. Voucher Card Structure**

```dart
_buildVoucherCard(
  type: 'CKG',                    // CKG, HH, CKN
  icon: Icons.discount,           // Icon riêng
  iconColor: Colors.green,        // Màu riêng
  title: 'Giảm 20%',              // Tên chiết khấu
  subtitle: 'Cho: Sản phẩm A',    // Áp dụng cho SP nào
  description: 'Giảm 20%...',     // Chi tiết
  isApplied: true,                // Đã áp dụng chưa
  isAutoApplied: true,            // Backend tự động hay user chọn
  ctaText: 'Đổi quà',             // Text button
  onTap: () { ... },              // Action khi click
)
```

### **3. Actions Return Format**

```dart
// Toggle CKG
{
  'action': 'toggle_ckg',
  'productCode': 'SP001',
  'enabled': true/false,
  'ckgItem': ListCkMatHang object
}

// Toggle HH
{
  'action': 'toggle_hh',
  'productCode': 'SP001',
  'enabled': true/false,
  'hhItem': ListCkMatHang object
}

// Select CKN
{
  'action': 'select_ckn',
  'groupKey': 'GROUP1',
  'items': List<ListCkMatHang>,
  'totalQuantity': 10.0
}
```

---

## 🎨 **Visual Design**

### **Color Scheme**

| Type | Primary Color | Background | Border |
|------|---------------|------------|--------|
| **CKG** | `Colors.green` | `Colors.green.shade50` | `Colors.green` |
| **HH** | `Colors.purple` | `Colors.purple.shade50` | `Colors.purple` |
| **CKN** | `Colors.blue` | `Colors.blue.shade50` | `Colors.blue` |
| **Not Applied** | `Colors.grey` | `Colors.grey.shade50` | `Colors.grey.shade300` |

### **Typography**

- **Title**: 15px, FontWeight.w600
- **Subtitle**: 12px, grey.shade600
- **Description**: 12px, grey.shade500
- **CTA Button**: 12px, FontWeight.w600

### **Spacing**

- Card padding: 12px
- Card margin bottom: 8px
- Section spacing: 16px
- Icon size: 24px
- Badge icon: 16px

---

## 🧪 **Test Scenarios**

### **Scenario 1: Tất cả loại có sẵn**
```
Given: Đơn hàng có 2 CKG, 1 HH, 1 CKN
When: User mở voucher sheet
Then:
  ✓ Hiển thị 4 vouchers
  ✓ CKG và HH: "Đã áp dụng"
  ✓ CKN: "Chọn ngay"
  ✓ UI đẹp, rõ ràng
```

### **Scenario 2: Toggle CKG off**
```
Given: CKG đang "Đã áp dụng"
When: User tap vào CKG voucher
Then:
  ✓ Voucher đổi sang "Chọn ngay"
  ✓ Product price = original price
  ✓ Toast: "Đã bỏ chiết khấu giá"
  ✓ Bottom sheet close
```

### **Scenario 3: Toggle HH off**
```
Given: HH đang "Đã áp dụng"
When: User tap vào HH voucher
Then:
  ✓ Voucher đổi sang "Chọn ngay"
  ✓ Gift removed from list
  ✓ Toast: "Đã bỏ quà tặng"
  ✓ Bottom sheet close
```

### **Scenario 4: Select CKN**
```
Given: CKN chưa chọn
When: User tap "Chọn ngay"
Then:
  ✓ Bottom sheet close
  ✓ Gift selection dialog open
  ✓ User chọn 3 sản phẩm
  ✓ Gifts added to cart
  ✓ Toast: "Đã thêm 3 sản phẩm tặng"
```

### **Scenario 5: Change CKN selection**
```
Given: CKN đã chọn (nhóm A)
When: User tap "Đổi quà khác"
Then:
  ✓ Gift selection dialog open
  ✓ User chọn nhóm B
  ✓ Nhóm A gifts removed
  ✓ Nhóm B gifts added
  ✓ Toast: "Đã cập nhật sản phẩm tặng"
```

---

## 📊 **Advantages vs Old UI**

| Aspect | Old UI | New UI (E-commerce Style) |
|--------|--------|---------------------------|
| **View All** | ❌ Phải xem từng loại riêng | ✅ Thấy tất cả cùng lúc |
| **Toggle** | ❌ Không cho phép | ✅ Bật/tắt tự do |
| **Visual** | ⚠️ Text-heavy | ✅ Icon + màu sắc |
| **Status** | ⚠️ Không rõ | ✅ "Đã áp dụng" rõ ràng |
| **UX** | ⚠️ Multiple dialogs | ✅ Single bottom sheet |
| **Familiar** | ❌ Custom | ✅ Giống Shopee/Lazada |

---

## 🚀 **Deployment Notes**

### **Backend Requirements:**
- ✅ Không thay đổi! Backend vẫn trả về như cũ
- ✅ CKG và HH vẫn tự động áp dụng
- ✅ Frontend chỉ thay đổi cách hiển thị

### **Migration:**
- ✅ Code cũ vẫn hoạt động
- ✅ Có thể rollback dễ dàng
- ✅ Không breaking changes

### **Feature Flags:**
Nếu cần test từ từ:
```dart
const bool USE_NEW_VOUCHER_UI = true; // Feature flag

void _showDiscountFlow() {
  if (USE_NEW_VOUCHER_UI) {
    _showVoucherBottomSheet(); // New
  } else {
    _showOldDiscountDialog();  // Old
  }
}
```

---

## 📝 **User Guide**

### **Cho User:**

**1. Xem vouchers:**
- Click icon 🎁 ở giỏ hàng
- Xem tất cả ưu đãi khả dụng

**2. Bỏ chiết khấu:**
- Tap vào voucher đang "Đã áp dụng"
- Voucher sẽ tắt, giá về gốc

**3. Bật lại chiết khấu:**
- Tap "Chọn ngay" trên voucher đã tắt
- Voucher sẽ bật lại

**4. Chọn quà tặng:**
- Tap "Chọn ngay" trên CKN voucher
- Chọn sản phẩm tặng yêu thích

**5. Đổi quà:**
- Tap "Đổi quà khác" nếu muốn đổi
- Chọn sản phẩm mới

---

## ✨ **Summary**

### **What's New:**
✅ **Bottom sheet** thay vì dialogs
✅ **All-in-one view** cho tất cả vouchers
✅ **Toggle on/off** CKG và HH
✅ **Visual indicators** rõ ràng
✅ **E-commerce UX** familiar cho users

### **What's Same:**
✅ Backend logic không đổi
✅ CKN flow vẫn như cũ
✅ Data structure giữ nguyên

---

**🎉 E-commerce style discount UI is ready!**

Giờ users có thể **xem và quản lý tất cả chiết khấu** trong 1 màn hình, giống như khi mua sắm trên Shopee, Lazada, Tiki! 🛍️

