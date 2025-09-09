import 'dart:io' show Platform;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/database/data_local.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../dms/check_in/component/detail_check_in.dart';
import '../../dms/refund_sale_out/component/list_sale_out_completed_screen.dart';
import '../../sell/order/order_sceen.dart';
import '../../sell/refund_order/component/list_order_completed_screen.dart';
import 'detail_customer_event.dart';
import 'detail_customer_state.dart';
import 'detail_customer_bloc.dart';

class DetailInfoCustomerScreen extends StatefulWidget {
  final String? idCustomer;

  const DetailInfoCustomerScreen({Key? key, this.idCustomer}) : super(key: key);
  @override
  _DetailInfoCustomerScreenState createState() => _DetailInfoCustomerScreenState();
}

class _DetailInfoCustomerScreenState extends State<DetailInfoCustomerScreen> {

  late DetailCustomerBloc _bloc;

  List<Color> listColor = [Colors.blueAccent,Colors.lightGreen,Colors.pink,Colors.yellow];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = DetailCustomerBloc(context);
    _bloc.add(GetPrefs());
  }

  Future<void> _openGoogleMapsWithAddress(String address) async {
    final String trimmed = address.replaceAll('null', '').trim();
    if (trimmed.isEmpty) {
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Địa chỉ trống, không thể mở Google Maps');
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mở bản đồ'),
        content: Text('Bạn có muốn mở bản đồ với địa chỉ:\n\n$trimmed'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Mở'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final String encoded = Uri.encodeComponent(trimmed);

    if (Platform.isIOS) {
      final Uri iosAppUri = Uri.parse('comgooglemaps://?q=$encoded');
      try {
        if (await canLaunchUrl(iosAppUri)) {
          await launchUrl(iosAppUri, mode: LaunchMode.externalApplication);
          return;
        }
        // Fallback to Apple Maps if Google Maps app is not available
        final Uri appleMapsUri = Uri.parse('http://maps.apple.com/?q=$encoded');
        if (await canLaunchUrl(appleMapsUri)) {
          await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    } else if (Platform.isAndroid) {
      final Uri androidGeoUri = Uri.parse('geo:0,0?q=$encoded');
      try {
        if (await canLaunchUrl(androidGeoUri)) {
          await launchUrl(androidGeoUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    final Uri webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    try {
      final launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Không thể mở Google Maps');
      }
    } catch (_) {
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Không thể mở Google Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DetailCustomerBloc,DetailCustomerState>(
          bloc: _bloc,
          listener: (context,state){
            if(state is GetPrefsSuccess){
              _bloc.add(GetDetailCustomerEvent(widget.idCustomer.toString()));
            }
            if(state is DetailCustomerFailure){
              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Có lỗi xảy ra.');
            }
            else if(state is GetInfoTaskCustomerSuccess){
              _bloc.add(GetDetailCheckInOnlineEvent(idCheckIn: state.idTask, idCustomer: state.idCustomer.toString()));
            }else if(state is GetDetailCheckInOnlineSuccess){
              DataLocal.latLongLocation = '';
              DataLocal.addressCheckInCustomer = '';
              DataLocal.addImageToAlbumRequest = false;
              DataLocal.addImageToAlbum = false;
              DataLocal.listInventoryIsChange = true;
              DataLocal.listOrderProductIsChange = true;

              PersistentNavBarNavigator.pushNewScreen(context, screen: DetailCheckInScreen(
                idCheckIn: _bloc.idCheckIn,
                dateCheckIn: DateTime.now(),
                listAppSettings: const [],
                view: false,
                isCheckInSuccess: false,
                listAlbumOffline: _bloc.listAlbum,
                listAlbumTicketOffLine: _bloc.listTicket,
                ngayCheckin: (state.itemSelect.ngayCheckin != "null" && state.itemSelect.ngayCheckin != '' && state.itemSelect.ngayCheckin != null) ? DateTime.tryParse(state.itemSelect.ngayCheckin.toString()).toString() : '',
                tgHoanThanh: (state.itemSelect.tgHoanThanh != null && state.itemSelect.tgHoanThanh != 'null' && state.itemSelect.tgHoanThanh != '') ? state.itemSelect.tgHoanThanh! : '',
                numberTimeCheckOut:  int.parse(state.itemSelect.timeCheckOut.toString()),
                isSynSuccess: false,
                item:  state.itemSelect,
                isGpsFormCustomer: true,
              ));
            }
          },
          child: BlocBuilder<DetailCustomerBloc,DetailCustomerState>(
            bloc: _bloc,
            builder: (BuildContext context, DetailCustomerState state){
              return Stack(
                children: [
                  buildBody(context, state),
                  Visibility(
                    visible: state is DetailCustomerLoading,
                    child:const PendingAction(),
                  ),
                ],
              );
            },
          )
      ),
    );
  }

  buildBody(BuildContext context,DetailCustomerState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16,top: 10,bottom: 10,right: 16),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Text(_bloc.detailCustomer.customerName??'',style: const TextStyle(color: blue,fontWeight: FontWeight.normal,fontSize: 18),)),
                          const SizedBox(height: 8,),
                          const Divider(
                            height: 1,
                            color: blue,
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            children: [
                              const Icon(Icons.phone,size: 13,color: grey,),
                              const SizedBox(width: 8,),
                              Text(
                                _bloc.detailCustomer.phone??'',
                                style: const TextStyle(fontSize: 13,color: grey,),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16,),
                          Row(
                            children: [
                              const Icon(Icons.email,size: 13,color: grey,),
                              const SizedBox(width: 8,),
                              Text(
                                _bloc.detailCustomer.email??'....',
                                style: const TextStyle(fontSize: 13,color: grey,),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16,),
                          Row(
                            children: [
                              const Icon(Icons.location_on,size: 13,color: grey,),
                              const SizedBox(width: 8,),
                              Expanded(
                                child: Text(
                                  _bloc.detailCustomer.address??'',
                                  style: const TextStyle(fontSize: 13,color: grey,),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 5,),
                              IconButton(
                                onPressed: (_bloc.detailCustomer.address?.replaceAll('null', '').trim().isNotEmpty == true) 
                                  ? () => _openGoogleMapsWithAddress(_bloc.detailCustomer.address ?? '') 
                                  : null,
                                icon: Icon(
                                  MdiIcons.mapOutline, 
                                  color: (_bloc.detailCustomer.address?.replaceAll('null', '').trim().isNotEmpty == true) 
                                    ? Colors.blueGrey 
                                    : Colors.grey, 
                                  size: 20,
                                ),
                                tooltip: 'Mở bản đồ',
                                splashRadius: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16,),
                          Row(
                            children: [
                              const Icon(FontAwesomeIcons.birthdayCake,size: 13,color: grey,),
                              const SizedBox(width: 8,),
                              Text(
                                _bloc.detailCustomer.birthday.toString().replaceAll('null', '').isNotEmpty ?  _bloc.detailCustomer.birthday.toString() : 'Chưa có thông tin sinh nở của KH này',
                                style: const TextStyle(fontSize: 13,color: grey,),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16,),
                          Row(
                            children: [
                              const Icon(Icons.receipt_long,size: 13,color: grey,),
                              const SizedBox(width: 8,),
                              Text(
                                (_bloc.detailCustomer.lastPurchaseDate.toString().replaceAll('null', '').isNotEmpty ) ?  _bloc.detailCustomer.lastPurchaseDate.toString() : 'KH này chưa từng mua hàng của bạn',
                                style: const TextStyle(fontSize: 13,color: grey,),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: Const.createTaskFromCustomer == true && state is !DetailCustomerLoading,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    child: GestureDetector(
                      onTap: (){
                        _bloc.add(CreateTaskFromCustomerEvent(idCustomer: _bloc.detailCustomer.customerCode.toString()));
                      },
                      child: Card(
                        elevation: 1,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding:const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                    color: subColor,
                                  ),
                                  child: Center(
                                      child:  Icon(MdiIcons.watchImport,color: Colors.white,size: 15,)
                                  )
                              ),
                              const SizedBox(width: 10,),
                              const Flexible(
                                child: Text(
                                  'Check-in / Giám sát',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                ),
                              ),//_bloc.listOtherData[index]?.value.toString()??'0.0'
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: state is !DetailCustomerLoading && Const.createNewOrderFromCustomer == true,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    child: GestureDetector(
                      onTap: ()=>PersistentNavBarNavigator.pushNewScreen(context, screen: OrderScreen(
                        nameCustomer: _bloc.detailCustomer.customerName,
                        phoneCustomer: _bloc.detailCustomer.phone,
                        addressCustomer: _bloc.detailCustomer.address,
                        codeCustomer: _bloc.detailCustomer.customerCode,
                      ),withNavBar: false),
                      child: Card(
                        elevation: 1,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding:const EdgeInsets.all(8),
                                  decoration:  BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    color: mainColor,
                                  ),
                                  child: Center(
                                      child: Icon(MdiIcons.cartOutline,size: 15,color: white,)
                                  )
                              ),
                              const SizedBox(width: 10,),
                              const Flexible(
                                child: Text(
                                  'Đặt đơn',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                ),
                              ),//_bloc.listOtherData[index]?.value.toString()??'0.0'
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: Const.refundOrder == true && state is !DetailCustomerLoading,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    child: GestureDetector(
                      onTap: ()=> PersistentNavBarNavigator.pushNewScreen(context, screen: OrderCompletedScreen(detailCustomer: _bloc.detailCustomer,),withNavBar: false),//_bloc.detailCustomer.customerCode.toString()
                      child: Card(
                        elevation: 1,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding:const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                    color: subColor,
                                  ),
                                  child: Center(
                                      child: Icon(MdiIcons.arrangeSendToBack,size: 15,color: white,)
                                  )
                              ),
                              const SizedBox(width: 10,),
                              const Flexible(
                                child: Text(
                                  'Lập phiếu hàng bán trả lại',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                ),
                              ),//_bloc.listOtherData[index]?.value.toString()??'0.0'
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: Const.refundOrderSaleOut == true && state is !DetailCustomerLoading,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    child: GestureDetector(
                      onTap: ()=> PersistentNavBarNavigator.pushNewScreen(context, screen: SaleOutCompletedScreen(detailAgency: _bloc.detailCustomer,),withNavBar: false),//_bloc.detailCustomer.customerCode.toString()
                      child: Card(
                        elevation: 1,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding:const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  child: Center(
                                      child: Icon(MdiIcons.sendCheckOutline,size: 15,color: white,)
                                  )
                              ),
                              const SizedBox(width: 10,),
                              const Flexible(
                                child: Text(
                                  'Lập phiếu hàng bán trả lại Sale Out',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                ),
                              ),//_bloc.listOtherData[index]?.value.toString()??'0.0'
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                listItem(context),
              ],
            ),
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
                "Thông tin khách hàng",
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

  Widget listItem(BuildContext context){
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 0,left: 16,right: 16),
          itemBuilder: (BuildContext context, int index){
            return GestureDetector(
              onTap: (){
                if(index == 0){
                 // Navigator.push(context, MaterialPageRoute(builder: (context)=> FilterOrderPage()));
                }else if(index == 1){

                }else if(index == 2){
                  //Navigator.push(context, MaterialPageRoute(builder: (context)=> ManagerCustomerPage()));
                }
              },
              child: Card(
                elevation: 1,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            color: _bloc.listOtherData?[index].iconUrl?.isNotEmpty == true ? Colors.white : listColor[index],
                          ),
                          child: _bloc.listOtherData?[index].iconUrl?.isNotEmpty == true ?
                          CachedNetworkImage(
                            imageUrl: _bloc.listOtherData![index].iconUrl.toString(),
                            fit: BoxFit.fitHeight,
                            height: 40,
                            width: 40,
                            // width: MediaQuery.of(context).size.width,
                          ) :
                          const Center(
                              child: Icon(Icons.library_books,size: 15,color: white,)
                          )
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Text(
                          _bloc.listOtherData?[index].text??'',
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),//_bloc.listOtherData[index]?.value.toString()??'0.0'
                      Center(child: Text(NumberFormat(_bloc.listOtherData?[index].formatString).format(_bloc.listOtherData?[index].value).toString(),style: const TextStyle(fontWeight: FontWeight.normal,color: orange),)),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index)=> Container(),
          itemCount: _bloc.listOtherData!.length
      ),
    );
  }
}
