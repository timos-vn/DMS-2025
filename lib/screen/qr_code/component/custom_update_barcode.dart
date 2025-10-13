import 'dart:async';
import 'package:dms/themes/colors.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/screen/qr_code/component/lot_selection_bloc.dart';

import '../../../model/network/response/dynamic_api_response.dart';

class UpdateBarCode extends StatefulWidget {
  final String? barcode;
  final String? hsd;
  final String? maVt; // Thêm maVt để gọi API lấy danh sách lô
  final String? selectedLotCode; // Mã lô đã chọn
  final String? selectedLotName; // Tên lô đã chọn

  const UpdateBarCode({super.key, this.barcode, this.hsd, this.maVt, this.selectedLotCode, this.selectedLotName});

  @override
  State<UpdateBarCode> createState() => _UpdateBarCodeState();
}

class _UpdateBarCodeState extends State<UpdateBarCode> {

  TextEditingController barcodeController = TextEditingController();
  TextEditingController hsdController = TextEditingController();

  FocusNode focusBarcode = FocusNode();
  FocusNode focusHSD = FocusNode();

  // Thêm các thuộc tính cho chức năng chọn Mã Lô
  LotData? selectedLot;
  String searchValue = '';
  int pageIndex = 1;
  int pageSize = 10;
  late LotSelectionBloc _lotSelectionBloc;
  Timer? _debounceTimer;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with empty strings instead of null
    barcodeController.text = widget.barcode?.toString().replaceAll('null', '') ?? '';
    hsdController.text = widget.hsd?.toString().replaceAll('null', '') ?? '';
    
    print('=== UPDATE BARCODE: initState ===');
    print('maVt: ${widget.maVt}');
    print('barcode: ${widget.barcode}');
    print('hsd: ${widget.hsd}');
    print('selectedLotCode: ${widget.selectedLotCode}');
    print('selectedLotName: ${widget.selectedLotName}');
    
    // Khởi tạo selectedLot nếu có thông tin đã chọn
    if (widget.selectedLotCode != null && widget.selectedLotCode!.isNotEmpty) {
      selectedLot = LotData(
        maLo: widget.selectedLotCode,
        tenLo: widget.selectedLotName,
        ngayHhsd: widget.hsd, // Sử dụng HSD hiện tại
      );
      print('=== UPDATE BARCODE: Initialized selectedLot ===');
      print('maLo: ${selectedLot?.maLo}');
      print('tenLo: ${selectedLot?.tenLo}');
    }
    
    // Khởi tạo bloc
    _lotSelectionBloc = LotSelectionBloc(
      networkFactory: NetWorkFactory(context),
    );
    
    // Gọi API lấy danh sách lô nếu có maVt
    if (widget.maVt != null && widget.maVt!.isNotEmpty) {
      print('=== UPDATE BARCODE: Calling _loadLotList from initState ===');
      _loadLotList();
    } else {
      print('=== UPDATE BARCODE: maVt is null or empty, not calling API ===');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _lotSelectionBloc.close();
    searchController.dispose();
    super.dispose();
  }

  // Phương thức gọi API lấy danh sách lô
  void _loadLotList() {
    if (widget.maVt == null || widget.maVt!.isEmpty) {
      print('=== UPDATE BARCODE: maVt is null or empty ===');
      return;
    }
    
    print('=== UPDATE BARCODE: Loading lot list ===');
    print('maVt: ${widget.maVt}');
    print('searchValue: $searchValue');
    print('pageIndex: $pageIndex');
    print('pageSize: $pageSize');
    
    _lotSelectionBloc.add(LoadLotListEvent(
      maVt: widget.maVt!,
      searchValue: searchValue,
      pageIndex: pageIndex,
      pageSize: pageSize,
    ));
  }

  // Phương thức chọn lô trong dialog
  void _selectLotInDialog(LotData lot, StateSetter setDialogState, ValueNotifier<LotData?> dialogSelectedLotNotifier) {
    print('=== UPDATE BARCODE: _selectLotInDialog called ===');
    print('Selected lot: ${lot.maLo} - ${lot.tenLo}');
    print('HSD: ${lot.ngayHhsd}');
    print('Current dialogSelectedLot: ${dialogSelectedLotNotifier.value?.maLo}');
    
    // Cơ chế tap: lần 1 chọn, lần 2 bỏ chọn, tap sang item khác chọn item mới
    if (dialogSelectedLotNotifier.value?.maLo == lot.maLo) {
      // Nếu đã chọn cùng item, bỏ chọn
      print('=== UPDATE BARCODE: Deselecting same lot ===');
      dialogSelectedLotNotifier.value = null;
    } else {
      // Chọn item mới
      print('=== UPDATE BARCODE: Selecting new lot ===');
      dialogSelectedLotNotifier.value = lot;
    }
    
    // Rebuild dialog
    setDialogState(() {});
  }

