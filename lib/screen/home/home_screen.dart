// // ignore_for_file: library_private_types_in_public_api
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// // import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:dms/model/database/database_models.dart' as models;
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:syncfusion_flutter_core/theme.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
// import '../../model/database/database_models.dart';
// import '../../model/models/bar_chart_model.dart';
// import '../../model/network/response/table_chart_response.dart';
// import '../../themes/colors.dart';
// import '../../utils/const.dart';
// import '../../utils/size_config.dart';
// import '../widget/custom_dropdown.dart';
// import '../widget/pending_action.dart';
// import 'component/bar_chart_graph.dart';
// import 'home_bloc.dart';
// import 'home_state.dart';
// import 'home_event.dart';
//
// List<Map<String,dynamic>> _listValuesCells = [];
// int _rowsPerPage = 15;
// List<Map<String,dynamic>> _paginatedDataSource = [];
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key,}) : super(key: key);
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//
//   late List<BarChartGroupData> rawBarGroups;
//   late List<BarChartGroupData> showingBarGroups;
//
//   List<HeaderData> _listHeader = [];
//   final ColumnSizer _columnSizer = ColumnSizer();
//
//   double _tongDT=0;double _tongCP=0;
//
//   late HomeBloc _bloc;
//   SelectionMode selectionMode = SelectionMode.single;
//   final DataGridController _dataGridController = DataGridController();
//   AutoRowHeightDataGridSource _autoRowHeightDataGridSource = AutoRowHeightDataGridSource(listHeader: []);
//
//   @override
//   void initState() {
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//         statusBarIconBrightness: Brightness.light,
//         statusBarColor: Colors.transparent
//     ));
//     // TODO: implement initState
//     super.initState();
//     _bloc = HomeBloc(context);
//     _bloc.add(GetPrefsHomeEvent());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return BlocListener<HomeBloc,HomeState>(
//       bloc: _bloc,
//       listener: (context,state){
//         if(state is GetPrefsSuccess){
//           _bloc.add(GetDataDefault());
//         }
//         else if(state is GetPrefsFail){
//           _bloc.add(GetPrefsHomeEvent());
//         }
//         else if(state is ChangeTimeValueSuccess){
//           if(Const.reportHome == true){
//             _bloc.add(GetReportData(reportId: _bloc.reportId.toString(),timeId:_bloc.timeId.toString(),));
//           }
//
//         }else if(state is GetDataSuccess){}
//         else if(state is GetDefaultDataSuccess){
//           if(Const.reportHome == true){
//             _listHeader = _bloc.listHeaderData;
//             _listValuesCells = _bloc.listValuesCells;
//
//             if(_listValuesCells.isNotEmpty){
//               _paginatedDataSource =
//                   _listValuesCells.getRange(0, ((_listValuesCells.length) >= 14 ? 14 : (_listValuesCells.length))).toList(growable: false);
//               _autoRowHeightDataGridSource = AutoRowHeightDataGridSource(listHeader: _listHeader);
//             }
//           }
//           // else if(Const.reportHome == false){
//           //   _bloc.add(SetStateEvent());
//           // }
//         }
//       },
//       child: BlocBuilder<HomeBloc,HomeState>(
//         bloc: _bloc,
//         builder: (BuildContext context, HomeState state){
//           return Scaffold(
//             backgroundColor: Colors.white.withOpacity(.09),
//             body: buildBody(context,state),
//           );
//         },
//       ),
//     );
//   }
//
//   buildBody(BuildContext context,HomeState state){
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.only(bottom: 60),
//         child: Column(
//           children: [
//             buildAppBar(),
//             Expanded(
//               child: Stack(
//                 children: [
//                   ListView(
//                     padding: EdgeInsets.zero,
//                     children: [
//                       buildOptions(),
//                       buildChar(),
//                       Visibility(
//                         visible: state is DoNotPermissionViewState,
//                         child: ListView(
//                           padding: EdgeInsets.zero,
//                           scrollDirection: Axis.vertical,
//                           shrinkWrap: true,
//                           children: [
//                             // BarChartGraph(
//                             //   data: data,
//                             // ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 16,right: 16,top: 18),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Container(
//                                             height: 30,width: 6,
//                                             decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.circular(24),
//                                                 color: mainColor
//                                             ),
//                                           ),
//                                           const SizedBox(width: 5,),
//                                           const Text('Tổng doanh thu',style: TextStyle(color: subColor),),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 7,),
//                                       Row(
//                                         children: [
//                                           Text("00,000,000",style: TextStyle(color: mainColor,fontWeight: FontWeight.bold,fontSize: 20),),
//                                           const SizedBox(width: 3,),
//                                           Text('vnđ',style: TextStyle(color: mainColor,fontSize: 12),),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           const Text('Tổng chi phí',style: TextStyle(color: subColor),),
//                                           const SizedBox(width: 5,),
//                                           Container(
//                                             height: 30,width: 6,
//                                             decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.circular(24),
//                                                 color: subColor
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 7,),
//                                       const Row(
//                                         children:[
//                                           Text("00,000,000",style: TextStyle(color: subColor,fontWeight: FontWeight.bold,fontSize: 20),),
//                                           SizedBox(width: 3,),
//                                           Text('vnđ',style: TextStyle(color: subColor,fontSize: 12),),
//                                         ],
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Visibility(
//                         visible: _bloc.dataChartType == Const.CHART && _bloc.chartType == Const.BAR_CHART,
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 16,right: 16,top: 10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Container(
//                                         height: 30,width: 6,
//                                         decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(24),
//                                             color: mainColor
//                                         ),
//                                       ),
//                                       const SizedBox(width: 5,),
//                                       const Text('Tổng doanh thu',style: TextStyle(color: subColor),),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 7,),
//                                   Row(
//                                     children: [
//                                       Text(NumberFormat(Const.amountFormat).format(_bloc.tongDT),style: TextStyle(color: mainColor,fontWeight: FontWeight.bold,fontSize: 20),),
//                                       const SizedBox(width: 3,),
//                                       Text('vnđ',style: TextStyle(color: mainColor,fontSize: 12),),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Row(
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Text('Tổng chi phí',style: TextStyle(color: subColor),),
//                                       const SizedBox(width: 5,),
//                                       Container(
//                                         height: 30,width: 6,
//                                         decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(24),
//                                             color: subColor
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 7,),
//                                   Row(
//                                     children: [
//                                       Text(NumberFormat(Const.amountFormat).format(_bloc.tongCP),style: const TextStyle(color: subColor,fontWeight: FontWeight.bold,fontSize: 20),),
//                                       const SizedBox(width: 3,),
//                                       const Text('vnđ',style: TextStyle(color: subColor,fontSize: 12),),
//                                     ],
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                       Visibility(
//                           visible: _bloc.dataChartType == Const.CHART && _bloc.chartType == Const.PIE_CHART,
//                           child: buildProfitLevel())
//                     ],
//                   ),
//                   Visibility(
//                     visible: state is HomeLoading,
//                     child:const  PendingAction(),
//                   )
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildProfitLevel(){
//     return Padding(
//       padding: const EdgeInsets.only(top: 35),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 16,bottom: 16,right: 8),
//             child: Row(
//               children: [
//                 Text('profit level'.toUpperCase(),style: const TextStyle(color: subColor,fontWeight: FontWeight.bold,fontSize: 17),),
//                 Text(
//                   (_bloc.typeMoney == '%')
//                       ?
//                   ' (tỷ lệ phần trăm doanh thu)'
//                       :
//                   ' (mức doanh thu)',
//                   style:const  TextStyle(color: Colors.blueGrey,fontSize: 12),),
//               ],
//             ),
//           ),
//           ListView.builder(
//               padding: const EdgeInsets.only(top: 10,left: 16,right: 16,bottom: 0),
//               shrinkWrap: true,
//               itemCount: _bloc.pieChart.length,
//               itemBuilder: (context,index) =>
//                   Container(
//                     decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.all(Radius.circular(8)),
//                       color: Colors.white,
//                     ),
//                     padding: const EdgeInsets.only(top: 15,right: 10,left: 10,bottom: 15),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: Row(
//                             children: [
//                               Text((_bloc.typeMoney == '%')
//                                       ?
//                                   '${_bloc.pieChart[index].value}%'
//                                       :
//                                   '${NumberFormat(Const.amountFormat).format(_bloc.pieChart[index].value)}đ',style: TextStyle(color: mainColor,fontSize: 12),),
//                               const SizedBox(width: 5,),
//                               Flexible(
//                                   child: Text(_bloc.pieChart[index].title.toString(),style: const TextStyle(color: Colors.black,fontSize: 14),maxLines: 1,overflow: TextOverflow.ellipsis,)),
//                             ],
//                           ),
//                         ),
//                         const Icon(Icons.equalizer,color: subColor,size: 18,),
//                       ],
//                     ),
//                   )
//           )
//         ],
//       ),
//     );
//   }
//
//   buildAppBar(){
//     return Container(
//       height: 83,
//       width: double.infinity,
//       decoration: BoxDecoration(
//           boxShadow: <BoxShadow>[
//             BoxShadow(
//                 color: Colors.grey.shade200,
//                 offset:const  Offset(2, 4),
//                 blurRadius: 5,
//                 spreadRadius: 2)
//           ],
//           gradient:const LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
//       padding: const EdgeInsets.fromLTRB(16, 35, 16,0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Flexible(
//                   child: Row(
//                     children: [
//                       Flexible(
//                         flex: 2,
//                         child: InkWell(
//                           onTap: (){
//                             // Utils.pushAndRemoveUtilKeepFirstPage(context, InfoCompanyPage(
//                             //   username:  _mainBloc.userName,
//                             //   listInfoUnitsID: _mainBloc.listInfoUnitsID,
//                             //   listInfoUnitsName: _mainBloc.listInfoUnitsName,
//                             //   currentCompanyName: _mainBloc.currentCompanyName,
//                             //   currentCompanyID: _mainBloc.currentCompanyID,
//                             //   getDF: true,
//                             // ));
//                           },
//                           child: Text(
//                             Const.companyName != '' ? Const.companyName : "Công ty ABC - Demo Công ty ABC - Demo Công ty ABC - Demo".toUpperCase(),
//                             style:const  TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
//                             maxLines: 1,overflow: TextOverflow.fade,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 5,),
//                 Text(
//                   Const.storeName != '' ? Const.storeName : Const.unitName,
//                   style: const TextStyle(fontSize: 11,color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10,),
//           InkWell(
//             //onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context)=> NotificationPage())),
//             child: Container(
//               padding:const  EdgeInsets.all(10),
//               child: Stack(
//                 clipBehavior: Clip.none, alignment: Alignment.center,
//                 children:<Widget>[
//                   Icon(
//                     MdiIcons.bellOutline,
//                     size: 25,
//                     color: Colors.white,
//                   ),
//                   // Visibility(
//                   //   visible: !Utils.isEmpty(_mainBloc.countNotifyUnRead)
//                   //       &&
//                   //       _mainBloc.countNotifyUnRead > 0
//                   //   ,
//                   //   child: Positioned(
//                   //     top: -7,
//                   //     right: -5,
//                   //     child: Container(
//                   //       alignment: Alignment.center,
//                   //       padding: EdgeInsets.all(2),
//                   //       decoration: BoxDecoration(
//                   //         color: blue,
//                   //         borderRadius: BorderRadius.circular(9),
//                   //       ),
//                   //       constraints: BoxConstraints(
//                   //         minWidth: 17,
//                   //         minHeight: 17,
//                   //       ),
//                   //       child: Text(
//                   //         !Utils.isEmpty(_mainBloc.countNotifyUnRead)
//                   //             &&
//                   //             _mainBloc.countNotifyUnRead > 0
//                   //             ? _mainBloc.countNotifyUnRead.toString()
//                   //             : "",
//                   //         style: TextStyle(
//                   //           color: Colors.white,
//                   //           fontSize: 10,
//                   //         ),
//                   //         textAlign: TextAlign.center,
//                   //       ),
//                   //     ),
//                   //   ),
//                   // )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   buildOptions() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 10),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color:const Color.fromARGB(198, 0, 51, 114),style: BorderStyle.solid,width: 1.1)
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 GestureDetector(
//                   onTap:(){
//                     if(_bloc.timeId != '001' && Const.reportHome == true){
//                       _bloc.pieChart.clear();
//                       _listValuesCells.clear();
//                       _bloc.add(ChangeValueTime(timeId: '001'));
//                     }
//                   },
//                   child: Container(
//                     padding:const EdgeInsets.symmetric(horizontal: 5,vertical: 3),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text('Days',style: TextStyle(color: Colors.black,fontSize: 13),),
//                         Visibility(
//                           visible: _bloc.timeId == '001',
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 2),
//                             child: Container(
//                               width: 40,
//                               height: 2,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(24),
//                                 color: subColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(height: 16,width: 1,color: Colors.grey,),
//                 GestureDetector(
//                   onTap:(){
//                     if(_bloc.timeId != '003' && Const.reportHome == true){
//                       _bloc.pieChart.clear();
//                       _listValuesCells.clear();
//                       _bloc.add(ChangeValueTime(timeId: '003'));
//                     }
//                   },
//                   child: Container(
//                     padding:const EdgeInsets.symmetric(horizontal: 5,vertical: 3),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text('Weeks',style: TextStyle(color: Colors.black,fontSize: 13),),
//                         Visibility(
//                           visible: _bloc.timeId == '003',
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 2),
//                             child: Container(
//                               width: 50,
//                               height: 2,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(24),
//                                 color: subColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(height: 16,width: 1,color: Colors.grey,),
//                 GestureDetector(
//                   onTap:(){
//                     if(_bloc.timeId != '005' && Const.reportHome == true){
//                       _bloc.pieChart.clear();
//                       _listValuesCells.clear();
//                       _bloc.add(ChangeValueTime(timeId: '005'));
//                     }
//                   },
//                   child: Container(
//                     padding:const EdgeInsets.symmetric(horizontal: 5,vertical: 3),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text('Months',style:  TextStyle(color: Colors.black,fontSize: 13),),
//                         Visibility(
//                           visible: _bloc.timeId == '005',
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 2),
//                             child: Container(
//                               width: 50,
//                               height: 2,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(24),
//                                 color: subColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(height: 16,width: 1,color: Colors.grey,),
//                 GestureDetector(
//                   onTap:(){
//                     if(_bloc.timeId != '013' && Const.reportHome == true){
//                       _bloc.pieChart.clear();
//                       _listValuesCells.clear();
//                       _bloc.add(ChangeValueTime(timeId: '013'));
//                     }
//                   },
//                   child: Container(
//                     padding:const EdgeInsets.symmetric(horizontal: 5,vertical: 3),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text('Year',style: TextStyle(color: Colors.black,fontSize: 13),),
//                         Visibility(
//                           visible: _bloc.timeId == '013',
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 2),
//                             child: Container(
//                               width: 40,
//                               height: 2,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(24),
//                                 color: subColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const Divider(
//           color: grey,
//           height: 1,
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
//           child: Const.reportHome == true
//               ?
//           PopupMenuButton(
//             shape: const TooltipShape(),
//             padding: EdgeInsets.zero,
//             offset: const Offset(4, 30),
//             itemBuilder: (BuildContext context) {
//               return <PopupMenuEntry<Widget>>[
//                 PopupMenuItem<Widget>(
//                   child: Container(
//                     decoration: ShapeDecoration(
//                         color: Colors.white,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10))),
//                     height: 300,
//                     width: 550,
//                     child: Scrollbar(
//                       child: ListView.builder(
//                         padding: const EdgeInsets.only(top: 10),
//                         itemCount: _bloc.listReportCategories.length,
//                         itemBuilder: (context, index) {
//                           final trans = _bloc.listReportCategories[index].reportName;
//                           return ListTile(
//                             title: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Flexible(
//                                   child: Text(
//                                     trans.toString(),
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                     ),
//                                     maxLines: 1,overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),Text(
//                                   _bloc.listReportCategories[index].reportId.toString(),
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             subtitle: const Divider(height: 1,),
//                             onTap: () {
//                               _bloc.pieChart.clear();
//                               _listValuesCells.clear();
//                               _bloc.reportId = _bloc.listReportCategories[index].reportId.toString();
//                               _bloc.add(GetReportData(reportId: _bloc.listReportCategories[index].reportId.toString(),timeId:_bloc.timeId.toString(),));
//                               Navigator.pop(context);
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 )
//               ];
//             },
//             child: Row(
//               children: [
//                 Icon(MdiIcons.chartLineVariant,color: Colors.black,size: 18,),
//                 const SizedBox(width: 7,),
//                 Text('Loại báo cáo: ',style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),),
//                 Expanded(child: Text(_bloc.title?.toString()??'',style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.visible,)),
//                 const SizedBox(width: 10,),
//                 const Icon(Icons.arrow_drop_down,color: Colors.black,),
//                 const SizedBox(width: 7,),
//               ],
//             ),
//           )
//               :
//           Row(
//             children: [
//               Icon(MdiIcons.chartLineVariant,color: Colors.black,size: 18,),
//               const SizedBox(width: 7,),
//               Text('Loại báo cáo: ',style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),),
//               Expanded(child: Text('Báo cáo giả định',style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.visible,)),
//               const SizedBox(width: 10,),
//               const Icon(Icons.arrow_drop_down,color: Colors.transparent,),
//               const SizedBox(width: 7,),
//             ],
//           ),
//         ),
//         Visibility(
//           visible: (_bloc.dataChartType != Const.TABLE),
//           child: Padding(
//             padding: EdgeInsets.only(top: 10,bottom: Const.reportHome == true ? 10 : 0),
//             child: Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         (_bloc.typeMoney == '%')
//                             ?
//                         "${_bloc.totalPercentPieChart*100}"
//                             :
//                         Const.reportHome == true ? NumberFormat(Const.amountFormat).format(_bloc.totalProfit) : '00,000,000',
//                         style: const TextStyle(color: subColor,fontWeight: FontWeight.bold,fontSize: 20),),
//                       const SizedBox(width: 3,),
//                       Text(
//                         (_bloc.typeMoney == '%')
//                             ?
//                         'percent (%)'
//                             :
//                         'vnđ',
//                         style: const TextStyle(color: subColor,fontSize: 12),),
//                     ],
//                   ),
//                   const Text('Tổng lợi nhuận',style: TextStyle(color: subColor),),
//                 ],
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }
//
//   buildChar(){
//     return _bloc.dataChartType == null
//         ?
//     Container()
//         :
//     (_bloc.dataChartType == Const.CHART && _bloc.chartType == Const.PIE_CHART)
//         ?
//     pieChartWidget()
//         :
//     tableAndBarChart();
//   }
//
//   Widget pieChartWidget(){
//     return const SizedBox(
//       height: 400,
//       width: double.infinity,
//       child: //_bloc.pieChart.isEmpty
//          // ?
//       Center(child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),)
//           //:
//       //createPieChart(),
//     );
//   }
//
//   // Widget createPieChart() {
//   //   List<charts.Series<models.DataPieChart, String>> seriesList = [];
//   //   seriesList.add(createSeriesPieChart());
//   //
//   //   return charts.PieChart<String>(
//   //     seriesList,
//   //     animate: true,
//   //     animationDuration: const Duration(seconds: 1),
//   //     defaultRenderer: charts.ArcRendererConfig(
//   //         arcWidth: 60,
//   //         strokeWidthPx: 6,
//   //         arcRendererDecorators: [
//   //           charts.ArcLabelDecorator(
//   //               labelPadding: 0,
//   //               showLeaderLines: true,
//   //               outsideLabelStyleSpec: charts.TextStyleSpec(
//   //                   fontSize: 12,
//   //                   fontFamily: GoogleFonts.montserrat().toString(),
//   //                   color: charts.MaterialPalette.black))
//   //         ]
//   //     ),
//   //     // behaviors: [
//   //     //   new charts.InitialSelection(selectedDataConfig: [
//   //     //     new charts.SeriesDatumConfig<String>('Purchases', 'Eating Out'),
//   //     //   ]),
//   //     //   new charts.DomainHighlighter(),
//   //     //   charts.DatumLegend(
//   //     //     position: charts.BehaviorPosition.end,
//   //     //     outsideJustification: charts.OutsideJustification.middleDrawArea,
//   //     //     horizontalFirst: false,
//   //     //     desiredMaxColumns: 1,
//   //     //     cellPadding: const EdgeInsets.only(
//   //     //       right: 4,
//   //     //       bottom: 4,
//   //     //     ),
//   //     //     entryTextStyle: charts.TextStyleSpec(
//   //     //         fontSize: 12, color: charts.MaterialPalette.black),
//   //     //   ),
//   //     // ],
//   //   );
//   // }
//   //
//   // charts.Series<DataPieChart, String> createSeriesPieChart() {
//   //   return charts.Series<DataPieChart, String>(
//   //       id: 'DataPieChart',
//   //       domainFn: (dataPieChart, int) => dataPieChart.title,
//   //       measureFn: (dataPieChart, _) => dataPieChart.value,
//   //       labelAccessorFn: (dataPieChart, _) => '${NumberFormat(Const.amountFormat).format(dataPieChart.value)} ${
//   //       _bloc.typeMoney =='%' ? '%' :'vnđ'
//   //       }',
//   //       colorFn: (dataPieChart, _) => charts.ColorUtil.fromDartColor(dataPieChart.color),
//   //       data: _bloc.pieChart
//   //   );//row.taskValue
//   // }
//
//   Widget tableAndBarChart(){
//
//     double _percentDT = 0;
//     double _percentCP = 0;
//     double _totalMN = 0;
//     _tongDT = _bloc.tongDT;
//     _tongCP =  _bloc.tongCP;
//     _totalMN = _bloc.tongDT - _bloc.tongCP;
//     _percentDT = (_bloc.tongDT / (_bloc.tongDT + _bloc.tongCP));
//     _percentCP = 1 - _percentDT;
//     return SizedBox(
//       height: (_bloc.dataChartType == Const.CHART &&  _bloc.chartType == Const.BAR_CHART) ? 400 : (MediaQuery.of(context).size.height/1.52),
//       width: double.infinity,
//       child: Column(
//         children: <Widget>[
//           Visibility(
//             visible:_bloc.dataChartType == Const.CHART &&  _bloc.chartType == Const.BAR_CHART,
//             child: Expanded(
//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(1, 0, 1, 5),
//                 width: double.infinity,
//                 child: Stack(
//                   children: [
//                     // _bloc.valueCl1.isEmpty ?
//                     // ListView(
//                     //   scrollDirection: Axis.vertical,
//                     //   shrinkWrap: true,
//                     //   children: [
//                     //     BarChartGraph(
//                     //       data: data,
//                     //     ),
//                     //   ],
//                     // )
//                     //     : createBarChart(),
//                     Positioned(
//                       right: 16,
//                       top: 25,
//                       child: Text('DVT'+': ${_bloc.typeMoney}',style: TextStyle(color: grey.withOpacity(0.5),fontSize: 10),),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Visibility(
//             visible:_bloc.dataChartType == Const.TABLE,
//             child:  Expanded(
//               child:   _listValuesCells.isNotEmpty ?
//               Column(
//                 children: [
//                   const SizedBox(height: 12,),
//                   Expanded(
//                     child: SfDataGridTheme(
//                       data: SfDataGridThemeData(
//                         // brightness: SfTheme.of(context).brightness,
//                         gridLineStrokeWidth: 1.0,
//                         headerHoverColor: const Color(0xFF9588D7).withOpacity(0.6),
//                         gridLineColor: subColor.withOpacity(0.4),
//                       ),
//                       child: SfDataGrid(
//                           columnWidthMode: ColumnWidthMode.auto,
//                           allowSorting: true,
//                           gridLinesVisibility: GridLinesVisibility.both,
//                           headerGridLinesVisibility: GridLinesVisibility.both,
//                           selectionMode: selectionMode,
//                           controller: _dataGridController,
//                           onCellTap: (index){},
//                           source: _autoRowHeightDataGridSource,
//                           columnSizer: _columnSizer,
//                           columns: List<GridColumn>.generate(_listHeader.length, (int index){
//                             return  GridColumn(
//                               label: Center(child: Text(_listHeader[index].name.toString().trim(),style: const TextStyle(color: subColor),)),
//                               columnName: _listHeader[index].field.toString().trim(),
//                               maximumWidth: 250,
//                               columnWidthMode: ColumnWidthMode.none,
//                             );
//                           })
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: 60,
//                     decoration: BoxDecoration(
//                         color: SfTheme.of(context).dataPagerThemeData.backgroundColor,
//                         border: const Border(
//                             top: BorderSide(
//                                 width: .5,
//                                 color: Colors.grey),
//                             bottom: BorderSide.none,
//                             left: BorderSide.none,
//                             right: BorderSide.none)),
//                     child: Align(alignment: Alignment.center, child: _autoRowHeightDataGridSource.listHeader.isNotEmpty ? _getDataPager() : Container()),
//                   )
//                 ],
//               )
//                   :
//              const Center(
//                 child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey))),
//             ),
//           ),
//           ///
//           // Visibility(
//           //   visible: indexChart == 2,
//           //   child: Expanded(
//           //     child: Padding(
//           //       padding: const EdgeInsets.only(left: 16,right: 8,bottom: 2),
//           //       child:  Card(
//           //         elevation: 5,
//           //         clipBehavior: Clip.antiAlias,
//           //         shape: RoundedRectangleBorder(
//           //             borderRadius: BorderRadius.all(Radius.circular(8))
//           //         ),
//           //         child: charts.LineChart(
//           //             _seriesLineData,
//           //             defaultRenderer: new charts.LineRendererConfig(
//           //               includeLine: true,
//           //               layoutPaintOrder: 10,
//           //               roundEndCaps: true,
//           //               includePoints: true,
//           //               includeArea: true,
//           //               stacked: true,
//           //
//           //             ),
//           //             animate: true,
//           //             animationDuration: Duration(seconds: 1),
//           //             behaviors: [
//           //               // new charts.ChartTitle('Years',
//           //               //     behaviorPosition: charts.BehaviorPosition.bottom,
//           //               //     titleOutsideJustification:charts.OutsideJustification.middleDrawArea),
//           //               // new charts.ChartTitle('Sales',
//           //               //     behaviorPosition: charts.BehaviorPosition.start,
//           //               //     titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
//           //               // new charts.ChartTitle('Departments',
//           //               //   behaviorPosition: charts.BehaviorPosition.end,
//           //               //   titleOutsideJustification:charts.OutsideJustification.middleDrawArea,
//           //               // )
//           //             ]
//           //         ),
//           //       ),
//           //     ),),
//           // ),
//         ],
//       ),
//     );
//   }
//
//   Widget _getDataPager() {
//     return SfDataPagerTheme(
//       data: SfDataPagerThemeData(
//         // backgroundColor: Brightness.light,
//         selectedItemColor: subColor,
//       ),
//       child: SfDataPager(
//         delegate: _autoRowHeightDataGridSource,
//         direction: Axis.horizontal,
//         pageCount: (int.parse((_listValuesCells.length / _rowsPerPage).toString().split('.')[1]) > 5 ? (_listValuesCells.length / _rowsPerPage + 1) : _listValuesCells.length / _rowsPerPage ),
//       ),
//     );
//   }
//
//   // Widget createBarChart() {
//   //   List<charts.Series<models.ReportDataModels, String>> seriesList = [];
//   //   String id = _bloc.legend1?.trim()??'Doanh thu';
//   //   String id2 = _bloc.legend2?.trim()??'Chi phí';
//   //   seriesList.add(createSeriesBarChart(id, _bloc.valueCl1,mainColor));
//   //   seriesList.add(createSeriesBarChart(id2,  _bloc.valueCl2,subColor));
//   //
//   //   return Padding(
//   //     padding: const EdgeInsets.only(left:2,top: 0,bottom: 10,right: 0),
//   //     child: charts.BarChart(
//   //       seriesList,
//   //       animate: true,
//   //       animationDuration: const Duration(seconds: 1),
//   //       barGroupingType: charts.BarGroupingType.grouped,
//   //       primaryMeasureAxis: const charts.NumericAxisSpec(
//   //         tickProviderSpec: charts.BasicNumericTickProviderSpec(
//   //           desiredMinTickCount: 6,
//   //           desiredMaxTickCount: 10,
//   //         ),
//   //       ),
//   //       secondaryMeasureAxis: const charts.NumericAxisSpec(
//   //           tickProviderSpec: charts.BasicNumericTickProviderSpec(
//   //               desiredTickCount: 6, desiredMaxTickCount: 10)),
//   //       selectionModels: [
//   //         charts.SelectionModelConfig(
//   //             changedListener: (charts.SelectionModel model) {
//   //               if (model.hasDatumSelection)
//   //                 print(model.selectedSeries[0]
//   //                     .measureFn(model.selectedDatum[0].index));
//   //             })
//   //       ],
//   //     ),
//   //   );
//   // }
//   //
//   // charts.Series<models.ReportDataModels, String> createSeriesBarChart(String id,var data,Color color) {
//   //   return charts.Series<models.ReportDataModels, String>(
//   //     id: id,
//   //     domainFn: (models.ReportDataModels wear, _) => 'T ${wear.times}',
//   //     measureFn: (models.ReportDataModels wear, _) => wear.values,
//   //     data: data,
//   //     fillPatternFn: (_,__)=>charts.FillPatternType.solid,
//   //     colorFn: (_,__)=>charts.ColorUtil.fromDartColor(color),
//   //   );
//   // }
//   //
//   // final List<BarChartModel> data = [
//   //   BarChartModel(
//   //     year: "${DateTime.now().year-6}",
//   //     financial: 250,
//   //     color: charts.ColorUtil.fromDartColor
//   //       (const Color(0xFF47505F)),
//   //   ),
//   //   BarChartModel(
//   //     year: "${DateTime.now().year-5}",
//   //     financial: 300,
//   //     color: charts.ColorUtil.fromDartColor
//   //       (Colors.red),
//   //   ),
//   //   BarChartModel(
//   //     year: "${DateTime.now().year-4}",
//   //     financial: 100,
//   //     color: charts.ColorUtil.fromDartColor
//   //       (Colors.green),
//   //   ),
//   //   BarChartModel(
//   //     year: "${DateTime.now().year-3}",
//   //     financial: 450,
//   //     color: charts.ColorUtil.fromDartColor
//   //       (Colors.yellow),
//   //   ),
//   //   BarChartModel(
//   //     year: "${DateTime.now().year-2}",
//   //     financial: 630,
//   //     color: charts.ColorUtil.fromDartColor
//   //       (Colors.lightBlueAccent),
//   //   ),
//   //   BarChartModel(
//   //     year: "${DateTime.now().year-1}",
//   //     financial: 1000,
//   //     color: charts.ColorUtil.fromDartColor
//   //       (Colors.pink),
//   //   ),
//   //   BarChartModel(
//   //     year: "${DateTime.now().year}",
//   //     financial: 400,
//   //     color: charts.ColorUtil.fromDartColor
//   //       (Colors.purple),
//   //   ),
//   // ];
//
// }
//
// class AutoRowHeightDataGridSource extends DataGridSource {
//
//   final List<HeaderData> listHeader;
//
//   AutoRowHeightDataGridSource({required this.listHeader}) {
//     buildPaginatedDataGridRows();
//   }
//
//   List<DataGridRow>  dataGrid = [];
//
//   @override
//   List<DataGridRow> get rows => dataGrid;
//
//   void buildPaginatedDataGridRows() {
//
//     List<DataGridRow> listDataGridRow=[];
//
//     for (var element in _paginatedDataSource) {
//       List<DataGridCell> listDataGridCell=[];
//       for (var headerFiled in listHeader) {
//           DataGridCell dataGridCell = DataGridCell(
//               columnName: headerFiled.field.toString(),
//               value: element[headerFiled.field].toString().trim()
//           );
//           listDataGridCell.add(dataGridCell);
//       }
//       DataGridRow dataGridRow = DataGridRow(
//           cells:  listDataGridCell
//       );
//       listDataGridRow.add(dataGridRow);
//     }
//     dataGrid = listDataGridRow;
//   }
//
//   int get rowCount => _listValuesCells.length;
//
//   @override
//   DataGridRowAdapter? buildRow(DataGridRow row) {
//     // TODO: implement buildRow
//     return DataGridRowAdapter(
//         cells: row.getCells().map<Widget>((e) {
//           return Container(
//             alignment: Alignment.center,
//             padding: const EdgeInsets.all(8.0),
//             child: Text(e.value.toString()),
//           );
//         }).toList());
//   }
//
//   @override
//   Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
//     final int _startIndex = newPageIndex * _rowsPerPage;
//     int _endIndex = _startIndex + _rowsPerPage;
//     if (_endIndex > _paginatedDataSource.length) {
//       _endIndex = _paginatedDataSource.length;
//     }
//
//     if((_startIndex + _rowsPerPage) > _listValuesCells.length){
//       _rowsPerPage = _listValuesCells.length % _rowsPerPage;
//     }else{
//       _rowsPerPage = 15;
//     }
//
//     _paginatedDataSource = _listValuesCells
//         .getRange(_startIndex, _startIndex + _rowsPerPage)
//         .toList(growable: false);
//     // notifyDataSourceListeners();
//     buildPaginatedDataGridRows();
//     notifyListeners();
//     return Future<bool>.value(true);
//   }
//   @override
//
//   bool shouldRecalculateColumnWidths() {
//     return true;
//   }
// }
//
