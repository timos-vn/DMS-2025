import 'dart:io' show Platform;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/database/data_local.dart';
import '../../../model/entity/item_check_in.dart';
import '../../../model/network/response/detail_customer_response.dart';
import '../../../model/network/response/list_checkin_response.dart';
import '../../../services/location_service.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../dms/check_in/component/detail_check_in.dart';
import 'package:geolocator/geolocator.dart';
import '../../dms/refund_sale_out/component/list_sale_out_completed_screen.dart';
import '../../sell/order/order_sceen.dart';
import '../../sell/refund_order/component/list_order_completed_screen.dart';
import 'detail_customer_event.dart';
import 'detail_customer_state.dart';
import 'detail_customer_bloc.dart';

// Helper class for action buttons
class ActionButtonItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  ActionButtonItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });
}

class DetailInfoCustomerScreen extends StatefulWidget {
  final String? idCustomer;

  const DetailInfoCustomerScreen({Key? key, this.idCustomer}) : super(key: key);
  @override
  _DetailInfoCustomerScreenState createState() => _DetailInfoCustomerScreenState();
}

class _DetailInfoCustomerScreenState extends State<DetailInfoCustomerScreen> {

  late DetailCustomerBloc _bloc;
  bool _hasPendingCheckIn = false;
  ItemCheckInOffline? _pendingCheckIn;

