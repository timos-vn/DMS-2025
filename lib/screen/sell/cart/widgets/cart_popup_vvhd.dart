import 'package:dms/screen/sell/component/search_vv_hd.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../model/database/data_local.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../widget/custom_dropdown.dart';
import '../cart_bloc.dart';

class CartPopupVvHd extends StatelessWidget {
  final CartBloc bloc;
  final Function(String, String, String, String, String) onApply;

  const CartPopupVvHd({
    Key? key,
    required this.bloc,
    required this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25)
          )
      ),
      margin: MediaQuery.of(context).viewInsets,
      child: FractionallySizedBox(
        heightFactor: 0.65,
        child: StatefulBuilder(
          builder: (BuildContext context,StateSetter myState){
            return Padding(
              padding: const EdgeInsets.only(top: 10,bottom: 0),
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        topLeft: Radius.circular(25)
                    )
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0,left: 16,right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.check,color: Colors.white,),
                          const Text('Tuỳ chọn',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),),
                          InkWell(
                              onTap: ()=> Navigator.pop(context),
                              child: const Icon(Icons.close,color: Colors.black,)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5,),
                    const Divider(color: Colors.blueGrey,),
                    const SizedBox(height: 5,),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(left: 8,right: 0,bottom: 0),
                        children: [
                          Visibility(
                            visible: Const.isVv == true || Const.isVvHd == true,
                            child: SizedBox(
                              height:35,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      bloc.idVv = '';
                                      bloc.nameVv = 'Chọn Chương trình bán hàng';
                                      bloc.idHdForVv = '';
                                      myState(() {});
                                    },
                                    child: SizedBox(
                                      height: 35,width: 30,
                                      child: Center(child: Icon(MdiIcons.deleteSweepOutline,size: 20,color: Colors.black,)),
                                    ),
                                  ),
                                  const SizedBox(width: 3,),
                                  const Text('Chương trình bán hàng',style: TextStyle(color: Colors.black,fontSize: 13),),
                                  const SizedBox(width: 10,),
                                  DataLocal.listVv.isEmpty
                                      ? const Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12))
                                      :
                                  Expanded(
                                    child: PopupMenuButton(
                                      shape: const TooltipShape(),
                                      padding: EdgeInsets.zero,
                                      offset: const Offset(0, 40),
                                      itemBuilder: (BuildContext context) {
                                        return <PopupMenuEntry<Widget>>[
                                          PopupMenuItem<Widget>(
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10))),
                                              height: 250,
                                              width: 320,
                                              child: Scrollbar(
                                                child: ListView.builder(
                                                  padding: const EdgeInsets.only(top: 10,),
                                                  itemCount: DataLocal.listVv.length,
                                                  itemBuilder: (context, index) {
                                                    final trans = DataLocal.listVv[index].tenVv.toString().trim();
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
                                                              maxLines: 1,overflow: TextOverflow.fade,
                                                            ),
                                                          ),
                                                          Text(
                                                            DataLocal.listVv[index].maVv.toString().trim().length > 10 ?
                                                            '${DataLocal.listVv[index].maVv.toString().trim().substring(0,10)}...' : DataLocal.listVv[index].maVv.toString().trim(),
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle:const Divider(height: 1,),
                                                      onTap: () {
                                                        bloc.idVv = DataLocal.listVv[index].maVv.toString().trim();
                                                        bloc.nameVv = DataLocal.listVv[index].tenVv.toString().trim();
                                                        bloc.idHdForVv = DataLocal.listVv[index].maDmhd.toString().trim();
                                                        myState(() {});
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ];
                                      },
                                      child: SizedBox(
                                        height: 35,width: double.infinity,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(bloc.nameVv.toString() == '' ? 'Chọn Chương trình bán hàng' : bloc.nameVv.toString(),style: const TextStyle(color: subColor,fontSize: 12.5)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      PersistentNavBarNavigator.pushNewScreen(context, screen: const SearchVVHDScreen(isVV: true),withNavBar: false).then((value){
                                        if(value != '' && value[0] == 'Accept'){
                                          bloc.idVv = value[1];
                                          bloc.nameVv = value[2];
                                          bloc.idHdForVv = value[3];
                                          myState(() {});
                                        }
                                      });
                                    },
                                    child: const SizedBox(
                                      height: 35,width: 45,
                                      child: Center(child: Icon(Icons.search,size: 20,color: Colors.black,)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 8,bottom: 12),
                            child: Divider(),
                          ),
                          Visibility(
                            visible: Const.isHd == true || Const.isVvHd == true,
                            child: SizedBox(
                              height: 35,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      bloc.idHd = '';
                                      bloc.nameHd = 'Chọn loại Hợp đồng';
                                      myState(() {});
                                    },
                                    child: SizedBox(
                                      height: 35,width: 30,
                                      child: Center(child: Icon(MdiIcons.deleteSweepOutline,size: 20,color: Colors.black,)),
                                    ),
                                  ),
                                  const SizedBox(width: 3,),
                                  const Text('Loại hợp đồng',style: TextStyle(color: Colors.black,fontSize: 13),),
                                  const SizedBox(width: 10,),
                                  DataLocal.listHd.isEmpty
                                      ? const Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12))
                                      :
                                  Expanded(
                                    child: PopupMenuButton(
                                      shape: const TooltipShape(),
                                      padding: EdgeInsets.zero,
                                      offset: const Offset(0, 40),
                                      itemBuilder: (BuildContext context) {
                                        return <PopupMenuEntry<Widget>>[
                                          PopupMenuItem<Widget>(
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10))),
                                              height: 250,
                                              width: 320,
                                              child: Scrollbar(
                                                child: ListView.builder(
                                                  padding: const EdgeInsets.only(top: 10,),
                                                  itemCount: DataLocal.listHd.length,
                                                  itemBuilder: (context, index) {
                                                    final trans = DataLocal.listHd[index].tenHd.toString().trim();
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
                                                              maxLines: 1,overflow: TextOverflow.fade,
                                                            ),
                                                          ),
                                                          Text(
                                                            DataLocal.listHd[index].maHd.toString().trim().length > 10 ?
                                                            '${DataLocal.listHd[index].maHd.toString().trim().substring(0,10)}...' : DataLocal.listHd[index].maHd.toString().trim(),
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle:const Divider(height: 1,),
                                                      onTap: () {
                                                        bloc.nameHd = DataLocal.listHd[index].tenHd.toString().trim();
                                                        bloc.idHd = DataLocal.listHd[index].maHd.toString().trim();
                                                        Navigator.pop(context);
                                                        myState(() {});
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ];
                                      },
                                      child: SizedBox(
                                          height: 35,width: double.infinity,
                                          child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(bloc.nameHd.toString() == '' ? 'Chọn loại Hợp đồng' : bloc.nameHd.toString(),style: const TextStyle(color: subColor,fontSize: 12.5)))),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      PersistentNavBarNavigator.pushNewScreen(context, screen: const SearchVVHDScreen(isVV: false),withNavBar: false).then((value){
                                        if(value != '' && value[0] == 'Accept'){
                                          bloc.nameHd = value[1];
                                          bloc.idHd = value[2];
                                          myState(() {});
                                        }
                                      });
                                    },
                                    child: const SizedBox(
                                      height: 35,width: 45,
                                      child: Center(child: Icon(Icons.search,size: 20,color: Colors.black,)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16,bottom: 12),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pop(context,['ReLoad',bloc.idVv,bloc.nameVv,bloc.idHd,bloc.nameHd,bloc.idHdForVv]);
                        },
                        child: Container(
                          height: 45, width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: subColor
                          ),
                          child: const Center(
                            child: Text('Áp dụng', style: TextStyle(color: Colors.white,fontSize: 12.5),),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

