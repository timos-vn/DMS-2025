import 'dart:async';
import 'dart:convert';

import 'package:dms/screen/dms/inventory/stock_inventory.dart';
import 'package:dms/widget/barcode_scanner_widget.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vibration/vibration.dart';

import '../../../model/network/response/inventory_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/utils.dart';
import '../dms_bloc.dart';
import '../dms_event.dart';
import '../dms_state.dart';
import 'model/draft_ticket.dart';


class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({key,
    required this.ticket,
    this.draft,this.onCompleteDraft,
  });

  final ListInventoryRequestResponseData ticket;
  final DraftTicket? draft;
  final ValueChanged<String>? onCompleteDraft;


  @override
  _TicketDetailScreenState createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>with TickerProviderStateMixin {
  late DMSBloc _bloc;
  bool showSearch = false;
  bool chooseStock = false;
  TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<String> listIconsV4 = ['Sản phẩm','Lịch sử'];
  late TabController tabController;
  int tabIndex = 0;
  late List<ItemHistoryInventoryResponseData> filteredListHistory = [];

  late DraftTicket currentDraft;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(vsync: this, length:  listIconsV4.length);
    currentDraft = widget.draft ??
        DraftTicket(
          historyList: [],
          inventoryList: [],
          lastModified: DateTime.now(),
          autoIncrementSttRec0: 1,
        );
    _bloc = DMSBloc(context);
    _bloc.add(GetPrefsDMSEvent());
    tabController.addListener(() {
      tabIndex = tabController.index;
      if(tabIndex == 0){
        // if(chooseStock == false){
        //   _bloc.add(GetListItemInventoryEvent(sttRec: widget.sttRec,pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
        // }else{
        //   _bloc.add(GetListItemInventoryEvent(sttRec: widget.sttRec,pageIndex: selectedPage, searchKey: item.maKho.toString().trim()));
        // }
      }else{
        if(_maVtSelected.toString().replaceAll('null', '').isNotEmpty){
          showSearch = true;
          searchController.text = _maVtSelected.toString().replaceAll('null', '');
          Future.delayed(const Duration(milliseconds: 500), () {
            updateFilter(searchController.text.toString());
          });
        }else{
          setState(() {
            totalSoLuongKk = filteredListHistory.fold<double>(
              0,
                  (sum, item) => sum + (item.soLuongKk ?? 0),
            );
          });
        }
      }
    });
  }
  double totalSoLuongKk = 0;
  void updateFilter(String value) {
    final keyword = value.trim().toLowerCase();

    searchController.text = keyword;

    // Lọc từ currentDraft.historyList chứ không phải từ BLoC gốc nữa!
    filteredListHistory = currentDraft.historyList.where((w) {
      final maIn = w.maIn?.trim().toLowerCase() ?? '';
      final maVt = w.maVt?.trim().toLowerCase() ?? '';
      final tenVt = w.tenVt?.trim().toLowerCase() ?? '';

      return maIn.contains(keyword) || maVt.contains(keyword) || tenVt.contains(keyword);
    }).toList();

    // Tính lại tổng SLKK
    totalSoLuongKk = filteredListHistory.fold<double>(
      0,
          (sum, item) => sum + (item.soLuongKk ?? 0),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Luôn trả về currentDraft khi pop bằng nút vật lý!
        Navigator.pop(context, currentDraft);
        return false; // Chặn pop mặc định
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
           _bloc.add(UpdateInventoryEvent(currentDraft: currentDraft,sttRec: widget.ticket.sttRec.toString()));
          },
          child: const Icon(Icons.add),
        ),

        body: BlocListener<DMSBloc, DMSState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state is GetPrefsSuccess) {
              _bloc.add(GetListStoreFromSttRecEvent(sttRec: widget.ticket.sttRec.toString()));
            }
            else if (state is GetListStockInventoryRequestSuccess) {
              _bloc.add(GetListItemInventoryEvent(sttRec: widget.ticket.sttRec.toString(),pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
            }
            else if (state is GetListInventorySuccess) {
              final apiInventory = _bloc.listItemInventory;

              // Merge với currentDraft.inventoryList cũ nếu có
              final mergedInventory = apiInventory.map((apiItem) {
                ListItemInventoryResponseData? draftItem;
                try {
                  draftItem = currentDraft.inventoryList.firstWhere(
                        (inv) => inv.maVt.toString().trim().toUpperCase() == apiItem.maVt.toString().trim().toUpperCase()
                            && inv.maKho.toString().trim().toUpperCase() == apiItem.maKho.toString().trim().toUpperCase(),
                  );
                } catch (_) {
                  draftItem = null;
                }

                return apiItem.copyWith(
                  so_luong_kk_tt: draftItem?.so_luong_kk_tt ?? 0,
                );
              }).toList();

              // Update lại currentDraft
              currentDraft = currentDraft.copyWith(
                inventoryList: mergedInventory,
                lastModified: DateTime.now(),
              );
              _bloc.add(GetListHistoryInventoryEvent(sttRec: widget.ticket.sttRec.toString(),pageIndex: selectedPage));
            }
            else if (state is GetListGetListHistoryInventorySuccess) {
              final apiList = _bloc.listItemHistoryInventory;

              // Merge API list với currentDraft.historyList
              final mergedHistory = List<ItemHistoryInventoryResponseData>.from(currentDraft.historyList);

              for (final apiItem in apiList) {
                final exist = mergedHistory.any((e) => e.maIn.toString().trim().toUpperCase() == apiItem.maIn.toString().trim().toUpperCase());
                if (!exist) {
                  mergedHistory.add(apiItem);
                }
              }

              // Tìm max sttRec0 + 1
              final maxRec0 = mergedHistory.isEmpty
                  ? 0
                  : mergedHistory.map((e) => e.sttRec0 ?? 0).reduce((a, b) => a > b ? a : b);

              // Tính lại so_luong_kk_tt cho inventoryList
              final updatedInventory = currentDraft.inventoryList.map((inv) {
                final sum = mergedHistory
                    .where((h) => h.maVt.toString().trim().toUpperCase() == inv.maVt.toString().trim().toUpperCase()
                    && h.maKho.toString().trim().toUpperCase() == inv.maKho.toString().trim().toUpperCase())
                    .fold<double>(0.0, (prev, h) => prev + (h.soLuongKk ?? 0));
                return inv.copyWith(so_luong_kk_tt: sum);
              }).toList();

              // Cập nhật currentDraft
              currentDraft = currentDraft.copyWith(
                historyList: mergedHistory,
                inventoryList: updatedInventory,
                lastModified: DateTime.now(),
                autoIncrementSttRec0: maxRec0 + 1,
              );
              filteredListHistory = currentDraft.historyList;
              // final scannerKey = BarcodeScannerWidget.globalKey;
              // scannerKey.currentState?.startCamera();
              setState(() {});
            }
            else if (state is UpdateInventorySuccess) {
              _bloc.add(UpdateHistoryInventoryEvent(currentDraft: currentDraft,sttRec: widget.ticket.sttRec.toString()));
            }
            else if (state is UpdateHistoryInventory) {
              Utils.showCustomToast(context, Icons.check, 'Cập nhật thành công');
              widget.onCompleteDraft?.call(widget.ticket.sttRec.toString());
              Navigator.pop(context, null);
            }
            else if (state is DMSFailure) {
              Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error.toString());
            }
          },
          child: BlocBuilder<DMSBloc, DMSState>(
            bloc: _bloc,
            builder: (BuildContext context, DMSState state) {
              return Stack(
                children: [
                  buildBody(context, state),
                  Visibility(
                    visible: state is DMSLoading,
                    child: const PendingAction(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  buildBody(BuildContext context, DMSState state) {
    return Column(
      children: [
        buildAppBar(),
        SizedBox(
          height: 200,width: double.infinity,
          child: BarcodeScannerWidget(
            onBarcodeDetected: (maIn) async{
                  if ((await Vibration.hasVibrator()) ?? false) {
                    Vibration.vibrate();
                  }
              addNewHistory(maIn);
            },
          ),
        ),
        Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16,right: 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.0),
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2)),
                    ),
                    child: TabBar(
                      controller: tabController,
                      unselectedLabelColor: Colors.grey.withOpacity(0.8),
                      labelColor: Colors.red,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      isScrollable: false,
                      indicatorPadding: const EdgeInsets.all(0),
                      indicatorColor: Colors.red,
                      dividerColor: Colors.red,automaticIndicatorColorAdjustment: true,
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      indicator: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              style: BorderStyle.solid,
                              color: Colors.red,
                              width: 2
                          ),
                        ),
                      ),
                      tabs: List<Widget>.generate(listIconsV4.length, (int index) {
                        return Tab(
                          text: listIconsV4[index],
                        );
                      }),
                      onTap: (index){
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        color: grey_100,
                        child: TabBarView(
                            controller: tabController,
                            children: List<Widget>.generate(listIconsV4.length, (int index) {
                              for (int i = 0; i <= (listIconsV4.length); i++) {
                                if(index == 0){
                                  return buildListSP(context,state);
                                }else{
                                  return buildHistory();
                                }
                              }
                              return const Text('');
                            })),
                      ),
                    ),
                  ),
                ),
              ],
            )
        ),
      ],
    );
  }

  String? _maVtSelected;
  buildListSP(BuildContext context, DMSState state){
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: currentDraft.inventoryList.length,
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context, int index) {
              final item = currentDraft.inventoryList[index];
              final isSelected = (state is DMSInventoryState) ? state.selectedIndex == index : false;
              if(isSelected == true){
                selectedIndex = index;
                _maVtSelected = currentDraft.inventoryList[index].maVt.toString().trim().replaceAll('null', '');
              }
              return GestureDetector(
                onTap: () {
                  if (isSelected == true) {
                    selectedIndex = index;

                    final selectedItem = currentDraft.inventoryList[selectedIndex!];

                    // Tìm các history đã nhập cho SP này (trong DRAFT, không dùng BLoC nữa)
                    final sameProductHistory = currentDraft.historyList.where(
                          (e) =>
                      (e.maVt?.trim().toUpperCase() ?? '') == (selectedItem.maVt?.trim().toUpperCase() ?? '') &&
                          (e.maKho?.trim().toUpperCase() ?? '') == (selectedItem.maKho?.trim().toUpperCase() ?? ''),
                    );

                    final maxSttRec0 = sameProductHistory.isEmpty
                        ? 0
                        : sameProductHistory
                        .map((e) => e.sttRec0 ?? 0)
                        .reduce((a, b) => a > b ? a : b);

                    // Lưu lại trong currentDraft để đồng bộ mọi nơi
                    currentDraft = currentDraft.copyWith(
                      autoIncrementSttRec0: maxSttRec0 + 1,
                    );
                  } else {
                    selectedIndex = null;
                  }
                  _bloc.add(SelectItemInventory(isSelected ? null : index),);
                },
                child: Card(
                  semanticContainer: true,
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 6, top: 10, bottom: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 5,
                          height: 100,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 3, top: 6, bottom: 5),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Kho ${item.tenKho?.trim() ?? ''}',
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (value) {
                                        if (isSelected == true) {
                                          selectedIndex = index;

                                          final selectedItem = currentDraft.inventoryList[selectedIndex!];

                                          // Tìm các history đã nhập cho SP này (trong DRAFT, không dùng BLoC nữa)
                                          final sameProductHistory = currentDraft.historyList.where(
                                                (e) =>
                                            (e.maVt?.trim().toUpperCase() ?? '') == (selectedItem.maVt?.trim().toUpperCase() ?? '') &&
                                                (e.maKho?.trim().toUpperCase() ?? '') == (selectedItem.maKho?.trim().toUpperCase() ?? ''),
                                          );

                                          final maxSttRec0 = sameProductHistory.isEmpty
                                              ? 0
                                              : sameProductHistory
                                              .map((e) => e.sttRec0 ?? 0)
                                              .reduce((a, b) => a > b ? a : b);

                                          // Lưu lại trong currentDraft để đồng bộ mọi nơi
                                          currentDraft = currentDraft.copyWith(
                                            autoIncrementSttRec0: maxSttRec0 + 1,
                                          );
                                        } else {
                                          selectedIndex = null;
                                        }
                                        _bloc.add(SelectItemInventory(isSelected ? null : index),);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '[${item.maVt?.trim() ?? ''}] ${item.tenVt?.trim() ?? ''}',
                                  style: const TextStyle(fontSize: 12, color: Colors.black),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tồn: ${item.tonHd.toString().trim() ?? ''} (${item.dvt?.trim() ?? ''})',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'KK Thực tế: ${item.so_luong_kk_tt.toString().trim().replaceAll('null', '0')} (${item.dvt?.trim() ?? ''})',
                                      style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.blue),
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Chênh lệch: ${item.chenh_lech.toString().trim().replaceAll('null', '0')} (${item.dvt?.trim() ?? ''})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: item.chenh_lech.toString().trim().replaceAll('null', '').replaceAll('0.0', '').isNotEmpty == true
                                            ? Colors.red
                                            : Colors.transparent,
                                      ),
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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
          )
        ),
        currentDraft.inventoryList.length > 10 ? _getDataPager() : Container()
      ],
    );
  }


  buildHistory(){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 14),
          child: Text('Tổng SL: $totalSoLuongKk',style: const TextStyle(color: Colors.black,fontSize: 13),),
        ),
        Expanded(
          child: filteredListHistory.isNotEmpty ? ListView.builder(
              itemCount: filteredListHistory.length,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index){
                return Slidable(
                  key: const ValueKey(1),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dragDismissible: false,
                    children: [
                      SlidableAction(
                        onPressed:(_) async{
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Xác nhận'),
                                content: const Text('Bạn có chắc chắn muốn xoá dòng này không?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Huỷ'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Xoá'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (result == true) {
                            removeHistory(filteredListHistory[index]);
                          }

                        },
                        borderRadius:const BorderRadius.all(Radius.circular(8)),
                        padding:const EdgeInsets.all(10),
                        backgroundColor: const Color(0xFFC90000),
                        foregroundColor: Colors.white,
                        icon: Icons.delete_forever,
                        label: 'Xoá',
                      ),
                    ],
                  ),
                  child: Card(
                    semanticContainer: true,
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 5,
                            height: 100,
                            decoration: const BoxDecoration(
                                borderRadius:BorderRadius.all( Radius.circular(6),)
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding:const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Kho ${filteredListHistory[index].maKho.toString().trim()}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(
                                    filteredListHistory[index].maIn.toString().trim(),
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color: Colors.black),
                                    maxLines:1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(
                                    '[${filteredListHistory[index].maVt.toString().trim()}] ${filteredListHistory[index].tenVt.toString().trim()}',
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color: Colors.black),
                                    maxLines:2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(
                                    'SLKK: ${filteredListHistory[index].soLuongKk.toString().trim()}',
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.red),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
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
              }
          ) : Container(),
        )
      ],
    );
  }

  int? selectedIndex; // index đang được chọn trong listItemInventory

  int autoIncrementSttRec0 = 1; // đếm dòng tự tăng

  void addNewHistory(String maIn) {
    if (selectedIndex == null) {
      Utils.showCustomToast(context, Icons.check_box_outlined, 'Vui lòng chọn sản phẩm trước');
      return;
    }

    final selectedItem = currentDraft.inventoryList[selectedIndex!];
    if (currentDraft.historyList.any((e) => e.maIn.toString().trim().toUpperCase() == maIn.toString().trim().toUpperCase())) {
      Utils.showCustomToast(context, Icons.edit_notifications_outlined, 'Đã tồn tại trong danh sách!');
      return;
    }

    final newItem = ItemHistoryInventoryResponseData(
      maIn: maIn.toString().trim(),
      maVt: selectedItem.maVt,
      tenVt: selectedItem.tenVt,
      maKho: selectedItem.maKho,
      soLuongKk: 10,
      sttRec0: currentDraft.autoIncrementSttRec0,
    );

    currentDraft.historyList.add(newItem);
    currentDraft.autoIncrementSttRec0++;

    // Tính lại tổng SLKK
    final sum = currentDraft.historyList
        .where((e) =>
    e.maVt.toString().trim().replaceAll('null', '').toUpperCase() ==
        selectedItem.maVt.toString().replaceAll('null', '').trim().toUpperCase() &&
        e.maKho.toString().replaceAll('null', '').trim().toUpperCase() ==
            selectedItem.maKho.toString().replaceAll('null', '').trim().toUpperCase())
        .fold<double>(0.0, (prev, e) => prev + (e.soLuongKk ?? 0));


    currentDraft.inventoryList[selectedIndex!] =
        currentDraft.inventoryList[selectedIndex!]
            .copyWith(so_luong_kk_tt: sum);

    currentDraft = currentDraft.copyWith(lastModified: DateTime.now());
    Utils.showCustomToast(context, Icons.qr_code, 'Thêm mới thành công');
    setState(() {});
  }

  void removeHistory(ItemHistoryInventoryResponseData item) {
    currentDraft.historyList.remove(item);

    // Update sum lại cho SP gốc
    final index = currentDraft.inventoryList.indexWhere(
          (inv) => inv.maVt.toString().replaceAll('null', '').trim().toUpperCase() == item.maVt.toString().replaceAll('null', '').trim().toUpperCase()
              && inv.maKho.toString().replaceAll('null', '').trim().toUpperCase() == item.maKho.toString().replaceAll('null', '').trim().toUpperCase(),
    );

    if (index != -1) {
      final sum = currentDraft.historyList
          .where((e) =>
      e.maVt.toString().replaceAll('null', '').trim().toUpperCase() ==
          item.maVt.toString().replaceAll('null', '').trim().toUpperCase() &&
          e.maKho.toString().replaceAll('null', '').trim().toUpperCase() ==
              item.maKho.toString().replaceAll('null', '').trim().toUpperCase())
          .fold<double>(0.0, (prev, e) => prev + (e.soLuongKk ?? 0));

      currentDraft.inventoryList[index] =
          currentDraft.inventoryList[index].copyWith(so_luong_kk_tt: sum);
    }

    currentDraft = currentDraft.copyWith(lastModified: DateTime.now());
    totalSoLuongKk = filteredListHistory.fold<double>(
      0,
          (sum, item) => sum + (item.soLuongKk ?? 0),
    );
    Utils.showCustomToast(context, Icons.delete_forever_outlined, 'Xoá thành công');
    setState(() {});
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
                  onTap: ()=> Navigator.pop(context, currentDraft),
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
                        'DS vật tư yêu cầu kiểm kê',
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
                        readOnly: chooseStock,
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        focusNode: _searchFocus,
                        onTap: ()=> tabIndex == 0 ? chooseStock == false ? null : showChooseStockInventory() : null,
                        onChanged: (value) {
                          if(tabIndex == 0){
                            if (debounce?.isActive ?? false) debounce!.cancel();
                            debounce = Timer(const Duration(milliseconds: 500), () {
                              currentDraft.inventoryList.clear();
                              _bloc.add(GetListItemInventoryEvent(sttRec: widget.ticket.sttRec.toString(),pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
                            });
                          }else{
                            updateFilter(value);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'kho, mã vt, tên vt ...',
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
                          suffixIcon: tabIndex == 0
                              ? GestureDetector(
                            onTap: () {
                             if(chooseStock == false){
                               chooseStock = true;
                               showChooseStockInventory();
                             }else{
                               chooseStock = false;
                               searchController.text = '';
                               _searchFocus.requestFocus();
                               item = ListsStockInventoryResponseData();
                             }
                            },
                            child: Icon( chooseStock == true ? Icons.clear : Icons.list, color: Colors.white),
                          )
                              : GestureDetector(
                            onTap: () {
                              setState((){
                                searchController.text = '';
                                // filteredListHistory.addAll(_bloc.listItemHistoryInventory);
                                // print(filteredListHistory.length);
                                updateFilter('');
                              });
                            },
                            child: const Icon(Icons.clear, color: Colors.white),
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
                      if(tabIndex == 0){
                        currentDraft.inventoryList.clear();
                        item = ListsStockInventoryResponseData();
                        _bloc.add(GetListItemInventoryEvent(sttRec: widget.ticket.sttRec.toString(),pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
                      }else{
                        updateFilter("");
                      }
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
  ListsStockInventoryResponseData item = ListsStockInventoryResponseData();
  void showChooseStockInventory(){
    showWarehousePicker(
      context: context,
      warehouses: _bloc.listStockInventory,
      onSelected: (w) {
        item = ListsStockInventoryResponseData();
        FocusScope.of(context).unfocus();
        item = w;
        searchController.text = '';
        currentDraft.inventoryList.clear();
        searchController.text = item.tenKho.toString().trim();
        _bloc.add(GetListItemInventoryEvent(searchKey: item.maKho.toString().trim(),pageIndex: selectedPage,sttRec: widget.ticket.sttRec.toString(),));
      },
    );
  }

  Future<void> showWarehousePicker({
    required BuildContext context,
    required List<ListsStockInventoryResponseData> warehouses,
    required void Function(ListsStockInventoryResponseData) onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return WarehousePicker(
          warehouses: warehouses,
          onSelected: onSelected,
        );
      },
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
                          _bloc.add(GetListItemInventoryEvent(sttRec: widget.ticket.sttRec.toString(),pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
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
                            _bloc.add(GetListItemInventoryEvent(sttRec: widget.ticket.sttRec.toString(),pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
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
                                _bloc.add(GetListItemInventoryEvent(sttRec: widget.ticket.sttRec.toString(),pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
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
                            _bloc.add(GetListItemInventoryEvent(sttRec: widget.ticket.sttRec.toString(),pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
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
                          _bloc.add(GetListItemInventoryEvent(sttRec: widget.ticket.sttRec.toString(),pageIndex: selectedPage, searchKey: Utils.convertKeySearch(searchController.text)));
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
