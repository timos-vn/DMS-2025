import 'dart:async';
import 'package:dms/model/entity/product.dart';
import 'package:dms/model/network/response/contract_reponse.dart';
import 'package:dms/screen/sell/cart/cart_screen.dart';
import 'package:dms/screen/sell/contract/component/popup_order_from_contract.dart';
import 'package:dms/screen/sell/contract/component/popup_update_quantity_contract.dart';
import 'package:dms/screen/sell/contract/contract_bloc.dart';
import 'package:dms/screen/sell/contract/contract_event.dart';
import 'package:dms/screen/sell/contract/contract_state.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        isSearchItem: widget.isSearchItem
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
                      else if(state is AddCartSuccess){
              if(widget.isSearchItem){
                // Hiển thị thông báo thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    dismissDirection: DismissDirection.startToEnd,
                    content: Text('Đã thêm $addedCount vật tư vào giỏ hàng'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Quay về màn cart_screen
                Navigator.pop(context, 'refresh_cart');
              }else{
                _bloc.add(GetCountProductEvent(isNextScreen: true));
              }
            }
          else if(state is GetListOrderFormContractSuccess){
            if (_bloc.listOrderFormContract.isNotEmpty) {
              OrderListBottomSheet.show(context, _bloc.listOrderFormContract,widget.contractMaster);
            } else {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Thông báo"),
                  content: const Text("Không có đơn hàng nào"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Đóng"),
                    )
                  ],
                ),
              );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.isSearchItem == false
                  ?
              _buildMasterInfo() : Container(),
              const Divider(),
              Expanded(child: Column(
                children: [
                  Expanded(child: _buildMaterialList()),
                  _bloc.totalPager > 1 ? _getDataPager() : Container(height: 0,)
                ],
              )),
              const Divider(),
              widget.isSearchItem == true
                  ?
              GestureDetector(
                onTap: () async {
                  if (selectedItemIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng chọn ít nhất một vật tư'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  
                  // Thêm các vật tư đã chọn vào giỏ hàng

                  for (String itemId in selectedItemIds) {
                    var selectedItem = _bloc.listItemProduct.firstWhere(
                      (item) => item.sttRec0 == itemId,
                      orElse: () => ListItem(),
                    );
                    
                    if (selectedItem.maVt != null && selectedQuantities.containsKey(itemId)) {
                      double selectedQty = selectedQuantities[itemId] ?? 0;
                      
                      // Tính số lượng tối đa có thể đặt
                      double currentInCart = _getQuantityFromCartForItem(itemId);
                      double availableExcludingCurrent = _getAvailableQuantityExcludingCurrentItem(selectedItem.maVt, selectedItem.maVt2, selectedItem.so_luong_kd, itemId);
                      double maxCanOrder = currentInCart + availableExcludingCurrent;
                      
                      if (selectedQty > maxCanOrder) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Vật tư ${selectedItem.maVt} vượt quá số lượng tối đa (${maxCanOrder.toInt()})'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        continue; // Bỏ qua item này
                      }
                      
                      // Tạo Product object để thêm vào giỏ hàng
                      Product product = Product(
                        code: selectedItem.maVt!,
                        name: selectedItem.tenVt ?? '',
                        name2: selectedItem.tenVt ?? '',
                        dvt: selectedItem.dvt ?? '',
                        description: '',
                        price: selectedItem.giaNt2,
                        priceAfter: selectedItem.giaNt2,
                        giaSuaDoi: selectedItem.giaNt2, // Set giaSuaDoi để getDiscountProduct() tính đúng
                        giaGui: selectedItem.giaNt2, // Set giaGui để đảm bảo tính toán chính xác
                        discountPercent: selectedItem.tlCk,
                        stockAmount: selectedItem.so_luong_kd,
                        taxPercent: selectedItem.thueSuat,
                        imageUrl: '',
                        count: selectedQty,
                        countMax: selectedItem.so_luong_kd,
                        maVt2: selectedItem.maVt2,
                        sttRec0: selectedItem.sttRec0, // Thêm sttRec0 để định danh
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
                      );
                      
                      // Thêm vào giỏ hàng (sử dụng sttRec0 làm key, THAY THẾ số lượng)
                      _bloc.add(AddCartWithSttRec0ReplaceEvent(productItem: product));
                      addedCount++;
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10,left: 5,right: 5),
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: subColor,
                      borderRadius: BorderRadius.circular(24)
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Thêm vào giỏ hàng',style: TextStyle(color: Colors.white),),
                      SizedBox(width: 8,),
                      Icon( Icons.arrow_right_alt_outlined ,color: Colors.white,)
                    ],
                  ),
                ),
              )
                  :
              _buildBottomTotal(_bloc.payment.tongTien??0, _bloc.payment.tongCk??0, _bloc.payment.tongThue??0, _bloc.payment.tongThanhToan??0),
              const SizedBox(height: 15,),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMasterInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Số HĐ', widget.contractMaster.soCt),
          _buildInfoRow(
              'Khách hàng', '${widget.contractMaster.maKh} - ${widget.contractMaster.tenKh}'),
          _buildInfoRow('Trạng thái', widget.contractMaster.statusname.toString().contains('Lập') ? 'Chờ duyệt' : widget.contractMaster.statusname,
              valueColor: Colors.green),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value,
      {Color valueColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: '$title: ',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87),
          children: [
            TextSpan(
              text: value ?? '',
              style:
              TextStyle(fontWeight: FontWeight.normal, color: valueColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialList() {
    // Debug: In ra thông tin để kiểm tra
    print('DEBUG: _bloc.listItemProduct.length = ${_bloc.listItemProduct.length}');
    print('DEBUG: widget.isSearchItem = ${widget.isSearchItem}');
    print('DEBUG: widget.cartItems = ${widget.cartItems?.length ?? 'null'}');
    
    // Lọc bỏ vật tư đã có trong giỏ hàng khi isSearchItem = true
    List<ListItem> filteredItems = _bloc.listItemProduct;
    // Tạm thời comment logic lọc để debug
    /*
    if (widget.isSearchItem && widget.cartItems != null) {
      filteredItems = _bloc.listItemProduct.where((item) {
        // Kiểm tra xem vật tư này đã có trong giỏ hàng chưa - sử dụng sttRec0 để so sánh
        bool existsInCart = widget.cartItems!.any((cartItem) => cartItem.sttRec0 == item.sttRec0);
        print('DEBUG: Item ${item.maVt} (sttRec0: ${item.sttRec0}) existsInCart = $existsInCart');
        return !existsInCart; // Chỉ hiển thị vật tư chưa có trong giỏ hàng
      }).toList();
      print('DEBUG: filteredItems.length = ${filteredItems.length}');
    }
    */
    
    return ListView.builder(
      padding: const EdgeInsets.only(left: 12,right: 12,bottom: 12,top: 2),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        double tien = item.soLuong * item.giaNt2;
        double tong = (tien - item.ck) + item.thue;
        
        // Tìm index trong list gốc để cập nhật trạng thái
        int originalIndex = _bloc.listItemProduct.indexWhere((element) => element.sttRec0 == item.sttRec0);
        if (originalIndex != -1) {
          _bloc.listItemProduct[originalIndex].isCheck = selectedItemIds.contains(item.sttRec0);
        }
        return GestureDetector(
          onTap: () {
            if(widget.isSearchItem == true){
              _handleItemSelection(originalIndex, item, !(_bloc.listItemProduct[originalIndex].isCheck ?? false));
            }
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.maVt.toString().trim()} - ${item.tenVt.toString().trim()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.isSearchItem,
                        child: Checkbox(
                          value: _bloc.listItemProduct[originalIndex].isCheck,
                          onChanged: (value) {
                            _handleItemSelection(originalIndex, item, value ?? false);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                                     _buildDetailRow('Kho', '${item.maKho?.toString().trim() ?? ''} - ${item.tenKho?.toString().trim() ?? ''}'),
                   _buildDetailRow('Số lượng', widget.isSearchItem 
                     ? _buildQuantityDisplayForSearchItem(item)
                     : '${Utils.formatDecimalNumber(item.slDh)}/${Utils.formatDecimalNumber(item.so_luong_kd)} ${item.dvt?.toString() ?? ''}', 
                     highlight: widget.isSearchItem 
                       ? _getAvailableQuantityForItem(item.maVt, item.maVt2, item.so_luong_kd) > 0
                       : item.slDh < item.so_luong_kd),
                   _buildDetailRow('Đơn giá', '${Utils.formatMoneyStringToDouble(item.giaNt2)} đ'),
                   if (item.tlCk.toString() != 'null' && item.tlCk.toString().isNotEmpty)
                     _buildDetailRow('Tỷ lệ CK', '${Utils.formatDecimalNumber(item.tlCk)}%'),
                   if (item.thueSuat.toString() != 'null' && item.thueSuat.toString().isNotEmpty)
                     _buildDetailRow('Thuế', '${Utils.formatDecimalNumber(item.thueSuat)}%'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Expanded(child: Text('Tổng sau CK & thuế')),
                        Text(
                          '${Utils.formatMoneyStringToDouble(tong)} đ',
                          style: const TextStyle(
                            fontWeight:  FontWeight.bold ,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    // Ẩn trường nếu giá trị rỗng hoặc "null"
    if (value.isEmpty || value.trim() == 'null' || value.trim() == '') {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width:100,child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                color: highlight ? Colors.indigo : Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTotal(double tien, double ck, double thue, double tong) {
    return Container(
      color: Colors.indigo.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTotalRow('Tổng tiền', tien),
          _buildTotalRow('Tổng chiết khấu', ck),
          _buildTotalRow('Tổng thuế', thue),
          const Divider(),
          _buildTotalRow('Tổng thanh toán', tong, bold: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String title, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text('${Utils.formatMoneyStringToDouble(value)} đ',
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: bold ? Colors.indigo : Colors.black87)),
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
                      // Kiểm tra xem có vật tư nào còn số lượng khả dụng không
                      bool hasAvailableQuantity = false;
                      for (var item in _bloc.listItemProduct) {
                        double availableQuantity = _getAvailableQuantityForItem(item.maVt, item.maVt2, item.so_luong_kd);
                        if (availableQuantity > 0) {
                          hasAvailableQuantity = true;
                          break;
                        }
                      }

                      if (!hasAvailableQuantity) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Thông báo'),
                            content: const Text('Không còn số lượng khả dụng để đặt hàng'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Đóng'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      showDialog(
                          context: context,
                          builder: (context) {
                            return WillPopScope(
                                onWillPop: () async => true,
                                child: CustomQuestionComponent(
                                  showTwoButton: true,
                                  iconData: Icons.warning_amber_outlined,
                                  title: 'Tạo đơn hàng cho HĐ ${widget.contractMaster.soCt.toString().trim()}',
                                  content: 'Thao tác này sẽ đưa bạn đến mục tạo đơn hàng',
                                )
                            );
                          }).then((onValues){
                           if(onValues.toString().contains('Yeah')){
                             //_bloc.add(DeleteProductInCartEvent());
                             PersistentNavBarNavigator.pushNewScreen(context, screen: CartScreen(
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
                                 codeCustomer: widget.contractMaster.maKh, loadDataLocal: true,
                                 sttRectHD: widget.contractMaster.sttRec,
                                 isContractCreateOrder: true,
                                 contractMaster: widget.contractMaster,
                               ),withNavBar: false).then((result){
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
                                _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
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
                          _bloc.add(GetDetailContractEvent(searchKey: Utils.convertKeySearch(searchController.text),pageIndex: selectedPage, sttRec: widget.contractMaster.sttRec.toString(),date: widget.contractMaster.ngayCt.toString().split('T').first, isSearchItem:  widget.isSearchItem));
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
    for (String selectedId in selectedItemIds) {
      var selectedItem = _bloc.listItemProduct.firstWhere(
        (element) => element.sttRec0 == selectedId,
        orElse: () => ListItem(),
      );
      if (selectedItem.maVt2 == maVt2) {
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
    for (String selectedId in selectedItemIds) {
      if (selectedId == currentItemId) continue; // Bỏ qua item hiện tại
      
      var selectedItem = _bloc.listItemProduct.firstWhere(
        (element) => element.sttRec0 == selectedId,
        orElse: () => ListItem(),
      );
      if (selectedItem.maVt2 == maVt2) {
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
    for (String selectedId in selectedItemIds) {
      var selectedItem = _bloc.listItemProduct.firstWhere(
        (element) => element.sttRec0 == selectedId,
        orElse: () => ListItem(),
      );
      if (selectedItem.maVt2 == item.maVt2) {
        totalOrderedForMaVt2 += selectedQuantities[selectedId] ?? 0;
      }
    }
    
    double remainingAvailable = (item.so_luong_kd - totalOrderedForMaVt2).clamp(0, item.so_luong_kd);
    
    return '${Utils.formatDecimalNumber(totalCurrent)}/${Utils.formatDecimalNumber(remainingAvailable)} ${item.dvt?.toString() ?? ''}';
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
          });
        },
        maVt2: item.maVt ?? '',
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
      });
    }
  }


}






