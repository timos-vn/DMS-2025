import 'dart:io';

class CustomerCareFormData {
  // Customer Information
  String customerName;
  String customerPhone;
  String customerAddress;
  String? customerCode;

  // Care Content
  String content;
  String feedback;

  // Care Types
  bool isPhone;
  bool isEmail;
  bool isSMS;
  bool isMXH;
  bool isOther;
  String? otherCareType;

  // Images
  List<File> images;
  
  // Image quality setting
  double percentQuantityImage;

  // Validation
  bool get hasSelectedCareType => isPhone || isEmail || isSMS || isMXH || isOther;

  CustomerCareFormData({
    this.customerName = '',
    this.customerPhone = '',
    this.customerAddress = '',
    this.customerCode,
    this.content = '',
    this.feedback = '',
    this.isPhone = false,
    this.isEmail = false,
    this.isSMS = false,
    this.isMXH = false,
    this.isOther = false,
    this.otherCareType,
    List<File>? images,
    this.percentQuantityImage = 0.65,
  }) : images = images ?? [];

  /// Get selected care types as list
  List<String> get selectedCareTypes {
    final List<String> types = [];
    if (isPhone) types.add('Phone');
    if (isEmail) types.add('Email');
    if (isSMS) types.add('SMS');
    if (isMXH) types.add('Page');
    if (isOther && otherCareType != null && otherCareType!.isNotEmpty) {
      types.add(otherCareType!);
    }
    return types;
  }

  /// Get selected care types as comma-separated string
  String get careTypesString => selectedCareTypes.join(',');

  /// Check if form is valid
  bool get isValid {
    return customerName.isNotEmpty &&
           customerPhone.isNotEmpty &&
           customerAddress.isNotEmpty &&
           content.isNotEmpty &&
           feedback.isNotEmpty &&
           hasSelectedCareType &&
           (!isOther || (otherCareType != null && otherCareType!.isNotEmpty));
  }

  /// Get validation errors
  List<String> get validationErrors {
    final List<String> errors = [];

    if (customerName.isEmpty) {
      errors.add('Vui lòng nhập tên khách hàng');
    }

    if (customerPhone.isEmpty) {
      errors.add('Vui lòng nhập số điện thoại');
    }

    if (customerAddress.isEmpty) {
      errors.add('Vui lòng nhập địa chỉ khách hàng');
    }

    if (content.isEmpty) {
      errors.add('Vui lòng nhập nội dung');
    }

    if (feedback.isEmpty) {
      errors.add('Vui lòng nhập phản hồi của khách hàng');
    }

    if (!hasSelectedCareType) {
      errors.add('Vui lòng chọn ít nhất một loại chăm sóc');
    }

    if (isOther && (otherCareType == null || otherCareType!.isEmpty)) {
      errors.add('Vui lòng nhập loại chăm sóc khác');
    }

    return errors;
  }

  /// Create a copy of this object with updated values
  CustomerCareFormData copyWith({
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? customerCode,
    String? content,
    String? feedback,
    bool? isPhone,
    bool? isEmail,
    bool? isSMS,
    bool? isMXH,
    bool? isOther,
    String? otherCareType,
    List<File>? images,
    double? percentQuantityImage,
  }) {
    return CustomerCareFormData(
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      customerCode: customerCode ?? this.customerCode,
      content: content ?? this.content,
      feedback: feedback ?? this.feedback,
      isPhone: isPhone ?? this.isPhone,
      isEmail: isEmail ?? this.isEmail,
      isSMS: isSMS ?? this.isSMS,
      isMXH: isMXH ?? this.isMXH,
      isOther: isOther ?? this.isOther,
      otherCareType: otherCareType ?? this.otherCareType,
      images: images ?? this.images,
      percentQuantityImage: percentQuantityImage ?? this.percentQuantityImage,
    );
  }

  /// Reset form data
  void reset() {
    customerName = '';
    customerPhone = '';
    customerAddress = '';
    customerCode = null;
    content = '';
    feedback = '';
    isPhone = false;
    isEmail = false;
    isSMS = false;
    isMXH = false;
    isOther = false;
    otherCareType = null;
    images.clear();
  }

  /// Add image to the list
  void addImage(File image) {
    images.add(image);
  }

  /// Remove image from the list
  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
    }
  }

  /// Clear all images
  void clearImages() {
    images.clear();
  }

  /// Toggle care type
  void toggleCareType(int index) {
    switch (index) {
      case 1:
        isPhone = !isPhone;
        break;
      case 2:
        isEmail = !isEmail;
        break;
      case 3:
        isSMS = !isSMS;
        break;
      case 4:
        isMXH = !isMXH;
        break;
      case 5:
        isOther = !isOther;
        if (!isOther) {
          otherCareType = null;
        }
        break;
    }
  }

  /// Convert to Map for API request
  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'customerCode': customerCode,
      'content': content,
      'feedback': feedback,
      'careTypes': careTypesString,
      'otherCareType': otherCareType,
      'imageCount': images.length,
    };
  }

  @override
  String toString() {
    return 'CustomerCareFormData('
        'customerName: $customerName, '
        'customerPhone: $customerPhone, '
        'customerAddress: $customerAddress, '
        'customerCode: $customerCode, '
        'content: $content, '
        'feedback: $feedback, '
        'careTypes: ${selectedCareTypes}, '
        'otherCareType: $otherCareType, '
        'imageCount: ${images.length}, '
        'isValid: $isValid)';
  }
}
