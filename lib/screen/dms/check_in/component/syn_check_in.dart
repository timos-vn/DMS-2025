// ignore_for_file: library_private_types_in_public_api, unrelated_type_equality_checks
import 'dart:async';

import 'package:dms/utils/const.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:dms/screen/dms/check_in/check_in_event.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../model/database/dbhelper.dart';
import '../../../../model/network/response/detail_checkin_response.dart';
import '../../../../model/network/response/list_checkin_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/toast.dart';
import '../../../../utils/utils.dart';

import '../check_in_bloc.dart';
import '../check_in_state.dart';
import 'detail_check_in.dart';


class SynCheckInScreen extends StatefulWidget {
  final List<ListAlbum> listAlbumOffline;
  final List<ListAlbumTicketOffLine> listAlbumTicketOffLine;
  const SynCheckInScreen({Key? key,required this.listAlbumOffline, required this.listAlbumTicketOffLine,}) : super(key: key);

  @override
  _SynCheckInScreenState createState() => _SynCheckInScreenState();
}

class _SynCheckInScreenState extends State<SynCheckInScreen> {

  late CheckInBloc _bloc;

  final ScrollController controller  = ScrollController();
  final _controller = ScrollController();
  ListCheckIn itemSelect = ListCheckIn();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = CheckInBloc(context);
    _bloc.add(GetPrefsCheckIn());

  }

  DatabaseHelper db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocListener<CheckInBloc,CheckInState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetListSynCheckInEvent());
          }
          else if(state is GetListSynCheckInSuccess){
            _bloc.add(GetImageLocalEvent());
          }
          else if(state is SynCheckInSuccess){
            if(_bloc.numberSync > 0){
              _bloc.add(SynCheckInEvent());
            }else if(_bloc.numberSync == 0){
              ToastUtils.success('Đồng bộ dữ liệu thành công');
              _bloc.add(GetListSynCheckInEvent());
            }
          }
          else if(state is GetTimeCheckOutSaveSuccess){
            PersistentNavBarNavigator.pushNewScreen(context, screen: DetailCheckInScreen(
              item: itemSelect,
              idCheckIn: (itemSelect.id !=  '' && itemSelect.id != 'null') ? itemSelect.id! : 0,//itemSelect!.id!,
              dateCheckIn: DateTime.parse(itemSelect.ngayCheckin.toString()),
              listAppSettings: const [],
              view: false,
              isCheckInSuccess: false,
              listAlbumOffline: widget.listAlbumOffline,
              listAlbumTicketOffLine: widget.listAlbumTicketOffLine,
              ngayCheckin: (itemSelect.ngayCheckin != '' && itemSelect.ngayCheckin != 'null') ? Utils.parseStringToDate(itemSelect.ngayCheckin!, Const.DATE_SV).toString() : '',
              tgHoanThanh: (itemSelect.tgHoanThanh != '' && itemSelect.tgHoanThanh != 'null') ? itemSelect.tgHoanThanh! : '',
              numberTimeCheckOut: itemSelect.numberTimeCheckOut??0,
              isSynSuccess: itemSelect.isSynSuccessful??false,
            )).then((value) {
              SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.light,
                  statusBarColor: Colors.transparent
              ));
              _bloc.add(GetListSynCheckInEvent());
            });
          }
        },
        child: BlocBuilder<CheckInBloc,CheckInState>(
          bloc: _bloc,
          builder: (BuildContext context, CheckInState state){
            return Scaffold(
              backgroundColor: Colors.white,
              floatingActionButton:_bloc.listSynCheckIn.isEmpty ? Container() : FloatingActionButton(
                backgroundColor: subColor,
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (context) {
                        return WillPopScope(
                          onWillPop: () async => false,
                          child: CustomQuestionComponent(
                            showTwoButton: true,
                            iconData: MdiIcons.cloudUploadOutline,
                            title: 'Đồng bộ dữ liệu',
                            content: 'Bạn hãy đảm bảo đường truyền Internet/3G/4G/5G của bạn đang là ổn định và trong phạm vi có sóng di động, để đảm bảo quá trình đồng bộ không xảy ra lỗi.',
                          ),
                        );
                      }).then((value)async{
                    if(value != null){
                      if(!Utils.isEmpty(value) && value == 'Yeah'){
                        _bloc.add(SynCheckInEvent());
                      }
                    }
                  });
                },
                child: Icon(MdiIcons.cloudSyncOutline,color: Colors.white,),
              ),
              body: Stack(
                children: [
                  buildBody(context,state),
                  Visibility(
                    visible: state is CheckInLoading,
                    child: const PendingAction(),
                  ),
                  Visibility(
                    visible: state is SyncLoading,
                    child: Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          // leftDotColor: const Color(0xFF1A1A3F),
                          // rightDotColor: const Color(0xFFEA3799),
                          size: 50, color: red,
                        ),)
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,CheckInState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(state),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 16),
              // decoration: BoxDecoration(
              //     boxShadow: <BoxShadow>[
              //       BoxShadow(
              //           color: Colors.grey.shade200,
              //           offset: Offset(2, 4),
              //           blurRadius: 5,
              //           spreadRadius: 2)
              //     ],
              //     gradient: LinearGradient(
              //         begin: Alignment.centerLeft,
              //         end: Alignment.centerRight,
              //         colors: [subColor,Color.fromARGB(255, 150, 185, 229)])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Visibility(
                          visible: _bloc.listSynCheckIn.isEmpty,
                          child:const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16,horizontal: 18),
                              child: Center(
                                child: Text('Úi, Không có dữ liệu nào cần đồng bộ!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _bloc.listSynCheckIn.isNotEmpty,
                          child: Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              //physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              controller: _controller,
                              itemCount: _bloc.listSynCheckIn.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: (){
                                    itemSelect = ListCheckIn(
                                        id: (_bloc.listSynCheckIn[index].idCheckIn != "null" && _bloc.listSynCheckIn[index].idCheckIn != '') ? int.parse(_bloc.listSynCheckIn[index].idCheckIn.toString()) : 0,
                                    tieuDe: _bloc.listSynCheckIn[index].tieuDe??'',
                                    ngayCheckin: _bloc.listSynCheckIn[index].timeCheckIn??'',
                                    maKh: _bloc.listSynCheckIn[index].maKh??'',
                                    tenCh: _bloc.listSynCheckIn[index].tenCh??'',
                                    diaChi: _bloc.listSynCheckIn[index].diaChi??'',
                                    dienThoai: _bloc.listSynCheckIn[index].dienThoai??'',
                                    gps: _bloc.listSynCheckIn[index].gps??'',
                                    trangThai: _bloc.listSynCheckIn[index].timeCheckOut?.isEmpty == true
                                        ?
                                    'Chưa check out'
                                        :
                                    'Hoàn thành',
                                    tgHoanThanh: _bloc.listSynCheckIn[index].tgHoanThanh??'',
                                    lastCheckOut: _bloc.listSynCheckIn[index].lastChko??'',
                                    isCheckInSuccessful: _bloc.listSynCheckIn[index].trangThai?.trim() == 'Hoàn thành' ? true : false,
                                    latLong: _bloc.listSynCheckIn[index].latlong??'',
                                      timeCheckOut: _bloc.listSynCheckIn[index].timeCheckOut??'',
                                      numberTimeCheckOut: _bloc.listSynCheckIn[index].numberTimeCheckOut,
                                      isSynSuccessful: _bloc.listSynCheckIn[index].isSynSuccessful == 1 ? true : false
                                    );
                                    _bloc.add(GetTimeCheckOutSave(
                                        //latLong: _bloc.listSynCheckIn[index].latLong.toString(),
                                        idCheckIn: int.parse(_bloc.listSynCheckIn[index].idCheckIn.toString()),
                                        // nameStore: _bloc.listSynCheckIn[index].nameStore.toString(),
                                        idCustomer: _bloc.listSynCheckIn[index].maKh.toString(),
                                        itemSelect: itemSelect
                                        // isCheckInSuccess: false,
                                        // title: _bloc.listSynCheckIn[index].title.toString(),
                                        // dateCheckIn: DateTime.parse(_bloc.listSynCheckIn[index].timeCheckIn.toString())
                                    ));

                                  },
                                  child: Container(
                                      height: 110,width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width:13,
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12),bottomLeft: Radius.circular(12)),
                                                color: Colors.deepPurple
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: grey_100,
                                                borderRadius: const BorderRadius.only(topRight: Radius.circular(12),bottomRight: Radius.circular(12)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 8,right: 12,top: 15,bottom: 10),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Flexible(child: Text('${_bloc.listSynCheckIn[index].tieuDe}',style:const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Icon(MdiIcons.store,color: subColor,size: 16,),
                                                        const SizedBox(width: 5,),
                                                        Flexible(child: Text('${_bloc.listSynCheckIn[index].tenCh}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Icon(MdiIcons.mapMarkerRadiusOutline,color: subColor,size: 16,),
                                                        const SizedBox(width: 5,),
                                                        Flexible(child: Text('${_bloc.listSynCheckIn[index].diaChi}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    Row(
                                                      children: [
                                                        Icon(MdiIcons.calendarCheckOutline,color: subColor,size: 16,),
                                                        const SizedBox(width: 5,),
                                                        Text(_bloc.listSynCheckIn[index].timeCheckOut?.isEmpty == true
                                                            ?
                                                        'Chưa check out'
                                                            :
                                                        'Hoàn thành',
                                                          style:TextStyle(
                                                              color: _bloc.listSynCheckIn[index].timeCheckOut?.isEmpty == true ? Colors.blueAccent : Colors.red,
                                                              fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildAppBar(CheckInState state){
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
            onTap: (){
              if(state is SyncLoading){
                print('on123');
              }
              else{Navigator.pop(context);}
            },
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
                'Đồng bộ dữ liệu Check-in',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.search_outlined,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }
}
