// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:dms/model/entity/image_check_in.dart';
import 'package:dms/screen/dms/check_in/album/album_event.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/custom_dropdown.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/custom_widget.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../model/database/data_local.dart';
import '../../../../model/network/response/list_image_store_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/utils.dart';
import '../../../menu/component/view_files.dart';
import 'album_bloc.dart';
import 'album_state.dart';



class AlbumImageScreen extends StatefulWidget {
  final bool view;
  final int idCheckIn;
  final String idCustomer;
  final bool isCheckInSuccess;
  final bool isSynSuccess;

  const AlbumImageScreen({Key? key,required this.view,  required this.idCheckIn, required this.idCustomer, required this.isCheckInSuccess, required this.isSynSuccess}) : super(key: key);

  @override
  AlbumImageScreenState createState() => AlbumImageScreenState();
}

class AlbumImageScreenState extends State<AlbumImageScreen>with WidgetsBindingObserver  {

  CameraController? _controller;
  bool _isCameraInitialized = false;
  late final List<CameraDescription> _cameras;


  Future<void> initCamera() async {
    _cameras = await availableCameras();
    // Initialize the camera with the first camera in the list
    await onNewCameraSelected(_cameras.first);
  }

  Future<void> onNewCameraSelected(CameraDescription description) async {
    final previousCameraController = _controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }
    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  late AlbumBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;
  late Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  int start = 2;

