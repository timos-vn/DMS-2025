import 'dart:async';
import 'package:dms/model/entity/product.dart';
import 'package:dms/model/network/response/contract_reponse.dart';
import 'package:dms/screen/sell/cart/cart_screen.dart';
import 'package:dms/screen/sell/contract/component/create_order_dialog.dart';
import 'package:dms/screen/sell/contract/component/popup_order_from_contract.dart';
import 'package:dms/screen/sell/contract/component/popup_update_quantity_contract.dart';
import 'package:dms/screen/sell/contract/component/skeleton_loading.dart';
import 'package:dms/screen/sell/contract/component/warning_dialog.dart';
import 'package:dms/screen/sell/contract/contract_bloc.dart';
import 'package:dms/screen/sell/contract/contract_event.dart';
import 'package:dms/screen/sell/contract/contract_state.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class DetailContractScreen extends StatefulWidget {
  const DetailContractScreen({
    super.key, 
    required this.contractMaster, 
    required this.isSearchItem,
    this.cartItems, // Thêm danh sách sản phẩm từ giỏ hàng
  });

  final ContractItem contractMaster;
  final bool isSearchItem;
  final List<dynamic>? cartItems; // Có thể là List<Product> hoặc List<SearchItemResponseData>

  @override
  _DetailContractScreenState createState() => _DetailContractScreenState();
}

class _DetailContractScreenState extends State<DetailContractScreen> with TickerProviderStateMixin{

