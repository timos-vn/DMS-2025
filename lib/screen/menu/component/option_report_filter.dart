import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/model/network/response/report_field_lookup_response.dart';
import 'package:dms/screen/filter/filter_bloc.dart';
import 'package:dms/screen/filter/filter_event.dart';
import 'package:dms/screen/filter/filter_state.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/utils.dart';

enum _SearchMode { code, name, both }

class OptionReportFilter extends StatefulWidget {
  final String controller;
  final String listItem;
  final bool show;
  const OptionReportFilter(
      {super.key,
      required this.controller,
      required this.listItem,
      required this.show});
  @override
  _OptionReportFilterState createState() => _OptionReportFilterState();
}

class _OptionReportFilterState extends State<OptionReportFilter> {
  late FilterBloc _filterBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  _SearchMode _searchMode = _SearchMode.code;

  @override
  void initState() {
    super.initState();
    _filterBloc = FilterBloc(context);
    _filterBloc.add(GetPrefs());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _filterBloc.close();
    super.dispose();
  }

  void _loadPage(int page, {String? query}) {
    if (!mounted) {
      return;
    }
    FocusScope.of(context).unfocus();
    final safePage = page < 1 ? 1 : page;
    final rawQuery = query ?? _searchController.text.trim();
    String codeQuery = '';
    String nameQuery = '';
    switch (_searchMode) {
      case _SearchMode.code:
        codeQuery = rawQuery;
        break;
      case _SearchMode.name:
        nameQuery = rawQuery;
        break;
      case _SearchMode.both:
        codeQuery = rawQuery;
        nameQuery = rawQuery;
        break;
    }
    _filterBloc.add(GetListFieldLookup(
      controller: widget.controller,
      listItem: widget.listItem,
      pageIndex: safePage,
      searchTextCode: codeQuery,
      searchTextName: nameQuery,
    ));
  }

  void _triggerSearch() {
    _loadPage(1, query: _searchController.text.trim());
  }

