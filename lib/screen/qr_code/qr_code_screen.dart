// import 'dart:io';
// import 'dart:math';
//
// import 'package:dms/model/database/data_local.dart';
// import 'package:dms/screen/qr_code/qr_code_bloc.dart';
// import 'package:dms/screen/qr_code/qr_code_sate.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutterflow_ui/flutterflow_ui.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:styled_divider/styled_divider.dart';
//
// import '../../themes/colors.dart';
//
// class QRCodeScreen extends StatefulWidget {
//   const QRCodeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<QRCodeScreen> createState() => _QRCodeScreenState();
// }
//
// class _QRCodeScreenState extends State<QRCodeScreen> with TickerProviderStateMixin {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   Barcode? result;
//   late QRViewController controller;
//   late QRCodeBloc _bloc;
//   late TabController tabController;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     tabController = TabController(vsync: this, length: DataLocal.listFunctionQrCode.length);
//     _bloc = QRCodeBloc(context);
//     if (Platform.isAndroid) {
//       controller.pauseCamera();
//     } else if (Platform.isIOS) {
//       controller.resumeCamera();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
//       appBar: AppBar(
//         backgroundColor: FlutterFlowTheme.of(context).primary,
//         automaticallyImplyLeading: false,
//         leading: FlutterFlowIconButton(
//           borderColor: FlutterFlowTheme.of(context).primary,
//           borderRadius: 30,
//           borderWidth: 1,
//           buttonSize: 40,
//           fillColor: FlutterFlowTheme.of(context).accent1,
//           icon: Icon(
//             Icons.chevron_left,
//             color: Colors.white,
//             size: 30,
//           ),
//           onPressed: () {
//             print('IconButton pressed ...');
//           },
//         ),
//         title: Text(
//           'Quét Mọi Thứ',
//           style: FlutterFlowTheme.of(context).headlineMedium.override(
//             fontFamily: 'Plus Jakarta Sans',
//             color: Colors.white,
//             fontSize: 22,
//           ),
//         ),
//         actions: [],
//         centerTitle: true,
//         elevation: 2,
//       ),
//       body: SafeArea(
//         top: true,
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         FlutterFlowTheme.of(context).primary,
//                         FlutterFlowTheme.of(context).info
//                       ],
//                       stops: [0, 1],
//                       begin: AlignmentDirectional(0, -1),
//                       end: AlignmentDirectional(0, 1),
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.max,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
//                         child: Text(
//                           'Quét Vi Trí',
//                           style: FlutterFlowTheme.of(context)
//                               .titleLarge
//                               .override(
//                             fontFamily: 'Plus Jakarta Sans',
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
//                         child: Container(
//                           width: 230,
//                           height: 230,
//                           decoration: BoxDecoration(
//                             color: FlutterFlowTheme.of(context)
//                                 .secondaryBackground,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                       ),
//                       Text(
//                         '1234 - 5678',
//                         style:
//                         FlutterFlowTheme.of(context).titleLarge.override(
//                           fontFamily: 'Plus Jakarta Sans',
//                           color: Colors.white,
//                           fontSize: 18,
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.max,
//                           children: [
//                             Container(
//                               width: 20,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 color: FlutterFlowTheme.of(context)
//                                     .primaryBackground,
//                                 borderRadius: BorderRadius.only(
//                                   bottomLeft: Radius.circular(0),
//                                   bottomRight: Radius.circular(16),
//                                   topLeft: Radius.circular(0),
//                                   topRight: Radius.circular(16),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.max,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   StyledDivider(
//                                     height: 2,
//                                     thickness: 1,
//                                     color: Colors.white,
//                                     lineStyle: DividerLineStyle.dashed,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               width: 20,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 color: FlutterFlowTheme.of(context)
//                                     .primaryBackground,
//                                 borderRadius: BorderRadius.only(
//                                   bottomLeft: Radius.circular(16),
//                                   bottomRight: Radius.circular(0),
//                                   topLeft: Radius.circular(16),
//                                   topRight: Radius.circular(0),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.max,
//                           children: [
//                             Container(
//                               width: double.infinity,
//
//                               // color: Colors.white,
//                               child: Padding(
//                                 padding: EdgeInsetsDirectional.fromSTEB(26, 0, 26, 10),
//                                 child: TabBar(
//                                   controller: tabController,
//                                   unselectedLabelColor: white,
//                                   labelColor: orange,
//                                   labelStyle: const TextStyle(fontWeight: FontWeight.normal),
//                                   isScrollable: true,
//                                   // indicatorPadding: EdgeInsets.only(top: 6,bottom: 6,right: 8,left: 8),
//
//                                   indicator:const BoxDecoration(color: white, borderRadius:  BorderRadius.all(Radius.circular(10))),
//                                   tabs: List<Widget>.generate(DataLocal.listFunctionQrCode.length, (int index) {
//                                     return  Tab(
//                                       text: DataLocal.listFunctionQrCode[index].toString(),
//                                     );
//                                   }),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: TabBarView(
//                                   controller: tabController,
//                                   children: List<Widget>.generate(DataLocal.listFunctionQrCode.length, (int index) {
//                                     for (int i = 0; i <= DataLocal.listFunctionQrCode.length; i++) {
//                                       if (i == index) {
//                                         return Placeholder();
//                                       }
//                                     }
//                                     return const Text('');
//                                   })
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   buildBody(BuildContext context, QRCodeState state){
//     return Scaffold(
//       body: Stack(
//         children: <Widget>[
//           // QRView(
//           //   key: qrKey,
//           //   onQRViewCreated: _onQRViewCreated,
//           //
//           // ),
//           // Positioned(
//           //   bottom: 60,right: 12,left: 12,
//           //   child:
//           //   Center(
//           //     child: (result != null)
//           //         ? Text(
//           //         'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
//           //         : Text('Scan a code'),
//           //   ),
//           // )
//         ],
//       ),
//     );
//   }
//
//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         result = scanData;
//         print(result);
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
// }
