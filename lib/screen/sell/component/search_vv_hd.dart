// ignore_for_file: unnecessary_null_comparison, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../model/database/data_local.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../cart/cart_bloc.dart';
import '../cart/cart_event.dart';
import '../cart/cart_state.dart';


class SearchVVHDScreen extends StatefulWidget {
  final bool isVV;

  const SearchVVHDScreen({Key? key, required this.isVV}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchVVHDScreenState();
  }
}

class SearchVVHDScreenState extends State<SearchVVHDScreen> {

  final focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  late ScrollController _scrollController;


  late CartBloc _bloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = CartBloc(context);
    _bloc.add(GetPrefs());
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus( FocusNode());
        },
        child: BlocListener<CartBloc,CartState>(
            bloc: _bloc,
            listener: (context, state) {
              if(state is GetPrefsSuccess){
                 _bloc.listVv = DataLocal.listVv;
                 _bloc.listHd = DataLocal.listHd;
              }else if (state is CartFailure) {
                Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Đã có lỗi xảy ra');
              } else if (state is RequiredText) {
                Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vui lòng nhập kí tự cần tìm kiếm');
              }
              else if(state is AddCartSuccess){
                Const.listKeyGroupCheck = Const.listKeyGroup;
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm vào giỏ hàng thành công');
              }else if(state is UpdateProductCountInventorySuccess){
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Thêm vào Sổ tồn thành công');
                DataLocal.listInventoryIsChange = true;
              }else if(state is AddProductCountFromCheckInSuccess){
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Thêm vào đơn hàng thành công');
                DataLocal.listOrderProductIsChange = true;
              }
              else if(state is AddProductSaleOutSuccess){
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Thêm sản phẩm thành công');
                DataLocal.listOrderProductIsChange = true;
              }
            },
            child: BlocBuilder<CartBloc,CartState>(
                bloc: _bloc,
                builder: (BuildContext context, CartState state) {
                  return buildBody(context, state);
                })),
      ),
    );
  }


  buildBody(BuildContext context,CartState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: widget.isVV == true ? ListView.builder(
              padding: const EdgeInsets.only(top: 10,),
              itemCount: _bloc.listVv.length,
              itemBuilder: (context, index) {
                final trans = _bloc.listVv[index].tenVv.toString().trim();
                return ListTile(
                  minVerticalPadding: 1,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          trans.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          maxLines: 2,overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 9,),
                      Text(
                        _bloc.listVv[index].maVv.toString().trim().length > 10 ?
                        '${_bloc.listVv[index].maVv.toString().trim().substring(0,10)}...' : _bloc.listVv[index].maVv.toString().trim(),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  subtitle:const Divider(height: 1,),
                  onTap: () {
                    // _bloc.idVv = _bloc.listVv[index].maVv.toString().trim();
                    // _bloc.nameVv = _bloc.listVv[index].tenVv.toString().trim();
                    // _bloc.idHdForVv = _bloc.listVv[index].maDmhd.toString().trim();
                    Navigator.pop(context,['Accept',_bloc.listVv[index].maVv.toString().trim(),_bloc.listVv[index].tenVv.toString().trim(),_bloc.listVv[index].maDmhd.toString().trim()]);
                  },
                );
              },
            )
                :
            ListView.builder(
              padding: const EdgeInsets.only(top: 10,),
              itemCount: _bloc.listHd.length,
              itemBuilder: (context, index) {
                final trans = _bloc.listHd[index].tenHd.toString().trim();
                return ListTile(
                  minVerticalPadding: 1,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          trans.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          maxLines: 2,overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 9,),
                      Text(
                        _bloc.listHd[index].maHd.toString().trim().length > 10 ?
                        '${_bloc.listHd[index].maHd.toString().trim().substring(0,10)}...' : _bloc.listHd[index].maHd.toString().trim(),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  subtitle:const Divider(height: 1,),
                  onTap: () {
                    Navigator.pop(context,['Accept',_bloc.listHd[index].tenHd.toString().trim(),_bloc.listHd[index].maHd.toString().trim()]);
                  },
                );
              },
            )
            ,
          )
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
      padding: const EdgeInsets.fromLTRB(5, 35, 5,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){
              Navigator.pop(context,['Back']);
            },
            child: Container(
              width: 40,
              height: 50,
              padding: const EdgeInsets.only(bottom: 10),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextField(
                          autofocus: true,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                          focusNode: focusNode,
                          onSubmitted: (text) {
                            //_bloc.add(SearchProduct(Utils.convertKeySearch(_searchController.text),widget.idGroup!.toInt(), widget.itemGroupCode.toString(),widget.idCustomer.toString()));
                          },
                          controller: _searchController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onChanged: (text) {
                            if(widget.isVV == true){
                              _bloc.add(SearchItemVvEvent(text));
                            }else{
                              _bloc.add(SearchItemHdEvent(text));
                            }
                            _bloc.add(CheckShowCloseEvent(text));
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: transparent,
                              hintText: "Tìm kiếm ${widget.isVV == true? 'Chương trình bán hàng' :'loại hợp đồng'}",
                              hintStyle:const  TextStyle(color: Colors.white),
                              contentPadding:const EdgeInsets.only(
                                  bottom: 10, top: 16.5)
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _bloc.isShowCancelButton,
                      child: InkWell(
                          child: Padding(
                            padding: EdgeInsets.only(left: 0,top:0,right: 8,bottom: 0),
                            child: Icon(
                              MdiIcons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          onTap: () {
                            _searchController.text = "";
                            _bloc.add(CheckShowCloseEvent(""));
                          }),
                    )
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bloc.reset();
    super.dispose();
  }
}
