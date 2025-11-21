// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api

import 'package:dms/model/network/response/contract_reponse.dart';
import 'package:dms/screen/sell/cart/cart_screen.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../model/database/data_local.dart';
import '../../../model/network/response/manager_customer_response.dart';
import '../../../model/network/response/setting_options_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../cart/confirm_order_screen.dart';
import '../cart/cart_bloc.dart';
import '../cart/cart_event.dart';
import '../cart/cart_state.dart';

class HistoryOrderDetailScreen extends StatefulWidget {
  final String? sttRec;
  final String? currencyCode;
  final String? title;
  final String? itemGroupCode;
  final bool status;
  final bool? approveOrder;
  final String codeCustomer;
  final String nameCustomer;
  final String addressCustomer;
  final String phoneCustomer;
  final String dateOrder;
  final String dateEstDelivery;
  final bool? hideEditAndCancelButtons;
  final String? statusName;


  const HistoryOrderDetailScreen({Key? key,this.sttRec,this.currencyCode,this.title, this.itemGroupCode,required this.codeCustomer,
    required this.nameCustomer ,required this.status,required this.addressCustomer,this.approveOrder,
    required this.phoneCustomer, required this.dateOrder, required this.dateEstDelivery, this.hideEditAndCancelButtons, this.statusName}) : super(key: key);

  @override
  _HistoryOrderDetailScreenState createState() => _HistoryOrderDetailScreenState();
}

class _HistoryOrderDetailScreenState extends State<HistoryOrderDetailScreen> {

