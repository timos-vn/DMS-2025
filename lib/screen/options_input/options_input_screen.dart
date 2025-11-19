import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../model/network/response/list_status_response.dart';
import '../../themes/colors.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';
import 'options_input_bloc.dart';
import 'options_input_event.dart';
import 'options_input_state.dart';


class OptionsFilterDate extends StatefulWidget {
  final List<ListStatusApprovalResponseData>? listStatus;

  final String? dateFrom;
  final String? dateTo;

  const OptionsFilterDate({Key? key, this.listStatus, this.dateFrom, this.dateTo}) : super(key: key);
  @override
  _OptionsFilterDateState createState() => _OptionsFilterDateState();
}

class _OptionsFilterDateState extends State<OptionsFilterDate> {

  late OptionsInputBloc _bloc;
  String statusTypeName = 'Chờ duyệt';
  int statusType = 0;
  String toDate ="";
  String fromDate="";
  ListStatusApprovalResponseData? itemData;

  String dateFrom = '';
  String dateTo = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = OptionsInputBloc(context);
    List<ListStatusApprovalResponseData> listStatus =widget.listStatus??[];

    if(widget.listStatus != null){

      // itemData = widget.listStatus?[0];
    }
    if(widget.dateFrom.toString().replaceAll('null', '').isNotEmpty){
      dateFrom =  widget.dateFrom.toString();
      _bloc.add(DateFrom(Utils.parseStringToDate(dateFrom, Const.DATE_FORMAT_2)));
    }else{
      dateFrom = DateTime.now().toString();
    }
    if(widget.dateTo.toString().replaceAll('null', '').isNotEmpty){
      dateTo =  widget.dateTo.toString();
      _bloc.add(DateTo(Utils.parseStringToDate(dateTo, Const.DATE_FORMAT_2)));
    }else{
      dateTo = DateTime.now().toString();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
        body: BlocListener<OptionsInputBloc,OptionsInputState>(
          bloc: _bloc,
            listener: (context, state){
              if (state is WrongDate) {
                Utils.showCustomToast(context, Icons.warning_amber_outlined, '\'Từ ngày\' phải là ngày trước \'Đến ngày\'');
              }else if(state is PickDateSuccess){
              }
            },
            child: BlocBuilder<OptionsInputBloc,OptionsInputState>(
              bloc: _bloc,
              builder: (BuildContext context, OptionsInputState state){
                return buildPage(context,state);
              },
            )
        )
    );
  }

  Widget buildPage(BuildContext context,OptionsInputState state){
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: subColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: subColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Bộ lọc',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Visibility(
              visible: widget.listStatus?.isNotEmpty == true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    'Trạng thái',
                    genderStatus2(),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    'Loại',
                    genderType(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          height: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'HOẶC',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          height: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Date Range Section
            _buildDateField(
              context,
              label: 'Từ ngày',
              date: Utils.parseStringDateToString(
                _bloc.dateFrom.toString(),
                Const.DATE_TIME_FORMAT,
                Const.DATE_FORMAT_1,
              ),
              icon: Icons.calendar_today_rounded,
              onTap: () {
                Utils.dateTimePickerCustom(context).then((value) {
                  if (value != null) {
                    setState(() {
                      _bloc.add(DateFrom(value));
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDateField(
              context,
              label: 'Đến ngày',
              date: Utils.parseStringDateToString(
                _bloc.dateTo.toString(),
                Const.DATE_TIME_FORMAT,
                Const.DATE_FORMAT_1,
              ),
              icon: Icons.event_available_rounded,
              onTap: () {
                Utils.dateTimePickerCustom(context).then((value) {
                  if (value != null) {
                    setState(() {
                      _bloc.add(DateTo(value));
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 28),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Hủy',
                    color: Colors.grey.shade300,
                    textColor: Colors.grey.shade700,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    label: 'Áp dụng',
                    color: subColor,
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.pop(context, [
                        statusType,
                        _bloc.statusCode,
                        '',
                        _bloc.getStringFromDateYMD(_bloc.dateFrom),
                        _bloc.getStringFromDateYMD(_bloc.dateTo),
                        statusTypeName,
                      ]);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required String date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: subColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (color == subColor)
                BoxShadow(
                  color: color.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }


  List<String> typeStatus = ['Chờ duyệt','Đã duyệt'];

  Widget genderType() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          icon: Icon(
            MdiIcons.sortVariant,
            size: 15,
            color: black,
          ),
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: statusTypeName,
          items: typeStatus.map((value) => DropdownMenuItem<String>(
            value: value,
            child: Align(
                alignment: Alignment.center,
                child: Text(value.toString(), style: TextStyle(fontSize: 13.0, color: blue.withOpacity(0.6)),)),
          )).toList(),
          onChanged: (value) {
            setState(() {
              statusTypeName = value!;
            });
            if(value == 'Chờ duyệt'){
              statusType = 1;
            }else if(value == 'Đã duyệt'){
              statusType = 2;
            }
          }),
    );
  }


  Widget genderStatus2() {
    return widget.listStatus?.isEmpty == true
        ? const Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12))
        : DropdownButtonHideUnderline(
          child: DropdownButton<ListStatusApprovalResponseData>(
          icon: Icon(
            MdiIcons.sortVariant,
            size: 15,
            color: black,
          ),
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: itemData,
          items: widget.listStatus?.map((value) => DropdownMenuItem<ListStatusApprovalResponseData>(
            value: value,
            child: Align(
                alignment: Alignment.center,
                child: Text(value.uStatusName.toString(), style: TextStyle(fontSize: 13.0, color: blue.withOpacity(0.6)),)),
          )).toList() ?? [],
          onChanged: (value) {
            setState(() {
              itemData = value;
            });
            _bloc.add(PickGenderStatus(statusCode:  int.parse(itemData!.uStatus.toString()),statusName: itemData?.uStatusName));
          }),
    );
  }
}
