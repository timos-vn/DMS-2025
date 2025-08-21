// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:dms/model/database/data_local.dart';
import 'package:dms/screen/sell/contract/contract_bloc.dart';
import 'package:dms/screen/sell/contract/contract_state.dart';
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
            return Stack(
              children: [
                buildBody(context, state),
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
    return Column(
      children: [
        buildAppBar(),
        Expanded(
          child: RefreshIndicator(
            color: mainColor,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 2));
              _bloc.add(GetListContractEvent(pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
            },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _bloc.listContract.length,
                itemBuilder: (context, index) {
                  final contract = _bloc.listContract[index];
                  return GestureDetector(
                    onTap: (){
                      PersistentNavBarNavigator.pushNewScreen(context, screen: DetailContractScreen(contractMaster: contract, isSearchItem: false,),withNavBar: false).then((_){
                        DataLocal.listProductGift.clear();
                        _bloc.add(DeleteProductInCartEvent());
                      });
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleRow(Icons.receipt_long, 'Số HĐ', contract.soCt),
                            _buildTitleRow(Icons.person, 'Khách hàng',
                                '${contract.maKh} - ${contract.tenKh}'),
                            _buildTitleRow(Icons.calendar_today, 'Hạn thanh toán',
                                contract.hantt.toString().replaceAll('Hạn thanh toán', '')),
                            _buildTitleRow(Icons.date_range, 'Ngày hiệu lực',
                                contract.ngayHl.toString().split('T').first),
                            _buildTitleRow(Icons.event, 'Ngày kết thúc',
                                contract.ngayHhl.toString().split('T').first),
                            _buildTitleRow(Icons.description, 'Diễn giải',
                                contract.dienGiai),
                            Row(
                              children: [
                                Expanded(child: _buildTitleRow(
                                  Icons.verified,
                                  'Trạng thái',
                                  contract.statusname.toString().trim().contains('Lập') ? 'Chờ duyệt' : contract.statusname ,
                                  color: contract.statusname.toString().trim() == 'Duyệt'
                                      ? Colors.green
                                      : Colors.grey,
                                ),),
                                IconButton(icon: const Icon(Icons.phone),color: Colors.orange, onPressed: () {
                                  if(contract.dienThoai.toString().replaceAll('null', '').isNotEmpty){
                                    callPhoneNumber(contract.dienThoai.toString().replaceAll('null', ''),context);
                                  }else{
                                    Utils.showCustomToast(context, Icons.warning_amber, 'Khách hàng chưa khai báo SĐT');
                                  }
                                },),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ),
        ),
        _bloc.listContract.length > 10 ? _getDataPager() : Container(height: 40,)
      ],
    );
  }

  Widget _buildTitleRow(IconData icon, String title, String? value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? Colors.indigo),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$title: ',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87),
                children: [
                  TextSpan(
                    text: value ?? '',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: color ?? Colors.black87),
                  ),
                ],
              ),
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
    return Center(
      child: SizedBox(
        height: 57,
        width: double.infinity,
        child: Column(
          children: [
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,bottom: 2),
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
                                    color: selectedPage == (index + 1) ?  mainColor : Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(48))
                                ),
                                child: Center(
                                  child: Text((index + 1).toString(),style: TextStyle(color: selectedPage == (index + 1) ?  Colors.white : Colors.black),),
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
            ),
          ],
        ),
      ),
    );
  }
}
