import 'package:flutter/material.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../cart_bloc.dart';

class CartBottomTotal extends StatelessWidget {
  final CartBloc bloc;
  final TabController tabController;
  final VoidCallback onNextPressed;
  final VoidCallback onCreateOrderPressed;
  final bool isProcessing;

  const CartBottomTotal({
    Key? key,
    required this.bloc,
    required this.tabController,
    required this.onNextPressed,
    required this.onCreateOrderPressed,
    required this.isProcessing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
      decoration: const BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total price',
                style: TextStyle(color: grey, fontSize: 12.5),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${Utils.formatMoneyStringToDouble(bloc.totalPayment)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: isProcessing ? null : _handleButtonTap,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: tabController.index == 2 ? mainColor : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tabController.index == 2 ? 'Đặt hàng' : 'Tiếp tục',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleButtonTap() {
    if (tabController.index == 0 || tabController.index == 1) {
      // Navigate to next tab
      Future.delayed(const Duration(milliseconds: 200)).then(
        (value) => tabController.animateTo((tabController.index + 1) % 10),
      );
    } else {
      // Create order
      onCreateOrderPressed();
    }
  }
}

