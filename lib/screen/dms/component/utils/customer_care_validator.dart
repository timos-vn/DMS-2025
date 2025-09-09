class CustomerCareValidator {
  static String? validateCustomerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên khách hàng';
    }
    if (value.trim().length < 2) {
      return 'Tên khách hàng phải có ít nhất 2 ký tự';
    }
    return null;
  }

  static String? validateCustomerPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    // Basic phone validation for Vietnamese numbers
    final phoneRegex = RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  static String? validateCustomerAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ khách hàng';
    }
    if (value.trim().length < 10) {
      return 'Địa chỉ phải có ít nhất 10 ký tự';
    }
    return null;
  }

  static String? validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập nội dung';
    }
    if (value.trim().length < 10) {
      return 'Nội dung phải có ít nhất 10 ký tự';
    }
    if (value.trim().length > 100) {
      return 'Nội dung không được vượt quá 100 ký tự';
    }
    return null;
  }

  static String? validateFeedback(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập phản hồi của khách hàng';
    }
    if (value.trim().length < 10) {
      return 'Phản hồi phải có ít nhất 10 ký tự';
    }
    if (value.trim().length > 1000) {
      return 'Phản hồi không được vượt quá 1000 ký tự';
    }
    return null;
  }

  static String? validateOtherCareType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập loại chăm sóc khác';
    }
    if (value.trim().length < 3) {
      return 'Loại chăm sóc phải có ít nhất 3 ký tự';
    }
    return null;
  }

  static bool validateForm({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String content,
    required String feedback,
    required bool hasSelectedCareType,
    String? otherCareType,
    required bool isOtherSelected,
  }) {
    // Check if at least one care type is selected
    if (!hasSelectedCareType) {
      return false;
    }

    // If "Other" is selected, validate other care type
    if (isOtherSelected && (otherCareType == null || otherCareType.trim().isEmpty)) {
      return false;
    }

    // Validate required fields
    return validateCustomerName(customerName) == null &&
           validateCustomerPhone(customerPhone) == null &&
           validateCustomerAddress(customerAddress) == null &&
           validateContent(content) == null &&
           validateFeedback(feedback) == null;
  }

  static String getValidationMessage({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String content,
    required String feedback,
    required bool hasSelectedCareType,
    String? otherCareType,
    required bool isOtherSelected,
  }) {
    if (!hasSelectedCareType) {
      return 'Vui lòng chọn ít nhất một loại chăm sóc';
    }

    if (isOtherSelected && (otherCareType == null || otherCareType.trim().isEmpty)) {
      return 'Vui lòng nhập loại chăm sóc khác';
    }

    String? error = validateCustomerName(customerName);
    if (error != null) return error;

    error = validateCustomerPhone(customerPhone);
    if (error != null) return error;

    error = validateCustomerAddress(customerAddress);
    if (error != null) return error;

    error = validateContent(content);
    if (error != null) return error;

    error = validateFeedback(feedback);
    if (error != null) return error;

    return '';
  }
}

