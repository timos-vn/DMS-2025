# Tính năng Khảo sát Khách hàng (Customer Survey)

## Tổng quan
Tính năng khảo sát khách hàng được tích hợp vào màn hình Chăm sóc khách hàng (CSKH) để thu thập thông tin phản hồi từ khách hàng một cách có hệ thống.

## Cấu trúc file

### Models
- `survey_question.dart` - Model cho câu hỏi khảo sát
- `survey_answer.dart` - Model cho câu trả lời khảo sát

### API Response Models
- `survey_response.dart` - Models cho API response

### Services
- **Tích hợp vào `NetWorkFactory`** - Sử dụng pattern chuẩn của project

### BLoC Pattern
- `survey_bloc.dart` - Business logic controller
- `survey_event.dart` - Events
- `survey_state.dart` - States

### Lazy Loading Strategy
- **Câu hỏi**: Load ngay khi màn hình khởi tạo
- **Câu trả lời**: Chỉ load khi user click vào câu hỏi (mở rộng)
- **Cache**: Ghi nhớ câu trả lời đã load để không call API lại

### UI Components
- `customer_survey_screen.dart` - Màn hình chính khảo sát
- `widgets/survey_progress_bar.dart` - Progress bar hiển thị tiến độ
- `widgets/survey_question_card.dart` - Card hiển thị câu hỏi

## Tính năng chính

### 1. Quản lý câu hỏi
- Load danh sách câu hỏi từ API
- Hỗ trợ tìm kiếm câu hỏi
- Phân trang câu hỏi

### 2. Quản lý câu trả lời
- Load danh sách câu trả lời theo câu hỏi
- Hỗ trợ chọn nhiều câu trả lời
- Câu trả lời tùy chỉnh

### 3. Validation
- Kiểm tra câu hỏi bắt buộc
- Giới hạn số lượng câu trả lời được chọn
- Hiển thị thông báo lỗi

### 4. UI/UX
- Progress bar hiển thị tiến độ
- Expansion tile cho câu hỏi
- Checkbox cho câu trả lời
- Responsive design
- **UI thông minh**: Tự động chuyển đổi giữa checkbox và scrollable list dựa trên số lượng câu trả lời
  - ≤5 câu trả lời: Hiển thị dạng checkbox đơn giản
  - >5 câu trả lời: Hiển thị dạng scrollable list với nút (x) để bỏ chọn nhanh
- **Enhanced Custom Answer**: 
  - Checkbox "Khác" hoạt động đúng
  - TextField hiển thị ngay khi chọn
  - Preview câu trả lời tùy chỉnh
  - Nút xóa nhanh
  - **Multiple ways to hide keyboard**: Nút ẩn bàn phím, nút "Hoàn thành", tap bên ngoài, nhấn Enter

## User Flow & Interaction

### 1. Smart Question Interaction
```
User Flow:
1. User thấy danh sách câu hỏi (chỉ PendingAction khi load questions lần đầu)
2. User click vào câu hỏi HOẶC mũi tên → Bắt đầu loading answers (chức năng giống nhau)
3. ExpansionTile expand → Hiển thị CircularProgressIndicator trong card
4. API trả về → Loading xong → Expand thực sự
5. Hiển thị câu trả lời
6. User tương tác với câu trả lời
```

**✅ Unified Interaction**: Click vào title câu hỏi và click vào mũi tên có chức năng hoàn toàn giống nhau

### 2. Progressive Loading Experience
```
Loading Strategy:
1. Initial Load: PendingAction toàn màn hình (chỉ khi questions.isEmpty)
2. Questions Loaded: Hiển thị danh sách câu hỏi
3. Answers Loading: Loading chỉ trong ExpansionTile, không block UI
4. User Interaction: Vẫn có thể tương tác với câu hỏi khác
5. Seamless UX: Không có loading screen gián đoạn
```

### 2. Visual Feedback System
- **Chưa expand**: Câu hỏi bình thường
- **Đang loading**: ExpansionTile expand + CircularProgressIndicator trong card
- **Đã load**: Expand thực sự + Hiển thị câu trả lời với UI thông minh
- **Đã trả lời**: Checkbox xanh + "Đã trả lời" badge
- **Câu trả lời tùy chỉnh**: Preview + Nút xóa nhanh
- **Scrollable answers**: Height cố định + Visual feedback rõ ràng

### 3. Smart Loading Behavior
- **Initial loading**: Chỉ hiển thị PendingAction khi load questions lần đầu
- **Answers loading**: Loading chỉ trong ExpansionTile, không block toàn màn hình
- **Progressive loading**: User vẫn thấy câu hỏi và có thể tương tác khi đang load answers
- **Seamless UX**: Không có loading screen gián đoạn

## Cách sử dụng

### 1. Tích hợp vào màn hình CSKH
```dart
// Trong AddNewCustomerCareScreen
ElevatedButton.icon(
  onPressed: () => _openCustomerSurvey(),
  icon: const Icon(Icons.quiz),
  label: const Text('Thêm khảo sát'),
)
```

