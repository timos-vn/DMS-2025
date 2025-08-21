import 'package:dms/screen/sell/cart/cart_bloc.dart';
import 'package:dms/screen/sell/cart/component/search_item.dart';
import 'package:dms/utils/utils.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../themes/colors.dart';

class CustomOrder extends StatefulWidget {
  const CustomOrder({Key? key, required this.bloc, required this.idCustomer}) : super(key: key);

  final CartBloc bloc;
  final String idCustomer;

  @override
  State<CustomOrder> createState() => _CustomOrderState();
}

class _CustomOrderState extends State<CustomOrder> {



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 10,),
        customSelect('Đơn vị tài chính',false,onTap: (){
          PersistentNavBarNavigator.pushNewScreen(context, screen:  const SearchItem(customerID: '',typeSearch: 1, title: 'Đơn vị tài chính',)).then((value) {
           if(value != null){
             setState(() {
               widget.bloc.idDVTC = value[0];
               widget.bloc.nameDVTC = value[1];
             });
           }
          });
        },values: widget.bloc.nameDVTC.toString(),icon: EneftyIcons.edit_outline),
        customSelect('Mã điều chuyển',false,onTap: (){
         if(widget.idCustomer.toString().replaceAll('null', '').isNotEmpty){
           PersistentNavBarNavigator.pushNewScreen(context, screen:  SearchItem(customerID: widget.idCustomer,typeSearch: 2,  title: 'Mã điều chuyển',)).then((value) {
             if(value != null){
               setState(() {
                 widget.bloc.idMDC = value[0];
                 widget.bloc.nameMDC = value[1];
               });
             }
           });
         }else{
           Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng chọn Khác hàng trước');
         }
        },values: widget.bloc.nameMDC.toString(),icon: EneftyIcons.edit_outline),
        customSelect('Người nhận',true,controller: widget.bloc.nguoiNhan,onTap: (){},icon: EneftyIcons.edit_outline),
        customSelect('Ghi chú',true,controller: widget.bloc.ghiChu,onTap: (){},icon: EneftyIcons.edit_outline),
        customSelect('Thời gian giao',true,controller: widget.bloc.thoiGianGiao,onTap: (){},icon: EneftyIcons.edit_outline),
        customSelect('Tiền',true,controller: widget.bloc.tien,onTap: (){},icon: EneftyIcons.edit_outline),
        customSelect('Báo giá',true,controller: widget.bloc.baoGia,onTap: (){},icon: EneftyIcons.edit_outline),
      ],
    );
  }

  customSelect(String? title,bool editAction,{
    TextEditingController? controller, String? hintText,VoidCallback? onTap,String? values,required IconData icon
}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 10,),
        Text(title.toString(),style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
        const SizedBox(height: 10,),
        editAction == true
            ?
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey)
            ),
            height: 45,width: double.infinity,
            child: TextField(
              autofocus: false,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: Colors.black, fontSize: 13),
              controller: controller,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: transparent,
                  hintText: hintText.toString(),
                  hintStyle: const TextStyle(color: accent),
                  suffixIcon: Icon(icon,size: 15,color: Colors.black),
                  // suffixIconConstraints: BoxConstraints(maxWidth: 20),
                  contentPadding: const EdgeInsets.only(left: 5,bottom: 10, top: 0,right: 0)
              ),
            ),
          ),
        )
            :
        InkWell(
          onTap: onTap,
          child: Container(
              height: 45,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(values.toString().replaceAll('null', ''),style: const TextStyle(fontSize: 12,color: Colors.black),maxLines: 1,)),
                  const Icon(EneftyIcons.search_normal_outline,size: 16,color: Colors.black,),
                ],
              )
          ),
        )
      ],
    );
  }
}
