import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dms/model/network/response/apply_discount_response.dart';
import 'package:dms/model/network/response/search_list_item_response.dart';

/// Bottom sheet hiển thị TẤT CẢ chiết khấu như vouchers
/// Style giống Shopee, Lazada, Tiki
/// Hỗ trợ multiple selection CHO TẤT CẢ các loại (CKG, HH, CKN, CKTDTT)
class DiscountVoucherSelectionSheet extends StatefulWidget {
  final List<ListCkMatHang> listCkn;
  final List<ListCk> listCkg;
  final List<ListCk> listHH;
  final List<ListCkTongDon> listCktdtt; // CKTDTT - Chiết khấu tổng đơn tặng tiền
  final List<ListCkMatHang> listCktdth; // CKTDTH - Chiết khấu tổng đơn tặng hàng
  final Set<String> selectedCknGroups; // MULTIPLE CKN groups
  final Set<String> selectedCkgIds;
  final Set<String> selectedHHIds;
  final Set<String> selectedCktdttIds; // MULTIPLE CKTDTT
  final Set<String> selectedCktdthGroups; // MULTIPLE CKTDTH groups
  final List<SearchItemResponseData> currentCart;
  final void Function(String groupKey, List<ListCkMatHang> items, double totalQuantity)?
      onSelectCknGroup;
  final void Function(String groupKey)? onRemoveCknGroup;
  final void Function(String ckgId, ListCk ckgItem)? onSelectCkg;
  final void Function(String ckgId, ListCk ckgItem)? onRemoveCkg;
  final void Function(String cktdttId, ListCkTongDon cktdttItem)? onSelectCktdtt;
  final void Function(String cktdttId, ListCkTongDon cktdttItem)? onRemoveCktdtt;
  final void Function(String groupKey, List<ListCkMatHang> items, double totalQuantity)?
      onSelectCktdthGroup;
  final void Function(String groupKey)? onRemoveCktdthGroup;

  const DiscountVoucherSelectionSheet({
    Key? key,
    required this.listCkn,
    required this.listCkg,
    required this.listHH,
    required this.listCktdtt,
    required this.listCktdth,
    required this.selectedCknGroups,
    required this.selectedCkgIds,
    required this.selectedHHIds,
    required this.selectedCktdttIds,
    required this.selectedCktdthGroups,
    required this.currentCart,
    this.onSelectCknGroup,
    this.onRemoveCknGroup,
    this.onSelectCkg,
    this.onRemoveCkg,
    this.onSelectCktdtt,
    this.onRemoveCktdtt,
    this.onSelectCktdthGroup,
    this.onRemoveCktdthGroup,
  }) : super(key: key);

  @override
  State<DiscountVoucherSelectionSheet> createState() => DiscountVoucherSelectionSheetState();
}

class DiscountVoucherSelectionSheetState extends State<DiscountVoucherSelectionSheet> {
  // Local state for multiple selection (TẤT CẢ các loại dùng checkbox!)
  late Set<String> _selectedCkgIds;
  late Set<String> _selectedHHIds;
  late Set<String> _selectedCknGroups; // MULTIPLE CKN groups
  late Set<String> _selectedCktdttIds; // MULTIPLE CKTDTT
  late Set<String> _selectedCktdthGroups; // MULTIPLE CKTDTH groups
  
  String _buildCkgId(ListCk ckgItem) {
    final sttRecCk = (ckgItem.sttRecCk ?? '').trim();
    final productCode = (ckgItem.maVt ?? '').trim();
    return '${sttRecCk}_$productCode';
  }

  String _normalizeCkgId(String id) {
    if (id.contains('_')) return id;
    for (final ckg in widget.listCkg) {
      final sttRecCk = (ckg.sttRecCk ?? '').trim();
      if (sttRecCk == id.trim()) {
        return _buildCkgId(ckg);
      }
    }
    return id.trim();
  }
  
  @override
  void initState() {
    super.initState();
    // Initialize with current selections
    _selectedCkgIds = widget.selectedCkgIds.map(_normalizeCkgId).toSet();
    _selectedHHIds = Set.from(widget.selectedHHIds);
    _selectedCknGroups = Set.from(widget.selectedCknGroups);
    _selectedCktdttIds = Set.from(widget.selectedCktdttIds);
    _selectedCktdthGroups = Set.from(widget.selectedCktdthGroups);
  }
  
