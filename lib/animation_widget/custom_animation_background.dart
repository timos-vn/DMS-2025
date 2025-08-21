import 'dart:math';

import 'package:flutter/material.dart';


class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    Key? key,
    required this.width,
    required this.show,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.ease,
    this.offset = Offset.zero,
  }) : super(key: key);
  final Offset offset;
  final double width;
  final Duration duration;
  final Curve curve;
  final bool show;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final CurveTween tween;
  late final Animation<double> animation;
  late final AnimationController controller;

  @override
  void initState() {
    tween = CurveTween(curve: widget.curve);
    controller = AnimationController(vsync: this, duration: widget.duration);
    animation = tween.animate(controller);
    animation.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AnimatedBackground oldWidget) {
    // trigger animation
    if (oldWidget.show != widget.show) {
      if (widget.show) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return CustomPaint(
          painter: _AnimatedBackgroundPainter(
            animation.value,
            widget.width,
            widget.offset,
          ),
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          ),
        );
      }),
    );
  }
}

class _AnimatedBackgroundPainter extends CustomPainter {
  final double value;
  final double maxWidth;
  final Offset offset;

  _AnimatedBackgroundPainter(this.value, this.maxWidth, this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Color.fromARGB(255, 0, 51, 114);
    var rvalue = (value * maxWidth);
    var hw = sqrt(2 * (maxWidth * maxWidth)) / 2 + 50;
    var rhw = sqrt(2 * (rvalue * rvalue)) / 2 ;
    var h = size.height - hw * 1 ;
    var w = h / 3;

    var path = Path();
    path.moveTo(offset.dx + 0, offset.dy + hw );
    path.lineTo(offset.dx + 0, offset.dy + hw - rhw ); // điểm đầu đường kẻ bên ngoài - của đường trên
    path.lineTo(offset.dx + w + rhw  , offset.dy + h / 2); //góc mũi bên phải - từ trên xuống
    path.lineTo(offset.dx + 0, offset.dy + h + rhw );//+50
    path.lineTo(offset.dx + 0, offset.dy + h );
    path.lineTo(offset.dx + 0, offset.dy + h - rhw *1.5); // đường kẻ bên trong - của đường dưới
    path.lineTo(offset.dx + w - rhw, offset.dy + h / 2 );
    path.lineTo(offset.dx + 0, offset.dy + hw + rhw );//+ 25
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
