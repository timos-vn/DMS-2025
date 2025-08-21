// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:dms/screen/dms/check_in/ticket/ticket_bloc.dart';
import 'package:dms/screen/dms/check_in/ticket/ticket_state.dart';
import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../custom_lib/view_only_image.dart';
import '../../../../model/entity/item_check_in.dart';
import '../../../../model/network/response/list_image_store_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/utils.dart';
import '../ticket/ticket_event.dart';


class AddNewTicketScreen extends StatefulWidget {
  final String nameTicketType;
  final String idCustomer;
  final String idTicketType;
  final String idCheckIn;
  final bool addNew;
  final String comment;
  final ItemListTicketOffLine? itemListTicketOffLine;

  const AddNewTicketScreen({Key? key,required this.nameTicketType,
    required this.idCustomer, required this.idTicketType,
    required this.idCheckIn,required this.addNew, required this.comment, this.itemListTicketOffLine
  }) : super(key: key);

  @override
  _AddNewTicketScreenState createState() => _AddNewTicketScreenState();
}

class _AddNewTicketScreenState extends State<AddNewTicketScreen> {

  late TicketBloc _bloc;

  final _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  late Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  int start = 3;

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
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = TicketBloc(context);
    _bloc.add(GetPrefsTicket());
  }

  // final imagePicker = ImagePicker();

  Future getImage()async {
    // final image = await imagePicker.pickImage(source: ImageSource.camera,imageQuality: 45);

    PersistentNavBarNavigator.pushNewScreen(context, screen: const CameraCustomUI()).then((value){
      if(value != null){
        XFile image = value;
        setState(() {
          if(image != null){
            start = 2;waitingLoad  = true;
            startTimer();
            ListImageFile item = ListImageFile(
                fileName: image.name,
                fileImage: File(image.path),
                maAlbum: widget.idTicketType,
                tenAlbum: widget.nameTicketType,
                id: widget.idCustomer + widget.idCheckIn,
                isSync: false
            );
            _bloc.listFileTicket.add(item);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: subColor,
        onPressed: ()async{
          if(_noteController.text.isNotEmpty){
            _bloc.add(AddNewTicketEvent(
              idIncrement: widget.itemListTicketOffLine != null ? widget.itemListTicketOffLine!.idIncrement.toString() : '',
              addNew: widget.addNew,
              idCustomer: widget.idCustomer,
              idTicketType: widget.idTicketType,
              nameTicketType: widget.nameTicketType,
              idCheckIn: widget.idCheckIn,
              comment: _noteController.text,
            ));
          }else{
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vui lòng nhập đầy đủ nội dung');
          }
        },
        child:  Icon( widget.addNew == true ? Icons.post_add : Icons.update ,color: Colors.white,),
      ),
      body: BlocListener<TicketBloc,TicketState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            if(widget.addNew == false){
              _noteController.text = widget.comment.toString();
              if(widget.itemListTicketOffLine != null){
                if(widget.itemListTicketOffLine!.filePath != '' && widget.itemListTicketOffLine!.filePath != 'null'){
                  widget.itemListTicketOffLine!.filePath!.split(',').forEach((element) {
                    ListImageFile item = ListImageFile(
                        fileName: element.toString(),
                        fileImage: File(element.toString()),
                        maAlbum: widget.idTicketType,
                        tenAlbum: widget.nameTicketType,
                        id: widget.idCustomer + widget.idCheckIn,
                        isSync: false
                    );
                    _bloc.listFileTicket.add(item);
                  });

                }
              }
            }
          }
          else if(state is GrantCameraPermission){
            getImage();
          }else if(state is AddNewTicketSuccess){
            if(widget.addNew == true){
              Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Thêm mới phản hồi thành công');
            }else{
              Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Cập nhật Ticket thành công');
            }

           Navigator.pop(context,'RELOAD');
          }
        },
        child: BlocBuilder<TicketBloc,TicketState>(
          bloc: _bloc,
          builder: (BuildContext context, TicketState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is TicketLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,TicketState state){
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                    child: Text('Thông tin phản hồi Ticket',style: TextStyle(color: subColor,fontWeight: FontWeight.bold),),
                  ),
                  inputWidget(title: "Nội dung",hideText: 'Vui lòng nhập nội dung',controller: _noteController,focusNode: _noteFocus,
                    textInputAction: TextInputAction.newline, onTapSuffix: (){},note: true,
                    onSubmitted: ()=>null,),
                  buildAttachFileInvoice()
                ],
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
            onTap: ()=> Navigator.pop(context,),
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
                "Thêm mới phản hồi Ticket",
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

  Widget inputWidget({String? title,String? hideText,IconData? iconPrefix,IconData? iconSuffix, bool? isEnable,
    TextEditingController? controller,Function? onTapSuffix, Function? onSubmitted,FocusNode? focusNode,
    TextInputAction? textInputAction,bool inputNumber = false,bool isPhone = false,bool note = false,bool isPassWord = false, bool cod = true,int? maxLength, bool customContainer = false}){
    return Padding(
      padding: EdgeInsets.only(top: 10,left: 10,right: 10,bottom: customContainer == true ? 0 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title??'',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12,color: Colors.black),
              ),
              Visibility(
                visible: note == true,
                child: const Text(' *',style: TextStyle(color: Colors.red),),
              )
            ],
          ),
          const SizedBox(height: 5,),
          Container(
            // height: customContainer == true ? 60 : 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12)
            ),
            child: TextField(
              minLines: 1,
              maxLines: null,
              controller: controller!,
              textInputAction: textInputAction!,
              keyboardType: TextInputType.multiline,
              focusNode: focusNode,
              onChanged: (string){},
              onSubmitted: (text)=> onSubmitted,
              style: const TextStyle(
                fontSize: 13,
                color: black,
              ),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: grey, width: 1),),
                  // enabledBorder: const UnderlineInputBorder(
                  //   borderSide: BorderSide(color: grey, width: 1),
                  // ),
                  // focusedBorder: const UnderlineInputBorder(
                  //   borderSide: BorderSide(color: grey, width: 1),
                  // ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 7,horizontal: 5),
                  isDense: true,
                  focusColor: primaryColor,
                  hintText: hideText,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: grey,
                  ),
                  errorStyle: const TextStyle(
                    fontSize: 10,
                    color: red,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  buildAttachFileInvoice(){
    return Padding(
      padding: const EdgeInsets.only(top: 10,left: 10,right: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                getImage();
                // _bloc.add(GetCameraEvent());
              },
              child: Container(padding: const EdgeInsets.only(left: 10,right: 15,top: 8,bottom: 8),
                height: 40,
                width: double.infinity,
                color: Colors.amber.withOpacity(0.4),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ảnh của bạn',style: TextStyle(color: Colors.black,fontSize: 13),),
                    Icon(Icons.add_a_photo_outlined,size: 20,),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16,),
            _bloc.listFileTicket.isEmpty ? const SizedBox(height: 100,child: Center(child: Text('Hãy chọn thêm hình của bạn từ thư viện ảnh hoặc camera',style: TextStyle(color: Colors.blueGrey,fontSize: 12),),),) :
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _bloc.listFileTicket.length,
                    itemBuilder: (context,index){
                      return (start > 1 && waitingLoad == true && _bloc.listFileTicket.length == (index + 1)) ? const SizedBox(height: 100,width: 80,child: PendingAction()) : GestureDetector(
                        onTap: (){
                          openImageFullScreen(index,File(_bloc.listFileTicket[index].fileImage!.path));//_bloc.listFileTicket[index].fileImage!.path);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: 115,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  child: Image.file(
                                    File(_bloc.listFileTicket[index].fileImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,right: 6,
                                child: InkWell(
                                  onTap: (){
                                    setState(() {
                                      _bloc.listFileTicket.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    height: 20,width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black.withOpacity(.7),
                                    ),
                                    child: const Icon(Icons.clear,color: Colors.white,size: 12,),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // to open gallery image in full screen
  void openImageFullScreen(final int indexOfImage, File fileImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageViewWrapperViewOnly(
          titleGallery: "Zoom Image",
          viewNetWorkImage: false,
          backgroundDecoration: const BoxDecoration(
            color: Colors.white,
          ),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal, galleryItemsFile: fileImage,
        ),
      ),
    );
  }
}
