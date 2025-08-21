// ignore_for_file: library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/screen/menu/report/report_layout/report_bloc.dart';
import 'package:dms/screen/menu/report/report_layout/report_event.dart';
import 'package:dms/screen/menu/report/report_layout/report_sate.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/utils.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../model/network/response/report_info_response.dart';
import '../../component/value_report_filter.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with TickerProviderStateMixin {

  late TabController tabController;
  late ReportBloc _reportBloc;
  bool show = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 0, vsync: this);
    _reportBloc = ReportBloc(context);
    _reportBloc.add(GetPrefs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<ReportBloc, ReportState>(
          bloc: _reportBloc,
          listener: (context, state) {
            if(state is GetPrefsSuccess){
              _reportBloc.add(GetListReports(isRefresh: true));
            }
            if (state is GetListReportSuccess) {
              tabController = TabController(vsync: this, length: _reportBloc.listTabViewReport.length);
              show = true;
            }
            if (state is GetListReportLayoutSuccess) {
              PersistentNavBarNavigator.pushNewScreen(context, screen: ValueReportFilter(
                listRPLayout: _reportBloc.listDataReportLayout,
                idReport: state.idReport,
                title: state.titleReport,
              ),withNavBar: false);
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => ValueReportFilter(
              //       listRPLayout: _reportBloc.listDataReportLayout,
              //       idReport: state.idReport,
              //       title: state.titleReport,
              //     )));
            }
          },
          child: BlocBuilder<ReportBloc, ReportState>(
            bloc: _reportBloc,
            builder: (BuildContext context, ReportState state) {
              return Stack(
                children: [
                  buildBody(context, state),
                  Visibility(
                    visible: state is LoadingReport,
                    child: const PendingAction(),
                  ),
                ],
              );
            },
          ),
        )
    );
  }

  buildAppBar(){
    return Container(
      height: 153,
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
      child: Column(
        children: [
          Row(
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
                child: Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Báo cáo tổng hợp",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                      maxLines: 1,overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10,),
            ],
          ),
          Visibility(
            visible: show == true,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Container(
                  padding: const EdgeInsets.all(4),
                  height: 43,
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(width: 0.8, color: white), borderRadius: const BorderRadius.all(Radius.circular(16))),
                  child: TabBar(
                    controller: tabController,
                    unselectedLabelColor: white,
                    labelColor: orange,
                    labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                    isScrollable: _reportBloc.listTabViewReport.length <= 3 ? false : true,
                    // indicatorPadding: EdgeInsets.only(top: 6,bottom: 6,right: 8,left: 8),

                    indicator:const BoxDecoration(color: white, borderRadius:  BorderRadius.all(Radius.circular(12))),
                    tabs: List<Widget>.generate(_reportBloc.listTabViewReport.length, (int index) {
                      return  Tab(
                        text: _reportBloc.listTabViewReport[index].toString(),
                      );
                    }),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  buildBody(BuildContext context,ReportState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: RefreshIndicator(
              color: mainColor,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 2));
               // _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
              },
              child: SizedBox(
                height: double.infinity,width: double.infinity,
                child: TabBarView(
                    controller: tabController,

                    children: List<Widget>.generate(_reportBloc.listTabViewReport.length, (int index) {
                      for (int i = 0; i <= _reportBloc.listTabViewReport.length; i++) {
                        if (i == index) {
                          return buildPageReport(context, _reportBloc.listDetailDataReport, index);
                        }
                      }
                      return const Text('');
                    })),
              ),
            ),
          ),const SizedBox(height: 10,),
        ],
      ),
    );
  }

  Widget buildPageReport(BuildContext context,  List<DetailDataReport> detailDataReport, int i) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: ListView.separated(
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _reportBloc.add(GetListReportLayout(detailDataReport[i].reportList![index].id.toString(),detailDataReport[i].reportList![index].name.toString()));
              },
              child: Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      detailDataReport[i].reportList![index].iconUrl!.isNotEmpty ? CachedNetworkImage(
                        imageUrl: detailDataReport[i].reportList![index].iconUrl.toString(),
                        fit: BoxFit.fitHeight,
                        height: 40,
                        width: 40,
                      ) : Container(),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detailDataReport[i].reportList![index].name.toString(),
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Visibility(
                              visible: !Utils.isEmpty(detailDataReport[i].reportList![index].desc.toString()) == true && detailDataReport[i].reportList![index].desc.toString() != 'null',
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  detailDataReport[i].reportList![index].desc.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: grey,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => Container(),
          itemCount: detailDataReport[i].reportList!.length),
    );
  }
}
