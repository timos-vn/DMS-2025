import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../utils/const.dart';
import '../../../sell/contract/component/detail_contract.dart';
import '../../../sell/component/search_product.dart';
import '../cart_bloc.dart';
import '../cart_event.dart';

class CartAppBar extends StatelessWidget {
  final CartBloc bloc;
  final bool? viewUpdateOrder;
  final String? nameCustomer;
  final bool? isContractCreateOrder;
  final dynamic contractMaster;
  final bool? viewDetail;
  final bool orderFromCheckIn;
  final String? codeCustomer;
  final String? currencyCode;
  final List<String>? listIdGroupProduct;
  final String? itemGroupCode;
  final VoidCallback onBackPressed;

  const CartAppBar({
    Key? key,
    required this.bloc,
    this.viewUpdateOrder,
    this.nameCustomer,
    this.isContractCreateOrder,
    this.contractMaster,
    this.viewDetail,
    required this.orderFromCheckIn,
    this.codeCustomer,
    this.currencyCode,
    this.listIdGroupProduct,
    this.itemGroupCode,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 83,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(5, 35, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onBackPressed,
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Center(
                child: Text(
                  viewUpdateOrder == true ? nameCustomer?.toString() ?? '' : 'Giỏ hàng',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              if (isContractCreateOrder == true) {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: DetailContractScreen(
                    contractMaster: contractMaster!,
                    isSearchItem: true,
                    cartItems: bloc.listOrder,
                  ),
                  withNavBar: false,
                ).then((result) {
                  if (result == 'refresh_cart') {
                    bloc.add(GetListProductFromDB(
                      addOrderFromCheckIn: false,
                      getValuesTax: false,
                      key: '',
                    ));
                  }
                });
              } else if (viewDetail == false && orderFromCheckIn == false) {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: SearchProductScreen(
                    idCustomer: codeCustomer.toString(),
                    currency: currencyCode,
                    viewUpdateOrder: false,
                    listIdGroupProduct: listIdGroupProduct,
                    itemGroupCode: itemGroupCode,
                    inventoryControl: false,
                    addProductFromCheckIn: false,
                    addProductFromSaleOut: false,
                    giftProductRe: false,
                    lockInputToCart: false,
                    checkStockEmployee: Const.checkStockEmployee,
                    listOrder: bloc.listProductOrderAndUpdate,
                    backValues: false,
                    isCheckStock: false,
                  ),
                  withNavBar: false,
                ).then((value) {
                  bloc.listOrder.clear();
                  bloc.listItemOrder.clear();
                  bloc.listCkMatHang.clear();
                  bloc.listCkTongDon.clear();
                  bloc.listPromotion = '';
                  bloc.add(GetListProductFromDB(
                    addOrderFromCheckIn: false,
                    getValuesTax: false,
                    key: '',
                  ));
                });
              }
            },
            child: SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.search,
                size: 25,
                color: orderFromCheckIn == false ? Colors.black : Colors.transparent,
              ),
            ),
          )
        ],
      ),
    );
  }
}

