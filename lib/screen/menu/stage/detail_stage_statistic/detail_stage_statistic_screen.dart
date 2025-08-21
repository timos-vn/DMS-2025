// import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms/widget/custom_confirm.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';

import '../../../../model/network/response/detail_stage_statistic_response.dart';
import '../../component/update_stage_statistic.dart';
import 'detail_stage_statistic_bloc.dart';
import 'detail_stage_statistic_state.dart';
import 'detail_stage_statistic_event.dart';

class DetailStageStatisticScreen extends StatefulWidget {
  final String? sttRec;
  final String? nameStage;
  final int? idStage;
  final String? idCustomer;
  final String? nameCustomer;

  const DetailStageStatisticScreen({Key? key, this.sttRec,this.nameStage,this.idStage,this.idCustomer,this.nameCustomer}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _DetailStageStatisticScreenState createState() => _DetailStageStatisticScreenState();
}

class _DetailStageStatisticScreenState extends State<DetailStageStatisticScreen>  with SingleTickerProviderStateMixin{

  late DetailStageStatisticBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  final bool _hasReachedMax = true;

  final List<DetailStageStatisticResponseData> _listDetailStage =  <DetailStageStatisticResponseData>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = DetailStageStatisticBloc(context);
    _bloc.add(GetPrefs());
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListDetailStageStatistic(soCt: widget.sttRec.toString(),isLoadMore:true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DetailStageStatisticBloc,DetailStageStatisticState>(
      bloc: _bloc,
      listener: (context,state){
        if(state is GetPrefsSuccess){
          _bloc.add(GetStoreList(idStage: widget.idStage!));
        }
        else if(state is GetListStoreSuccess){
          _bloc.add(GetListDetailStageStatistic(soCt: widget.sttRec.toString()));
        }
        else if(state is GetListDetailStageSuccess){
          if(_bloc.listDetailStage.isNotEmpty){
            for (var element in _bloc.listDetailStage) {
              if(widget.idStage == 1){
                if(element.slSongTt! > 0 || element.slSongCp! > 0 || element.slSongTd! > 0 || element.slSongDat! > 0){
                  _listDetailStage.add(element);
                }
              }
              else if(widget.idStage == 2){
                if(element.slInTt! > 0 || element.slInHong! > 0 || element.slInSong! > 0 || element.slInDat! > 0){
                  _listDetailStage.add(element);
                }
              }
              else if(widget.idStage == 3){
                if(element.slCbTt! > 0 || element.slCbIn! > 0 || element.slCbSong! > 0 || element.slCbBx! > 0 || element.slCbDat! > 0){
                  _listDetailStage.add(element);
                }
              }
              else if(widget.idStage == 4){
                if(element.slLvTt! > 0 || element.slLvIn! > 0 || element.slLvSong! > 0 || element.slLvBx! > 0 || element.slLvDat! > 0){
                  _listDetailStage.add(element);
                }
              }
              else if(widget.idStage == 5){
                if(element.slHtTt! > 0 || element.slHtIn! > 0 || element.slHtCb! > 0 || element.slHtHt! > 0 || element.slHtDat! > 0){
                  _listDetailStage.add(element);
                }
              }
            }
          }
        }
        else if(state is CreateTKCDSuccess){
          Navigator.pop(context,'BackLoad');
          Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Tạo phiếu thành công');
        }else if(state is CreateTKCDFailed){
          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Tạo phiếu Không thành công');
        }
      },
      child: BlocBuilder<DetailStageStatisticBloc,DetailStageStatisticState>(
        bloc: _bloc,
        builder: (BuildContext context, DetailStageStatisticState state){
          return Scaffold(
            floatingActionButton:  Visibility(
              visible: Const.cacheAllowed == true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: FloatingActionButton(
                  backgroundColor: subColor,
                  onPressed: ()async{
                    if(_listDetailStage.isNotEmpty){
                      _bloc.add(UpdateTKCDDraft(sttRec: widget.sttRec.toString(),idStage: widget.idStage!,listDetailStage: _listDetailStage));
                    }else{
                      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn chưa cập nhật MVT nào vào phiếu kìa.');
                    }
                  },
                  child: const Icon(Icons.save_alt,color: Colors.white,),
                ),
              ),
            ),
            body: Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetListDetailStageEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is DetailStageStatisticLoading,
                  child: const PendingAction(),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  buildStage(DetailStageStatisticResponseData item){
    final double width = MediaQuery.of(context).size.width;
    return Expanded(
      child: widget.idStage == 1
          ?
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  DataTable(
          headingRowHeight: 40,
          dividerThickness: 1.0,
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: <DataColumn>[
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Sản xuất',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Chuyển phế',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'SL Đạt',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Kho',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Center(child: Text('${(item.slSongTt.toString().trim() == 'null' ? 0 : item.slSongTt.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slSongCp.toString().trim() == 'null' ? 0 : item.slSongCp.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slSongDat.toString().trim() == 'null' ? 0 : item.slSongDat.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(PopupMenuButton(
                    padding: EdgeInsets.zero,
                    offset: const Offset(4, 30),
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<Widget>>[
                        PopupMenuItem<Widget>(
                          child: Container(
                            decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            height: 300,
                            width: 550,
                            child: Scrollbar(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(top: 10),
                                itemCount: _bloc.listStore.length,
                                itemBuilder: (context, index) {
                                  final trans = _bloc.listStore[index].tenKho;
                                  return ListTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            trans.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),Text(
                                          _bloc.listStore[index].maKho.toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: const Divider(height: 1,),
                                    onTap: () {
                                      _bloc.add(ChooseStore(idStore: _bloc.listStore[index].maKho.toString(),nameStore: _bloc.listStore[index].tenKho.toString()));
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ];
                    },
                    child: Center(child: Text(_bloc.nameStore??'....',style: const TextStyle(fontSize: 11,color: Colors.grey),)))),
              ],
            ),
          ],
        ),
      )
          :
      widget.idStage == 2
          ?
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  DataTable(
          headingRowHeight: 40,
          dividerThickness: 1.0,
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: <DataColumn>[
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Phôi vào',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng in',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng sóng',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'SL Đạt',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Center(child: Text('${(item.slInTt.toString().trim() == 'null' ? 0 : item.slInTt.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slInHong.toString().trim() == 'null' ? 0 : item.slInHong.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slInSong.toString().trim() == 'null' ? 0 : item.slInSong.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slInDat.toString().trim() == 'null' ? 0 : item.slInDat.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
              ],
            ),
          ],
        ),
      )
          :
      widget.idStage == 3
          ?
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  DataTable(
          headingRowHeight: 40,
          dividerThickness: 1.0,
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: <DataColumn>[
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Phôi vào',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng in',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng sóng',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng bế xẻ',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'SL Đạt',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Center(child: Text('${(item.slCbTt.toString().trim() == 'null' ? 0 : item.slCbTt.toString())}' ,style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slCbIn.toString().trim() == 'null' ? 0 : item.slCbIn.toString())}' ,style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slCbSong.toString().trim() == 'null' ? 0 : item.slCbSong.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slCbBx.toString().trim() == 'null' ? 0 : item.slCbBx.toString())}' ,style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slCbDat.toString().trim() == 'null' ? 0 : item.slCbDat.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
              ],
            ),
          ],
        ),
      )
          :
      widget.idStage == 4
          ?
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  DataTable(
          headingRowHeight: 40,
          dividerThickness: 1.0,
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: <DataColumn>[
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Phôi vào',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng in',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng sóng',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng bế xẻ',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'SL Đạt',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Center(child: Text('${(item.slLvTt.toString().trim() == 'null' ? 0 : item.slLvTt.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slLvIn.toString().trim() == 'null' ? 0 : item.slLvIn.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slLvSong.toString().trim() == 'null' ? 0 : item.slLvSong.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slLvBx.toString().trim() == 'null' ? 0 : item.slLvBx.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slLvDat.toString().trim() == 'null' ? 0 : item.slLvDat.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
              ],
            ),
          ],
        ),
      )
          :
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  DataTable(
          headingRowHeight: 40,
          dividerThickness: 1.0,
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: <DataColumn>[
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Phôi vào',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng in',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng chế biến',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Hỏng hoàn thiện',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'SL Đạt',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const DataColumn(
              label: VerticalDivider(),
            ),
            DataColumn(
              label: SizedBox(
                width: width * .2,
                child: const Center(
                  child: Text(
                    'Kho',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Center(child: Text('${(item.slHtTt.toString().trim() == 'null' ? 0 : item.slHtTt.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slHtIn.toString().trim() == 'null' ? 0 : item.slHtIn.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slHtCb.toString().trim() == 'null' ? 0 : item.slHtCb.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slHtHt.toString().trim() == 'null' ? 0 : item.slHtHt.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(Center(child: Text('${(item.slHtDat.toString().trim() == 'null' ? 0 : item.slHtDat.toString())}',style: const TextStyle(fontSize: 11,color: Colors.grey),))),
                const DataCell(VerticalDivider()),
                DataCell(PopupMenuButton(
                    padding: EdgeInsets.zero,
                    offset: const Offset(4, 30),
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<Widget>>[
                        PopupMenuItem<Widget>(
                          child: Container(
                            decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            height: 300,
                            width: 550,
                            child: Scrollbar(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(top: 10),
                                itemCount: _bloc.listStore.length,
                                itemBuilder: (context, index) {
                                  final trans = _bloc.listStore[index].tenKho;
                                  return ListTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            trans.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),Text(
                                          _bloc.listStore[index].maKho.toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: const Divider(height: 1,),
                                    onTap: () {
                                      _bloc.add(ChooseStore(idStore: _bloc.listStore[index].maKho.toString(),nameStore: _bloc.listStore[index].tenKho.toString()));
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ];
                    },
                    child: Center(child: Text(_bloc.nameStore??'....',style: const TextStyle(fontSize: 11,color: Colors.grey),)))),
              ],
            ),
          ],
        ),
      )
      ,
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
          Expanded(
            child: Center(
              child: Text(
                'Chi tiết ${widget.nameStage.toString().trim()}',
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          Visibility(
            visible: Const.allowedConfirm == true,
            child: InkWell(
              onTap: (){
                if(_listDetailStage.isNotEmpty){
                  showDialog(
                      context: context,
                      builder: (context) {
                        return WillPopScope(
                          onWillPop: () async => false,
                          child: const CustomConfirm(
                            title: 'Xác nhận lệnh sản xuất!',
                            content: 'Vui lòng chọn ngày tạo phiếu',
                            type: 0,
                          ),
                        );
                      }).then((value) {
                    if(!Utils.isEmpty(value) && value[0] == 'confirm'){
                      if(!Utils.isEmpty(value[1])){
                        _bloc.dateOrder = Utils.parseStringToDate(value[1], Const.DATE_FORMAT_2);
                      }else{
                        _bloc.dateOrder = Utils.parseStringToDate(DateFormat('yyyy-MM-dd').format(DateTime.now()), Const.DATE_FORMAT_2);
                      }
                      _bloc.add(CreateTKCD(sttRec: widget.sttRec.toString(),idStage: widget.idStage!,listDetailStage: _listDetailStage,takeNote: value[2]));
                    }
                  });
                }
                else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn chưa cập nhật MVT nào vào phiếu kìa.');
                }
              },
              child: const SizedBox(
                height: 45,
                width: 50,
                child: Icon(Icons.how_to_reg,color: Colors.white,),
              ),
            ),
          ),
          Visibility(
            visible: Const.allowedConfirm == false,
            child: const SizedBox(
              height: 45,
              width: 50,
              child: Icon(Icons.how_to_reg,color: Colors.transparent,),
            ),
          )
        ],
      ),
    );
  }

  buildBody(BuildContext context,DetailStageStatisticState state){
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
                _bloc.add(GetStoreList(idStage: widget.idStage!));
              },
              child: Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.grey.withOpacity(.1),
                padding: const EdgeInsets.only(left: 8,right: 8,top: 10,bottom: 60),
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemCount: _bloc.listDetailStage.length,
                    itemBuilder: (BuildContext context, int index){
                      return GestureDetector(
                        onTap: (){
                          showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) {
                                return UpdateStageQuantityPopup(title: 'Cập nhật số lượng thực',mvt: _bloc.listDetailStage[index].maVt.toString(),
                                  idStage: widget.idStage!,
                                  item: _bloc.listDetailStage[index],
                                );
                              }).then((value){
                            if(value != null){
                              _bloc.listDetailStage.forEach((element) {
                                if(element.maVt.toString().trim() == _bloc.listDetailStage[index].maVt.toString().trim()){
                                  if(widget.idStage == 1){
                                    setState(() {
                                      _bloc.listDetailStage[index].slSongTt = double.parse(value[0]);
                                      _bloc.listDetailStage[index].slSongCp = double.parse(value[1]);
                                      _bloc.listDetailStage[index].slSongDat = double.parse(value[2]);
                                      _bloc.listDetailStage[index].maKho = _bloc.idStore;
                                    });
                                  }
                                  else if(widget.idStage == 2){
                                    setState(() {
                                      _bloc.listDetailStage[index].slInTt = double.parse(value[0]);
                                      _bloc.listDetailStage[index].slInHong = double.parse(value[1]);
                                      _bloc.listDetailStage[index].slInSong = double.parse(value[2]);
                                      _bloc.listDetailStage[index].slInDat = double.parse(value[3]);
                                    });
                                  }
                                  else if(widget.idStage == 3){
                                    setState(() {
                                      _bloc.listDetailStage[index].slCbTt = double.parse(value[0]);
                                      _bloc.listDetailStage[index].slCbIn = double.parse(value[1]);
                                      _bloc.listDetailStage[index].slCbSong = double.parse(value[2]);
                                      _bloc.listDetailStage[index].slCbBx = double.parse(value[3]);
                                      _bloc.listDetailStage[index].slCbDat = double.parse(value[4]);
                                    });
                                  }
                                  else if(widget.idStage == 4){
                                    setState(() {
                                      _bloc.listDetailStage[index].slLvTt = double.parse(value[0]);
                                      _bloc.listDetailStage[index].slLvIn = double.parse(value[1]);
                                      _bloc.listDetailStage[index].slLvSong = double.parse(value[2]);
                                      _bloc.listDetailStage[index].slLvBx = double.parse(value[3]);
                                      _bloc.listDetailStage[index].slLvDat = double.parse(value[4]);
                                    });
                                  }
                                  else if(widget.idStage == 5){
                                    setState(() {
                                      _bloc.listDetailStage[index].slHtTt = double.parse(value[0]);
                                      _bloc.listDetailStage[index].slHtIn = double.parse(value[1]);
                                      _bloc.listDetailStage[index].slHtCb = double.parse(value[2]);
                                      _bloc.listDetailStage[index].slHtHt = double.parse(value[3]);
                                      _bloc.listDetailStage[index].slHtDat = double.parse(value[4]);
                                      _bloc.listDetailStage[index].maKho = _bloc.idStore;
                                    });
                                  }
                                }
                              });

                              if(widget.idStage == 1){
                                if(double.parse(value[0]) == 0 && double.parse(value[1]) == 0 && double.parse(value[2]) == 0 && _listDetailStage.length > 0){
                                  _listDetailStage.removeWhere((item) => item.maVt.toString().trim() == _bloc.listDetailStage[index].maVt.toString().trim());
                                }else{
                                  _listDetailStage.removeWhere((item) => item.maVt.toString().trim() == _bloc.listDetailStage[index].maVt.toString().trim());
                                  _listDetailStage.add(_bloc.listDetailStage[index]);
                                }
                              }
                              else if(widget.idStage == 2){
                                if(double.parse(value[0]) == 0 && double.parse(value[1]) == 0 && double.parse(value[2]) == 0 && double.parse(value[3])==0 && _listDetailStage.length > 0){
                                  _listDetailStage.removeWhere((item) => item.maVt.toString().trim() == _bloc.listDetailStage[index].maVt.toString().trim());
                                }else{
                                  _listDetailStage.removeWhere((item) => item.maVt.toString().trim() == _bloc.listDetailStage[index].maVt.toString().trim());
                                  _listDetailStage.add(_bloc.listDetailStage[index]);
                                }
                              }
                              else if(widget.idStage == 5 || widget.idStage == 4 || widget.idStage == 3){
                                if(double.parse(value[0]) == 0 && double.parse(value[1]) == 0 && double.parse(value[2]) == 0 && double.parse(value[3]) == 0 && double.parse(value[4]) == 0 && _listDetailStage.length > 0){
                                  _listDetailStage.removeWhere((item) => item.maVt.toString().trim() == _bloc.listDetailStage[index].maVt.toString().trim());
                                }else{
                                  _listDetailStage.removeWhere((item) => item.maVt.toString().trim() == _bloc.listDetailStage[index].maVt.toString().trim());
                                  _listDetailStage.add(_bloc.listDetailStage[index]);
                                }
                              }
                            }
                          });
                        },
                        child: Card(
                          elevation: 10,
                          shadowColor: Colors.blueGrey.withOpacity(0.5),
                          child: Container(
                            height: 170,width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.code,color: Colors.grey,size: 12,),
                                      const SizedBox(width: 5,),
                                      Text('Code: ${_bloc.listDetailStage[index].maVt.toString().trim()}', style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.bold),),
                                    ],),
                                    Visibility(
                                      visible: widget.idStage == 2,
                                      child: Text('Số lệnh sx: ${_bloc.listDetailStage[index].soLsx.toString().trim()}', style: const TextStyle(color: Colors.black,fontSize: 12),),),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  children: [
                                    const Icon(Icons.drive_file_rename_outline,color: Colors.grey,size: 12,),
                                    const SizedBox(width: 5,),
                                    Flexible(child: Text('${_bloc.listDetailStage[index].tenVt.toString()}', style: const TextStyle(color: Colors.black,fontSize: 12),maxLines: 1,overflow: TextOverflow.visible,)),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  children: [
                                    const Icon(Icons.equalizer,color: Colors.grey,size: 12,),
                                    const SizedBox(width: 5,),
                                    Text('SL đơn hàng: ${_bloc.listDetailStage[index].soLuongDonHang?.toInt().toString()}', style: const TextStyle(color: Colors.black,fontSize: 12),),
                                  ],
                                ),

                                const Divider(),
                                buildStage(_bloc.listDetailStage[index])
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
