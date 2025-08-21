// ignore_for_file: library_private_types_in_public_api


import 'package:dms/screen/menu/menu_bloc.dart';

import 'package:dms/screen/menu/menu_state.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../options_input/options_input_screen.dart';
import '../menu_event.dart';


class HistoryActionEmployeeScreen extends StatefulWidget {
  final String? idCustomer;

  const HistoryActionEmployeeScreen({Key? key,required ,this.idCustomer}) : super(key: key);

  @override
  _HistoryActionEmployeeScreenState createState() => _HistoryActionEmployeeScreenState();
}

class _HistoryActionEmployeeScreenState extends State<HistoryActionEmployeeScreen> {

  late MenuBloc _bloc;

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  String dateFrom = Utils.parseDateToString(DateTime.now().add(const Duration(days: -5)), Const.DATE_SV_FORMAT_2);
  String dateTo = Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2);

  String idCustomer = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _bloc = MenuBloc(context);
    _bloc.add(GetPrefsMenuEvent());
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListHistoryActionEmployeeEvent(isLoadMore:true,dateFrom:dateFrom.toString(),dateTo: dateTo,idCustomer:idCustomer));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MenuBloc,MenuState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            idCustomer = widget.idCustomer.toString();
            _bloc.add(GetListHistoryActionEmployeeEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,idCustomer: idCustomer));
          }
        },
        child: BlocBuilder<MenuBloc,MenuState>(
          bloc: _bloc,
          builder: (BuildContext context, MenuState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetListHistoryEmployeeEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is MenuLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,MenuState state){
    int length = _bloc.list.length;
    if (state is GetListHistoryEmployeeSuccess) {
      _hasReachedMax = length < _bloc.currentPage * 20;
    }
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: RefreshIndicator(
              color: mainColor,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 2));
                _bloc.list.clear();
                _bloc.add(GetListHistoryActionEmployeeEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,idCustomer: idCustomer));
              },
              child: SizedBox(
                height: double.infinity,width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        const SizedBox(width: 4,),
                        Text('Danh sách từ $dateFrom - $dateTo' ,style: const TextStyle(color:Colors.blueGrey,fontSize: 12),),
                        const SizedBox(width: 4,),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        separatorBuilder: (BuildContext context, int index)=>Container(),
                        itemBuilder: (BuildContext context, int index){
                          return index >= length ?
                          Container(
                            height: 100.0,
                            color: white,
                            child: const PendingAction(),
                          )
                              :
                          Card(
                            semanticContainer: true,
                            margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 10,right: 3,top: 5,bottom: 5),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(MdiIcons.contentPaste,color: subColor,size: 15,),
                                                const SizedBox(width: 5,),
                                                Text(
                                                  _bloc.list[index].tieuDe.toString().trim(),
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 12.5,),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5,),
                                        Row(
                                          children: [
                                            Icon(MdiIcons.contactsOutline,color: subColor,size: 15,),
                                            const SizedBox(width: 5,),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'KH: ',
                                                    style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color: Color(0xff555a55)),
                                                  ),
                                                  TextSpan(
                                                    text: '[${_bloc.list[index].maKh.toString().trim()}] ',
                                                    style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                        0xff555a55)),
                                                  ),
                                                  TextSpan(
                                                    text: _bloc.list[index].tenKh.toString().trim(),
                                                    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5,),
                                        Row(
                                          children: [
                                            const Icon(Icons.account_circle_outlined,color: subColor,size: 15,),
                                            const SizedBox(width: 5,),
                                            Text(
                                              'NVPT: ${_bloc.list[index].tenNv.toString().trim()}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(color: Color(0xff555a55),fontWeight: FontWeight.bold, fontSize: 12.5,),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5,),
                                        Row(
                                          children: [
                                            const Icon(Icons.date_range,color: subColor,size: 15,),
                                            const SizedBox(width: 5,),
                                            Text(
                                              'Thời gian HĐ: ${_bloc.list[index].ngay != null ? Utils.parseDateTToString(_bloc.list[index].ngay.toString(), Const.DATE_TIME_FORMAT_LOCAL).toString() : 'Đang cập nhật'}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(color: Color(0xff555a55), fontSize: 11,),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 3,),
                                  const Divider(),
                                  const SizedBox(height: 3,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Loại hình:  ${_bloc.list[index].loaiHinh.toString().trim()}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
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
                                          'Nội dung:  ${_bloc.list[index].noiDung}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: length == 0 ? length : _hasReachedMax ? length : length + 1,
                      ),
                    ),
                    const SizedBox(height: 15,)
                  ],
                ),
              ),
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
                "Lịch sử hoạt động",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: ()=>showDialog(
                context: context,
                builder: (context) => const OptionsFilterDate()).then((value){
              if(value != null){
                if(value[1] != null && value[2] != null){
                  dateFrom = value[3];
                  dateTo = value[4];
                  if(_bloc.list.isNotEmpty){
                    _bloc.list.clear();
                  }
                  _bloc.add(GetListHistoryActionEmployeeEvent(
                      dateFrom:dateFrom.toString(),
                      dateTo: dateTo,
                      idCustomer: idCustomer
                  ));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy chọn từ ngày đến ngày');
                }
              }
            }),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.event,
                size: 25,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
