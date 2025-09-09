import 'package:dms/screen/customer/search_customer/search_customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../../themes/colors.dart';
import '../../../../../widget/text_field_widget2.dart';
import '../../../sell/component/input_address_popup.dart';
import '../../../../model/network/response/manager_customer_response.dart';

class CustomerInfoSection extends StatelessWidget {
  final TextEditingController nameCustomerController;
  final TextEditingController addressCustomerController;
  final TextEditingController phoneCustomerController;
  final FocusNode nameCustomerFocus;
  final FocusNode addressCustomerFocus;
  final FocusNode phoneCustomerFocus;
  final Function(ManagerCustomerResponseData) onCustomerSelected;
  final Function(String) onAddressChanged;

  const CustomerInfoSection({
    Key? key,
    required this.nameCustomerController,
    required this.addressCustomerController,
    required this.phoneCustomerController,
    required this.nameCustomerFocus,
    required this.addressCustomerFocus,
    required this.phoneCustomerFocus,
    required this.onCustomerSelected,
    required this.onAddressChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        _buildCustomerInfoContainer(context),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 6),
      child: Row(
        children: [
          Icon(MdiIcons.informationOutline, color: mainColor),
          const SizedBox(width: 10),
          const Text(
            'Thông tin khách hàng',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Thông tin chi tiết:',
            style: TextStyle(
              color: mainColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: subColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildContainerHeader(),
                const SizedBox(height: 22),
                _buildCustomerNameField(context),
                _buildPhoneField(),
                _buildAddressField(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerHeader() {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 40,
      width: double.infinity,
      color: Colors.amber.withOpacity(0.4),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Thông tin khách hàng',
          style: TextStyle(color: Colors.black, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildCustomerNameField(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToSearchCustomer(context),
      child: Stack(
        children: [
          _buildInputField(
            title: 'Tên khách hàng',
            hintText: "Nguyễn Văn A",
            controller: nameCustomerController,
            focusNode: nameCustomerFocus,
            isEnabled: false,
          ),
          const Positioned(
            top: 20,
            right: 10,
            child: Icon(Icons.search_outlined, color: Colors.grey, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return _buildInputField(
      title: "SĐT khách hàng",
      hintText: '0963 xxx xxx',
      controller: phoneCustomerController,
      focusNode: phoneCustomerFocus,
      isPhone: true,
    );
  }

  Widget _buildAddressField(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddressDialog(context),
      child: Stack(
        children: [
          _buildInputField(
            title: 'Địa chỉ khách hàng',
            hintText: "Vui lòng nhập địa chỉ KH",
            controller: addressCustomerController,
            focusNode: addressCustomerFocus,
            isEnabled: false,
          ),
          const Positioned(
            top: 20,
            right: 10,
            child: Icon(Icons.edit, color: Colors.grey, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isEnabled = true,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFieldWidget2(
              controller: controller,
              textInputAction: TextInputAction.done,
              isEnable: isEnabled,
              keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
              hintText: hintText,
              focusNode: focusNode,
              isNull: true,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSearchCustomer(BuildContext context) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const SearchCustomerScreen(
        selected: true,
        allowCustomerSearch: false,
        inputQuantity: false,
      ),
      withNavBar: false,
    ).then((value) {
      if (value != null) {
        ManagerCustomerResponseData infoCustomer = value;
        onCustomerSelected(infoCustomer);
      }
    });
  }

  void _showAddressDialog(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return InputAddressPopup(
          note: addressCustomerController.text.isNotEmpty
              ? addressCustomerController.text
              : "",
          title: 'Địa chỉ KH',
          desc: 'Vui lòng nhập địa chỉ KH',
          convertMoney: false,
          inputNumber: false,
        );
      },
    ).then((note) {
      if (note != null) {
        onAddressChanged(note);
      }
    });
  }
}

