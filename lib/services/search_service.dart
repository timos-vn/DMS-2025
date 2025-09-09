import 'package:dms/model/entity/search_feature.dart';
import 'package:dms/model/entity/quick_access_feature.dart';
import 'package:dms/utils/const.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  // Danh sách tất cả các chức năng có thể tìm kiếm
  List<SearchFeature> getAllSearchFeatures() {
    return [
      // Bán hàng
      SearchFeature(
        id: 'create_order',
        title: 'Đơn hàng',
        description: 'Tạo đơn hàng mới cho khách hàng',
        icon: EneftyIcons.bag_2_outline,
        category: 'Bán hàng',
        route: '/sell/order',
        isEnabled: Const.createNewOrder,
      ),
      SearchFeature(
        id: 'history_order',
        title: 'Lịch sử ĐH',
        description: 'Xem lịch sử các đơn hàng đã tạo',
        icon: MdiIcons.history,
        category: 'Bán hàng',
        route: '/sell/history',
        isEnabled: Const.historyOrder,
      ),
      SearchFeature(
        id: 'product_info',
        title: 'Sản phẩm',
        description: 'Xem thông tin chi tiết sản phẩm',
        icon: Icons.inventory,
        category: 'Bán hàng',
        route: '/sell/product',
        isEnabled: Const.infoProduction,
      ),
      SearchFeature(
        id: 'customer_sell',
        title: 'Khách hàng',
        description: 'Quản lý thông tin khách hàng',
        icon: Icons.person,
        category: 'Bán hàng',
        route: '/sell/customer',
        isEnabled: Const.infoCustomerSell,
      ),
      SearchFeature(
        id: 'contract',
        title: 'Hợp đồng',
        description: 'Quản lý hợp đồng khách hàng',
        icon: Icons.description,
        category: 'Bán hàng',
        route: '/sell/contract',
        isEnabled: Const.contract,
      ),
      SearchFeature(
        id: 'refund_order',
        title: 'Trả lại',
        description: 'Quản lý hàng bán trả lại',
        icon: Icons.assignment_return,
        category: 'Bán hàng',
        route: '/sell/refund',
        isEnabled: Const.refundOrder,
      ),

      // DMS
      SearchFeature(
        id: 'check_in',
        title: 'Check-in',
        description: 'Check-in khách hàng',
        icon: EneftyIcons.location_outline,
        category: 'DMS',
        route: '/dms/check-in',
        isEnabled: Const.checkIn,
      ),
      SearchFeature(
        id: 'inventory',
        title: 'Kiểm kê HH',
        description: 'Kiểm kê tồn kho hàng hoá',
        icon: Icons.inventory_2,
        category: 'DMS',
        route: '/dms/inventory',
        isEnabled: Const.inventory,
      ),
      SearchFeature(
        id: 'sale_out',
        title: 'Sale Out',
        description: 'Bán hàng tại điểm bán',
        icon: Icons.point_of_sale,
        category: 'DMS',
        route: '/dms/sale-out',
        isEnabled: Const.saleOut,
      ),
      SearchFeature(
        id: 'kpi_report',
        title: 'KPI',
        description: 'Xem báo cáo KPI',
        icon: MdiIcons.chartBar,
        category: 'DMS',
        route: '/dms/kpi',
        isEnabled: Const.reportKPI,
      ),
      SearchFeature(
        id: 'open_store',
        title: 'Mở mới ĐB',
        description: 'Tạo điểm bán mới',
        icon: EneftyIcons.shop_add_outline,
        category: 'DMS',
        route: '/dms/open-store',
        isEnabled: Const.openStore,
      ),
      SearchFeature(
        id: 'customer_dms',
        title: 'KH DMS',
        description: 'Quản lý khách hàng DMS',
        icon: Icons.people,
        category: 'DMS',
        route: '/dms/customer',
        isEnabled: Const.infoCustomerDMS,
      ),
      SearchFeature(
        id: 'delivery_plan',
        title: 'Giao hàng',
        description: 'Lập kế hoạch giao hàng',
        icon: Icons.local_shipping,
        category: 'DMS',
        route: '/dms/delivery-plan',
        isEnabled: Const.deliveryPlan,
      ),
      SearchFeature(
        id: 'delivery',
        title: 'Giao vận',
        description: 'Giao vận',
        icon: Icons.delivery_dining,
        category: 'DMS',
        route: '/dms/delivery',
        isEnabled: Const.delivery,
      ),

      // Nhân sự
      SearchFeature(
        id: 'personnel',
        title: 'Nhân sự',
        description: 'Quản lý nhân sự và chấm công',
        icon: EneftyIcons.personalcard_outline,
        category: 'Nhân sự',
        route: '/personnel',
        isEnabled: Const.hrm,
      ),
      SearchFeature(
        id: 'time_keeping',
        title: 'Chấm công',
        description: 'Chấm công',
        icon: Icons.access_time,
        category: 'Nhân sự',
        route: '/personnel/time-keeping',
        isEnabled: Const.timeKeeping,
      ),
      SearchFeature(
        id: 'day_off',
        title: 'Đề xuất',
        description: 'Đăng ký nghỉ phép, tăng ca, công tác',
        icon: Icons.event_busy,
        category: 'Nhân sự',
        route: '/personnel/day-off',
        isEnabled: Const.dayOff,
      ),
      SearchFeature(
        id: 'overtime',
        title: 'Tăng ca',
        description: 'Đăng ký tăng ca',
        icon: Icons.schedule,
        category: 'Nhân sự',
        route: '/personnel/overtime',
        isEnabled: Const.overTime,
      ),

      // Menu
      SearchFeature(
        id: 'report',
        title: 'Báo cáo',
        description: 'Xem báo cáo tổng hợp',
        icon: MdiIcons.chartBar,
        category: 'Menu',
        route: '/menu/report',
        isEnabled: Const.report,
      ),
      SearchFeature(
        id: 'approval',
        title: 'Duyệt phiếu',
        description: 'Duyệt các phiếu yêu cầu',
        icon: MdiIcons.calendarCheckOutline,
        category: 'Menu',
        route: '/menu/approval',
        isEnabled: Const.approval,
      ),
      SearchFeature(
        id: 'approve_order',
        title: 'Duyệt ĐH',
        description: 'Duyệt đơn hàng',
        icon: Icons.app_registration,
        category: 'Menu',
        route: '/menu/approve-order',
        isEnabled: Const.approveOrder,
      ),
      const SearchFeature(
        id: 'settings',
        title: 'Cài đặt',
        description: 'Cài đặt ứng dụng',
        icon: Icons.settings_outlined,
        category: 'Menu',
        route: '/menu/settings',
        isEnabled: true,
      ),

      // Additional features based on permissions
      SearchFeature(
        id: 'business_trip',
        title: 'Công tác',
        description: 'Đăng ký công tác',
        icon: Icons.business_center,
        category: 'Nhân sự',
        route: '/personnel/business-trip',
        isEnabled: Const.businessTrip,
      ),
      SearchFeature(
        id: 'advance_request',
        title: 'Tạm ứng',
        description: 'Đăng ký tạm ứng',
        icon: Icons.account_balance_wallet,
        category: 'Nhân sự',
        route: '/personnel/advance-request',
        isEnabled: Const.advanceRequest,
      ),
      SearchFeature(
        id: 'car_request',
        title: 'Điều xe',
        description: 'Đăng ký điều xe',
        icon: Icons.directions_car,
        category: 'Nhân sự',
        route: '/personnel/car-request',
        isEnabled: Const.carRequest,
      ),
      SearchFeature(
        id: 'meeting_room',
        title: 'Phòng họp',
        description: 'Đặt phòng họp',
        icon: Icons.meeting_room,
        category: 'Nhân sự',
        route: '/personnel/meeting-room',
        isEnabled: Const.meetingRoom,
      ),
      SearchFeature(
        id: 'table_time_keeping',
        title: 'Bảng chấm công',
        description: 'Xem bảng chấm công',
        icon: Icons.table_chart,
        category: 'Nhân sự',
        route: '/personnel/table-time-keeping',
        isEnabled: Const.tableTimeKeeping,
      ),
      SearchFeature(
        id: 'on_leave',
        title: 'Nghỉ phép',
        description: 'Quản lý nghỉ phép',
        icon: Icons.event_busy,
        category: 'Nhân sự',
        route: '/personnel/on-leave',
        isEnabled: Const.onLeave,
      ),
      SearchFeature(
        id: 'recommend_spending',
        title: 'Đề nghị chi',
        description: 'Đề nghị chi phí',
        icon: Icons.money_off,
        category: 'Nhân sự',
        route: '/personnel/recommend-spending',
        isEnabled: Const.recommendSpending,
      ),
      SearchFeature(
        id: 'article_car',
        title: 'Điều xe',
        description: 'Quản lý điều xe',
        icon: Icons.drive_eta,
        category: 'Nhân sự',
        route: '/personnel/article-car',
        isEnabled: Const.articleCar,
      ),
      SearchFeature(
        id: 'create_new_work',
        title: 'Tạo công việc mới',
        description: 'Tạo công việc mới',
        icon: Icons.work_outline,
        category: 'Nhân sự',
        route: '/personnel/create-new-work',
        isEnabled: Const.createNewWork,
      ),
      SearchFeature(
        id: 'work_assigned',
        title: 'Công việc được giao',
        description: 'Xem công việc được giao',
        icon: Icons.assignment,
        category: 'Nhân sự',
        route: '/personnel/work-assigned',
        isEnabled: Const.workAssigned,
      ),
      SearchFeature(
        id: 'my_work',
        title: 'Công việc của tôi',
        description: 'Xem công việc của tôi',
        icon: Icons.work,
        category: 'Nhân sự',
        route: '/personnel/my-work',
        isEnabled: Const.myWork,
      ),
      SearchFeature(
        id: 'work_involved',
        title: 'Công việc tham gia',
        description: 'Xem công việc tham gia',
        icon: Icons.group_work,
        category: 'Nhân sự',
        route: '/personnel/work-involved',
        isEnabled: Const.workInvolved,
      ),
      SearchFeature(
        id: 'info_employee',
        title: 'Thông tin nhân viên',
        description: 'Xem thông tin nhân viên',
        icon: Icons.person_outline,
        category: 'Nhân sự',
        route: '/personnel/info-employee',
        isEnabled: Const.infoEmployee,
      ),
      SearchFeature(
        id: 'stage_statistic',
        title: 'Thống kê công đoạn',
        description: 'Xem thống kê công đoạn',
        icon: MdiIcons.chartLine,
        category: 'Menu',
        route: '/menu/stage-statistic',
        isEnabled: Const.stageStatistic,
      ),
      SearchFeature(
        id: 'stage_statistic_v2',
        title: 'Thống kê công đoạn V2',
        description: 'Xem thống kê công đoạn phiên bản 2',
        icon: MdiIcons.chartLineVariant,
        category: 'Menu',
        route: '/menu/stage-statistic-v2',
        isEnabled: Const.stageStatisticV2,
      ),
      SearchFeature(
        id: 'list_voucher',
        title: 'Danh sách phiếu',
        description: 'Xem danh sách phiếu',
        icon: Icons.list_alt,
        category: 'Menu',
        route: '/menu/list-voucher',
        isEnabled: Const.listVoucher,
      ),
      SearchFeature(
        id: 'ticket',
        title: 'Vé',
        description: 'Quản lý vé',
        icon: Icons.confirmation_number,
        category: 'DMS',
        route: '/dms/ticket',
        isEnabled: Const.ticket,
      ),
      SearchFeature(
        id: 'care_diary_customer_dms',
        title: 'Nhật ký CSKH DMS',
        description: 'Nhật ký chăm sóc khách hàng DMS',
        icon: Icons.notes,
        category: 'DMS',
        route: '/dms/care-diary-customer',
        isEnabled: Const.careDiaryCustomerDMS,
      ),
      SearchFeature(
        id: 'itinerary',
        title: 'Giám sát hành trình',
        description: 'Giám sát hành trình',
        icon: Icons.route,
        category: 'DMS',
        route: '/dms/itinerary',
        isEnabled: Const.itinerary,
      ),
      SearchFeature(
        id: 'refund_order_sale_out',
        title: 'Hàng bán trả lại Sale Out',
        description: 'Quản lý hàng bán trả lại Sale Out',
        icon: Icons.assignment_returned,
        category: 'DMS',
        route: '/dms/refund-order-sale-out',
        isEnabled: Const.refundOrderSaleOut,
      ),
      SearchFeature(
        id: 'create_task_from_customer',
        title: 'Tạo task từ khách hàng',
        description: 'Tạo task từ thông tin khách hàng',
        icon: Icons.task_alt,
        category: 'DMS',
        route: '/dms/create-task-from-customer',
        isEnabled: Const.createTaskFromCustomer,
      ),

      // Additional DMS functions found in the app
      SearchFeature(
        id: 'point_of_sale',
        title: 'Các điểm phân phối',
        description: 'Quản lý các điểm phân phối',
        icon: Icons.store,
        category: 'DMS',
        route: '/dms/point-of-sale',
        isEnabled: Const.pointOfSale,
      ),
      SearchFeature(
        id: 'order_status_place',
        title: 'Trạng thái đơn hàng đã đặt',
        description: 'Xem trạng thái đơn hàng đã đặt',
        icon: Icons.local_grocery_store_outlined,
        category: 'DMS',
        route: '/dms/order-status-place',
        isEnabled: Const.orderStatusPlace,
      ),
      SearchFeature(
        id: 'refund_order_sale_out_history',
        title: 'Lịch sử hàng trả lại Sale Out',
        description: 'Xem lịch sử hàng trả lại Sale Out',
        icon: MdiIcons.history,
        category: 'DMS',
        route: '/dms/refund-order-sale-out-history',
        isEnabled: Const.refundOrderSaleOut,
      ),
      SearchFeature(
        id: 'care_diary_customer_dms',
        title: 'Lịch sử CSKH',
        description: 'Xem lịch sử chăm sóc khách hàng',
        icon: MdiIcons.whatsapp,
        category: 'DMS',
        route: '/dms/care-diary-customer',
        isEnabled: Const.careDiaryCustomerDMS,
      ),
      SearchFeature(
        id: 'ticket',
        title: 'Ticket',
        description: 'Quản lý ticket',
        icon: MdiIcons.calendarTextOutline,
        category: 'DMS',
        route: '/dms/ticket',
        isEnabled: Const.ticket,
      ),
      SearchFeature(
        id: 'itinerary',
        title: 'Giám sát hành trình',
        description: 'Giám sát hành trình giao hàng',
        icon: MdiIcons.mapLegend,
        category: 'DMS',
        route: '/dms/itinerary',
        isEnabled: Const.itinerary,
      ),

      // Additional Personnel functions found in the app
      SearchFeature(
        id: 'create_new_work',
        title: 'Thêm mới công việc',
        description: 'Tạo công việc mới',
        icon: Icons.note_add,
        category: 'Nhân sự',
        route: '/personnel/create-new-work',
        isEnabled: Const.createNewWork,
      ),
      SearchFeature(
        id: 'work_assigned',
        title: 'Công việc tôi giao',
        description: 'Xem công việc tôi đã giao',
        icon: MdiIcons.pencilBoxMultipleOutline,
        category: 'Nhân sự',
        route: '/personnel/work-assigned',
        isEnabled: Const.workAssigned,
      ),
      SearchFeature(
        id: 'my_work',
        title: 'Công việc của tôi',
        description: 'Xem công việc của tôi',
        icon: MdiIcons.timetable,
        category: 'Nhân sự',
        route: '/personnel/my-work',
        isEnabled: Const.myWork,
      ),
      SearchFeature(
        id: 'work_involved',
        title: 'Công việc tôi liên quan',
        description: 'Xem công việc tôi liên quan',
        icon: Icons.fact_check,
        category: 'Nhân sự',
        route: '/personnel/work-involved',
        isEnabled: Const.workInvolved,
      ),
      SearchFeature(
        id: 'info_employee',
        title: 'Thông tin nhân viên',
        description: 'Xem thông tin nhân viên',
        icon: MdiIcons.accountDetailsOutline,
        category: 'Nhân sự',
        route: '/personnel/info-employee',
        isEnabled: Const.infoEmployee,
      ),
    ];
  }

  // Danh sách các chức năng có thể thêm vào quick access
  // Lấy tất cả chức năng từ search features và chuyển đổi thành quick access features
  List<QuickAccessFeature> getAvailableQuickAccessFeatures() {
    final searchFeatures = getAllSearchFeatures();
    final quickAccessFeatures = <QuickAccessFeature>[];
    
    for (int i = 0; i < searchFeatures.length; i++) {
      final feature = searchFeatures[i];
      quickAccessFeatures.add(
        QuickAccessFeature(
          id: feature.id,
          title: feature.title, // Use original title for available functions list
          icon: feature.icon,
          route: feature.route,
          isEnabled: feature.isEnabled,
          order: i + 1,
        ),
      );
    }
    
    return quickAccessFeatures;
  }


  // Tìm kiếm features
  List<SearchFeature> searchFeatures(String query) {
    if (query.isEmpty) return [];
    
    final allFeatures = getAllSearchFeatures();
    final lowercaseQuery = query.toLowerCase();
    
    return allFeatures.where((feature) {
      return feature.isEnabled && (
        feature.title.toLowerCase().contains(lowercaseQuery) ||
        feature.description.toLowerCase().contains(lowercaseQuery) ||
        feature.category.toLowerCase().contains(lowercaseQuery)
      );
    }).toList();
  }

  // Lấy feature theo ID
  SearchFeature? getFeatureById(String id) {
    final allFeatures = getAllSearchFeatures();
    try {
      return allFeatures.firstWhere((feature) => feature.id == id);
    } catch (e) {
      return null;
    }
  }

  // Lấy features theo category
  List<SearchFeature> getFeaturesByCategory(String category) {
    return getAllSearchFeatures()
        .where((feature) => feature.category == category && feature.isEnabled)
        .toList();
  }

  // Lấy categories
  List<String> getCategories() {
    final categories = getAllSearchFeatures()
        .where((feature) => feature.isEnabled)
        .map((feature) => feature.category)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
