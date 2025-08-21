import 'package:dms/screen/dms/dms_screen.dart';
import 'package:dms/screen/menu/menu_screen.dart';

import 'package:dms/themes/colors.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../utils/const.dart';
import '../../utils/utils.dart';
import '../dms/dms_bloc.dart';
import '../home/home_bloc.dart';
import '../home/home_screen2.dart';
import '../menu/menu_bloc.dart';
import '../personnel/personnel_bloc.dart';
import '../qr_code/component/custom_qr_code.dart';
import '../sell/sell_bloc.dart';
import '../sell/sell_screen.dart';
import 'main_bloc.dart';
import 'main_event.dart';
import 'main_state.dart';

class MainScreen extends StatefulWidget {
  final List<Widget> listMenu;
  final List<PersistentBottomNavBarItem> listNavItem;
  final String? userName;
  final String? currentAddress;
  final int? rewardPoints;

  const MainScreen({Key? key,required this.listMenu,required this.listNavItem,this.userName,this.currentAddress,this.rewardPoints}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{
  late MainBloc _mainBloc;
  late HomeBloc _homeBloc;
  late SellBloc _sellBloc;
  late DMSBloc _dmsBloc;
  late PersonnelBloc _personnelBloc;
  late MenuBloc _menuBloc;


  int _lastIndexToHome = 0;
  int _currentIndex = 0;


  GlobalKey<NavigatorState>? _currentTabKey;
  // late List<BottomNavigationBarItem> listBottomItems;
  final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> fourthTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> fifthTabNavKey = GlobalKey<NavigatorState>();

  // void showUpdate(){
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return WillPopScope(
  //           onWillPop: () async => false,
  //           child: const ConfirmUpdateVersionPage(
  //             title: 'Đã có phiên bản mới',
  //             content: 'Cập nhật ứng dụng của bạn để có trải nghiệm tốt nhất',
  //             type: 0,
  //           ),
  //         );
  //       });
  // }


  late List<Widget> _screens = [

  ];

  @override
  void initState() {
    _screens = <Widget>[
      HomeScreen2(userName: widget.userName.toString(),),
      SellScreen(userName: widget.userName.toString(),),
      const QRCodeGeneratorWidget(),
      const DMSScreen(),
      const MenuScreen()
    ];

    _mainBloc = MainBloc(context);
    _homeBloc = HomeBloc(context);
    _sellBloc = SellBloc(context);
    _dmsBloc = DMSBloc(context);
    _personnelBloc = PersonnelBloc(context);
    _menuBloc = MenuBloc(context);
    _currentTabKey = firstTabNavKey;

    _mainBloc.add(GetPrefs());

    super.initState();
  }



  SnakeBarBehaviour snakeBarStyle = SnakeBarBehaviour.floating;
  SnakeShape snakeShape = SnakeShape.circle;
  EdgeInsets padding = const EdgeInsets.all(12);
  ShapeBorder? bottomBarShape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(25)),
  );

  Color selectedColor = mainColor;
  Color unselectedColor = Colors.blueGrey;
  int _selectedItemPosition = 0;
  PageController controller = PageController(initialPage: 0,keepPage: true);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        bool isSuccess = await _currentTabKey!.currentState!.maybePop();
        if (!isSuccess && _currentIndex != Const.HOME) {
          _lastIndexToHome = Const.HOME;
          _currentIndex = _lastIndexToHome;
          _currentTabKey = firstTabNavKey;
        }
        if (!isSuccess) {
          // ignore: use_build_context_synchronously
          _exitApp(context);
        }
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        extendBody: true,
        body: MultiBlocProvider(
            providers: [
              BlocProvider<MainBloc>(
                create: (context) {
                  if (_mainBloc.isClosed == true) _mainBloc = MainBloc(context);
                  return _mainBloc;
                },
              ),
              BlocProvider<HomeBloc>(
                create: (context) {
                  if (_homeBloc.isClosed == true) _homeBloc = HomeBloc(context);
                  return _homeBloc;
                },
              ),
              BlocProvider<SellBloc>(
                create: (context) {
                  if (_sellBloc.isClosed == true) _sellBloc = SellBloc(context);
                  return _sellBloc;
                },
              ),
              BlocProvider<DMSBloc>(
                create: (context) {
                  if (_dmsBloc.isClosed == true) _dmsBloc = DMSBloc(context);
                  return _dmsBloc;
                },
              ),
              BlocProvider<PersonnelBloc>(
                create: (context) {
                  if (_personnelBloc.isClosed == true) _personnelBloc = PersonnelBloc(context);
                  return _personnelBloc;
                },
              ),
              BlocProvider<MenuBloc>(
                create: (context) {
                  if (_menuBloc.isClosed == true) _menuBloc = MenuBloc(context);
                  return _menuBloc;
                },
              ),
            ],
            child: BlocListener<MainBloc, MainState>(
              bloc: _mainBloc,
              listener: (context, state) {},
              child: BlocBuilder<MainBloc, MainState>(
                bloc: _mainBloc,
                builder: (context, state) {
                  _mainBloc.init(context);
                  return Stack(
                    children: [
                      PageView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _screens.length,
                        controller: controller,
                        itemBuilder: (context, position)=> _selectedItemPosition == position ? _screens[position] : Container(),
                        onPageChanged: (pageIndex){},
                      ),
                      Visibility(
                        visible: state is MainLoading,
                        child: const PendingAction(),
                      )
                    ],
                  );
                },
              ),
            )),
        bottomNavigationBar: SnakeNavigationBar.color(
          // height: 80,
          behaviour: snakeBarStyle,
          snakeShape: snakeShape,
          shape: bottomBarShape,
          padding: padding,

          ///configuration for SnakeNavigationBar.color
          snakeViewColor: selectedColor,
          selectedItemColor:
          snakeShape == SnakeShape.indicator ? selectedColor : null,
          unselectedItemColor: unselectedColor,

          ///configuration for SnakeNavigationBar.gradient
          // snakeViewGradient: selectedGradient,
          // selectedItemGradient: snakeShape == SnakeShape.indicator ? selectedGradient : null,
          // unselectedItemGradient: unselectedGradient,

          showUnselectedLabels: true,
          showSelectedLabels: true,

          currentIndex: _selectedItemPosition,
          onTap: (index) {
            setState(() {
              _selectedItemPosition = index;
              controller.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(EneftyIcons.home_2_outline), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(EneftyIcons.bag_2_outline), label: 'Bán hàng'),
            BottomNavigationBarItem(icon: Icon(EneftyIcons.scan_barcode_bold), label: 'Quét'),
            BottomNavigationBarItem(icon: Icon(EneftyIcons.calendar_3_outline), label: 'Gặp gỡ'),
            BottomNavigationBarItem(icon: Icon(EneftyIcons.menu_2_outline), label: 'Mở rộng')
          ],
          selectedLabelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  void _exitApp(BuildContext context) {
    List<Widget> actions = [
      ElevatedButton(
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        child: const Text('No',
            style:
            TextStyle(
              color: Colors.orange,
              fontSize: 14,
            )),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
        child: const Text(
            'Yes',
            style:TextStyle(
              color: Colors.orange,
              fontSize: 14,)
        ),
      )
    ];

    Utils.showDialogTwoButton(
        context: context,
        title: 'Notice',
        contentWidget: const Text(
            'ExitApp',
            style:TextStyle(fontSize: 16.0)),
        actions: actions);
  }
}
