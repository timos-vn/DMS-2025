import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TRoundedImage extends StatelessWidget {
  const TRoundedImage({
    Key? key,
    this.width,
    this.height,
    required this.imageLink,
    this.applyImageRadius = true,
    this.border,
    this.backgroundColor = Colors.white,
    this.boxFit = BoxFit.contain,
    this.padding,
    this.isNetworkImage = false,
    this.onPress,
    this.borderRadius = 16.0
  }) : super(key: key);

  final double? width, height;
  final String imageLink;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit? boxFit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPress;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: onPress,
      child: Container(
        height: height,width: width,padding: padding,
        decoration: BoxDecoration(
          border: border,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius)
        ),
        child: ClipRRect(
          borderRadius: applyImageRadius ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
          child: Image(fit: boxFit, image: isNetworkImage ? NetworkImage(imageLink) : AssetImage(imageLink) as ImageProvider,),
        ),
      ),
    );
  }
}