  void _onToggleItem(ReportFieldLookupResponseData item, bool isSelected) {
    setState(() {
      if (!widget.show && isSelected) {
        for (final element in _filterBloc.listRPLP) {
          element.isChecked = false;
        }
        _filterBloc.listCheckedReport.clear();
      }
      item.isChecked = isSelected;
      if (!widget.show && !isSelected) {
        _filterBloc.listCheckedReport.clear();
      }
    });
    _filterBloc.add(AddItemSelectedEvent(item, isSelected));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocProvider<FilterBloc>.value(
        value: _filterBloc,
        child: BlocListener<FilterBloc, FilterState>(
          listener: (context, state) {
            if (state is GetPrefsSuccess) {
              _loadPage(1);
            }
            if (state is FilterSuccess) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            }
            if (state is FilterFailure) {
              Utils.showCustomToast(
                context,
                Icons.warning_amber_outlined,
                state.error,
              );
            }
          },
          child: BlocBuilder<FilterBloc, FilterState>(
            builder: (context, state) {
              return buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, FilterState state) {
    final list = _filterBloc.listRPLP;
    final bool isInitialLoading = state is FilterLoading && list.isEmpty;
    final bool isLoading = state is FilterLoading && list.isNotEmpty;

    final footer = widget.show
        ? _buildSelectionFooter(context)
        : _buildSingleSelectFooter(context);
    final double maxHeight = MediaQuery.of(context).size.height * 0.75;
    final double dialogHeight = maxHeight.clamp(440, 560);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      title: _buildHeader(context),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SizedBox(
          width: double.maxFinite,
          height: dialogHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchSection(),
              const SizedBox(height: 16),
              Expanded(
                child: isInitialLoading
                    ? const Center(child: PendingAction())
                    : _buildResultList(state, list, isLoading),
              ),
              const SizedBox(height: 16),
              _buildPagination(state, list),
              const SizedBox(height: 16),
              footer,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: orange.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.tune,
            size: 20,
            color: orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Điều kiện lọc',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Tooltip(
          message: 'Đóng',
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        )
      ],
    );
  }

  Widget _buildSearchSection() {
    return _buildSearchField(
      controller: _searchController,
      hintText: 'Nhập từ khoá',
      focusNode: _searchFocusNode,
      onSearch: _triggerSearch,
      onClear: () {
        setState(() {
          _searchController.clear();
        });
        _triggerSearch();
      },
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required FocusNode focusNode,
    required VoidCallback onSearch,
    required VoidCallback onClear,
  }) {
    const modeLabels = {
      _SearchMode.code: 'Mã',
      _SearchMode.name: 'Tên',
    };
    final entries = modeLabels.entries.toList();
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        setState(() {});
      },
      onSubmitted: (_) => onSearch(),
      style: const TextStyle(fontSize: 14, color: accent),
      decoration: InputDecoration(
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0, maxHeight: 48),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8, right: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400, width: 0.8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_SearchMode>(
                value: _searchMode,
                isDense: true,
                icon: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(12),
                selectedItemBuilder: (context) => entries
                    .map(
                      (entry) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entry.value,
                            style: const TextStyle(fontSize: 12, color: accent),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: accent,
                          ),
                        ],
                      ),
                    )
                    .toList(),
                items: entries
                    .map(
                      (entry) => DropdownMenuItem<_SearchMode>(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 12, color: accent),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (mode) {
                  if (mode == null) return;
                  setState(() {
                    _searchMode = mode;
                  });
                  onSearch();
                },
              ),
            ),
          ),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.text.isNotEmpty)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.clear, size: 18),
                tooltip: 'Xoá',
              ),
            IconButton(
              onPressed: onSearch,
              icon: const Icon(Icons.search, size: 18),
              tooltip: 'Tìm kiếm',
            ),
          ],
        ),
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: orange, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildResultList(
    FilterState state,
    List<ReportFieldLookupResponseData> list,
    bool isLoading,
  ) {
    if (state is FilterEmpty) {
      return _buildEmptyState();
    }
    if (list.isEmpty) {
      return const Center(child: PendingAction());
    }
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: ListView.separated(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _buildListTile(list[index]);
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: PendingAction()),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListTile(ReportFieldLookupResponseData item) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _onToggleItem(item, !item.isChecked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: item.isChecked,
              onChanged: (selected) {
                if (selected == null) return;
                _onToggleItem(item, selected);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.code ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inbox_outlined, size: 40, color: Colors.blueGrey),
          SizedBox(height: 12),
          Text(
            'Úi, Không có gì ở đây cả!!!',
            style: TextStyle(color: Colors.blueGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(
      FilterState state, List<ReportFieldLookupResponseData> list) {
    final bool isBusy = state is FilterLoading;
    final int currentPage = _filterBloc.currentPage;
    final bool canGoPrevious = currentPage > 1 && !isBusy;
    final bool canGoNext =
        _filterBloc.hasMoreData && !isBusy && list.isNotEmpty;
    final int totalKnownPages =
        (currentPage + (_filterBloc.hasMoreData ? 1 : 0)).clamp(1, 9999);
    final List<int> pageOptions =
        List<int>.generate(totalKnownPages, (index) => index + 1);
    if (!pageOptions.contains(currentPage)) {
      pageOptions.add(currentPage);
      pageOptions.sort();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Tooltip(
            message: 'Trang trước',
            child: IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  canGoPrevious ? () => _loadPage(currentPage - 1) : null,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Trang',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: currentPage,
              isDense: true,
              items: pageOptions
                  .map(
                    (page) => DropdownMenuItem<int>(
                      value: page,
                      child: Text(page.toString()),
                    ),
                  )
                  .toList(),
              onChanged: isBusy
                  ? null
                  : (page) {
                      if (page != null && page != currentPage) {
                        _loadPage(page);
                      }
                    },
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: 'Trang tiếp',
            child: IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.chevron_right),
              onPressed: canGoNext ? () => _loadPage(currentPage + 1) : null,
            ),
          ),
          const Spacer(),
          Text(
            'Hiện tại: $currentPage',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionFooter(BuildContext context) {
    final selectedCount = _filterBloc.listCheckedReport.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$selectedCount điều kiện đã chọn',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(96, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huỷ'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(110, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: selectedCount > 0
                  ? () => Navigator.of(context).pop(
                        List<ReportFieldLookupResponseData>.from(
                            _filterBloc.listCheckedReport),
                      )
                  : null,
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleSelectFooter(BuildContext context) {
    final selected = _filterBloc.listCheckedReport.isNotEmpty
        ? _filterBloc.listCheckedReport.first
        : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(96, 38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(110, 38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: selected != null
              ? () => Navigator.of(context).pop([
                    selected.code?.toString() ?? '',
                    selected.name?.toString() ?? '',
                  ])
              : null,
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
