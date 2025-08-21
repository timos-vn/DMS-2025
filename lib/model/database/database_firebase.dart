import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../network/response/get_list_slider_image_response.dart';
import 'data_local.dart';

class DatabaseMethods{
  // getVersionUpdateApp() async{
  //   return await FirebaseFirestore.instance.collection('Version_App').where('key',isEqualTo: 'DMS-SSE').get();
  // }
  getVersionUpdateApp() async{
    return await FirebaseFirestore.instance.collection('SSE-DMS').doc('Version_App').get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      if(Platform.isIOS) {
        print(data['goLiveIOS']);
        // versionGoLiveApp = data['goLiveIOS'];
      }else if(Platform.isAndroid){
        print(data['goLiveAndroid']);
        // versionGoLiveApp = data['goLiveAndroid'];
      }
      print(data['contentUpdate']);
      // contentUpdate = data['contentUpdate'];
      // versionLastUpdate = Const.versionApp;
      // add(UpdateVersionApp());
    },
      onError: (e) =>  print(e),);
  }
  getAccountVipMember() async{
    return await FirebaseFirestore.instance.collection('SSE-DMS').doc('account-vip-member').collection('List-member').get()
        .then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        ListMember item = ListMember(
          userId: docSnapshot.data()['userId'],
          type: docSnapshot.data()['type'],
        );
        DataLocal.listVipMemberFirebase.add(item);
      }
    },
      onError: (e) =>  print(e),);
  }
}

// class DatabaseMethods{
//   getVersionUpdateApp() async{
//     return await FirebaseFirestore.instance.collection('DMS-SSE').doc('Version_App').get();
//   }
//   getNews() async{
//     return await FirebaseFirestore.instance.collection('DMS-SSE').doc("News").collection('List-New').get();
//   }
// }