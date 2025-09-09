import 'package:dms/screen/customer/manager_customer/manager_customer_screen.dart';
import 'package:dms/screen/dms/check_in/check_in_screen.dart';
import 'package:dms/screen/dms/component/list_customer_dms_screen.dart';
import 'package:dms/screen/dms/component/request_open_store.dart';
import 'package:dms/screen/dms/customer_care/customer_care_screen.dart';
import 'package:dms/screen/dms/delivery/delivery_plan/delivery_plan_screen.dart';
import 'package:dms/screen/dms/inventory/list_inventory_request_screen.dart';
import 'package:dms/screen/dms/kpi/kpi_screen.dart';
import 'package:dms/screen/dms/refund_sale_out/component/list_history_refund_sale_out_screen.dart';
import 'package:dms/screen/dms/sale_out/component/history_sale_out_screen.dart';
import 'package:dms/screen/dms/shipping/shipping_screen.dart';
import 'package:dms/screen/dms/ticket/ticket_screen.dart';
import 'package:dms/screen/menu/approval/approval/approval_screen.dart';
import 'package:dms/screen/menu/component/layout_voucher_screen.dart';
import 'package:dms/screen/menu/report/report_layout/report_screen.dart';
import 'package:dms/screen/menu/setting/profile.dart';
import 'package:dms/screen/personnel/component/employee_screen.dart';
import 'package:dms/screen/personnel/component/list_history_leave_letter.dart';
import 'package:dms/screen/personnel/personnel_screen.dart';
import 'package:dms/screen/personnel/proposal/proposal_screen.dart';
import 'package:dms/screen/personnel/suggestions/suggestions_screen.dart';
import 'package:dms/screen/personnel/time_keeping/time_keeping_screen.dart';
import 'package:dms/screen/sell/component/history_order.dart';
import 'package:dms/screen/sell/component/order_for_suggest/history_order_for_suggest.dart';
import 'package:dms/screen/sell/component/product_screen.dart';
import 'package:dms/screen/sell/contract/contract_screen.dart';
import 'package:dms/screen/sell/order/order_sceen.dart';
import 'package:dms/screen/sell/refund_order/component/list_history_refund_order_screen.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Navigate to screen based on route
  void navigateToRoute(BuildContext context, String route, Map<String, dynamic>? parameters) {
    switch (route) {
      // Sell routes
      case '/sell/order':
        _navigateToSellOrder(context);
        break;
      case '/sell/history':
        _navigateToSellHistory(context, parameters);
        break;
      case '/sell/product':
        _navigateToSellProduct(context);
        break;
      case '/sell/customer':
        _navigateToSellCustomer(context);
        break;
      case '/sell/contract':
        _navigateToSellContract(context);
        break;
      case '/sell/refund':
        _navigateToSellRefund(context);
        break;

      // DMS routes
      case '/dms/check-in':
        _navigateToDMSCheckIn(context, parameters);
        break;
      case '/dms/inventory':
        _navigateToDMSInventory(context);
        break;
      case '/dms/sale-out':
        _navigateToDMSSaleOut(context);
        break;
      case '/dms/kpi':
        _navigateToDMSKPI(context);
        break;
      case '/dms/open-store':
        _navigateToDMSOpenStore(context);
        break;
      case '/dms/customer':
        _navigateToDMSCustomer(context);
        break;
      case '/dms/delivery-plan':
        _navigateToDMSDeliveryPlan(context);
        break;
      case '/dms/delivery':
        _navigateToDMSDelivery(context);
        break;
      case '/dms/customer-care':
        _navigateToDMSCustomerCare(context);
        break;
      case '/dms/ticket':
        _navigateToDMSTicket(context);
        break;
      case '/dms/refund-sale-out':
        _navigateToDMSRefundSaleOut(context);
        break;

      // Personnel routes
      case '/personnel':
        _navigateToPersonnel(context);
        break;
      case '/personnel/time-keeping':
        _navigateToPersonnelTimeKeeping(context);
        break;
      case '/personnel/day-off':
        _navigateToPersonnelDayOff(context);
        break;
      case '/personnel/overtime':
        _navigateToPersonnelOvertime(context);
        break;
      case '/personnel/proposal':
        _navigateToPersonnelProposal(context);
        break;
      case '/personnel/suggestions':
        _navigateToPersonnelSuggestions(context);
        break;

      // Menu routes
      case '/menu/report':
        _navigateToMenuReport(context);
        break;
      case '/menu/approval':
        _navigateToMenuApproval(context);
        break;
      case '/menu/approve-order':
        _navigateToMenuApproveOrder(context);
        break;
      case '/menu/settings':
        _navigateToMenuSettings(context);
        break;
      case '/menu/voucher':
        _navigateToMenuVoucher(context);
        break;

      default:
        // Handle unknown routes
        break;
    }
  }

  // Sell navigation methods
  void _navigateToSellOrder(BuildContext context) {
    if (Const.createNewOrder == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const OrderScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToSellHistory(BuildContext context, Map<String, dynamic>? parameters) {
    if (Const.historyOrder == true) {
      final userId = parameters?['userId'] ?? Const.userId.toString();
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: HistoryOrderScreen(userId: userId),
        withNavBar: true,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToSellProduct(BuildContext context) {
    if (Const.infoProduction == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ProductScreen(),
        withNavBar: true,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToSellCustomer(BuildContext context) {
    if (Const.infoCustomerSell == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ManagerCustomerScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToSellContract(BuildContext context) {
    if (Const.contract == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ContractScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToSellRefund(BuildContext context) {
    if (Const.refundOrder == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ListHistoryRefundOrderScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  // DMS navigation methods
  void _navigateToDMSCheckIn(BuildContext context, Map<String, dynamic>? parameters) {
    if (Const.checkIn == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: CheckInScreen(
          reloadData: false,
          listCheckInToDay: const [],
          listAlbumOffline: const [],
          listAlbumTicketOffLine: const [],
          userId: Const.userId.toString(),
        ),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToDMSInventory(BuildContext context) {
    if (Const.inventory == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ListInventoryRequestScreen(),
        withNavBar: true,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToDMSSaleOut(BuildContext context) {
    if (Const.saleOut == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const HistorySaleOutScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToDMSKPI(BuildContext context) {
    if (Const.reportKPI == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const KPIScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToDMSOpenStore(BuildContext context) {
    if (Const.openStore == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const RequestOpenStoreScreen(),
        withNavBar: true,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToDMSCustomer(BuildContext context) {
    if (Const.infoCustomerDMS == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ListCustomerDMSScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToDMSDeliveryPlan(BuildContext context) {
    if (Const.deliveryPlan == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const DeliveryPlanScreen(),
        withNavBar: true,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToDMSDelivery(BuildContext context) {
    if (Const.delivery == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ShippingScreen(),
        withNavBar: true,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToDMSCustomerCare(BuildContext context) {
    if (Const.careDiaryCustomerDMS == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const CustomerCareScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToDMSTicket(BuildContext context) {
    if (Const.ticket == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const TicketHistoryScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToDMSRefundSaleOut(BuildContext context) {
    if (Const.refundOrderSaleOut == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ListHistoryRefundSaleOutScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  // Personnel navigation methods
  void _navigateToPersonnel(BuildContext context) {
    if (Const.hrm == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const PersonnelScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToPersonnelTimeKeeping(BuildContext context) {
    if (Const.timeKeeping == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const TimeKeepingScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToPersonnelDayOff(BuildContext context) {
    if (Const.dayOff == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const HistoryLeaveLetterScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToPersonnelOvertime(BuildContext context) {
    if (Const.overTime == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const SuggestionsScreen(
          keySuggestion: 2,
          title: 'Tăng ca',
        ),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToPersonnelProposal(BuildContext context) {
    if (Const.advanceRequest == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ProposalScreen(
          title: 'Đề nghị tạm ứng',
          controller: 'AdvanceRequest',
        ),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToPersonnelSuggestions(BuildContext context) {
    if (Const.businessTrip == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const SuggestionsScreen(
          keySuggestion: 3,
          title: 'Đề xuất công tác',
        ),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  // Menu navigation methods
  void _navigateToMenuReport(BuildContext context) {
    if (Const.report == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ReportScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToMenuApproval(BuildContext context) {
    if (Const.approval == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ApprovalScreen(),
        withNavBar: true,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToMenuApproveOrder(BuildContext context) {
    if (Const.approveOrder == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const EmployeeScreen(typeView: 1),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }

  void _navigateToMenuSettings(BuildContext context) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const ProfileScreen(),
      withNavBar: false,
    );
  }

  void _navigateToMenuVoucher(BuildContext context) {
    if (Const.listVoucher == true) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const LayOutVoucherScreen(),
        withNavBar: false,
      );
    } else {
      Utils.showUpgradeAccount(context);
    }
  }
}
