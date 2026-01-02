import 'package:dms/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:dms/model/network/response/list_tax_response.dart';
import 'package:dms/model/database/data_local.dart';

/// Bottom sheet để chọn thuế
/// Load danh sách thuế từ API khi mở bottom sheet
class TaxSelectionSheet extends StatefulWidget {
  final GetListTaxResponseData? selectedTax;
  final Function(GetListTaxResponseData) onTaxSelected;
  final Future<List<GetListTaxResponseData>> Function()? onLoadTaxList;

  const TaxSelectionSheet({
    Key? key,
    this.selectedTax,
    required this.onTaxSelected,
    this.onLoadTaxList,
  }) : super(key: key);

  @override
  State<TaxSelectionSheet> createState() => _TaxSelectionSheetState();
}

class _TaxSelectionSheetState extends State<TaxSelectionSheet> {
  List<GetListTaxResponseData> _taxList = [];
  bool _isLoading = true;
  String? _errorMessage;
  GetListTaxResponseData? _selectedTax; // Tax được chọn tạm thời (chưa confirm)

  @override
  void initState() {
    super.initState();
    _selectedTax = widget.selectedTax; // Khởi tạo với tax hiện tại
    _loadTaxList();
  }

  Future<void> _loadTaxList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<GetListTaxResponseData> taxList = [];
      
      // Nếu có callback để load từ API
      if (widget.onLoadTaxList != null) {
        taxList = await widget.onLoadTaxList!();
      } else {
        // Fallback: dùng DataLocal.listTax nếu có
        if (DataLocal.listTax.isNotEmpty) {
          taxList = DataLocal.listTax;
        }
      }

      // ✅ Tự động thêm option "Không áp dụng thuế" vào đầu danh sách
      if (taxList.isNotEmpty) {
        GetListTaxResponseData noTaxOption = GetListTaxResponseData(
          maThue: '#000',
          tenThue: 'Không áp dụng thuế cho đơn hàng này',
          thueSuat: 0.0,
        );
        
        // Chỉ thêm nếu chưa có
        bool hasNoTaxOption = taxList.any((tax) => tax.maThue?.trim() == '#000');
        if (!hasNoTaxOption) {
          taxList.insert(0, noTaxOption);
        }
      }

      setState(() {
        _taxList = taxList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải danh sách thuế: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Chọn thuế',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Content
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTaxList,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          else if (_taxList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Không có dữ liệu thuế'),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _taxList.length,
                itemBuilder: (context, index) {
                  final tax = _taxList[index];
                  final isSelected = _selectedTax?.maThue == tax.maThue;
                  
                  return InkWell(
                    onTap: () {
                      // Chỉ update state, không gọi callback ngay
                      setState(() {
                        _selectedTax = tax;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tax.tenThue ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? subColor
                                        : Colors.black,
                                  ),
                                ),
                                if (tax.maThue?.trim() != '#000' &&
                                    tax.thueSuat != null)
                                  const SizedBox(height: 4),
                                if (tax.maThue?.trim() != '#000' &&
                                    tax.thueSuat != null)
                                  Text(
                                    'Mã thuế: ${tax.maThue ?? ''} - ${tax.thueSuat}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Colors.blue.shade700,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // ✅ Buttons "Huỷ" và "Chọn"
          if (!_isLoading && _errorMessage == null && _taxList.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  // Button "Huỷ"
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Huỷ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Button "Chọn"
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedTax != null
                          ? () {
                              // Gọi callback và đóng sheet
                              widget.onTaxSelected(_selectedTax!);
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Chọn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

