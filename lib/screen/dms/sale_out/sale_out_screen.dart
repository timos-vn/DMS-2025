// ignore_for_file: library_private_types_in_public_api
// import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:dms/widget/InputDiscountPercent.dart';
import 'package:dms/widget/custom_confirm.dart';
import 'package:dms/widget/input_quantity_popup_order.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:dms/widget/text_field_widget2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../model/network/response/manager_customer_response.dart';
import '../../../model/network/response/setting_options_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../customer/search_customer/search_customer_screen.dart';
import '../../sell/component/input_address_popup.dart';
import '../../sell/component/search_product.dart';
import 'sale_out_bloc.dart';
import 'sale_out_state.dart';
import 'sale_out_event.dart';


class SaleOutScreen extends StatefulWidget {
  final String? codeCustomer;
  final String? nameCustomer;
  final String? phoneCustomer;
  final String? addressCustomer;

  const SaleOutScreen({Key? key, this.codeCustomer, this.nameCustomer, this.phoneCustomer, this.addressCustomer,}) : super(key: key);

  @override
  _SaleOutScreenState createState() => _SaleOutScreenState();
}

class _SaleOutScreenState extends State<SaleOutScreen>with TickerProviderStateMixin{

  late SaleOutBloc _bloc;
  String? dateTransfer;
  String? timeTransfer;

  final nameCompanyController = TextEditingController();
  final noteController = TextEditingController();
  final mstController = TextEditingController();
  final addressController = TextEditingController();
  final nameCompanyFocus = FocusNode();
  final mstFocus = FocusNode();final addressFocus = FocusNode();final noteFocus = FocusNode();

  final nameCustomerController = TextEditingController();
  final addressCustomerController = TextEditingController();
  final phoneCustomerController = TextEditingController();
  final nameCustomerFocus = FocusNode();
  final addressCustomerFocus = FocusNode();
  final phoneCustomerFocus = FocusNode();

  final nameAgentController = TextEditingController();
  final addressAgentController = TextEditingController();
  final phoneAgentController = TextEditingController();
  final nameAgentFocus = FocusNode();
  final addressAgentFocus = FocusNode();
  final phoneAgentFocus = FocusNode();

  String nameStore = '';
  String codeStore = '';

  late int indexSelect;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    date = Utils.parseDateToString(DateTime.now(), Const.DATE_FORMAT_2);
    _bloc = SaleOutBloc(context);
    nameCustomerController.text = widget.codeCustomer.toString();
    phoneCustomerController.text = widget.phoneCustomer.toString();
    addressCustomerController.text = widget.addressCustomer.toString();

    nameCustomerController.text = (widget.nameCustomer.toString() != 'null' && widget.nameCustomer.toString().isNotEmpty) ? widget.nameCustomer.toString() : '' ;
    phoneCustomerController.text = (widget.phoneCustomer.toString() != 'null' && widget.phoneCustomer.toString().isNotEmpty) ? widget.phoneCustomer.toString() : '' ;//widget.phoneCustomer.toString();
    addressCustomerController.text = (widget.addressCustomer.toString() != 'null' && widget.addressCustomer.toString().isNotEmpty) ? widget.addressCustomer.toString() : '' ;//widget.addressCustomer.toString();

    _bloc.customerName = (widget.nameCustomer.toString() != 'null' && widget.nameCustomer.toString().isNotEmpty) ? widget.nameCustomer.toString() : '' ;
    _bloc.phoneCustomer = (widget.phoneCustomer.toString() != 'null' && widget.phoneCustomer.toString().isNotEmpty) ? widget.phoneCustomer.toString() : '' ;//widget.phoneCustomer.toString();
    _bloc.addressCustomer = (widget.addressCustomer.toString() != 'null' && widget.addressCustomer.toString().isNotEmpty) ? widget.addressCustomer.toString() : '' ;//widget.addressCustomer.toString();
    _bloc.codeCustomer = widget.codeCustomer.toString();

    _bloc.add(GetSaleOutPrefs());
    