  // Phương thức debounce search
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      print('=== UPDATE BARCODE: Debounce search triggered ===');
      print('Search value: $value');
      setState(() {
        searchValue = value;
        pageIndex = 1;
      });
      _loadLotList();
    });
  }

  // Format HSD theo định dạng yyyy-MM-dd
  String _formatHSD(String input) {
    // Remove all non-digit characters
    String digits = input.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limit to 8 digits (yyyyMMdd)
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }
    
    // Format as yyyy-MM-dd
    if (digits.length >= 4) {
      String year = digits.substring(0, 4);
      String month = digits.length >= 6 ? digits.substring(4, 6) : '';
      String day = digits.length >= 8 ? digits.substring(6, 8) : '';
      
      if (month.isNotEmpty && day.isNotEmpty) {
        return '$year-$month-$day';
      } else if (month.isNotEmpty) {
        return '$year-$month';
      } else {
        return year;
      }
    }
    
    return digits;
  }

  // Phương thức hiển thị dialog chọn lô
  Future<LotData?> _showLotSelectionDialog() {
    print('=== UPDATE BARCODE: _showLotSelectionDialog called ===');
    print('maVt: ${widget.maVt}');
    print('searchValue: $searchValue');
    print('pageIndex: $pageIndex');
    
    // Reset search và gọi API ngay khi mở popup
    searchController.clear();
    setState(() {
      searchValue = '';
      pageIndex = 1;
    });
    _loadLotList();
    
    // Biến để lưu lô được chọn trong dialog - khởi tạo với lô đã chọn hiện tại
    final dialogSelectedLotNotifier = ValueNotifier<LotData?>(selectedLot);
    
    return showDialog<LotData?>(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _lotSelectionBloc,
        child: BlocListener<LotSelectionBloc, LotSelectionState>(
          listener: (context, state) {
            if (state is LotSelectionError) {
              Utils.showCustomToast(context, Icons.error, state.message);
            }
          },
          child: BlocBuilder<LotSelectionBloc, LotSelectionState>(
            builder: (context, state) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: subColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(EneftyIcons.box_outline, color: subColor, size: 24),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Chọn Mã Lô',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context, null),
                              icon: const Icon(Icons.close, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Search field
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return TextField(
                              controller: searchController,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm mã lô...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search, 
                                  color: subColor,
                                  size: 18,
                                ),
                                suffixIcon: searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          searchController.clear();
                                          setState(() {});
                                          _onSearchChanged('');
                                        },
                                        icon: Icon(
                                          Icons.clear, 
                                          color: Colors.grey[500],
                                          size: 18,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: subColor.withOpacity(0.2)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: subColor.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: subColor, width: 1.5),
                                ),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.03),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {});
                                _onSearchChanged(value);
                              },
                            );
                          },
                        ),
                      ),
                      // List lô
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: StatefulBuilder(
                              builder: (context, setDialogState) {
                                return ValueListenableBuilder<LotData?>(
                                  valueListenable: dialogSelectedLotNotifier,
                                  builder: (context, dialogSelectedLot, child) {
                                    return state is LotSelectionLoading
                                    ? const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(color: subColor),
                                            SizedBox(height: 16),
                                            Text('Đang tải danh sách lô...'),
                                          ],
                                        ),
                                      )
                                    : state is LotSelectionLoaded
                                        ? state.listLot.isEmpty
                                            ? const Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                                                    SizedBox(height: 16),
                                                    Text(
                                                      'Không có dữ liệu',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : ListView.builder(
                                                itemCount: state.listLot.length,
                                                itemBuilder: (context, index) {
                                                  final lot = state.listLot[index];
                                                  final isSelected = dialogSelectedLot?.maLo == lot.maLo;
                                                  return Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? subColor.withOpacity(0.1) : Colors.white,
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(
                                                        color: isSelected ? subColor : Colors.grey.withOpacity(0.2),
                                                        width: isSelected ? 2 : 1,
                                                      ),
                                                    ),
                                                    child: ListTile(
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      leading: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: isSelected ? subColor : Colors.grey.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Icon(
                                                          EneftyIcons.box_outline,
                                                          color: isSelected ? Colors.white : Colors.grey,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        lot.tenLo ?? '',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: isSelected ? subColor : Colors.black87,
                                                        ),
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            'Mã lô: ${lot.maLo ?? ''}',
                                                            style: TextStyle(
                                                              color: Colors.grey[600],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            lot.ngayHhsd != null && lot.ngayHhsd!.isNotEmpty
                                                                ? 'HSD: ${DateTime.parse(lot.ngayHhsd!).toLocal().toString().split(' ')[0]}'
                                                                : 'HSD: N/A',
                                                            style: TextStyle(
                                                              color: Colors.grey[600],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          if (isSelected) ...[
                                                            const SizedBox(height: 2),
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: subColor.withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(4),
                                                                border: Border.all(color: subColor.withOpacity(0.3)),
                                                              ),
                                                              child: Text(
                                                                'Đã chọn',
                                                                style: TextStyle(
                                                                  color: subColor,
                                                                  fontSize: 10,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                      trailing: isSelected
                                                          ? const Icon(Icons.check_circle, color: subColor, size: 24)
                                                          : const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24),
                                                      onTap: () => _selectLotInDialog(lot, setDialogState, dialogSelectedLotNotifier),
                                                    ),
                                                  );
                                                },
                                              )
                                        : const Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                                                SizedBox(height: 16),
                                                Text(
                                                  'Không có dữ liệu',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Pagination
                      if (state is LotSelectionLoaded && state.totalPage > 1)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: pageIndex > 1 ? () {
                                  print('=== UPDATE BARCODE: Previous page ===');
                                  print('Current page: $pageIndex');
                                  setState(() {
                                    pageIndex--;
                                  });
                                  _loadLotList();
                                } : null,
                                icon: Icon(
                                  Icons.chevron_left,
                                  color: pageIndex > 1 ? subColor : Colors.grey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: subColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Trang $pageIndex/${state.totalPage}',
                                  style: const TextStyle(
                                    color: subColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: pageIndex < state.totalPage ? () {
                                  print('=== UPDATE BARCODE: Next page ===');
                                  print('Current page: $pageIndex');
                                  setState(() {
                                    pageIndex++;
                                  });
                                  _loadLotList();
                                } : null,
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: pageIndex < state.totalPage ? subColor : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Action buttons
                      ValueListenableBuilder<LotData?>(
                        valueListenable: dialogSelectedLotNotifier,
                        builder: (context, dialogSelectedLot, child) {
                          return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context, null),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    side: BorderSide.none,
                                  ),
                                  child: Text(
                                    'Hủy',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: [subColor, subColor.withOpacity(0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: dialogSelectedLot != null ? () {
                                    print('=== UPDATE BARCODE: Confirm lot selection ===');
                                    print('Selected lot: ${dialogSelectedLot.maLo} - ${dialogSelectedLot.tenLo}');
                                    
                                    // Gửi event khi xác nhận
                                    _lotSelectionBloc.add(SelectLotEvent(dialogSelectedLot));
                                    
                                    // Cập nhật HSD khi xác nhận chọn lô
                                    if (dialogSelectedLot.ngayHhsd != null && dialogSelectedLot.ngayHhsd!.isNotEmpty) {
                                      try {
                                        final date = DateTime.parse(dialogSelectedLot.ngayHhsd!);
                                        hsdController.text = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                      } catch (e) {
                                        hsdController.text = dialogSelectedLot.ngayHhsd ?? '';
                                      }
                                    } else {
                                      hsdController.text = '';
                                    }
                                    
                                    Navigator.pop(context, dialogSelectedLot);
                                  } : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Xác nhận',
                                    style: TextStyle(
                                      color: dialogSelectedLot != null ? Colors.white : Colors.grey[400],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.white,),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.38,
                minHeight: 330,
              ),
              width: double.infinity,
              child: Material(
                  animationDuration: const Duration(seconds: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Column(
                    children: [
                      Flexible(
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Cập nhật Barcode & HSD',
                                      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    InkWell(
                                      onTap: ()=> Navigator.pop(context),
                                      child: const Icon(Icons.clear,color: Colors.black,),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8,),
                                // Nút chọn Mã Lô
                                if (widget.maVt != null && widget.maVt!.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: InkWell(
                                      onTap: () async {
                                        focusBarcode.unfocus();
                                        focusHSD.unfocus();
                                        FocusScope.of(context).unfocus();
                                        
                                        final result = await _showLotSelectionDialog();
                                        if (result != null) {
                                          setState(() {
                                            selectedLot = result;
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 45,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: subColor.withOpacity(0.3)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(left: 14, right: 8),
                                              child: Icon(EneftyIcons.box_outline, size: 18, color: subColor),
                                            ),
                                            Expanded(
                                              child: Text(
                                                selectedLot != null 
                                                    ? 'Mã lô: ${selectedLot!.maLo} - ${selectedLot!.tenLo}'
                                                    : 'Chọn Mã Lô (LOT)',
                                                style: TextStyle(
                                                  color: selectedLot != null ? Colors.black : Colors.grey,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.only(right: 12),
                                              child: Icon(Icons.arrow_drop_down, color: subColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                // TextField HSD
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tiêu đề HSD
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4, bottom: 8),
                                      child: Text(
                                        'Hạn sử dụng (HSD)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: subColor,
                                        ),
                                      ),
                                    ),
                                    // TextField HSD
                                    Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: subColor.withOpacity(0.3)),
                                        color: Colors.grey.withOpacity(0.05),
                                      ),
                                      child: TextField(
                                        maxLines: 1,
                                        controller: hsdController,
                                        focusNode: focusHSD,
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            final formatted = _formatHSD(value);
                                            if (formatted != value) {
                                              hsdController.value = hsdController.value.copyWith(
                                                text: formatted,
                                                selection: TextSelection.collapsed(offset: formatted.length),
                                              );
                                            }
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Nhập HSD',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                          ),
                                          prefixIcon: const Icon(
                                            EneftyIcons.calendar_3_outline,
                                            color: subColor,
                                            size: 20,
                                          ),
                                          suffixIcon: hsdController.text.isNotEmpty
                                              ? IconButton(
                                                  onPressed: () {
                                                    hsdController.clear();
                                                    setState(() {});
                                                  },
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: Colors.grey[500],
                                                    size: 18,
                                                  ),
                                                  padding: const EdgeInsets.all(8),
                                                  constraints: const BoxConstraints(
                                                    minWidth: 32,
                                                    minHeight: 32,
                                                  ),
                                                )
                                              : null,
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.datetime,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // TextField Barcode
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tiêu đề Barcode
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4, bottom: 8),
                                      child: Text(
                                        'Mã Barcode',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: subColor,
                                        ),
                                      ),
                                    ),
                                    // TextField Barcode
                                    Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: subColor.withOpacity(0.3)),
                                        color: Colors.grey.withOpacity(0.05),
                                      ),
                                      child: TextField(
                                        maxLines: 1,
                                        autofocus: false,
                                        controller: barcodeController,
                                        focusNode: focusBarcode,
                                        decoration: InputDecoration(
                                          hintText: 'Nhập mã barcode sản phẩm',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                          ),
                                          prefixIcon: const Icon(
                                            EneftyIcons.scan_barcode_outline,
                                            color: subColor,
                                            size: 20,
                                          ),
                                          suffixIcon: barcodeController.text.isNotEmpty
                                              ? IconButton(
                                                  onPressed: () {
                                                    barcodeController.clear();
                                                    setState(() {});
                                                  },
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: Colors.grey[500],
                                                    size: 18,
                                                  ),
                                                  padding: const EdgeInsets.all(8),
                                                  constraints: const BoxConstraints(
                                                    minWidth: 32,
                                                    minHeight: 32,
                                                  ),
                                                )
                                              : null,
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.text,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              ),
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10,top: 10),
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: subColor,
                          ),
                          child: InkWell(
                            onTap: (){
                              print('=== UPDATE BARCODE: Confirm button tapped ===');
                              print('Barcode: ${barcodeController.text}');
                              print('HSD: ${hsdController.text}');
                              print('Selected lot: ${selectedLot?.maLo} - ${selectedLot?.tenLo}');
                              
                              // Trả về dữ liệu với mã lô đã chọn
                              Navigator.pop(context, [
                                barcodeController.text.trim(),
                                hsdController.text.trim(),
                                selectedLot?.maLo ?? '',
                                selectedLot?.tenLo ?? '',
                              ]);
                            },
                            child: const Align(
                                alignment: Alignment.center,
                                child: Text('Xác nhận',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                    ],
                  )),
            ),
          ],
        ));
  }
}