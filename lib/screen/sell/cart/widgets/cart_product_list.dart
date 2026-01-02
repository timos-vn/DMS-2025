import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../model/database/data_local.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/custom_question.dart';
import '../../../../widget/InputDiscountPercent.dart';
import '../cart_bloc.dart';

/// Component hiển thị danh sách sản phẩm trong giỏ hàng
class CartProductList extends StatelessWidget {
  final CartBloc bloc;
  final VoidCallback onShowDiscountFlow;
  final VoidCallback onAddAllHDVV;
  final VoidCallback onAddDiscountForAll;
  final VoidCallback onDeleteAll;
  final Function(int) onEditProduct;
  final Function(int) onDeleteProduct;
  final Function(int) onApplyVVHD;
  final Function(int, double) onApplyManualDiscount;
  final Widget Function(BuildContext, int) buildProductItem;
  final Widget Function(BuildContext, int) buildGiftItem;
  final VoidCallback? onAddGiftProduct;

  const CartProductList({
    Key? key,
    required this.bloc,
    required this.onShowDiscountFlow,
    required this.onAddAllHDVV,
    required this.onAddDiscountForAll,
    required this.onDeleteAll,
    required this.onEditProduct,
    required this.onDeleteProduct,
    required this.onApplyVVHD,
    required this.onApplyManualDiscount,
    required this.buildProductItem,
    required this.buildGiftItem,
    this.onAddGiftProduct,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              'Hãy kiểm tra lại danh sách sản phẩm trước khi lên đơn hàng nhé bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
          ),
          _buildProductListHeader(context),
          const SizedBox(height: 8),
          _buildProductListView(context),
          Utils.buildLine(),
          if (Const.discountSpecial == true) _buildGiftListHeader(context),
          if (Const.discountSpecial == true) const SizedBox(height: 8),
          if (Const.discountSpecial == true) _buildGiftListView(context),
        ],
      ),
    );
  }

  Widget _buildProductListHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 14),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Transform.scale(
                          scale: 1,
                          alignment: Alignment.topLeft,
                          child: Checkbox(
                            value: true,
                            activeColor: mainColor,
                            hoverColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: MaterialStateBorderSide.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) {
                                return BorderSide(color: mainColor);
                              } else {
                                return BorderSide(color: mainColor);
                              }
                            }),
                            onChanged: (bool? value) {},
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sản phẩm (${Utils.formatQuantity(bloc.totalProductView)})',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Discount icon
                Visibility(
                  visible: (bloc.hasCknDiscount ||
                          bloc.hasCkgDiscount ||
                          bloc.hasHHDiscount ||
                          bloc.hasCktdttDiscount ||
                          bloc.hasCktdthDiscount) &&
                      bloc.listOrder.isNotEmpty,
                  child: InkWell(
                    onTap: onShowDiscountFlow,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Icon(
                        Icons.card_giftcard_rounded,
                        size: 20,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                // VV/HD icon
                Visibility(
                  visible: Const.isVv == true && bloc.listOrder.isNotEmpty,
                  child: InkWell(
                    onTap: () => _showAddVVHDDialog(context),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(
                        Icons.description,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                // Discount icon
                Visibility(
                  visible: Const.enableAutoAddDiscount == true &&
                      bloc.listOrder.isNotEmpty,
                  child: InkWell(
                    onTap: () => _showAddDiscountDialog(context),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(
                        Icons.discount,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                // Delete all icon
                Visibility(
                  visible: bloc.listOrder.isNotEmpty,
                  child: InkWell(
                    onTap: () => _showDeleteAllDialog(context),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(
                        Icons.delete_forever,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListView(BuildContext context) {
    if (bloc.listOrder.isEmpty) {
      return const SizedBox(
        height: 100,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Úi, Không có gì ở đây cả.',
              style: TextStyle(color: Colors.black, fontSize: 11.5),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Gợi ý: Bấm nút ',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 10.5),
                ),
                Icon(
                  Icons.search_outlined,
                  color: Colors.blueGrey,
                  size: 18,
                ),
                Text(
                  ' để thêm sản phẩm của bạn',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 10.5),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: bloc.listOrder.length,
      itemBuilder: buildProductItem,
    );
  }

  Widget _buildGiftListHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0, left: 12, right: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.cubeOutline, color: mainColor),
                    const SizedBox(width: 6),
                    Text(
                      'Sản phẩm tặng (${bloc.totalProductGift})',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (onAddGiftProduct != null)
                  Visibility(
                    visible: Const.discountSpecial == true,
                    child: InkWell(
                      onTap: onAddGiftProduct,
                      child: const SizedBox(
                        height: 30,
                        width: 50,
                        child: Icon(Icons.addchart_outlined, color: Colors.black, size: 20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftListView(BuildContext context) {
    if (DataLocal.listProductGift.isEmpty) {
      return const SizedBox(
        height: 100,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Úi, Không có gì ở đây cả.',
              style: TextStyle(color: Colors.black, fontSize: 11.5),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Gợi ý: Bấm nút ',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 10.5),
                ),
                Icon(
                  Icons.addchart_outlined,
                  color: Colors.blueGrey,
                  size: 16,
                ),
                Text(
                  ' để thêm sản phẩm tặng của bạn',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 10.5),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: DataLocal.listProductGift.length,
      itemBuilder: buildGiftItem,
    );
  }

  void _showAddVVHDDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const CustomQuestionComponent(
            showTwoButton: true,
            iconData: Icons.warning_amber_outlined,
            title: 'Chương trình bán hàng',
            content: 'Thêm CTBH cho tất cả các sản phẩm được tích chọn',
          ),
        );
      },
    ).then((value) {
      if (value != null && !Utils.isEmpty(value) && value == 'Yeah') {
        onAddAllHDVV();
      }
    });
  }

  void _showAddDiscountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const CustomQuestionComponent(
            showTwoButton: true,
            iconData: Icons.warning_amber_outlined,
            title: 'Thêm chiết khấu',
            content: 'Thêm chiết khấu cho tất cả các sản phẩm được tích chọn',
          ),
        );
      },
    ).then((value) async {
      if (value != null && !Utils.isEmpty(value) && value == 'Yeah') {
        final percent = await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return const InputDiscountPercent(
              title: 'Vui lòng nhập tỉ lệ chiết khấu',
              subTitle: 'Vui lòng nhập tỉ lệ chiết khấu',
              typeValues: '%',
              percent: 0,
            );
          },
        );
        if (percent != null &&
            percent is List &&
            percent.isNotEmpty &&
            percent[0] == 'BACK') {
          final discountValue = double.tryParse(percent[1].toString()) ?? 0;
          onAddDiscountForAll();
        }
      }
    });
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const CustomQuestionComponent(
            showTwoButton: true,
            iconData: Icons.warning_amber_outlined,
            title: 'Xoá sản phẩm',
            content: 'Bạn sẽ xoá tất cả sản phẩm trong giỏ hàng',
          ),
        );
      },
    ).then((value) {
      if (value != null && !Utils.isEmpty(value) && value == 'Yeah') {
        onDeleteAll();
      }
    });
  }
}

