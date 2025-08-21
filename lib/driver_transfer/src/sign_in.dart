// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/date_symbol_data_local.dart';
//
// import '../api/api_utils.dart';
// import '../api/models/user_model.dart';
// import '../helper/constant.dart';
//
// class SignInSSE extends StatefulWidget {
//   const SignInSSE({super.key});
//
//   @override
//   State<SignInSSE> createState() => _SignInSSEState();
// }
//
// class _SignInSSEState extends State<SignInSSE> {
//   final account = TextEditingController();
//   final password = TextEditingController();
//   String error = '';
//   late SharedPreferences pref;
//   bool load = true;
//
//   @override
//   void initState() {
//     initializeDateFormatting();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       SharedPreferences.getInstance().then((value) {
//         pref = value;
//         if (pref.containsKey('account')) {
//           showLoaderDialog(context);
//           user = UserModel.fromJson(jsonDecode(pref.getString('account')!));
//           isAccess().then((res) {
//             cancelLoaderDialog(context);
//             if (res) {
//               if (user.dataUser!.isManager!) {
//                 Navigator.pushReplacement(
//                     context, MaterialPageRoute(builder: (context) => const ManagerScreen()));
//               } else {
//                 Navigator.pushReplacement(
//                     context, MaterialPageRoute(builder: (context) => const EmployeeScreen()));
//               }
//             } else {
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (context) => const CheckPermission()));
//             }
//           });
//         }
//       });
//     });
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       extendBodyBehindAppBar: true,
//       backgroundColor: white,
//       appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           systemOverlayStyle: const SystemUiOverlayStyle(
//               statusBarColor: Colors.transparent,
//               statusBarBrightness: Brightness.light,
//               statusBarIconBrightness: Brightness.dark)),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 56),
//           Center(child: Image(image: welcomeAsset, height: 200)),
//           const SizedBox(height: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             color: white,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 setText('Tài khoản', 13),
//                 const SizedBox(height: 10),
//                 Container(
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8), border: Border.all(color: gray)),
//                     child: TextFormField(
//                       controller: account,
//                       style: const TextStyle(
//                           fontSize: 15, fontWeight: FontWeight.normal, color: black),
//                       decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           isDense: true,
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                           hintText: 'Nhập tài khoản',
//                           hintStyle: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.normal,
//                               color: Color(0xffc7c7c7))),
//                     )),
//                 const SizedBox(height: 20),
//                 setText('Mật khẩu', 13),
//                 const SizedBox(height: 10),
//                 Container(
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8), border: Border.all(color: gray)),
//                     child: TextFormField(
//                       controller: password,
//                       obscureText: true,
//                       style: const TextStyle(
//                           fontSize: 15, fontWeight: FontWeight.normal, color: black),
//                       decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           isDense: true,
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                           hintText: 'Nhập mật khẩu',
//                           hintStyle: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.normal,
//                               color: Color(0xffc7c7c7))),
//                     )),
//                 const SizedBox(height: 20),
//                 setText(error, 15, color: red, fontWeight: FontWeight.w500),
//                 const SizedBox(height: 30),
//                 GestureDetector(
//                   onTap: onLogin,
//                   child: Container(
//                     decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: blue),
//                     height: 50,
//                     alignment: Alignment.center,
//                     child: setText('Đăng nhập', 16, color: white, fontWeight: FontWeight.w600),
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   void onLogin() {
//     FocusManager.instance.primaryFocus?.unfocus();
//     if (account.text.isEmpty && password.text.isEmpty) {
//       setState(() {
//         error = 'Tài khoản và mật khẩu không được để trống';
//       });
//     } else if (account.text.isEmpty) {
//       setState(() {
//         error = 'Tài khoản không được để trống';
//       });
//     } else if (password.text.isEmpty) {
//       setState(() {
//         error = 'Mật khẩu không được để trống';
//       });
//     } else {
//       showLoaderDialog(context);
//       login(account: account.text, pass: password.text).then((value) {
//         setState(() {
//           user = value;
//         });
//         pref.setString('account', jsonEncode(value));
//         cancelLoaderDialog(context);
//         isAccess().then((res) {
//           if (res) {
//             if (user.dataUser!.isManager!) {
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (context) => const ManagerScreen()));
//             } else {
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (context) => const EmployeeScreen()));
//             }
//           } else {
//             Navigator.pushReplacement(
//                 context, MaterialPageRoute(builder: (context) => const CheckPermission()));
//           }
//         });
//       }).onError((error, stackTrace) {
//         cancelLoaderDialog(context);
//       });
//     }
//   }
// }
