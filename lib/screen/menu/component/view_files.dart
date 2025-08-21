import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../themes/colors.dart';

class ViewFilesPage extends StatefulWidget {
  final Uint8List? imageData;
  final File? fileData;
  final bool isCheckIn;
  final bool? isInternetImage;
  final String? pathImageNewWork;
  const ViewFilesPage({Key? key,this.imageData, required this.isCheckIn,this.fileData, this.isInternetImage,this.pathImageNewWork}) : super(key: key);

  @override
  _ViewFilesPageState createState() => _ViewFilesPageState();
}

class _ViewFilesPageState extends State<ViewFilesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width:  double.infinity,
        child: buildBody(context))
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
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor,const Color.fromARGB(255, 150, 185, 229)])),
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
                "Attach Files",
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
              Icons.filter_alt_outlined,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  buildBody(BuildContext context,){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 15,),
          widget.isCheckIn == false
              ?
          Expanded(
              child: InteractiveViewer(
                child: Image.memory(widget.imageData!),
              )
          )
              :
          widget.isInternetImage == false ? Expanded(
              child: InteractiveViewer(
                child: Image.file(widget.fileData!),
              )
          ) : Expanded(
              child: InteractiveViewer(
                child: CachedNetworkImage(imageUrl: widget.pathImageNewWork.toString(),),
              )
          ),
          const SizedBox(height: 55,)
        ],
      ),
    );
  }
}
