// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:dms/custom_lib/image_file/gallery_image_file.dart';
import 'package:dms/model/entity/item_check_in.dart';
import 'package:dms/screen/dms/check_in/ticket/ticket_event.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/widget/custom_dropdown.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/custom_widget.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../custom_lib/view_only_image.dart';
import '../../../../model/network/response/detail_checkin_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/images.dart';
import '../../../../utils/utils.dart';
import '../component/add_new_ticket.dart';
import 'ticket_bloc.dart';
import 'ticket_state.dart';

class TicketScreen extends StatefulWidget {
  final bool isCheckInSuccess;
  final bool view;
  final bool isSynSuccess;
  final int idCheckIn;
  final String idCustomer;
  final List<ListAlbumTicketOffLine> listAlbumTicketOffLine;

  const TicketScreen({Key? key,required this.isCheckInSuccess ,required this.idCheckIn, required this.idCustomer, required this.listAlbumTicketOffLine,required this.view, required this.isSynSuccess}) : super(key: key);

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {

  late TicketBloc _bloc;

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  final bool _hasReachedMax = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.listAlbumTicketOffLine.length);
    _scrollController = ScrollController();
    _bloc = TicketBloc(context);
    _bloc.add(GetPrefsTicket());
    // _scrollController.addListener(() {
    //   final maxScroll = _scrollController.position.maxScrollExtent;
    //   final currentScroll = _scrollController.position.pixels;
    //   if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
    //     _bloc.add(GetListTicket(isLoadMore:true,idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idTypeTicket: _bloc.idTicket));
    //   }
    // });
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketBloc,TicketState>(
      bloc: _bloc,
      listener: (context,state){
        if(state is GetPrefsSuccess){
          if(widget.listAlbumTicketOffLine.isNotEmpty){
            _bloc.idTicket = widget.listAlbumTicketOffLine[0].maTicket!.toString().trim();
            _bloc.nameTicket = widget.listAlbumTicketOffLine[0].tenTicket!.toString().trim();
          }

          if(widget.isCheckInSuccess == true){
            _bloc.add(GetListTicket(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idTypeTicket: _bloc.idTicket));
          }else{
            _bloc.add(GetListTicketLocal());
          }
          // if(Const.ticketCheckIn == true){
          //   if(_bloc.listTicket.isNotEmpty){
          //     _bloc.listTicket.clear();
          //   }
          //   if(widget.listTicket.isNotEmpty){
          //     _bloc.idTicket = widget.listTicket[0].maTicket!.toString().trim();
          //     _bloc.nameTicket = widget.listTicket[0].tenTicket!.toString().trim();
          //     _bloc.add(GetListTicket(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idTypeTicket: _bloc.idTicket));
          //   }else{
          //     _bloc.add(GetListTicket(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idTypeTicket: _bloc.idTicket));
          //   }
          // }
        }
        else if(state is GetListTicketOffLineSuccess){
          if(state.listTicketOffLine.isNotEmpty){
            // print(_bloc.listTicketOffLine.length);
            // DataLocal.listTicketLocal.clear();
            _bloc.listTicketOffLine.clear();
            for (var element in state.listTicketOffLine) {
              // print((widget.idCheckIn.toString().trim() + widget.idCustomer.toString().trim()));
              // print(element.id);
              // print(identical(element.id.toString().trim(),(widget.idCheckIn.toString().trim() + widget.idCustomer.toString().trim())));
              // print(element.id.toString().trim() == (widget.idCheckIn.toString().trim() + widget.idCustomer.toString().trim()).toString());
              if(element.id == (widget.idCheckIn.toString().trim() + widget.idCustomer.toString().trim())){
                ItemListTicketOffLine item = ItemListTicketOffLine(
                    customerCode: element.customerCode,
                    idTicketType: element.idTicketType,
                    nameTicketType: element.nameTicketType,
                    id: element.id.toString(),
                    comment: element.comment,
                    filePath: element.filePath.toString(),
                    fileName: element.fileName,
                    dateTimeCreate: element.dateTimeCreate,
                    listFileTicket: (element.filePath != null && element.filePath != '') ?  element.filePath?.split(',') : [],
                    status: element.status
                );
                // DataLocal.listTicketLocal.add(item);
                _bloc.listTicketOffLine.add(item);
              }
            }
          }
          _bloc.add(PickAlbumTicket( idAlbumTicket: _bloc.idTicket,nameAlbumTicket: _bloc.nameTicket.toString(),idCheckIn: widget.idCheckIn.toString().trim() + widget.idCustomer.toString().trim()));
        }
        else if(state is DeleteTicketSuccess){
          Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Xoá hình ảnh thành công');
          if(widget.listAlbumTicketOffLine.isNotEmpty){
            _bloc.idTicket = widget.listAlbumTicketOffLine[0].maTicket!.toString().trim();
            _bloc.nameTicket = widget.listAlbumTicketOffLine[0].tenTicket!.toString().trim();
          }
          _bloc.add(GetListTicketLocal());
        }
        else if(state is UpdateTicketSuccess){
          // Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Cập nhật Ticket thành công');
          // if(widget.listAlbumTicketOffLine.isNotEmpty){
          //   _bloc.idTicket = widget.listAlbumTicketOffLine[0].maTicket!.toString().trim();
          //   _bloc.nameTicket = widget.listAlbumTicketOffLine[0].tenTicket!.toString().trim();
          // }
          // if(_bloc.listTicketOffLine.isNotEmpty){
          //   _bloc.listTicketOffLine.clear();
          // }
          // _bloc.add(GetListTicketLocal());
        }
      },
      child: BlocBuilder<TicketBloc,TicketState>(
        bloc: _bloc,
        builder: (BuildContext context, TicketState state){
          return  Column(
            children: [
              Visibility(
                visible: Const.ticketCheckIn == true,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 8, top: 12, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Ticket',
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),
                        ),
                      ),
                      Visibility(
                          visible: widget.listAlbumTicketOffLine.isEmpty,
                          child: const Text('Không có DS Ticket nào',style: TextStyle(color: Colors.blueGrey,fontSize: 12),)
                      ),
                      Visibility(
                          visible: widget.listAlbumTicketOffLine.isNotEmpty,
                          child: buildDropdownMenuTicket()
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  floatingActionButton: (widget.view == false && widget.isCheckInSuccess == false && Const.ticketCheckIn == true) ? FloatingActionButton(
                    backgroundColor: subColor,
                    onPressed: (){
                      PersistentNavBarNavigator.pushNewScreen(context, screen: AddNewTicketScreen(
                        idCustomer: widget.idCustomer,
                        idCheckIn: widget.idCheckIn.toString(),
                        idTicketType: _bloc.idTicket,
                        nameTicketType: _bloc.nameTicket,
                        addNew: true,
                        comment:  '',
                      ),withNavBar: false).then((value){
                        if(_bloc.listTicketOffLine.isNotEmpty){
                          _bloc.listTicketOffLine.clear();
                        }
                        Future.delayed(const Duration(seconds: 1)).whenComplete(() => _bloc.add(GetListTicketLocal()));
                        // _bloc.add(GetListTicket(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idTypeTicket: _bloc.idTicket));
                      });
                    },
                    child: const Icon(Icons.post_add,color: Colors.white,),
                  ) : Container(),
                  body: Stack(
                    children: [
                      buildBody(context,state),
                      Visibility(
                        visible: state is TicketLoading,
                        child: const PendingAction(),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  buildBody(BuildContext context,TicketState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Const.ticketCheckIn == true
          ?
      (widget.isCheckInSuccess == true) ?
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding:const EdgeInsets.symmetric(horizontal: 5),
                  child: Text('Danh sách ticket của Cửa Hàng (${_bloc.listTicket.length})',style:const TextStyle(color: Colors.blueGrey,fontSize: 10)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _bloc.listTicket.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Card(
                  semanticContainer: true,
                  margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                    child: Column(
                      children: [
                        Row(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Tên nv: ${_bloc.listTicket[index].tenNv.toString().trim()}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 13),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Text(
                                          _bloc.listTicket[index].status == '0' ? 'Chưa xử lý' : 'Đã xử lý',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(color:  Color(0xff358032), fontSize: 12,),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text(
                                          'Thời gian tạo: ${_bloc.listTicket[index].thoiGian != null ?
                                          // DateFormat("yyyy-MM-dd' 'HH:mm:ss.SSSSSS'Z").parse(_bloc.listTicketOffLine[index].dateTimeCreate!.toString()) : 'Thời gian đang cập nhật'}',
                                          Utils.parseStringToDate(_bloc.listTicket[index].thoiGian!.toString(), Const.DATE_TIME_FORMAT).toString().split('.')[0] : 'Thời gian đang cập nhật'}',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(color: grey, fontSize: 11,),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5,),
                                    Text(
                                      'Nội dung: ${_bloc.listTicket[index].noiDung.toString().trim()}',
                                      textAlign: TextAlign.left,
                                      style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: _bloc.listTicket[index].imageList!.isNotEmpty,
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
                                    itemCount:  _bloc.listTicket[index].imageList!.length,
                                    itemBuilder: (context,index2){
                                      return  GestureDetector(
                                        onTap: (){
                                          openImageFullScreen(index2,_bloc.listTicket[index].imageList![index2].pathL.toString());
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
                                                      _bloc.listTicket[index].imageList![index2].pathL.toString(),
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
                        // ignore: unrelated_type_equality_checks
                        // _bloc.listTicket[index].imageList != '' ? GalleryImageLocalNetWork(
                        //   titleGallery: 'Zoom Image',
                        //   numOfShowImages: _bloc.listTicket[index].imageList!.length < 3 ? 0 : 3,
                        //   imageUrls: _bloc.listTicket[index].imageList!.toList(growable: true)) : Container(),
                      ],
                    ),
                  ),
                );
              },
            ),),
          Visibility(
            visible: _bloc.listTicket.isEmpty,
            child: const Expanded(
              child: Center(
                child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
              ),
            ),
          ),
        ],
      )
          :
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding:const EdgeInsets.symmetric(horizontal: 5),
                  child: Text('Danh sách ticket của Cửa Hàng (${_bloc.listTicketOffLine.length})',style:const TextStyle(color: Colors.blueGrey,fontSize: 10)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _bloc.listTicketOffLine.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){
                    showBottomSheet(index);
                    // pushNewScreen(context, screen: AddNewTicketScreen(
                    //   idCustomer: widget.idCustomer,
                    //   idCheckIn: widget.idCheckIn.toString(),
                    //   idTicketType: _bloc.idTicket,
                    //   nameTicketType: _bloc.nameTicket,
                    // ),withNavBar: false).then((value){
                    //   if(_bloc.listTicketOffLine.isNotEmpty){
                    //     _bloc.listTicketOffLine.clear();
                    //   }
                    //   Future.delayed(const Duration(seconds: 1)).whenComplete(() => _bloc.add(GetListTicketLocal()));
                    //   // _bloc.add(GetListTicket(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idTypeTicket: _bloc.idTicket));
                    // });
                  },
                  child: Card(
                    semanticContainer: true,
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                      child: Column(
                        children: [
                          Row(
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Tên nv: ${_bloc.userName}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 13),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 10,),
                                          Text(
                                            _bloc.listTicketOffLine[index].status == '0' ? 'Chưa xử lý' : 'Đã xử lý',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(color:  Color(0xff358032), fontSize: 12,),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        children: [
                                          Text(
                                            'Thời gian tạo: ${_bloc.listTicketOffLine[index].dateTimeCreate != null ?
                                      // DateFormat("yyyy-MM-dd' 'HH:mm:ss.SSSSSS'Z").parse(_bloc.listTicketOffLine[index].dateTimeCreate!.toString()) : 'Thời gian đang cập nhật'}',
                                            Utils.parseStringToDate(_bloc.listTicketOffLine[index].dateTimeCreate!.toString(), Const.DATE_TIME_FORMAT).toString().split('.')[0] : 'Thời gian đang cập nhật'}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(color: grey, fontSize: 11,),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Text(
                                        'Nội dung: ${_bloc.listTicketOffLine[index].comment}',
                                        textAlign: TextAlign.left,
                                        style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // ignore: unrelated_type_equality_checks
                          _bloc.listTicketOffLine[index].filePath != '' ? GalleryImageLocalFile(
                            titleGallery: 'Zoom Image',
                           numOfShowImages: _bloc.listTicketOffLine[index].filePath!.split(',').length < 3 ? 0 : 3,
                           imageUrls: _bloc.listTicketOffLine[index].filePath!.split(',').map((e) =>File(e)).toList(),) : Container(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),),
          Visibility(
            visible: _bloc.listTicketOffLine.isEmpty,
            child: const Expanded(
              child: Center(
                child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
              ),
            ),
          ),
        ],
      )
          :
      lockModule(),
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

  buildDropdownMenuTicket(){
    return PopupMenuButton(
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
              width: 200,
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10,),
                  itemCount: widget.listAlbumTicketOffLine.length,
                  itemBuilder: (context, index) {
                    final trans = widget.listAlbumTicketOffLine[index].tenTicket.toString().trim();
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
                            widget.listAlbumTicketOffLine[index].maTicket.toString().trim(),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      subtitle:const Divider(height: 1,),
                      onTap: () {
                        _bloc.idTicket = widget.listAlbumTicketOffLine[index].maTicket.toString().trim();
                        _bloc.nameTicket = widget.listAlbumTicketOffLine[index].tenTicket.toString();
                        if((widget.isCheckInSuccess == true )){ //&& widget.isSynSuccess == true
                          _bloc.add(GetListTicket(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idTypeTicket: _bloc.idTicket));
                        }
                        else{
                          _bloc.add(PickAlbumTicket( idAlbumTicket: widget.listAlbumTicketOffLine[index].maTicket.toString().trim(),nameAlbumTicket: widget.listAlbumTicketOffLine[index].tenTicket.toString(),idCheckIn: widget.idCheckIn.toString().trim() + widget.idCustomer.toString().trim()));
                        }
                        //_bloc.add(GetListTicket(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idTypeTicket: widget.listTicket[index].maTicket.toString()));
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
      child: Row(
        children: [
          Text(_bloc.nameTicket.toString(),style: const TextStyle(color: Colors.blueGrey,fontSize: 12,fontWeight: FontWeight.w600),),
          const SizedBox(width: 5,),
          const Icon(Icons.arrow_drop_down_outlined,color: Colors.blueGrey,),
        ],
      ),
    );
  }

  void showBottomSheet(int index){
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
            height: MediaQuery.of(context).copyWith().size.height * 0.32,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25)
                )
            ),
            margin: MediaQuery.of(context).viewInsets,
            child: StatefulBuilder(
              builder: (BuildContext context,StateSetter myState){
                return Padding(
                  padding: const EdgeInsets.only(top: 10,bottom: 0),
                  child: Container(
                    decoration:const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25)
                        )
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0,left: 8,right: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: ()=> Navigator.pop(context),
                                  child: const Icon(Icons.close,color: Colors.white,)),
                              const Text('Thêm tuỳ chọn',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                              InkWell(
                                  onTap: ()=> Navigator.pop(context),
                                  child: Icon(Icons.clear,color: mainColor,)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5,),
                        const Divider(color: Colors.blueGrey,),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  // color: Colors.blueGrey,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10,top: 12),
                                      child: InkWell(
                                        onTap:()=>Navigator.pop(context,'1'),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            side: BorderSide(color: Colors.blueGrey.withOpacity(0.1), width: 0.5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: const [
                                                Text('Xoá ticket',style: TextStyle(color: Colors.black),),
                                                Icon(Icons.delete_forever,color: subColor,)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10,top: 10),
                                      child: InkWell(
                                        onTap:()=>Navigator.pop(context,'2'),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            side: BorderSide(color: Colors.blueGrey.withOpacity(0.1), width: 0.5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: const [
                                                Text('Sửa ticket',style: TextStyle(color: Colors.black),),
                                                Icon(Icons.view_carousel_outlined,color: subColor,)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
    ).then((value)async{
      if(value != null){
        switch (value){
          case '1':
            showDialog(
                context: context,
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: const CustomQuestionComponent(
                      showTwoButton: true,
                      iconData: Icons.delete_forever_outlined,
                      title: 'Bạn muốn xoá ticket này?',
                      content: 'Hãy chắc chắn bạn muốn điều này?',
                    ),
                  );
                }).then((value)async{
              if(value != null){
                if(!Utils.isEmpty(value) && value == 'Yeah'){
                  _bloc.add(DeleteOrUpdateTicketEvent(
                    customerCode: widget.idCustomer.toString(),
                      idIncrement: _bloc.listTicketOffLine[index].idIncrement!.toInt(),
                    idTicketType: _bloc.listTicketOffLine[index].idTicketType.toString(),
                    nameTicketType: _bloc.listTicketOffLine[index].nameTicketType.toString(),
                    idCheckIn: widget.idCheckIn,
                    comment: _bloc.listTicketOffLine[index].comment.toString(),
                    filePath: _bloc.listTicketOffLine[index].filePath.toString(),
                    deleteAction: true
                  ));
                }
              }
            });

            break;
          case '2':
            PersistentNavBarNavigator.pushNewScreen(context, screen: AddNewTicketScreen(
              idCustomer: widget.idCustomer,
              idCheckIn: widget.idCheckIn.toString(),
              idTicketType: _bloc.idTicket,
              nameTicketType: _bloc.nameTicket,
              addNew: false,
              itemListTicketOffLine:  _bloc.listTicketOffLine[index],
              comment:  _bloc.listTicketOffLine[index].comment.toString(),
            ),withNavBar: false).then((value){
              if(_bloc.listTicketOffLine.isNotEmpty){
                _bloc.listTicketOffLine.clear();
              }
              Future.delayed(const Duration(seconds: 1)).whenComplete(() => _bloc.add(GetListTicketLocal()));
              // _bloc.add(GetListTicket(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idTypeTicket: _bloc.idTicket));
            });
            break;
        }
      }
    });
  }
}
