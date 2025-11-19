import 'package:dms/screen/menu/report/result_report/result_report_bloc.dart';
import 'package:dms/screen/menu/report/result_report/result_report_event.dart';
import 'package:dms/screen/menu/report/result_report/result_report_state.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/utils.dart';
import '../../../../model/network/response/approval_detail_response.dart';

Map<String,dynamic> _dataMap =  {};
List<Map<String,dynamic>> _listValuesCells = [];
List<Map<String,dynamic>> _paginatedDataSource = [];
int _rowsPerPage = 20;
class ResultReportScreen extends StatefulWidget {
  final String idReport;
  final List<dynamic> listRequestValue;
  final String title;

  const ResultReportScreen({Key? key, required this.idReport, required this.listRequestValue, required this.title}) : super(key: key);
  @override
  _ResultReportScreenState createState() => _ResultReportScreenState();
}

class _ResultReportScreenState extends State<ResultReportScreen> {
  late ResultReportBloc _resultReportBloc;
  /// table
  SelectionMode selectionMode = SelectionMode.single;
  final DataGridController _dataGridController = DataGridController();
  final ColumnSizer _columnSizer = ColumnSizer();
  List<HeaderData> _listHeader = <HeaderData>[];
  AutoRowHeightDataGridSource _autoRowHeightDataGridSource = AutoRowHeightDataGridSource(listHeader: []);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _resultReportBloc = ResultReportBloc(context);
    _resultReportBloc.add(GetPrefs());
    if(!Utils.isEmpty(_listValuesCells)){
      _listValuesCells.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<ResultReportBloc, ResultReportState>(
            bloc: _resultReportBloc,
            listener: (context, state) {
              if(state is GetPrefsSuccess){
                _resultReportBloc.add(GetResultReportEvent(widget.idReport, widget.listRequestValue));
              }
              if (state is GetResultReportSuccess) {
                _listHeader = _resultReportBloc.listHeaderData;
                _dataMap = _resultReportBloc.dataMap2;
                _listValuesCells = _resultReportBloc.listValuesCells;
                // print('Check zalo ${_listValuesCells.length}');
                // print(_listValuesCells.length % _rowsPerPage);
                // print((int.parse((_listValuesCells.length % _rowsPerPage).toString().split('.')[1]) >= 1 ? (_listValuesCells.length / _rowsPerPage + 1) : _listValuesCells.length / _rowsPerPage ));
                _paginatedDataSource = _listValuesCells.getRange(0, ( (_listValuesCells.length))).toList(growable: false);
                _autoRowHeightDataGridSource = AutoRowHeightDataGridSource(listHeader: _listHeader);
              }
              if (state is ResultReportFailure) {}
            },
            child: BlocBuilder<ResultReportBloc, ResultReportState>(
              bloc: _resultReportBloc,
              builder: (BuildContext context, ResultReportState state) {
                return buildPage(context, state);
              },
            )));
  }

  buildAppBar(){
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor,Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.pop(context),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.event,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  Widget buildPage(BuildContext context, ResultReportState state) {
    return Stack(
      children: [
        Column(
          children: [
            buildAppBar(),
            Expanded(
              child: SfDataGridTheme(
            data: SfDataGridThemeData(
              // brightness: SfTheme.of(context).brightness,
              gridLineStrokeWidth: 1.0,
              headerHoverColor: const Color(0xFF9588D7).withOpacity(0.6),

             gridLineColor: subColor.withOpacity(0.4),
            ),
                child: SfDataGrid(
                columnWidthMode: ColumnWidthMode.auto,
                allowSorting: true,

                gridLinesVisibility: GridLinesVisibility.none,
                headerGridLinesVisibility: GridLinesVisibility.horizontal,
                selectionMode: selectionMode,
                controller: _dataGridController,
                onCellTap: (index){},
                source: _autoRowHeightDataGridSource,
                columnSizer: _columnSizer,
                    highlightRowOnHover: true,
                columns: List<GridColumn>.generate(_listHeader.length, (int index){
                  return  GridColumn(
                    label: Padding(
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Center(child: Text(_listHeader[index].name.toString().trim(),style: const TextStyle(color: subColor),)),
                    ),
                    columnName: _listHeader[index].field.toString().trim(),
                    visible: (_listHeader[index].field.toString().trim() == 'allowBold' || _listHeader[index].field.toString().trim() == 'AllowBold') ? false : true,
                    maximumWidth: 250,
                    columnWidthMode: ColumnWidthMode.none,
                  );
                })
            ),
          ),
        ),
            Container(
              height: 60,
              decoration: BoxDecoration(
              color: SfTheme.of(context).dataPagerThemeData.backgroundColor,
              border: const Border(
                  top: BorderSide(
                      width: .5,
                      color: Colors.grey),
                  bottom: BorderSide.none,
                  left: BorderSide.none,
                  right: BorderSide.none)),
              child: Align(alignment: Alignment.center, child: _autoRowHeightDataGridSource.listHeader.isNotEmpty ? _getDataPager() : Container()),
        )
      ],
    ),
        Visibility(
          visible: state is GetResultReportEmpty,
          child: const Center(
            child:Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),),
        ),
        Visibility(
          visible: state is ResultLoadingReport,
          child: const PendingAction(),
        ),
      ],
    );
  }

  Widget _getDataPager() {
    return SfDataPagerTheme(
      data: const SfDataPagerThemeData(
        // brightness: Brightness.light,
        selectedItemColor: subColor,
      ),
      child: SfDataPager(
        delegate: _autoRowHeightDataGridSource,
        direction: Axis.horizontal,
        pageCount: (int.parse((_listValuesCells.length / _rowsPerPage).toString().split('.')[1]) >= 1 ? (_listValuesCells.length / _rowsPerPage + 1) : _listValuesCells.length / _rowsPerPage ),
      ),
    );
  }
}
int indexRow = 0;
class AutoRowHeightDataGridSource extends DataGridSource {