  late CartBloc _bloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = CartBloc(context);
    _bloc.add(GetPrefs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: BlocListener<CartBloc,CartState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetListItemUpdateOrderEvent(widget.sttRec.toString()));
          }
          else if(state is DeleteOrderSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Huỷ đơn thành công');
            Navigator.pop(context,Const.REFRESH);
          }
          else if(state is ApproveOrderSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Duyệt đơn thành công');
            Navigator.pop(context,Const.REFRESH);
          }
          else if(state is AddProductToCartSuccess){
            if(Const.discountSpecial == true){
              DataLocal.listProductGift.clear();
              DataLocal.listProductGift.addAll(_bloc.listProductGift);
            }
            Const.currencyCode = !Utils.isEmpty(widget.currencyCode.toString()) ? widget.currencyCode.toString() : Const.currencyList[0].currencyCode.toString();
            Const.itemGroupCode = widget.currencyCode.toString();
            DataLocal.dateEstDelivery = widget.dateEstDelivery;


            if(_bloc.masterDetailOrder.isHD == 1){
              ContractItem contractMaster = ContractItem();
              contractMaster = ContractItem(
                sttRec: _bloc.masterDetailOrder.sttRec,
                maKh: _bloc.masterDetailOrder.maKh,
                tenKh: _bloc.masterDetailOrder.tenKh,
                  soCt: _bloc.masterDetailOrder.soCt,
                dienGiai: _bloc.masterDetailOrder.description,
                maGd: _bloc.masterDetailOrder.maGD,
                ngayCt: _bloc.masterDetailOrder.ngayCt
              );
              PersistentNavBarNavigator.pushNewScreen(context, screen: CartScreen(
                viewUpdateOrder: false,
                viewDetail: false,
                listIdGroupProduct:  Const.listGroupProductCode,
                itemGroupCode:  Const.itemGroupCode,
                listOrder: _bloc.listProduct,
                orderFromCheckIn: false,
                title: 'Đặt hàng',
                currencyCode:  Const.currencyList.isNotEmpty ? Const.currencyList[0].currencyCode.toString() : '',
                nameCustomer: contractMaster.tenKh,
                idCustomer: contractMaster.maKh,
                phoneCustomer: '',
                addressCustomer: '',
                codeCustomer: contractMaster.maKh, loadDataLocal: true,
                sttRectHD: contractMaster.sttRec,
                isContractCreateOrder: _bloc.masterDetailOrder.isHD ==  1 ? true : false,
                contractMaster: contractMaster,
              ),withNavBar: false).then((value) {
                DataLocal.listProductGift.clear();
                _bloc.add(DeleteProductInCartEvent());
                Navigator.pop(context,Const.REFRESH);
              });
            }
            else{
              PersistentNavBarNavigator.pushNewScreen(context, screen: ConfirmScreen(
                viewUpdateOrder: true,
                viewDetail: false,
                dateOrder: widget.dateOrder,
                listIdGroupProduct: Const.listGroupProductCode,
                itemGroupCode: Const.itemGroupCode,
                listOrder: _bloc.listProduct,
                orderFromCheckIn: false,
                title:'Cập nhật đơn',
                currencyCode: !Utils.isEmpty(widget.currencyCode.toString()) ? widget.currencyCode.toString() : Const.currencyList[0].currencyCode.toString(),
                nameCustomer: widget.nameCustomer,
                idCustomer: widget.codeCustomer,
                phoneCustomer: widget.phoneCustomer,
                addressCustomer: widget.addressCustomer,
                codeCustomer: widget.codeCustomer,
                sttRec: widget.sttRec,
                description: _bloc.description, loadDataLocal: false,
              ),withNavBar: false).then((value) {
                DataLocal.listProductGift.clear();
                _bloc.add(DeleteProductInCartEvent());
                Navigator.pop(context,Const.REFRESH);
              });
            }
          }else if(state is DeleteProductInCartSuccess){
            DataLocal.listOrderCalculatorDiscount.clear();
            DataLocal.listProductGift.clear();
          }
        },
        child: BlocBuilder<CartBloc,CartState>(
          bloc: _bloc,
          builder: (BuildContext context, CartState state){
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is CartLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,CartState state){
    return Column(
      children: [
        buildAppBar(),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10)
                )
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Expanded(
                    child: buildListViewProduct()
                ),
                Container(
                  padding: const EdgeInsets.only(left: 16,right: 16,top: 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng tiền',style: TextStyle(color: Colors.black,fontSize: 12),),
                          Text('${Utils.formatMoneyStringToDouble(_bloc.infoPayment?.tTien??0)} ₫',style: const TextStyle(color: Colors.black,fontSize: 12),),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng thuế',style: TextStyle(color: Colors.black,fontSize: 12),),
                          Text('${Utils.formatMoneyStringToDouble(_bloc.infoPayment?.tThueNt??0)} ₫',style: const TextStyle(color: Colors.black,fontSize: 12),),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Chiết khấu',style: TextStyle(color: Colors.black,fontSize: 12),),
                          Text('- ${Utils.formatMoneyStringToDouble(_bloc.infoPayment?.tCkTtNt??0)} ₫',style: const TextStyle(color: Colors.black,fontSize: 12),),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng thanh toán',style: TextStyle(color: Colors.black,fontSize: 12),),
                          Text('${Utils.formatMoneyStringToDouble(_bloc.infoPayment?.tTtNt??0)} ₫',style: const TextStyle(color: Colors.black,fontSize: 12),),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Visibility(
                        visible: _canEditOrCancel() && widget.hideEditAndCancelButtons != true,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10,right: 10),
                                child: InkWell(
                                  onTap: widget.approveOrder != true ? (){
                                    final status = _bloc.masterDetailOrder.status;
                                    final canEditByCode = status == 0 || status == 1;
                                    final canEditByName = _isPendingApprovalStatusName(widget.statusName);

                                    if(!(canEditByCode || canEditByName)){
                                      return;
                                    }

                                    DataLocal.listObjectDiscount.clear();
                                    DataLocal.listOrderDiscount.clear();
                                    DataLocal.infoCustomer = ManagerCustomerResponseData();
                                    DataLocal.transactionCode = "";
                                    DataLocal.transaction = ListTransaction();
                                    DataLocal.indexValuesTax = -1;
                                    DataLocal.taxPercent = 0;
                                    DataLocal.taxCode = '';
                                    DataLocal.valuesTypePayment = '';
                                    DataLocal.datePayment = '';
                                    _bloc.add(AddProductToCartEvent());
                                  } : (){},
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
                                    height: 45,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: subColor
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Sửa đơn',style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),),
                                        Icon( MdiIcons.bookEdit,color: Colors.white,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10,left: 10),
                                child: InkWell(
                                  onTap: (){
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return WillPopScope(
                                            onWillPop: () async => false,
                                            child: const CustomQuestionComponent(
                                              showTwoButton: true,
                                              iconData: Icons.warning_amber_outlined,
                                              title: 'Đơn này sẽ bị huỷ',
                                              content: 'Hãy chắc chắn ngay cả khi bạn lỡ tay',
                                            ),
                                          );
                                        }).then((value)async{
                                      if(value != null){
                                        if(!Utils.isEmpty(value) && value == 'Yeah'){
                                          _bloc.add(DeleteEvent(sttRec: widget.sttRec.toString()));
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
                                    height: 45,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.red
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Huỷ đơn',style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),),
                                        Icon( MdiIcons.deleteEmptyOutline,color: Colors.white,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: widget.approveOrder == true,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return WillPopScope(
                                      onWillPop: () async => false,
                                      child: const CustomQuestionComponent(
                                        showTwoButton: true,
                                        iconData: Icons.warning_amber_outlined,
                                        title: 'Duyệt đơn',
                                        content: 'Hãy chắc chắn ngay cả khi bạn lỡ tay',
                                      ),
                                    );
                                  }).then((value)async{
                                if(value != null){
                                  if(!Utils.isEmpty(value) && value == 'Yeah'){
                                    _bloc.add(ApproveOrderEvent(sttRec: widget.sttRec.toString()));
                                  }
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
                              height: 45,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: mainColor
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Duyệt đơn',style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),),
                                  Icon( MdiIcons.deleteEmptyOutline,color: Colors.white,)
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 15,)
      ],
    );
  }

  buildListViewProduct(){
    return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _bloc.lineItem.length,
        itemBuilder: (context,index){
          bool exits = Const.kColorForAlphaB.any((element) => element.keyText == _bloc.lineItem[index].tenVt.toString().substring(0,1).toUpperCase());
          if(exits == true){
            var itemCheck = Const.kColorForAlphaB.firstWhere((item) => item.keyText == _bloc.lineItem[index].tenVt.toString().substring(0,1).toUpperCase());
            if(itemCheck != null){
              _bloc.lineItem[index].kColorFormatAlphaB = itemCheck.color;
            }
          }
          return Card(
            semanticContainer: true,
            margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
            child: Padding(
              padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Stack(
                    clipBehavior: Clip.none, children: [
                    _bloc.lineItem[index].kmYn == 1?
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
                        child: const Icon(Icons.card_giftcard_rounded ,size: 16,color: Colors.white,))
                        :
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color:_bloc.lineItem[index].kColorFormatAlphaB == null ? Colors.blueGrey : Color(_bloc.lineItem[index].kColorFormatAlphaB!.value),
                          borderRadius: const BorderRadius.all(Radius.circular(6),)
                      ),
                      child:
                      Center(child: Text('${_bloc.lineItem[index].tenVt?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
                    ),
                    Visibility(
                      visible: _bloc.lineItem[index].ckNt! > 0,
                      child: Positioned(
                        top: -6,left: -6,
                        child: Container(
                          height: 20,width: 20,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              color: Colors.red
                          ),
                          child: const Center(child: Text('S',style: TextStyle(color: Colors.white,fontSize: 10),)),
                        ),
                      ),
                    ),
                  ],
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
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: _bloc.lineItem[index].tenVt.toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                        ),
                                        TextSpan(
                                          text: _bloc.lineItem[index].tlCk! >0 ? '  (-${_bloc.lineItem[index].tlCk} %)'
                                              : '',
                                          style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 11, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  )
                              ),
                              const SizedBox(width: 10,),
                              Column(
                                children: [
                                  (_bloc.lineItem[index].price! > 0 && _bloc.lineItem[index].price == _bloc.lineItem[index].priceAfter ) ?
                                  Container()
                                      :
                                  Text(
                                    ((widget.currencyCode == "VND"
                                        ?
                                    _bloc.lineItem[index].price
                                        :
                                    _bloc.lineItem[index].price))
                                        == 0 ? 'Giá đang cập nhật' : '${widget.currencyCode == "VND"
                                        ?
                                    Utils.formatMoneyStringToDouble(_bloc.lineItem[index].price??0)
                                        :
                                    Utils.formatMoneyStringToDouble(_bloc.lineItem[index].price??0)} ₫'
                                    ,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color:
                                    ((widget.currencyCode == "VND"
                                        ?
                                    _bloc.lineItem[index].price
                                        :
                                    _bloc.lineItem[index].price)) == 0
                                        ?
                                    Colors.grey : Colors.red, fontSize: 10, decoration: ((widget.currencyCode == "VND"
                                        ?
                                    _bloc.lineItem[index].price
                                        :
                                    _bloc.lineItem[index].price)) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                  ),
                                  const SizedBox(height: 3,),
                                  Visibility(
                                    visible: _bloc.lineItem[index].priceAfter! > 0,
                                    child: Text(
                                      '${Utils.formatMoneyStringToDouble(_bloc.lineItem[index].priceAfter??0)} ₫',
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
                                '${_bloc.lineItem[index].maVt}',
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
                                    _bloc.lineItem[index].kmYn == 1 ? 'KL Tặng' :
                                    'KH đặt:',
                                    style: TextStyle(color: _bloc.lineItem[index].kmYn == 1 ? Colors.red : Colors.black.withOpacity(0.7), fontSize: 11),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text("${_bloc.lineItem[index].soLuong?.toDouble()??0} (${_bloc.lineItem[index].dvt.toString().trim()})",
                                    style: TextStyle(color: _bloc.lineItem[index].kmYn == 1 ? Colors.red : blue, fontSize: 12),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${_bloc.lineItem[index].nameStore}",
                                style: const TextStyle(color: blue, fontSize: 12),
                                textAlign: TextAlign.left,
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
          );
        }
    );
  }

  bool _canEditOrCancel() {
    return _isDraftStatusName(widget.statusName) ||
        _isPendingApprovalStatusName(widget.statusName);
  }

  bool _isDraftStatusName(String? statusName) {
    if (statusName == null || statusName.trim().isEmpty) {
      return false;
    }
    final statusNameLower = statusName.toLowerCase().trim();
    return statusNameLower == 'lập ctừ' ||
        statusNameLower == 'lập chứng từ' ||
        statusNameLower.contains('lập ctừ') ||
        statusNameLower.contains('lập chứng từ');
  }

  bool _isPendingApprovalStatusName(String? statusName) {
    if (statusName == null || statusName.trim().isEmpty) {
      return false;
    }
    final normalized = statusName.toLowerCase().trim();
    return normalized == 'chờ duyệt' || normalized.contains('chờ duyệt');
  }

  buildAppBar(){
    print("adv");
    print(Const.downFileFromDetailOrder);
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
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor,Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.of(context).pop(widget.currencyCode),
            child:const SizedBox(
              width: 40,
              height: 50,
              child:  Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(widget.title?.toString()??'',
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              print(_bloc.masterDetailOrder.sttRec);
              if(Const.downFileFromDetailOrder == true){
                if( _bloc.masterDetailOrder.sttRec.toString().replaceAll('null', '').isNotEmpty /*&& (_bloc.masterDetailOrder.maGD.toString().replaceAll('null', '') == "5" || _bloc.masterDetailOrder.maGD.toString().replaceAll('null', '') == '6')*/){
                  _bloc.add(DownloadFileEvent(sttRec: _bloc.masterDetailOrder.sttRec.toString()));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber, 'Úi, Không lấy được mã phiếu.');
                }
              }
            },
            child: SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.file_download_outlined,
                size: 25,
                color: Const.downFileFromDetailOrder == true ? Colors.white :
                (/*_bloc.masterDetailOrder.status != 1 && _bloc.masterDetailOrder.status != 0 ||*/ widget.approveOrder == true) ? Colors.transparent : Colors.white
              ),
            ),
          )
        ],
      ),
    );
  }
}



