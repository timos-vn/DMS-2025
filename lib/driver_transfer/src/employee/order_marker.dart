import 'package:flutter/material.dart';

import '../../api/models/order_model.dart';
import '../../helper/constant.dart';

class OrderMarker extends StatelessWidget {
  const OrderMarker({key, required this.listKey, required this.listOrder});

  final List<GlobalKey> listKey;
  final List<OrderModel> listOrder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: List.generate(listKey.length, (index) {
        return RepaintBoundary(
          key: listKey[index],
          child: Stack(
            children: [
              Image(image: pinAsset, width: 26, color: //listOrder[index].isTarget == true ?
            //  Colors.orange :
              listOrder[index].status.toString() == '1' ? Colors.blue : Colors.red ),
              Positioned(
                  top: 4.88,
                  left: 4.88,
                  right: 4.88,
                  child: Container(
                      height: 16,
                      width: 16,
                      decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: setText('${listOrder[index].poinNumber}', 13,
                          fontWeight: FontWeight.w600, height: 1, color: (
                            //  listOrder[index].isTarget == true ?
                                //  Colors.orange :
                              listOrder[index].status.toString() == '1' ? Colors.blue : Colors.red ))))
            ],
          ),
        );
      }),
    ));
  }

  Color color(OrderModel item) {
    print('xxx: ${item.status} -- ${item.customerName}');
    print(item.status.toString().trim() == "0");
    if (item.isTarget!) {
      return orange;
    }
    else if (item.status.toString().trim() == "0") {
      return red;
    }
    else if (item.status.toString().trim() == "1") {
      return Colors.pink;
    }else{
      return Colors.black;
    }
  }

  String get curOrder {
    if (listOrder.every((element) => element.status == "1")) {
      return '';
    }
    return listOrder.firstWhere((element) => element.status == "0").id.toString();
  }
}