  final List<HeaderData> listHeader;

  AutoRowHeightDataGridSource({required this.listHeader}) {
    buildPaginatedDataGridRows();
  }

  List<DataGridRow>  dataGrid = [];

  @override
  List<DataGridRow> get rows => dataGrid;

  void buildPaginatedDataGridRows() {

    List<DataGridRow> listDataGridRow=[];

    for (var element in _paginatedDataSource) {
      List<DataGridCell> listDataGridCell=[];
      for (var headerFiled in listHeader) {
        DataGridCell dataGridCell = DataGridCell(
            columnName: headerFiled.field.toString(),
            value: element[headerFiled.field].toString().trim(),
        );
        listDataGridCell.add(dataGridCell);
      }
      DataGridRow dataGridRow = DataGridRow(
          cells:  listDataGridCell
      );
      listDataGridRow.add(dataGridRow);
    }
    dataGrid = listDataGridRow;
  }

  int get rowCount => _listValuesCells.length;

  // @override
  // List<DataGridRow> get rows =>  listDataGridRow;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    TextStyle getStyleIndexFirst(){
       int index = dataGrid.indexOf(row);
        // print(dataGrid[index].getCells().first.value.toString().trim() == "0" ? 'OKE NE' : "FAIL NE");
        print(dataGrid[index].getCells().last.value.toString().trim());
       if(dataGrid[index].getCells().first.value.toString().trim() == "1"){
         return const TextStyle(fontWeight: FontWeight.bold,color: Colors.green);
       }else{
         return const TextStyle(fontWeight: FontWeight.normal);
       }
    }
    return DataGridRowAdapter(
        color: ((dataGrid.indexOf(row) + 1) % 2) == 0 ? const Color.fromARGB(1, 250, 250, 250) : Colors.white ,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(e.value.toString(),style:  getStyleIndexFirst(),),
          );
        }).toList());
  }

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    final int startIndex = newPageIndex * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    if (endIndex > _paginatedDataSource.length) {
      endIndex = _paginatedDataSource.length;
    }

    if((startIndex + _rowsPerPage) > _listValuesCells.length){
      _rowsPerPage = _listValuesCells.length % _rowsPerPage;
    }else{
      _rowsPerPage = 20;
    }

    _paginatedDataSource = _listValuesCells
        .getRange(startIndex, startIndex + _rowsPerPage)
        .toList(growable: false);
    // notifyDataSourceListeners();
    buildPaginatedDataGridRows();
    notifyListeners();
    return Future<bool>.value(true);
  }
  @override

  bool shouldRecalculateColumnWidths() {
    return true;
  }
}