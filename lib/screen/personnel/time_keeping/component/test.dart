// ignore_for_file: library_private_types_in_public_api

import 'dart:math' as math;

import 'package:flutter/material.dart';

class ViewProFileScreen extends StatefulWidget {
  final String userName;
  final String level;
  const ViewProFileScreen({Key? key, required this.userName, required this.level}) : super(key: key);

  @override
  _ViewProFileScreenState createState() => _ViewProFileScreenState();
}

class _ViewProFileScreenState extends State<ViewProFileScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ListModel listModel;
  bool showOnlyCompleted = false;

  static const double _imageHeight = 256.0;

  @override
  void initState() {
    super.initState();
    listModel = ListModel(_listKey, getTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildTimeline(),
          _buildImage(),
          _buildTopHeader(),
          _buildProfileRow(),
          _buildBottomPart(),
          _buildFab()
        ],
      ),
    );
  }

  Widget _buildTopHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24.0),
    child: Row(
      children: <Widget>[
        IconButton(
          onPressed: ()=> Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        const Expanded(
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
            child: Text(
              "Profile",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.more_horiz,
            color: Colors.transparent,
          ),
        )
      ],
    ),
  );

  Widget _buildImage() => ClipPath(
    clipper: DialogonalClipper(),
    child: SizedBox(
      width: double.infinity,
      child: Image.asset(
        'assets/images/avatar_store.jpg',
        fit: BoxFit.cover,
        height: _imageHeight,
        colorBlendMode: BlendMode.srcOver,
        color: const Color.fromARGB(120, 20, 10, 40),
      ),
    ),
  );

  Widget _buildProfileRow() => Padding(
    padding: const EdgeInsets.only(top: _imageHeight / 2.5, left: 16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const CircleAvatar(
          minRadius: 28.0,
          maxRadius: 28.0,
          backgroundImage: AssetImage('assets/images/avatar_store.jpg'),
        ),
        Expanded(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.userName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w300),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.level,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w200),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    ),
  );

  Widget _buildBottomPart() => Padding(
    padding: const EdgeInsets.only(top: _imageHeight),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildMyTaskHeader(),
        _buildTaskList()
      ],
    ),
  );

  Widget _buildMyTaskHeader() => Padding(
    padding: const EdgeInsets.only(left: 64.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text(
          'My Tasks',
          style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w400),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'FEBRUARY 8, 2020',
            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300),
          ),
        )
      ],
    ),
  );

  Widget _buildTimeline() => Positioned(
    top: 0.0,
    bottom: 0.0,
    left: 32.0,
    child: Container(
      width: 1.0,
      color: Colors.grey[300],
    ),
  );

  Widget _buildTaskList() => Expanded(
      child: AnimatedList(
          key: _listKey,
          initialItemCount: getTask.length,
          itemBuilder: (context, index, animation) => TaskRow(
            task: listModel[index],
            animation: animation,
          )));

  Widget _buildFab() => Positioned(
    top: _imageHeight - 100.0,
    right: -40.0,
    child: AnimatedFab(
      onClick: _changeFilterState,
    ),
  );

  _changeFilterState() {
    showOnlyCompleted = !showOnlyCompleted;
    getTask.where((task) => !task.completed!).forEach((task) {
      if (showOnlyCompleted) {
        listModel.removeAt(listModel.indexOf(task));
      } else {
        listModel.insert(getTask.indexOf(task), task);
      }
    });
  }
}

class TaskRow extends StatelessWidget {
  final Animation<double> animation;
  final Task task;