### 2. Sử dụng NetWorkFactory (Pattern chuẩn)
```dart
// Trong SurveyBloc
final data = await _networkFactory!.getSurveyQuestions(
  _accessToken!,
  searchKey: event.searchKey,
  pageIndex: event.pageIndex,
  pageCount: event.pageCount,
);

// Xử lý response
if (data is String) {
  emit(SurveyFailure('Úi, $data'));
  return;
}

final response = SurveyQuestionsResponse.fromJson(data as Map<String, dynamic>);
```

### 2. Mở màn hình khảo sát
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CustomerSurveyScreen(
      customerId: customerId,
      customerName: customerName,
    ),
  ),
);
```

### 3. Xử lý kết quả
```dart
// Trong CustomerSurveyScreen
BlocListener<SurveyBloc, SurveyState>(
  listener: (context, state) {
    if (state is SurveySubmitted) {
      // Xử lý khi khảo sát được gửi thành công
      Navigator.pop(context, 'SUCCESS');
    }
  },
)
```

## API Endpoints

### 1. Lấy danh sách câu hỏi
```
GET /api/v1/todos/danh-sach-cau-hoi
Query params: searchKey, page_index, page_count
```

### 2. Lấy danh sách câu trả lời
```
GET /api/v1/todos/danh-sach-cau-tra-loi
Query params: stt_rec, ma_cau_hoi
```

### 3. Submit khảo sát
```
POST /api/v1/todos/submit-survey
Body: { customerId, surveyResults, timestamp }
```

## Cấu hình

### 1. Base URL
Base URL được lấy tự động từ `HostSingleton` trong project

### 2. Authorization
✅ **Đã được xử lý!** Sử dụng pattern chuẩn của project:
- **NetWorkFactory**: Tích hợp trực tiếp vào class API chính
- **Token Management**: Sử dụng `GetStorage` để lấy token từ `Const.ACCESS_TOKEN`
- **Automatic Headers**: Tự động thêm `Authorization: Bearer {token}` vào mọi request
- **Error Handling**: Xử lý lỗi 401 khi token không tồn tại
- **Pattern Consistency**: Theo đúng kiến trúc `CustomerCareBloc` và các BLoC khác

### 3. Validation Rules
Cập nhật validation logic trong `SurveyQuestion.isValid`

### 4. Progress Tracking Logic
- **Real-time updates**: Tiến độ cập nhật ngay khi nhập customAnswer
- **Dual validation**: Kiểm tra cả selectedAnswers và customAnswer
- **Progress calculation**: completionRate = answeredQuestions / totalQuestions
- **Answered logic**: isAnswered = hasSelectedAnswers || hasCustomAnswer
- **Validation rules**: Cập nhật để chấp nhận customAnswer

## Debug & Testing

### 1. Kiểm tra dữ liệu API
```dart
// Trong SurveyBloc, thêm logging
print('API Response: $data');
print('Response type: ${data.runtimeType}');
print('Data structure: ${data.toString()}');
```

### 2. Test với dữ liệu mẫu
```dart
// Dữ liệu câu hỏi mẫu
{
  "data": [
    {
      "ma_cau_hoi": "001",
      "ten_cau_hoi": "Các nhãn hàng đang sử dụng ?"
    }
  ],
  "totalPage": 9,
  "statusCode": 200,
  "message": null
}
```

## Performance Optimization

### 1. Lazy Loading
- **Câu hỏi**: Load ngay lập tức để user thấy nội dung
- **Câu trả lời**: Chỉ load khi cần thiết (click vào câu hỏi)
- **Cache**: Sử dụng `isAnswersLoaded` để tránh call API lại

### 2. Smart UI Rendering
- **≤5 câu trả lời**: Checkbox list đơn giản
- **>5 câu trả lời**: Dropdown để tránh UI bị kéo dài
- **Responsive**: Tự động điều chỉnh dựa trên số lượng dữ liệu

### 3. Timeout & Retry Protection
- **Câu hỏi**: 30 giây timeout + retry mechanism
- **Câu trả lời**: 20 giây timeout + retry mechanism  
- **Submit**: 45 giây timeout + retry mechanism
- **Smart Retry UI**: Hiển thị retry button dựa trên loại lỗi

### 4. Enhanced UI/UX Features
- **Smart Answer Display**: 
  - ≤5 items: Checkbox list đơn giản
  - >5 items: Scrollable list với nút (x) nhanh
- **Custom Answer Enhancement**:
  - Checkbox "Khác" hoạt động đúng
  - TextField hiển thị ngay khi chọn
  - Preview và nút xóa nhanh
- **Interactive Elements**:
  - Click vào cả dòng để tích chọn
  - Visual feedback khi chọn
  - Smooth animations và transitions
- **Smart Question Interaction**:
  - **Click vào câu hỏi**: Bắt đầu loading, chỉ expand khi load xong
  - **Loading State**: CircularProgressIndicator hiển thị khi expanded và đang loading
  - **Unified Interaction**: Bấm vào item và bấm vào mũi tên có chức năng như nhau
  - **Smart Expand**: Chỉ expand thực sự khi dữ liệu đã load xong

## Mở rộng

### 1. Thêm loại câu hỏi mới
- Cập nhật model `SurveyQuestion`
- Thêm UI component tương ứng
- Cập nhật validation logic

### 2. Thêm loại câu trả lời mới
- Cập nhật model `SurveyAnswer`
- Thêm UI component tương ứng
- Cập nhật BLoC logic

### 3. Thêm báo cáo
- Tạo màn hình báo cáo kết quả khảo sát
- Thêm biểu đồ thống kê
- Export dữ liệu

## Troubleshooting

### 1. Lỗi API
- Kiểm tra base URL
- Kiểm tra network connection
- Kiểm tra authorization

### 2. Lỗi Parse Dữ liệu
- **"Bad state: No element"**: Đã được xử lý bằng try-catch và fallback logic
- **"No such method"**: Kiểm tra import và class definitions
- **"Type 'X' is not a subtype of type 'Y'"**: Kiểm tra JSON structure và model mapping

### 3. Lỗi Timeout & Loading
- **"CircularProgressIndicator quay vô hạn"**: Đã được xử lý bằng timeout mechanism
- **"Yêu cầu bị timeout sau X giây"**: Kiểm tra kết nối mạng và thử lại
- **"Token không tồn tại"**: Không thể retry, cần đăng nhập lại

### 4. Lỗi UI/UX
- **"Checkbox 'Khác' không hoạt động"**: Đã được sửa, hiện hoạt động đúng
- **"Dropdown không scroll được"**: Đã thay bằng scrollable list với height cố định
- **"Không thấy trạng thái đã chọn"**: Đã thêm visual feedback và nút (x) nhanh
- **"Click vào dòng không tích chọn"**: Đã thêm InkWell để click vào cả dòng

### 5. Lỗi Interaction
- **"Click vào câu hỏi không expand"**: Đã thêm InkWell để click vào title
- **"Bấm vào item và mũi tên khác nhau"**: Đã thống nhất chức năng
- **"Loading state không rõ ràng"**: Đã thêm CircularProgressIndicator khi expanded
- **"Expand trước khi load xong"**: Đã sửa để chỉ expand khi load xong
- **"Không biết câu hỏi nào đã trả lời"**: Đã thêm "Đã trả lời" badge và màu xanh
- **"Checkbox 'Khác' không hoạt động"**: Đã sửa với action đầy đủ - tích chọn focus vào text field, bỏ chọn xóa nội dung
- **"Danh sách dài không scroll được"**: Đã thêm scrollable list với height cố định
- **"Không có nút bỏ chọn nhanh"**: Đã thêm nút (x) cho từng câu trả lời
- **"Không có preview custom answer"**: Đã thêm preview với styling đẹp
- **"Không biết cách ẩn bàn phím"**: Đã thêm 4 cách ẩn bàn phím - nút ẩn bàn phím, nút "Hoàn thành", tap bên ngoài, nhấn Enter
- **"Nhập 'Khác' nhưng thanh tiến độ không thay đổi"**: Đã sửa logic cập nhật isAnswered và validation để tính cả customAnswer
- **"Loading toàn màn hình khi onLoadAnswers"**: Đã sửa để loading chỉ trong ExpansionTile, không block UI
- **"Click vào item câu hỏi khác với mũi tên"**: Đã thống nhất chức năng - cả title và mũi tên đều sử dụng cùng logic

### 2. Lỗi 401 (Unauthorized)
✅ **Đã được xử lý tự động:**
- Token được lấy từ cache (`Const.ACCESS_TOKEN`)
- Nếu token không tồn tại, hiển thị thông báo "Vui lòng đăng nhập lại"
- Sử dụng `GetStorage` để lưu trữ token an toàn
- Tự động thêm `Authorization: Bearer {token}` vào mọi request

### 3. Lỗi Parse Dữ liệu
✅ **Đã được xử lý:**
- **Safe Navigation**: Sử dụng try-catch để xử lý `firstWhere` an toàn
- **Fallback Logic**: Nếu không tìm thấy dữ liệu, tạo danh sách rỗng
- **Error Handling**: Xử lý lỗi "Bad state: No element" một cách graceful
- **Data Validation**: Kiểm tra null và empty trước khi xử lý

### 4. Timeout & Retry Mechanism
✅ **Đã được xử lý:**
- **Timeout Protection**: Tránh CircularProgressIndicator quay vô hạn
  - Câu hỏi: 30 giây
  - Câu trả lời: 20 giây  
  - Submit: 45 giây
- **Smart Retry UI**: Hiển thị retry button thông minh
  - `canRetry: true/false` - Kiểm soát khả năng retry
  - `retryAction: String` - Hướng dẫn action cụ thể
  - Fallback options khi không thể retry

### 2. Lỗi UI
- Kiểm tra import paths
- Kiểm tra widget dependencies
- Kiểm tra theme colors

### 3. Lỗi Validation
- Kiểm tra validation rules
- Kiểm tra data types
- Kiểm tra null safety
