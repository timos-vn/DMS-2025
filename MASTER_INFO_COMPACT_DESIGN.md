# 🎨 Master Info - Compact Design

## 📋 Thiết kế mới

### **Trước (Old):**
```
┌─────────────────────────────────────────┐
│ 📄  Thông tin hợp đồng    [Chờ duyệt]  │
├─────────────────────────────────────────┤
│                                         │
│ 📝 Số hợp đồng                          │
│    HD001/2024                           │
│                                         │
│ 👤 Khách hàng                           │
│    KH001 - Công ty ABC                  │
│                                         │
└─────────────────────────────────────────┘
```
❌ Chiếm nhiều không gian  
❌ White background giống vật tư cards  
❌ Padding lớn (16px)  
❌ Layout dọc  

---

### **Sau (New - Compact):**
```
┌─────────────────────────────────────────┐
│ 📄 HĐ: HD001/2024     [Chờ duyệt]      │
│ 👤 KH001 - Công ty ABC                  │
└─────────────────────────────────────────┘
```
✅ Nhỏ gọn, chỉ 2 dòng  
✅ Gradient background (khác biệt rõ)  
✅ Padding nhỏ (12px)  
✅ Layout ngang tối ưu  
✅ Status badge solid color  

---

## 🎨 Design Specs

### **Container:**
```dart
margin:     16px horizontal, 12px vertical
padding:    12px all sides
background: Linear gradient (mainColor → subColor)
border:     mainColor.withOpacity(0.2), 1px
radius:     12px
```

### **Icon:**
```dart
size:       16px (nhỏ hơn)
padding:    6px (compact)
background: mainColor.withOpacity(0.15)
radius:     6px
```

### **Header Row:**
```
[Icon] HĐ: HD001/2024          [Status Badge]
│      │                        │
│      └─ Bold, 14pt           └─ Solid color, 11pt
└─ 16px icon
```

### **Customer Row:**
```
[👤 Icon] KH001 - Công ty ABC
│         │
│         └─ 13pt, Medium weight
└─ 14px icon
```

### **Status Badge:**
- **Background:** Solid color (green/orange)
- **Text:** White, bold, 11pt
- **Icon:** 12px
- **Padding:** 8px horizontal, 4px vertical
- **Radius:** 12px (pill shape)

---

## 📊 So sánh kích thước

| Element | Old | New |
|---------|-----|-----|
| **Height** | ~140px | ~70px |
| **Icon size** | 20px | 16px |
| **Padding** | 16px | 12px |
| **Margin** | 16px all | 16px H, 12px V |
| **Font size** | 14-16pt | 11-14pt |
| **Background** | Solid white | Gradient |
| **Layout** | Vertical | Horizontal |

**Tiết kiệm:** ~50% không gian!

---

## 🎯 Khác biệt với Material Cards

| Feature | Master Info | Material Cards |
|---------|-------------|----------------|
| **Background** | Gradient | Solid white |
| **Border** | mainColor.withOpacity(0.2) | grey.withOpacity(0.15) |
| **Shadow** | None | Dual-layer |
| **Height** | Fixed ~70px | Dynamic |
| **Layout** | Horizontal compact | Vertical detailed |
| **Icon style** | Small (16px) | Medium (20px) |
| **Status** | Solid badge | Outlined badge |

---

## ✨ Advantages

### **1. Space Efficient**
- Giảm 50% chiều cao
- Nhiều không gian hơn cho danh sách vật tư
- Scroll ít hơn

### **2. Visual Distinction**
- **Gradient background** khác hẳn white cards
- **Border color** khác (mainColor vs grey)
- **No shadow** → cảm giác "flat" khác với elevated cards
- **Horizontal layout** khác vertical

### **3. Quick Scan**
- Thông tin quan trọng trên 1 dòng
- Status badge nổi bật với solid color
- Customer info ngắn gọn

### **4. Modern Look**
- Gradient subtle
- Pill-shaped badge
- Compact và gọn gàng

---

## 🎨 Color Scheme

```dart
// Background gradient
mainColor.withOpacity(0.05) → subColor.withOpacity(0.02)

// Border
mainColor.withOpacity(0.2)

// Icon container
mainColor.withOpacity(0.15)

// Status badge
Solid: Colors.green | Colors.orange

// Text
mainColor (HĐ number)
Colors.black87 (Customer)
```

---

## 📱 Visual Hierarchy

```
Priority 1: Số HĐ (Bold, mainColor, 14pt)
Priority 2: Status (Solid badge, white text)
Priority 3: Customer (Medium, 13pt, grey icon)
```

---

## 🔄 Layout Flow

```
┌──────────────────────────────────────┐
│ Master Info (Compact - 70px)        │ ← Gradient
├──────────────────────────────────────┤
│ Divider                              │
├──────────────────────────────────────┤
│                                      │
│ ┌────────────────────────────────┐  │
│ │ Material Card 1 (White, 150px) │  │ ← Shadow
│ └────────────────────────────────┘  │
│                                      │
│ ┌────────────────────────────────┐  │
│ │ Material Card 2 (White, 150px) │  │ ← Shadow
│ └────────────────────────────────┘  │
│                                      │
│ ...                                  │
└──────────────────────────────────────┘
```

**Clear separation:**
- Master info: Gradient, flat, compact
- Material cards: White, elevated, detailed

---

## 📐 Responsive Design

### **Overflow Handling:**
```dart
Text(
  '${maKh} - ${tenKh}',
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

### **Flexible Width:**
```dart
Expanded(
  child: Text(...),  // Tự động điều chỉnh
)
```

---

## ✅ Code Quality

- ✅ No hardcoded values (sử dụng theme colors)
- ✅ Responsive với Expanded
- ✅ Null safety với _safeText()
- ✅ Maintainable với clear structure
- ✅ No linter errors

---

## 🎯 Summary

**Old Design:**
- Large card (140px)
- White background
- Vertical layout
- Nhiều padding
- Giống material cards

**New Design:**
- Compact (70px) - **50% nhỏ hơn**
- Gradient background - **Khác biệt rõ**
- Horizontal layout - **Efficient**
- Compact padding - **Tiết kiệm không gian**
- Solid status badge - **Nổi bật hơn**

---

**Result:** Thông tin hợp đồng giờ đây:
1. ✅ Nhỏ gọn (50% chiều cao)
2. ✅ Khác biệt hoàn toàn với vật tư cards
3. ✅ Dễ scan thông tin
4. ✅ Nhiều không gian cho danh sách vật tư
5. ✅ Modern và professional

**Created:** 2025-10-09  
**File:** `/lib/screen/sell/contract/component/detail_contract.dart`  
**Status:** ✅ Completed

