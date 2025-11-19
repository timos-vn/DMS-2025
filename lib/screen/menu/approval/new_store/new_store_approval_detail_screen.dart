import 'package:dms/model/network/response/new_store_approval_detail_response.dart';
import 'package:dms/screen/menu/approval/new_store/new_store_approval_detail_bloc.dart';
import 'package:dms/screen/menu/approval/new_store/new_store_approval_detail_event.dart';
import 'package:dms/screen/menu/approval/new_store/new_store_approval_detail_state.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class NewStoreApprovalDetailScreen extends StatefulWidget {
  final String idLead;
  final String storeName;

  const NewStoreApprovalDetailScreen({
    Key? key,
    required this.idLead,
    required this.storeName,
  }) : super(key: key);

  @override
  State<NewStoreApprovalDetailScreen> createState() =>
      _NewStoreApprovalDetailScreenState();
}

class _NewStoreApprovalDetailScreenState
    extends State<NewStoreApprovalDetailScreen> {
  late final NewStoreApprovalDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = NewStoreApprovalDetailBloc(context);
    _bloc.add(NewStoreApprovalDetailFetched(widget.idLead));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.storeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: BlocConsumer<NewStoreApprovalDetailBloc,
            NewStoreApprovalDetailState>(
          listener: (context, state) {
            if (state is NewStoreApprovalDetailFailure) {
              Utils.showCustomToast(
                context,
                Icons.error_outline,
                state.message,
              );
            } else if (state is NewStoreApprovalActionSuccess) {
              Utils.showCustomToast(
                context,
                Icons.check_circle_outline,
                state.message,
              );
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            final cachedDetail = _bloc.detail;

            if (state is NewStoreApprovalDetailLoading && cachedDetail != null) {
              return Stack(
                children: [
                  _buildDetail(cachedDetail),
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black26,
                      child: Center(child: PendingAction()),
                    ),
                  ),
                ],
              );
            }

            if (state is NewStoreApprovalDetailLoading) {
              return const Center(child: PendingAction());
            }

            if (state is NewStoreApprovalDetailFailure) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              );
            }

            if (state is NewStoreApprovalDetailLoaded) {
              return _buildDetail(state.detail);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetail(NewStoreApprovalDetailData detail) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              _buildHeader(detail),
              const SizedBox(height: 16),
              _buildQuickActions(detail),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Thông tin liên hệ',
                rows: [
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'Khách hàng',
                    value: detail.hoTen,
                  ),
                  _buildInfoRow(
                    icon: Icons.call,
                    label: 'Điện thoại',
                    value: detail.dienThoai,
                    onPrimaryTap: detail.dienThoai?.trim().isNotEmpty == true
                        ? () => _launchPhone(detail.dienThoai!.trim())
                        : null,
                    primaryIcon: Icons.phone_forwarded_outlined,
                  ),
                  _buildInfoRow(
                    icon: Icons.call_outlined,
                    label: 'Điện thoại dự phòng',
                    value: detail.dienThoaiDd,
                    onPrimaryTap: detail.dienThoaiDd?.trim().isNotEmpty == true
                        ? () => _launchPhone(detail.dienThoaiDd!.trim())
                        : null,
                    primaryIcon: Icons.phone_forwarded_outlined,
                  ),
                  _buildInfoRow(
                    icon: Icons.alternate_email,
                    label: 'Người liên hệ',
                    value: detail.nguoiLienHe,
                  ),
                  _buildInfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Ngày sinh',
                    value: detail.ngaySinh != null
                        ? Utils.parseDateTToString(
                            detail.ngaySinh!,
                            Const.DATE_FORMAT,
                          )
                        : null,
                    enableCopy: false,
                  ),
                ],
              ),
              _buildSection(
                title: 'Địa chỉ & khu vực',
                rows: [
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Địa chỉ',
                    value: detail.diaChi,
                    enableCopy: true,
                  ),
                  _buildInfoRow(
                    icon: Icons.map_outlined,
                    label: 'Tỉnh/Thành',
                    value: detail.tenTinhThanh,
                    enableCopy: false,
                  ),
                  _buildInfoRow(
                    icon: Icons.apartment_outlined,
                    label: 'Quận/Huyện',
                    value: detail.tenQuanHuyen,
                    enableCopy: false,
                  ),
                  _buildInfoRow(
                    icon: Icons.location_city_outlined,
                    label: 'Phường/Xã',
                    value: detail.tenXaPhuong,
                    enableCopy: false,
                  ),
                  _buildInfoRow(
                    icon: Icons.route_outlined,
                    label: 'Tuyến',
                    value: detail.tenTuyen,
                  ),
                ],
              ),
              _buildSection(
                title: 'Thông tin kinh doanh',
                rows: [
                  _buildInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Phân loại',
                    value: detail.tenLoai,
                    enableCopy: false,
                  ),
                  _buildInfoRow(
                    icon: Icons.store_mall_directory_outlined,
                    label: 'Hình thức',
                    value: detail.tenHinhThuc,
                    enableCopy: false,
                  ),
                  _buildInfoRow(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Mã số thuế',
                    value: detail.maSoThue,
                  ),
                  _buildInfoRow(
                    icon: Icons.info_outline,
                    label: 'Tình trạng',
                    value: detail.tenTinhTrang,
                    enableCopy: false,
                  ),
                ],
              ),
              _buildSection(
                title: 'Ghi chú',
                rows: [
                  _buildInfoRow(
                    icon: Icons.note_alt_outlined,
                    label: 'Ghi chú nội bộ',
                    value: detail.ghiChu,
                    enableCopy: true,
                  ),
                  _buildInfoRow(
                    icon: Icons.article_outlined,
                    label: 'Mô tả',
                    value: detail.moTa,
                    enableCopy: true,
                  ),
                ],
              ),
              _buildSection(
                title: 'Toạ độ',
                rows: [
                  _buildInfoRow(
                    icon: Icons.my_location_outlined,
                    label: 'Vị trí GPS',
                    value: detail.latlong,
                    enableCopy: true,
                    onPrimaryTap: detail.latlong?.trim().isNotEmpty == true
                        ? () => _openMap(detail.latlong!.trim())
                        : null,
                    primaryIcon: Icons.directions_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showConfirmDialog(detail);
              },
              icon: const Icon(Icons.verified_outlined),
              label: const Text(
                'Duyệt điểm bán',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(NewStoreApprovalDetailData detail) {
    final String displayName = detail.hoTen?.trim().isNotEmpty == true
        ? detail.hoTen!.trim()
        : 'Điểm bán mới';
    final String storeType = detail.tenLoai?.trim() ?? '';
    final String status = detail.tenTinhTrang?.trim() ?? 'Chờ xác nhận';
    final bool isApproved = status.toLowerCase().contains('duyệt');
    final List<String> locationTags = [
      if (detail.tenTinhThanh?.trim().isNotEmpty == true)
        detail.tenTinhThanh!.trim(),
      if (detail.tenQuanHuyen?.trim().isNotEmpty == true)
        detail.tenQuanHuyen!.trim(),
      if (detail.khuVuc?.trim().isNotEmpty == true) detail.khuVuc!.trim(),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            subColor.withOpacity(0.95),
            subColor.withOpacity(0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.storefront_outlined,
                  size: 30,
                  color: subColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isApproved ? Colors.greenAccent : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (storeType.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              storeType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
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
          ),
          if (locationTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: locationTags
                  .map(
                    (text) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(NewStoreApprovalDetailData detail) {
    final String primaryPhone = detail.dienThoai?.trim() ?? '';
    final String mapLocation = detail.latlong?.trim() ?? '';
    final bool hasPhone = primaryPhone.isNotEmpty;
    final bool hasLocation = mapLocation.isNotEmpty;

    if (!hasPhone && !hasLocation) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tác vụ nhanh',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: subColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (hasPhone)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchPhone(primaryPhone),
                  icon: Icon(Icons.phone_forwarded_outlined, color: subColor),
                  label: Text(
                    'Gọi ngay',
                    style: TextStyle(
                      color: subColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: subColor.withOpacity(0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            if (hasPhone && hasLocation) const SizedBox(width: 12),
            if (hasLocation)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openMap(mapLocation),
                  icon: Icon(Icons.directions_outlined, color: subColor),
                  label: Text(
                    'Xem bản đồ',
                    style: TextStyle(
                      color: subColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: subColor.withOpacity(0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget?> rows,
  }) {
    final List<Widget> visibleRows = rows.whereType<Widget>().toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: subColor,
            ),
          ),
          const SizedBox(height: 6),
          ...visibleRows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: row,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildInfoRow({
    required IconData icon,
    required String label,
    required String? value,
    VoidCallback? onPrimaryTap,
    IconData? primaryIcon,
    bool enableCopy = true,
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final String displayValue = value.trim();
    final List<Widget> actions = [];

    if (onPrimaryTap != null) {
      actions.add(
        IconButton(
          icon: Icon(primaryIcon ?? Icons.open_in_new, color: subColor),
          onPressed: onPrimaryTap,
        ),
      );
    }

    if (enableCopy) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.copy_outlined, color: Colors.grey),
          onPressed: () => _copyToClipboard(displayValue),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: subColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: subColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayValue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (actions.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actions,
          ),
      ],
    );
  }

  Future<void> _showConfirmDialog(NewStoreApprovalDetailData detail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận duyệt'),
        content: const Text(
          'Bạn có chắc muốn duyệt điểm bán mở mới này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Duyệt'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _bloc.add(NewStoreApprovalSubmitted(
        sttRec: widget.idLead,
        action: 1,
        phanCap: 1,
      ));
    }
  }

  Future<void> _copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    Utils.showCustomToast(context, Icons.copy_outlined, 'Đã sao chép');
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        Utils.showCustomToast(
          context,
          Icons.error_outline,
          'Không thể mở ứng dụng gọi điện',
        );
      }
    } catch (_) {
      if (!mounted) return;
      Utils.showCustomToast(
        context,
        Icons.error_outline,
        'Không thể mở ứng dụng gọi điện',
      );
    }
  }

  Future<void> _openMap(String location) async {
    final parts = location.split(',');
    final String query = parts.length >= 2
        ? '${parts.first.trim()},${parts.last.trim()}'
        : location.trim();
    final Uri uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        Utils.showCustomToast(
          context,
          Icons.error_outline,
          'Không thể mở bản đồ, đã sao chép toạ độ',
        );
        _copyToClipboard(query);
      }
    } catch (_) {
      if (!mounted) return;
      Utils.showCustomToast(
        context,
        Icons.error_outline,
        'Không thể mở bản đồ, đã sao chép toạ độ',
      );
      _copyToClipboard(query);
    }
  }
}

