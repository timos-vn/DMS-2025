// ignore_for_file: library_private_types_in_public_api

import 'package:dms/screen/sell/refund_order/refund_order_bloc.dart';
import 'package:dms/screen/sell/refund_order/refund_order_event.dart';
import 'package:dms/screen/sell/refund_order/refund_order_state.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/input_quantity_popup_refund_order.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:dms/widget/text_field_widget2.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../themes/colors.dart';
import '../../../model/database/data_local.dart';
import '../../../model/network/response/detail_customer_response.dart';
import '../../sell/component/input_address_popup.dart';


class RefundOrderScreen extends StatefulWidget {
  final DetailCustomerResponseData detailCustomer;
  final String codeTax;
  final double percentTax;
  final String tk;

  const RefundOrderScreen({Key? key,required this.detailCustomer, required this.codeTax, required this.percentTax, required this.tk}) : super(key: key);

  @override
  _RefundOrderScreenState createState() => _RefundOrderScreenState();
}

class _RefundOrderScreenState extends State<RefundOrderScreen> {

  late RefundOrderBloc _bloc;

  final nameCustomerController = TextEditingController();
  final addressCustomerController = TextEditingController();
  final phoneCustomerController = TextEditingController();
  final nameCustomerFocus = FocusNode();
  final addressCustomerFocus = FocusNode();
  final phoneCustomerFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameCustomerController.text = widget.detailCustomer.customerName.toString().trim();
    addressCustomerController.text = widget.detailCustomer.address.toString().trim();
    phoneCustomerController.text = widget.detailCustomer.phone.toString().trim();

