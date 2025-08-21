import 'package:flutter/material.dart';

class RollingSwitchCustom extends StatefulWidget {
  final bool value;
  final double width;
  final double height;
  final String textOn;
  final String textOff;
  final Color colorOn;
  final Color colorOff;
  final IconData iconOn;
  final IconData iconOff;
  final Duration animationDuration;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onSwipe;

  const RollingSwitchCustom({
    super.key,
    required this.value,
    required this.textOn,
    required this.textOff,
    required this.colorOn,
    required this.colorOff,
    required this.iconOn,
    required this.iconOff,
    required this.onChanged,
    this.width = 150,
    this.height = 50,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onTap,
    this.onDoubleTap,
    this.onSwipe,
  });

  @override
  State<RollingSwitchCustom> createState() => _RollingSwitchCustomState();
}

class _RollingSwitchCustomState extends State<RollingSwitchCustom>
    with SingleTickerProviderStateMixin {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.value;
  }

  void toggle() {
    setState(() => isOn = !isOn);
    widget.onChanged(isOn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        toggle();
        widget.onTap?.call();
      },
      onDoubleTap: widget.onDoubleTap,
      onPanUpdate: (details) {
        if (details.delta.dx.abs() > 10) {
          toggle();
          widget.onSwipe?.call();
        }
      },
      child: AnimatedContainer(
        duration: widget.animationDuration,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isOn ? widget.colorOn : widget.colorOff,
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
        child: Stack(
          children: [
            // Text and Icon
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: isOn
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    Icon(
                      isOn ? widget.iconOn : widget.iconOff,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOn ? widget.textOn : widget.textOff,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Thumb
            AnimatedAlign(
              alignment:
              isOn ? Alignment.centerRight : Alignment.centerLeft,
              duration: widget.animationDuration,
              curve: Curves.easeInOut,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: widget.height - 8,
                  height: widget.height - 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 2,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
