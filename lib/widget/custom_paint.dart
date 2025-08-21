
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CheckCorner extends CustomPainter {
  final double size;
  final Color color;

  CheckCorner({this.size = 20, this.color = Colors.grey});

  @override
  void paint(Canvas canvas, Size _) {
    var shapePainter = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var shapePath = Path();
    shapePath.moveTo(0, 0);
    shapePath.lineTo(0, size);
    shapePath.lineTo(size, 0);
    shapePath.close();

    var checkPainter = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawPath(shapePath, shapePainter);
    canvas.drawLine(Offset(size * .15, size * .25),
        Offset(size * .3, size * .45), checkPainter);
    canvas.drawLine(Offset(size * .3, size * .45),
        Offset(size * .6, size * .15), checkPainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


class ProductLikePaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = Color.fromARGB(255, 255, 0, 4)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.0381373, size.height * 0.7943000);
    path_0.lineTo(size.width * 0.0381373, size.height * 0.0393000);
    path_0.lineTo(size.width * 0.9557843, size.height * 0.0393000);
    path_0.quadraticBezierTo(size.width * 0.9950784, size.height * 0.0460000,
        size.width * 0.9969608, size.height * 0.1393000);
    path_0.cubicTo(
        size.width * 0.9964706,
        size.height * 0.2780500,
        size.width * 0.9954902,
        size.height * 0.5555500,
        size.width * 0.9950000,
        size.height * 0.6943000);
    path_0.quadraticBezierTo(size.width * 0.9942745, size.height * 0.7736000,
        size.width * 0.9597059, size.height * 0.7793000);

    canvas.drawPath(path_0, paint_0);

    Paint paint_1 = new Paint()
      ..color = Color.fromARGB(255, 175, 17, 20)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.0400000, size.height * 0.7937000);
    path_1.lineTo(size.width * 0.0993333, size.height * 0.9974000);
    path_1.lineTo(size.width * 0.1000392, size.height * 0.7885500);

    canvas.drawPath(path_1, paint_1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}