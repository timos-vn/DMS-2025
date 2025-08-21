import 'package:carousel_slider/carousel_slider.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/custom_dropdown.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../model/network/response/info_store_response.dart';
import '../home_bloc.dart';
import '../home_event.dart';
import '../home_state.dart';
import 'circle _chart.dart';

class HomeKPIScreen extends StatefulWidget {

  const HomeKPIScreen({Key? key}) : super(key: key);

  @override
  State<HomeKPIScreen> createState() => _HomeKPIScreenState();
}

class _HomeKPIScreenState extends State<HomeKPIScreen> with TickerProviderStateMixin {

  int activeIndex = 0;
  double we =0;
  double he = 0;
  String dateType = 'day';

  String storeName = '';
  late TabController tabController;
  List<String> listFilter = ['Ngày','Tuần','Tháng'];
  late HomeBloc _bloc;
  List<Widget> listChild = <Widget>[];
  setActiveDot(index) {
    setState(() {
      activeIndex = index;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(vsync: this, length: listFilter.length);
    _bloc = HomeBloc(context);
    _bloc.add(GetPrefsHomeEvent());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    we = MediaQuery.of(context).size.width;
    he = MediaQuery.of(context).size.height;
    return Scaffold(
      body: BlocListener<HomeBloc, HomeState>(
          bloc: _bloc,
          listener: (context, state) {
            if(state is GetPrefsSuccess){
              _bloc.add(GetKPIEvent(dateType: dateType,storeId: _bloc.storeId));
            }
            if(state is PickTransactionSuccess){
              _bloc.add(GetKPIEvent(dateType: dateType,storeId: _bloc.storeId));
            }
            else if(state is GetKPISuccess){
              listChild.clear();

              if( _bloc.doanhThuThuan.isNotEmpty){
                listChild.add(doanhThu());
              } if( _bloc.loiNhuanGop.isNotEmpty){
                listChild.add(laiSuatGop());
              }
              if( _bloc.tyTrongDoanhThuTheoCuaHang.isNotEmpty){
                listChild.add(tyTrong());
              } if( _bloc.doanhThuTheoSP.isNotEmpty){
                listChild.add(topProduct());
              }
              if( _bloc.doanhThuTheoNV.isNotEmpty){
                listChild.add(topUser());
              }
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            bloc: _bloc,
            builder: (BuildContext context, HomeState state) {
              return Stack(
                children: [
                  buildBody(context, state),
                  Visibility(
                    visible: state is HomeLoading,
                    child:const PendingAction(),
                  ),
                ],
              );
            },
          )),
    );
  }

  buildBody(BuildContext context, HomeState state){
    return SizedBox(
      width: we,
      height: he,
      child: Container(
        margin: const EdgeInsets.only(left: 14,right: 14),
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 40),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap:(){

                        },
                        child: Container(
                          alignment: Alignment.topLeft,

                          child: Text("Hi, ${_bloc.userName.toString()}!",style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: subColor
                          ),),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(top: 5),
                        child: Text("Hãy xem chỉ số KPI của mình và đội nhóm nhé",style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: subColor.withOpacity(0.6)
                        ),),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    height: 50,width: 50,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                        color: Colors.white
                    ),
                    child: const Icon(Icons.notifications_active_outlined),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  border: Border.all(color: Colors.grey.withOpacity(0.4))
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      const Icon(EneftyIcons.search_normal_2_outline,size: 18,),
                      const SizedBox(width: 10,),
                      Text('Bạn có thể tìm kiếm mọi thứ từ đây',style: TextStyle(color: subColor.withOpacity(0.5),fontSize: 12.5),)
                    ],
                  ),
                  const Spacer(),
                  const Icon(EneftyIcons.setting_4_outline,size: 18,),
                ],
              ),
            ),

            SizedBox(
              height: he * 0.01,
            ),
            Expanded(child: contentBody())
          ],
        ),
      ),
    );
  }

  buildGroupProduct(){
    return DataLocal.listStore.isEmpty == true
        ? const Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12))
        :
    PopupMenuButton(
      shape: const TooltipShape(),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Widget>>[
          PopupMenuItem<Widget>(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter myState){
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  height: 250,
                  child: Column(
                    children: [
                      Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 10),
                            itemCount: DataLocal.listStore.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                minVerticalPadding: 1,
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DataLocal.listStore[index].storeName.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: const Divider(height: 1,),
                                onTap: () {
                                  myState(() {});
                                  _bloc.add(PickStoreEvent(index, DataLocal.listStore[index]));
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ];
      },
      child: Row(
        children: [
          Text(_bloc.storeId.toString().replaceAll('null', '').isEmpty ? 'Tất cả cửa hàng' : _bloc.storeName.toString()),
          const SizedBox(width: 8,),
           Icon(
            MdiIcons.sortVariant,
            size: 15,
            color: black,
          ),
        ],
      ),
    );
  }

  contentBody(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 40,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    width: 200,
                    child: TabBar(
                      controller: tabController,
                      unselectedLabelColor: Colors.grey.withOpacity(0.8),
                      labelColor: Colors.red,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      isScrollable: true,
                      indicatorPadding: const EdgeInsets.all(0),
                      indicatorColor: Colors.red,
                      dividerColor: Colors.red,
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      indicator: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      tabs: List<Widget>.generate(listFilter.length, (int index) {
                        return Tab(
                          child: Text(listFilter[index].toString(),style: const TextStyle(fontSize: 13),),
                        );
                      }),
                      onTap: (index){
                        dateType = listFilter[index].toString().contains('Tuần') ? 'week' :
                        listFilter[index].toString().contains('Tháng') ? 'month' : 'day';
                        _bloc.add(GetKPIEvent(dateType: dateType,storeId: _bloc.storeId));
                      },
                    ),
                  ),
                ),

                SizedBox(
                    height: 20,
                    child: buildGroupProduct())
              ],
            ),
          ),
          SizedBox(
            height: he * 0.02,
          ),
          SizedBox(
            height: 450,width: double.infinity,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              elevation: 8,
              child: SizedBox(
                height: double.infinity,width: double.infinity,
                child:  Stack(
                  children: [
                    SizedBox(
                        height: 400,
                        width: double.infinity,
                        child: CarouselSlider(
                            items: listChild.map((child) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return child;
                                },
                              );
                            }).toList(),
                            options: CarouselOptions(
                              viewportFraction: 1,
                              initialPage: 0,
                              enlargeCenterPage: true,aspectRatio: 1.1,
                              autoPlay: false,
                              autoPlayCurve: Curves.easeInOutCirc,

                              autoPlayInterval: const Duration(seconds: 3),
                              autoPlayAnimationDuration: const Duration(milliseconds: 800),
                              enableInfiniteScroll: true,
                              onPageChanged:(index,__){
                                setActiveDot(index);
                              },
                            )
                        )
                    ),
                    Positioned.fill(
                      bottom: 10,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            listChild.length,
                                (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: activeIndex == index ? 15 : 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: activeIndex == index
                                    ? Colors.black
                                    : Colors.transparent,
                                border: Border.all(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Const.defaultPadding*5,)
        ],
      ),
    );
  }

  ///Store id
  Widget doanhThu() {
    return _bloc.doanhThuThuan.isNotEmpty ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(EneftyIcons.status_up_bold,color: Colors.green,size: 40,),
                const SizedBox(height: 10,),
                Text('Doanh Thu'.toUpperCase(),style: const TextStyle(color: Colors.black,fontSize: 14),),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          const Icon(EneftyIcons.direct_down_outline,color: Colors.transparent,),
                          Text('${Utils.formatMoneyStringToDouble(_bloc.doanhThuThuanItem.changes).toString().replaceAll('-', '')}%',style: const TextStyle(color: Colors.transparent,fontSize: 13),),
                        ],),
                    ),
                    Text(Utils.formatMoneyStringToDouble(_bloc.doanhThuThuanItem.tien),style: const TextStyle(color: Colors.blue,fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          _bloc.doanhThuThuanItem.changes! > 0 ?
                           Icon(MdiIcons.arrowDownBold,color: Colors.red,size: 18,) :
                           Icon(MdiIcons.arrowDownBold,color: Colors.red,size: 18,),
                          Text('${Utils.formatMoneyStringToDouble(_bloc.doanhThuThuanItem.changes).toString().replaceAll('-', '')}%',style: const TextStyle(color: Colors.red,fontSize: 12),),
                        ],),
                    )
                  ],
                ),
               // Text(Utils.formatMoneyStringToDouble(_bloc.doanhThuThuanItem.tien),style: const TextStyle(color: Colors.blue,fontSize: 18,fontWeight: FontWeight.bold),),
                const SizedBox(height: 10,),
                Text('Số đơn hàng: ${_bloc.doanhThuThuanItem.soDonHang}',style: const TextStyle(color: Colors.black,fontSize: 13),),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
                children: [
                  const TextSpan(
                    text:'Doanh thu ',
                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12.5),
                  ),
                  TextSpan(
                    text:'Bằng tổng giá trị các đơn hàng giao thành công, đã trừ trả hàng',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: FontWeight.normal,
                      fontSize: 12.5,),
                  )
                ]
            )
          )
        ],
      ),
    ) : Container();
  }

  Widget laiSuatGop() {
    return _bloc.loiNhuanGop.isNotEmpty ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(EneftyIcons.status_up_bold,color: Colors.green,size: 40,),
                const SizedBox(height: 10,),
                Text('Lợi nhuận gộp'.toUpperCase(),style: const TextStyle(color: Colors.black,fontSize: 14),),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          const Icon(EneftyIcons.direct_down_outline,color: Colors.transparent,),
                          Text('${Utils.formatMoneyStringToDouble(_bloc.loiNhuanGopItem.changes).toString().replaceAll('-', '')}%',style: const TextStyle(color: Colors.transparent,fontSize: 13),),
                        ],),
                    ),
                    Text(Utils.formatMoneyStringToDouble(_bloc.loiNhuanGopItem.loiNhuan),style: const TextStyle(color: Colors.blue,fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          _bloc.loiNhuanGopItem.changes! > 0 ?
                           Icon(MdiIcons.arrowDownBold,color: Colors.red,size: 18,) :
                           Icon(MdiIcons.arrowDownBold,color: Colors.red,size: 18,),
                          Text('${Utils.formatMoneyStringToDouble(_bloc.loiNhuanGopItem.changes).toString().replaceAll('-', '')}%',style: const TextStyle(color: Colors.red,fontSize: 12),),
                        ],),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Text('Tỷ suất lợi nhuận:${Utils.formatMoneyStringToDouble(_bloc.loiNhuanGopItem.tySuatLn)}%',style: const TextStyle(color: Colors.black,fontSize: 13),),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text('Doanh thu',style: TextStyle(color: Colors.black,fontSize: 13),),
                        const SizedBox(height: 5,),
                        Text(Utils.formatMoneyStringToDouble(_bloc.loiNhuanGopItem.doanhThu),style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Tiền vốn',style: TextStyle(color: Colors.black,fontSize: 13),),
                        const SizedBox(height: 5,),
                        Text(Utils.formatMoneyStringToDouble(_bloc.loiNhuanGopItem.tienVon),style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                      ],
                    )
                  ],
                )
              ],
            )
          ),
         const Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text('Lợi nhuận gộp = Doanh thu - Thuế - Giá vốn * SL bán',style: TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.bold),),
             SizedBox(height: 10,),
             Text('Giá vốn (MAC) là giá vốn bình quân của sản phẩm được tính sau mỗi lần nhập hàng',style: TextStyle(color: Colors.black,fontSize: 13),),
           ],
         )
        ],
      ),
    ) : Container();
  }

  Widget tyTrong() {
    return _bloc.tyTrongDoanhThuTheoCuaHang.isNotEmpty ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tỷ trọng'.toUpperCase(),style: const TextStyle(color: Colors.black,fontSize: 14),),
              const SizedBox(height: 10,),
              SizedBox(
                height: 180,
                width: double.infinity,
                child: PieChartTyTrongDoanhThu(tyTrongDoanhThuTheoCuaHang: _bloc.tyTrongDoanhThuTheoCuaHang),
              ),
              const SizedBox(height: 10,),
              Text('Tổng: ${Utils.formatMoneyStringToDouble(_bloc.tongTyTrong)}',style: const TextStyle(color: Colors.blue,fontSize: 18,fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              GestureDetector(
                onTap: ()=> showBottomSheetOrderQuantity(),
                child: const Row(
                  children: [
                    Expanded(child: Divider(),),
                    Text('Xem chi tiết',style: TextStyle(color: Colors.blue,fontSize: 13),),
                    SizedBox(
                      width: 10,
                      child: Divider(),
                    )
                  ],
                ),
              ),
            ],
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: _bloc.tyTrongDoanhThuTheoCuaHang.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      height: 30,width: 30,
                      padding: const EdgeInsets.all(3),
                      margin: const EdgeInsets.only(right: 4),
                      child: Row(
                        children: [
                         Expanded(child: Row(
                           children: [
                             Icon(Icons.circle,color: _bloc.tyTrongDoanhThuTheoCuaHang[index].color ,size: 16,),
                             const SizedBox(width: 6,),
                             Text(_bloc.tyTrongDoanhThuTheoCuaHang[index].tenBp.toString().trim(),style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 11,fontWeight: FontWeight.bold),),
                           ],
                         )),
                          Text(Utils.formatMoneyStringToDouble(_bloc.tyTrongDoanhThuTheoCuaHang[index].value).toString().trim(),style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 11,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    );
                  }
              )
          )
        ],
      ),
    ): Container();
  }

  Widget topProduct() {
    return _bloc.doanhThuTheoSP.isNotEmpty ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10,),
              Text('top ${_bloc.doanhThuTheoSP.length} sản phẩm'.toUpperCase(),style: const TextStyle(color: Colors.black,fontSize: 14),),
              const SizedBox(height: 10,),
              const Divider(),
            ],
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: _bloc.doanhThuTheoSP.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      height: 30,width: 30,
                      padding: const EdgeInsets.all(3),
                      margin: const EdgeInsets.only(right: 4),
                      child: Row(
                        children: [
                         Expanded(child: Row(
                           children: [
                             const Icon(Icons.circle,color: Colors.orange,size: 16,),
                             const SizedBox(width: 6,),
                             Text('${_bloc.doanhThuTheoSP[index].title}',style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 11,fontWeight: FontWeight.bold),),
                           ],
                         )),
                          Text(Utils.formatMoneyStringToDouble(_bloc.doanhThuTheoSP[index].value),style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 11,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    );
                  }
              )
          )
        ],
      ),
    ): Container();
  }

  Widget topUser() {
    return  _bloc.doanhThuTheoNV.isNotEmpty ?  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10,),
              Text('top ${_bloc.doanhThuTheoNV.length} nhân viên'.toUpperCase(),style: const TextStyle(color: Colors.black,fontSize: 14),),
              const SizedBox(height: 10,),
              const Divider(),
            ],
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: _bloc.doanhThuTheoNV.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      height: 30,width: 30,
                      padding: const EdgeInsets.all(3),
                      margin: const EdgeInsets.only(right: 4),
                      child: Row(
                        children: [
                         Expanded(child: Row(
                           children: [
                             const Icon(Icons.circle,color: Colors.orange,size: 16,),
                             const SizedBox(width: 6,),
                             Text('${_bloc.doanhThuTheoNV[index].name}',style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 11,fontWeight: FontWeight.bold),),
                           ],
                         )),
                          Text(Utils.formatMoneyStringToDouble(_bloc.doanhThuTheoNV[index].value),style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 11,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    );
                  }
              )
          )
        ],
      ),
    ) : Container();
  }

  void showBottomSheetOrderQuantity(){
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        backgroundColor: Colors.white,
        builder: (builder){
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25)
                )
            ),
            margin: MediaQuery.of(context).viewInsets,
            child: FractionallySizedBox(
              heightFactor: 0.95,
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
                            child: ListView.builder(
                                itemCount: _bloc.tyTrongDoanhThuTheoCuaHang.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemBuilder: (BuildContext context, int index){
                                  return Container(
                                    height: 30,width: 30,
                                    padding: const EdgeInsets.all(3),
                                    margin: const EdgeInsets.only(right: 4),
                                    child: Row(
                                      children: [
                                        Expanded(child: Row(
                                          children: [
                                            Icon(Icons.circle,color: _bloc.tyTrongDoanhThuTheoCuaHang[index].color ,size: 16,),
                                            const SizedBox(width: 6,),
                                            Text(_bloc.tyTrongDoanhThuTheoCuaHang[index].tenBp.toString().trim(),style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 11,fontWeight: FontWeight.bold),),
                                          ],
                                        )),
                                        Text(Utils.formatMoneyStringToDouble(_bloc.tyTrongDoanhThuTheoCuaHang[index].value).toString().trim(),style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 11,fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  );
                                }
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16,right: 16,bottom: 12),
                            child: GestureDetector(
                              onTap: (){
                                Navigator.pop(context,['Yeah']);
                              },
                              child: Container(
                                height: 45, width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: subColor
                                ),
                                child: const Center(
                                  child: Text('Save', style: TextStyle(color: Colors.white,fontSize: 12.5),),
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
    ).then((value){
      if(value != null){
        if(value[0] == 'Yeah'){

        }
      }
    });
  }
}

