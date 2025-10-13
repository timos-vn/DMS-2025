class DynamicApiResponse {
  ResponseModel? responseModel;
  ListObject? listObject;

  DynamicApiResponse({
    this.responseModel,
    this.listObject,
  });

  DynamicApiResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('=== DYNAMIC API RESPONSE: Parsing dynamic api response ===');
      print('JSON: $json');
      
      // Xử lý responseModel an toàn
      final responseModelValue = json['responseModel'];
      if (responseModelValue != null && responseModelValue is Map<String, dynamic>) {
        try {
          responseModel = ResponseModel.fromJson(responseModelValue);
        } catch (e) {
          print('=== DYNAMIC API RESPONSE: Error parsing responseModel ===');
          print('Error: $e');
          print('responseModelValue: $responseModelValue');
          responseModel = null;
        }
      } else {
        print('=== DYNAMIC API RESPONSE: No responseModel or invalid format ===');
        responseModel = null;
      }
      
      // Xử lý listObject an toàn
      final listObjectValue = json['listObject'];
      if (listObjectValue != null && listObjectValue is Map<String, dynamic>) {
        try {
          listObject = ListObject.fromJson(listObjectValue);
        } catch (e) {
          print('=== DYNAMIC API RESPONSE: Error parsing listObject ===');
          print('Error: $e');
          print('listObjectValue: $listObjectValue');
          listObject = null;
        }
      } else {
        print('=== DYNAMIC API RESPONSE: No listObject or invalid format ===');
        listObject = null;
      }
      
      print('=== DYNAMIC API RESPONSE: Parsed successfully ===');
      print('responseModel: ${responseModel != null}');
      print('listObject: ${listObject != null}');
    } catch (e) {
      print('=== DYNAMIC API RESPONSE: Error parsing ===');
      print('Error: $e');
      print('JSON: $json');
      // Không rethrow, trả về object với giá trị null
      responseModel = null;
      listObject = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (responseModel != null) {
      data['responseModel'] = responseModel!.toJson();
    }
    if (listObject != null) {
      data['listObject'] = listObject!.toJson();
    }
    return data;
  }
}

class ResponseModel {
  bool? isSucceded;
  String? message;

  ResponseModel({
    this.isSucceded,
    this.message,
  });

  ResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      print('=== RESPONSE MODEL: Parsing response model ===');
      print('JSON: $json');
      
      // Xử lý isSucceded an toàn hơn
      final isSuccededValue = json['isSucceded'];
      if (isSuccededValue == null) {
        isSucceded = false;
      } else if (isSuccededValue is bool) {
        isSucceded = isSuccededValue;
      } else if (isSuccededValue is String) {
        try {
          isSucceded = isSuccededValue.toLowerCase() == 'true';
        } catch (e) {
          print('=== RESPONSE MODEL: Error converting isSucceded string ===');
          print('Error: $e');
          isSucceded = false;
        }
      } else {
        isSucceded = false;
      }
      
      // Xử lý message an toàn
      final messageValue = json['message'];
      if (messageValue != null) {
        try {
          message = messageValue.toString();
        } catch (e) {
          print('=== RESPONSE MODEL: Error converting message to string ===');
          print('Error: $e');
          message = null;
        }
      } else {
        message = null;
      }
      
      print('=== RESPONSE MODEL: Parsed successfully ===');
      print('isSucceded: $isSucceded');
      print('message: $message');
    } catch (e) {
      print('=== RESPONSE MODEL: Error parsing ===');
      print('Error: $e');
      print('JSON: $json');
      // Không rethrow, trả về object với giá trị mặc định
      isSucceded = false;
      message = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isSucceded'] = isSucceded;
    data['message'] = message;
    return data;
  }
}

class ListObject {
  DataLists? dataLists;

  ListObject({
    this.dataLists,
  });

  ListObject.fromJson(Map<String, dynamic> json) {
    try {
      print('=== LIST OBJECT: Parsing list object ===');
      print('JSON: $json');
      
      // Xử lý dataLists an toàn
      final dataListsValue = json['dataLists'];
      if (dataListsValue != null && dataListsValue is Map<String, dynamic>) {
        try {
          dataLists = DataLists.fromJson(dataListsValue);
        } catch (e) {
          print('=== LIST OBJECT: Error parsing dataLists ===');
          print('Error: $e');
          print('dataListsValue: $dataListsValue');
          dataLists = null;
        }
      } else {
        print('=== LIST OBJECT: No dataLists or invalid format ===');
        dataLists = null;
      }
      
      print('=== LIST OBJECT: Parsed successfully ===');
      print('dataLists: ${dataLists != null}');
    } catch (e) {
      print('=== LIST OBJECT: Error parsing ===');
      print('Error: $e');
      print('JSON: $json');
      // Không rethrow, trả về object với giá trị null
      dataLists = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (dataLists != null) {
      data['dataLists'] = dataLists!.toJson();
    }
    return data;
  }
}

class DataLists {
  List<LotData>? data;
  List<Pagination>? pagination;

  DataLists({
    this.data,
    this.pagination,
  });