    // Auto load agent by maNPP nếu có
    _autoLoadAgentIfNeeded();
  }
  
  /// Auto load thông tin đại lý nếu có mã NPP
  void _autoLoadAgentIfNeeded() {
    // Check điều kiện cho phép auto add agent
    if (Const.autoAddAgentFromSaleOut != true) {
      // Không cho phép auto add → return
      return;
    } 
    
    // Check Const.maNPP có hợp lệ không
    if (Const.maNPP.isNotEmpty && 
        Const.maNPP != 'null' && 
        Const.maNPP.trim().isNotEmpty) {
      // Dispatch event để load agent
      _bloc.add(AutoLoadAgentByNPPEvent(maNPP: Const.maNPP));
    }
  }
  
  /// Hiển thị dialog thông báo khi đã load đại lý thành công
  void _showAgentLoadedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Thông báo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin đại lý/NPP đã được tự động điền:',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Tên:', _bloc.agentName ?? ''),
                    const SizedBox(height: 6),
                    _buildInfoRow('SĐT:', _bloc.agentPhone ?? ''),
                    const SizedBox(height: 6),
                    _buildInfoRow('Địa chỉ:', _bloc.agentAddress ?? ''),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng', style: TextStyle(fontSize: 15)),
            ),
          ],
        );
      },
    );
  }
  
  /// Widget hiển thị thông tin trong dialog
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleOutBloc,SaleOutState>(
      listener: (context,state){
        if(state is GetPrefsSuccess || state is DeleteProductFromDBSuccess){
          _bloc.add(GetListProductFromDB());
        }
        else if(state is PickInfoCustomerSuccess){
          // Safe handling: sử dụng null coalescing operator
          nameCustomerController.text = _bloc.customerName ?? '';
          phoneCustomerController.text = _bloc.phoneCustomer ?? '';
          addressCustomerController.text = _bloc.addressCustomer ?? '';
        }
        else if(state is PickInfoAgentSuccess){
          // Safe handling: sử dụng null coalescing operator
          nameAgentController.text = _bloc.agentName ?? '';
          phoneAgentController.text = _bloc.agentPhone ?? '';
          addressAgentController.text = _bloc.agentAddress ?? '';
        }
        else if(state is AutoLoadAgentSuccess){
          // Auto fill thông tin đại lý từ maNPP
          nameAgentController.text = _bloc.agentName ?? '';
          phoneAgentController.text = _bloc.agentPhone ?? '';
          addressAgentController.text = _bloc.agentAddress ?? '';
          codeAgent = _bloc.agentCode ?? '';
          
          // Hiển thị dialog thông báo
          _showAgentLoadedDialog();
        }
        else if(state is SaleOutSuccess){
          _bloc.add(DeleteAllProductFromDB());
          _bloc.listProductOrderAndUpdate.clear();
          nameCustomerController.text = '';
          phoneCustomerController.text = '';
          addressCustomerController.text = '';
          DataLocal.listProductGiftSaleOut.clear();
          nameAgentController.text = '';
          phoneAgentController.text = '';
          addressAgentController.text = '';
          Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Cập nhật Sale-out công thành công');
          Navigator.pop(context,['ReloadScreen']);
        }
        else if(state is GetListStockEventSuccess){
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return InputQuantityPopupOrder(
                  title: 'Cập nhật số lượng',
                  quantity: 0,
                  quantityStock: _bloc.listProductOrderAndUpdate[indexSelect].stockAmount??0,
                  listDvt: _bloc.listProductOrderAndUpdate[indexSelect].allowDvt == 0 ? _bloc.listProductOrderAndUpdate[indexSelect].contentDvt!.split(',').toList() : [],
                  inventoryStore: false,
                  listStock: const [],
                  findStock: false,
                  allowDvt: _bloc.listProductOrderAndUpdate[indexSelect].allowDvt == 0 ? true : false,
                  nameProduction: _bloc.listProductOrderAndUpdate[indexSelect].name.toString(),
                  price:  _bloc.listProductOrderAndUpdate[indexSelect].price??0,
                  codeProduction: _bloc.listProductOrderAndUpdate[indexSelect].code.toString(),
                  listObjectJson: _bloc.listProductOrderAndUpdate[indexSelect].jsonOtherInfo.toString(), listQuyDoiDonViTinh: [],
                  nuocsx: '',quycach: '',tenThue: '',thueSuat: '',
                  originalPrice: _bloc.listProductOrderAndUpdate[indexSelect].originalPrice,
                );
              }).then((value){
            if(value != null && double.parse(value[0].toString()) > 0){
              _bloc.listProductOrderAndUpdate[indexSelect].count = double.parse(value[0].toString());
              // Cập nhật giá nếu có thay đổi (value[4] là giá)
              if(value.length > 4 && value[4] != null){
                _bloc.listProductOrderAndUpdate[indexSelect].price = double.parse(value[4].toString());
              }
              _bloc.add(UpdateProductCountEvent(index: indexSelect,item: _bloc.listProductOrderAndUpdate[indexSelect]));
            }
          });
        }
        else if(state is UpdateProductFromDBSuccess || state is DeleteAllProductFromDBSuccess || state is DeleteProductFromDBSuccess){
          _bloc.add(GetListProductFromDB());
        }
      },
      bloc: _bloc,
      child: BlocBuilder<SaleOutBloc,SaleOutState>(
        bloc: _bloc,
        builder: (BuildContext context,SaleOutState state){
          return Stack( 
            children: [
              buildScreen(context, state),
              Visibility(
                visible: state is SaleOutLoading,
                child: const PendingAction(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildScreen(BuildContext context,SaleOutState state){
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildAppBar(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              width: double.infinity,
              height: 1,
              color: Colors.blueGrey.withOpacity(0.5),
            ),
          ),
          Expanded(
              child: buildBody(height)
          ),
        ],
      ),
    );
  }

  Widget buildBody(double height){
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              buildListCart(),
              buildLine(),
              Visibility(
                visible: Const.chooseSaleOffSaleOut == true,
                child: buildListProductGiftCart(),
              ),

              Visibility(
                visible: Const.chooseSaleOffSaleOut == true,
                child: buildLine(),
              ),
              buildMethodReceive(),
              const SizedBox(height: 50,),
            ],
          ),
        ),
        buildUpdate()
      ],
    );
  }

  buildUpdate(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10,right: 10,top: 12,bottom: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text('${NumberFormat(Const.amountFormat).format(_bloc.totalMNProduct??0)} đ',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.normal,decoration: TextDecoration.lineThrough),),
            // const SizedBox(width: 8,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng sản phẩm/\$',style: TextStyle(color: Colors.black,fontSize: 12),),
                Text(' ${_bloc.listProductOrderAndUpdate.length} sản phẩm / ${Utils.formatMoneyStringToDouble(_bloc.totalMoney)} ₫',style: const TextStyle(color: subColor,fontWeight: FontWeight.bold),),
              ],
            ),
            const SizedBox(width: 18,),
            GestureDetector(
              onTap: (){
                if (nameCustomerController.text.toString().isNotEmpty &&  codeCustomer.isNotEmpty){
                  if(Const.chooseAgentSaleOut == true){
                    if(nameAgentController.text.toString().isNotEmpty && codeAgent.isNotEmpty){
                      saleOut();
                    }else{
                      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn chưa chọn ĐL kìa');
                    }
                  }else{
                    saleOut();
                  }
                }
                else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn chưa chọn KH kìa');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: mainColor
                ),
                child: const Center(
                  child: Text('Cập nhật',style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saleOut(){
    if(!Utils.isEmpty(_bloc.listProductOrderAndUpdate)){
      showDialog(
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: const CustomConfirm(
                title: 'Bạn đang tạo phiếu sale out!',
                content: 'Hãy chắc chắn là bạn muốn điều này!',
                type: 1,
              ),
            );
          }).then((value) {
        if(!Utils.isEmpty(value) && value[0] == 'confirm'){
          _bloc.add(UpdateSaleOutEvent(
              dateTime: value[1],
              codeCustomer: _bloc.codeCustomer,
              listOrder: _bloc.listProductOrderAndUpdate,
              desc: _bloc.noteSell.toString(),
              dateEstDelivery: date.toString()
          ));
        }
      });
    }
    else{
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Đơn hàng của bạn đâu có gì?');
    }
  }

  buildLine(){
    return Padding(
      padding: const EdgeInsets.only(top: 10,bottom: 10),
      child: Container(
        height: 8,
        width: double.infinity,
        color: grey_200,
      ),
    );
  }

  buildListCart(){
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10,left: 12),
            child: Row(
              children: [
                Icon(MdiIcons.cubeOutline,color: mainColor,),
                const SizedBox(width: 6,),
                const Text('Sản phẩm',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          const SizedBox(height: 8,),
          Visibility(
            visible: _bloc.listProductOrderAndUpdate.isNotEmpty,
            child: SizedBox(
              height: !_bloc.expanded ? 90 : null,
              child: buildListViewProduct(),
            ),
          ),
          Visibility(
            visible: _bloc.listProductOrderAndUpdate.isNotEmpty && _bloc.listProductOrderAndUpdate.length > 1,
            child: GestureDetector(
              onTap: (){
                _bloc.add(ChangeHeightListEvent(expanded: !_bloc.expanded));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(),
                    ),
                    Text(!_bloc.expanded ? 'Xem thêm' : 'Thu gọn',style: const TextStyle(color: Colors.blueGrey,fontSize: 12.5),),
                    Icon(!_bloc.expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,color: Colors.blueGrey,size: 16,),
                    const Expanded(
                      child: Divider(),
                    )
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: _bloc.listProductOrderAndUpdate.isEmpty,
            child: const SizedBox(
              height: 200,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Úi, Không có gì ở đây cả.',style: TextStyle(color: Colors.black)),
                  SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Gợi ý: Bấm nút ',style: TextStyle(color: Colors.blueGrey,fontSize: 12.5)),
                      Icon(Icons.search_outlined,color: Colors.blueGrey,size: 18,),
                      Text(' để thêm sản phẩm của bạn',style: TextStyle(color: Colors.blueGrey,fontSize: 12.5)),
                    ],
                  ),
                ],
              )
            ),
          ),
        ],
      ),
    );
  }

  buildListViewProduct(){
    return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _bloc.listProductOrderAndUpdate.length,
        itemBuilder: (context,index){
          return Slidable(
              key: const ValueKey(1),
              startActionPane: Const.saleOutUpdatePrice == false ? null : ActionPane(
                motion: const ScrollMotion(),
                // extentRatio: 0.25,
                dragDismissible: false,
                children: [
                  SlidableAction(
                    onPressed:(_) {
                      setState(() {
                        showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) {
                              return const InputDiscountPercent(
                                title: 'Vui lòng nhập giá cho sản phẩm',
                                subTitle: 'Vui lòng nhập giá cho sản phẩm',
                                typeValues: 'vnd',
                                percent: 0,
                              );
                            }).then((value){
                          if(value[0] == 'BACK'){
                            _bloc.listProductOrderAndUpdate[index].price = value[1];
                            _bloc.add(UpdateProductCountEvent(index: index,item:  _bloc.listProductOrderAndUpdate[index]));
                          }
                        });
                      });
                    },
                    borderRadius:const BorderRadius.all(Radius.circular(8)),
                    backgroundColor: const Color(0xFFC7033B),
                    foregroundColor: Colors.white,
                    icon: Icons.discount,
                    label: 'Giá',
                  )
                ],
              ),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                dragDismissible: false,
                children: [
                  SlidableAction(
                    onPressed:(_) {
                      _bloc.add(DeleteProductFromDB(index,_bloc.listProductOrderAndUpdate[index]));
                    },
                    borderRadius:const BorderRadius.all(Radius.circular(8)),
                    backgroundColor: const Color(0xFFC90000),
                    foregroundColor: Colors.white,
                    icon: Icons.delete_forever,
                    label: 'Delete',
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: (){
                  indexSelect = index;
                  _bloc.add(GetListStockEvent(itemCode: _bloc.listProductOrderAndUpdate[index].code.toString(), checkStockEmployee: Const.checkStockEmployee == true ? false : true,));
                },
                child: Card(
                  semanticContainer: true,
                  margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Color(_bloc.listProductOrderAndUpdate[index].kColorFormatAlphaB!),
                              borderRadius: const BorderRadius.all(Radius.circular(6),)
                          ),
                          child: Center(child: Text('${_bloc.listProductOrderAndUpdate[index].name?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${_bloc.listProductOrderAndUpdate[index].name}',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          (_bloc.listProductOrderAndUpdate[index].price ?? 0) == 0 
                                              ? 'Giá đang cập nhật' 
                                              : '${Utils.formatMoneyStringToDouble(_bloc.listProductOrderAndUpdate[index].price??0)} ₫',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: (_bloc.listProductOrderAndUpdate[index].price ?? 0) == 0 
                                                ? Colors.grey 
                                                : const Color(0xff067902), 
                                            fontSize: (_bloc.listProductOrderAndUpdate[index].price ?? 0) == 0 ? 11 : 13,
                                            fontWeight: (_bloc.listProductOrderAndUpdate[index].price ?? 0) == 0 
                                                ? FontWeight.normal 
                                                : FontWeight.w700
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_bloc.listProductOrderAndUpdate[index].code}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                          0xff358032)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'SL:',
                                          style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text("${_bloc.listProductOrderAndUpdate[index].count?.toInt()??0} ${_bloc.listProductOrderAndUpdate[index].dvt}",
                                          style: const TextStyle(color: blue, fontSize: 12),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
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
              )
          );
        }

    );
  }

  buildListProductGiftCart(){
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0,left: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.cubeOutline,color: mainColor,),
                    const SizedBox(width: 6,),
                    const Text('Sản phẩm tặng',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                  ],
                ),
                InkWell(
                  onTap: (){
                    PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProductScreen(
                        idCustomer: widget.codeCustomer.toString(), /// Chỉ có thêm tồn kho ở check-in mới thêm idCustomer
                        currency: Const.currencyCode,
                        viewUpdateOrder: false,
                        listIdGroupProduct: Const.listGroupProductCode,
                        itemGroupCode: '',//Const.itemGroupCode,
                        inventoryControl: false,
                        addProductFromCheckIn: false,
                        addProductFromSaleOut: true,
                        giftProductRe: false,
                        lockInputToCart: false,
                        addProductGiftFromSaleOut: true,checkStockEmployee: false,
                        listOrder: _bloc.listProductOrderAndUpdate, backValues: false, isCheckStock: Const.isCheckStockSaleOut,),withNavBar: false).then((value){
                      setState(() {

                      });
                    });
                  },
                  child: const SizedBox(
                    height: 30,
                    width: 50,
                    child: Icon(Icons.addchart_outlined,color: Colors.black,size: 20,),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8,),
          Visibility(
            visible: DataLocal.listProductGiftSaleOut.isNotEmpty,
            child: SizedBox(
              height: (!_bloc.expandedProductGift || DataLocal.listProductGiftSaleOut.length == 1) ? 90 : 250,
              child: buildListViewProductGift(),
            ),
          ),
          Visibility(
            visible: DataLocal.listProductGiftSaleOut.isNotEmpty && DataLocal.listProductGiftSaleOut.length > 1,
            child: GestureDetector(
              onTap: (){
                _bloc.add(ChangeHeightListProductGiftEvent(expandedProductGift: !_bloc.expandedProductGift));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(),
                    ),
                    Text(!_bloc.expandedProductGift ? 'Xem thêm' : 'Thu gọn',style: const TextStyle(color: Colors.blueGrey,fontSize: 12.5),),
                    Icon(!_bloc.expandedProductGift ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,color: Colors.blueGrey,size: 16,),
                    const Expanded(
                      child: Divider(),
                    )
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: DataLocal.listProductGiftSaleOut.isEmpty,
            child: const SizedBox(
                height: 100,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Úi, Không có gì ở đây cả.',style: TextStyle(color: Colors.black,fontSize: 11.5)),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Gợi ý: Bấm nút ',style: TextStyle(color: Colors.blueGrey,fontSize: 10.5)),
                        Icon(Icons.addchart_outlined,color: Colors.blueGrey,size: 16,),
                        Text(' để thêm sản phẩm tặng của bạn',style: TextStyle(color: Colors.blueGrey,fontSize: 10.5)),
                      ],
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  buildListViewProductGift(){
    return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemCount: DataLocal.listProductGiftSaleOut.length,
        itemBuilder: (context,index){
          return Slidable(
              key: const ValueKey(1),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                // extentRatio: 0.25,
                dragDismissible: false,
                children: [
                  SlidableAction(
                    onPressed:(_) {
                      _bloc.add(AddOrDeleteProductGiftEvent(false,DataLocal.listProductGiftSaleOut[index]));
                    },
                    backgroundColor: const Color(0xFFC90000),
                    foregroundColor: Colors.white,
                    icon: Icons.delete_forever,
                    label: 'Delete',
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: (){
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return InputQuantityPopupOrder(
                          title: 'Cập nhật số lượng',
                          quantity: 0,
                            quantityStock: DataLocal.listProductGiftSaleOut[index].stockAmount??0,
                          listDvt: DataLocal.listProductGiftSaleOut[index].allowDvt == true ? DataLocal.listProductGiftSaleOut[indexSelect].contentDvt!.split(',').toList() : [],
                          inventoryStore: false,
                          listStock: const [],
                          findStock: false,
                          allowDvt: DataLocal.listProductGiftSaleOut[index].allowDvt,
                          nameProduction: DataLocal.listProductGiftSaleOut[index].name.toString(),
                          price: Const.isWoPrice == false ? DataLocal.listProductGiftSaleOut[index].price??0 : DataLocal.listProductGiftSaleOut[index].woPrice??0,
                          codeProduction: DataLocal.listProductGiftSaleOut[index].code.toString(),
                          listObjectJson: DataLocal.listProductGiftSaleOut[index].jsonOtherInfo.toString(), listQuyDoiDonViTinh: [],
                          nuocsx: '',quycach: '',tenThue: '',thueSuat: '',
                        );
                      }).then((value){
                    if(double.parse(value[0].toString()) > 0){
                      DataLocal.listProductGiftSaleOut[index].count = double.parse(value[0].toString());
                      DataLocal.listProductGiftSaleOut[index].price = 0;
                      DataLocal.listProductGiftSaleOut[index].priceAfter = 0;
                      setState(() {});
                    }
                  });
                },
                child: Card(
                  semanticContainer: true,
                  margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(6)),
                              color:  const Color(0xFF0EBB00),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    offset: const Offset(2, 4),
                                    blurRadius: 5,
                                    spreadRadius: 2)
                              ],),
                            child: const Icon(Icons.card_giftcard_rounded ,size: 16,color: Colors.white,)),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${DataLocal.listProductGiftSaleOut[index].name}',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    Column(
                                      children: [
                                        (DataLocal.listProductGiftSaleOut[index].price! > 0 && DataLocal.listProductGiftSaleOut[index].price == DataLocal.listProductGiftSaleOut[index].priceAfter ) ?
                                        Container()
                                            :
                                        Text(
                                          ((Const.currencyCode == "VND"
                                              ?
                                          DataLocal.listProductGiftSaleOut[index].price
                                              :
                                          DataLocal.listProductGiftSaleOut[index].price))
                                              == 0 ? 'Giá đang cập nhật' : '${Const.currencyCode == "VND"
                                              ?
                                          Utils.formatMoneyStringToDouble(DataLocal.listProductGiftSaleOut[index].price??0)
                                              :
                                          Utils.formatMoneyStringToDouble(DataLocal.listProductGiftSaleOut[index].price??0)} ₫'
                                          ,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(color:
                                          ((Const.currencyCode == "VND"
                                              ?
                                          DataLocal.listProductGiftSaleOut[index].price
                                              :
                                          DataLocal.listProductGiftSaleOut[index].price)) == 0
                                              ?
                                          Colors.grey : Colors.red, fontSize: 10, decoration: ((Const.currencyCode == "VND"
                                              ?
                                          DataLocal.listProductGiftSaleOut[index].price
                                              :
                                          DataLocal.listProductGiftSaleOut[index].price)) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                        ),
                                        const SizedBox(height: 3,),
                                        Visibility(
                                          visible: DataLocal.listProductGiftSaleOut[index].priceAfter! > 0,
                                          child: Text(
                                            '${Utils.formatMoneyStringToDouble(DataLocal.listProductGiftSaleOut[index].priceAfter??0)} ₫',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(color: Color(
                                                0xff067902), fontSize: 13,fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${DataLocal.listProductGiftSaleOut[index].code}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                          0xff358032)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                         'KL Tặng',
                                          style: TextStyle(color: DataLocal.listProductGiftSaleOut[index].gifProduct == true ? Colors.red : Colors.black.withOpacity(0.7), fontSize: 11),
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text("${DataLocal.listProductGiftSaleOut[index].count?.toInt()??0} (${DataLocal.listProductGiftSaleOut[index].dvt.toString().trim()})",
                                          style: TextStyle(color: DataLocal.listProductGiftSaleOut[index].gifProduct == true ? Colors.red : blue, fontSize: 12),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
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
              )
          );
        }

    );
  }

  String date = '';

  buildMethodReceive(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16,right: 8,top: 10,bottom: 6),
          child: Row(
            children: [
              Icon(MdiIcons.tagTextOutline,color: mainColor,),
              const SizedBox(width: 10,),
              const Text('Thông tin thanh toán & diễn giải',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16,right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Thông tin khách hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
              buildInfoCallOtherPeople(),
              Visibility(
                visible: Const.chooseStatusToSaleOut == true,
                child: Padding(
                  padding: EdgeInsets.only(top: 25,bottom: Const.dateEstDelivery == true ? 0 : 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loại giao dịch:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                      const SizedBox(height: 10,),
                      Container(
                          height: 45,
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey)
                          ),
                          child: transactionWidget()
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: Const.dateEstDelivery == true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14,bottom: 10),
                    child: Text('Dự kiến giao hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                  )),
              Visibility(
                visible: Const.dateEstDelivery == true,
                child: Container(
                  padding:const EdgeInsets.only(left: 12,right: 2,top: 10,bottom: 10),
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: grey.withOpacity(0.8),width: 1),
                      borderRadius: const BorderRadius.all(Radius.circular(8))
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            const Text('Ngày dự kiến giao hàng: ',style:  TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,),
                            const SizedBox(width: 5,),
                            Text(date,style: const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                        SizedBox(
                          width: 50,
                          child: InkWell(
                            onTap: (){
                              Utils.dateTimePickerCustom(context).then((value){
                                if(value != null){
                                  setState(() {
                                    date = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                  });
                                }
                              });
                            },
                            child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                          ),
                        ),
                        // SizedBox(
                        //   // height: 40,
                        //   width: 50,
                        //   child: DateTimePicker(
                        //     type: DateTimePickerType.date,
                        //     // dateMask: 'd MMM, yyyy',
                        //     initialValue: DateTime.now().toString(),
                        //     firstDate: DateTime(2000),
                        //     lastDate: DateTime(2100),
                        //     decoration:const InputDecoration(
                        //       suffixIcon: Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                        //       contentPadding: EdgeInsets.only(left: 12),
                        //       border: InputBorder.none,
                        //     ),
                        //     style:const TextStyle(fontSize: 13),
                        //     locale: const Locale("vi", "VN"),
                        //     // icon: Icon(Icons.event),
                        //     selectableDayPredicate: (date) {
                        //       // Disable weekend days to select from the calendar
                        //       // if (date.weekday == 6 || date.weekday == 7) {
                        //       //   return false;
                        //       // }
                        //
                        //       return true;
                        //     },
                        //     onChanged: (val){
                        //       // DateTime? dateOrder = val as DateTime?;
                        //       setState(() {
                        //         date = val;
                        //       });
                        //     },
                        //     validator: (result) {
                        //       DateTime? dateOrder = result as DateTime?;
                        //       setState(() {
                        //         date = Utils.parseDateToString(dateOrder!, Const.DATE_FORMAT_1);
                        //       });
                        //       return null;
                        //     },
                        //     onSaved: (val){
                        //       print('asd$val');
                        //     },
                        //   ),
                        // ),
                        // const SizedBox(width: 5,),
                      ]),
                ),
              ),
              Visibility(
                  visible: Const.chooseAgentSaleOut == true,
                  child: Padding(
                    padding: EdgeInsets.only(top: Const.dateEstDelivery == true ? 15 : 10),
                    child: Text('Thông tin Đại lý/NPP:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                  )),
              Visibility(
                visible: Const.chooseAgentSaleOut == true,
                child: buildInfoAgent(),
              ),
              const SizedBox(height: 14,),
              Text('Diễn giải:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
              GestureDetector(
                onTap: (){
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return InputAddressPopup(note: _bloc.noteSell != null ? _bloc.noteSell.toString() : "",title: 'Thêm ghi chú cho đơn hàng',desc: 'Vui lòng nhập ghi chú',convertMoney: false, inputNumber: false,);
                      }).then((note){
                    if(note != null){
                      _bloc.add(AddNote(
                        note: note,
                      ));
                    }
                  });
                },
                child: SizedBox(
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nội dung:',style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic,decoration: TextDecoration.underline,fontSize: 12),),
                      const SizedBox(width: 12,),
                      Expanded(child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(_bloc.noteSell != null ? _bloc.noteSell.toString() : "Viết tin nhắn...",style: const TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String codeCustomer = '';
  String codeAgent = '';

  buildInfoCallOtherPeople(){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(10),
              height: 40,
              width: double.infinity,
              color: Colors.amber.withOpacity(0.4),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Thông tin người liên hệ',style: TextStyle(color: Colors.black,fontSize: 13),),
              ),
            ),
            const SizedBox(height: 22,),
            GestureDetector(
              onTap:(){
                PersistentNavBarNavigator.pushNewScreen(context, screen: const SearchCustomerScreen(selected: true,allowCustomerSearch: false, inputQuantity: false,),withNavBar: false).then((value){
                  if(!Utils.isEmpty(value)){
                    ManagerCustomerResponseData infoCustomer = value;
                    codeCustomer = infoCustomer.customerCode.toString();
                    _bloc.add(PickInfoCustomer(customerName: infoCustomer.customerName,phone: infoCustomer.phone,address: infoCustomer.address,codeCustomer: infoCustomer.customerCode));
                  }
                });
              },
              child: Stack(
                children: [
                  inputWidget(title:'Tên khách hàng',hideText: "Nguyễn Văn A",controller: nameCustomerController,focusNode: nameCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
                  const Positioned(
                      top: 20,right: 10,
                      child: Icon(Icons.search_outlined,color: Colors.grey,size: 20,))
                ],
              ),
            ),
            inputWidget(title:"SĐT khách hàng",hideText: '0963 xxx xxx ',controller: phoneCustomerController,focusNode: phoneCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true),
            GestureDetector(
              onTap:(){
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      // ignore: unnecessary_null_comparison
                      return InputAddressPopup(note: addressCustomerController.text != null ? addressCustomerController.text.toString() : "",title: 'Địa chỉ KH',desc: 'Vui lòng nhập địa chỉ KH',convertMoney: false, inputNumber: false,);
                    }).then((note){
                  if(note != null){
                    setState(() {
                      addressCustomerController.text = note;
                    });
                  }
                });
              },
              child: Stack(
                children: [
                  inputWidget(title:'Địa chỉ khách hàng',hideText: "Vui lòng nhập địa chỉ KH",controller: addressCustomerController,focusNode: addressCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
                  const Positioned(
                      top: 20,right: 10,
                      child: Icon(Icons.edit,color: Colors.grey,size: 20,))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildInfoAgent(){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(10),
              height: 40,
              width: double.infinity,
              color: Colors.amber.withOpacity(0.4),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Thông tin người đại lý/NPP',style: TextStyle(color: Colors.black,fontSize: 13),),
              ),
            ),
            const SizedBox(height: 22,),
            GestureDetector(
              onTap:(){
                PersistentNavBarNavigator.pushNewScreen(context, screen: const SearchCustomerScreen(selected: true,typeName: true,allowCustomerSearch: false, inputQuantity: false,),withNavBar: false).then((value){
                  if(value != null){
                    ManagerCustomerResponseData infoCustomer = value;
                    codeAgent = infoCustomer.customerCode.toString();
                    _bloc.add(PickInfoAgent(customerName: infoCustomer.customerName,phone: infoCustomer.phone,address: infoCustomer.address,codeCustomer: infoCustomer.customerCode));
                  }
                });
              },
              child: Stack(
                children: [
                  inputWidget(title:'Tên đại lý/NPP',hideText: "Đại lý/NPP A",controller: nameAgentController,focusNode: nameAgentFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
                  const Positioned(
                      top: 20,right: 10,
                      child: Icon(Icons.search_outlined,color: Colors.grey,size: 20,))
                ],
              ),
            ),
            inputWidget(title:"SĐT đại lý/NPP",hideText: '0963 xxx xxx ',controller: phoneAgentController,focusNode: phoneAgentFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true),
            GestureDetector(
              onTap:(){
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      // ignore: unnecessary_null_comparison
                      return InputAddressPopup(note: addressAgentController.text != null ? addressAgentController.text.toString() : "",title: 'Địa chỉ KH',desc: 'Vui lòng nhập địa chỉ KH',convertMoney: false, inputNumber: false,);
                    }).then((note){
                  if(note != null){
                    setState(() {
                      addressAgentController.text = note;
                    });
                  }
                });
              },
              child: Stack(
                children: [
                  inputWidget(title:'Địa chỉ đại lý/NPP',hideText: "Vui lòng nhập địa chỉ",controller: addressAgentController,focusNode: addressAgentFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
                  const Positioned(
                      top: 20,right: 10,
                      child: Icon(Icons.edit,color: Colors.grey,size: 20,))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionWidget() {
    return Utils.isEmpty(Const.listTransactionsSaleOut)
        ? const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        : DropdownButtonHideUnderline(
      child: DropdownButton<ListTransaction>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: Const.listTransactionsSaleOut[_bloc.transactionIndex],
          items: Const.listTransactionsSaleOut.map((value) => DropdownMenuItem<ListTransaction>(
            value: value,
            child: Text(value.tenGd.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            ListTransaction transaction = value!;
            _bloc.transactionCode = int.parse(transaction.maGd.toString());
            _bloc.add(PickTransactionName(Const.listTransactionsSaleOut.indexOf(value),transaction.tenGd.toString()));
          }),
    );
  }

  Widget inputWidget({String? title,String? hideText,IconData? iconPrefix,IconData? iconSuffix, bool? isEnable,
    TextEditingController? controller,Function? onTapSuffix, Function? onSubmitted,FocusNode? focusNode,
    TextInputAction? textInputAction,bool inputNumber = false,bool note = false,bool isPassWord = false}){
    return Padding(
      padding: const EdgeInsets.only(top: 0,left: 10,right: 10,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title??'',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,color: Colors.black),
              ),
              Visibility(
                visible: note == true,
                child: const Text(' *',style: TextStyle(color: Colors.red),),
              )
            ],
          ),
          const SizedBox(height: 5,),
          Container(
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8)
            ),
            child: TextFieldWidget2(
              controller: controller!,
              suffix: iconSuffix,
              textInputAction: textInputAction!,
              isEnable: isEnable ?? true,
              keyboardType: inputNumber == true ? TextInputType.phone : TextInputType.text,
              hintText: hideText,
              focusNode: focusNode,
              onSubmitted: (text)=> onSubmitted,
              isPassword: isPassWord,
              isNull: true,
              color: Colors.blueGrey,

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.of(context).pop(Const.currencyCode),
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
          const Expanded(
            child: Center(
              child: Text(
                'Cập nhật Sale Out',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProductScreen(
                  idCustomer: widget.codeCustomer.toString(), /// Chỉ có thêm tồn kho ở check-in mới thêm idCustomer
                  currency: Const.currencyCode,
                  viewUpdateOrder: false,
                  listIdGroupProduct: Const.listGroupProductCode,
                  itemGroupCode: '',//Const.itemGroupCode,
                  inventoryControl: false,
                  addProductFromCheckIn: false,
                  addProductFromSaleOut: true,
                  giftProductRe: false,
                  lockInputToCart: false,checkStockEmployee: false,
                  listOrder: _bloc.listProductOrderAndUpdate, backValues: false, isCheckStock: Const.isCheckStockSaleOut
                ,),withNavBar: false).then((value){
                _bloc.add(GetListProductFromDB());
              });
            },
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.search,
                size: 25,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
