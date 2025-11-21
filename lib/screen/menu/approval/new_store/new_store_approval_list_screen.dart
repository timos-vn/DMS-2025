import 'package:dms/model/network/response/new_store_approval_list_response.dart';
import 'package:dms/screen/menu/approval/new_store/new_store_approval_detail_screen.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'new_store_approval_list_bloc.dart';
import 'new_store_approval_list_event.dart';
import 'new_store_approval_list_state.dart';

class NewStoreApprovalListScreen extends StatefulWidget {
  const NewStoreApprovalListScreen({Key? key}) : super(key: key);

  @override
  State<NewStoreApprovalListScreen> createState() =>
      _NewStoreApprovalListScreenState();
}

class _NewStoreApprovalListScreenState extends State<NewStoreApprovalListScreen> {
  late final NewStoreApprovalListBloc _bloc;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _statusOptions = const [
    {'label': 'Chờ duyệt', 'value': 0},
    {'label': 'Đã duyệt', 'value': 1},
    {'label': 'Từ chối', 'value': 2},
    {'label': 'Tất cả', 'value': null},
  ];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _bloc = NewStoreApprovalListBloc(context);
    _bloc.add(const NewStoreApprovalListFetch());
    _searchController.text = _bloc.keySearch;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(const NewStoreApprovalListFetch(isLoadMore: true));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildFilterBar(context),
            Expanded(
              child: BlocConsumer<NewStoreApprovalListBloc,
                  NewStoreApprovalListState>(
                listener: (context, state) {
                  if (state is NewStoreApprovalListFailure) {
                    Utils.showCustomToast(
                      context,
                      Icons.error_outline,
                      state.message,
                    );
                  }
                },
                builder: (context, state) {
                  final items = _bloc.items;

                  if (state is NewStoreApprovalListLoading && items.isEmpty) {
                    return const Center(child: PendingAction());
                  }

                  if (state is NewStoreApprovalListEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        _bloc.add(const NewStoreApprovalListFetch(isRefresh: true));
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'Úi, chưa có dữ liệu nào.',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.blueGrey),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          _bloc.add(
                              const NewStoreApprovalListFetch(isRefresh: true));
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _buildListItem(context, item);
                          },
                        ),
                      ),
                      if (state is NewStoreApprovalListLoading && state.isRefresh)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black26,
                            child: Center(child: PendingAction()),
                          ),
                        ),
                      if (state is NewStoreApprovalListLoading &&
                          state.isRefresh == false &&
                          items.isNotEmpty)
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSearching
            ? Container(
                key: const ValueKey('searchField'),
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: subColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText:
                              'Tìm kiếm theo tên KH / cửa hàng / điện thoại',
                          border: InputBorder.none,
                        ),
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          _bloc.add(NewStoreApprovalListSearch(value.trim()));
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, color: subColor),
                        onPressed: () {
                          _searchController.clear();
                          _bloc.add(const NewStoreApprovalListSearch(''));
                        },
                      ),
                  ],
                ),
              )
            : const Text(
                'Duyệt điểm bán mở mới',
                key: ValueKey('title'),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isSearching
              ? IconButton(
                  key: const ValueKey('closeSearch'),
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                    });
                    if (_searchController.text.isNotEmpty) {
                      _searchController.clear();
                      _bloc.add(const NewStoreApprovalListSearch(''));
                    }
                  },
                )
              : IconButton(
                  key: const ValueKey('openSearch'),
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final dateFromText =
        Utils.parseDateToString(_bloc.dateFrom, Const.DATE_FORMAT);
    final dateToText =
        Utils.parseDateToString(_bloc.dateTo, Const.DATE_FORMAT);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  context: context,
                  label: 'Từ ngày',
                  value: dateFromText,
                  onTap: () async {
                    final selected = await Utils.dateTimePickerCustom(context);
                    if (selected != null) {
                      _bloc.add(NewStoreApprovalListUpdateFilter(
                        dateFrom: selected,
                      ));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip(
                  context: context,
                  label: 'Đến ngày',
                  value: dateToText,
                  onTap: () async {
                    final selected = await Utils.dateTimePickerCustom(context);
                    if (selected != null) {
                      _bloc.add(NewStoreApprovalListUpdateFilter(
                        dateTo: selected,
                      ));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined, color: subColor),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: _statusOptions
                        .firstWhere(
                          (element) => element['value'] == _bloc.status,
                          orElse: () => _statusOptions.last,
                        )['value'] as int?,
                    items: _statusOptions
                        .map(
                          (option) => DropdownMenuItem<int?>(
                            value: option['value'] as int?,
                            child: Text(
                              option['label'] as String,
                              style: const TextStyle(
                                color: subColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      _bloc.add(NewStoreApprovalListUpdateFilter(status: value));
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: subColor.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(MdiIcons.calendar, size: 18, color: subColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: subColor.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: subColor),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, NewStoreApprovalItem item) {
    final bool isApproved = item.trangThai ?? false;
    final Color statusColor = isApproved ? Colors.green : subColor;
    final statusText = (item.tenTrangThai ?? '').trim().isEmpty
        ? (item.trangThai ?? false ? 'Đã duyệt' : 'Chờ duyệt')
        : item.tenTrangThai!.trim();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if ((item.keyValue ?? '').trim().isEmpty) return;
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: NewStoreApprovalDetailScreen(
              idLead: item.keyValue!.trim(),
              storeName: item.tenCuaHang?.trim().isNotEmpty == true
                  ? item.tenCuaHang!.trim()
                  : item.tenKhachHang?.trim() ?? 'Chi tiết điểm bán',
            ),
            withNavBar: false,
          ).then((value) {
            if (value == true) {
              _bloc.add(const NewStoreApprovalListFetch(isRefresh: true));
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.tenCuaHang?.trim().isNotEmpty == true
                          ? item.tenCuaHang!.trim()
                          : item.tenKhachHang?.trim() ?? '(Chưa cập nhật)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if ((item.diaChi ?? '').trim().isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: subColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.diaChi!.trim(),
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              if ((item.dienThoai ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: subColor),
                    const SizedBox(width: 6),
                    Text(
                      item.dienThoai!.trim(),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: subColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Người tạo: ${item.nguoiTao?.trim() ?? '(Không rõ)'}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
              if ((item.ngayTao ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: subColor),
                    const SizedBox(width: 6),
                    Text(
                      Utils.parseDateTToString(
                        item.ngayTao.toString(),
                        Const.DATE_TIME_FORMAT_LOCAL,
                      ),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

