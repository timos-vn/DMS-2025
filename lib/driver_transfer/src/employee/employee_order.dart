import 'package:dms/extension/extension_compare_date.dart';
import 'package:dms/screen/options_input/options_input_screen.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../api/models/order_detail_model.dart';
import '../../api/models/order_model.dart';
import '../../helper/constant.dart';
import 'order_detail.dart';

class EmployeeOrder extends StatefulWidget {
  const EmployeeOrder(
      {key,
      required this.height,
      required this.date,
      this.onClear,
      this.changePolylines,
      this.onDirection,this.onChooseDate,
      this.active = true,
      required this.listOrder,
      required this.name,
      this.confirmOrder,
      this.isReality = false});

  final DateTime date;
  final double height;
  final Function()? onClear;
  final Function()? changePolylines;
  final Function(OrderModel)? onDirection;
  final Function(ObjDateFunc)? onChooseDate;
  final bool active;
  final List<OrderModel> listOrder;
  final String name;
  final  Function(OrderDetailModel)? confirmOrder;
  final bool isReality;

  @override
  State<EmployeeOrder> createState() => _EmployeeOrderState();
}

class _EmployeeOrderState extends State<EmployeeOrder> {
  PanelController controller = PanelController();

  @override
  void initState() {
    // Const.dateFrom = DateTime.now();
    // Const.dateTo = DateTime.now();
    if (controller.isAttached) {
      controller.show();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.active,
      child: SlidingUpPanel(
        color: Colors.transparent,
        maxHeight: widget.height,
        controller: controller,
        panelBuilder: (sc) {
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)), color: white),
            child: SingleChildScrollView(
              controller: sc,
              child: Column(
                children: [
                  _info(),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 1,
                      color: const Color(0xffE8E8E8)),
                  const SizedBox(height: 20),
                  widget.listOrder.isEmpty
                      ? Column(
                          children: [
                            const SizedBox(height: 100),
                            Image(image: noResultAsset, width: 180),
                            const SizedBox(height: 20),
                            setText('Không tìm thấy đơn', 15, color: gray)
                          ],
                        )
                      : Column(
                          children:
                              List.generate(widget.listOrder.length, (index) => _item(index))),
                  if (widget.listOrder.isNotEmpty && user.dataUser!.isManager!)
                    GestureDetector(
                      onTap: widget.changePolylines,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        height: 45,
                        decoration:
                            BoxDecoration(color: orange, borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: setText(
                            widget.isReality ? 'Xem đường đi chỉ dẫn' : 'Xem đường đi thực tế', 16,
                            fontWeight: FontWeight.w600, color: white),
                      ),
                    ),
                  SizedBox(height: bottomPadding),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _info() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)), color: white),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: //Image.asset(avatarAsset,height: 50,)
                    Image(image: avatarAsset, height: 50),
                  ),
                  Positioned(
                      bottom: 0,
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                            border: Border.all(color: white, width: 2),
                            color: green,
                            shape: BoxShape.circle),
                      ))
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  setText('Tài xế', 14, color: gray),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      setText(widget.name, 16, fontWeight: FontWeight.w600, color: blue),
                      const Spacer(),
                      InkWell(
                        onTap: ()=>  showDialog(
                            context: context,
                            builder: (context) => OptionsFilterDate(
                              dateFrom: Const.dateFrom.toString().isNotEmpty ? Const.dateFrom.toString() : DateTime.now().toString(),
                              dateTo: Const.dateTo.toString().isNotEmpty ? Const.dateTo.toString() : DateTime.now().toString(),
                            )).then((value){
                          if(value != null){
                            if(value[1] != null && value[2] != null){
                              Const.dateFrom = Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT);
                              Const.dateTo = Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT);
                              setState(() {

                              });
                              ObjDateFunc dateTime = ObjDateFunc(startDate: DateFormat('yyyy-MM-dd').format(Const.dateFrom),endDate: DateFormat('yyyy-MM-dd').format(Const.dateTo));
                              widget.onChooseDate!(dateTime);
                              // _bloc.add(GetListShippingEvent(dateFrom: Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT),dateTo: Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT)));
                            }else{
                              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy chọn từ ngày đến ngày');
                            }
                          }
                        }),
                        child: setText(
                            Const.dateFrom.isSameDate(Const.dateTo) == true ? 'Hôm nay' :
                          '${DateFormat('dd/MM').format(Const.dateFrom)} - ${DateFormat('dd/MM').format(Const.dateTo)}',
                            // widget.date.isToday
                            //     ? 'Hôm nay'
                            //     : DateFormat('dd/MM/yyyy').format(widget.date),
                            14,
                            color: gray),
                      )
                    ],
                  ),
                ],
              )),
            ],
          ),
        ),
        if (widget.onClear != null)
          Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                  onTap: widget.onClear, child: Image(image: clearAsset, height: 24)))
      ],
    );
  }

  _item(int index) {
    final item = widget.listOrder[index];
    bool check = !user.dataUser!.isManager! && item.status == "0";
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showMaterialModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            builder: (context) => OrderDetail(
                height: widget.height,
                // confirmOrder: widget.confirmOrder!,
                confirmOrder: widget.confirmOrder,
                id: item.id.toString()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: item.isTarget == true
            ? const Color(0xffFFF3E5)
            : item.status == "1"
                ? green.withOpacity(0.15)
                : white,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                    width: 38,
                    alignment: Alignment.center,
                    child: setText('${item.poinNumber}', 18,
                        fontWeight: FontWeight.w700, color: blue)),
                const SizedBox(width: 10),
                Expanded(
                    child: setText(item.namePoint ?? '', 18,
                        fontWeight: FontWeight.w600, color: black)),
                if (item.status == "1")
                  setText(DateFormat('HH:mm').format(item.timeFinished!), 14,
                      fontWeight: FontWeight.w800, color: green)
              ],
            ),
            const SizedBox(height: 3),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  index == widget.listOrder.length - 1
                      ? const SizedBox(width: 38)
                      : Container(
                          margin: const EdgeInsets.symmetric(horizontal: 18),
                          width: 2,
                          color: blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        setText(item.strAddress ?? '', 12, color: gray),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            setText('SCT ${item.ctNumber}', 12, color: gray),
                            setText(item.ctDate.toString().replaceAll('null', '').isNotEmpty ? Utils.parseDateTToString(item.ctDate.toString(), Const.DATE_SV_FORMAT_2) : '', 12, color: gray),
                            setText(
                                item.status == "0" ? 'Chờ giao' : item.status == "1" ? 'Đã giao' : item.status == "3" ? "Thất bại" : "Huỷ",
                                12,
                                color: (item.status == "3" || item.status == "4") ? red : item.status == "0" ? gray : purple)
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            setText('Điểm dừng số ${item.poinNumber}', 12, color: gray),
                            item.distance == null
                                ? const SizedBox()
                                : Row(
                                    children: [
                                      Container(
                                        height: 5,
                                        width: 5,
                                        decoration: const BoxDecoration(
                                            color: gray, shape: BoxShape.circle),
                                        margin: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                      setText(item.distance?.text ?? '', 12, color: gray),
                                      Container(
                                        height: 5,
                                        width: 5,
                                        decoration: const BoxDecoration(
                                            color: gray, shape: BoxShape.circle),
                                        margin: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                      setText(item.duration?.text ?? '', 12, color: gray),
                                    ],
                                  )
                          ],
                        ),
                        if (check)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              controller.close();

                              widget.onDirection!(item);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  setText('Chỉ đường', 14, color: Colors.blue),
                                  const SizedBox(width: 10),
                                  const RotatedBox(
                                      quarterTurns: 1,
                                      child: Icon(Icons.navigation, color: Colors.blue))
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