  DataLists.fromJson(Map<String, dynamic> json) {
    try {
      print('=== DATA LISTS: Parsing data lists ===');
      print('JSON: $json');
      
      // Xử lý data array an toàn
      final dataValue = json['data'];
      if (dataValue != null && dataValue is List) {
        print('=== DATA LISTS: Parsing data array ===');
        data = <LotData>[];
        for (var item in dataValue) {
          if (item != null && item is Map<String, dynamic>) {
            try {
              print('=== DATA LISTS: Parsing lot item ===');
              data!.add(LotData.fromJson(item));
            } catch (e) {
              print('=== DATA LISTS: Error parsing lot item ===');
              print('Error: $e');
              print('Item: $item');
              // Bỏ qua item lỗi và tiếp tục
            }
          }
        }
        print('=== DATA LISTS: Data array parsed successfully ===');
        print('Data count: ${data!.length}');
      } else {
        print('=== DATA LISTS: No data array or invalid format ===');
        data = <LotData>[];
      }
      
      // Xử lý pagination array an toàn
      final paginationValue = json['pagination'];
      if (paginationValue != null && paginationValue is List) {
        print('=== DATA LISTS: Parsing pagination array ===');
        pagination = <Pagination>[];
        for (var item in paginationValue) {
          if (item != null && item is Map<String, dynamic>) {
            try {
              print('=== DATA LISTS: Parsing pagination item ===');
              pagination!.add(Pagination.fromJson(item));
            } catch (e) {
              print('=== DATA LISTS: Error parsing pagination item ===');
              print('Error: $e');
              print('Item: $item');
              // Bỏ qua item lỗi và tiếp tục
            }
          }
        }
        print('=== DATA LISTS: Pagination array parsed successfully ===');
        print('Pagination count: ${pagination!.length}');
      } else {
        print('=== DATA LISTS: No pagination array or invalid format ===');
        pagination = <Pagination>[];
      }
    } catch (e) {
      print('=== DATA LISTS: Error parsing ===');
      print('Error: $e');
      print('JSON: $json');
      // Không rethrow, trả về object với giá trị mặc định
      data = <LotData>[];
      pagination = <Pagination>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LotData {
  String? maLo;
  String? tenLo;
  String? ngayHhsd;

  LotData({
    this.maLo,
    this.tenLo,
    this.ngayHhsd,
  });

  LotData.fromJson(Map<String, dynamic> json) {
    try {
      print('=== LOT DATA: Parsing lot data ===');
      print('JSON: $json');
      
      // Xử lý maLo an toàn
      final maLoValue = json['ma_lo'];
      if (maLoValue != null) {
        try {
          maLo = maLoValue.toString();
        } catch (e) {
          print('=== LOT DATA: Error converting maLo to string ===');
          print('Error: $e');
          maLo = null;
        }
      } else {
        maLo = null;
      }
      
      // Xử lý tenLo an toàn
      final tenLoValue = json['ten_lo'];
      if (tenLoValue != null) {
        try {
          tenLo = tenLoValue.toString();
        } catch (e) {
          print('=== LOT DATA: Error converting tenLo to string ===');
          print('Error: $e');
          tenLo = null;
        }
      } else {
        tenLo = null;
      }
      
      // Xử lý ngayHhsd an toàn (có thể null)
      final ngayHhsdValue = json['ngay_hhsd'];
      if (ngayHhsdValue != null) {
        try {
          ngayHhsd = ngayHhsdValue.toString();
        } catch (e) {
          print('=== LOT DATA: Error converting ngayHhsd to string ===');
          print('Error: $e');
          ngayHhsd = null;
        }
      } else {
        ngayHhsd = null;
      }
      
      print('=== LOT DATA: Parsed successfully ===');
      print('maLo: $maLo');
      print('tenLo: $tenLo');
      print('ngayHhsd: $ngayHhsd');
    } catch (e) {
      print('=== LOT DATA: Error parsing ===');
      print('Error: $e');
      print('JSON: $json');
      // Không rethrow, trả về object với giá trị null
      maLo = null;
      tenLo = null;
      ngayHhsd = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_lo'] = maLo;
    data['ten_lo'] = tenLo;
    data['ngay_hhsd'] = ngayHhsd;
    return data;
  }
}

class Pagination {
  int? totalPage;

  Pagination({
    this.totalPage,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    try {
      print('=== PAGINATION: Parsing pagination ===');
      print('JSON: $json');
      
      // Xử lý totalPage an toàn hơn
      final totalPageValue = json['totalPage'];
      if (totalPageValue == null) {
        totalPage = 1;
      } else if (totalPageValue is int) {
        totalPage = totalPageValue;
      } else if (totalPageValue is String) {
        try {
          totalPage = int.tryParse(totalPageValue) ?? 1;
        } catch (e) {
          print('=== PAGINATION: Error parsing totalPage string ===');
          print('Error: $e');
          totalPage = 1;
        }
      } else if (totalPageValue is double) {
        try {
          totalPage = totalPageValue.toInt();
        } catch (e) {
          print('=== PAGINATION: Error converting totalPage double ===');
          print('Error: $e');
          totalPage = 1;
        }
      } else {
        totalPage = 1;
      }
      
      print('=== PAGINATION: Parsed successfully ===');
      print('totalPage: $totalPage');
    } catch (e) {
      print('=== PAGINATION: Error parsing ===');
      print('Error: $e');
      print('JSON: $json');
      // Không rethrow, trả về object với giá trị mặc định
      totalPage = 1;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalPage'] = totalPage;
    return data;
  }
}