  late ContractBloc _bloc;
  final Set<String> selectedItemIds = {}; // stt_rec0 làm key định danh
  // Thêm map để lưu số lượng đã chọn cho từng item
  final Map<String, double> selectedQuantities = {};
  // Cache maVt2 của các items đã chọn để tính toán khi phân trang
  final Map<String, String> selectedItemMaVt2 = {}; // sttRec0 → maVt2
  // Cache thông tin đầy đủ của items đã chọn để add vào giỏ khi phân trang
  final Map<String, ListItem> selectedItemsCache = {}; // sttRec0 → ListItem
  int addedCount = 0;
  TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = ContractBloc(context);
    _bloc.add(GetContractPrefsEvent());
  }

  void _refreshDataIfNeeded() {
    // Refresh dữ liệu khi cần thiết
    if (widget.isSearchItem) {
      _bloc.add(GetCountProductEvent(isNextScreen: false));
    } else {
      _bloc.add(GetDetailContractEvent(
        searchKey: Utils.convertKeySearch(searchController.text),
        pageIndex: selectedPage, 
        sttRec: widget.contractMaster.sttRec.toString(),
        date: widget.contractMaster.ngayCt.toString().split('T').first, 
        isSearchItem: widget.isSearchItem,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ContractBloc,ContractState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            if(widget.isSearchItem){
              _bloc.add(GetCountProductEvent(isNextScreen: false));
            }else{
              _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
            }
          }
          else if(state is DeleteProductInCartSuccess){

          }
          else if(state is ContractOrderListLoading){
            // Hiển thị loading dialog chuyên nghiệp
            _showLoadingDialog(context);
          }
          else if(state is AddCartSuccess){
            if(widget.isSearchItem){
              // Hiển thị dialog thành công thay cho SnackBar
              _showSuccessDialog(
                context,
                title: 'Thêm vào giỏ hàng',
                message: 'Đã thêm $addedCount vật tư vào giỏ hàng',
              ).then((_) {
                // Quay về màn cart_screen sau khi đóng dialog
                Navigator.pop(context, 'refresh_cart');
              });
            }else{
                _bloc.add(GetCountProductEvent(isNextScreen: true));
              }
            }
          else if(state is GetListOrderFormContractSuccess){
            // Đóng loading dialog
            Navigator.of(context, rootNavigator: true).pop();
            
            if (_bloc.listOrderFormContract.isNotEmpty) {
              OrderListBottomSheet.show(context, _bloc.listOrderFormContract,widget.contractMaster);
            } else {
              _showNoOrdersDialog(context);
            }
          }
          else if(state is GetCountProductSuccess){
            if(state.isNextScreen == true){
             
            }else{
              for (var element in _bloc.listProduct) {
                selectedItemIds.add(element.code.toString());
              }
              _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
            }
          }
          else if(state is GetDetailContractSuccess){

          }
          else if(state is ContractFailure){
            // Đóng loading dialog nếu có lỗi
            try {
              Navigator.of(context, rootNavigator: true).pop();
            } catch (e) {
              // Dialog không tồn tại
            }
            
          // Hiển thị dialog lỗi thay cho SnackBar
          _showErrorDialog(
            context,
            title: 'Có lỗi xảy ra',
            message: state.error,
          );
          }
        },
        child: BlocBuilder<ContractBloc,ContractState>(
          bloc: _bloc,
          builder: (BuildContext context, ContractState state){
            // Initial loading - hiển thị skeleton
            if (state is ContractInitialLoading) {
              return Column(
                children: [
                  buildAppBar(),
                  Expanded(
                    child: SkeletonMaterialList(
                      showMasterInfo: widget.isSearchItem == false,
                    ),
                  ),
                ],
              );
            }
            
            // Default: hiển thị nội dung với các loading khác
            return Stack(
              children: [
                buildBody(context, state), 
                // Pagination loading - Shimmer overlay
                if (state is ContractPaginationLoading)
                  Positioned.fill(
                    top: 83, // Sau AppBar
                    child: ShimmerOverlay(
                      showMasterInfo: widget.isSearchItem == false,
                    ),
                  ),
                // Fallback: Loading cũ (nếu có state khác)
                Visibility(
                  visible: state is ContractLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,ContractState state){
    return Container(
      color: Colors.grey[100], // Background color để card nổi bật
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Master Info (không scroll)
                if (widget.isSearchItem == false) _buildMasterInfo(),
                if (widget.isSearchItem == false) Divider(height: 1, thickness: 1, color: Colors.grey[300]),
                
                // Material List (scrollable với pull-to-refresh)
                Expanded(
                  child: RefreshIndicator(
                    color: mainColor,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      _bloc.listItemProduct.clear();
                      // Trigger refresh event
                      if (widget.isSearchItem) {
                        _bloc.add(GetCountProductEvent(isNextScreen: false));
                      } else {
                        _bloc.add(GetDetailContractEvent(
                          searchKey: Utils.convertKeySearch(searchController.text),
                          pageIndex: selectedPage, 
                          sttRec: widget.contractMaster.sttRec.toString(),
                          date: widget.contractMaster.ngayCt.toString().split('T').first, 
                          isSearchItem: widget.isSearchItem
                        ));
                      }
                      // Wait for loading to complete
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: Column(
                  children: [
                    Expanded(child: _buildMaterialList()),
                        if (_bloc.totalPager > 1) _getDataPager(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
                Divider(height: 1, thickness: 1, color: Colors.grey[300]),
                widget.isSearchItem == true
                    ?
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: selectedItemIds.isEmpty ? null : _addSelectedItemsToCart,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: selectedItemIds.isEmpty 
                              ? null 
                              : LinearGradient(
                                  colors: [mainColor, subColor],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          color: selectedItemIds.isEmpty ? Colors.grey[300] : null,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: selectedItemIds.isEmpty 
                              ? null 
                              : [
                                  BoxShadow(
                                    color: mainColor.withOpacity(0.3),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: selectedItemIds.isEmpty ? Colors.grey[600] : Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedItemIds.isEmpty 
                                  ? 'Chọn vật tư để thêm vào giỏ'
                                  : 'Thêm ${selectedItemIds.length} vật tư vào giỏ',
                              style: TextStyle(
                                color: selectedItemIds.isEmpty ? Colors.grey[600] : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: selectedItemIds.isEmpty ? Colors.grey[600] : Colors.white,
                              size: 20,
                            ),
                          ],
                      ),
                    ),
                  ),
                ),
              )
                  :
              _buildBottomTotal(_bloc.payment.tongTien??0, _bloc.payment.tongCk??0, _bloc.payment.tongThue??0, _bloc.payment.tongThanhToan??0),
              const SizedBox(height: 15,),
        ],
      ),
    );
  }

  // Helper method to safely display text without 'null'
  String _safeText(dynamic value, {String defaultValue = '---'}) {
    if (value == null) return defaultValue;
    String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return defaultValue;
    return text;
  }

  // Helper method to format money - chỉ hiển thị thập phân khi cần
  String _formatMoney(dynamic value) {
    if (value == null) return '0';
    try {
      double amount = double.parse(value.toString());
      // Nếu là số nguyên, không hiển thị phần thập phân
      if (amount == amount.roundToDouble()) {
        final formatter = NumberFormat('#,##0', 'en_US');
        return formatter.format(amount);
      }
      // Nếu có phần thập phân, format với separator
      final formatter = NumberFormat('#,##0.##', 'en_US');
      return formatter.format(amount);
    } catch (e) {
      return '0';
    }
  }

  Widget _buildMasterInfo() {
    final statusText = widget.contractMaster.statusname.toString().contains('Lập') 
        ? 'Chờ duyệt' 
        : _safeText(widget.contractMaster.statusname);
    final statusColor = statusText == 'Duyệt' ? Colors.green : Colors.orange;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mainColor.withOpacity(0.05),
            subColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mainColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.description,
                  size: 16,
                  color: mainColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'HĐ: ${_safeText(widget.contractMaster.soCt)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusText == 'Duyệt' ? Icons.check_circle : Icons.schedule,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Compact customer info
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${_safeText(widget.contractMaster.maKh)} - ${_safeText(widget.contractMaster.tenKh)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialList() {

    
    // Lọc bỏ vật tư đã có trong giỏ hàng khi isSearchItem = true
    List<ListItem> filteredItems = _bloc.listItemProduct;

    if (widget.isSearchItem && widget.cartItems != null) {
      filteredItems = _bloc.listItemProduct.where((item) { 
        // Kiểm tra xem vật tư này đã có trong giỏ hàng chưa - sử dụng sttRec0 để so sánh
        bool existsInCart = widget.cartItems!.any((cartItem) => cartItem.sttRec0 == item.sttRec0);
        return !existsInCart; // Chỉ hiển thị vật tư chưa có trong giỏ hàng
      }).toList();
    }

    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        print(item.slDh);
        print(item.giaNt2);
        
        // ✅ Tính totalCurrent (số lượng hiện tại)
        double currentInCart = _getQuantityFromCartForItem(item.sttRec0);
        double currentSelected = selectedQuantities[item.sttRec0] ?? 0;
        double totalCurrent = currentInCart + currentSelected;
        
        // ✅ Tính tổng tiền
        // - Search item mode: totalCurrent * đơn giá
        // - Normal mode: slDh (số lượng A) * đơn giá
        double tong = widget.isSearchItem 
            ? (totalCurrent * item.giaNt2)
            : (item.slDh * item.giaNt2);
        
        // Tìm index trong list gốc để cập nhật trạng thái
        int originalIndex = _bloc.listItemProduct.indexWhere((element) => element.sttRec0 == item.sttRec0);
        if (originalIndex != -1) {
          _bloc.listItemProduct[originalIndex].isCheck = selectedItemIds.contains(item.sttRec0);
        }
        return _buildMaterialCard(item, originalIndex, totalCurrent, tong);
      },
    );
  }

  Widget _buildMaterialCard(ListItem item, int originalIndex, double totalCurrent, double tong) {
    final isChecked = _bloc.listItemProduct[originalIndex].isCheck ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked && widget.isSearchItem 
              ? mainColor.withOpacity(0.5) 
              : Colors.grey.withOpacity(0.15),
          width: isChecked && widget.isSearchItem ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if(widget.isSearchItem == true){
              _handleItemSelection(originalIndex, item, !isChecked);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Product name & checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _safeText(item.maVt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _safeText(item.tenVt),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isSearchItem)
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          _handleItemSelection(originalIndex, item, value ?? false);
                        },
                        activeColor: mainColor,
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 12),
                
                // Kho

                  _buildCompactDetailRow(
                    icon: Icons.warehouse,
                  label: 'Tổng tồn kho',
                  value: '${Utils.formatDecimal(item.soLuongTonKho, withSeparator: true)} ${_safeText(item.dvt)}',
                    iconColor: Colors.orange,
                  ),
                
                // Số lượng
                const SizedBox(height: 8),
                _buildCompactDetailRow(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Số lượng (ĐH/CL)',
                  value: widget.isSearchItem 
                      ? _buildQuantityDisplayForSearchItem(item)
                      : '${Utils.formatDecimal(item.slDh, withSeparator: true)}/${Utils.formatDecimal(item.so_luong_kd, withSeparator: true)} ${_safeText(item.dvt)}',
                  iconColor: widget.isSearchItem 
                      ? (_getAvailableQuantityForItem(item.maVt, item.maVt2, item.so_luong_kd) > 0 ? Colors.green : Colors.red)
                      : (item.slDh < item.so_luong_kd ? Colors.green : Colors.grey),
                  highlight: true,
                ),
                
                // Đơn giá
                const SizedBox(height: 8),
                _buildCompactDetailRow(
                  icon: Icons.payments_outlined,
                  label: 'Đơn giá (trước VAT)',
                  value: '${_formatMoney(item.giaNt2)} đ',
                  iconColor: Colors.purple, 
                ),

                // Thuế (nếu có) - chỉ hiển thị ở normal mode
                if (widget.isSearchItem == false && _safeText(item.thueSuat) != '---' && item.thueSuat.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildCompactDetailRow(
                    icon: Icons.receipt_outlined,
                    label: 'Thuế suất',
                    value: '${Utils.formatDecimal(item.thueSuat)}%',
                    iconColor: Colors.teal,
                  ),
                ],
                
                // Tổng sau CK & thuế - chỉ hiển thị ở normal mode
                if (widget.isSearchItem == false) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Icon(Icons.calculate_outlined, size: 18, color: mainColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Tổng sau CK & thuế',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_formatMoney(tong)} đ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ],
                ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool highlight = false,
  }) {
    // Ẩn trường nếu giá trị rỗng hoặc "null"
    if (value.isEmpty || value.trim() == 'null' || value.trim() == '---') {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: highlight ? iconColor : Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTotal(double tien, double ck, double thue, double tong) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              mainColor.withOpacity(0.08),
              subColor.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: mainColor.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Row 1: Tổng tiền & Thuế (2 columns)
            Row(
              children: [
                Expanded(
                  child: _buildCompactTotalItem(
                    icon: Icons.attach_money,
                    label: 'Tổng tiền',
                    value: tien,
                    iconColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactTotalItem(
                    icon: Icons.receipt_outlined,
                    label: 'Tổng thuế',
                    value: thue,
                    iconColor: Colors.teal,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            Divider(height: 1, thickness: 1.5, color: mainColor.withOpacity(0.3)),
            const SizedBox(height: 10),
            
            // Row 2: Tổng thanh toán (highlighted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, size: 18, color: mainColor),
                      const SizedBox(width: 8),
                      Text(
                        'Tổng thanh toán',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_formatMoney(tong)} đ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTotalItem({
    required IconData icon,
    required String label,
    required double value,
    required Color iconColor,
    bool fullWidth = false,
  }) {
    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${_formatMoney(value)} đ',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildAppBar(){
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient:const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: StatefulBuilder(
          builder: (context, setState) {
            Timer? debounce;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: ()=> Navigator.pop(context),
                  child: const SizedBox(
                    width: 40,
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      focusNode: _searchFocus,
                      onChanged: (value) {
                        if (debounce?.isActive ?? false) debounce!.cancel();
                        debounce = Timer(const Duration(milliseconds: 500), () {
                          _bloc.listItemProduct.clear();
                          _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Tên vật tư hoặc mã vật tư ...',
                        hintStyle: const TextStyle(color: Colors.white70,fontSize: 13),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 1),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            searchController.text = '';
                            // _searchFocus.requestFocus();
                            _bloc.listItemProduct.clear();
                            _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
                          },
                          child: const Icon( Icons.clear, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.isSearchItem == false,
                  child: InkWell(
                    onTap: (){
                      _bloc.add(GetListOrderFormContractEvent(soCt: widget.contractMaster.soCt.toString()));
                    },
                    child: const SizedBox(
                      width: 40,
                      height: 50,
                      child: Icon(
                        Icons.badge,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.isSearchItem == false,
                  child:                   InkWell(
                    onTap: (){
                      // Kiểm tra trạng thái đơn - không cho tạo đơn nếu đang "Chờ duyệt"
                      if (widget.contractMaster.statusname.toString().contains('Lập')) {
                        showPendingStatusWarning(
                          context,
                          widget.contractMaster.soCt.toString().trim(),
                        );
                        return;
                      }
                      
                      // Kiểm tra số lượng khả dụng từ bloc.payment
                      if (_bloc.payment.soLuongKhaDung == null || _bloc.payment.soLuongKhaDung! <= 0) {
                        showNoQuantityWarning(context);
                        return;
                      }

                      showCreateOrderDialog(
                          context: context,
                        contractNumber: widget.contractMaster.soCt.toString().trim(),
                        customerName: widget.contractMaster.tenKh.toString().trim(),
                        availableQuantity: (_bloc.payment.soLuongKhaDung ?? 0).toInt(),
                      ).then((confirmed) {
                        if (confirmed == true) {
                             //_bloc.add(DeleteProductInCartEvent());
                          PersistentNavBarNavigator.pushNewScreen(
                            context, 
                            screen: CartScreen(
                                 viewUpdateOrder: false,
                                 viewDetail: false,
                                 listIdGroupProduct:  Const.listGroupProductCode,
                                 itemGroupCode:  Const.itemGroupCode,
                                 listOrder: _bloc.listProduct,
                                 orderFromCheckIn: false,
                                 title: 'Đặt hàng',
                                 currencyCode:  Const.currencyList.isNotEmpty ? Const.currencyList[0].currencyCode.toString() : '',
                                 nameCustomer: widget.contractMaster.tenKh,
                                 idCustomer: widget.contractMaster.maKh,
                                 phoneCustomer: '',
                                 addressCustomer: '',
                              codeCustomer: widget.contractMaster.maKh, 
                              loadDataLocal: true,
                                 sttRectHD: widget.contractMaster.sttRec,
                                 isContractCreateOrder: true,
                                 contractMaster: widget.contractMaster,
                            ),
                            withNavBar: false,
                          ).then((result) {
                               // Nếu có result từ cart_screen, refresh dữ liệu
                               if (result != null && result is Map && result['refresh'] == true) {
                                 // Refresh dữ liệu khi quay lại từ cart_screen sau khi đặt đơn thành công
                                 _refreshDataIfNeeded();
                               }
                             });
                           }
                      });
                    },
                    child: const SizedBox(
                      width: 40,
                      height: 50,
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  int lastPage=0;
  int selectedPage=1;

  Widget _getDataPager() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(height: 1, thickness: 1, color: Colors.grey[300]),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: (){
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = 1;
                          });
                          _bloc.listItemProduct.clear();
                          _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
                        },
                        child: const Icon(Icons.skip_previous_outlined,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          if(selectedPage > 1){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage - 1;
                            });
                            _bloc.listItemProduct.clear();
                            _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
                          }
                        },
                        child: const Icon(Icons.navigate_before_outlined,color: Colors.grey,)),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index){
                            return InkWell(
                              onTap: (){
                                setState(() {
                                  lastPage = selectedPage;
                                  selectedPage = index+1;
                                });
                                _bloc.listItemProduct.clear();
                                _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: selectedPage == (index + 1) ?  mainColor : Colors.grey[200],
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    border: Border.all(
                                      color: selectedPage == (index + 1) ? mainColor : Colors.grey.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                ),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      color: selectedPage == (index + 1) ?  Colors.white : Colors.black87,
                                      fontWeight: selectedPage == (index + 1) ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder:(BuildContext context, int index)=> Container(width: 6,),
                          itemCount: _bloc.totalPager > 10 ? 10 : _bloc.totalPager),
                    ),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          if(selectedPage < _bloc.totalPager){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage + 1;
                            });
                            _bloc.listItemProduct.clear();
                            _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
                          }
                        },
                        child: const Icon(Icons.navigate_next_outlined,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = _bloc.totalPager;
                          });
                          _bloc.listItemProduct.clear();
                          _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
                        },
                        child: const Icon(Icons.skip_next_outlined,color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }





  double _getAvailableQuantityForItem(String? maVt, String? maVt2, double soLuongKd) {
    if (maVt == null || maVt2 == null) return soLuongKd;
    
    // Tính tổng số lượng đã đặt cho maVt2 này (giống logic trong cart_screen)
    double totalOrderedForMaVt2 = 0;
    
    // Từ giỏ hàng hiện tại
    if (widget.cartItems != null) {
      for (var item in widget.cartItems!) {
        if (item.maVt2 == maVt2) {
          totalOrderedForMaVt2 += item.count ?? 0;
        }
      }
    }
    
    // Từ selectedQuantities (đang chọn trong màn này)
    // FIX: Sử dụng cache selectedItemMaVt2 thay vì tìm trong listItemProduct
    for (String selectedId in selectedItemIds) {
      // Lấy maVt2 từ cache
      String? cachedMaVt2 = selectedItemMaVt2[selectedId];
      if (cachedMaVt2 == maVt2) {
        totalOrderedForMaVt2 += selectedQuantities[selectedId] ?? 0;
      }
    }
    
    // Trả về số lượng khả dụng còn lại (giống logic trong cart_screen)
    return (soLuongKd - totalOrderedForMaVt2).clamp(0, soLuongKd);
  }

  // Method tính số lượng khả dụng KHÔNG bao gồm item hiện tại (để tránh circular logic)
  double _getAvailableQuantityExcludingCurrentItem(String? maVt, String? maVt2, double soLuongKd, String currentItemId) {
    if (maVt == null || maVt2 == null) return soLuongKd;
    
    // Tính tổng số lượng đã đặt cho maVt2 này, KHÔNG bao gồm currentItemId
    double totalOrderedForMaVt2 = 0;
    
    // Từ giỏ hàng hiện tại
    if (widget.cartItems != null) {
      for (var item in widget.cartItems!) {
        if (item.maVt2 == maVt2) {
          totalOrderedForMaVt2 += item.count ?? 0;
        }
      }
    }
    
    // Từ selectedQuantities (đang chọn trong màn này) - LOẠI TRỪ item hiện tại
    // FIX: Sử dụng cache selectedItemMaVt2 thay vì tìm trong listItemProduct
    for (String selectedId in selectedItemIds) {
      if (selectedId == currentItemId) continue; // Bỏ qua item hiện tại
      
      // Lấy maVt2 từ cache
      String? cachedMaVt2 = selectedItemMaVt2[selectedId];
      if (cachedMaVt2 == maVt2) {
        totalOrderedForMaVt2 += selectedQuantities[selectedId] ?? 0;
      }
    }
    
    // Trả về số lượng khả dụng còn lại
    return (soLuongKd - totalOrderedForMaVt2).clamp(0, soLuongKd);
  }

  double _getQuantityFromCartForItem(String? sttRec0) {
    if (sttRec0 == null || widget.cartItems == null) return 0;
    
    // Lấy dữ liệu từ giỏ hàng được truyền vào - tìm item tương ứng
    double quantityFromCart = 0;
    
    try {
      for (var item in widget.cartItems!) {
        // Tìm item có cùng sttRec0 - map 1-1
        if (item.sttRec0 == sttRec0) {
          quantityFromCart = item.count ?? 0;
          break; // Chỉ lấy item đầu tiên tìm thấy
        }
      }
    } catch (e) {
      // Fallback nếu không truy cập được
      print('Không thể lấy dữ liệu từ giỏ hàng: $e');
    }
    
    return quantityFromCart;
  }

  // Method để hiển thị số lượng theo format A/B cho search item
  String _buildQuantityDisplayForSearchItem(ListItem item) {
    // A = Số lượng hiện tại (giỏ hàng + đang chọn)
    double currentInCart = _getQuantityFromCartForItem(item.sttRec0);
    double currentSelected = selectedQuantities[item.sttRec0] ?? 0;
    double totalCurrent = currentInCart + currentSelected;
    
    // B = Số lượng khả dụng còn lại = Tổng kho - Tổng đã đặt cho maVt2
    double totalOrderedForMaVt2 = 0;
    
    // Tính tổng số lượng đã đặt cho maVt2 này
    // Từ giỏ hàng hiện tại
    if (widget.cartItems != null) {
      for (var cartItem in widget.cartItems!) {
        if (cartItem.maVt2 == item.maVt2) {
          totalOrderedForMaVt2 += cartItem.count ?? 0;
        }
      }
    }
    
    // Từ selectedQuantities (đang chọn trong màn này)
    // FIX: Sử dụng cache selectedItemMaVt2 thay vì tìm trong listItemProduct
    for (String selectedId in selectedItemIds) {
      // Lấy maVt2 từ cache
      String? cachedMaVt2 = selectedItemMaVt2[selectedId];
      if (cachedMaVt2 == item.maVt2) {
        totalOrderedForMaVt2 += selectedQuantities[selectedId] ?? 0;
      }
    }
    
    double remainingAvailable = (item.so_luong_kd - totalOrderedForMaVt2).clamp(0, item.so_luong_kd);
    
    return '${Utils.formatDecimal(totalCurrent, withSeparator: true)}/${Utils.formatDecimal(remainingAvailable, withSeparator: true)} ${item.dvt?.toString() ?? ''}';
  }



  // Method chung để add selected items vào giỏ hàng
  Future<void> _addSelectedItemsToCart() async {
    if (selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một vật tư'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    addedCount = 0;
    
    // Thêm các vật tư đã chọn vào giỏ hàng
    for (String itemId in selectedItemIds) {
      // FIX: Lấy từ cache thay vì tìm trong listItemProduct
      // Vì listItemProduct có thể không chứa items từ các trang khác
      var selectedItem = selectedItemsCache[itemId];
      
      // Nếu không có trong cache (trường hợp cũ), fallback về tìm trong listItemProduct
      if (selectedItem == null) {
        selectedItem = _bloc.listItemProduct.firstWhere(
          (item) => item.sttRec0 == itemId,
          orElse: () => ListItem(),
        );
      }
      
      if (selectedItem.maVt != null && selectedQuantities.containsKey(itemId)) {
        double selectedQty = selectedQuantities[itemId] ?? 0;
        
        // Tìm giá trị LỚN NHẤT của so_luong_kd trong các items cùng maVt2
        // Đây là TỔNG khả dụng CHUNG cho maVt2
        double totalAvailableQuantity = selectedItem.so_luong_kd;
        
        // FIX: Tìm trong cache (các items đã chọn từ tất cả các trang)
        for (var cachedItem in selectedItemsCache.values) {
          if (cachedItem.maVt2 == selectedItem.maVt2 && cachedItem.so_luong_kd > totalAvailableQuantity) {
            totalAvailableQuantity = cachedItem.so_luong_kd;
          }
        }
        
        // Tìm thêm trong trang hiện tại (nếu có items chưa chọn cùng maVt2)
        for (var item in _bloc.listItemProduct) {
          if (item.maVt2 == selectedItem.maVt2 && item.so_luong_kd > totalAvailableQuantity) {
            totalAvailableQuantity = item.so_luong_kd;
          }
        }
        
        // Tính số lượng tối đa có thể thêm VÀO GIỎ lúc này
        double currentInCart = _getQuantityFromCartForItem(itemId);
        double availableExcludingCurrent = _getAvailableQuantityExcludingCurrentItem(
          selectedItem.maVt, 
          selectedItem.maVt2, 
          totalAvailableQuantity, // Dùng giá trị MAX đã tìm được
          itemId
        );
        double maxCanAddNow = currentInCart + availableExcludingCurrent;
        
        if (selectedQty > maxCanAddNow) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vật tư ${selectedItem.maVt} vượt quá số lượng tối đa (${Utils.formatQuantity(maxCanAddNow)})'),
              backgroundColor: Colors.red,
            ),
          );
          continue; // Bỏ qua item này
        }
        
        // Tạo Product object để thêm vào giỏ hàng
        // Lưu TỔNG khả dụng gốc (so_luong_kd) vào availableQuantity để dùng chung cho maVt2
        Product product = Product(
          code: selectedItem.maVt!,
          name: selectedItem.tenVt ?? '',
          name2: selectedItem.tenVt ?? '',
          dvt: selectedItem.dvt ?? '',
          description: '',
          price: selectedItem.giaNt2,
          priceAfter: selectedItem.giaNt2,
          giaSuaDoi: selectedItem.giaNt2,
          giaGui: selectedItem.giaNt2,
          discountPercent: selectedItem.tlCk,
          stockAmount: selectedItem.so_luong_kd,
          taxPercent: selectedItem.thueSuat,
          imageUrl: '',
          count: selectedQty,
          countMax: selectedItem.so_luong_kd,
          maVt2: selectedItem.maVt2,
          sttRec0: selectedItem.sttRec0,
          isMark: 1,
          discountMoney: '0',
          discountProduct: '0',
          budgetForItem: '',
          budgetForProduct: '',
          residualValueProduct: 0,
          residualValue: 0,
          unit: selectedItem.dvt ?? '',
          unitProduct: '',
          dsCKLineItem: '',
          codeStock: selectedItem.maKho ?? '',
          nameStock: selectedItem.tenKho ?? '',
          so_luong_kd: totalAvailableQuantity, // Lưu tổng khả dụng gốc cho maVt2 - FIX: đảm bảo fallback khi availableQuantity null
          availableQuantity: totalAvailableQuantity, // Lưu TỔNG khả dụng gốc cho maVt2 (10,000)
          originalPrice: selectedItem.giaNt2, // Giá gốc ban đầu
          maThue: selectedItem.maThue, // Mã thuế
          tenThue: selectedItem.tenThue, // Tên thuế  
          thueSuat: selectedItem.thueSuat, // Thuế suất (%)
        );
        
        // Thêm vào giỏ hàng (sử dụng sttRec0 làm key, THAY THẾ số lượng)
        _bloc.add(AddCartWithSttRec0ReplaceEvent(productItem: product));
        addedCount++;
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [mainColor.withOpacity(0.2), subColor.withOpacity(0.1)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            size: 40,
                            color: mainColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Text
                const Text(
                  'Đang tải danh sách đơn hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Vui lòng đợi...',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNoOrdersDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon với gradient background
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withOpacity(0.2),
                                Colors.amber.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox_outlined,
                            size: 60,
                            color: Colors.orange[700],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Title
                        const Text(
                          'Chưa có đơn hàng',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Description
                        Text(
                          'Hợp đồng này chưa có đơn hàng nào.\nHãy tạo đơn hàng mới để bắt đầu!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Button đóng
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Đã hiểu',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showSuccessDialog(BuildContext context, {required String title, required String message}) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 36),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    label: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showErrorDialog(BuildContext context, {required String title, required String message}) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline, color: Colors.red, size: 36),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    label: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleItemSelection(int index, ListItem item, bool isSelected) async {
    if (isSelected) {
      // Tính số lượng hiện tại từ giỏ hàng (chỉ tính từ giỏ hàng, không tính selectedQuantities)
      double currentQuantityFromCart = _getQuantityFromCartForItem(item.sttRec0);
      
      // Tính số lượng khả dụng còn lại (không bao gồm item hiện tại)
      double availableQuantityExcludingCurrent = _getAvailableQuantityExcludingCurrentItem(item.maVt, item.maVt2, item.so_luong_kd, item.sttRec0 ?? '');
      
      // Tổng số lượng tối đa có thể đặt = số lượng hiện tại + số lượng khả dụng còn lại
      double maxQuantityCanOrder = currentQuantityFromCart + availableQuantityExcludingCurrent;
      
      // Hiển thị popup nhập số lượng khi tích chọn
      await showChangeQuantityPopup(
        context: context,
        originalQuantity: maxQuantityCanOrder, // Số lượng tối đa có thể đặt
        onConfirmed: (newQuantity) {
          setState(() {
            selectedItemIds.add(item.sttRec0 ?? '');
            _bloc.listItemProduct[index].isCheck = true;
            selectedQuantities[item.sttRec0 ?? ''] = newQuantity;
            // FIX: Lưu maVt2 và thông tin item vào cache để dùng khi phân trang
            selectedItemMaVt2[item.sttRec0 ?? ''] = item.maVt2 ?? '';
            selectedItemsCache[item.sttRec0 ?? ''] = item;
          });
        },
        maVt2: item.maVt ?? '',
        productName: item.tenVt, // Thêm tên sản phẩm
        listOrder: [],
        currentQuantity: currentQuantityFromCart, // Số lượng hiện tại trong giỏ hàng
        availableQuantity: maxQuantityCanOrder, // Tối đa có thể đặt
      );
    } else {
      // Khi bỏ tích chọn, reset số lượng về 0
      setState(() {
        selectedItemIds.remove(item.sttRec0 ?? '');
        _bloc.listItemProduct[index].isCheck = false;
        selectedQuantities.remove(item.sttRec0 ?? '');
        // FIX: Xóa khỏi cache
        selectedItemMaVt2.remove(item.sttRec0 ?? '');
        selectedItemsCache.remove(item.sttRec0 ?? '');
      });
    }
  }


}




















