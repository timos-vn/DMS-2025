// import 'list_image_store_response.dart';
//
// class ListAlbumImageCheckInResponse {
//   List<ListAlbum>? data;
//   int? totalPage;
//   int? statusCode;
//   String? message;
//
//   ListAlbumImageCheckInResponse(
//       {this.data, this.totalPage, this.statusCode, this.message});
//
//   ListAlbumImageCheckInResponse.fromJson(Map<String, dynamic> json) {
//     if (json['data'] != null) {
//       data = <ListAlbum>[];
//       json['data'].forEach((v) {
//         data!.add( ListAlbum.fromJson(v));
//       });
//     }
//     totalPage = json['totalPage'];
//     statusCode = json['statusCode'];
//     message = json['message'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  <String, dynamic>{};
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     data['totalPage'] = totalPage;
//     data['statusCode'] = statusCode;
//     data['message'] = message;
//     return data;
//   }
// }
//
