import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableWidget<T> extends StatelessWidget {
  final Widget child;
  final Function() onDismissed;

  const SlidableWidget({
    required this.child,
    required this.onDismissed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Slidable(
        key: const ValueKey(1),
        child: child,
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: ()=>print('12333')),
          children: [
            SlidableAction(
              onPressed: onDismissed(),
              backgroundColor: Color(0xFF7BC043),
              foregroundColor: Colors.white,
              icon: Icons.archive,
              label: 'Xoá',
            ),
          ],
        ),
      );
}

