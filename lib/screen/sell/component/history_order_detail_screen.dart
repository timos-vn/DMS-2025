// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api

import 'dart:typed_data';
import 'dart:io';
import 'package:dms/model/network/response/contract_reponse.dart';
import 'package:dms/screen/sell/cart/cart_screen.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../../../model/database/data_local.dart';
import '../../../model/network/response/manager_customer_response.dart';
import '../../../model/network/response/setting_options_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../cart/confirm_order_screen.dart';
import '../cart/cart_bloc.dart';
import '../cart/cart_event.dart';
import '../cart/cart_state.dart';

class HistoryOrderDetailScreen extends StatefulWidget {
  final String? sttRec;
  final String? currencyCode;
  final String? title;
  final String? itemGroupCode;
  final bool status;
  final bool? approveOrder; 
  final String codeCustomer;
  final String nameCustomer;
  final String addressCustomer;
  final String phoneCustomer;
  final String dateOrder;
  final String dateEstDelivery;
  final bool? hideEditAndCancelButtons;
  final String? statusName;


  const HistoryOrderDetailScreen({Key? key,this.sttRec,this.currencyCode,this.title, this.itemGroupCode,required this.codeCustomer,
    required this.nameCustomer ,required this.status,required this.addressCustomer,this.approveOrder,
    required this.phoneCustomer, required this.dateOrder, required this.dateEstDelivery, this.hideEditAndCancelButtons, this.statusName}) : super(key: key);

  @override
  _HistoryOrderDetailScreenState createState() => _HistoryOrderDetailScreenState();
}

class _HistoryOrderDetailScreenState extends State<HistoryOrderDetailScreen> {

