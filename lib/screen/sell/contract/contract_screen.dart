// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:dms/model/database/data_local.dart';
import 'package:dms/screen/sell/contract/contract_bloc.dart';
import 'package:dms/screen/sell/contract/contract_state.dart';
import 'package:dms/screen/sell/contract/component/skeleton_loading.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:dms/widget/widget_helper.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../themes/colors.dart';
import '../../../utils/utils.dart';
import 'component/detail_contract.dart';
import 'contract_event.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  _ContractScreenState createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> with TickerProviderStateMixin{

  late ContractBloc _bloc;
  bool showSearch = false;
  TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = ContractBloc(context);
    _bloc.add(GetContractPrefsEvent());
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ContractBloc,ContractState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetListContractEvent(pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
          }
        },
        child: BlocBuilder<ContractBloc,ContractState>(
          bloc: _bloc,
          builder: (BuildContext context, ContractState state){
            // Initial loading - hiển thị skeleton toàn bộ
            if (state is ContractInitialLoading) {
              return Column(
                children: [
                  buildAppBar(),
                  const Expanded(child: SkeletonContractList()),
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
                    child: const ShimmerOverlayContractList(),
                  ),
                // Fallback: Loading cũ (nếu có state khác cần loading)
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
          child: RefreshIndicator(
            color: mainColor,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 2));
              _bloc.add(GetListContractEvent(pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
            },
              child: _bloc.listContract.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _bloc.listContract.length,
                itemBuilder: (context, index) {
                  final contract = _bloc.listContract[index];
                        return _buildContractCard(contract);
                      },
                    ),
            ),
          ),
          _bloc.listContract.length > 10 ? _getDataPager() : Container(height: 40, color: Colors.white,)
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 80,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Không có hợp đồng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chưa có hợp đồng nào được tìm thấy.\nKéo xuống để làm mới danh sách.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
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

  // Helper method to format date
  String _formatDate(dynamic date) {
    if (date == null) return '---';
    String dateStr = date.toString();
    if (dateStr.toLowerCase() == 'null' || dateStr.isEmpty) return '---';
    if (dateStr.contains('T')) {
      return dateStr.split('T').first;
    }
    return dateStr;
  }

  // Helper method to get status color
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    String statusText = status.toString().trim().toLowerCase();
    if (statusText == 'duyệt' || statusText.contains('approved')) {
      return Colors.green;
    } else if (statusText.contains('lập') || statusText.contains('pending')) {
      return Colors.orange;
    } else if (statusText.contains('từ chối') || statusText.contains('reject')) {
      return Colors.red;
    }
    return Colors.grey;
  }

  // Helper method to get status display text
  String _getStatusText(String? status) {
    if (status == null) return 'Chưa xác định';
    String statusText = status.toString().trim();
    if (statusText.isEmpty || statusText.toLowerCase() == 'null') {
      return 'Chưa xác định';
    }
    if (statusText.contains('Lập')) {
      return 'Chờ duyệt';
    }
    return statusText;
  }

  Widget _buildContractCard(dynamic contract) {
    final statusColor = _getStatusColor(contract.statusname);
    final statusText = _getStatusText(contract.statusname);
    final customerName = _safeText(contract.tenKh);
    final customerCode = _safeText(contract.maKh);
    final phoneNumber = _safeText(contract.dienThoai, defaultValue: '');
    final hasPhone = phoneNumber.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
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
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: DetailContractScreen(
                contractMaster: contract,
                isSearchItem: false,
              ),
              withNavBar: false,
            ).then((_) {
                        DataLocal.listProductGift.clear();
                        _bloc.add(DeleteProductInCartEvent());
                      });
                    },
          borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                // Header: Contract Number & Status Badge
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              size: 20,
                              color: mainColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Số hợp đồng',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _safeText(contract.soCt),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusText == 'Duyệt' ? Icons.check_circle : Icons.schedule,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 16),

                // Customer Info
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Khách hàng',
                  value: customerCode != '---' && customerName != '---'
                      ? '$customerCode - $customerName'
                      : customerName != '---'
                          ? customerName
                          : '---',
                  iconColor: Colors.blue,
                ),
                
                const SizedBox(height: 12),

                // Date Information in Row
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactInfoRow(
                        icon: Icons.event_available,
                        label: 'Hiệu lực',
                        value: _formatDate(contract.ngayHl),
                        iconColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactInfoRow(
                        icon: Icons.event_busy,
                        label: 'Kết thúc',
                        value: _formatDate(contract.ngayHhl),
                        iconColor: Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Payment Due Date
                _buildInfoRow(
                  icon: Icons.payment,
                  label: 'Hạn thanh toán',
                  value: _formatDate(contract.hantt).replaceAll('Hạn thanh toán', '').trim(),
                  iconColor: Colors.orange,
                ),

                // Description (if available)
                if (_safeText(contract.dienGiai) != '---') ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.description_outlined,
                    label: 'Diễn giải',
                    value: _safeText(contract.dienGiai),
                    iconColor: Colors.purple,
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (hasPhone)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            callPhoneNumber(phoneNumber, context);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone, size: 18, color: Colors.green),
                                const SizedBox(width: 6),
                                Text(
                                  phoneNumber,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_disabled, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              'Chưa có SĐT',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Xem chi tiết',
                            style: TextStyle(
                              color: mainColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 12, color: mainColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
                        ),
                      ),
                    ),
                  );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
          Expanded(
                child: Text(
                  label,
                    style: TextStyle(
                    fontSize: 11,
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: ()=> Navigator.pop(context),
                  child: const SizedBox(
                    width: 40,
                    height: 50,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
                Visibility(
                  visible: !showSearch,
                  child: const Expanded(
                    child: Center(
                      child: Text(
                        'Danh sách hợp đồng',
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                        maxLines: 1,overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
                if (!showSearch)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _searchFocus.requestFocus();
                      setState(() => showSearch = true);},
                    child: const SizedBox( height: 50,  width: 40,
                      child: Icon(
                        EneftyIcons.search_normal_outline,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        focusNode: _searchFocus,
                        onChanged: (value) {
                          if (debounce?.isActive ?? false) debounce!.cancel();
                          debounce = Timer(const Duration(milliseconds: 500), () {
                            _bloc.add(GetListContractEvent(pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'mã HĐ, tên HD ...',
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
                              _searchFocus.requestFocus();
                            },
                            child: const Icon( Icons.clear, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                Visibility(
                  visible: showSearch,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (){
                      FocusScope.of(context).unfocus();
                      showSearch = false;
                      searchController.text = '';
                      _bloc.add(GetListContractEvent(pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
                    },
                    child: const SizedBox(
                      height: 50,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10,top: 13),
                        child: Text('Huỷ bỏ',style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                )
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
                          _bloc.add(GetListContractEvent(pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
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
                            _bloc.add(GetListContractEvent(pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
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
                                _bloc.add(GetListContractEvent(pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
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
                            _bloc.add(GetListContractEvent(pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
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
                          _bloc.add(GetListContractEvent(pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
                        },
                        child: const Icon(Icons.skip_next_outlined,color: Colors.grey)),
                  ],
              ),
            ),
          ],
      ),
    );
  }
}