  const TaskRow({Key? key, required this.task, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.5),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: task.color),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.name.toString(),
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      task.category.toString(),
                      style: TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  task.time.toString(),
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedFab extends StatefulWidget {
  final VoidCallback onClick;

  const AnimatedFab({Key? key,required this.onClick}) : super(key: key);

  @override
  _AnimatedFabState createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  final double expandedSize = 180.0;
  final hiddenSize = 20.0;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _colorAnimation = ColorTween(begin: Colors.pinkAccent, end: Colors.pink[800]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expandedSize,
      height: expandedSize,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildExpandedBackground(),
            _buildOption(Icons.check_circle, 0.0),
            _buildOption(Icons.flash_on, -math.pi / 3),
            _buildOption(Icons.access_time, -2 * math.pi / 3),
            _buildOption(Icons.error_outline, math.pi),
            _buildFabCore(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedBackground() {
    double size =
        hiddenSize + (expandedSize - hiddenSize) * _animationController.value;
    return Container(
      height: size,
      width: size,
      decoration:
      const BoxDecoration(shape: BoxShape.circle, color: Colors.pinkAccent),
    );
  }

  Widget _buildFabCore() {
    double scaleFactor = 2 * (_animationController.value - 0.5).abs();
    return FloatingActionButton(
      onPressed: _onTabTap,
      backgroundColor: _colorAnimation.value,
      child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(1.0, scaleFactor),
          child: Icon(
            _animationController.value > 0.5 ? Icons.close : Icons.filter_list,
            color: Colors.white,
            size: 26.0,
          )),
    );
  }

  Widget _buildOption(IconData icon, double angle) {
    double iconSize = 0.0;

    if (_animationController.value > 0.8) {
      iconSize = 26.0 * (_animationController.value - 0.8) * 5;
    }

    return Transform.rotate(
      angle: angle,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: IconButton(
            onPressed: _onIconClick,
            icon: Transform.rotate(
              angle: -angle,
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            iconSize: iconSize,
            alignment: Alignment.center,
            padding: EdgeInsets.all(0.0),
          ),
        ),
      ),
    );
  }

  _onTabTap() {
    if (_animationController.isDismissed) {
      open();
    } else {
      close();
    }
  }

  _onIconClick() {
    widget.onClick();
    close();
  }

  open() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    }
  }

  close() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }
}

class DialogonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..lineTo(0.0, size.height - 60.0)
    ..lineTo(size.width, size.height)
    ..lineTo(size.width, 0.0)
    ..close();

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class Task {
  final String? name;
  final String? category;
  final String? time;
  final Color? color;
  final bool? completed;

  Task({this.name, this.category, this.time, this.color, this.completed});
}

class ListModel {
  final GlobalKey<AnimatedListState> listKey;
  final List<Task> items;

  ListModel(this.listKey, items) : items = List.of(items);

  AnimatedListState? get _animatedList => listKey.currentState;

  int get length => items.length;

  Task operator [](int index) => items[index];

  int indexOf(Task item) => items.indexOf(item);

  void insert(int index, Task item) {
    items.insert(index, item);
    _animatedList?.insertItem(index);
  }

  Task removeAt(int index) {
    final Task removedItem = items.removeAt(index);
    if (removedItem != null) {
      _animatedList?.removeItem(index, (context, animation) => Container());
    }
    return removedItem;
  }
}

List<Task> getTask = [
  Task(
      name: "Catch up with Brian",
      category: "Mobile Project",
      time: "5pm",
      color: Colors.orange,
      completed: false),
  Task(
      name: "Make new icons",
      category: "Web App",
      time: "3pm",
      color: Colors.cyan,
      completed: true),
  Task(
      name: "Design explorations",
      category: "Company Website",
      time: "2pm",
      color: Colors.pink,
      completed: false),
  Task(
      name: "Lunch with Mary",
      category: "Grill House",
      time: "12pm",
      color: Colors.lightGreenAccent,
      completed: true),
  Task(
      name: "Teem Meeting",
      category: "Hangouts",
      time: "10am",
      color: Colors.redAccent,
      completed: true),
  Task(
      name: "Catch up with Brian",
      category: "Mobile Project",
      time: "5pm",
      color: Colors.yellowAccent,
      completed: false),
  Task(
      name: "Make new icons",
      category: "Web App",
      time: "3pm",
      color: Colors.blueAccent,
      completed: true),
  Task(
      name: "Design explorations",
      category: "Company Website",
      time: "2pm",
      color: Colors.pinkAccent,
      completed: false),
  Task(
      name: "Lunch with Mary",
      category: "Grill House",
      time: "12pm",
      color: Colors.lightBlue,
      completed: true),
  Task(
      name: "Teem Meeting",
      category: "Hangouts",
      time: "10am",
      color: Colors.purple,
      completed: true),
  Task(
      name: "Catch up with Brian",
      category: "Mobile Project",
      time: "5pm",
      color: Colors.orange,
      completed: false),
  Task(
      name: "Make new icons",
      category: "Web App",
      time: "3pm",
      color: Colors.cyan,
      completed: true),
  Task(
      name: "Design explorations",
      category: "Company Website",
      time: "2pm",
      color: Colors.pink,
      completed: false),
  Task(
      name: "Lunch with Mary",
      category: "Grill House",
      time: "12pm",
      color: Colors.lightGreenAccent,
      completed: true),
  Task(
      name: "Teem Meeting",
      category: "Hangouts",
      time: "10am",
      color: Colors.indigoAccent,
      completed: true)
];