  late CartBloc _bloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = CartBloc(context);
    _bloc.add(GetPrefs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: BlocListener<CartBloc,CartState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetListItemUpdateOrderEvent(widget.sttRec.toString()));
          }
          else if(state is DeleteOrderSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Huỷ đơn thành công');
            Navigator.pop(context,Const.REFRESH);
          }
          else if(state is ApproveOrderSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Duyệt đơn thành công');
            Navigator.pop(context,Const.REFRESH);
          }
          else if(state is AddProductToCartSuccess){
            if(Const.discountSpecial == true){
              DataLocal.listProductGift.clear();
              DataLocal.listProductGift.addAll(_bloc.listProductGift);
            }
            Const.currencyCode = !Utils.isEmpty(widget.currencyCode.toString()) ? widget.currencyCode.toString() : Const.currencyList[0].currencyCode.toString();
            Const.itemGroupCode = widget.currencyCode.toString();
            DataLocal.dateEstDelivery = widget.dateEstDelivery;


            if(_bloc.masterDetailOrder.isHD == 1){
              ContractItem contractMaster = ContractItem();
              contractMaster = ContractItem(
                sttRec: _bloc.masterDetailOrder.sttRec,
                maKh: _bloc.masterDetailOrder.maKh,
                tenKh: _bloc.masterDetailOrder.tenKh,
                  soCt: _bloc.masterDetailOrder.soCt,
                dienGiai: _bloc.masterDetailOrder.description,
                maGd: _bloc.masterDetailOrder.maGD,
                ngayCt: _bloc.masterDetailOrder.ngayCt
              );
              PersistentNavBarNavigator.pushNewScreen(context, screen: CartScreen(
                viewUpdateOrder: false,
                viewDetail: false,
                listIdGroupProduct:  Const.listGroupProductCode,
                itemGroupCode:  Const.itemGroupCode,
                listOrder: _bloc.listProduct,
                orderFromCheckIn: false,
                title: 'Đặt hàng',
                currencyCode:  Const.currencyList.isNotEmpty ? Const.currencyList[0].currencyCode.toString() : '',
                nameCustomer: contractMaster.tenKh,
                idCustomer: contractMaster.maKh,
                phoneCustomer: '',
                addressCustomer: '',
                codeCustomer: contractMaster.maKh, loadDataLocal: true,
                sttRectHD: contractMaster.sttRec,
                isContractCreateOrder: _bloc.masterDetailOrder.isHD ==  1 ? true : false,
                contractMaster: contractMaster,
              ),withNavBar: false).then((value) {
                DataLocal.listProductGift.clear();
                _bloc.add(DeleteProductInCartEvent());
                Navigator.pop(context,Const.REFRESH);
              });
            }
            else{
              PersistentNavBarNavigator.pushNewScreen(context, screen: ConfirmScreen(
                viewUpdateOrder: true,
                viewDetail: false,
                dateOrder: widget.dateOrder,
                listIdGroupProduct: Const.listGroupProductCode,
                itemGroupCode: Const.itemGroupCode,
                listOrder: _bloc.listProduct,
                orderFromCheckIn: false,
                title:'Cập nhật đơn',
                currencyCode: !Utils.isEmpty(widget.currencyCode.toString()) ? widget.currencyCode.toString() : Const.currencyList[0].currencyCode.toString(),
                nameCustomer: widget.nameCustomer,
                idCustomer: widget.codeCustomer,
                phoneCustomer: widget.phoneCustomer,
                addressCustomer: widget.addressCustomer,
                codeCustomer: widget.codeCustomer,
                sttRec: widget.sttRec,
                description: _bloc.description, loadDataLocal: false,
              ),withNavBar: false).then((value) {
                DataLocal.listProductGift.clear();
                _bloc.add(DeleteProductInCartEvent());
                Navigator.pop(context,Const.REFRESH);
              });
            }
          }else if(state is DeleteProductInCartSuccess){
            DataLocal.listOrderCalculatorDiscount.clear();
            DataLocal.listProductGift.clear();
          }
        },
        child: BlocBuilder<CartBloc,CartState>(
          bloc: _bloc, 
          builder: (BuildContext context, CartState state){ 
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is CartLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,CartState state){
    return Column(
      children: [
        buildAppBar(),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12)
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary Card
                _buildOrderSummaryCard(),
                // Divider để tách biệt thông tin khách hàng và danh sách sản phẩm
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
                // Product List
                Expanded(
                  child: _bloc.lineItem.isEmpty 
                    ? _buildEmptyState()
                    : buildListViewProduct()
                ),
                // Payment Summary & Actions
                _buildPaymentAndActionsSection()
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryCard() {
    final statusColor = _getStatusColor(widget.statusName);
    final statusIcon = _getStatusIcon(widget.statusName);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header với mã đơn và status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 16, color: subColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child:                     Text(
                        _getDisplayValue(widget.sttRec),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if(_getDisplayValue(widget.statusName, defaultValue: '').isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _getDisplayValue(widget.statusName),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(height: 12, thickness: 1),
          // Compact customer info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _getDisplayValue(widget.nameCustomer),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                _getDisplayValue(widget.phoneCustomer),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _getDisplayValue(widget.addressCustomer),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                _sanitizeValue(widget.dateOrder).isNotEmpty
                    ? Utils.parseStringDateToString(widget.dateOrder, Const.DATE_SV, Const.DATE_FORMAT_1)
                    : 'N/A',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Icon(Icons.local_shipping_outlined, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _sanitizeValue(widget.dateEstDelivery).isNotEmpty
                      ? Utils.parseStringDateToString(widget.dateEstDelivery, Const.DATE_SV, Const.DATE_FORMAT_1)
                      : 'N/A',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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

  Color _getStatusColor(String? statusName) { 
    final sanitized = _sanitizeValue(statusName);
    if (sanitized.isEmpty) {
      return Colors.grey; 
    }
    final normalized = sanitized.toLowerCase();
    if (normalized.contains('duyệt') && !normalized.contains('chờ')) {
      return Colors.green;
    } else if (normalized.contains('chờ duyệt')) {
      return Colors.orange;
    } else if (normalized.contains('lập') || normalized.contains('draft')) {
      return Colors.blue;
    } else if (normalized.contains('hủy') || normalized.contains('cancel')) {
      return Colors.red;
    }
    return Colors.grey;
  }

  IconData _getStatusIcon(String? statusName) {
    final sanitized = _sanitizeValue(statusName);
    if (sanitized.isEmpty) {
      return Icons.receipt_long_rounded;
    }
    final normalized = sanitized.toLowerCase();
    if (normalized.contains('duyệt') && !normalized.contains('chờ')) {
      return Icons.check_circle_rounded;
    } else if (normalized.contains('chờ duyệt')) {
      return Icons.schedule_rounded;
    } else if (normalized.contains('lập') || normalized.contains('draft')) {
      return Icons.edit_document;
    } else if (normalized.contains('hủy') || normalized.contains('cancel')) {
      return Icons.cancel_rounded;
    }
    return Icons.receipt_long_rounded;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có sản phẩm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentAndActionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact Payment Summary
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              children: [
                _buildPaymentRow('Tổng tiền', Utils.formatMoneyStringToDouble(_bloc.infoPayment?.tTien??0), false),
                const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                    Text('Thuế', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    Text('${Utils.formatMoneyStringToDouble(_bloc.infoPayment?.tThueNt??0)} ₫', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        ],
                      ),
                const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                    Text('Chiết khấu', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    Text('-${Utils.formatMoneyStringToDouble(_bloc.infoPayment?.tCkTtNt??0)} ₫', style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                  ],
                ),
                const Divider(height: 12, thickness: 1),
                _buildPaymentRow('Tổng thanh toán', Utils.formatMoneyStringToDouble(_bloc.infoPayment?.tTtNt??0), true),
              ],
            ),
          ),
          // Compact Action Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Column(
              children: [
                      Visibility(
                        visible: _canEditOrCancel() && widget.hideEditAndCancelButtons != true,
                        child: Row(
                          children: [
                            Expanded(
                        child: _buildCompactButton('Sửa', MdiIcons.pencilOutline, subColor, _handleEditOrder),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCompactButton('Huỷ', MdiIcons.deleteOutline, Colors.red, _handleCancelOrder),
                      ),
                    ],
                  ),
                ),
                if (_canEditOrCancel() && widget.hideEditAndCancelButtons != true)
                  const SizedBox(height: 8),
                Visibility(
                  visible: widget.approveOrder == true && 
                           _isPendingApprovalStatusName(widget.statusName) &&
                           !_isApprovedStatusName(widget.statusName) && 
                           Const.approveOrderFromHistoryOrder,
                  child: _buildCompactButton('Duyệt đơn', MdiIcons.checkCircleOutline, mainColor, _handleApproveOrder),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          '$value ₫',
          style: TextStyle(
            fontSize: isBold ? 16 : 12,
            fontWeight: FontWeight.bold,
            color: isBold ? subColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
                                child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEditOrder() {
                                    final status = _bloc.masterDetailOrder.status;
                                    final canEditByCode = status == 0 || status == 1;
                                    final canEditByName = _isPendingApprovalStatusName(widget.statusName);
    final isApproved = _isApprovedStatusName(widget.statusName);

    if(isApproved){
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Đơn hàng đã được duyệt, không thể sửa đơn');
      return;
    }

                                    if(!(canEditByCode || canEditByName)){
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Đơn hàng không thể sửa ở trạng thái hiện tại');
                                      return;
                                    }

                                    DataLocal.listObjectDiscount.clear();
                                    DataLocal.listOrderDiscount.clear();
                                    DataLocal.infoCustomer = ManagerCustomerResponseData();
                                    DataLocal.transactionCode = "";
                                    DataLocal.transaction = ListTransaction();
                                    DataLocal.indexValuesTax = -1;
                                    DataLocal.taxPercent = 0;
                                    DataLocal.taxCode = '';
                                    DataLocal.valuesTypePayment = '';
                                    DataLocal.datePayment = '';
                                    _bloc.add(AddProductToCartEvent());
  }

  void _handleCancelOrder() {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return WillPopScope(
                                            onWillPop: () async => false,
                                            child: const CustomQuestionComponent(
                                              showTwoButton: true,
                                              iconData: Icons.warning_amber_outlined,
                                              title: 'Đơn này sẽ bị huỷ',
                                              content: 'Hãy chắc chắn ngay cả khi bạn lỡ tay',
                                            ),
                                          );
      },
    ).then((value)async{
      if(value != null && !Utils.isEmpty(value) && value == 'Yeah'){
                                          _bloc.add(DeleteEvent(sttRec: widget.sttRec.toString()));
                                        }
    });
  }

  void _handleApproveOrder() {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return WillPopScope(
                                      onWillPop: () async => false,
                                      child: const CustomQuestionComponent(
                                        showTwoButton: true,
            iconData: Icons.check_circle_outline,
                                        title: 'Duyệt đơn',
            content: 'Bạn có chắc chắn muốn duyệt đơn hàng này?',
          ),
        );
      },
    ).then((value)async{
      if(value != null && !Utils.isEmpty(value) && value == 'Yeah'){
                                    _bloc.add(ApproveOrderEvent(sttRec: widget.sttRec.toString()));
      }
    });
  }

  buildListViewProduct(){
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _bloc.lineItem.length,
      itemBuilder: (context, index) {
        bool exits = Const.kColorForAlphaB.any((element) => 
          element.keyText == _bloc.lineItem[index].tenVt.toString().substring(0,1).toUpperCase()
        );
          if(exits == true){
          var itemCheck = Const.kColorForAlphaB.firstWhere((item) => 
            item.keyText == _bloc.lineItem[index].tenVt.toString().substring(0,1).toUpperCase()
          );
            if(itemCheck != null){
              _bloc.lineItem[index].kColorFormatAlphaB = itemCheck.color;
            }
          }
        return _buildProductCard(index);
      },
    );
  }

  Widget _buildProductCard(int index) {
    final item = _bloc.lineItem[index];
    final isGift = item.kmYn == 1;
    final hasDiscount = item.tlCk != null && item.tlCk! > 0;
    final price = item.price ?? 0;
    final priceAfter = item.priceAfter ?? 0;
    final hasPriceChange = price > 0 && price != priceAfter;
    final productCode = _getDisplayValue(item.maVt?.toString(), defaultValue: '');
    final productName = _getDisplayValue(item.tenVt?.toString());
    final displayName = productCode.isNotEmpty ? '[$productCode] $productName' : productName;
    
    // Determine avatar color
    Color avatarBgColor;
    Color avatarTextColor;
    if (isGift) {
      avatarBgColor = Colors.green.shade50;
      avatarTextColor = Colors.green.shade700;
    } else if (item.kColorFormatAlphaB != null) {
      avatarBgColor = Color(item.kColorFormatAlphaB!.value).withOpacity(0.1);
      avatarTextColor = Color(item.kColorFormatAlphaB!.value);
    } else {
      avatarBgColor = Colors.grey.shade100;
      avatarTextColor = Colors.grey.shade700;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isGift ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isGift
                  ? Icon(Icons.card_giftcard_rounded, color: avatarTextColor, size: 20)
                  : Center(
                      child: Text(
                        item.tenVt?.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(
                          color: avatarTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              ),
              // Special Badge
              if (hasDiscount)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _formatDiscountPercent(item.tlCk),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Name & Price Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasPriceChange && price > 0)
                          Text(
                            '${Utils.formatMoneyStringToDouble(price)} ₫',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough,
                              height: 1,
                            ),
                          ),
                        if (priceAfter > 0)
                          Text(
                            '${Utils.formatMoneyStringToDouble(priceAfter)} ₫',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                              height: 1.2,
                            ),
                          )
                        else if (price == 0)
                          Text(
                            'Cập nhật',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Metadata: Store & Quantity aligned edges, Response below
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _getDisplayValue(item.nameStore?.toString(), defaultValue: '').isNotEmpty
                                ? _buildInfoChip(
                                    Icons.store,
                                    'Kho: ${_getDisplayValue(item.nameStore?.toString())}',
                                    Colors.grey.shade600,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _buildInfoChip(
                              isGift ? Icons.card_giftcard : Icons.inventory_2,
                              'Số lượng: ${_formatQuantity(item.soLuong?.toDouble(), unit: item.dvt)}',
                              isGift ? Colors.red.shade600 : Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((item.soLuongDapUng ?? 0) > 0) ...[
                      const SizedBox(height: 4),
                      _buildInfoChip(
                        Icons.assignment_turned_in_outlined,
                        'Đáp ứng: ${_formatQuantity(item.soLuongDapUng, unit: item.dvt)}',
                        Colors.teal.shade700,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatQuantity(double? value, {String? unit}) {
    final qty = value ?? 0;
    String numberStr;
    if (qty % 1 == 0) {
      numberStr = qty.toInt().toString();
    } else {
      numberStr = qty.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    final sanitizedUnit = _sanitizeValue(unit);
    return sanitizedUnit.isNotEmpty ? '$numberStr $sanitizedUnit' : numberStr;
  }

  String _formatDiscountPercent(double? percent) {
    if (percent == null) return '-0%';
    final value = percent % 1 == 0 ? percent.toInt().toString() : percent.toString();
    return '-$value%';
  }

  bool _canEditOrCancel() {
    return _isDraftStatusName(widget.statusName) ||
        _isPendingApprovalStatusName(widget.statusName);
  }

  bool _isDraftStatusName(String? statusName) {
    final sanitized = _sanitizeValue(statusName);
    if (sanitized.isEmpty) {
      return false;
    }
    final statusNameLower = sanitized.toLowerCase();
    return statusNameLower == 'lập ctừ' ||
        statusNameLower == 'lập chứng từ' ||
        statusNameLower.contains('lập ctừ') ||
        statusNameLower.contains('lập chứng từ');
  }

  bool _isPendingApprovalStatusName(String? statusName) {
    final sanitized = _sanitizeValue(statusName);
    if (sanitized.isEmpty) {
      return false;
    }
    final normalized = sanitized.toLowerCase();
    return normalized == 'chờ duyệt' || normalized.contains('chờ duyệt');
  }

  bool _isApprovedStatusName(String? statusName) {
    final sanitized = _sanitizeValue(statusName);
    if (sanitized.isEmpty) {
      return false;
    }
    final normalized = sanitized.toLowerCase();
    // Kiểm tra các trạng thái đã được duyệt
    return normalized == 'duyệt' || 
           normalized.contains('duyệt') && !normalized.contains('chờ');
  }

  Future<void> _generateAndSharePDF() async {
    if (!mounted) return;
    
    try {
      // Show loading
      Utils.showCustomToast(context, Icons.info_outline, 'Đang tạo PDF...');
      
      // Generate PDF
      final pdfBytes = await _generatePDF();
      
      if (!mounted) return;
      
      // Save PDF to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'DonHang_${widget.sttRec ?? DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      
      if (!mounted) return;
      
      // Share PDF
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Chi tiết đơn hàng ${widget.sttRec ?? ''}',
        subject: 'Đơn hàng ${widget.sttRec ?? ''}',
      );
      
      if (!mounted) return;
      Utils.showCustomToast(context, Icons.check_circle_outline, 'PDF đã được tạo và sẵn sàng chia sẻ');
    } catch (e) {
      if (!mounted) return;
      Utils.showCustomToast(context, Icons.error_outline, 'Lỗi khi tạo PDF: $e');
    }
  }

  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();
    const pageFormat = PdfPageFormat.a4;
    
    // Load Vietnamese font
    final vietnameseFont = await _loadVietnameseFont();
    final vietnameseFontBold = await _loadVietnameseFontBold();
    
    // Load logo for watermark
    final logoImage = await _loadLogoImage();
    
    // Get order data
    final orderInfo = _bloc.infoPayment;
    final lineItems = _bloc.lineItem;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: vietnameseFont,
          bold: vietnameseFontBold,
        ),
        build: (pw.Context context) {
          return [
            // Stack: Watermark first (background), then content on top
            pw.Stack(
              children: [
                // Watermark layer - placed first so it's behind content
                if (logoImage != null) 
                  pw.Positioned.fill(
                    child: _buildWatermark(logoImage, pageFormat),
                  ),
                
                // Content layer - placed after watermark so it's on top
                pw.Column(
                  children: [
                    // Header
                    _buildPDFHeader(vietnameseFont, vietnameseFontBold),
                    pw.SizedBox(height: 20),
                    
                    // Customer Info
                    _buildPDFCustomerInfo(vietnameseFont, vietnameseFontBold),
                    pw.SizedBox(height: 20),
                    
                    // Order Info
                    _buildPDFOrderInfo(vietnameseFont, vietnameseFontBold),
                    pw.SizedBox(height: 20),
                    
                    // Products Table
                    _buildPDFProductsTable(vietnameseFont, vietnameseFontBold, lineItems),
                    pw.SizedBox(height: 20),
                    
                    // Summary
                    _buildPDFSummary(vietnameseFont, vietnameseFontBold, orderInfo),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );
    
    return pdf.save();
  }

  Future<pw.MemoryImage?> _loadLogoImage() async {
    try {
      final imageData = await rootBundle.load('assets/images/logo.png');
      final imageBytes = imageData.buffer.asUint8List();
      final image = pw.MemoryImage(imageBytes);
      return image;
    } catch (e) {
      print('Error loading logo image: $e');
      return null;
    }
  }

  pw.Widget _buildWatermark(pw.MemoryImage logoImage, PdfPageFormat pageFormat) {
    // Center the watermark
    return pw.Center(
      child: pw.Opacity(
        opacity: 0.08, // Very light watermark
        child: pw.Container(
          width: 200, // Logo size
          height: 200,
          child: pw.Image(logoImage, fit: pw.BoxFit.contain),
        ),
      ),
    );
  }

  Future<pw.Font> _loadVietnameseFont() async {
    try {
      // Load NotoSans font from assets
      final fontData = await rootBundle.load('assets/fonts/Noto_Sans/NotoSans-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      print('Error loading Vietnamese font from assets: $e');
      // Fallback: Use default font
      return pw.Font.courier();
    }
  }

  Future<pw.Font> _loadVietnameseFontBold() async {
    try {
      // Load NotoSans Bold font from assets
      final fontData = await rootBundle.load('assets/fonts/Noto_Sans/NotoSans-Bold.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      print('Error loading Vietnamese bold font from assets: $e');
      // Fallback: Use default bold font
      return pw.Font.courierBold();
    }
  }

  pw.Widget _buildPDFHeader(pw.Font baseFont, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CHI TIẾT ĐƠN HÀNG',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
                font: boldFont,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Ngày tạo: ${_sanitizeValue(widget.dateOrder) != '' ? Utils.parseStringDateToString(widget.dateOrder, Const.DATE_SV, Const.DATE_FORMAT_1) : 'N/A'}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
                font: baseFont,
              ),
            ),
          ],
        ),
        if (_sanitizeValue(widget.statusName).isNotEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              _sanitizeValue(widget.statusName),
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                font: boldFont,
              ),
            ),
          ),
      ],
    );
  }

  pw.Widget _buildPDFCustomerInfo(pw.Font baseFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'THÔNG TIN KHÁCH HÀNG',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
              font: boldFont,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPDFInfoRow(baseFont, boldFont, 'Tên khách hàng:', widget.nameCustomer),
                    pw.SizedBox(height: 4),
                    _buildPDFInfoRow(baseFont, boldFont, 'Mã khách hàng:', widget.codeCustomer),
                    pw.SizedBox(height: 4),
                    _buildPDFInfoRow(baseFont, boldFont, 'Số điện thoại:', widget.phoneCustomer),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPDFInfoRow(baseFont, boldFont, 'Mã đơn hàng:', widget.sttRec),
                    pw.SizedBox(height: 4),
                    _buildPDFInfoRow(baseFont, boldFont, 'Ngày giao hàng:', 
                      _sanitizeValue(widget.dateEstDelivery) != '' 
                        ? Utils.parseStringDateToString(widget.dateEstDelivery, Const.DATE_SV, Const.DATE_FORMAT_1)
                        : 'N/A'),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          _buildPDFInfoRow(baseFont, boldFont, 'Địa chỉ:', widget.addressCustomer),
        ],
      ),
    );
  }

  String _sanitizeValue(String? value) {
    if (value == null || value.trim().isEmpty || value.toLowerCase() == 'null') {
      return '';
    }
    return value.trim();
  }

  String _getDisplayValue(String? value, {String defaultValue = 'N/A'}) {
    final sanitized = _sanitizeValue(value);
    return sanitized.isEmpty ? defaultValue : sanitized;
  }

  double _getNumericValue(dynamic value) {
    if (value == null) return 0;
    if (value is String) {
      if (value.trim().isEmpty || value.toLowerCase() == 'null') return 0;
      return double.tryParse(value) ?? 0;
    }
    if (value is num) return value.toDouble();
    return 0;
  }

  pw.Widget _buildPDFInfoRow(pw.Font baseFont, pw.Font boldFont, String label, String? value) {
    final sanitizedValue = _sanitizeValue(value);
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
              font: boldFont,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            sanitizedValue.isEmpty ? 'N/A' : sanitizedValue,
            style: pw.TextStyle(
              fontSize: 10,
              font: baseFont,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPDFOrderInfo(pw.Font baseFont, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Mã đơn: ${_sanitizeValue(widget.sttRec).isEmpty ? 'N/A' : _sanitizeValue(widget.sttRec)}',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            font: boldFont,
          ),
        ),
        pw.Text(
          'Số lượng sản phẩm: ${_bloc.lineItem.length}',
          style: pw.TextStyle(
            fontSize: 11,
            font: baseFont,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPDFProductsTable(pw.Font baseFont, pw.Font boldFont, List lineItems) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildPDFTableCell(baseFont, boldFont, 'STT', isHeader: true),
            _buildPDFTableCell(baseFont, boldFont, 'Tên sản phẩm', isHeader: true),
            _buildPDFTableCell(baseFont, boldFont, 'Mã SP', isHeader: true),
            _buildPDFTableCell(baseFont, boldFont, 'Số lượng', isHeader: true),
            _buildPDFTableCell(baseFont, boldFont, 'Thành tiền', isHeader: true),
          ],
        ),
        // Data rows
        ...lineItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final quantity = item.soLuong?.toDouble() ?? 0;
          final respondQty = item.soLuongDapUng?.toDouble() ?? 0;
          final price = item.priceAfter ?? item.price ?? 0;
          final total = quantity * price;
          
          final productName = _sanitizeValue(item.tenVt?.toString());
          final productCode = _sanitizeValue(item.maVt?.toString());
          final unit = _sanitizeValue(item.dvt?.toString());
          final quantityLabel = _formatQuantity(quantity, unit: unit);
          final respondLabel = respondQty > 0 ? 'Đáp ứng: ${_formatQuantity(respondQty, unit: unit)}' : '';
          
          return pw.TableRow(
            children: [
              _buildPDFTableCell(baseFont, boldFont, '${index + 1}'),
              _buildPDFTableCell(baseFont, boldFont, productName.isEmpty ? 'N/A' : productName),
              _buildPDFTableCell(baseFont, boldFont, productCode.isEmpty ? '-' : productCode),
              _buildPDFTableCell(
                baseFont,
                boldFont,
                respondLabel.isNotEmpty ? '$quantityLabel\n$respondLabel' : quantityLabel,
              ),
              _buildPDFTableCell(baseFont, boldFont, '${Utils.formatMoneyStringToDouble(total)} ₫'),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildPDFTableCell(pw.Font baseFont, pw.Font boldFont, String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blue900 : PdfColors.black,
          font: isHeader ? boldFont : baseFont,
        ),
        maxLines: 2,
      ),
    );
  }

  pw.Widget _buildPDFSummary(pw.Font baseFont, pw.Font boldFont, dynamic orderInfo) {
    // Safely extract values, handling null and "null" string
    final totalMoney = _getNumericValue(orderInfo?.tTien);
    final totalTax = _getNumericValue(orderInfo?.tThueNt);
    final totalDiscount = _getNumericValue(orderInfo?.tCkTtNt);
    final totalPayment = _getNumericValue(orderInfo?.tTtNt);
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildPDFSummaryRow(baseFont, boldFont, 'Tổng tiền:', Utils.formatMoneyStringToDouble(totalMoney)),
          pw.SizedBox(height: 4),
          _buildPDFSummaryRow(baseFont, boldFont, 'Tổng thuế:', Utils.formatMoneyStringToDouble(totalTax)),
          pw.SizedBox(height: 4),
          _buildPDFSummaryRow(baseFont, boldFont, 'Chiết khấu:', '-${Utils.formatMoneyStringToDouble(totalDiscount)}'),
          pw.Divider(),
          _buildPDFSummaryRow(
            baseFont,
            boldFont,
            'TỔNG THANH TOÁN:',
            Utils.formatMoneyStringToDouble(totalPayment),
            isBold: true,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFSummaryRow(pw.Font baseFont, pw.Font boldFont, String label, String value, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: isBold ? 12 : 10,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            font: isBold ? boldFont : baseFont,
          ),
        ),
        pw.Text(
          '$value ₫',
          style: pw.TextStyle(
            fontSize: isBold ? 14 : 10,
            fontWeight: pw.FontWeight.bold,
            color: isBold ? PdfColors.blue900 : PdfColors.black,
            font: boldFont,
          ),
        ),
      ],
    );
  }

  buildAppBar(){
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.centerLeft, 
              end: Alignment.centerRight,
          colors: [subColor, Color.fromARGB(255, 150, 185, 229)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            // Back Button - Compact
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(widget.currencyCode),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: const Icon(
                Icons.arrow_back_rounded,
                    size: 25,
                color: Colors.white,
              ),
            ),
          ),
            ),
            // Title - Compact
          const Expanded(
            child: Center(
                child: Text(
                  'Chi tiết đơn hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Action Buttons Row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Export PDF Button
                Visibility(
                  visible: Const.downFileFromDetailOrder == true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _generateAndSharePDF,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Download Button - Compact
                if (_bloc.masterDetailOrder.sttRec.toString().replaceAll('null', '').isNotEmpty
                    && (_bloc.masterDetailOrder.maGD.toString().replaceAll('null', '') == "5"
                        || _bloc.masterDetailOrder.maGD.toString().replaceAll('null', '') == '6')) ...[
                  const SizedBox(width: 4),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (_bloc.masterDetailOrder.sttRec.toString().replaceAll('null', '').isNotEmpty) {
                          _bloc.add(DownloadFileEvent(sttRec: _bloc.masterDetailOrder.sttRec.toString()));
                        } else {
                          Utils.showCustomToast(context, Icons.warning_amber, 'Không lấy được mã phiếu.');
                        }
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.file_download_outlined,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else
                  const SizedBox(width: 0),
              ],
            ),
        ],
        ),
      ),
    );
  }
}



