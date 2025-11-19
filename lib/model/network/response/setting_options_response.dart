class SettingOptionsResponse {
  MasterAppSettings? masterAppSettings;
  List<ListTransaction>? listTransaction;
  List<ListAgency>? listAgency;
  List<ListTypePayment>? listTypePayment;
  List<ListFunctionQrCode>? listFunctionQrCode;
  List<ListTypeDelivery>? listTypeDelivery;
  List<ListTypeVoucher>? listTypeVoucher;
  // List<ListAdvanceOrderInfo>? listAdvanceOrderInfo;
  int? statusCode;
  String? message;

  SettingOptionsResponse(
      {this.masterAppSettings,
      this.listTransaction,
      this.listAgency,
      this.listTypePayment,
      this.listFunctionQrCode,
      this.listTypeDelivery,
      this.listTypeVoucher,
      // this.listAdvanceOrderInfo,
      this.statusCode,
      this.message});

  SettingOptionsResponse.fromJson(Map<String, dynamic> json) {
    masterAppSettings = json['masterAppSettings'] != null
        ? MasterAppSettings.fromJson(json['masterAppSettings'])
        : null;
    if (json['listTransaction'] != null) {
      listTransaction = <ListTransaction>[];
      json['listTransaction'].forEach((v) {
        listTransaction!.add(ListTransaction.fromJson(v));
      });
    }
    if (json['listAgency'] != null) {
      listAgency = <ListAgency>[];
      json['listAgency'].forEach((v) {
        listAgency!.add(ListAgency.fromJson(v));
      });
    }
    if (json['listTypePayment'] != null) {
      listTypePayment = <ListTypePayment>[];
      json['listTypePayment'].forEach((v) {
        listTypePayment!.add(ListTypePayment.fromJson(v));
      });
    }
    if (json['listFunctionQrCode'] != null) {
      listFunctionQrCode = <ListFunctionQrCode>[];
      json['listFunctionQrCode'].forEach((v) {
        listFunctionQrCode!.add(ListFunctionQrCode.fromJson(v));
      });
    }
    if (json['listTypeDelivery'] != null) {
      listTypeDelivery = <ListTypeDelivery>[];
      json['listTypeDelivery'].forEach((v) {
        listTypeDelivery!.add(ListTypeDelivery.fromJson(v));
      });
    }
    if (json['listTypeVoucher'] != null) {
      listTypeVoucher = <ListTypeVoucher>[];
      json['listTypeVoucher'].forEach((v) {
        listTypeVoucher!.add(ListTypeVoucher.fromJson(v));
      });
    }
    // if (json['listAdvanceOrderInfo'] != null) {
    //   listAdvanceOrderInfo = <ListAdvanceOrderInfo>[];
    //   json['listAdvanceOrderInfo'].forEach((v) {
    //     listAdvanceOrderInfo!.add( ListAdvanceOrderInfo.fromJson(v));
    //   });
    // }

    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (masterAppSettings != null) {
      data['masterAppSettings'] = masterAppSettings!.toJson();
    }
    if (listTransaction != null) {
      data['listTransaction'] =
          listTransaction!.map((v) => v.toJson()).toList();
    }
    if (listAgency != null) {
      data['listAgency'] = listAgency!.map((v) => v.toJson()).toList();
    }
    if (listTypePayment != null) {
      data['listTypePayment'] =
          listTypePayment!.map((v) => v.toJson()).toList();
    }
    if (listFunctionQrCode != null) {
      data['listFunctionQrCode'] =
          listFunctionQrCode!.map((v) => v.toJson()).toList();
    }
    if (listFunctionQrCode != null) {
      data['listTypeDelivery'] =
          listTypeDelivery!.map((v) => v.toJson()).toList();
    }
    if (listTypeVoucher != null) {
      data['listTypeVoucher'] =
          listTypeVoucher!.map((v) => v.toJson()).toList();
    }
    // if (listAdvanceOrderInfo != null) {
    //   data['listAdvanceOrderInfo'] =
    //       listAdvanceOrderInfo!.map((v) => v.toJson()).toList();
    // }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class MasterAppSettings {
  int? inStockCheck;
  int? freeDiscount;
  int? discountSpecial;
  int? woPrice;
  int? allowsWoPriceAndTransactionType;
  double? latitude;
  double? longitude;
  int? deliveryPhotoRange;
  int? distanceLocationCheckIn;
  int? isVvHd;
  int? isVv;
  int? isHd;
  int? lockStockInItem;
  int? lockStockInCart;
  int? lockStockInItemGift;
  int? findStoreForItemProduct;
  int? saleOutUpdatePrice;
  int? afterTax;
  int? useTax;
  int? chooseAgency;
  int? chooseTypePayment;
  int? wholesale;
  int? orderWithCustomerRegular;
  int? chooseStockBeforeOrder;
  int? checkGroup;
  int? chooseAgentSaleOut;
  int? chooseSaleOffSaleOut;
  int? chooseStatusToCreateOrder;
  int? enableAutoAddDiscount;
  int? enableProductFollowStore;
  int? enableViewPriceAndTotalPriceProductGift;
  int? chooseStatusToSaleOut;
  int? chooseStateWhenCreateNewOpenStore;
  int? editPrice;
  int? approveOrder;
  int? approveNewStore;
  int? dateEstDelivery;
  int? typeProduction;
  int? giaGui;
  int? editNameProduction;
  int? checkPriceAddToCard;
  int? checkStockEmployee;
  int? chooseStockBeforeOrderWithGiftProduction;
  int? takeFirstStockInList;
  int? chooseTypeDelivery;
  int? noteForEachProduct;
  int? isCheckStockSaleOut;
  int? isGetAdvanceOrderInfo;
  int? typeOrder;
  int? typeTransfer;
  int? manyUnitAllow;
  int? isBaoGia;
  int? isEnableNotification;
  int? isDeliveryPhotoRange;
  int? isDefaultCongNo;
  int? scanQRCodeForInvoicePXB;
  int? allowCreateTicketShipping;
  int? percentQuantityImage;
  int? reportLocationNoChooseCustomer;
  int? editPriceWidthValuesEmptyOrZero;
  int? noCheckDayOff;
  int? autoAddAgentFromSaleOut;
  int? discountSpecialAdd;
  int? addProductionSameQuantity;

  MasterAppSettings({
    this.inStockCheck,
    this.freeDiscount,
    this.discountSpecial,
    this.woPrice,
    this.allowsWoPriceAndTransactionType,
    this.latitude,
    this.longitude,
    this.deliveryPhotoRange,
    this.distanceLocationCheckIn,
    this.isVvHd,
    this.findStoreForItemProduct,
    this.saleOutUpdatePrice,
    this.afterTax,
    this.useTax,
    this.chooseAgency,
    this.chooseTypePayment,
    this.wholesale,
    this.orderWithCustomerRegular,
    this.chooseStockBeforeOrder,
    this.isVv,
    this.isHd,
    this.lockStockInItem,
    this.lockStockInCart,
    this.lockStockInItemGift,
    this.checkGroup,
    this.chooseAgentSaleOut,
    this.chooseSaleOffSaleOut,
    this.chooseStatusToCreateOrder,
    this.enableAutoAddDiscount,
    this.enableProductFollowStore,
    this.enableViewPriceAndTotalPriceProductGift,
    this.chooseStatusToSaleOut,
    this.chooseStateWhenCreateNewOpenStore,
    this.editPrice,
    this.approveOrder,
    this.approveNewStore,
    this.typeProduction,
    this.giaGui,
    this.dateEstDelivery,
    this.editNameProduction,
    this.checkPriceAddToCard,
    this.checkStockEmployee,
    this.chooseStockBeforeOrderWithGiftProduction,
    this.takeFirstStockInList,
    this.chooseTypeDelivery,
    this.noteForEachProduct,
    this.isCheckStockSaleOut,
    this.isGetAdvanceOrderInfo,
    this.typeOrder,
    this.typeTransfer,
    this.manyUnitAllow,
    this.isBaoGia,
    this.isEnableNotification,
    this.isDeliveryPhotoRange,
    this.isDefaultCongNo,
    this.scanQRCodeForInvoicePXB,
    this.allowCreateTicketShipping,
    this.percentQuantityImage,
    this.reportLocationNoChooseCustomer,
    this.editPriceWidthValuesEmptyOrZero,
    this.noCheckDayOff,
    this.autoAddAgentFromSaleOut,
    this.discountSpecialAdd,
    this.addProductionSameQuantity,
  });

  MasterAppSettings.fromJson(Map<String, dynamic> json) {
    inStockCheck = json['inStockCheck'];
    freeDiscount = json['freeDiscount'];
    discountSpecial = json['discountSpecial'];
    woPrice = json['woPrice'];
    allowsWoPriceAndTransactionType = json['allowsWoPriceAndTransactionType'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    deliveryPhotoRange = json['deliveryPhotoRange'];
    distanceLocationCheckIn = json['distanceLocationCheckIn'];
    isVvHd = json['isVvHd'];
    findStoreForItemProduct = json['findStoreForItemProduct'];
    saleOutUpdatePrice = json['saleOutUpdatePrice'];
    afterTax = json['afterTax'];
    useTax = json['useTax'];
    chooseAgency = json['chooseAgency'];
    chooseTypePayment = json['chooseTypePayment'];
    wholesale = json['wholesale'];
    orderWithCustomerRegular = json['orderWithCustomerRegular'];
    chooseStockBeforeOrder = json['chooseStockBeforeOrder'];
    isVv = json['isVv'];
    isHd = json['isHd'];
    lockStockInItem = json['lockStockInItem'];
    lockStockInCart = json['lockStockInCart'];
    lockStockInItemGift = json['lockStockInItemGift'];
    checkGroup = json['checkGroup'];
    chooseAgentSaleOut = json['chooseAgentSaleOut'];
    chooseSaleOffSaleOut = json['chooseSaleOffSaleOut'];
    chooseStatusToCreateOrder = json['chooseStatusToCreateOrder'];
    enableAutoAddDiscount = json['enableAutoAddDiscount'];
    enableProductFollowStore = json['enableProductFollowStore'];
    enableViewPriceAndTotalPriceProductGift =
        json['enableViewPriceAndTotalPriceProductGift'];
    chooseStatusToSaleOut = json['chooseStatusToSaleOut'];
    chooseStateWhenCreateNewOpenStore =
        json['chooseStateWhenCreateNewOpenStore'];
    editPrice = json['editPrice'];
    approveOrder = json['approveOrder'];
    approveNewStore = json['approveNewStore'];
    typeProduction = json['typeProduction'];
    giaGui = json['giaGui'];
    dateEstDelivery = json['dateEstDelivery'];
    editNameProduction = json['editNameProduction'];
    checkPriceAddToCard = json['checkPriceAddToCard'];
    checkStockEmployee = json['checkStockEmployee'];
    chooseStockBeforeOrderWithGiftProduction =
        json['chooseStockBeforeOrderWithGiftProduction'];
    takeFirstStockInList = json['takeFirstStockInList'];
    chooseTypeDelivery = json['chooseTypeDelivery'];
    noteForEachProduct = json['noteForEachProduct'];
    isCheckStockSaleOut = json['isCheckStockSaleOut'];
    isGetAdvanceOrderInfo = json['isGetAdvanceOrderInfo'];
    typeOrder = json['typeOrder'];
    typeTransfer = json['typeTransfer'];
    manyUnitAllow = json['manyUnitAllow'];
    isBaoGia = json['isBaoGia'];
    isEnableNotification = json['isEnableNotification'];
    isDeliveryPhotoRange = json['isDeliveryPhotoRange'];
    isDefaultCongNo = json['isDefaultCongNo'];
    scanQRCodeForInvoicePXB = json['scanQRCodeForInvoicePXB'];
    allowCreateTicketShipping = json['allowCreateTicketShipping'];
    percentQuantityImage = json['percentQuantityImage'];
    reportLocationNoChooseCustomer = json['reportLocationNoChooseCustomer'];
    editPriceWidthValuesEmptyOrZero = json['editPriceWidthValuesEmptyOrZero'];
    noCheckDayOff = json['noCheckDayOff'];
    autoAddAgentFromSaleOut = json['autoAddAgentFromSaleOut'];
    discountSpecialAdd = json['discountSpecialAdd'];
    addProductionSameQuantity = json['addProductionSameQuantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['inStockCheck'] = inStockCheck;
    data['freeDiscount'] = freeDiscount;
    data['discountSpecial'] = discountSpecial;
    data['woPrice'] = woPrice;
    data['allowsWoPriceAndTransactionType'] = allowsWoPriceAndTransactionType;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['distanceLocationCheckIn'] = distanceLocationCheckIn;
    data['deliveryPhotoRange'] = deliveryPhotoRange;
    data['isVvHd'] = isVvHd;
    data['findStoreForItemProduct'] = findStoreForItemProduct;
    data['saleOutUpdatePrice'] = saleOutUpdatePrice;
    data['afterTax'] = afterTax;
    data['useTax'] = useTax;
    data['chooseAgency'] = chooseAgency;
    data['chooseTypePayment'] = chooseTypePayment;
    data['wholesale'] = wholesale;
    data['orderWithCustomerRegular'] = orderWithCustomerRegular;
    data['chooseStockBeforeOrder'] = chooseStockBeforeOrder;
    data['isVv'] = isVv;
    data['isHd'] = isHd;
    data['lockStockInItem'] = lockStockInItem;
    data['lockStockInCart'] = lockStockInCart;
    data['lockStockInItemGift'] = lockStockInItemGift;
    data['checkGroup'] = checkGroup;
    data['chooseAgentSaleOut'] = chooseAgentSaleOut;
    data['chooseSaleOffSaleOut'] = chooseSaleOffSaleOut;
    data['chooseStatusToCreateOrder'] = chooseStatusToCreateOrder;
    data['enableAutoAddDiscount'] = enableAutoAddDiscount;
    data['enableProductFollowStore'] = enableProductFollowStore;
    data['enableViewPriceAndTotalPriceProductGift'] =
        enableViewPriceAndTotalPriceProductGift;
    data['chooseStatusToSaleOut'] = chooseStatusToSaleOut;
    data['chooseStateWhenCreateNewOpenStore'] =
        chooseStateWhenCreateNewOpenStore;
    data['editPrice'] = editPrice;
    data['approveOrder'] = approveOrder;
    data['approveNewStore'] = approveNewStore;
    data['typeProduction'] = typeProduction;
    data['giaGui'] = giaGui;
    data['dateEstDelivery'] = dateEstDelivery;
    data['editNameProduction'] = editNameProduction;
    data['checkPriceAddToCard'] = checkPriceAddToCard;
    data['checkStockEmployee'] = checkStockEmployee;
    data['chooseStockBeforeOrderWithGiftProduction'] =
        chooseStockBeforeOrderWithGiftProduction;
    data['takeFirstStockInList'] = takeFirstStockInList;
    data['chooseTypeDelivery'] = chooseTypeDelivery;
    data['noteForEachProduct'] = noteForEachProduct;
    data['isCheckStockSaleOut'] = isCheckStockSaleOut;
    data['isGetAdvanceOrderInfo'] = isGetAdvanceOrderInfo;
    data['typeOrder'] = typeOrder;
    data['typeTransfer'] = typeTransfer;
    data['manyUnitAllow'] = manyUnitAllow;
    data['isBaoGia'] = isBaoGia;
    data['isEnableNotification'] = isEnableNotification;
    data['isDeliveryPhotoRange'] = isDeliveryPhotoRange;
    data['isDefaultCongNo'] = isDefaultCongNo;
    data['scanQRCodeForInvoicePXB'] = scanQRCodeForInvoicePXB;
    data['allowCreateTicketShipping'] = allowCreateTicketShipping;
    data['percentQuantityImage'] = percentQuantityImage;
    data['reportLocationNoChooseCustomer'] = reportLocationNoChooseCustomer;
    data['editPriceWidthValuesEmptyOrZero'] = editPriceWidthValuesEmptyOrZero;
    data['noCheckDayOff'] = noCheckDayOff;
    data['autoAddAgentFromSaleOut'] = autoAddAgentFromSaleOut;
    data['discountSpecialAdd'] = discountSpecialAdd;
    data['addProductionSameQuantity'] = addProductionSameQuantity;
    return data;
  }
}

class ListTransaction {
  String? maCt;
  String? maGd;
  String? tenGd;
  int? chonDLYN;
  bool? isMark = false;

  ListTransaction(
      {this.maCt, this.maGd, this.tenGd, this.chonDLYN, this.isMark = false});

  ListTransaction.fromJson(Map<String, dynamic> json) {
    maCt = json['ma_ct'];
    maGd = json['ma_gd'];
    tenGd = json['ten_gd'];
    chonDLYN = json['chon_dl_yn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_ct'] = maCt;
    data['ma_gd'] = maGd;
    data['ten_gd'] = tenGd;
    data['chon_dl_yn'] = chonDLYN;
    return data;
  }
}

class ListAgency {
  String? codeDiscount;
  String? nameDiscount;
  double? discountPercent;
  String? typeCustomer;

  ListAgency(
      {this.codeDiscount,
      this.nameDiscount,
      this.discountPercent,
      this.typeCustomer});

  ListAgency.fromJson(Map<String, dynamic> json) {
    codeDiscount = json['ma_ck'];
    nameDiscount = json['ten_ck'];
    discountPercent = json['tl_ck'];
    typeCustomer = json['kieu_kh'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_ck'] = codeDiscount;
    data['ten_ck'] = nameDiscount;
    data['tl_ck'] = discountPercent;
    data['kieu_kh'] = typeCustomer;
    return data;
  }
}

class ListTypePayment {
  String? codeDiscount;
  String? nameDiscount;
  double? discountPercent;

  ListTypePayment({this.codeDiscount, this.nameDiscount, this.discountPercent});

  ListTypePayment.fromJson(Map<String, dynamic> json) {
    codeDiscount = json['ma_ck'];
    nameDiscount = json['ten_ck'];
    discountPercent = json['tl_ck'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_ck'] = codeDiscount;
    data['ten_ck'] = nameDiscount;
    data['tl_ck'] = discountPercent;
    return data;
  }
}

class ListFunctionQrCode {
  String? key;
  String? description;
  String? status;

  ListFunctionQrCode({this.key, this.description, this.status});

  ListFunctionQrCode.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    description = json['mo_ta'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['mo_ta'] = description;
    data['tl_ck'] = status;
    return data;
  }
}

class ListTypeDelivery {
  String? idTypeDelivery;
  String? nameTypeDelivery;

  ListTypeDelivery({this.idTypeDelivery, this.nameTypeDelivery});

  ListTypeDelivery.fromJson(Map<String, dynamic> json) {
    idTypeDelivery = json['htvc'];
    nameTypeDelivery = json['ten_htvc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['htvc'] = idTypeDelivery;
    data['ten_htvc'] = nameTypeDelivery;
    return data;
  }
}

class ListTypeVoucher {
  String? codeVoucher;
  String? nameVoucher;

  ListTypeVoucher({this.codeVoucher, this.nameVoucher});

  ListTypeVoucher.fromJson(Map<String, dynamic> json) {
    codeVoucher = json['ma_ct'];
    nameVoucher = json['ten_ct'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_ct'] = codeVoucher;
    data['ten_ct'] = nameVoucher;
    return data;
  }
}

class ListAdvanceOrderInfo {
  String? title;
  String? colName;
  String? type;
  String? format;
  String? options;
  String? nullable;
  String? controller;

  ListAdvanceOrderInfo({
    this.title,
    this.colName,
    this.type,
    this.format,
    this.options,
    this.nullable,
    this.controller,
  });

  ListAdvanceOrderInfo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    colName = json['colName'];
    type = json['type'];
    format = json['format'];
    options = json['options'];
    nullable = json['nullable'];
    controller = json['controller'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['colName'] = colName;
    data['type'] = type;
    data['format'] = format;
    data['options'] = options;
    data['nullable'] = nullable;
    data['controller'] = controller;
    return data;
  }
}
