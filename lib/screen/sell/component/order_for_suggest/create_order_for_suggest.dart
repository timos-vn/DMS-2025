import 'dart:async';

import 'package:dms/widget/pending_action.dart';
import 'package:dms/widget/text_field_widget2.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../model/database/data_local.dart';
import '../../../../model/network/request/create_order_suggest_request.dart';
import '../../../../model/network/response/data_default_response.dart';
import '../../../../model/network/response/detail_order_suggest_response.dart';
import '../../../../model/network/response/list_item_suggest_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../customer/search_customer/search_customer_screen.dart';
import '../../sell_bloc.dart';
import '../../sell_state.dart';
import '../../sell_event.dart';
import '../input_address_popup.dart';
import 'list_item_suggest.dart';


class CreateOrderForSuggestScreen extends StatefulWidget {
  final bool isEdit ;
  final ListTableOne? master ;
  final List<ListTableTwo>? listDetail ;
  const CreateOrderForSuggestScreen({Key? key, required this.isEdit, this.master, this.listDetail}) : super(key: key);

  @override
  State<CreateOrderForSuggestScreen> createState() => _CreateOrderForSuggestScreenState();
}

class _CreateOrderForSuggestScreenState extends State<CreateOrderForSuggestScreen> with TickerProviderStateMixin{
  late SellBloc _bloc;
  late TabController tabController;
  List<IconData> listIcons = [EneftyIcons.receipt_edit_outline,EneftyIcons.personalcard_outline];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SellBloc(context);

    if(widget.isEdit == true){
      if(Const.stockList.isNotEmpty){
        for(int i = 0; i< Const.stockList.length;i++){
          if(Const.stockList[i].stockCode.toString().trim() == widget.master?.maKho.toString().trim()){
            _bloc.storeIndexOutPut = i;
            _bloc.storeCodeOutPut = Const.stockList[i].stockCode.toString().trim();
            print(_bloc.storeCodeOutPut);
          }
          if(Const.stockList[i].stockCode.toString().trim() == widget.master?.maKhon.toString().trim()){
            _bloc.storeIndexInPut = i;
            _bloc.storeCodeInPut = Const.stockList[i].stockCode.toString().trim();

          }
        }
      }
      DataLocal.noteSell = widget.master?.dienGiai != null ?  widget.master!.dienGiai.toString().trim() : '';
    }else {
      if(Const.stockList.isNotEmpty){
        _bloc.storeCodeInPut = Const.stockList[0].stockCode.toString().trim();
        _bloc.storeCodeOutPut = Const.stockList[0].stockCode.toString().trim();
        print(_bloc.storeCodeInPut);
        print(_bloc.storeCodeOutPut);
      }
    }

