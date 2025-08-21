// Removed unused cached_network_image import
import 'dart:io' show Platform;
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:dms/screen/dms/shipping/shipping_bloc.dart';
import 'package:dms/screen/dms/shipping/shipping_event.dart';
import 'package:dms/screen/dms/shipping/shipping_state.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/database/data_local.dart';
import '../../../themes/colors.dart';
import '../../options_input/options_input_screen.dart';
import '../detail_shipping/detail_shipping_screen.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({Key? key}) : super(key: key);

  @override
  _ShippingScreenState createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {

  late ShippingBloc _bloc;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = ShippingBloc(context);
    _bloc.add(GetPrefsShippingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ShippingBloc,ShippingState>(
        listener: (context, state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetListShippingEvent(dateFrom: Const.dateFrom,dateTo: Const.dateTo));
          }
        },
        bloc: _bloc,
        child: BlocBuilder<ShippingBloc,ShippingState>(
          bloc: _bloc,
          builder: (BuildContext context, ShippingState state){
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is GetListShippingEmpty,
                  child: const Center(child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey),),),
                ),
                Visibility(
                  visible: state is ShippingLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
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

  buildBody(BuildContext context,ShippingState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: RefreshIndicator(
              color: mainColor,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 2));
                _bloc.add(GetListShippingEvent(dateFrom: Const.dateFrom,dateTo: Const.dateTo));
              },
              child: SizedBox(
                height: double.infinity,width: double.infinity,
                child: buildListShipping(context),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildListShipping(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(left: 8,right: 8,bottom: 55),
      child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: _bloc.listShipping.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index){
            if(DataLocal.listStatus.isNotEmpty){
              for (var element in DataLocal.listStatus) {
                if(element.status.toString().trim().replaceAll('null', '') == _bloc.listShipping[index].status.toString().trim().replaceAll('null', '')){
                  _bloc.listShipping[index].statusName = element.statusname.toString().trim().replaceAll('null', '');
                  break;
                }
              }}
            final String _addressRaw = _bloc.listShipping[index].address?.toString() ?? '';
            final String _addressText = _addressRaw.replaceAll('null', '').trim();
            final bool _hasAddress = _addressText.isNotEmpty;
            return GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailShippingScreen(
                  sttRec: _bloc.listShipping[index].sttRec.toString().trim(),
                  maCT: _bloc.listShipping[index].maCt.toString().trim(),

                ))).then((value) {
                  _bloc.add(GetListShippingEvent(dateFrom: Const.dateFrom,dateTo: Const.dateTo));
                });
              },
              child: Card(
                elevation: 10,
                shadowColor: Colors.blueGrey.withOpacity(0.5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text('KH: ${_bloc.listShipping[index].tenKh?.trim()}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                              Text(' (${_bloc.listShipping[index].maKh?.trim()})', style: const TextStyle(color: Colors.grey,fontSize: 10),),
                            ],
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            children: [
                              Icon(MdiIcons.mapMarker,color: Colors.blueGrey,size: 12,),
                              const SizedBox(width: 3,),
                              Expanded(child: Text(_addressText, style: const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,)),
                              const SizedBox(width: 5,),
                              IconButton(
                                onPressed: _hasAddress ? () => _openGoogleMapsWithAddress(_addressText) : null,
                                icon: Icon(MdiIcons.mapOutline, color: _hasAddress ? Colors.blueGrey : Colors.grey, size: 20,),
                                tooltip: 'Mở bản đồ',
                                splashRadius: 20,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            children: [
                              Icon(MdiIcons.locker,color: Colors.blueGrey,size: 12,),
                              const SizedBox(width: 3,),
                              Text('Số CT: ${_bloc.listShipping[index].soCt?.trim()}', style: const TextStyle(color: Colors.blueGrey,fontSize: 12),),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              Icon(MdiIcons.locker,color: Colors.blueGrey,size: 12,),
                              const SizedBox(width: 3,),
                              Text('Số PX: ${_bloc.listShipping[index].soPhieuXuat.toString().trim().replaceAll('null', 'Đang cập nhật')}', style: const TextStyle(color: Colors.blueGrey,fontSize: 12),),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              Icon(MdiIcons.locker,color: Colors.blueGrey,size: 12,),
                              const SizedBox(width: 3,),
                              Text('Số Fcode3: ${_bloc.listShipping[index].fcode3.toString().trim().replaceAll('null', 'Đang cập nhật')}', style: const TextStyle(color: Colors.blueGrey,fontSize: 12),),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,color: Colors.blueGrey,size: 12,),
                              const SizedBox(width: 3,),
                              Text('Ngày:   ${Utils.parseStringDateToString(_bloc.listShipping[index].ngayCt.toString(), Const.DATE_SV, Const.DATE_FORMAT_1)}', style: const TextStyle(color: Colors.blueGrey,fontSize: 12),),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.monetization_on_outlined,color: Colors.blueGrey,size: 12,),
                                    const SizedBox(width: 3,),
                                    Text('Tổng thanh toán: ${Utils.formatMoney(_bloc.listShipping[index].tTtNt)} VNĐ', style: const TextStyle(color: Colors.blueGrey,fontSize: 12),),
                                  ],
                                ),
                              ),
                              Text('${_bloc.listShipping[index].statusName}', style: const TextStyle(color: Colors.purple,fontSize: 12.5),),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
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
                "Danh sách P.Giao Hàng",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: ()=>  showDialog(
                context: context,
                builder: (context) => OptionsFilterDate(
                  dateFrom: Const.dateFrom.toString(),
                  dateTo: Const.dateTo.toString(),
                )).then((value){
              if(value != null){
                if(value[1] != null && value[2] != null){
                  Const.dateFrom = Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT);
                  Const.dateTo = Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT);
                  _bloc.add(GetListShippingEvent(dateFrom: Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT),dateTo: Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT)));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy chọn từ ngày đến ngày');
                }
              }
            }),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.calendar_today_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

}