  List<Color> listColor = [Colors.blueAccent,Colors.lightGreen,Colors.pink,Colors.yellow];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = DetailCustomerBloc(context);
    _bloc.add(GetPrefs());
  }

  // Helper function để format date string
  String _formatDateString(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == 'null') {
      return 'Chưa có thông tin';
    }

    try {
      // Loại bỏ 'null' và trim
      final cleaned = dateString.replaceAll('null', '').trim();
      if (cleaned.isEmpty) {
        return 'Chưa có thông tin';
      }

      // Thử parse với nhiều format khác nhau
      DateTime? parsedDate;

      // Thử ISO format trước (2025-01-15T10:30:00 hoặc 2025-01-15)
      try {
        parsedDate = DateTime.parse(cleaned);
      } catch (_) {
        // Thử format dd/MM/yyyy
        try {
          parsedDate = DateFormat('dd/MM/yyyy').parseStrict(cleaned);
        } catch (_) {
          // Thử format dd-MM-yyyy
          try {
            parsedDate = DateFormat('dd-MM-yyyy').parseStrict(cleaned);
          } catch (_) {
            // Thử format yyyy-MM-dd
            try {
              parsedDate = DateFormat('yyyy-MM-dd').parseStrict(cleaned);
            } catch (_) {
              // Nếu không parse được, trả về "Chưa có thông tin"
              return 'Chưa có thông tin';
            }
          }
        }
      }

      if (parsedDate != null) {
        // Kiểm tra nếu là ngày mặc định (01/01/0001 hoặc năm < 1900) - không hợp lệ
        if (parsedDate.year < 1900 || 
            (parsedDate.year == 1 && parsedDate.month == 1 && parsedDate.day == 1)) {
          return 'Chưa có thông tin';
        }

        // Format theo định dạng Việt Nam: dd/MM/yyyy
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      }

      return 'Chưa có thông tin';
    } catch (e) {
      // Nếu có lỗi, trả về "Chưa có thông tin"
      return 'Chưa có thông tin';
    }
  }

  Future<void> _openGoogleMapsWithAddress(String address) async {
    final String trimmed = address.replaceAll('null', '').trim();
    if (trimmed.isEmpty) {
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Địa chỉ trống, không thể mở Google Maps');
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mở bản đồ'),
        content: Text('Bạn có muốn mở bản đồ với địa chỉ:\n\n$trimmed'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Mở'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final String encoded = Uri.encodeComponent(trimmed);

    if (Platform.isIOS) {
      final Uri iosAppUri = Uri.parse('comgooglemaps://?q=$encoded');
      try {
        if (await canLaunchUrl(iosAppUri)) {
          await launchUrl(iosAppUri, mode: LaunchMode.externalApplication);
          return;
        }
        // Fallback to Apple Maps if Google Maps app is not available
        final Uri appleMapsUri = Uri.parse('http://maps.apple.com/?q=$encoded');
        if (await canLaunchUrl(appleMapsUri)) {
          await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    } else if (Platform.isAndroid) {
      final Uri androidGeoUri = Uri.parse('geo:0,0?q=$encoded');
      try {
        if (await canLaunchUrl(androidGeoUri)) {
          await launchUrl(androidGeoUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    final Uri webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    try {
      final launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Không thể mở Google Maps');
      }
    } catch (_) {
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Không thể mở Google Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DetailCustomerBloc,DetailCustomerState>(
          bloc: _bloc,
          listener: (context,state){
            if(state is GetPrefsSuccess){
              _bloc.add(GetDetailCustomerEvent(widget.idCustomer.toString()));
            }
            if(state is DetailCustomerFailure){
              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Có lỗi xảy ra.');
            }
            else if(state is GetDetailCustomerSuccess){
              // Check pending check-in sau khi load thông tin khách hàng
              _bloc.add(CheckPendingCheckInEvent(customerCode: widget.idCustomer.toString()));
            }
            else if(state is CheckPendingCheckInSuccess){
              setState(() {
                _hasPendingCheckIn = state.hasPendingCheckIn;
                _pendingCheckIn = state.pendingCheckInData as ItemCheckInOffline?;
              });
            }
            else if(state is GetInfoTaskCustomerSuccess){
              _bloc.add(GetDetailCheckInOnlineEvent(idCheckIn: state.idTask, idCustomer: state.idCustomer.toString()));
            }else if(state is GetDetailCheckInOnlineSuccess){
              DataLocal.latLongLocation = '';
              DataLocal.addressCheckInCustomer = '';
              DataLocal.addImageToAlbumRequest = false;
              DataLocal.addImageToAlbum = false;
              DataLocal.listInventoryIsChange = true;
              DataLocal.listOrderProductIsChange = true;

              PersistentNavBarNavigator.pushNewScreen(context, screen: DetailCheckInScreen(
                idCheckIn: _bloc.idCheckIn,
                dateCheckIn: DateTime.now(),
                listAppSettings: const [],
                view: false,
                isCheckInSuccess: false,
                listAlbumOffline: _bloc.listAlbum,
                listAlbumTicketOffLine: _bloc.listTicket,
                ngayCheckin: (state.itemSelect.ngayCheckin != "null" && state.itemSelect.ngayCheckin != '' && state.itemSelect.ngayCheckin != null) ? DateTime.tryParse(state.itemSelect.ngayCheckin.toString()).toString() : '',
                tgHoanThanh: (state.itemSelect.tgHoanThanh != null && state.itemSelect.tgHoanThanh != 'null' && state.itemSelect.tgHoanThanh != '') ? state.itemSelect.tgHoanThanh! : '',
                numberTimeCheckOut:  int.parse(state.itemSelect.timeCheckOut.toString().replaceAll('null', '').isNotEmpty ? state.itemSelect.timeCheckOut.toString() : "0"),
                isSynSuccess: false,
                item:  state.itemSelect,
                isGpsFormCustomer: true,
              ));
            }
          },
          child: BlocBuilder<DetailCustomerBloc,DetailCustomerState>(
            bloc: _bloc,
            builder: (BuildContext context, DetailCustomerState state){
              return Stack(
                children: [
                  buildBody(context, state),
                  Visibility(
                    visible: state is DetailCustomerLoading,
                    child:const PendingAction(),
                  ),
                ],
              );
            },
          )
      ),
    );
  }

  buildBody(BuildContext context,DetailCustomerState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compact Customer Info Card - Kết hợp tất cả thông tin
                  _buildCompactCustomerCard(state),
                  
                  // Stats Horizontal Scroll - Compact
                  if (_bloc.listOtherData != null && _bloc.listOtherData!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCompactStats(),
                  ],
                  
                  // Action Buttons - Compact List
                  const SizedBox(height: 12),
                  _buildCompactActionButtons(state),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Compact Customer Card - Kết hợp tất cả thông tin trong 1 card
  Widget _buildCompactCustomerCard(DetailCustomerState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header với avatar và tên
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [subColor, Color.fromARGB(255, 150, 185, 229)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Avatar nhỏ gọn
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: _bloc.detailCustomer.imageUrl != null && 
                         _bloc.detailCustomer.imageUrl!.isNotEmpty &&
                         _bloc.detailCustomer.imageUrl != 'null'
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: _bloc.detailCustomer.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            size: 28,
                            color: subColor,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 28,
                        color: subColor,
                      ),
                ),
                const SizedBox(width: 12),
                // Tên và mã
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _bloc.detailCustomer.customerName ?? 'Chưa có tên',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_bloc.detailCustomer.customerCode != null && 
                          _bloc.detailCustomer.customerCode!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Mã: ${_bloc.detailCustomer.customerCode}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Thông tin chi tiết
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCompactInfoRow(
                  icon: Icons.phone,
                  label: 'Điện thoại',
                  value: _bloc.detailCustomer.phone ?? 'Chưa có',
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildCompactInfoRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: _bloc.detailCustomer.email ?? 'Chưa có',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildCompactInfoRow(
                  icon: Icons.location_on,
                  label: 'Địa chỉ',
                  value: _bloc.detailCustomer.address?.replaceAll('null', '').trim() ?? 'Chưa có',
                  color: Colors.red,
                  showMapButton: _bloc.detailCustomer.address?.replaceAll('null', '').trim().isNotEmpty == true,
                  onMapTap: () => _openGoogleMapsWithAddress(_bloc.detailCustomer.address ?? ''),
                ),
                if (_bloc.detailCustomer.birthday != null && 
                    _bloc.detailCustomer.birthday!.toString().replaceAll('null', '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildCompactInfoRow(
                    icon: FontAwesomeIcons.birthdayCake,
                    label: 'Sinh nhật',
                    value: _formatDateString(_bloc.detailCustomer.birthday),
                    color: Colors.pink,
                  ),
                ],
                if (_bloc.detailCustomer.lastPurchaseDate != null && 
                    _bloc.detailCustomer.lastPurchaseDate!.toString().replaceAll('null', '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildCompactInfoRow(
                    icon: Icons.receipt_long,
                    label: 'Mua hàng cuối',
                    value: _formatDateString(_bloc.detailCustomer.lastPurchaseDate),
                    color: Colors.orange,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool showMapButton = false,
    VoidCallback? onMapTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showMapButton && onMapTap != null) ...[
                    const SizedBox(width: 6),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onMapTap,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            MdiIcons.mapOutline,
                            size: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Compact Stats - Horizontal Scroll
  Widget _buildCompactStats() {
    if (_bloc.listOtherData == null || _bloc.listOtherData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _bloc.listOtherData!.length,
        itemBuilder: (context, index) {
          final item = _bloc.listOtherData![index];
          return _buildCompactStatCard(item, index);
        },
      ),
    );
  }

  Widget _buildCompactStatCard(OtherData item, int index) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon nhỏ
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: listColor[index % listColor.length].withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.iconUrl != null && item.iconUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: item.iconUrl!,
                      width: 16,
                      height: 16,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(
                        Icons.analytics_outlined,
                        size: 16,
                        color: listColor[index % listColor.length],
                      ),
                    ),
                  )
                : Icon(
                    Icons.analytics_outlined,
                    size: 16,
                    color: listColor[index % listColor.length],
                  ),
            ),
            const SizedBox(height: 8),
            // Value
            Text(
              item.formatString != null && item.formatString!.isNotEmpty
                ? NumberFormat(item.formatString).format(item.value ?? 0)
                : (item.value ?? 0).toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: listColor[index % listColor.length],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              item.text ?? '',
              style: const TextStyle(
                fontSize: 10,
                color: grey,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Compact Action Buttons - List View
  Widget _buildCompactActionButtons(DetailCustomerState state) {
    List<ActionButtonItem> actions = [];
    
    if (Const.createTaskFromCustomer == true && state is !DetailCustomerLoading) {
      actions.add(ActionButtonItem(
        title: 'Check-in / Giám sát',
        icon: _hasPendingCheckIn ? MdiIcons.clockOutline : MdiIcons.watchImport,
        color: _hasPendingCheckIn ? Colors.orange : subColor,
        onTap: _handleCheckInTap,
        badge: _hasPendingCheckIn ? 'Đang check-in' : null,
      ));
    }
    
    if (state is !DetailCustomerLoading && Const.createNewOrderFromCustomer == true) {
      actions.add(ActionButtonItem(
        title: 'Đặt đơn',
        icon: MdiIcons.cartOutline,
        color: mainColor,
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: OrderScreen(
              nameCustomer: _bloc.detailCustomer.customerName,
              phoneCustomer: _bloc.detailCustomer.phone,
              addressCustomer: _bloc.detailCustomer.address,
              codeCustomer: _bloc.detailCustomer.customerCode,
            ),
            withNavBar: false,
          );
        }
      ));
    }
    
    if (Const.refundOrder == true && state is !DetailCustomerLoading) {
      actions.add(ActionButtonItem(
        title: 'Trả lại hàng bán',
        icon: MdiIcons.arrangeSendToBack,
        color: subColor,
        onTap: () => PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: OrderCompletedScreen(detailCustomer: _bloc.detailCustomer),
          withNavBar: false,
        ),
      ));
    }
    
    if (Const.refundOrderSaleOut == true && state is !DetailCustomerLoading) {
      actions.add(ActionButtonItem(
        title: 'Trả lại Sale Out',
        icon: MdiIcons.sendCheckOutline,
        color: Colors.deepPurpleAccent,
        onTap: () => PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: SaleOutCompletedScreen(detailAgency: _bloc.detailCustomer),
          withNavBar: false,
        ),
      ));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return Column(
            children: [
              _buildCompactActionItem(action),
              if (index < actions.length - 1)
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactActionItem(ActionButtonItem action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon với background màu
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Title và badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            action.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (action.badge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              action.badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (action.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        action.subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }


  buildAppBar(){
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [subColor, Color.fromARGB(255, 150, 185, 229)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.fromLTRB(5, 10, 12, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Thông tin khách hàng",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCheckInTap() {
    if (_hasPendingCheckIn && _pendingCheckIn != null) {
      // Kiểm tra vị trí trước khi khôi phục check-in dở dang
      _handleRestoreCheckInWithLocationValidation();
    } else {
      // Tạo check-in mới
      _bloc.add(CreateTaskFromCustomerEvent(idCustomer: _bloc.detailCustomer.customerCode.toString()));
    }
  }

  // Method xử lý restore check-in với validation vị trí (giống luồng "Gặp gỡ")
  void _handleRestoreCheckInWithLocationValidation() async {
    if (_pendingCheckIn == null) return;

    try {
      print('📍 Starting restore check-in validation...');
      
      // Hiển thị loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Lấy vị trí GPS hiện tại
      LocationResult locationResult = await LocationService.getLocationWithRetry(
        forceFresh: true,
        maxRetries: 3,
      );

      Navigator.pop(context); // Đóng loading dialog

      if (!locationResult.isSuccess) {
        Utils.showCustomToast(
          context,
          Icons.error_outline,
          locationResult.error ?? 'Không thể lấy vị trí GPS. Vui lòng thử lại.',
        );
        return;
      }

      Position? currentPosition = locationResult.position;

      // Kiểm tra có tọa độ khách hàng không
      String customerLatLong = _pendingCheckIn!.latlong ?? _pendingCheckIn!.gps ?? '';
      if (customerLatLong.isEmpty || customerLatLong == 'null') {
        print('📍 No customer coordinates, proceeding without location check');
        _restorePendingCheckIn();
        return;
      }

      // Validate check-in với LocationService (giống luồng "Gặp gỡ")
      CheckInValidationResult validation = LocationService.validateCheckIn(
        customerLatLong: customerLatLong,
        currentPosition: currentPosition,
        maxAllowedDistance: Const.distanceLocationCheckIn,
      );

      if (validation.isSuccess) {
        print('📍 Restore check-in validation successful: distance=${validation.distance!.toStringAsFixed(2)}m');
        _restorePendingCheckIn();
        
      } else if (validation.isDistanceExceeded) {
        print('📍 Distance exceeded: ${validation.distance!.toStringAsFixed(2)}m > ${validation.maxAllowed}m');
        _showDistanceExceededDialogForRestore(validation);
        
      } else {
        print('📍 Restore check-in validation failed: ${validation.error}');
        _showLocationErrorDialogForRestore(validation);
      }
      
    } catch (e) {
      print('❌ Restore check-in validation error: $e');
      Navigator.pop(context); // Đóng loading dialog nếu có
      Utils.showCustomToast(context, Icons.error_outline, 
        'Lỗi kiểm tra vị trí. Vui lòng thử lại.');
    }
  }

  // Hiển thị dialog khi khoảng cách vượt quá khi restore
  void _showDistanceExceededDialogForRestore(CheckInValidationResult validation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.red),  
            SizedBox(width: 8),
            Text('Khoảng cách vượt quá'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bạn đang cách vị trí check-in ${validation.distance!.toStringAsFixed(0)}m'),
            Text('(Cho phép tối đa: ${validation.maxAllowed}m)', 
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: const Column(
                children: [
                  Text('⚠️ Bạn đang quá xa vị trí check-in', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(height: 4),
                  Text('Vui lòng di chuyển đến gần vị trí khách hàng để tiếp tục check-in', 
                    style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  // Hiển thị dialog khi lỗi vị trí khi restore
  void _showLocationErrorDialogForRestore(CheckInValidationResult validation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Lỗi kiểm tra vị trí'),
          ],
        ),
        content: Text(validation.error ?? 'Không thể kiểm tra vị trí. Vui lòng thử lại.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleRestoreCheckInWithLocationValidation(); // Thử lại
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _restorePendingCheckIn() {
    if (_pendingCheckIn == null) return;

    // Set DataLocal để khôi phục check-in dở dang
    DataLocal.idCurrentCheckIn = _pendingCheckIn!.id ?? '';
    DataLocal.dateTimeStartCheckIn = _pendingCheckIn!.timeCheckIn ?? '';
    
    // Khôi phục địa chỉ và vị trí GPS từ pending check-in nếu có
    if (_pendingCheckIn!.latlong != null && _pendingCheckIn!.latlong!.isNotEmpty) {
      DataLocal.latLongLocation = _pendingCheckIn!.latlong ?? '';
    }
    if (_pendingCheckIn!.diaChi != null && _pendingCheckIn!.diaChi!.isNotEmpty) {
      DataLocal.addressCheckInCustomer = _pendingCheckIn!.diaChi ?? '';
    }

    // Tạo ListCheckIn từ ItemCheckInOffline
    ListCheckIn restoredCheckIn = ListCheckIn(
      id: int.tryParse(_pendingCheckIn!.idCheckIn ?? '0') ?? 0,
      tieuDe: _pendingCheckIn!.tieuDe ?? '',
      ngayCheckin: _pendingCheckIn!.ngayCheckin ?? DateTime.now().toString(),
      maKh: _pendingCheckIn!.maKh ?? '',
      tenCh: _pendingCheckIn!.tenCh ?? '',
      diaChi: _pendingCheckIn!.diaChi ?? '',
      dienThoai: _pendingCheckIn!.dienThoai ?? '',
      gps: _pendingCheckIn!.gps ?? '',
      trangThai: _pendingCheckIn!.trangThai ?? '',
      tgHoanThanh: _pendingCheckIn!.tgHoanThanh ?? '',
      timeCheckOut: _pendingCheckIn!.timeCheckOut ?? '',
      latLong: _pendingCheckIn!.latlong ?? '',
    );

    // Điều hướng tới DetailCheckInScreen với check-in dở dang
    DataLocal.addImageToAlbumRequest = false;
    DataLocal.addImageToAlbum = false;
    DataLocal.listInventoryIsChange = true;
    DataLocal.listOrderProductIsChange = true;

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: DetailCheckInScreen(
        idCheckIn: int.tryParse(_pendingCheckIn!.idCheckIn ?? '0') ?? 0,
        dateCheckIn: _pendingCheckIn!.ngayCheckin != null && _pendingCheckIn!.ngayCheckin!.isNotEmpty
            ? (DateTime.tryParse(_pendingCheckIn!.ngayCheckin!) ?? DateTime.now())
            : DateTime.now(),
        listAppSettings: const [],
        view: false,
        isCheckInSuccess: false,
        listAlbumOffline: _bloc.listAlbum,
        listAlbumTicketOffLine: _bloc.listTicket,
        ngayCheckin: _pendingCheckIn!.ngayCheckin ?? DateTime.now().toString(),
        tgHoanThanh: _pendingCheckIn!.tgHoanThanh ?? '',
        numberTimeCheckOut: _pendingCheckIn!.numberTimeCheckOut ?? 0,
        isSynSuccess: false,
        item: restoredCheckIn,
        isGpsFormCustomer: true,
      ),
      withNavBar: false,
    ).then((value) {
      // Refresh pending check-in status sau khi quay lại
      if (value != null) {
        _bloc.add(CheckPendingCheckInEvent(customerCode: widget.idCustomer.toString()));
      }
    });
  }

}