  @override
  Widget build(BuildContext context) {
    // Count số chiết khấu khả dụng
    int totalDiscounts = widget.listCkn.length + widget.listCkg.length + widget.listHH.length + widget.listCktdtt.length + widget.listCktdth.length;
    // Count số chiết khấu đã chọn (CKG + HH + CKN groups + CKTDTT + CKTDTH)
    int selectedCount = _selectedCkgIds.length + _selectedHHIds.length + _selectedCknGroups.length + _selectedCktdttIds.length + _selectedCktdthGroups.length;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(totalDiscounts),
          
          const Divider(height: 1),
          
          // List of vouchers
          Flexible(
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                // CKG Vouchers
                if (widget.listCkg.isNotEmpty) ...[
                  _buildSectionTitle('💰 Chiết khấu giá', widget.listCkg.length),
                  const SizedBox(height: 8),
                  ..._buildCkgVouchers(),
                  const SizedBox(height: 16),
                ],
                
                // HH Vouchers
                if (widget.listHH.isNotEmpty) ...[
                  _buildSectionTitle('🎁 Quà tặng kèm', widget.listHH.length),
                  const SizedBox(height: 8),
                  ..._buildHHVouchers(),
                  const SizedBox(height: 16),
                ],
                
                // CKN Vouchers
                if (widget.listCkn.isNotEmpty) ...[
                  _buildSectionTitle('🎊 Chọn quà tặng', widget.listCkn.length),
                  const SizedBox(height: 8),
                  ..._buildCknVouchers(),
                  const SizedBox(height: 16),
                ],
                
                // CKTDTT Vouchers - Chiết khấu tổng đơn tặng tiền
                if (widget.listCktdtt.isNotEmpty) ...[
                  _buildSectionTitle('💵 Chiết khấu tổng đơn', widget.listCktdtt.length),
                  const SizedBox(height: 8),
                  ..._buildCktdttVouchers(),
                  const SizedBox(height: 16),
                ],
                
                // CKTDTH Vouchers - Chiết khấu tổng đơn tặng hàng
                if (widget.listCktdth.isNotEmpty) ...[
                  _buildSectionTitle('🎁 Chiết khấu tổng đơn tặng hàng', widget.listCktdth.length),
                  const SizedBox(height: 8),
                  ..._buildCktdthVouchers(),
                ],
                
                const SizedBox(height: 80), // Space for bottom button
              ],
            ),
          ),
          
          // Bottom action button
          _buildBottomButton(selectedCount),
        ],
      ),
    );
  }
  
  Widget _buildBottomButton(int selectedCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // Return all selections (ALL 3 types can have multiple selections!)
            Navigator.pop(context, {
              'action': 'apply_all',
              'selectedCkgIds': _selectedCkgIds,
              'selectedHHIds': _selectedHHIds,
              'selectedCknGroups': _selectedCknGroups, // MULTIPLE CKN groups
              'selectedCktdttIds': _selectedCktdttIds, // MULTIPLE CKTDTT
              'selectedCktdthGroups': _selectedCktdthGroups, // MULTIPLE CKTDTH
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Áp dụng ($selectedCount ưu đãi)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalDiscounts) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_offer,
              color: Colors.orange.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voucher & Ưu đãi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalDiscounts ưu đãi khả dụng',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Text(
      '$title ($count)',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  // CKG Vouchers - Cho phép chọn nhiều (checkbox)
  List<Widget> _buildCkgVouchers() {
    List<Widget> widgets = [];
    
    for (var ckgItem in widget.listCkg) {
      String ckgId = _buildCkgId(ckgItem);
      bool isSelected = _selectedCkgIds.contains(ckgId);
      
      // Tìm sản phẩm trong giỏ
      String productCode = ckgItem.maVt?.trim() ?? '';
      var product = widget.currentCart.firstWhere(
        (item) => item.code == productCode && item.gifProduct != true,
        orElse: () => SearchItemResponseData(code: productCode, name: productCode),
      );
      
      // Tính % hoặc số tiền giảm
      String discountText = '';
      if (ckgItem.tlCk != null && ckgItem.tlCk! > 0) {
        discountText = 'Giảm ${ckgItem.tlCk!.toStringAsFixed(1)}%';
      } else if (ckgItem.ck != null && ckgItem.ck! > 0) {
        String formattedAmount = _formatMoneyWithSeparator(ckgItem.ck);
        discountText = 'Giảm ${formattedAmount}đ';
      }
      
      widgets.add(
        _buildVoucherCheckboxCard(
          id: ckgId,
          type: 'CKG',
          icon: Icons.discount,
          iconColor: Colors.green,
          title: ckgItem.tenCk ?? discountText,
          subtitle: 'Cho: ${product.name ?? productCode}',
          description: discountText,
          isSelected: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedCkgIds.add(ckgId);
                widget.onSelectCkg?.call(ckgId, ckgItem);
              } else {
                _selectedCkgIds.remove(ckgId);
                widget.onRemoveCkg?.call(ckgId, ckgItem);
              }
            });
          },
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  // HH Vouchers - Cho phép chọn nhiều (checkbox)
  List<Widget> _buildHHVouchers() {
    List<Widget> widgets = [];
    
    for (var hhItem in widget.listHH) {
      // ✅ FIX: Dùng unique ID (sttRecCk + tenVt) để phân biệt các HH items khác nhau
      String hhId = '${hhItem.sttRecCk?.trim() ?? ''}_${hhItem.tenVt?.trim() ?? ''}';
      bool isSelected = _selectedHHIds.contains(hhId);
      
      // Tìm sản phẩm gốc trong giỏ (từ ma_vt)
      String productCode = hhItem.maVt?.trim() ?? '';
      var product = widget.currentCart.firstWhere(
        (item) => item.code == productCode && item.gifProduct != true,
        orElse: () => SearchItemResponseData(code: productCode, name: productCode),
      );
      
      widgets.add(
        _buildVoucherCheckboxCard(
          id: hhId,
          type: 'HH',
          icon: Icons.redeem,
          iconColor: Colors.purple,
          title: hhItem.tenCk ?? 'Quà tặng kèm',
          subtitle: 'Cho: ${product.name ?? productCode}',
          description: 'Tặng ${hhItem.tenVt} x${hhItem.soLuong?.toInt() ?? 0}',
          isSelected: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedHHIds.add(hhId);
              } else {
                _selectedHHIds.remove(hhId);
              }
            });
          },
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  // CKN Vouchers - Cho phép chọn NHIỀU nhóm (checkbox - multiple selection)
  List<Widget> _buildCknVouchers() {
    // Group CKN by group_dk
    Map<String, List<ListCkMatHang>> groupedByGroup = {};
    for (var cknItem in widget.listCkn) {
      String groupKey = cknItem.group_dk?.toString() ?? 'default';
      if (!groupedByGroup.containsKey(groupKey)) {
        groupedByGroup[groupKey] = [];
      }
      groupedByGroup[groupKey]!.add(cknItem);
    }

    List<Widget> widgets = [];
    groupedByGroup.forEach((groupKey, cknItems) {
      var cknItem = cknItems.first;
      bool isSelected = _selectedCknGroups.contains(groupKey);
      
      // Tính tổng số lượng
      double totalQty = cknItems.fold(0.0, (sum, item) => sum + (item.soLuong ?? 0));
      
      widgets.add(
        _buildVoucherCheckboxCard(
          id: groupKey,
          type: 'CKN',
          icon: Icons.card_giftcard,
          iconColor: Colors.blue,
          title: cknItem.ten_ck?.toString() ?? 'Chọn quà tặng',
          subtitle: 'Chọn tối đa ${totalQty.toInt()} sản phẩm',
          description: '${cknItems.length} nhóm sản phẩm khả dụng',
          isSelected: isSelected,
          hasArrow: true, // Show arrow vì cần mở dialog
          onChanged: (bool? value) {
            if (value == true) {
              setState(() {
                _selectedCknGroups.add(groupKey);
              });
              widget.onSelectCknGroup?.call(groupKey, cknItems, totalQty);
            } else {
              setState(() {
                _selectedCknGroups.remove(groupKey);
              });
              widget.onRemoveCknGroup?.call(groupKey);
            }
          },
        ),
      );
      widgets.add(const SizedBox(height: 8));
    });

    return widgets;
  }

  // Helper function để format số tiền với dấu chấm phân cách hàng nghìn
  String _formatMoneyWithSeparator(double? amount) {
    if (amount == null || amount <= 0) return '';
    try {
      // Format với dấu phẩy từ NumberFormat, sau đó thay bằng dấu chấm
      final formatter = NumberFormat('#,##0', 'vi_VN');
      return formatter.format(amount).replaceAll(',', '.');
    } catch (e) {
      return amount.toStringAsFixed(0);
    }
  }

  // CKTDTT Vouchers - Chiết khấu tổng đơn tặng tiền (checkbox, multiple selection)
  List<Widget> _buildCktdttVouchers() {
    List<Widget> widgets = [];
    
    for (var cktdttItem in widget.listCktdtt) {
      String cktdttId = (cktdttItem.sttRecCk ?? '').trim();
      bool isSelected = _selectedCktdttIds.contains(cktdttId);
      
      // Tính số tiền giảm với format phần nghìn
      String discountText = '';
      if (cktdttItem.tCkTt != null && cktdttItem.tCkTt! > 0) {
        String formattedAmount = _formatMoneyWithSeparator(cktdttItem.tCkTt);
        discountText = 'Giảm ${formattedAmount}đ';
      } else if (cktdttItem.tlCkTt != null && cktdttItem.tlCkTt! > 0) {
        discountText = 'Giảm ${cktdttItem.tlCkTt!.toStringAsFixed(1)}%';
      } else if (cktdttItem.tCkTtNt != null && cktdttItem.tCkTtNt! > 0) {
        String formattedAmount = _formatMoneyWithSeparator(cktdttItem.tCkTtNt);
        discountText = 'Giảm ${formattedAmount}đ';
      }
      
      widgets.add(
        _buildVoucherCheckboxCard(
          id: cktdttId,
          type: 'CKTDTT',
          icon: Icons.payments,
          iconColor: Colors.blue,
          title: cktdttItem.maCk ?? 'Chiết khấu tổng đơn',
          subtitle: 'Áp dụng cho toàn bộ đơn hàng',
          description: discountText.isNotEmpty ? discountText : 'Chiết khấu tổng đơn',
          isSelected: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedCktdttIds.add(cktdttId);
                widget.onSelectCktdtt?.call(cktdttId, cktdttItem);
              } else {
                _selectedCktdttIds.remove(cktdttId);
                widget.onRemoveCktdtt?.call(cktdttId, cktdttItem);
              }
            });
          },
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  // CKTDTH Vouchers - Chiết khấu tổng đơn tặng hàng (tương tự CKN, cần chọn hàng tặng)
  List<Widget> _buildCktdthVouchers() {
    List<Widget> widgets = [];
    
    // Group CKTDTH by group_dk (giống CKN)
    Map<String, List<ListCkMatHang>> groupedCktdth = {};
    for (var item in widget.listCktdth) {
      String groupKey = (item.group_dk ?? '').trim();
      if (groupKey.isEmpty) {
        groupKey = (item.sttRecCk ?? '').trim(); // Fallback to sttRecCk if no group_dk
      }
      if (!groupedCktdth.containsKey(groupKey)) {
        groupedCktdth[groupKey] = [];
      }
      groupedCktdth[groupKey]!.add(item);
    }
    
    groupedCktdth.forEach((groupKey, cktdthItems) {
      bool isSelected = _selectedCktdthGroups.contains(groupKey);
      
      // Calculate total quantity available
      double totalQty = 0;
      for (var item in cktdthItems) {
        totalQty += (item.soLuong ?? 0);
      }
      
      // Get discount name
      String discountName = cktdthItems.first.ten_ck?.toString() ?? 'CKTDTH';
      
      widgets.add(
        _buildVoucherCheckboxCard(
          id: groupKey,
          type: 'CKTDTH',
          icon: Icons.card_giftcard,
          iconColor: Colors.purple,
          title: discountName,
          subtitle: 'Chọn tối đa ${totalQty.toInt()} sản phẩm',
          description: '${cktdthItems.length} nhóm sản phẩm khả dụng',
          isSelected: isSelected,
          hasArrow: true, // Show arrow vì cần mở dialog
          onChanged: (bool? value) {
            if (value == true) {
              setState(() {
                _selectedCktdthGroups.add(groupKey);
              });
              widget.onSelectCktdthGroup?.call(groupKey, cktdthItems, totalQty);
            } else {
              setState(() {
                _selectedCktdthGroups.remove(groupKey);
              });
              widget.onRemoveCktdthGroup?.call(groupKey);
            }
          },
        ),
      );
      widgets.add(const SizedBox(height: 8));
    });

    return widgets;
  }
  
  // Voucher card with checkbox (for ALL 3 types - multiple selection)
  Widget _buildVoucherCheckboxCard({
    required String id,  
    required String type,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
    bool hasArrow = false, // For CKN - show arrow to indicate dialog
  }) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: onChanged,
              activeColor: iconColor,
            ),
            
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow for CKN (indicates dialog will open)
            if (hasArrow && isSelected) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Đổi',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else if (hasArrow && !isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
            ],
          ],
        ),
      ),
    );
  }

  // Allow parent widget to force unselect when user cancels gift dialog
  void unselectCknGroup(String groupKey) {
    if (!_selectedCknGroups.contains(groupKey)) return;
    setState(() {
      _selectedCknGroups.remove(groupKey);
    });
    widget.onRemoveCknGroup?.call(groupKey);
  }

  void unselectCktdthGroup(String groupKey) {
    if (!_selectedCktdthGroups.contains(groupKey)) return;
    setState(() {
      _selectedCktdthGroups.remove(groupKey);
    });
    widget.onRemoveCktdthGroup?.call(groupKey);
  }
}

