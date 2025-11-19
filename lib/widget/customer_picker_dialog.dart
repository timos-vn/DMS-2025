// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../model/network/response/manager_customer_response.dart';
import '../themes/colors.dart';
import '../utils/debouncer.dart';
import '../utils/utils.dart';
import '../screen/sell/contract/component/skeleton_loading.dart';
import '../screen/customer/search_customer/search_customer_bloc.dart';
import '../screen/customer/search_customer/search_customer_event.dart';
import '../screen/customer/search_customer/search_customer_state.dart';

class CustomerPickerDialog extends StatefulWidget {
  const CustomerPickerDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CustomerPickerDialogState();
  }
}

class _CustomerPickerDialogState extends State<CustomerPickerDialog> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  late SearchCustomerBloc _bloc;
  late ScrollController _scrollController;
  final double _scrollThreshold = 200.0;
  bool _hasReachedMax = true;
  final Debounce _debouncer = Debounce(delay: const Duration(milliseconds: 500));

  List<ManagerCustomerResponseData> _results = [];

  @override
  void initState() {
    super.initState();
    _bloc = SearchCustomerBloc(context);
    _bloc.add(GetPrefs());
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(SearchCustomer(Utils.convertKeySearch(_searchController.text), false, isLoadMore: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.92,
        height: MediaQuery.of(context).size.height * 0.8,
        child: BlocListener<SearchCustomerBloc, SearchCustomerState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state is GetPrefsSuccess) {
              _bloc.allowCustomerSearch = true;
              _bloc.add(SearchCustomer(Utils.convertKeySearch(_searchController.text), false));
            }
          },
          child: BlocBuilder<SearchCustomerBloc, SearchCustomerState>(
            bloc: _bloc,
            builder: (BuildContext context, SearchCustomerState state) {
              _results = _bloc.searchResults;
              final int length = _results.length;
              if (state is SearchSuccess) {
                _hasReachedMax = length < _bloc.currentPage * 20;
              } else {
                _hasReachedMax = false;
              }
              return Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(context),
                      _buildSearchBar(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: EdgeInsets.zero,
                          separatorBuilder: (context, index) => const Divider(height: 0),
                          itemCount: length == 0 ? (state is SearchLoading ? 6 : 0) : _hasReachedMax ? length : length + 1,
                          itemBuilder: (context, index) {
                            if (state is SearchLoading && length == 0) {
                              // Initial loading shimmer
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: SkeletonContractCard(),
                              );
                            }
                            if (index >= length) {
                              // Pagination shimmer footer
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: SkeletonContractCard(),
                              );
                            }
                            final item = _results[index];
                            return ListTile(
                              onTap: () => Navigator.pop(context, item),
                              leading: const CircleAvatar(backgroundColor: subColor, child: Icon(Icons.person, color: Colors.white, size: 18)),
                              title: Text(item.customerName ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(children: [const Icon(Icons.location_on, size: 12, color: grey), const SizedBox(width: 4), Expanded(child: Text(item.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: grey)))]),
                                  const SizedBox(height: 4),
                                  Row(children: [const Icon(Icons.phone, size: 12, color: grey), const SizedBox(width: 4), Text(item.phone ?? '', style: const TextStyle(fontSize: 12, color: grey))]),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  Visibility(visible: state is EmptySearchState, child: const Center(child: Text('Úi, Không có gì ở đây cả !!!', style: TextStyle(color: Colors.blueGrey, fontSize: 12)))),
                  // Replace spinner with shimmer overlay if needed. Keep UI clean without spinner.
                  const SizedBox.shrink(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: subColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Chọn khách hàng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(onPressed: () => Navigator.pop(context), icon: Icon(MdiIcons.close, color: Colors.white))
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: const BorderRadius.all(Radius.circular(12))),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            const Icon(Icons.search, color: grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Tìm kiếm khách hàng'),
                onChanged: (text) {
                  _debouncer.debounce(() => _bloc.add(SearchCustomer(Utils.convertKeySearch(text), false)));
                },
              ),
            ),
            Visibility(
              visible: _searchController.text.isNotEmpty,
              child: InkWell(
                onTap: () {
                  _searchController.clear();
                  _bloc.add(SearchCustomer(Utils.convertKeySearch(''), false));
                  setState(() {});
                },
                child: Icon(MdiIcons.closeCircle, color: grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.reset();
    super.dispose();
  }
}


