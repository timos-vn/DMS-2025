// import 'package:dms/screen/dms/dms_screen.dart';
// import 'package:dms/screen/home/home_screen.dart';
// import 'package:dms/screen/menu/menu_screen.dart';
// import 'package:dms/themes/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
//
// import '../../utils/const.dart';
// import '../../utils/utils.dart';
// import '../dms/dms_bloc.dart';
// import '../home/home_bloc.dart';
// import '../home/home_screen2.dart';
// import '../menu/menu_bloc.dart';
// import '../personnel/personnel_bloc.dart';
// import '../qr_code/component/custom_qr_code.dart';
// import '../qr_code/qr_code_screen.dart';
// import '../sell/sell_bloc.dart';
// import '../sell/sell_screen.dart';
// import '../widget/pending_action.dart';
// import 'component/custom_tab_bar.dart';
// import 'main_bloc.dart';
// import 'main_event.dart';
// import 'main_state.dart';
//
// class MainScreen extends StatefulWidget {
//   final List<Widget> listMenu;
//   final List<PersistentBottomNavBarItem> listNavItem;
//   final String? userName;
//   final String? currentAddress;
//   final int? rewardPoints;
//
//   const MainScreen({Key? key,required this.listMenu,required this.listNavItem,this.userName,this.currentAddress,this.rewardPoints}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _MainScreenState();
// }
//
//
// class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{
//   late MainBloc _mainBloc;
//   late HomeBloc _homeBloc;
//   late SellBloc _sellBloc;
//   late DMSBloc _dmsBloc;
//   late PersonnelBloc _personnelBloc;
//   late MenuBloc _menuBloc;
//
//   PersistentTabController? _controller;
//
//   int _lastIndexToHome = 0;
//   int _currentIndex = 0;
//
//
//   GlobalKey<NavigatorState>? _currentTabKey;
//   // late List<BottomNavigationBarItem> listBottomItems;
//   final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
//   final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();
//   final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();
//   final GlobalKey<NavigatorState> fourthTabNavKey = GlobalKey<NavigatorState>();
//   final GlobalKey<NavigatorState> fifthTabNavKey = GlobalKey<NavigatorState>();
//
//   // void showUpdate(){
//   //   showDialog(
//   //       context: context,
//   //       builder: (context) {
//   //         return WillPopScope(
//   //           onWillPop: () async => false,
//   //           child: const ConfirmUpdateVersionPage(
//   //             title: 'Đã có phiên bản mới',
//   //             content: 'Cập nhật ứng dụng của bạn để có trải nghiệm tốt nhất',
//   //             type: 0,
//   //           ),
//   //         );
//   //       });
//   // }
//   PageController _myPage = PageController(initialPage: 0);
//
//   late AnimationController? _animationController;
//   late AnimationController? _onBoardingAnimController;
//   late Animation<double> _onBoardingAnim;
//   late Animation<double> _sidebarAnim;
//   bool _showOnBoarding = false;
//
//   Widget _tabBody = Container(color: Color(0xFFF2F6FF));
//
//   final List<Widget> _screens = [
//     HomeScreen2(),
//     SellScreen(),
//     QRCodeGeneratorWidget(),
//     DMSScreen(),
//     MenuScreen()
//   ];
//
//   @override
//   void initState() {
//
//     _mainBloc = MainBloc(context);
//     _homeBloc = HomeBloc(context);
//     _sellBloc = SellBloc(context);
//     _dmsBloc = DMSBloc(context);
//     _personnelBloc = PersonnelBloc(context);
//     _menuBloc = MenuBloc(context);
//     _controller = PersistentTabController(initialIndex: 0);
//     _currentTabKey = firstTabNavKey;
//
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       upperBound: 1,
//       vsync: this,
//     );
//     _onBoardingAnimController = AnimationController(
//       duration: const Duration(milliseconds: 350),
//       upperBound: 1,
//       vsync: this,
//     );
//
//     _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
//       parent: _animationController!,
//       curve: Curves.linear,
//     ));
//
//     _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
//       parent: _onBoardingAnimController!,
//       curve: Curves.linear,
//     ));
//
//     _tabBody = _screens.first;
//
//     _mainBloc.add(GetPrefs());
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: ()async{
//         bool isSuccess = await _currentTabKey!.currentState!.maybePop();
//         if (!isSuccess && _currentIndex != Const.HOME) {
//           _lastIndexToHome = Const.HOME;
//           _currentIndex = _lastIndexToHome;
//           _currentTabKey = firstTabNavKey;
//         }
//         if (!isSuccess) {
//           // ignore: use_build_context_synchronously
//           _exitApp(context);
//         }
//         return false;
//       },
//       child: Scaffold(
//         // bottomNavigationBar: RepaintBoundary(
//         //   child: AnimatedBuilder(
//         //     animation: !_showOnBoarding ? _sidebarAnim : _onBoardingAnim,
//         //     builder: (context, child) {
//         //       return Transform.translate(
//         //         offset: Offset(
//         //             0,
//         //             !_showOnBoarding
//         //                 ? _sidebarAnim.value * 300
//         //                 : _onBoardingAnim.value * 200),
//         //         child: child,
//         //       );
//         //     },
//         //     child: Stack(
//         //       alignment: Alignment.center,
//         //       children: [
//         //         CustomTabBar(
//         //           onTabChange: (tabIndex) {
//         //             setState(() {
//         //               _tabBody = _screens[tabIndex];
//         //             });
//         //           },
//         //         )
//         //       ],
//         //     ),
//         //   ),
//         // ),
//         body: MultiBlocProvider(
//             providers: [
//               BlocProvider<MainBloc>(
//                 create: (context) {
//                   if (_mainBloc.isClosed == true) _mainBloc = MainBloc(context);
//                   return _mainBloc;
//                 },
//               ),
//               BlocProvider<HomeBloc>(
//                 create: (context) {
//                   if (_homeBloc.isClosed == true) _homeBloc = HomeBloc(context);
//                   return _homeBloc;
//                 },
//               ),
//               BlocProvider<SellBloc>(
//                 create: (context) {
//                   if (_sellBloc.isClosed == true) _sellBloc = SellBloc(context);
//                   return _sellBloc;
//                 },
//               ),
//               BlocProvider<DMSBloc>(
//                 create: (context) {
//                   if (_dmsBloc.isClosed == true) _dmsBloc = DMSBloc(context);
//                   return _dmsBloc;
//                 },
//               ),
//               BlocProvider<PersonnelBloc>(
//                 create: (context) {
//                   if (_personnelBloc.isClosed == true) _personnelBloc = PersonnelBloc(context);
//                   return _personnelBloc;
//                 },
//               ),
//               BlocProvider<MenuBloc>(
//                 create: (context) {
//                   if (_menuBloc.isClosed == true) _menuBloc = MenuBloc(context);
//                   return _menuBloc;
//                 },
//               ),
//             ],
//             child: BlocListener<MainBloc, MainState>(
//               bloc: _mainBloc,
//               listener: (context, state) {
//                 // if (state is GetVersionGoLiveSuccess) {
//                 //
//                 // }else if(state is GetPrefsSuccess){
//                 //   _mainBloc.add(GetLocationEvent());
//                 // }
//                 // else if(state is GetLisPromotionsSuccess){
//                 //
//                 // }
//                 // if (state is LogoutSuccess) {
//                 //   _lastIndexToShop = Const.HOME;
//                 //   _currentIndex = _lastIndexToShop;
//                 //   _currentTabKey = firstTabNavKey;
//                 // }
//                 // if (state is NavigateToNotificationState) {
//                 // }
//               },
//               child: BlocBuilder<MainBloc, MainState>(
//                 bloc: _mainBloc,
//                 builder: (context, state) {
//                   // if (state is MainPageState) {
//                   //   _currentIndex = state.position;
//                   //   if (_currentIndex == Const.HOME) {}
//                   //   else if (_currentIndex == Const.SALE) {}
//                   //   else if (_currentIndex == Const.DMS) {}
//                   // }
//                   // if (state is MainProfile) {
//                   //   _currentTabKey = fifthTabNavKey;
//                   // }
//                   _mainBloc.init(context);
//                   // return PageView(
//                   //   controller: _myPage,
//                   //   onPageChanged: (int) {
//                   //     print('Page Changes to index $int');
//                   //   },
//                   //   children: <Widget>[
//                   //
//                   //   ],
//                   //   physics: NeverScrollableScrollPhysics(), // Comment this if you need to use Swipe.
//                   // );
//
//                   return Stack(
//                     children: [
//                       PersistentTabView(
//                         context,
//                         controller: _controller,
//                         screens: widget.listMenu,
//                         items: widget.listNavItem,
//                         confineInSafeArea: true,
//
//                         handleAndroidBackButtonPress: true,
//                         resizeToAvoidBottomInset: true,
//                         stateManagement: true,
//                         navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
//                             ? 0.0
//                             : kBottomNavigationBarHeight,
//                         hideNavigationBarWhenKeyboardShows: true,
//                         margin: const EdgeInsets.all(0.0),
//                         popActionScreens: PopActionScreensType.all,
//                         bottomScreenMargin: 0.0,
//                         onWillPop: (context) async {
//                           await showDialog(
//                             context: context!,
//                             useSafeArea: true,
//                             builder: (context) => Container(
//                               height: 50.0,
//                               width: 50.0,
//                               color: Colors.white,
//                               child: ElevatedButton(
//                                 child: const Text("Close"),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                             ),
//                           );
//                           return false;
//                         },
//                         selectedTabScreenContext: (context) {
//                         },
//                         hideNavigationBar: false,
//                         backgroundColor: Colors.white,
//                         decoration: const NavBarDecoration(
//                           //border: Border.all(),
//                             boxShadow: [
//                               BoxShadow(color: Colors.grey, spreadRadius: 0.1),
//                             ],
//                             //colorBehindNavBar: Colors.indigo,
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(16),
//                               topRight: Radius.circular(16),
//                             )),
//                         popAllScreensOnTapOfSelectedTab: true,
//                         itemAnimationProperties: const ItemAnimationProperties(
//                           duration: Duration(milliseconds: 400),
//                           curve: Curves.ease,
//                         ),
//                         navBarStyle: NavBarStyle.style6, // Choose the nav bar style with this property
//                       ),
//                       Visibility(
//                         visible: state is MainLoading,
//                         child: PendingAction(),
//                       )
//                     ],
//                   );
//                 },
//               ),
//             )),
//       ),
//     );
//   }
//
//   void _exitApp(BuildContext context) {
//     List<Widget> actions = [
//       ElevatedButton(
//         onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
//         child: const Text('No',
//             style:
//             TextStyle(
//               color: Colors.orange,
//               fontSize: 14,
//             )),
//       ),
//       ElevatedButton(
//         onPressed: () {
//           Navigator.of(context, rootNavigator: true).pop();
//           SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//         },
//         child: const Text(
//             'Yes',
//             style:TextStyle(
//               color: Colors.orange,
//               fontSize: 14,)
//         ),
//       )
//     ];
//
//     Utils.showDialogTwoButton(
//         context: context,
//         title: 'Notice',
//         contentWidget: const Text(
//             'ExitApp',
//             style:TextStyle(fontSize: 16.0)),
//         actions: actions);
//   }
// }