  bool waitingLoad = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {
          waitingLoad = false;
          setState(() {});
          timer.cancel();
        } else {
          start--;
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _bloc = AlbumBloc(context);
    if(DataLocal.listItemAlbum.isNotEmpty){
      _bloc.listAlbum = DataLocal.listItemAlbum;
    }
    _bloc.add(GetPrefsAlbum());

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListImageStore(isLoadMore:true,idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString()));
      }
    });
  }

  // final imagePicker = ImagePicker();

  Future getImage()async {
    // final image = await imagePicker.pickImage(source: ImageSource.camera,imageQuality: 80,maxWidth: 1920,maxHeight: 1080);

    PersistentNavBarNavigator.pushNewScreen(context, screen: const CameraCustomUI()).then((value){
      if(value != null){
        XFile image = value;
        setState(() {
          if(Const.selectedAlbumLock == true){
            _bloc.idAlbum = 'DLDC';
            _bloc.nameAlbum = 'Đại lý đóng cửa';
          }
          if(image != null){
            start = 2;waitingLoad  = true;
            startTimer();
            ListImageFile itemFile = ListImageFile(
                id: (widget.idCheckIn.toString().trim() + widget.idCustomer.trim().trim()),
                fileImage: File(image.path),
                maAlbum: _bloc.idAlbum.trim(),
                tenAlbum: _bloc.nameAlbum,
                fileName: image.name,
                isSync: false
            );
            ImageCheckIn imageCheckIn = ImageCheckIn(
                id: (widget.idCheckIn.toString().trim() + widget.idCustomer.trim().trim()),
                idCheckIn: widget.idCheckIn.toString(),
                maAlbum: _bloc.idAlbum.trim(),
                tenAlbum: _bloc.nameAlbum,
                fileName: image.name,
                filePath: image.path,
                isSync: 0
            );
            _bloc.add(AddImageLocalEvent(imageCheckInItem: imageCheckIn));
            DataLocal.listFileAlbum.add(itemFile);
            _bloc.listFileAlbumView.add(itemFile);
            if(_bloc.idAlbum.contains("DLDC") || _bloc.nameAlbum.contains('Đóng cửa') ){
              DataLocal.addImageToAlbumRequest = true;
            }
            if(Const.selectedAlbumLock == true){
              _bloc.listFileAlbumCloseStoreView.add(itemFile);
            }else{

            }
            DataLocal.latLongLocation = '';
            if(DataLocal.latLongLocation.isEmpty){
              _bloc.getUserLocation();
            }
          }
        });
      }
    });

  }

  bool lockSelected = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlbumBloc,AlbumState>(
      bloc: _bloc,
      listener: (context,state){
        if(state is GetPrefsSuccess){
          if(Const.imageCheckIn == true){
            if(widget.isCheckInSuccess == true && widget.isSynSuccess == true){
              _bloc.idAlbum = DataLocal.listItemAlbum[0].maAlbum!.toString().trim();
              _bloc.nameAlbum = DataLocal.listItemAlbum[0].tenAlbum!.toString().trim();
              _bloc.add(GetListImageStore(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idAlbum: DataLocal.listItemAlbum[0].maAlbum.toString()));
            }
            else {
              _bloc.add(GetImageLocalEvent());
            }
          }
          if(DataLocal.listItemAlbum.isNotEmpty){
            // for (var element in widget.listAlbum) {
            //
            // }
          }
        }
        else if(state is GetImageCheckInLocalSuccess){
          if(state.listImageCheckIn.isNotEmpty){
            DataLocal.listFileAlbum.clear();
            _bloc.listFileAlbumView.clear();
            for (var element in state.listImageCheckIn) {
              if(element.id == (widget.idCheckIn.toString().trim() + widget.idCustomer.toString().trim())){
                ListImageFile itemFile = ListImageFile(
                  id: element.id.toString(),
                  fileImage: File(element.filePath.toString()),
                  maAlbum: element.maAlbum.toString().trim(),
                  tenAlbum: element.tenAlbum.toString(),
                  fileName: element.fileName,
                  isSync: false
                );
                _bloc.listFileAlbumView.add(itemFile);
                DataLocal.addImageToAlbum = true;
                DataLocal.listFileAlbum.add(itemFile);
              }
            }
          }
          if(DataLocal.listFileAlbum.isNotEmpty){
            _bloc.add(PickAlbumImage( idAlbumImage: DataLocal.listFileAlbum[0].maAlbum.toString(),nameAlbumImage: DataLocal.listFileAlbum[0].tenAlbum.toString()));
          }else {
            if(DataLocal.listItemAlbum.isNotEmpty){
              _bloc.idAlbum = DataLocal.listItemAlbum[0].maAlbum!.toString().trim();
              _bloc.nameAlbum = DataLocal.listItemAlbum[0].tenAlbum!.toString().trim();
              _bloc.add(PickAlbumImage( idAlbumImage: DataLocal.listItemAlbum[0].maAlbum.toString(),nameAlbumImage: DataLocal.listItemAlbum[0].tenAlbum.toString()));
            }
          }
        }
        else if(state is PickAlbumImageSuccess){
          if(widget.isCheckInSuccess == true){
            if(_bloc.listImage.isNotEmpty){
              _bloc.listImage.clear();
            }
            _bloc.add(GetListImageStore(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString(),idAlbum: _bloc.idAlbum));
          }else{

          }
        }
        else if(state is GetListAlbumImageCheckInSuccess){
          if(_bloc.listAlbum.isNotEmpty){
            _bloc.idAlbum = _bloc.listAlbum[0].maAlbum!;_bloc.nameAlbum = _bloc.listAlbum[0].tenAlbum!;
          }
          if(DataLocal.listFileAlbum.isNotEmpty){
            _bloc.add(PickAlbumImage( idAlbumImage: _bloc.idAlbum.toString(),nameAlbumImage: _bloc.nameAlbum.toString()));
          }
        }
        else if(state is GrantCameraPermission){
          getImage();
        }
        else if(state is EmployeeScanFailure){
          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, ${state.error}');
        }
      },
      child: BlocBuilder<AlbumBloc,AlbumState>(
        bloc: _bloc,
        builder: (BuildContext context, AlbumState state){
          // if(Const.selectedAlbumLock == false && lockSelected == false){
          //   print('check');
          //   if(widget.listAlbum.isNotEmpty){
          //     _bloc.idAlbum = widget.listAlbum[0].maAlbum!;
          //     _bloc.nameAlbum = widget.listAlbum[0].tenAlbum!;
          //     if(_bloc.listFileAlbumView.isNotEmpty){
          //       _bloc.listFileAlbumView.clear();
          //     }
          //     for (var element in DataLocal.listFileAlbum) {
          //       if(element.maAlbum?.trim() == _bloc.idAlbum.trim()){
          //         _bloc.listFileAlbumView.add(element);
          //       }
          //     }
          //     // _bloc.add(PickAlbumImage(idAlbumImage: _bloc.idAlbum.toString().trim(),nameAlbumImage: _bloc.nameAlbum.toString().trim()));
          //     print('check1: ${_bloc.idAlbum}');
          //   }
          //   else{
          //     print('check2');
          //     _bloc.idAlbum = 'DLDC';
          //     _bloc.nameAlbum = 'Đại lý đóng cửa';
          //   }
          // }else{
          //   lockSelected = false;
          // }
          return Column(
            children: [
              Visibility(
                visible: Const.imageCheckIn == true,
                child: SizedBox(
                  height: 35,width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 8, top: 10, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Album',
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),
                          ),
                        ),
                        Visibility(
                          visible: DataLocal.listItemAlbum.isEmpty,
                          child: const Text('Không có Album nào',style: TextStyle(color: Colors.blueGrey,fontSize: 12),),
                        ),
                        Visibility(
                          visible: Const.selectedAlbumLock == true,
                          child: const Text('Đại lý đóng cửa',style: TextStyle(color: Colors.blueGrey,fontSize: 12),),
                        ),
                        Visibility(
                          visible: DataLocal.listItemAlbum.isNotEmpty && Const.selectedAlbumLock == false,
                          child: buildDropdownMenuAlbum(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  floatingActionButton: (widget.view == false && widget.isCheckInSuccess == false && Const.imageCheckIn == true)//(widget.isToday == true && widget.view == false)
                      ? FloatingActionButton(
                    backgroundColor: subColor,
                    onPressed: (){
                      setState(() {});
                      getImage();
                      // _bloc.add(GetCameraEvent());
                    },
                    child: const Icon(Icons.photo_filter,color: Colors.white,),
                  ) : Container(),
                  body: Stack(
                    children: [
                      buildBody(context,state),
                      Visibility(
                        visible: state is AlbumLoading,
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

  buildBody(BuildContext context,AlbumState state){
    int length = _bloc.listImage.length;
    if (state is GetListImageStoreSuccess) {
      _hasReachedMax = length < _bloc.currentPage * 20;
    }

    return Container(
      color: Colors.white,
      height: double.infinity,
      width: double.infinity,
      child: Const.imageCheckIn == true
          ?
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10,top: 5),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding:const EdgeInsets.symmetric(horizontal: 5),
                  child: Text('Danh sách hình ảnh của Cửa Hàng (${( widget.isCheckInSuccess == false && widget.view == false) ? _bloc.listFileAlbumView.length :  _bloc.listImage.length})',style:const TextStyle(color: Colors.blueGrey,fontSize: 10)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),
          Visibility(
            visible: (  widget.isCheckInSuccess == false && widget.view == false) && _bloc.listFileAlbumView.isNotEmpty,
            child: Expanded(
              child: Const.selectedAlbumLock == true
                  ?
              GridView.builder(
                  padding: const EdgeInsets.only(left: 12,right: 12),
                  // controller: _scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 2/1.6,
                    crossAxisCount: Utils.getCountByScreen(context),
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _bloc.listFileAlbumCloseStoreView.length,
                  itemBuilder: (context, index) {
                    return (start > 1 && waitingLoad == true && _bloc.listFileAlbumCloseStoreView.length == (index + 1)) ? const PendingAction() :
                    GestureDetector(
                          onTap: ()=>showBottomSheet(index),
                          child: Card(
                            semanticContainer: true,
                            margin: const EdgeInsets.all(5),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  flex:1,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(6),)
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(6),
                                            topLeft:  Radius.circular(6),
                                          ),
                                          child: SizedBox.fromSize(
                                              size: const Size.fromRadius(35), // Image radius
                                              child: InteractiveViewer(child: Image.file(_bloc.listFileAlbumCloseStoreView[index].fileImage!,fit: BoxFit.contain,width: 600,height: 600,cacheHeight: 600,cacheWidth: 600,filterQuality: FilterQuality.low,))
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                      );
                  }
              )
                  :
              GridView.builder(
                  padding: const EdgeInsets.only(left: 12,right: 12),
                  // controller: _scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 2/1.6,
                    crossAxisCount: Utils.getCountByScreen(context),
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _bloc.listFileAlbumView.length,
                  itemBuilder: (context, index) {

                    return (start > 1 && waitingLoad == true && _bloc.listFileAlbumView.length == (index + 1)) ? const PendingAction() :
                    GestureDetector(
                        onTap: ()=>showBottomSheet(index),
                        child: Card(
                          semanticContainer: true,
                          margin: const EdgeInsets.all(5),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                flex:1,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(6),)
                                      ),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(6),
                                          topLeft:  Radius.circular(6),
                                        ),
                                        child: SizedBox.fromSize(
                                            size: const Size.fromRadius(35), // Image radius
                                            child: InteractiveViewer(child: Image.file(_bloc.listFileAlbumView[index].fileImage!,fit: BoxFit.contain,cacheHeight: 600,cacheWidth: 600,height: 600,width: 600,filterQuality: FilterQuality.low,))
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                    );
                  }
              ),
            ),
          ),
          Visibility(
            visible: ( widget.isCheckInSuccess != false) && _bloc.listImage.isNotEmpty,
            child: Expanded(
              child: GridView.builder(
                  padding: const EdgeInsets.only(left: 12,right: 12),
                  controller: _scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 2/1.6,
                    crossAxisCount: Utils.getCountByScreen(context),
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _bloc.listImage.length ,
                  itemBuilder: (context, index) {
                    return index >= length ?
                    Container(
                      height: 100.0,
                      color: white,
                      child: const PendingAction(),
                    )
                        :
                      GestureDetector(
                          onTap: ()=> PersistentNavBarNavigator.pushNewScreen(context, screen: ViewFilesPage(pathImageNewWork: _bloc.listImage[index].pathL,isCheckIn: true,isInternetImage: true,)),
                          child: Card(
                            semanticContainer: true,
                            margin: const EdgeInsets.all(5),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  flex:1,
                                  child: SizedBox(
                                    width: 115,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      child: Hero(
                                        tag: index,
                                        child: InteractiveViewer(child: Image.network(_bloc.listImage[index].pathL!,fit: BoxFit.cover,cacheHeight: 150,cacheWidth: 150,)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      );
                  }
              ),),
          ),
          Visibility(
            visible: _bloc.listFileAlbumView.isEmpty && _bloc.listImage.isEmpty,
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

  Widget buildDropdownMenuAlbum(){
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
                  itemCount: DataLocal.listItemAlbum.length,
                  itemBuilder: (context, index) {
                    final trans = DataLocal.listItemAlbum[index].tenAlbum.toString().trim();
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
                          const Text(
                            '',//widget.listAlbum[index].maAlbum.toString().trim(),
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      subtitle:const Divider(height: 1,),
                      onTap: () {
                        lockSelected = true;
                       _bloc.add(PickAlbumImage(idAlbumImage: DataLocal.listItemAlbum[index].maAlbum.toString().trim(),nameAlbumImage: DataLocal.listItemAlbum[index].tenAlbum.toString().trim()));
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
          Text(_bloc.nameAlbum.toString(),style: const TextStyle(color: Colors.blueGrey,fontSize: 12,fontWeight: FontWeight.w600),),
          const SizedBox(width: 5,),
          const Icon(Icons.arrow_drop_down_outlined,color: Colors.blueGrey,),
        ],
      ),
    );
  }

  // void compressWithNativeImage(File? imageFile,String fileName, String fileExt, int fileSize, double totalFileSize) async {
  //   File? imageCompressed;
  //   await FlutterNativeImage.compressImage(
  //     imageFile!.path,
  //     quality: 35,
  //   )
  //       .then((response) {
  //     imageCompressed = response;
  //     // var bytes = File(imageCompressed!.path).readAsBytesSync();
  //     // var result = hex.encoder.convert(bytes);
  //     // AlbumInStore dataFile = AlbumInStore(
  //     //   pathImage:
  //     // );
  //     // ListImageFile itemFile = ListImageFile(
  //     //     fileImage: File(imageCompressed!.path),
  //     //     maAlbum: _bloc.idAlbum,
  //     //     tenAlbum: _bloc.nameAlbum
  //     // );
  //     // DataLocal.listFileAlbum.add(itemFile);
  //     // _bloc.listFileAlbumView.add(itemFile);
  //   })
  //       .catchError((e) {
  //   });
  // }

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
                                          child: const Padding(
                                            padding: EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Xoá hình ảnh',style: TextStyle(color: Colors.black),),
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
                                          child: const Padding(
                                            padding: EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Xem hình ảnh',style: TextStyle(color: Colors.black),),
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
                      title: 'Bạn muốn xoá ảnh này?',
                      content: 'Hãy chắc chắn bạn muốn điều này?',
                    ),
                  );
                }).then((value)async{
              if(value != null){
                if(!Utils.isEmpty(value) && value == 'Yeah'){
                  int indexLocal = DataLocal.listFileAlbum.indexOf(_bloc.listFileAlbumView[index]);

                  _bloc.add(DeleteImageLocalEvent(fileName: DataLocal.listFileAlbum[indexLocal].fileName.toString()));
                  DataLocal.listFileAlbum.removeAt(indexLocal);
                  _bloc.listFileAlbumView.removeAt(index);
                  if(_bloc.listFileAlbumView.isEmpty){
                    // _bloc.add(DeleteAllImageLocalEvent());
                    DataLocal.addImageToAlbum = false;
                  }
                  setState(() {});
                  Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Xoá hình ảnh thành công');
                }
              }
            });

            break;
          case '2':
            PersistentNavBarNavigator.pushNewScreen(context, screen: ViewFilesPage(fileData:_bloc.listFileAlbumView[index].fileImage,isCheckIn: true,isInternetImage: false,));
            break;
        }
      }
    });
  }

}
