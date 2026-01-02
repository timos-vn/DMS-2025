// ignore_for_file: library_private_types_in_public_api

import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../custom_lib/view_only_image.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/images.dart';
import '../../options_input/options_input_screen.dart';
import '../dms_bloc.dart';
import '../dms_event.dart';
import '../dms_state.dart';
import 'add_new_request_open_store.dart';


class RequestOpenStoreScreen extends StatefulWidget {
  const RequestOpenStoreScreen({Key? key}) : super(key: key);

  @override
  _RequestOpenStoreScreenState createState() => _RequestOpenStoreScreenState();
}

class _RequestOpenStoreScreenState extends State<RequestOpenStoreScreen> {

  late DMSBloc _bloc;

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  String valuesDate = Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2);

  String dateFrom = Utils.parseDateToString(DateTime.now().add(const Duration(days: -7)), Const.DATE_SV_FORMAT_2);
  String dateTo = Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = DMSBloc(context);
    _bloc.add(GetPrefsDMSEvent());
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListRequestOpenStore(isLoadMore:true,dateTime:valuesDate.toString(),status: _bloc.status, dateFrom:dateFrom.toString(),
          dateTo: dateTo,));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 55),
        child: FloatingActionButton(
          backgroundColor: subColor,
          onPressed: ()async{
            PersistentNavBarNavigator.pushNewScreen(context, screen: const AddNewRequestOpenStoreScreen(),withNavBar: false).then((value) {
              if(value == 'RELOAD'){
                if(_bloc.listDataRequest.isNotEmpty){
                  _bloc.listDataRequest.clear();
                }
                _bloc.add(GetListRequestOpenStore(dateTime:valuesDate.toString(),status: _bloc.status, dateFrom:dateFrom.toString(),
                  dateTo: dateTo,));
              }
            });
          },
          child: const Icon(Icons.addchart_outlined,color: Colors.white,),
        ),
      ),
      body: BlocListener<DMSBloc,DMSState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetListRequestOpenStore(dateTime:valuesDate.toString(),status: _bloc.status, dateFrom:dateFrom.toString(),
              dateTo: dateTo,));
          }
        },
        child: BlocBuilder<DMSBloc,DMSState>(
          bloc: _bloc,
          builder: (BuildContext context, DMSState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetListRequestOpenStoreEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is DMSLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,DMSState state){
    int length = _bloc.listDataRequest.length;
    if (state is GetListRequestOpenStoreSuccess) {
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
                _bloc.listDataRequest.clear();
                _bloc.add(GetListRequestOpenStore(
                    dateTime:valuesDate.toString(),status: _bloc.status,
                  dateFrom:dateFrom.toString(),
                  dateTo: dateTo,
                ));
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
                       Text('Danh sách Open ngày $valuesDate',style: const TextStyle(color:Colors.blueGrey,fontSize: 12),),
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
                            GestureDetector(
                              onTap: ()=> PersistentNavBarNavigator.pushNewScreen(context, screen: AddNewRequestOpenStoreScreen(
                                idRequestOpenStore: _bloc.listDataRequest[index].master!.keyValue.toString(),
                                isEdit: true,
                                existingImageUrls: _bloc.listDataRequest[index].imageListRequestOpenStore?.map((e) => e.pathL ?? '').where((e) => e.isNotEmpty).toList(),
                              ),withNavBar: false).then((value){
                                if(value == 'RELOAD'){
                                  if(_bloc.listDataRequest.isNotEmpty){
                                    _bloc.listDataRequest.clear();
                                  }
                                  _bloc.add(GetListRequestOpenStore(
                                    dateFrom:dateFrom.toString(),
                                    dateTo: dateTo,
                                      dateTime:valuesDate.toString(),status: _bloc.status,
                                  ));
                                }
                              }),
                              child: Card(
                                semanticContainer: true,
                                margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          SizedBox(
                                            width: 40,height: 40,
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(22)),
                                              child: Hero(
                                                  tag: index,
                                                  /*semanticContainer: true,
                                              margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),*/
                                                  child: Image.asset(avatarRequest,
                                                    fit: BoxFit.cover,
                                                    height: 40,
                                                  )
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 10,right: 3,top: 5,bottom: 5),
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${_bloc.listDataRequest[index].master?.tenCh}',
                                                          textAlign: TextAlign.left,
                                                          style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 13),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Text(
                                                        _bloc.listDataRequest[index].master?.trangThai == 1 ? 'Chưa xử lý' : 'Đã xử lý',
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(color:  Color(0xff358032), fontSize: 12,),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.account_circle_outlined,color: subColor,size: 15,),
                                                          const SizedBox(width: 5,),
                                                          Text(
                                                            '${_bloc.listDataRequest[index].master?.tenKh}',
                                                            textAlign: TextAlign.left,
                                                            style: const TextStyle(color: grey, fontSize: 11,),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        '${_bloc.listDataRequest[index].master?.dienThoai}',
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(color: grey, fontSize: 11,),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Row(
                                                    children: [
                                                      Icon(MdiIcons.mapMarkerRadiusOutline,color: subColor,size: 15,),
                                                      const SizedBox(width: 5,),
                                                      Flexible(
                                                        child: Text(
                                                          _bloc.listDataRequest[index].master?.diaChi != '' ? _bloc.listDataRequest[index].master!.diaChi.toString() : 'Đang cập nhật',
                                                          textAlign: TextAlign.left,
                                                          style: const TextStyle(color: grey, fontSize: 11,),maxLines: 2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        children: [
                                          const Icon(Icons.date_range,color: subColor,size: 15,),
                                          const SizedBox(width: 5,),
                                          Text(
                                            _bloc.listDataRequest[index].master?.ngayTao != null ? Utils.parseDateTToString(_bloc.listDataRequest[index].master!.ngayTao.toString(), Const.DATE_TIME_FORMAT_LOCAL).toString() : 'Đang cập nhật',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(color: grey, fontSize: 11,),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Text(
                                        'Ghi chú:  ${_bloc.listDataRequest[index].master?.ghiChu}',
                                        textAlign: TextAlign.left,
                                        style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
                                      ),
                                      Visibility(
                                         visible: _bloc.listDataRequest[index].imageListRequestOpenStore!.isNotEmpty,
                                         child:  Padding(
                                           padding: const EdgeInsets.only(top: 8),
                                           child: SizedBox(
                                             height: 120,
                                             width: double.infinity,
                                             child: Padding(
                                               padding: const EdgeInsets.only(bottom: 8),
                                               child: ListView.builder(
                                                   padding: EdgeInsets.zero,
                                                   shrinkWrap: true,
                                                   scrollDirection: Axis.horizontal,
                                                   itemCount:  _bloc.listDataRequest[index].imageListRequestOpenStore!.length,
                                                   itemBuilder: (context,index2){
                                                     return  GestureDetector(
                                                       onTap: (){
                                                         openImageFullScreen(index2,_bloc.listDataRequest[index].imageListRequestOpenStore![index2].pathL.toString());
                                                       },
                                                       child: Padding(
                                                         padding: const EdgeInsets.only(left: 10.0),
                                                         child: Stack(
                                                           children: [
                                                             SizedBox(
                                                               width: 115,
                                                               child: ClipRRect(
                                                                 borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                                 child: Hero(
                                                                   tag: "#$index-$index2",
                                                                   /*semanticContainer: true,
                                            margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),*/
                                                                   child: Image.network(
                                                                     _bloc.listDataRequest[index].imageListRequestOpenStore![index2].pathL.toString(),
                                                                     fit: BoxFit.cover,
                                                                     cacheHeight: 150,cacheWidth: 150,
                                                                   ),
                                                                 ),
                                                               ),
                                                             ),
                                                           ],
                                                         ),
                                                       ),
                                                     );
                                                   }

                                               ),
                                             ),
                                           ),
                                         ),
                                       ),
                                       // Visibility(
                                       //   visible: _bloc.listDataRequest[index].imageListRequestOpenStore!.isNotEmpty,
                                       //   child: GalleryImage(
                                       //     titleGallery: 'Zoom Image',
                                       //    numOfShowImages: _bloc.listDataRequest[index].imageListRequestOpenStore!.length < 3 ? 0 : 3,
                                       //    imageUrls: _bloc.listDataRequest[index].imageListRequestOpenStore!.map((e) => e.pathL!).toList(),),
                                       // ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: _bloc.listDataRequest.length //length == 0 ? length : _hasReachedMax ? length : length + 1,
                      ),
                    ),
                    const SizedBox(height: 55,)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void openImageFullScreen(final int indexOfImage, String pathImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageViewWrapperViewOnly(
          titleGallery: "Zoom Image",
          viewNetWorkImage: true,
          backgroundDecoration: const BoxDecoration(
            color: Colors.white,
          ),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal, galleryItemsNetWork: pathImage,
        ),
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
                "KH đề xuất mở điểm",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: ()=>showDialog(
                context: context,
                builder: (context) => OptionsFilterDate(dateFrom: dateFrom.toString(),dateTo: dateTo.toString())).then((value){
              if(value != null){
                if(value[1] != null && value[2] != null){
                  dateFrom = value[3];
                  dateTo = value[4];
                  if(_bloc.listDataRequest.isNotEmpty){
                    _bloc.listDataRequest.clear();
                  }
                  _bloc.add(GetListRequestOpenStore(dateTime:valuesDate.toString(),status: _bloc.status,
                    dateFrom:dateFrom.toString(),
                    dateTo: dateTo,
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