    tabController = TabController(vsync: this, length: listIcons.length);
    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellBloc,SellState>(
      listener: (context,state){
        if(state is SellFailure){
          Utils.showCustomToast(context, Icons.check_circle_outline, state.error.toString());
        }else if(state is CreateOrderSuggestSuccess){
          if(widget.isEdit == true){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật đơn hàng thành công');
          }else{
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Tạo đơn hàng thành công');
          }
          Navigator.pop(context,['isReLoad']);
        }
      },
      bloc: _bloc,
      child: BlocBuilder<SellBloc,SellState>(
        bloc: _bloc,
        builder: (BuildContext context,SellState state){
          return Stack(
            children: [
              buildScreen(context, state),
              Visibility(
                visible: state is SellLoading,
                child: const PendingAction(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildScreen(BuildContext context,SellState state){
    return Scaffold(
      backgroundColor: grey_100,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildAppBar(),
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
                        tabs: List<Widget>.generate(listIcons.length, (int index) {
                          return Tab(
                            icon: Icon( listIcons[index]),
                          );
                        }),
                        onTap: (index){
                          // setState(() {
                          //   tabIndex = index;
                          // });
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
                              children: List<Widget>.generate(listIcons.length, (int index) {
                                for (int i = 0; i <= listIcons.length;) {
                                  if(index == 0){
                                    return buildListProduction();
                                  }else {
                                    return buildInfo();
                                  }
                                }
                                return const Text('');
                              })),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 70,width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                    decoration: const BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(16),topLeft: Radius.circular(16))
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total production',style: TextStyle(color: grey,fontSize: 12.5),),
                            const SizedBox(height: 4,),
                            Text(DataLocal.listSuggestSave.length.toString(),style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
                          ],
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                            child: GestureDetector(
                                onTap: (){
                                  if(tabController.index == 0 ){
                                    Future.delayed(const Duration(milliseconds: 200)).then((value)=>tabController.animateTo((tabController.index + 1) % 10));
                                    tabIndex = tabController.index + 1;
                                  }else{
                                    List<CreateOrderSuggestRequestDetail> _list = [];
                                    for (var element in DataLocal.listSuggestSave) {
                                      CreateOrderSuggestRequestDetail item = CreateOrderSuggestRequestDetail(
                                        sttRec: widget.isEdit == true ? element.sttRec.toString() : '',
                                        maVt: element.maVt,
                                        dvt: element.dvt,
                                        soLuong: element.qty
                                      );
                                      _list.add(item);
                                    }
                                    CreateOrderSuggestRequest request = CreateOrderSuggestRequest(
                                      data: CreateOrderSuggestRequestData(
                                        type: widget.isEdit == true ? '1' : '0',
                                        sttRec: widget.isEdit == true ? widget.master?.sttRec.toString() : '',
                                        ngayCt: Utils.parseDateToString(DateTime.now(), Const.DATE_FORMAT_2),
                                        maKho: _bloc.storeCodeOutPut.toString(),
                                        maKhoNhap: _bloc.storeCodeInPut.toString(),
                                        dienGiai: _bloc.noteSell.toString(),
                                        detail: _list
                                      )
                                    );
                                    _bloc.add(CreateOrderSuggestEvent(request: request));
                                  }
                                },
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(24)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text((tabIndex != 1) ? 'Tiếp tục' : widget.isEdit == true ? 'Cập nhật' :'Đặt hàng',style: const TextStyle(color: Colors.white),),
                                      const SizedBox(width: 8,),
                                      Icon((tabIndex != 1) ? Icons.arrow_right_alt_outlined : FluentIcons.cart_16_filled,color: Colors.white,)
                                    ],
                                  ),
                                )
                            )
                        )
                      ],
                    ),
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }

  int tabIndex = 0;

  buildListProduction(){
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
            child: Text('Hãy kiểm tra lại danh sách sản phẩm trước khi lên đơn hàng nhé bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5,color: Colors.grey),),
          ),
          buildListCart(),
        ],
      ),
    );
  }

  buildListCart(){
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10,left: 10,right: 14),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        //color: Colors.blue,
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
                                borderRadius: BorderRadius.circular(4)
                            ),
                            side: MaterialStateBorderSide.resolveWith((states){
                              if(states.contains(MaterialState.pressed)){
                                return BorderSide(color: mainColor);
                              }else{
                                return BorderSide(color: mainColor);
                              }
                            }), onChanged: (bool? value) {  },
                          ),
                        ),
                      ),
                      const SizedBox(width: 6,),
                      Text('Sản phẩm (${DataLocal.listSuggestSave.length})',style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                const SizedBox(width: 20,),
                Visibility(
                  visible: true,//_bloc.listOrder.isNotEmpty,
                  child: InkWell(
                      onTap: (){
                        PersistentNavBarNavigator.pushNewScreen(context, screen:  const SearchProductSuggestScreen(isSuggest: true,)).then((value){
                          setState(() {

                          });
                        });
                      },
                      child:const Row(
                        children: [
                          Text('Sản phẩm gợi ý',style: TextStyle(fontSize: 13),),
                          SizedBox(width: 10,),
                          Icon(Icons.list, size: 20),
                        ],
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8,),
          Visibility(
            visible: DataLocal.listSuggestSave.isEmpty,
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
                        Icon(Icons.search_outlined,color: Colors.blueGrey,size: 18,),
                        Text(' để thêm sản phẩm của bạn',style: TextStyle(color: Colors.blueGrey,fontSize: 10.5)),
                      ],
                    ),
                  ],
                )
            ),
          ),
          Visibility(
            visible: DataLocal.listSuggestSave.isNotEmpty,
            child: buildListViewProduct(),
          )
        ],
      ),
    );
  }

  buildListViewProduct(){
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: DataLocal.listSuggestSave.length,
        itemBuilder: (context,index){
          return Slidable(
              key: const ValueKey(1),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                dragDismissible: false,
                children: [
                  SlidableAction(
                    onPressed:(_) {
                      setState(() {
                        DataLocal.listSuggestSave.removeAt(index);
                      });
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 70,
                          decoration: const BoxDecoration(
                              borderRadius:BorderRadius.all( Radius.circular(6),)
                          ),
                          child: const Icon(EneftyIcons.image_outline,size: 50,weight: 0.6,),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5,right: 6,bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '[${DataLocal.listSuggestSave[index].maVt.toString().trim()}] ${DataLocal.listSuggestSave[index].tenVt.toString().toUpperCase()}',
                                  style:const TextStyle(color: subColor, fontSize: 14, fontWeight: FontWeight.w600,),
                                  maxLines: 2,overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: SizedBox(
                                        height: 13,
                                        child:(Text(
                                          'Số lượng: ${(DataLocal.listSuggestSave[index].qty.toString().isNotEmpty && DataLocal.listSuggestSave[index].qty.toString() != 'null') ? DataLocal.listSuggestSave[index].qty : '0'}',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(color: Colors.blueGrey,fontSize: 12
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ))
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
          );
        }
    );
  }

  buildInfo(){
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
            child: Text('Hãy kiểm tra thông tin khách hàng, ghi chú của đơn hàng trước khi lên đơn hàng nhé bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5,color: Colors.grey),),
          ),
          buildMethodReceive(),
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
              const Text('Thông tin & Phương thức nhận hàng',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16,right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Ghi chú cho đơn hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
              InkWell(
                onTap: (){
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return InputAddressPopup(note: (DataLocal.noteSell != '' && DataLocal.noteSell != "null") ? DataLocal.noteSell.toString() : "",
                          title: 'Thêm ghi chú cho đơn hàng',desc: 'Vui lòng nhập ghi chú',convertMoney: false, inputNumber: false,);
                      }).then((note){
                    if(note != null){
                      _bloc.add(AddNote(
                        note: note,
                      ));
                    }
                  });
                },
                child: SizedBox(
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5,left: 16,right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ghi chú:',style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic,decoration: TextDecoration.underline,fontSize: 12),),
                        const SizedBox(width: 12,),
                        Expanded(child: Align(
                            alignment: Alignment.centerRight,
                            child: Text((_bloc.noteSell.toString().replaceAll('null', '').isNotEmpty) ? _bloc.noteSell.toString() : "Viết tin nhắn...",style: const TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,))),
                      ],
                    ),
                  ),
                ),
              ),
              Utils.buildLine(),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text('Kho nhập hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
              ),
              const SizedBox(height: 10,),
              Container(
                  height: 45,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey)
                  ),
                 child: genderWidgetInput()
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text('Kho xuất hàng:',style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
              ),
              const SizedBox(height: 10,),
              Container(
                  height: 45,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey)
                  ),
                 child: genderWidgetOutPut()
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget genderWidgetInput() {
    return Utils.isEmpty(Const.stockList)
        ? const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        : DropdownButtonHideUnderline(
      child: DropdownButton<StockList>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: Const.stockList[_bloc.storeIndexInPut],
          items: Const.stockList.map((value) => DropdownMenuItem<StockList>(
            value: value,
            child: Text(value.stockName.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            StockList stocks = value!;
            _bloc.storeCodeInPut = stocks.stockCode;
            _bloc.add(PickStoreName(Const.stockList.indexOf(value),input: true));
          }),
    );
  }
  Widget genderWidgetOutPut() {
    return Utils.isEmpty(Const.stockList)
        ? const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        : DropdownButtonHideUnderline(
      child: DropdownButton<StockList>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: Const.stockList[_bloc.storeIndexOutPut],
          items: Const.stockList.map((value) => DropdownMenuItem<StockList>(
            value: value,
            child: Text(value.stockName.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            StockList stocks = value!;
            _bloc.storeCodeOutPut = stocks.stockCode;
            _bloc.add(PickStoreName(Const.stockList.indexOf(value),input: false));
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

  buildAppBar(){
    return Container(
      height: 83,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.pop(context),
            child: SizedBox(
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
              onTap: (){
              },
              child: const Center(
                child: Text(
                  'Giỏ hàng',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.black,),
                  maxLines: 1,overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              PersistentNavBarNavigator.pushNewScreen(context, screen:  const SearchProductSuggestScreen(isSuggest: false,)).then((value){
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
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}