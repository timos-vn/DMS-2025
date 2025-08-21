import 'package:cached_network_image/cached_network_image.dart';
import 'package:dms/themes/colors.dart';
import 'package:flutter/material.dart';

Widget lockModule(){
  return const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(Icons.lock,size: 25,color: Colors.blueGrey,),
      SizedBox(height: 5,),
      Text('Úi, Bạn không có quyền truy cập tính năng này',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    ],
  );
}

Widget customText(String msg, {TextStyle? style,TextAlign textAlign = TextAlign.justify,overflow = TextOverflow.clip,BuildContext? context}){

  // ignore: unnecessary_null_comparison
  if(msg == null){
    return const SizedBox(height: 0,width: 0,);
  }
  else{
    if(context != null && style != null){
      var fontSize = style.fontSize ?? Theme.of(context).textTheme.bodyMedium?.fontSize;
      style =  style.copyWith(fontSize: fontSize! - ( fullWidth(context) <= 375  ? 2 : 0));
    }
    return Text(msg,style: style,textAlign: textAlign,overflow:overflow,);
  }
}
double fullWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}
double fullHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}
double getDimension(context, double unit){
  if(fullWidth(context) <= 360.0){
    return unit / 1.3;
  }
  else {
    return unit;
  }
}
dynamic customAdvanceNetworkImage(String path){
  return CachedNetworkImageProvider(path);
}
double getFontSize(BuildContext context,double size){
  if(MediaQuery.of(context).textScaleFactor < 1){
    return getDimension(context,size);
  }
  else{
    return getDimension(context,size / MediaQuery.of(context).textScaleFactor);
  }
}
String getTypeImage(String type){
  switch(type){
    case 'Fighting' : return 'assets/images/types/Fight.png'; break;
    default: return 'assets/images/types/$type.png';
  }
}
buildTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2)),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(color: subColor, fontSize: 13),
          )),
    ),
  );
}
buildButton({required String title,required  IconData icons,required  bool lock,VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Center(
            child: Icon(
              icons,
              size: 24,
              color: lock == false ? subColor : Colors.grey,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  color: lock == false ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.normal),
            ),
          ),
          lock == false
              ? const Icon(
            Icons.navigate_next,
            color: Colors.blueGrey,
          )
              : const Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}