    _bloc = RefundOrderBloc(context);
    _bloc.percentTax = widget.percentTax;
    _bloc.add(GetPrefsRefundOrderEvent(calculator: true));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RefundOrderBloc,RefundOrderState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsRefundOrderSuccess){

          }
          else if(state is AddNewRefundOrderSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Tạo phiếu thành công');
            DataLocal.listDetailOrderCompletedSave.clear();
            DataLocal.codeSellLockRefundOrder = '';
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<RefundOrderBloc,RefundOrderState>(
          bloc: _bloc,
          builder: (BuildContext context, RefundOrderState state){
            final height = MediaQuery.of(context).size.height;
            return Stack(
              children: [
                Column(
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
                    buildPayment()
                  ],
                ),
                Visibility(
                  visible: state is GetListRefundOrderEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is RefundOrderLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildBody(double height){
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        buildListCart(),
        buildLine(),
        buildMethodReceive(),
        buildLine(),
        GestureDetector(
          onTap: (){
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return InputAddressPopup(note: _bloc.noteSell != null ? _bloc.noteSell.toString() : "",title: 'Thêm ghi chú của bạn',desc: 'Vui lòng nhập ghi chú',convertMoney: false, inputNumber: false,);
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
            child: Padding(
              padding: const EdgeInsets.only(top: 5,left: 16,right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ghi chú:',style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic,decoration: TextDecoration.underline,fontSize: 12),),
                  const SizedBox(width: 12,),
                  Expanded(child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(_bloc.noteSell != null ? _bloc.noteSell.toString() : "Viết tin nhắn...",style: const TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,))),
                ],
              ),
            ),
          ),
        ),
        buildLine(),
        buildPaymentDetail(),
        buildLine(),
        // buildOtherRequest(),

      ],
    );
  }

  buildPayment(){
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
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text('${NumberFormat(Const.amountFormat).format(_bloc.totalMNProduct??0)} đ',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.normal,decoration: TextDecoration.lineThrough),),
            // const SizedBox(width: 8,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng sản phẩm',style: TextStyle(color: Colors.black,fontSize: 12),),
                Text('${_bloc.totalCount} sản phẩm',style: const TextStyle(color: subColor,fontWeight: FontWeight.bold),),
              ],
            ),
            const SizedBox(width: 18,),
            GestureDetector(
              onTap: (){
                if(DataLocal.listDetailOrderCompletedSave.isNotEmpty){
                  _bloc.add(AddNewRefundOrderEvent(
                    idCustomer: widget.detailCustomer.customerCode.toString(),
                      phoneCustomer: widget.detailCustomer.phone.toString(),
                      addressCustomer: widget.detailCustomer.address.toString(),
                      codeTax: widget.codeTax,
                      tk: widget.tk.toString(),
                  ));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Phiếu hàng của bạn có gì đâu?');
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
                  child: Text('Tạo phiếu',style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
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
            visible: DataLocal.listDetailOrderCompletedSave.isNotEmpty,
            child: SizedBox(
              height: (!_bloc.expanded || DataLocal.listDetailOrderCompletedSave.length == 1) ? 120 : 300,
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                // physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index){
                  print(Utils.formatMoneyStringToDouble(DataLocal.listDetailOrderCompletedSave[index].giaNt2));
                  print(Utils.formatMoneyStringToDouble(DataLocal.listDetailOrderCompletedSave[index].giaNt2??0));

                  return GestureDetector(
                    onTap: (){
                      setState(() {
                        if(DataLocal.listDetailOrderCompletedSave[index].isMark == false){
                          showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) {
                                return InputQuantityPopupRefundOrder(
                                  title: 'Bạn chỉ được phép trả tối đa ${DataLocal.listDetailOrderCompletedSave[index].slCl!} SP',
                                  quantity: DataLocal.listDetailOrderCompletedSave[index].slCl??0,
                                );
                              }).then((value){
                            if(double.parse(value[0].toString()) > 0){
                              DataLocal.listDetailOrderCompletedSave[index].isMark = true;
                              DataLocal.listDetailOrderCompletedSave[index].slSt = value[0];
                              _bloc.add(CalculatorEvent());
                              Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm vào phiếu trả lại thành công');
                              // setState(() {});
                            }
                          });
                        }
                        else{
                          DataLocal.listDetailOrderCompletedSave[index].isMark = false;
                          DataLocal.listDetailOrderCompletedSave[index].slSt = 0;
                          _bloc.add(CalculatorEvent());
                          Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã huỷ hàng trả lại');
                        }
                      });
                    },
                    child: Card(
                      semanticContainer: true,
                      margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8,right: 6,top: 2,bottom: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 10,width: 40,
                              child: Transform.scale(
                                scale: 1,
                                alignment: Alignment.topLeft,
                                child: Checkbox(
                                  value:  DataLocal.listDetailOrderCompletedSave[index].isMark,
                                  onChanged: (b){
                                    setState(() {
                                      if(DataLocal.listDetailOrderCompletedSave[index].isMark == false){
                                        showDialog(
                                            barrierDismissible: true,
                                            context: context,
                                            builder: (context) {
                                              return InputQuantityPopupRefundOrder(
                                                title: 'Bạn chỉ được phép trả tối đa ${DataLocal.listDetailOrderCompletedSave[index].slCl!} SP',
                                                quantity: DataLocal.listDetailOrderCompletedSave[index].slCl??0,
                                              );
                                            }).then((value){
                                          if(double.parse(value[0].toString()) > 0){
                                            DataLocal.listDetailOrderCompletedSave[index].isMark = true;
                                            DataLocal.listDetailOrderCompletedSave[index].slSt = value[0];
                                            _bloc.add(CalculatorEvent());
                                            Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm vào phiếu trả lại thành công');
                                            // setState(() {});
                                          }
                                        });
                                      }
                                      else{
                                        DataLocal.listDetailOrderCompletedSave[index].isMark = false;
                                        DataLocal.listDetailOrderCompletedSave[index].slSt = 0;
                                        _bloc.add(CalculatorEvent());
                                        Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã huỷ hàng trả lại');
                                      }
                                    });
                                  },
                                  activeColor: mainColor,
                                  hoverColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  side: WidgetStateBorderSide.resolveWith((states){
                                    if(states.contains(WidgetState.pressed)){
                                      return BorderSide(color: mainColor);
                                    }else{
                                      return BorderSide(color: mainColor);
                                    }
                                  }),
                                ),
                              ),
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mã đơn/Số lô:',
                                          style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 12),
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text("${DataLocal.listDetailOrderCompletedSave[index].sttRec.toString().trim()}/${DataLocal.listDetailOrderCompletedSave[index].maLo.toString().trim()}",
                                          style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 12),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                    // Divider(),
                                    const SizedBox(height: 5,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: '[${DataLocal.listDetailOrderCompletedSave[index].maVt.toString().trim()}] ',
                                                    style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                        0xff555a55)),
                                                  ),
                                                  TextSpan(
                                                    text: DataLocal.listDetailOrderCompletedSave[index].tenVt.toString().trim(),
                                                    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                                  ),
                                                  TextSpan(
                                                    text: DataLocal.listDetailOrderCompletedSave[index].tlCk! > 0 ? '  (-${DataLocal.listDetailOrderCompletedSave[index].tlCk!.toDouble()} %)'
                                                        :
                                                    '',
                                                    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 11, color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            )
                                        ),
                                        const SizedBox(width: 10,),
                                        (DataLocal.listDetailOrderCompletedSave[index].kmYn == 0) ?
                                        Column(
                                          children: [
                                            Text(
                                              ((DataLocal.listDetailOrderCompletedSave[index].giaNt2??0))
                                                  == 0 ? 'Giá đang cập nhật' : '${Utils.formatMoneyStringToDouble(DataLocal.listDetailOrderCompletedSave[index].giaNt2??0)} ₫'
                                              ,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color:
                                              ((DataLocal.listDetailOrderCompletedSave[index].ckNt??0)) == 0
                                                  ?
                                              Colors.grey : Colors.red, fontSize: 10,
                                                  decoration: ((DataLocal.listDetailOrderCompletedSave[index].ckNt??0)) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                            ),
                                            const SizedBox(height: 3,),
                                            Visibility(
                                              visible: DataLocal.listDetailOrderCompletedSave[index].ckNt! > 0,
                                              child: Text(
                                                '${Utils.formatMoneyStringToDouble((DataLocal.listDetailOrderCompletedSave[index].giaNt2! - (DataLocal.listDetailOrderCompletedSave[index].ckNt!/DataLocal.listDetailOrderCompletedSave[index].slSt)))} ₫',
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(color: Color(
                                                    0xff067902), fontSize: 13,fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                          ],
                                        )
                                        :
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16,right: 30),
                                          child: Icon(
                                            MdiIcons.gift,
                                            size:18,
                                            color: DataLocal.listDetailOrderCompletedSave[index].kmYn == 1 ? const Color(0xFF0EBB00) : Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Mã kho: ${(DataLocal.listDetailOrderCompletedSave[index].nameStore.toString().isNotEmpty && DataLocal.listDetailOrderCompletedSave[index].nameStore.toString() != 'null') ? DataLocal.listDetailOrderCompletedSave[index].nameStore : 'Đang cập nhật'}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color: Colors.red),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 20,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              DataLocal.listDetailOrderCompletedSave[index].kmYn == 0 ?'KH đặt:' : 'KL tặng:',
                                              style: TextStyle(color: DataLocal.listDetailOrderCompletedSave[index].kmYn == 0 ? Colors.black.withOpacity(0.7) : const Color(0xFF0EBB00), fontSize: 11),
                                              textAlign: TextAlign.left,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text("${DataLocal.listDetailOrderCompletedSave[index].soLuong??0} (${DataLocal.listDetailOrderCompletedSave[index].dvt.toString().trim()})",
                                              style: TextStyle(color:  DataLocal.listDetailOrderCompletedSave[index].kmYn == 0 ? blue : const Color(0xFF0EBB00), fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'SL sẽ trả:',
                                                style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 12),
                                                textAlign: TextAlign.left,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text("${DataLocal.listDetailOrderCompletedSave[index].slSt} (${DataLocal.listDetailOrderCompletedSave[index].dvt.toString().trim()})",
                                                style:const TextStyle(color: blue, fontSize: 12),
                                                textAlign: TextAlign.left,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20,),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'SL đã trả  :',
                                                  style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 12),
                                                  textAlign: TextAlign.left,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text("${DataLocal.listDetailOrderCompletedSave[index].slTra??0} (${DataLocal.listDetailOrderCompletedSave[index].dvt.toString().trim()})",
                                                  style:const TextStyle(color: blue, fontSize: 12),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
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
                  );
                },
                itemCount: DataLocal.listDetailOrderCompletedSave.length,
              )
            ),
          ),
          Visibility(
            visible: DataLocal.listDetailOrderCompletedSave.isNotEmpty && DataLocal.listDetailOrderCompletedSave.length > 1,
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
            visible: DataLocal.listDetailOrderCompletedSave.isEmpty,
            child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Úi, Không có gì ở đây cả.',style: TextStyle(color: Colors.black,fontSize: 11.5)),
                    const SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text('Gợi ý: Bấm nút ',style: TextStyle(color: Colors.blueGrey,fontSize: 10.5)),
                        Icon(Icons.arrow_back,color: Colors.blueGrey,size: 18,),
                        Text(' để quay trở lại và chọn đơn hàng muốn trả lại',style: TextStyle(color: Colors.blueGrey,fontSize: 10.5)),
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

  buildMethodReceive(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16,right: 8,top: 10,bottom: 6),
          child: Row(
            children: [
              Icon(MdiIcons.truckFast,color: mainColor,),
              const SizedBox(width: 10,),
              const Text('Thông tin & Ghi chú đơn hàng',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16,right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Thông tin nhận hàng:',style: TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
              buildInfoCallOtherPeople(),
            ],
          ),
        ),
      ],
    );
  }

  buildInfoCallOtherPeople(){
    return Padding(
      padding: const EdgeInsets.only(top: 10,),
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
                child: Text('Thông tin khách hàng',style: TextStyle(color: Colors.black,fontSize: 13),),
              ),
            ),
            const SizedBox(height: 22,),
            Stack(
              children: [
                inputWidget(title:'Tên khách hàng',hideText: "Nguyễn Văn A",controller: nameCustomerController,focusNode: nameCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
                const Positioned(
                    top: 20,right: 10,
                    child: Icon(Icons.search_outlined,color: Colors.transparent,size: 20,) )
              ],
            ),
            inputWidget(title:"SĐT khách hàng",hideText: 'Đang cập nhật',controller: phoneCustomerController,focusNode: phoneCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
            Stack(
              children: [
                inputWidget(title:'Địa chỉ khách hàng',hideText: "Vui lòng nhập địa chỉ KH",controller: addressCustomerController,focusNode: addressCustomerFocus,textInputAction: TextInputAction.done, onTapSuffix: (){},note: true,isEnable: false),
                const Positioned(
                    top: 20,right: 10,
                    child: Icon(Icons.edit,color: Colors.transparent,size: 20,))
              ],
            ),
          ],
        ),
      ),
    );
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

  Widget buildPaymentDetail(){
    return Padding(
      padding: const EdgeInsets.only(left: 16,right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:const EdgeInsets.only(top: 10,bottom: 6,),
            child: Row(
              children: [
                Icon(MdiIcons.idCard,color: mainColor,),
                const SizedBox(width: 10,),
                const Text('Thanh toán',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold,),maxLines: 1,overflow: TextOverflow.ellipsis,),
              ],
            ),
          ),
          customWidgetPayment('Tổng số lượng:','${_bloc.totalCount} Sản phẩm',0,''),
          customWidgetPayment('Tổng tiền hàng:','${Utils.formatMoneyStringToDouble(_bloc.totalMoney)} ₫',0,''),
          customWidgetPayment('Thuế:',' ${Utils.formatMoneyStringToDouble(_bloc.totalTax)} ₫',0,''),
          customWidgetPayment('Chiết khấu:','- ${Utils.formatMoneyStringToDouble(_bloc.totalDiscount)} ₫',0,''),
          Padding(
            padding: const EdgeInsets.only(top: 15,bottom: 6,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng Thanh toán',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold,),maxLines: 1,overflow: TextOverflow.ellipsis,),
                Text('${Utils.formatMoneyStringToDouble(_bloc.totalPayment)} ₫',style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold,),maxLines: 1,overflow: TextOverflow.ellipsis,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget customWidgetPayment(String title,String subtitle,int discount, String codeDiscount){
    return Padding(
      padding:const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,style: const TextStyle(fontSize: 12,color: Colors.blueGrey),),
              subtitle != '' ? Text(subtitle,style: const TextStyle(fontSize: 13,color: Colors.black),) :
              discount > 0 ?
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: DottedBorder(
                        dashPattern: const [5, 3],
                        color: Colors.red,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(2),
                        padding: const EdgeInsets.only(top: 2,bottom: 2,left: 10,right: 10),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Text(codeDiscount,style: const TextStyle(fontSize: 11,color: Colors.red),
                          ),
                        )
                    ),
                  )
                ],
              )
                  : Container(),
            ],
          ),
          const Divider(color: Colors.grey,)
        ],
      ),
    );
  }

  Widget inputWidget({String? title,String? hideText,IconData? iconPrefix,IconData? iconSuffix, bool? isEnable,
    TextEditingController? controller,Function? onTapSuffix, Function? onSubmitted,FocusNode? focusNode,
    TextInputAction? textInputAction,bool inputNumber = false,bool note = false,bool isPassWord = false,
  }){
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
                "Tạo phiếu trả lại",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.event,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }
}
