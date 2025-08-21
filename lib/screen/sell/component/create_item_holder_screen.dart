import 'package:dms/model/database/data_local.dart';
import 'package:dms/screen/sell/component/search_product.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/custom_confirm.dart';
import 'package:dms/widget/input_quantity_shipping_popup.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../customer/search_customer/search_customer_screen.dart';
import '../sell_bloc.dart';
import '../sell_event.dart';
import '../sell_state.dart';

class CreateItemHolderScreen extends StatefulWidget {
  const CreateItemHolderScreen({Key? key}) : super(key: key);

  @override
  State<CreateItemHolderScreen> createState() => _CreateItemHolderScreenState();
}

class _CreateItemHolderScreenState extends State<CreateItemHolderScreen> {

  late SellBloc _bloc;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SellBloc(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SellBloc,SellState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is CreateItemHolderSuccess){
            DataLocal.listItemHolderCreate.clear();
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Tạo phiếu thành công');
            Navigator.pop(context);
          }else if(state is SellFailure){
            Utils.showCustomToast(context, Icons.warning_amber, state.error.toString());
          }
        },
        child: BlocBuilder<SellBloc,SellState>(
          bloc: _bloc,
          builder: (BuildContext context, SellState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetListHistoryOrderEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is SellLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget buildBody(BuildContext context, SellState state) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: DataLocal.listItemHolderCreate.isEmpty ? Container() : ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index) {
                  return Slidable(
                    key: const ValueKey(2),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      dragDismissible: false,
                      children: [
                        SlidableAction(
                          onPressed:(_) {
                            PersistentNavBarNavigator.pushNewScreen(context, screen: SearchCustomerScreen(
                              selected: true,
                              allowCustomerSearch: true,
                              inputQuantity: true,
                              itemHolderDetail: DataLocal.listItemHolderCreate[index],
                              quantityTotalItemHolder: DataLocal.listItemHolderCreate[index].soLuong,
                              indexItemHolder: index,
                                isCreateItemHolder:true,
                            ),withNavBar: false).then((value){
                              setState(() {});
                            });
                          },
                          borderRadius:const BorderRadius.all(Radius.circular(8)),
                          padding:const EdgeInsets.all(10),
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          icon: EneftyIcons.card_edit_outline,
                          label: 'Thêm KH',
                        ),
                        SlidableAction(
                          onPressed:(_) {
                            setState(() {
                              DataLocal.listItemHolderCreate.removeAt(index);
                            });
                          },
                          borderRadius:const BorderRadius.all(Radius.circular(8)),
                          padding:const EdgeInsets.all(10),
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: EneftyIcons.trash_outline,
                          label: 'Xoá',
                        ),
                      ],
                    ),
                    child: Card(
                      semanticContainer: true,
                      margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5,right: 6,bottom: 5,left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '[${DataLocal.listItemHolderCreate[index].maVt.toString().trim()}] ${DataLocal.listItemHolderCreate?[index].tenVt.toString().toUpperCase()}',
                                    style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                    maxLines: 2,overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(EneftyIcons.card_pos_outline,size: 15,color: Colors.grey),
                                      const SizedBox(width: 7,),
                                      Expanded(
                                        child: Text(DataLocal.listItemHolderCreate[index].sttRec??'đang cập nhật',
                                          textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 0,right: 0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 35,
                                            padding: const EdgeInsets.only(left: 0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(EneftyIcons.direct_outline,size: 15,color: Colors.grey),
                                                    const SizedBox(width: 7,),
                                                    Text(
                                                      'Đơn vị: ${DataLocal.listItemHolderCreate[index].tenDVCS.toString().trim().replaceAll('null', '')}',
                                                      style:const TextStyle(color: Colors.blueGrey,fontSize: 12,),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    width: 40,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 35,
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              color: grey_100
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              InkWell(
                                                  onTap: (){
                                                    double qty = 0;
                                                    qty = DataLocal.listItemHolderCreate[index].soLuong??0;
                                                    if(qty > 1){
                                                      setState(() {
                                                        qty = qty - 1;
                                                        DataLocal.listItemHolderCreate[index].soLuong = qty;
                                                      });
                                                    }
                                                  },
                                                  child: const SizedBox(width:25,child: Icon(FluentIcons.subtract_12_filled,size: 15,))),
                                              GestureDetector(
                                                onTap: (){
                                                  showDialog(
                                                      barrierDismissible: true,
                                                      context: context,
                                                      builder: (context) {
                                                        return const InputQuantityShipping(title: 'Vui lòng nhập số lượng thay đổi',desc: 'Nếu số lượng không thay đổi thì bạn không cần sửa.',);
                                                      }).then((quantity){
                                                    if(quantity != null){
                                                      setState(() {
                                                        DataLocal.listItemHolderCreate[index].soLuong = double.parse(quantity??'0');
                                                      });
                                                    }
                                                  });
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text("${DataLocal.listItemHolderCreate[index].soLuong??0} ",
                                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              InkWell(
                                                  onTap: (){
                                                    double qty = 0;
                                                    qty = DataLocal.listItemHolderCreate[index].soLuong??0;
                                                    setState(() {
                                                      qty = qty + 1;
                                                      DataLocal.listItemHolderCreate[index].soLuong = qty;
                                                    });
                                                  },
                                                  child: const SizedBox(width:25,child: Icon(FluentIcons.add_12_filled,size: 15))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: DataLocal.listItemHolderCreate[index].listCustomer!.isNotEmpty,
                                    child: SizedBox(
                                      height: 100,
                                      width: double.infinity,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:  DataLocal.listItemHolderCreate[index].listCustomer?.length??0,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, indexItemCustomer) {
                                          return SizedBox(
                                            height: double.infinity,width: 220,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(color: grey,width: 0.5)
                                              ),
                                              margin: const EdgeInsets.all(8),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${DataLocal.listItemHolderCreate[index].listCustomer?[indexItemCustomer].tenKh.toString().toUpperCase()}',
                                                      style:const TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w600,),
                                                      maxLines: 2,overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 3,),
                                                    Row(
                                                      children: [
                                                        const Icon(EneftyIcons.card_pos_outline,size: 15,color: Colors.grey),
                                                        const SizedBox(width: 7,),
                                                        Expanded(
                                                          child: Text(
                                                            '${DataLocal.listItemHolderCreate[index].listCustomer?[indexItemCustomer].maKh.toString()}',
                                                            style:const TextStyle(color: subColor, fontSize: 10,),
                                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${DataLocal.listItemHolderCreate[index].listCustomer?[indexItemCustomer].tenDVCS.toString()}',
                                                          style:const TextStyle(color: subColor, fontSize: 10,),
                                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 3,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 6),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          const Icon(EneftyIcons.shopping_bag_outline,color: Colors.grey,size: 15,),
                                                          const SizedBox(width: 5,),
                                                          Expanded(
                                                            child: Text('Số lượng: ${DataLocal.listItemHolderCreate[index].listCustomer?[indexItemCustomer].soLuong.toString()??'0'}',
                                                              textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 5,),
                                                          InkWell(
                                                              onTap: (){
                                                                setState(() {
                                                                  DataLocal.listItemHolderCreate[index].listCustomer?.removeAt(indexItemCustomer);
                                                                  Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật thành công');
                                                                });
                                                              },
                                                              child: const Icon(EneftyIcons.trash_outline,color: Colors.grey,size: 15,)),
                                                        ],
                                                      ),
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
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Container(),
                itemCount: DataLocal.listItemHolderCreate.length),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 10),
            child: GestureDetector(
              onTap: (){
                if(DataLocal.listItemHolderCreate.isNotEmpty){
                  checkOut();
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng thêm thông tin trước bạn êi');
                }
              },
              child: Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24)
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Xác nhận'
                      ,style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void checkOut(){
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: const CustomConfirm(
              title: 'Bạn đang tạo phiếu giữ hàng?',
              content: 'Hãy chắc chắn là bạn muốn điều này!',
              type: 0,
              expireDate: true,
            ),
          );
        }).then((value) {
      if(!Utils.isEmpty(value) && value[0] == 'confirm'){
        _bloc.add(CreateItemHolderEvent(
            listItemHolderCreate:DataLocal.listItemHolderCreate,
            comment: value[2],
            expireDate: Utils.parseStringToDate(value[1], Const.DATE_FORMAT_2).toString()
        ));
      }
    });
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
          const Expanded(
            child: Center(
              child: Text(
                "Thêm mới phiếu giữ hàng",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProductScreen(
                  idCustomer: '', /// Chỉ có thêm tồn kho ở check-in mới thêm idCustomer
                  currency: Const.currencyCode ,
                  viewUpdateOrder: false,
                  listIdGroupProduct: [],
                  inventoryControl: false,
                  addProductFromCheckIn: false,
                  addProductFromSaleOut: false,
                  giftProductRe: false,
                  lockInputToCart: false,
                  isCreateItemHolder: true,
                  listOrder: [],
                  checkStockEmployee: false,
                  backValues: true, isCheckStock: false),withNavBar: false).then((value){
                    setState(() {

                    });
              });
            },
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.search,
                size: 25,
                color: Colors.white ,
              ),
            ),
          )
        ],
      ),
    );
  }
}
